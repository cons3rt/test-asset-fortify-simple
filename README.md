<h1 style="text-align: center;"><strong><span style="text-decoration: underline;">Fortify Test Asset(s)</span></strong></h1>
<h2>Structure:</h2>
<ul>
<li><strong>asset.properties</strong> file: detailing the metadata of the test asset (name, description, etc)</li>
<li><strong>config directory</strong>:
<ul>
<li><strong>fortify-config.properties</strong> file: defining the required test asset properties (see properties)</li>
</ul>
</li>
<li><strong>scripts directory</strong>:
<ul>
<li><strong>executable </strong>script: main script that contains any user&nbsp;logic and defines fortify flow (Ex. run_fortify.sh in this case)</li>
<li><strong>build </strong>file: contains command line instructions for a fortify build (Ex. build)</li>
<li><strong>scan </strong>file: contains command line instructions for a fortify scan (Ex. scan)</li>
</ul>
</li>
<li><strong>License </strong>file: a license is not currently required for a fortify scan, so a dummy license file can be used</li>
<li><strong>Documentation </strong>file: details any specific information to the test case, such as deployment properties</li>
</ul>
<h1 style="text-align: center;"><strong><span style="text-decoration: underline;">Properties</span></strong></h1>
<h1 style="text-align: left;">Test Asset Properties:</h1>
<ul>
<li><strong>fortify.executable</strong>: the name of the executable file in the scripts directory. This file contains the necessary logic and flow to run a fortify scan, leveraging the both the build file and the scan file.</li>
<li><strong>fortify.build.file</strong>: the name of the build file in the scripts directory.&nbsp;</li>
<li><strong>fortify.scan.file</strong>: the name of the scan file in the scripts directory.</li>
</ul>
<h2>Deployment&nbsp;Properties:</h2>
<ul>
<li><strong>Required</strong>:
<ul>
<li><strong>fortify.scenario.id</strong>: the id of the scenario that contains the software asset to be scanned</li>
<li><strong>fortify.system.role</strong>: the role of the system that contains the software asset to be scanned</li>
<li><strong>fortify.software.id</strong>: the id of the software asset to be scanned</li>
</ul>
</li>
<li><strong>Optional:</strong><br />
<ul>
<li><strong>fortify.source.path</strong>: the path to the source code to be scanned.&nbsp;<strong><strong>Default</strong>:&nbsp;</strong>src</li>
<li><strong>fortify.build.id</strong>: the id to use for the fortify build/scan.&nbsp;<strong>Default</strong>: Fortify-Scan</li>
<li><strong>fortify.debug</strong>: whether or not to include the debug flag.&nbsp;<strong>Default</strong>: false</li>
</ul>
</li>
</ul>
<h1 style="text-align: center;"><span style="text-decoration: underline;">Exported Variables</span></h1>
<p>As part of the test tool adapter, the following variables are exported for use in the executable script:</p>
<ul>
<li><strong>reportDir</strong>: the path to the report directory in the test results</li>
<li><strong>logDir</strong>: the path to the log directory in the test results</li>
<li><strong>combinedPropsFile</strong>: the file that contains both deployment properties, and test asset properties</li>
<li><strong>buildFile</strong>: the build file (specified above)</li>
<li><strong>scanFile</strong>: the scan file (specified above)</li>
<li><strong>buildId</strong>: the build id (specified above)</li>
<li><strong>fortifyDebug</strong>: either "" or -debug, if fortify debug is set to false or true</li>
<li><strong>softwareAssetDir</strong>: the path to the corresponding ${ASSET_DIR} of the the software asset specified by deployment properties</li>
<li><strong>sourceDir</strong>: the path to the source directory (specifeid above) within the softwareAssetDir&nbsp;</li>
<li><strong>sourceanalyzer</strong>: the path to fortify sourceanalyzer executable</li>
<li><strong>ReportGenerator</strong>: the path to fortify report generator executable</li>
</ul>
<p>Any of the above variables can be accessed within the fortify executable script, format<strong>&nbsp;${softwareAssetDir}</strong></p>
<h1 style="text-align: center;"><span style="text-decoration: underline;"><strong>Additional Notes</strong></span></h1>
<p>As an example the executable script in this test asset, contains logic blocks to do the following:</p>
<ul>
<li>Replace tags such as "REPLACE_ME" with an exported variable ${logDir} in a specified file. This is leveraged to use variables within the build and scan files, since command line option files for fortify do not allow for variable use directly.</li>
<li>Parse a particular property from the combinedPropsFile, and (if specified) return a default value or the property. This is to allow for the use of deployment properties within the executable script (or build/scan files if combined with replace me tags) that the test tool adapter may not export or require normally.&nbsp;</li>
</ul>
<h4 style="padding-left: 30px;">&nbsp;</h4>