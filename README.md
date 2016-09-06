# Fortify Simple Test Asset
* **
## Usage:
In order to begin scanning with Fortify, you must first create a **Fortify Test Asset** just like this one. Then you can begin customizing the source code, license, and even the scan itself.

## Licensing:

The Fortify Elastic Test Tool works as "Bring Your Own License". To apply your license in this sample asset, simply replace the "scripts/fortify.license" file with your Fortify License.

## Customize your Own

1.  git clone: https://github.com/cons3rt/test-asset-fortify-simple.git
2.  Replace the scripts/fortify.license file with _**your Fortify License file**_ 
3.  Edit the asset.properties file as needed (e.g. name, description, etc.)
4.  If the scan is to be SCM based: add the required property to fortify-config.properties and the corresponding repositories file to the scripts directory (see below)
5.  Otherwise: add the desired source code to the media/source directory (see below)
6.  In the scripts directory, edit the **build** and **scan** files (if included) or edit the **run_fortify.sh** script directly to customize the type of scan to be run.
7.  Upload your new test asset to CONS3RT
8.  Add the new test asset to a deployment or create a test-only deployment and launch
9.  View your results!

# Structure:
* **

*   **asset.properties** file: detailing the metadata of the test asset (name, description, etc)
*   **LICENSE** file: Use as desired, defines licensing terms
*   **README.md** file: Add specific information about this test case, such as custom deployment properties, etc.
*   **config directory**:
    *   **fortify-config.properties** file: defining the required test asset properties (see properties)
*   **scripts directory**:
    *   Required:
        * **executable** script: main script that contains any user logic and defines fortify flow (Ex. run_fortify.sh in this case)
        *   **fortify.license** file: contains the Fortify License
    *   Optional:
        *   **repositories.json**: contains the json representing one or more repositories to checkout/clone
        *   **build** file: contains command line instructions for a fortify build (Ex. build)
        *   **scan** file: contains command line instructions for a fortify scan (Ex. scan)
*   **media directory**: _(optional)_
    * **source directory**: directory containing source code. Must be provided if scan is not SCM based.
    * **rules directory**: directory containing custom rules or rule sets.

# Properties
* **

## fortify-config.properties:

*   **fortify.executable**: _(required)_ the name of the executable file in the scripts directory. This file contains the necessary logic and flow to run a fortify scan
*   **fortify.scm.file**: _(optional)_ the file detailing the SCM repositor(y/ies) to be accessed. If not provided, the scan is assumed to be a local source code scan and the test asset's media directory must contain source code.
*   **fortify.build.file**: _(optional)_ the name of the build file in the scripts directory, if provided 
*   **fortify.scan.file**: _(optional)_ the name of the scan file in the scripts directory, if provided.
*   **fortify.source.path**: _(optional)_ the additional path to the source code to be scanned

## Deployment Properties:
*   **Optional:**
    *   **fortify.source.path**: the path to the source code to be scanned, this overrides the path in fortify-config.properties if provided.
    *   **fortify.build.id**: the id to use for the fortify build/scan. **Default**: Fortify-Scan
    *   **fortify.debug**: whether or not to include the debug flag. **Default**: false

## SCM JSON File:
* **
If a fortify scan is to access one or more remote SCM repositories for source code checkout, then a **fortify.scm.file** property must be provided in the **fortify-config.properties**, and the appropriately named file must exist in the **scripts directory**.

The SCM file contains one or more repository objects, in a JSON array. If no credentials object is provided or a type DEFAULT object is provided, the the default CONS3RT credentials will be used to access the repository. 

**Format**: 

    [
        {
                "type":"GIT",                       (Required: Either GIT or SVN)
                "url":"ssh://git@user-info.git",    (Required: The repostiory url)
                "branch":"master",                  (Optional: The specific branch to checkout)
                
                (Optional Object: used to pass credentials)
                "credentials" : {                   
                    "type": "USER_PASS",            (Required: Either DEFAULT or USER_PASS) 
                    "username":"foo",               (Required: if USER_PASS, the username)
                    "password":"bar",               (Required: if USER_PASS, the password)
                }
        }
    ]
    
# Exported Variables
* **

As part of the test tool adapter, the following variables are exported for use in the executable script:

*   **reportDir**: the path to the report directory, to be included in the test results
*   **logDir**: the path to the log directory, to be included in the test results
*   **combinedPropsFile**: the file that contains both deployment properties, and test asset properties
*   **buildFile**: the build file (if specified above)
*   **scanFile**: the scan file (if specified above)
*   **buildId**: the build id
*   **fortifyDebug**: either "" or -debug, if fortify debug is set to true or false
*   **sourceDir**: the path to the source code directory
*   **sourceCodePath**: the path to source code with the source code directory. Unless fortify.source.path was provided, this variabel will be the same as **sourceDir**
*   **localRulesDirectory**: the path to the test asset's media/rules directory _(empty if not included in test asset)_
*   **fortifyHome**: the location of the fortify install directory, all fortify utilities reside within
*   **sourceanalyzer**: the path to fortify sourceanalyzer executable
*   **ReportGenerator**: the path to fortify report generator executable
*   **BIRTReportGenerator**: the path to the fortify BIRT report generator executable
*   **FPRUtility**: the path to the fortify FPRUtility executable
*   **fortifyupdate**: the path to the fortify update utility

Any of the above variables can be accessed within the fortify executable script, format. **${sourceDir}**

# Additional Notes
* **

As an example the executable script in this test asset, contains logic blocks to do the following:

*   Replace tags such as "REPLACE_ME" with an exported variable such as ${sourceDir} in a specified file. This is leveraged to use variables within the build and scan files, since command line option files for fortify do not allow for variable use directly.
*   Parse a particular property from the combinedPropsFile, and (if specified) return a default value or the property. This is to allow for the use of deployment properties or test asset properties within the executable script (or build/scan files if combined with replace me tags) that the test tool adapter may not export or require normally.


