<cfcomponent displayname="jQuack" output="false">
	
	<!---
	===============================================================================================
	===============================================================================================
	
	** jQuack Coldfusion Component **
	
	A CFC wrapper for including jQuery core files, plugins, UI components and themes. Explicitly
	including jQuery files is no big deal, but jQuack's strength is being able to bundle a plugin's
	core and any depedencies into a single function call with a single parameter (or no parameter at all!)
	
	Is a dependency shared between plugins (e.g. bigiframe.js)? No problem, jQuack prevents files from
	being included more that once per request.
	
	It makes application-wide or server-wide version changes simple. 
	
	===============================================================================================
	===============================================================================================
	
	
	===========================
	Example Directory Structure
	===========================
	/{yourWebRoot}/
		/jquery/
			jquery-1.0.0.min.js *
				/plugins/
					/foo/
						foo.js
						foo.css
					/bar/
						bar.js
						bar.css
				/jquery-ui-1.0.0.custom/ *
					/css/
						/sunny/
							/images/
							jquery-ui-1.0.0.custom.css
						/rainy/
							/images/
							jquery-ui-1.0.0.custom.css
					/js/
						jquery-ui-1.0.0.custom.min.js
	
	* Default naming convention as downloaded from jquery.com and jqueryui.com
	
	===========================
	Example pluginStruct - A structure of arrays
	===========================
	<cfset pluginStruct = {} />
	<cfset pluginStruct.foo = ["foo/foo.js","foo/foo.css"] />
	<cfset pluginStruct.bar = ["bar/bar.css","bar/bar.js","bar/foobar.js","jquery.barfoo.js"] />
	<cfset pluginStruct.CFJS = ["cfjs/jquery.cfjs.packed.js"] />
	
	===========================
	Intialising jQuack
	===========================
	<cfset jQuack = CreateObject("component","{your_cfc_path}.jQuack").init() />
	
	===========================
	Usage Examples
	===========================
	
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
		<head>
			<title>jQuack..</title>
			#jQuack.core()#
			#jQuack.plugin("foo,bar,cfjs")#
			#jQuack.ui()#
		</head>
		<body>...</body>
	</html>
	
	// a different core file
	#jQuack.core("jquery-6.6.6.min.js")#
	
	// from an external URL
	#jQuack.core(coreFileName="jquery.min.js", rootPath="http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/")#
	
	// a single plugin
	#jQuack.plugin("foo")#
	
	// multiple plugins
	#jQuack.plugin("foo,bar")#
	
	// ALL plugins
	#jQuack.plugin()#
	
	// a plugin not defined in the pluginStruct
	#jQuack.plugin(file="outbackjack/outbackjack.js")#
	
	// a plugin from an external URL
	#jQuack.plugin(file="penelopepitstop.js", pluginPath="http://plugins.wackyraces.com/")#
	
	// UI with a different theme
	#jQuack.ui(themeName="rainy")#

	--->
	
	<!---
		Constructor.
	
		@param coreFileName		required	Name of the jQuery core file. e.g. jquery-1.0.0.min.js
		@param rootPath			optional	URL Path to your javascript directory, defaults to /jquery/
		@param UIBundleName		optional	Name of the jQuery UI bundle. e.g. jquery-ui-1.0.0.custom
		@param themeName		optional	Name of the theme directory
		@param pluginPath		optional	URL Path to your plugins directory, defaults to /jquery/plugins/
		@param pluginStruct		optional	A structure of arrays. Plugins will be reference by their structure key,
											the array will contain URLs to the plugin files relative to the {pluginPath}
											See Example pluginStruct above
		
		@returns an instance of itself
	--->
	<cffunction name="init" access="public" returntype="jQuack" output="false" displayname="jQuery Functions">
		<cfargument name="coreFileName" required="true" type="string" />
		<cfargument name="rootPath" required="false" type="string" default="/jquery/" />
		<cfargument name="UIBundleName" required="false" type="string" default="" />
		<cfargument name="themeName" required="false" type="string" default="" />
		<cfargument name="pluginPath" required="false" type="string" default="#arguments.rootPath#plugins/" />
		<cfargument name="pluginStruct" required="false" type="struct" default="#StructNew()#" />
		<cfset StructAppend(variables,arguments) />
		<cfreturn this />
	</cffunction>
	
	<!---
		Render the jQuery core markup
	
		@param coreFileName		optional	Name of the jQuery core file
		@param rootPath			optional	URL Path to your javascript directory		
		
		@returns <script ... /> markup
	--->
	<cffunction name="core" access="public" returntype="string" output="false">
		<cfargument name="coreFileName" type="string" required="false" default="#variables.coreFileName#" />
		<cfargument name="rootPath" type="string" required="false" default="#variables.rootpath#" />
		<cfset var loc = {} />
		<cfset loc.file = "#arguments.rootPath##arguments.coreFileName#" />
		<cfreturn $render(loc.file) />
	</cffunction>
	
	<!---
		Render the jQuery UI and theme markup

		@param UIBundleName		optional	Name of the jQuery UI bundle
		@param themeName		optional	Name of the theme directory
		@param rootPath			optional	URL Path to your javascript directory
					
		@returns <script ... /> & <link ... /> markup
	--->
	<cffunction name="ui" access="public" returntype="string" output="false">
		<cfargument name="UIBundleName" type="string" required="false" default="#variables.uiBundleName#" />
		<cfargument name="themeName" type="string" required="false" default="#variables.themeName#" />
		<cfargument name="rootPath" type="string" required="false" default="#variables.rootPath#" />
		<cfset var loc = {} />
		<cfset loc.return = $render("#arguments.rootpath##arguments.uiBundleName#/js/#arguments.uiBundleName#.min.js") & Chr(13) & Chr(10) />
		<cfset loc.return = loc.return & theme(arguments.themeName,arguments.uiBundleName) />
		<cfreturn loc.return />
	</cffunction>
	
	<!---
		Render the jQuery plugin markup
		
		@param pluginKey		optional	The a list of reference keys to the plugin array (pluginStruct.{key})
		@param file				optional	An array or list of plugin URLs not defined in the pluginStruct
											URLs relative to the {pluginPath}
		@param pluginPath		optional	URL Path to your plugins directory
		
		* Omit both pluginKey and file arguments to render all plugins defined in the pluginStruct
		
		@returns <script ... /> & <link ... /> markup
	--->
	<cffunction name="plugin" access="public" returntype="string" output="false">
		<cfargument name="pluginKey" type="string" required="false" default="" />
		<cfargument name="file" type="any" required="false" default="" />
		<cfargument name="pluginPath" type="string" required="false" default="#variables.pluginPath#" />
		<cfset var loc = {} />
		<cfset loc.return = "" />
		<cfset loc.files = [] />
		<cfif Len(arguments.pluginKey) gt 0>
			<cfloop list="#arguments.pluginKey#" index="loc.i">
				<cfif StructKeyExists(variables.pluginStruct,loc.i)>
					<cfset loc.files = $arrayJoin(loc.files,variables.pluginStruct[loc.i]) />
				</cfif>
			</cfloop>
		<cfelseif IsArray(arguments.file)>
			<cfset loc.files = $arrayJoin(loc.files,arguments.file) />
		<cfelseif Len(arguments.file) gt 0>
			<cfset loc.files = $arrayJoin(loc.files,ListToArray(arguments.file)) />
		<cfelseif Len(arguments.pluginKey) eq 0 AND Len(arguments.file) eq 0>
			<cfloop list="#StructKeyList(variables.pluginStruct)#" index="loc.i">
				<cfif StructKeyExists(variables.pluginStruct,loc.i)>
					<cfset loc.files = $arrayJoin(loc.files,variables.pluginStruct[loc.i]) />
				</cfif>
			</cfloop>
		</cfif>
		<cfset loc.files = $arrayJoin(loc.files,ListToArray(arguments.file)) />
		<cfloop from="1" to="#ArrayLen(loc.files)#" index="loc.i">
			<cfset loc.path = $render("#arguments.pluginPath##loc.files[loc.i]#") />
			<cfset loc.end = loc.i lt ArrayLen(loc.files) ? Chr(13) & Chr(10) : "" />
			<cfset loc.return = loc.return & loc.path & loc.end />
		</cfloop>
		<cfreturn loc.return />
	</cffunction>
	
	<!---
		Render the jQuery UI theme markup
		
		@param themeName		optional	Name of the theme directory
		@param UIBundleName		optional	Name of the jQuery UI bundle
		@param rootPath			optional	URL Path to your javascript directory
					
		@returns <link ... /> markup
	--->
	<cffunction name="theme" access="public" returntype="string" output="false">
		<cfargument name="themeName" type="string" required="false" default="#variables.coreFileName#" />
		<cfargument name="UIBundleName" type="string" required="false" default="#variables.uiBundleName#" />
		<cfargument name="rootPath" type="string" required="false" default="#variables.rootPath#" />
		<cfreturn $render("#arguments.rootpath##arguments.uiBundleName#/css/#arguments.themeName#/#arguments.uiBundleName#.css") />
	</cffunction>
	
	<!--- 
		private functions 
	--->
	
	<!---
		Combines two arrays
	--->
	<cffunction name="$arrayJoin" access="private" returntype="array" output="false">
		<cfargument name="array1" required="true" type="array" />
		<cfargument name="array2" required="true" type="array" />
		<cfset var loc = {} />
		<cfset loc.return = arguments.array1 />
		<cfloop array="#arguments.array2#" index="loc.i">
			<cfif arrayFindNoCase(loc.return,loc.i) eq 0>
				<cfset ArrayAppend(loc.return,loc.i) />
			</cfif>
		</cfloop>
		<cfreturn loc.return />
	</cffunction>
	
	<!---
		Renders <script.. /> and <link.. /> tags for js and css files. It will omit any files that have already been procesed during this request
	--->
	<cffunction name="$render" access="private" output="false" returntype="string">
		<cfargument name="file" type="string" required="true" />
		<cfset var loc = {} />
		<cfset loc.key = ReReplaceNoCase(arguments.file,"[^a-z0-9]","","all") />
		<cfset loc.return = "">
		<cfif not StructKeyExists(request,"_jquack")>
			<cfset request._jquack = {} />
		</cfif>
		<cfif StructKeyExists(request._jquack,loc.key)>
			<cfset loc.return = "">
		<cfelseif CompareNoCase(listLast(arguments.file,"."),"js") eq 0>
			<cfset loc.return = '<script type="text/javascript" src="#arguments.file#"></script>' />
		<cfelseif CompareNoCase(listLast(arguments.file,"."),"css") eq 0>
			<cfset loc.return = '<link rel="stylesheet" href="#arguments.file#" type="text/css" media="screen">' />
		</cfif>
		<cfset request._jquack[loc.key] = true />
		<cfreturn loc.return />
	</cffunction>
	
</cfcomponent>