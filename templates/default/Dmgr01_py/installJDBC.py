#---------------------------------------------------------
# Create JDBC Provider and associated Data Sources
#---------------------------------------------------------    
def installJDBC ( jdbcname, driverPath, dsname, dsjndiname, databaseURL, cfname, databasePasswordAlias, databaseUserId, databasePassword, databaseDescription, agedTimeout, connectionTimeout, maxConnections, minConnections, purgePolicy, reapTime, unusedTimeout, stmentCacheSize, jdbcj2eeAttr, jdbcimplclass, jdbcdesc, dsHelper, dsj2eeAttr, stuckTime, stuckTimerTime, stuckThreshold ):

	#
	# Added that if statement to set back to prior server setting if not server scope
	#
        cells = AdminConfig.list("Cell" )
        cells = wsadminToList(cells)

        cell = cells[0]

        jdbcclasspath_attr = ["classpath", driverPath]
	jdbcclasspath_nullpath_attr = ["classpath", ""]
        jdbcname_attr = ["name", jdbcname]
	jdbcimplclass_attr = ["implementationClassName", jdbcimplclass]
	jdbcdescription_attr = ["description", jdbcdesc]
        jdbcAttrs = [jdbcname_attr, jdbcclasspath_attr, jdbcimplclass_attr, jdbcdescription_attr]
	jdbcAttrs_nullpath = [jdbcname_attr, jdbcclasspath_nullpath_attr, jdbcimplclass_attr, jdbcdescription_attr]

        jdbcNoTemplateAttrs = [["classpath", driverPath], ["implementationClassName", jdbcimplclass], ["name", jdbcname], ["description", jdbcdesc]]

        jaasAttrs = [["alias", databasePasswordAlias], ["description", databaseDescription], ["userId", databaseUserId], ["password", databasePassword]]

        #-------------------------------------------------
        # Create / Update JAASAuthenication
        #-------------------------------------------------
        updJAAS = "false"
        jaasAuthDataList = AdminConfig.getid("/Cell:"+cellName+"/Security:/JAASAuthData:/" )
        jaasAuthDataList = wsadminToList(jaasAuthDataList)

        for jaasAuthData in jaasAuthDataList:
                jaasAuthDataName = AdminConfig.showAttribute(jaasAuthData, "alias" )
                if (cmp(jaasAuthDataName, databasePasswordAlias) == 0):
			
                        print "---> JAASAuthInfo for Database exists. Modifying JAASAuthInfo for "+jdbcname+" ......"
                        jdbc1 = AdminConfig.modify(jaasAuthData, jaasAttrs )
                        print "     Modified!"
                        updJAAS = "true"
                        break 
                #endIf 
        #endFor 

        if (cmp(updJAAS, "false") == 0):
		
                print "---> Creating new JAASAuthInfo for Database "+jdbcname+" login/password ......"
                security = AdminConfig.getid("/Cell:"+cellName+"/Security:/" )
                AdminConfig.create("JAASAuthData", security, jaasAttrs )
                print "     done!"
        #endIf 

        #-------------------------------------------------
        # Check to see if the jdbc we have requested
        # already exists. If it does, just update it.
        #-------------------------------------------------
        updJDBC = "false"
        jdbcProvider = AdminConfig.getid("/Cell:"+cellName+"/JDBCProvider:"+jdbcname )
        
        if (len(jdbcProvider) != 0):
		
                print "---> JDBC Provider exists. Modifying JDBC Provider "+jdbcname+" ......"
		jdbc1 = AdminConfig.modify(jdbcProvider, jdbcAttrs_nullpath )		
                jdbc1 = AdminConfig.modify(jdbcProvider, jdbcAttrs )
                print "     Modified!"
                updJDBC = "true"
        #endIf 

        if (cmp(updJDBC, "false") == 0):
                #---------------------------------------------------------
                # No template present, create the JDBCProvider from scratch
                #---------------------------------------------------------

                print "---> Creating a new JDBCProvider "+jdbcname+" ......"
                jdbcProvider = AdminConfig.create("JDBCProvider", cell, jdbcNoTemplateAttrs )
                print "     done!" 
        #endIf 

        #-------------------------------------------------
        # Check to see if the Data Source we have requested
        # already exists. If it doesn't, Create it first.
        #-------------------------------------------------
        ds = AdminConfig.getid("/Cell:"+cellName+"/JDBCProvider:"+jdbcname+"/DataSource:"+dsname+"/" ) 
        if (len(ds) != 0):

                print "---> Data Source exists. Modifying Data Source "+dsname+" ......"
        else:

                #---------------------------------------------------------
                # Create the Data source from scratch
                #---------------------------------------------------------
                print "---> Creating a new DataSource "+dsname+" for "+jdbcname+" ......"
                jndiAttrs = [["name", dsname], ["jndiName", [jdbcname]]]
                ds = AdminConfig.create("DataSource", jdbcProvider, jndiAttrs )
                print "     done!"

                dsHelper_attr = ["datasourceHelperClassname", dsHelper]
                attrs = [dsHelper_attr]
                AdminConfig.modify(ds, attrs )
        #endElse 

        #--------------------------------------------------------------
        # Modify the DataSource - give it a name and a jndiName, and remove 
        # existing properties created by the template
        # A collection of objects (such as the resourceProperties attribute of the
        # propertySet attribute) can only be added to.  To completely replace
        # the collection you need to delete the old one first.
        #--------------------------------------------------------------

        print "---> Modifying the datasource object -- name, jndiName and removing old properties ......"

        name_attr = ["name", dsname]
        jndiName_attr = ["jndiName", dsjndiname]
        dsHelper_attr = ["datasourceHelperClassname", dsHelper]
        auth_attr = ["authDataAlias", databasePasswordAlias]
        authmech_attr = ["authMechanismPreference", "BASIC_PASSWORD"]
        map_module = [["authDataAlias", databasePasswordAlias], ["mappingConfigAlias", "dsMappingConfigAlias_0"]]
        mapping_attr = ["mapping", map_module]
        ps_attr = ["propertySet", []]
        cache_statement_attr = ["statementCacheSize", stmentCacheSize]
        attrs = [name_attr, jndiName_attr, dsHelper_attr, auth_attr, authmech_attr, mapping_attr, ps_attr, cache_statement_attr]

        AdminConfig.modify(ds, attrs )

        print "     Modified!"

        #--------------------------------------------------------------
        # Change DataSource ConnectionPool settings
        #--------------------------------------------------------------

        print "---> Modifying DataSource ConnectionPool settings ......"
        connPool = AdminConfig.list("ConnectionPool", ds )
        AdminConfig.modify(connPool, [["agedTimeout", agedTimeout], ["connectionTimeout", connectionTimeout], ["maxConnections", maxConnections], ["minConnections", minConnections], ["purgePolicy", purgePolicy], ["reapTime", reapTime], ["unusedTimeout", unusedTimeout]] )
        try:
            _excp_ = 0
            AdminConfig.modify(connPool, [["stuckTime", stuckTime], ["stuckTimerTime", stuckTimerTime], ["stuckThreshold", stuckThreshold]] )
        except:   
            print "---> Could not configure advanced conn pool settings. Processing continued"
            _excp_ = 0
        #endTry
 		#
		#

        print "     Modifed!"
        
        #--------------------------------------------------------------
	# Add DataSource ConnectionTest settings (if required)
        #--------------------------------------------------------------
	# ds = AdminConfig.getid("/Cell:wastst02Network/JDBCProvider:PegaRULES/DataSource:PegaRULES_Dev00/")
	#
	
	print "---> Modifying ConnectionPool test connection settings ......"

	preTestConnection_attr = ["testConnection", "false"] 
	retryInterval_attr = ["testConnectionInterval", "10"]
	testConnection_attrs = [preTestConnection_attr, retryInterval_attr]

	AdminConfig.modify(connPool, testConnection_attrs )
	print "     Modifed!"

	
        #--------------------------------------------------------------
        # Add desired properties to the DataSource.
        #--------------------------------------------------------------

        print "---> Modifying the datasource object -- adding new properties ......"

        if (cmp(dsj2eeAttr, "") == 0):
                dsj2eeAttr = [[["name", "transactionBranchesLooselyCoupled"], ["type", "java.lang.Boolean"], ["value", "true"]]]
        #endIf 
        
        if (cmp(databaseURL, "") != 0):
	        dbname_attr = [["name", "URL"], ["value", databaseURL], ["type", "java.lang.String"], ["required", "true"]]
	        dsj2eeAttr.append(dbname_attr)
	#EndIf

        resprops = ["resourceProperties", dsj2eeAttr]
        ps_attr = ["propertySet", [resprops]]
        attrs = [ps_attr]

        AdminConfig.modify(ds, attrs )

        print "     Modified!"

        #--------------------------------------------------------------
        # Modify the DataSource to give it a relational resource adapter.
        # We use the built-in rra on the node. 
        #--------------------------------------------------------------

        print "---> Modifying the datasource object -- relationalResourceAdapter"
        rra = AdminConfig.getid("/Cell:"+cellName+"/J2CResourceAdapter:WebSphere Relational Resource Adapter/" )

        rra_attr = ["relationalResourceAdapter", rra]
        attrs = [rra_attr]

        AdminConfig.modify(ds, attrs )

        print "     Modified!"

        #---------------------------------------------------------
        # Create a CMPConnectorFactory, using the datasource from earlier 
        #---------------------------------------------------------

        print "---> Creating a new CMPConnectorFactory object "+cfname+" ......"

        name_attr = ["name", cfname]
        auth_attr = ["authDataAlias", databasePasswordAlias]
        authmech_attr = ["authMechanismPreference", "BASIC_PASSWORD"]
        cmpds_attr = ["cmpDatasource", ds]
        p_trans_res = [["name", "TransactionResourceRegistration"], ["type", "java.lang.String"], ["value", "dynamic"], ["description", "Type of transaction resource registration (enlistment). Valid values are either static (immediate) or dynamic (deferred)."]]
        inactiveConnSupport = [["name", "InactiveConnectionSupport"], ["type", "java.lang.Boolean"], ["value", "true"], ["description", "Specify whether connection handles support implicit reactivation. (Smart Handle support). Value may be true or false."]]
        newprops = [p_trans_res, inactiveConnSupport]
        resprops = ["resourceProperties", newprops]
        ps_attr = ["propertySet", [resprops]]
        mapping_attr = ["mapping", map_module]
        attrs = [name_attr, auth_attr, authmech_attr, cmpds_attr, ps_attr, mapping_attr]
        newcf = AdminConfig.create("CMPConnectorFactory", rra, attrs )

        print "     done!"
