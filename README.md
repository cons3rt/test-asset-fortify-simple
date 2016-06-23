<h1 style="text-align: center;"><strong><span style="text-decoration: underline;">Fortify Simple Test Asset</span></strong></h1>

<h1>Usage:</h1>

<h2>Out-of-the-Box</h2>

<p>You may use this Fortify asset out of the box with no modifications, it will perform the default Fortify code vulnerability scan and provide results on the Test&nbsp;Results tab on your the Deployment Run page in CONS3RT. &nbsp;To use this community asset:</p>

<ol>
	<li>From the main Navigation Menu, select &quot;Tests&quot;</li>
	<li>Search for &quot;Fortify Simple Scan&quot;</li>
	<li><a href="https://kb.cons3rt.com/articles/fortify-scans">Follow these instructions</a> to build up a Fortify Test Deployment to scan your source code!</li>
</ol>

<h2>Licensing</h2>

<p>The Fortify Elastic Test Tool works as &quot;Bring Your Own License&quot;. &nbsp;To apply your license in this sample asset, simply replace the &quot;scripts/fortify.license&quot; file with your Fortify License.</p>

<h2>Customize your Own</h2>

<ol>
	<li>git clone&nbsp;https://github.com/cons3rt/test-asset-fortify-simple.git</li>
	<li>Replace the scripts/fortify.license file with <em><strong>your&nbsp;Fortify License file</strong></em>&nbsp;</li>
	<li>Edit the asset.properties file as needed (e.g. name, description, etc.)</li>
	<li>In the scripts directory, edit the <strong>build</strong> and <strong>scan</strong> files to customize the type of scan&nbsp;</li>
	<li><a href="https://kb.cons3rt.com/articles/fortify-scans">Follow these instructions</a>&nbsp;to build up a Fortify Test Deployment to scan your source code!</li>
</ol>

<h1>Structure:</h1>

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
		<li><strong>fortify.license</strong> file: contains the Fortify License</li>
	</ul>
	</li>
	<li><strong>LICENSE&nbsp;</strong>file: Use as desired, not currently required for a fortify scan</li>
	<li><strong>README.md&nbsp;</strong>file: Add specific information about this test case, such as deployment properties</li>
</ul>

<h1 style="text-align: center;"><strong><span style="text-decoration: underline;">Properties</span></strong></h1>

<h2 style="text-align: left;">fortify-config.properties:</h2>

<ul>
	<li><strong>fortify.executable</strong>: the name of the executable file in the scripts directory. This file contains the necessary logic and flow to run a fortify scan, leveraging the both the build file and the scan file.</li>
	<li><strong>fortify.build.file</strong>: the name of the build file in the scripts directory.&nbsp;</li>
	<li><strong>fortify.scan.file</strong>: the name of the scan file in the scripts directory.</li>
</ul>

<h2>Custom Deployment&nbsp;Properties:</h2>

<ul>
	<li><strong>Required</strong>:

	<ul>
		<li><strong>fortify.scenario.id</strong>: the id of the scenario that contains the software asset to be scanned</li>
		<li><strong>fortify.system.role</strong>: the role of the system that contains the software asset to be scanned</li>
		<li><strong>fortify.software.id</strong>: the id of the software asset to be scanned</li>
	</ul>
	</li>
	<li><strong>Optional:</strong>
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
	<li><strong>fortifyDebug</strong>: either &quot;&quot; or -debug, if fortify debug is set to false or true</li>
	<li><strong>softwareAssetDir</strong>: the path to the corresponding ${ASSET_DIR} of the the software asset specified by deployment properties</li>
	<li><strong>sourceDir</strong>: the path to the source directory (specifeid above) within the softwareAssetDir&nbsp;</li>
	<li><strong>sourceanalyzer</strong>: the path to fortify sourceanalyzer executable</li>
	<li><strong>ReportGenerator</strong>: the path to fortify report generator executable</li>
</ul>

<p>Any of the above variables can be accessed within the fortify executable script, format<strong>&nbsp;${softwareAssetDir}</strong></p>

<h1 style="text-align: center;"><span style="text-decoration: underline;"><strong>Additional Notes</strong></span></h1>

<p>As an example the executable script in this test asset, contains logic blocks to do the following:</p>

<ul>
	<li>Replace tags such as &quot;REPLACE_ME&quot; with an exported variable ${logDir} in a specified file. This is leveraged to use variables within the build and scan files, since command line option files for fortify do not allow for variable use directly.</li>
	<li>Parse a particular property from the combinedPropsFile, and (if specified) return a default value or the property. This is to allow for the use of deployment properties within the executable script (or build/scan files if combined with replace me tags) that the test tool adapter may not export or require normally.&nbsp;</li>
</ul>

<h4 style="padding-left: 30px;">&nbsp;</h4>
