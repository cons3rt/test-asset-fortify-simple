#!/bin/bash

# Sample run_fortify.sh script
#
# Provided by: Jackpine Technologies Corp.
#
# Authors: John Paulo (john.paulo@jackpinetech.com) and Joe Yennaco
#          (joe.yennaco@jackpinetech.com)
#
# Usage: This script executes your desired Fortify build, scan, and report
#        generation actions.
#
# This script will be executed:
#   1. After your Fortify Scanner initially deploys
#   2. Each time you click the "Retest" button
#
# Feel free to use as is!  It should work in most cases.  If you would like to
# customize your scan output format, results, or build commands, you can edit
# the commands in the run_fortify function below.
#
# The following variables are exported for use in the this script:
#
# reportDir: Path to the report directory, included in the test results
# logDir: Path to the log directory, included in the test results
# combinedPropsFile: File that contains both deployment properties, and test asset properties
# buildFile: The build file (optional)
# scanFile: The scan file (optional)
# buildId: The build id
# fortifyDebug: Either "" or -debug, if fortify debug is set to true or false
# sourceDir: Path to the parent source code directory
# sourceCodePath: Path to source code. Unless fortify.source.path was provided, will be the same as "sourceDir"
# localRulesDirectory: Path to the test asset's media/rules directory (empty if not included in test asset)
# fortifyHome: Location of the fortify install directory, all fortify utilities reside within
# sourceanalyzer: Path to fortify sourceanalyzer executable
# ReportGenerator: Path to fortify report generator executable
# BIRTReportGenerator: Path to the fortify BIRT report generator executable
# FPRUtility: Path to the fortify FPRUtility executable
# fortifyupdate: Path to the fortify update utility
#

# Configure log files
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
    "$@"
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

    #################################################
    #                   Build
    #################################################

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

    #################################################
    #                   Scan
    #################################################

    # Perform scan
    logInfo "Starting the Fortify scan..."
    scanReport="${reportDir}${buildId}-scan.fpr"
    run_and_check_status "${sourceanalyzer}" -b "${buildId}" -scan -f "${scanReport}" -logfile "${logDir}${buildId}-scan.log" "${fortifyDebug}" "${fortifyMemoryAllocation}"

    #################################################
    #             Report Generation
    #################################################
    #
    # See the Fortify SCA documentation for a full set of options showing how to
    #
    #
    # Generate report from scan results
    #
    # See below for commonly used report generation options, see the
    # HP Fortify SCA documentation for the full set:
    #

    # Sample legacy report output formats
    # -----------------------------------
    #
    # -format <format>, options: PDF, RTF, XML
    #
    # -template <template_name>, options: "DeveloperWorkbook.xml", "OWASP2004.xml", "OWASP2007.xml", "OWASP2010.xml",
    #                                     "OWASP2013.xml", "ScanReport.xml"
    #
    # -showSuppressed, Include issues that have been marked as suppressed.
    #
    # -showRemoved, Include issues that have been marked as removed by SCA.
    #
    # -showHidden, Include issues that have been marked as hidden.
    #
    # -verbose, Displays status messages to the console.
    #
    owaspReport="${reportDir}${buildId}-OWASP-results.pdf"
    logInfo "Generating default report: ${owaspReport}..."
    run_and_check_status "${ReportGenerator}" -format "pdf" -f "${owaspReport}" -source "${scanReport}"

    developerWorkbook="${reportDir}${buildId}-DeveloperWorkbook-results.pdf"
    logInfo "Generating developer workbook: ${developerWorkbook}..."
    run_and_check_status "${ReportGenerator}" -template "DeveloperWorkbook.xml" -format "pdf" -f "${developerWorkbook}" -source "${scanReport}"

    # Sample BIRT Report formatted output
    # -----------------------------------
    #
    # -template <template name>, options: "Developer Workbook", "DISA STIG", "CWE/SANS Top 25",
    #                                     "FISMA Compliance", "OWASP Mobile Top 10", "OWASP Top 10",
    #                                      and "PCI DSS Compliance".
    #
    # -format <format>, options: PDF, DOC, HTML, and XLS
    #
    # --Version <version>, options:
    #      [CWE/SANS Top 25]: "2011 CWE/SANS Top 25", "2010 CWE/SANS Top 25", and "2009 CWE/SANS Top 25"
    #      [DISA STIG]: "DISA STIG 3.9", "DISA STIG 3.7", "DISA STIG 3.5", "DISA STIG 3.4", and "DISA STIG 3"
    #      [OWASP Top 10]: "OWASP Top 10 2013", "OWASP Top 10 2010", "OWASP Top 10 2007", and "OWASP Top 10 2004"
    #      [PCI DSS Compliance]: "3.0 Compliance" and "2.0 Compliance"
    #
    # -showSuppressed, Include issues that have been marked as suppressed.
    #
    # -showRemoved, Include issues that have been marked as removed.
    #
    # -showHidden, Include issues that have been marked as hidden.
    #
    # --IncludeDescOfKeyTerminology, Include the "Description of Key Terminology" section in the report.
    #
    # --IncludeHPEnterpriseSecurity, Include the "About HPE Security" section in the report.
    #
    # --SecurityIssueDetails, Provide detailed descriptions of reported issues. This option is not available
    #                         for the Developer Workbook template.
    #
    # --UseFortifyPriorityOrder, Use Fortify Priority instead of folder names to categorize issues. This option
    #                            is not available for the Developer Workbook and PCI Compliance templates.
    #
    birtReport="${reportDir}${buildId}-BirtReport-DevWorkbook-results.pdf"
    logInfo "Generating BIRT Report developer workbook: ${birtReport}..."
    run_and_check_status "${BIRTReportGenerator}" -format PDF -output "${birtReport}" -source "${scanReport}" -template "Developer Workbook"

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