#endDef 

def wsadminToList(inStr):
    outList=[]
    if (len(inStr)>0 and inStr[0]=='[' and inStr[-1]==']'):
            tmpList = inStr[1:-1].split(" ")
    else:
            tmpList = inStr.split("\n")  #splits for Windows or Linux
    for item in tmpList:
            item = item.rstrip();        #removes any Windows "\r"
            if (len(item)>0):
                    outList.append(item)
    return outList
#endDef

#--------------------------------------------------------------
# Save all the changes 
#--------------------------------------------------------------
def saveConfigAndSync (  ):
    print "---> Saving the configuration ......"
    AdminConfig.save( )
    print "     done!"
    
    print "     Invoking full resynchronization"
    configs = AdminControl.queryNames("*:*,type=ConfigRepository,process=nodeagent")
    configs = wsadminToList(configs)
    for nodeInstanceConfig in configs:
        print "     Refreshing Epoch for "+nodeInstanceConfig+" ..."
        AdminControl.invoke(nodeInstanceConfig, "refreshRepositoryEpoch")
    #endFor
    sleep(30 )
    print "     Done."
    return 
#endDef 

<% node[:base_was][:was][:jdbc].each do |jdbcname, jdbc| %>
installJDBC("<%= jdbcname %>", 
            "<%= jdbc[:driverPath] %>", 
            "<%= jdbc[:dsname] %>", 
            "<%= jdbc[:dsjndiname] %>", 
            "<%= jdbc[:databaseURL] %>", 
            "<%= jdbc[:cfname] %>", 
            "<%= jdbc[:databasePasswordAlias] %>", 
            "<%= jdbc[:databaseUserId] %>", 
            "<%= jdbc[:databasePassword] %>", 
            "<%= jdbc[:databaseDescription] %>", 
            "<%= jdbc[:agedTimeout] %>", 
            "<%= jdbc[:connectionTimeout] %>", 
            "<%= jdbc[:maxConnections] %>", 
            "<%= jdbc[:minConnections] %>", 
            "<%= jdbc[:purgePolicy] %>", 
            "<%= jdbc[:dsReapTime] %>", 
            "<%= jdbc[:dsUnusedTimeout] %>", 
            "<%= jdbc[:stmentCacheSize] %>", 
            "<%= jdbc[:jdbcj2eeAttr] %>", 
            "<%= jdbc[:jdbcimplclass] %>", 
            "<%= jdbc[:jdbcdesc] %>", 
            "<%= jdbc[:dsHelper] %>", 
            "<%= jdbc[:dsj2eeAttr] %>", 
            "<%= jdbc[:stuckTime] %>", 
            "<%= jdbc[:stuckTimerTime] %>", 
            "<%= jdbc[:stuckThreshold] %>" )
<% end %>
saveConfigAndSync()
