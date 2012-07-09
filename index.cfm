
<cfparam name="url.filepath" default="#expandPath('./test-template.cfm')#" />
<cfparam name="url.format" default="json" />

<cfscript>
request.pc = createObject('component', 'prefixchecker').init();
request.violations = request.pc.check(filePath=url.filePath, format=url.format);
</cfscript>

<cfswitch expression="#url.format#">

	<cfcase value="dump">
		<p>
		<cfoutput>There are prefix violations in #arrayLen(request.violations)# files.</cfoutput>
		</p>
		<cfdump var="#request.violations#">
	</cfcase>
	
	<cfcase value="xml">
		<cfwddx action="cfml2wddx" input="#request.violations#" output="request.violationsXML">
		<cfcontent reset="true" type="text/xml" />
		<cfoutput>#request.violationsXML#</cfoutput>
	</cfcase>
	
	<cfcase value="json">
		<cfcontent reset="true" type="application/json" />
		<cfoutput>#serializeJSON(request.violations)#</cfoutput>
	</cfcase>

</cfswitch>