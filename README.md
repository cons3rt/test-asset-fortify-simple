# Fortify Simple Test Asset

# Usage:

## Out-of-the-Box

You may use this Fortify asset out of the box with no modifications, it will perform the default Fortify code vulnerability scan and provide results on the Test Results tab on your the Deployment Run page in CONS3RT.  To use this community asset:

1.  From the main Navigation Menu, select "Tests"
2.  Search for "Fortify Simple Scan"
3.  [Follow these instructions](https://kb.cons3rt.com/articles/fortify-scans) to build up a Fortify Test Deployment to scan your source code!

## Licensing

The Fortify Elastic Test Tool works as "Bring Your Own License".  To apply your license in this sample asset, simply replace the "scripts/fortify.license" file with your Fortify License.

## Customize your Own

1.  git clone https://github.com/cons3rt/test-asset-fortify-simple.git
2.  Replace the scripts/fortify.license file with _**your Fortify License file**_ 
3.  Edit the asset.properties file as needed (e.g. name, description, etc.)
4.  In the scripts directory, edit the **build** and **scan** files to customize the type of scan 
5.  [Follow these instructions](https://kb.cons3rt.com/articles/fortify-scans) to build up a Fortify Test Deployment to scan your source code!

# Structure:

*   **asset.properties** file: detailing the metadata of the test asset (name, description, etc)
*   **config directory**:
    *   **fortify-config.properties** file: defining the required test asset properties (see properties)
*   **scripts directory**:
    *   **executable** script: main script that contains any user logic and defines fortify flow (Ex. run_fortify.sh in this case)
    *   **build** file: contains command line instructions for a fortify build (Ex. build)
    *   **scan** file: contains command line instructions for a fortify scan (Ex. scan)
    *   **fortify.license** file: contains the Fortify License
*   **LICENSE **file: Use as desired, not currently required for a fortify scan
*   **README.md **file: Add specific information about this test case, such as deployment properties

# **<span style="text-decoration: underline;">Properties</span>**

## fortify-config.properties:

*   **fortify.executable**: the name of the executable file in the scripts directory. This file contains the necessary logic and flow to run a fortify scan, leveraging the both the build file and the scan file.
*   **fortify.build.file**: the name of the build file in the scripts directory. 
*   **fortify.scan.file**: the name of the scan file in the scripts directory.

## Custom Deployment Properties:

*   **Required**:
    *   **fortify.scenario.id**: the id of the scenario that contains the software asset to be scanned
    *   **fortify.system.role**: the role of the system that contains the software asset to be scanned
    *   **fortify.software.id**: the id of the software asset to be scanned
*   **Optional:**
    *   **fortify.source.path**: the path to the source code to be scanned. ****Default**: **src
    *   **fortify.build.id**: the id to use for the fortify build/scan. **Default**: Fortify-Scan
    *   **fortify.debug**: whether or not to include the debug flag. **Default**: false

# Exported Variables

As part of the test tool adapter, the following variables are exported for use in the executable script:

*   **reportDir**: the path to the report directory in the test results
*   **logDir**: the path to the log directory in the test results
*   **combinedPropsFile**: the file that contains both deployment properties, and test asset properties
*   **buildFile**: the build file (specified above)
*   **scanFile**: the scan file (specified above)
*   **buildId**: the build id (specified above)
*   **fortifyDebug**: either "" or -debug, if fortify debug is set to false or true
*   **softwareAssetDir**: the path to the corresponding ${ASSET_DIR} of the the software asset specified by deployment properties
*   **sourceDir**: the path to the source directory (specifeid above) within the softwareAssetDir 
*   **sourceanalyzer**: the path to fortify sourceanalyzer executable
*   **ReportGenerator**: the path to fortify report generator executable

Any of the above variables can be accessed within the fortify executable script, format** ${softwareAssetDir}**

# Additional Notes

As an example the executable script in this test asset, contains logic blocks to do the following:

*   Replace tags such as "REPLACE_ME" with an exported variable ${logDir} in a specified file. This is leveraged to use variables within the build and scan files, since command line option files for fortify do not allow for variable use directly.
*   Parse a particular property from the combinedPropsFile, and (if specified) return a default value or the property. This is to allow for the use of deployment properties within the executable script (or build/scan files if combined with replace me tags) that the test tool adapter may not export or require normally.

