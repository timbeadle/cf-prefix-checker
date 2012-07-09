<cfimport prefix="lh" taglib="../extensions/customtags/">
<cfimport prefix="multisite" taglib="../../extensions/customtags/multisite">
<cfif structkeyexists(url,"ubergroup_name_urlsafe") and listfind("sex-toys,lingerie,sex,fun",url.ubergroup_name_urlsafe)>
	<cfquery datasource="#server.settings.ds_store#"
			 name="variables.ubergroup">
			 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			 SELECT ubergroups.ubergroup_name,ubergroups.ubergroup_pagetitle,ubergroups.ubergroup_h1,ubergroups.ubergroup_name_urlsafe,ubergroups.ubergroup_twoline,ubergroups.ubergroup_blah,ubergroups.ubergroup_meta_description
			 FROM ubergroups
			 WHERE ubergroups.ubergroup_name_urlsafe = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="50" value="#url.ubergroup_name_urlsafe#" />
			 and ubergroups.frn_website_id=<cfqueryparam cfsqltype="cf_sql_integer" value="#application.settings.siteid#" />
	</cfquery>
	<cfif variables.ubergroup.recordcount>
		<cfset variables.boxes = server.boxmanager.getBoxes(page_type="ubergroup", page_ubergroup_urlsafe=url.ubergroup_name_urlsafe,site_id=application.settings.siteid, csym=server.settings.csyms[session.user.currency], exchangeRate=server.settings.exchangerates[session.user.currency],showLiveChat=server.settings.livechat,shipping_country_rule=session.user.shipping.countryid) />
		<cfset variables.SuperGroups=server.store.getSuperGroups(SiteId=application.settings.SiteId,ubergroup_name_urlsafe=url.ubergroup_name_urlsafe) />
		<lh:nav_new secure="false" breadcrumbs="#variables.ubergroup.ubergroup_name#"
				title="#replace(variables.ubergroup.ubergroup_pagetitle, "&", "&amp;")#"
				description="#variables.ubergroup.ubergroup_meta_description#"
				keywords="#variables.ubergroup.ubergroup_name#"
				mode="ubergroup"
				tab="#variables.ubergroup.ubergroup_name_urlsafe#"
				leftcol="true"><lhx:adulthub /><cfoutput>
				#server.tags.processtags(variables.ubergroup.ubergroup_twoline)#
				#server.tags.processtags(variables.boxes.centre)#<cfif arraylen(variables.SuperGroups)>
				<h3>Related #variables.ubergroup.ubergroup_name# categories</h3>
				<p><cfloop from="1" to="#arraylen(variables.SuperGroups)#" index="variables.i"><cfif variables.i neq 1> | </cfif><a href="#variables.SuperGroups[i].URL#">#variables.SuperGroups[i].SuperGroupName#</a></cfloop></p></cfif></cfoutput>
				<cfinclude template="../extensions/includes/display/recently_viewed.cfm"/>
		</lh:nav_new>
	<cfelse>
		<cfinclude template="missing.cfm" />
	</cfif>
<cfelse>
	<cfinclude template="missing.cfm" />
	<foo:bar /><baz:smeg />
	
	<foo:barbaz />
</cfif>