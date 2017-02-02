#!/bin/bash

# Get the current timestamp and append to logfile name
source /etc/bashrc
TIMESTAMP=$(date "+%Y-%m-%d-%H%M")
logTag="run_fortify_script_output"
fortifyLogDir="/home/cons3rt/fortify/logs"
fortifyLogFile="${fortifyLogDir}/${logTag}-${TIMESTAMP}.log"
resultSet=()

# Set the default memory allocation to autoheap
defaultFortifyMemoryAllocation="-autoheap"
fortifyMemoryAllocation=

# Set up the log file
mkdir -p ${fortifyLogDir}
chmod 700 ${fortifyLogDir}
touch ${fortifyLogFile}
chmod 644 ${fortifyLogFile}

function logInfo() {
    logger -i -s -p local3.info -t ${logTag} -- [INFO] "${1}"
    timeStamp=$(date "+%Y-%m-%d-%H%M")
    echo -e "${timeStamp} -- [INFO]: ${1}" >> ${fortifyLogFile}
    echo -e "${timeStamp} -- [INFO]: ${1}"
}

function logWarn() {
    logger -i -s -p local3.warning -t ${logTag} -- [WARN] "${1}"
    timeStamp=$(date "+%Y-%m-%d-%H%M")
    echo -e "${timeStamp} -- [WARN]: ${1}" >> ${fortifyLogFile}
    echo -e "${timeStamp} -- [WARN]: ${1}"
}

function logErr() {
    logger -i -s -p local3.err -t ${logTag} -- [ERROR] "${1}"
    timeStamp=$(date "+%Y-%m-%d-%H%M")
    echo -e "${timeStamp} -- [ERROR]: ${1}" >> ${fortifyLogFile}
    echo -e "${timeStamp} -- [ERROR]: ${1}"
}

function set_asset_dir() {
    # Ensure ASSET_DIR exists, if not assume this script exists in ASSET_DIR/scripts
    if [ -z "${ASSET_DIR}" ] ; then
        logWarn "ASSET_DIR not found, assuming ASSET_DIR is 1 level above this script ..."
        SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        export ASSET_DIR="${SCRIPT_DIR}/.."
    fi
}

function set_deployment_home() {
    # Ensure DEPLOYMENT_HOME exists
    if [ -z "${DEPLOYMENT_HOME}" ] ; then
        logWarn "DEPLOYMENT_HOME is not set, attempting to determine..."
        deploymentDirCount=$(ls /opt/cons3rt-agent/run | grep Deployment | wc -l)
        # Ensure only 1 deployment directory was found
        if [ ${deploymentDirCount} -ne 1 ] ; then
            logErr "Could not determine DEPLOYMENT_HOME"
            return 1
        fi
        # Get the full path to deployment home
        deploymentDir=$(ls /opt/cons3rt-agent/run | grep "Deployment")
        deploymentHome="/opt/cons3rt-agent/run/${deploymentDir}"
        export DEPLOYMENT_HOME="${deploymentHome}"
    else
        deploymentHome="${DEPLOYMENT_HOME}"
    fi
}

function read_deployment_properties() {
    local deploymentPropertiesFile="${DEPLOYMENT_HOME}/deployment-properties.sh"
    if [ ! -f ${deploymentPropertiesFile} ] ; then
        logErr "Deployment properties file not found: ${deploymentPropertiesFile}"
        return 1
    fi
    source ${deploymentPropertiesFile}
    return $?
}

function get_fortify_memory_allocation() {
    if [ -z "${FORTIFY_MEMORY_IN_MB}" ] ; then
        logInfo "No custom property for FORTIFY_MEMORY_IN_MB defined, using the default: ${defaultFortifyMemoryAllocation}"
        fortifyMemoryAllocation="${defaultFortifyMemoryAllocation}"
    else
        logInfo "Found custom property set for FORTIFY_MEMORY_IN_MB set to: ${FORTIFY_MEMORY_IN_MB}"
        fortifyMemoryAllocation="-Xmx ${FORTIFY_MEMORY_IN_MB}M"
    fi
}

function run_and_check_status() {
    local command="$@"
    ${command}
    local status=$?
    if [ ${status} -ne 0 ] ; then
        logErr "Error executing: ${command}, exited with code: ${status}"
    else
        logInfo "${command} executed successfully and exited with code: ${status}"
    fi
    resultSet+=("${status}")
    return ${status}
}

