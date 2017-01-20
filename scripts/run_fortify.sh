#!/bin/bash

function run_and_check_status() {
    "$@"
    local status=$?
    if [ ${status} -ne 0 ] ; then
	echo -n `date "+%D %H:%M:%S"`
        echo " Error executing: $@, exited with code: ${status}"
	exit ${status}
    fi
}

function fortify() {
    # Used for debugging of env variables based in by fortify adapter
    printenv > ${logDir}environment_out.log

    echo
    echo -n `date "+%D %H:%M:%S"`
    echo " : Beginning fortify test"
    echo
    echo -n `date "+%D %H:%M:%S"`
    echo " : Beginning fortify build of ${sourceDir}"
    echo

    # Begin build process
    run_and_check_status "${sourceanalyzer}" -clean
    run_and_check_status "${sourceanalyzer}" -b "${buildId}" "${sourceDir}" -logfile "${logDir}${buildId}-build.log" "${fortifyDebug}" -autoheap

    echo
    echo -n `date "+%D %H:%M:%S"`
    echo " : Writing warnings to ${logDir}${buildId}-buildWarnings.log"
    echo

    # Capture build warnings and show the files in the build
    run_and_check_status "${sourceanalyzer}" -b "${buildId}" -show-build-warnings -logfile "${logDir}${buildId}-buildWarnings.log" "${fortifyDebug}"

    echo
    echo -n `date "+%D %H:%M:%S"`
    echo " : Listing build files to ${logDir}${buildId}-showfiles.log"
    echo

    run_and_check_status "${sourceanalyzer}" -b "${buildId}" -show-files -logfile "${logDir}${buildId}-showfiles.log" "${fortifyDebug}"

    echo
    echo -n `date "+%D %H:%M:%S"`
    echo " : Starting scan"
    echo

    # Perform scan
    run_and_check_status "${sourceanalyzer}" -b "${buildId}" -scan -f "${reportDir}${buildId}-scan.fpr" -logfile "${logDir}${buildId}-scan.log" "${fortifyDebug}" -autoheap

    echo
    echo -n `date "+%D %H:%M:%S"`
    echo " : Generating report ${reportDir}${buildId}-results.pdf"
    echo

    # Generate report from scan results
    run_and_check_status "${ReportGenerator}" -format "pdf" -f "${reportDir}${buildId}-results.pdf" -source "${reportDir}${buildId}-scan.fpr"

    echo
    echo -n `date "+%D %H:%M:%S"`
    echo " : Successfully completed fortify test"
}

fortify > "${reportDir}${buildId}-run.log"
