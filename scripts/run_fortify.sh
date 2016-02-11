#!/bin/bash

# This flow relies on buildId being constant through out configuration and the scan configuration pointing to an output file that report generate can then use

function run_and_check_status() {
    "$@"
    local status=$?
    if [ ${status} -ne 0 ] ; then
	echo -n `date "+%D %H:%M:%S"`
        echo " Error executing: $@, exited with code: ${status}"
	exit ${status}
    fi
}

function replace_tags() {
    local tag=$1
    local val=$2
    local file=$3
    
    echo "-- Replacing: ${tag} with ${val} in file: ${file}" 

    sed -i "s@${tag}@${val}@g" "${file}"
}

function parse_deployment_property() {
    local property=$1
    local default=$2

    local retval=$( grep "${property}" ${deploymentProperties} | sed s/.*=// )

    if [ -z "${retval}" ]; then
        if [ -z "${default}" ]; then
            exit 1
        else
            echo "${default}"
        fi
    else
        echo "${retval}"
    fi
}

function fortify() {
    # Used for debugging of env variables based in by fortify adapter 
    printenv > ${logDir}environment_out.log

    echo -n `date "+%D %H:%M:%S"`
    echo " -- Beginning fortify scan"

    # Note: variables can not be used inside of a Fortify SCA cmd line options file, so replace_me tags are used instead
    echo "-- Replacing tags in build file: ${buildFile}"
    replace_tags "REPLACE_BUILD_ID" "${buildId}" "${buildFile}"
    replace_tags "REPLACE_SOURCE_DIR" "${sourceDir}" "${buildFile}"
    replace_tags "REPLACE_DEBUG" "${fortifyDebug}" "${buildFile}"
    replace_tags "REPLACE_BUILD_LOG" "${logDir}${buildId}-build.log" "${buildFile}"

    echo
    echo "-- Replacing tags in scan file: ${scanFile}"
    replace_tags "REPLACE_BUILD_ID" "${buildId}" "${scanFile}"
    replace_tags "REPLACE_DEBUG" "${fortifyDebug}" "${scanFile}"
    replace_tags "REPLACE_SCAN_OUTPUT_FILE" "${reportDir}${buildId}-scan.fpr" "${scanFile}"
    replace_tags "REPLACE_SCAN_LOG" "${logDir}${buildId}-scan.log" "${scanFile}"
    echo

    run_and_check_status "${sourceanalyzer}" -clean
    run_and_check_status "${sourceanalyzer}" @"${buildFile}"
    run_and_check_status "${sourceanalyzer}" -b "${buildId}" -show-build-warnings > "${logDir}${buildId}-buildWarnings.log"
    run_and_check_status "${sourceanalyzer}" -b "${buildId}" -show-files > "${logDir}${buildId}-showfiles.log"
    run_and_check_status "${sourceanalyzer}" @"${scanFile}"
    run_and_check_status "${ReportGenerator}" -format "pdf" -f "${reportDir}${buildId}-results.pdf" -source "${reportDir}${buildId}-scan.fpr"
    
    echo -n `date "+%D %H:%M:%S"`
    echo " Successfully completed fortify scan: "
}

fortify
