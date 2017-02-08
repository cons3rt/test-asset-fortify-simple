# CONS3RT Fortify Elastic Test Tool (ETT) Sample Scan
* **
## Usage:
In order to begin scanning with Fortify, you must first create a **Fortify Test Asset** just like this one. Then 
you can begin customizing the source code, license, and even the scan itself.

## Bring your own License

The Fortify ETT requires you to "Bring Your Own License". To apply your license in this sample asset, replace 
the `scripts/fortify.license` file with your Fortify License.

## Fortify Rules Version

CONS3RT updates the Fortify Secure Coding Rules rules upon initial deployment of your Fortify Scanner Elastic Test 
Tool (ETT).  The rule set can also be updated before each scan by leveraging the sample `scipts/run_fortify.sh` in 
your test asset.  This script contains a method to run `fortifyupdate` prior to running your scan.  The test results
zip file will also contain a log listing the specific versions of the Fortify Secure Coding Rules used in the scan:

    logs/Fortify-Installed-Rules-TIMESTAMP.log

## Use with DI2E and Forge.mil

* [Documentation on integrations with DI2E and Forge.mil](https://kb.cons3rt.com/articles/source-code-accounts/)

## The Fortify Scanner VM

CONS3RT deploys a VM with 8 CPU and 32 GB RAM.  This sample runs Fortify with the `-autoheap` memory option which
works in most cases.  If your scan runs out of memory, you can set the following Custom Property to adjust the 
Fortify memory allocation, the following show the recommended maximum:

    FORTIFY_MEMORY_IN_MB=28672

* [Click here](https://kb.cons3rt.com/articles/custom-properties-2) for how to set Custom Properties in your 
Deployments.

## Use this Sample Asset Out-Of-The-Box

1. git clone https://github.com/cons3rt/test-asset-fortify-simple.git
1. Replace the scripts/fortify.license file with _**your Fortify License file**_ 
1. Create a zip file of the `test-asset-fortify-simple` directory

## Customize your Own Fortify Scan

1. git clone https://github.com/cons3rt/test-asset-fortify-simple.git
1. Replace the scripts/fortify.license file with _**your Fortify License file**_ 
1. Edit the asset.properties file as needed (e.g. name, description, etc.)
1. If you have a Source Code repository to clone/checkout, update the `repositories.json` file with your source code 
repo and credential information.  See samples in the `scripts/repositories-samples.json` file
repositories file to the scripts directory (see below)
1. To manually upload your source code, add your unpacked source code to the `media/source` directory
1. (Optional) Edit the **run_fortify.sh** scripts as desired 
1. Create a zip file of the `test-asset-fortify-simple` directory

## Customize your Fortify Reports

See the sample [run_fortify.sh](https://github.com/cons3rt/test-asset-fortify-simple/blob/master/scripts/run_fortify.sh) 
script and scroll down to the report generation section.  In this sample there are 3 different reports generated.  Use 
the options in the comments section to customize your report output.

## Launch your Scan and Get Results!

1. Import the asset zip file test asset to CONS3RT, [click here for instructions](https://kb.cons3rt.com/articles/import-a-test-asset)
1. Create a Deployment containing your Test Asset, [click here for instructions](https://kb.cons3rt.com/kb/deployments/creating-a-deployment)
1. Launch your Deployment to run your scan!  [click here for instructions](https://kb.cons3rt.com/articles/launching-a-deployment)
1. View your results! On the Run page, click on the **Test Results** tab, and download your results files!

## Retest to get new Results!

1. From the main navigation menu, select **Runs**, and click on your Fortify Scan ETT Run
1. To re-run your Fortify Scan, click the **Retest** button at the top-right
1. When the scan is complete, click on the **Results** tab and download a new set of results!

> Notes on Re-Running Scans

* The latest code will by dynamically updated when retesting (git pull or svn update).  
* For static source code contained in the test asset, you can update your asset with a new snapshot of the source code
* If you released your Fortify Scanner VM, you may also click the **Rerun** button to launch a new scanner and 
get a new set of scan results.

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

*   **fortify.executable**: _(required)_ the name of the executable file in the scripts directory. This file contains the necessary logic and flow to run a fortify scan. (See HPE_SCA_Guide_16.10.pdf for more info on how to configure a fortify scan)
*   **fortify.scm.file**: _(optional)_ the file detailing the SCM repositor(y/ies) to be accessed. If not provided, the scan is assumed to be a local source code scan and the test asset's media directory must contain source code.
*   **fortify.build.file**: _(optional)_ the name of the build file in the scripts directory, if provided 
*   **fortify.scan.file**: _(optional)_ the name of the scan file in the scripts directory, if provided.
*   **fortify.source.path**: _(optional)_ the additional path to the source code to be scanned

## Deployment Properties:
*   **Optional:**
    *   **FORTIFY_MEMORY_IN_MB**: System memory in metabytes to allocate to the Fortify application for build and scan actions
    *   **fortify.source.path**: the path to the source code to be scanned, this overrides the path in fortify-config.properties if provided.
    *   **fortify.build.id**: the id to use for the fortify build/scan. **Default**: Fortify-Scan
    *   **fortify.debug**: whether or not to include the debug flag. **Default**: false

## Using the repositories.json file:
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


