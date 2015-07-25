default[:base_was][:hostname] = 'websphere'
default[:base_was][:hosts] =  {
	'localhost' => '127.0.0.1',
	'chefserver' => '10.0.0.10', 
	'chefanalytics' => '10.0.0.20',
	'centosweb01' => '10.0.0.30',
	'centosweb02' => '10.0.0.40',
	'loadbalancer' => '10.0.0.50',
	'chefdk' => '10.0.0.60',
	'oracledb' => '10.0.0.80',
	node[:base_was][:hostname] => node[:ipaddress]
}
default[:base_was][:packages] = ["wget", "unzip", "gtk2.i686", "libXtst.i686"]
default[:base_was][:ibm_home] = '/opt/IBM'

default[:base_was][:device_id] = '/dev/xvde'
default[:base_was][:partition_number] = '2'
default[:base_was][:partition_size] = '+7G'
default[:base_was][:fs_type] = 'ext4'

default[:base_was][:iim][:install_dir] = node[:base_was][:ibm_home] + "/iim"
default[:base_was][:iim][:install_data_dir] = node[:base_was][:ibm_home] + "/iim-data"
default[:base_was][:iim][:install_file_uri] = "https://s3-eu-west-1.amazonaws.com/websphere-demo/Install_Mgr_v1.6.2_Lnx_WASv8.5.5.zip"

default[:base_was][:was][:install_dir] = node[:base_was][:ibm_home] + "/WebSphere85"
default[:base_was][:was][:product_id] = "com.ibm.websphere.ND.v85_8.5.5000.20130514_1044"
default[:base_was][:was][:install_file_uris] = [ "https://s3-eu-west-1.amazonaws.com/websphere-demo/WASND_v8.5.5_1of3.zip",
                                                 "https://s3-eu-west-1.amazonaws.com/websphere-demo/WASND_v8.5.5_2of3.zip",
                                                 "https://s3-eu-west-1.amazonaws.com/websphere-demo/WASND_v8.5.5_of3.zip" ]

default[:base_was][:was][:profiles][:Dmgr01][:type] = 'dmgr'
default[:base_was][:was][:profiles][:Dmgr01][:cell] = 'cell01'
default[:base_was][:was][:profiles][:Dmgr01][:host] = node[:base_was][:hostname]
default[:base_was][:was][:profiles][:Dmgr01][:enable_security] = 'true'
default[:base_was][:was][:profiles][:Dmgr01][:admin_username] = 'wasadmin'
default[:base_was][:was][:profiles][:Dmgr01][:admin_password] = 'wasadmin'
default[:base_was][:was][:profiles][:Dmgr01][:starting_port] = '28000'

default[:base_was][:was][:profiles][:node01][:type] = 'managed'
default[:base_was][:was][:profiles][:node01][:cell] = 'cell01_default'
default[:base_was][:was][:profiles][:node01][:host] = node[:base_was][:hostname]
default[:base_was][:was][:profiles][:node01][:dmgr_host] = node[:base_was][:was][:profiles][:Dmgr01][:host]
default[:base_was][:was][:profiles][:node01][:admin_username] = node[:base_was][:was][:profiles][:Dmgr01][:admin_username]
default[:base_was][:was][:profiles][:node01][:admin_password] = node[:base_was][:was][:profiles][:Dmgr01][:admin_password]
default[:base_was][:was][:profiles][:node01][:dmgr_port] = '28003'

default[:base_was][:was][:application][:perf_servlet_app][:node_name] = "node01"
default[:base_was][:was][:application][:perf_servlet_app][:server_name] = "server01"
default[:base_was][:was][:application][:perf_servlet_app][:path] = node[:base_was][:was][:install_dir] + "/installableApps/PerfServletApp.ear"

default[:base_was][:was][:jdbc][:oracle][:driverPath] = node[:base_was][:was][:install_dir] + "/oracle/lib/ojdbc6.jar"
default[:base_was][:was][:jdbc][:oracle][:driverClass] = 'oracle.jdbc.xa.client.OracleXADataSource'
default[:base_was][:was][:jdbc][:oracle][:templateName] = "Oracle JDBC Driver"
default[:base_was][:was][:jdbc][:oracle][:jdbcName] = 'Oracle JDBC Driver (XA)'
default[:base_was][:was][:jdbc][:oracle][:jdbcDescription] = 'Oracle JDBC Driver (XA)'
default[:base_was][:was][:jdbc][:oracle][:url] = 'https://s3-eu-west-1.amazonaws.com/oracle-demo/ojdbc6.jar'

default[:base_was][:was][:jdbc][:oracle][:ds][:DB1][:chefRole] = 'oracledb'
default[:base_was][:was][:jdbc][:oracle][:ds][:DB1][:dsjndiname] = "jndi_demo"
default[:base_was][:was][:jdbc][:oracle][:ds][:DB1][:defaultDatabaseURL] = "jdbc:oracle:thin:@//10.0.0.80:1521/DB1"
default[:base_was][:was][:jdbc][:oracle][:ds][:DB1][:databaseURLPerfix] = "jdbc:oracle:thin:@//"
default[:base_was][:was][:jdbc][:oracle][:ds][:DB1][:databasePort] = "1521"
default[:base_was][:was][:jdbc][:oracle][:ds][:DB1][:cfname] = ""
default[:base_was][:was][:jdbc][:oracle][:ds][:DB1][:databasePasswordAlias] = "demo_user"
default[:base_was][:was][:jdbc][:oracle][:ds][:DB1][:databaseUserId] = "demo"
default[:base_was][:was][:jdbc][:oracle][:ds][:DB1][:databasePassword] = "demo"
default[:base_was][:was][:jdbc][:oracle][:ds][:DB1][:databaseDescription] = "demo oracle database"
default[:base_was][:was][:jdbc][:oracle][:ds][:DB1][:dsHelper] = "com.ibm.websphere.rsadapter.Oracle11gDataStoreHelper"