function update_fortify_definitions() {

    fortifyUpdateLogFile="${logDir}/Fortify-Installed-Rules-${TIMESTAMP}.log"

    # Run fortifyupdate to get the latest Virus definitions
    logInfo "Updating Fortify to the latest definitions..."
    echo "-----------------------------" >> ${fortifyUpdateLogFile}
    echo "Fortify Installed Rules Info: ${TIMESTAMP}" >> ${fortifyUpdateLogFile}
    echo "-----------------------------" >> ${fortifyUpdateLogFile}
    echo "Output from running fortifyupdate:" >> ${fortifyUpdateLogFile}
    run_and_check_status /usr/local/bin/fortifyupdate >> ${fortifyUpdateLogFile} 2>&1

    logInfo "Logging installed rules to: ${fortifyUpdateLogFile}"

    echo "-----------------------------" >> ${fortifyUpdateLogFile}
    echo "Listing installed rules:" >> ${fortifyUpdateLogFile}
    /usr/local/bin/fortifyupdate -showInstalledRules >> ${fortifyUpdateLogFile} 2>&1

    logInfo "Logging installed external meta data to: ${fortifyUpdateLogFile}"

    echo "-----------------------------" >> ${fortifyUpdateLogFile}
    echo "Listing installed external meta data:" >> ${fortifyUpdateLogFile}
    /usr/local/bin/fortifyupdate -showInstalledExternalMetadata >> ${fortifyUpdateLogFile} 2>&1
}

function run_fortify() {

    # Set ASSET_DIR and DEPLOYMENT_HOME
    logInfo "Setting ASSET_DIR, DEPLOYMENT_HOME, and reading deployment properties..."
    set_asset_dir
    set_deployment_home
    read_deployment_properties

    # Update Fortify definitions
    update_fortify_definitions

    # Read the FORTIFY_MEMORY_IN_MB custom property
    logInfo "Determining fortify memory allocation"
    get_fortify_memory_allocation

    # Used for debugging of env variables based in by fortify adapter
    envVars=$(printenv)
    logInfo "Environment variables:\n${envVars}"
    echo ${envVars} >> ${logDir}environment_out.log

    # Begin build process
    logInfo "Beginning the Fortify build of ${sourceDir}"
    run_and_check_status "${sourceanalyzer}" -clean
    run_and_check_status "${sourceanalyzer}" -b "${buildId}" "${sourceDir}" -logfile "${logDir}${buildId}-build.log" "${fortifyDebug}" "${fortifyMemoryAllocation}"

    # Capture build warnings and show the files in the build
    logInfo "Writing warnings to: ${logDir}${buildId}-buildWarnings.log..."
    run_and_check_status "${sourceanalyzer}" -b "${buildId}" -show-build-warnings -logfile "${logDir}${buildId}-buildWarnings.log" "${fortifyDebug}"

    # List the build files
    logInfo "Listing build files to ${logDir}${buildId}-showfiles.log..."
    run_and_check_status "${sourceanalyzer}" -b "${buildId}" -show-files -logfile "${logDir}${buildId}-showfiles.log" "${fortifyDebug}"

    # Perform scan
    logInfo "Starting the Fortify scan..."
    run_and_check_status "${sourceanalyzer}" -b "${buildId}" -scan -f "${reportDir}${buildId}-scan.fpr" -logfile "${logDir}${buildId}-scan.log" "${fortifyDebug}" "${fortifyMemoryAllocation}"

    # Generate report from scan results
    logInfo "Generating report: ${reportDir}${buildId}-results.pdf..."
    run_and_check_status "${ReportGenerator}" -format "pdf" -f "${reportDir}${buildId}-results.pdf" -source "${reportDir}${buildId}-scan.fpr"

    # Check the results of commands from this script, return error if an error is found
    for resultCheck in "${resultSet[@]}" ; do
        if [ ${resultCheck} -ne 0 ] ; then
            logErr "Non-zero exit code found: ${resultCheck}"
            return 5
        fi
    done
    logInfo "Successfully completed the Fortify Scan!"
}

run_fortify > "${reportDir}${buildId}-run.log"
exit $?
