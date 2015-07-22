default[:base_was][:hostname] = 'websphere'
default[:base_was][:internal_ip] = '10.0.0.91'
default[:base_was][:hosts] =  {
	'chefserver' => '10.0.0.10', 
	'chefanalytics' => '10.0.0.20',
	'centosweb01' => '10.0.0.30',
	'centosweb02' => '10.0.0.40',
	'loadbalancer' => '10.0.0.50',
	'chefdk' => '10.0.0.60',
	'oracledb' => '10.0.0.80',
	node[:base_was][:hostname] => node[:base_was][:internal_ip]
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

default[:base_was][:was][:profiles][:dmgr][:name] = 'Dmgr01'
default[:base_was][:was][:profiles][:dmgr][:type] = 'dmgr'
default[:base_was][:was][:profiles][:dmgr][:cell] = 'cell01'
default[:base_was][:was][:profiles][:dmgr][:host] = node[:base_was][:hostname]
default[:base_was][:was][:profiles][:dmgr][:enable_security] = 'true'
default[:base_was][:was][:profiles][:dmgr][:admin_username] = 'wasadmin'
default[:base_was][:was][:profiles][:dmgr][:admin_password] = 'wasadmin'
default[:base_was][:was][:profiles][:dmgr][:starting_port] = '28000'
default[:base_was][:was][:profiles][:dmgr][:dmgr_port] = '28003'

default[:base_was][:was][:profiles][:node01][:name] = 'node01'
default[:base_was][:was][:profiles][:node01][:type] = 'managed'
default[:base_was][:was][:profiles][:node01][:cell] = 'cell01_default'
default[:base_was][:was][:profiles][:node01][:host] = node[:base_was][:hostname]
