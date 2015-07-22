default['base-was']['hostname'] = 'websphere'
default['base-was']['internal_ip'] = '10.0.0.91'
default['base-was']['hosts'] =  {
	'chefserver' => '10.0.0.10', 
	'chefanalytics' => '10.0.0.20',
	'centosweb01' => '10.0.0.30',
	'centosweb02' => '10.0.0.40',
	'loadbalancer' => '10.0.0.50',
	'chefdk' => '10.0.0.60',
	'oracledb' => '10.0.0.80',
	node['base-was']['hostname'] => node['base-was']['internal_ip']
}
default['base-was']['packages'] = ["wget", "unzip", "gtk2.i686", "libXtst.i686"]
default['base-was']['ibm_home'] = '/opt/IBM'

default['base-was']['device_id'] = '/dev/xvde'
default['base-was']['partition_number'] = '2'
default['base-was']['partition_size'] = '+7G'
default['base-was']['fs_type'] = 'ext4'

default['base-was']['iim']['install_dir'] = node['base-was']['ibm_home'] + "/iim"
default['base-was']['iim']['install_data_dir'] = node['base-was']['ibm_home'] + "/iim-data"
default['base-was']['iim']['install_file_uri'] = "https://s3-eu-west-1.amazonaws.com/websphere-demo/Install_Mgr_v1.6.2_Lnx_WASv8.5.5.zip"

default['base-was']['was']['install_dir'] = node['base-was']['ibm_home'] + "/WebSphere85"
default['base-was']['was']['product_id'] = "com.ibm.websphere.ND.v85_8.5.5000.20130514_1044"
default['base-was']['was']['install_file_uris'] = [ "https://s3-eu-west-1.amazonaws.com/websphere-demo/WASND_v8.5.5_1of3.zip",
												"https://s3-eu-west-1.amazonaws.com/websphere-demo/WASND_v8.5.5_2of3.zip",
												"https://s3-eu-west-1.amazonaws.com/websphere-demo/WASND_v8.5.5_of3.zip" ]

default['base-was']['was']['profiles']['dmgr']['name'] = 'Dmgr01'
default['base-was']['was']['profiles']['dmgr']['type'] = 'dmgr'
default['base-was']['was']['profiles']['dmgr']['cell'] = 'cell01'
default['base-was']['was']['profiles']['dmgr']['host'] = node['base-was']['hostname']
default['base-was']['was']['profiles']['dmgr']['enable_security'] = 'true'
default['base-was']['was']['profiles']['dmgr']['admin_username'] = 'wasadmin'
default['base-was']['was']['profiles']['dmgr']['admin_password'] = 'wasadmin'
default['base-was']['was']['profiles']['dmgr']['starting_port'] = '28000'
default['base-was']['was']['profiles']['dmgr']['dmgr_port'] = '28003'

default['base-was']['was']['profiles']['node01']['name'] = 'node01'
default['base-was']['was']['profiles']['node01']['type'] = 'managed'
default['base-was']['was']['profiles']['node01']['cell'] = 'cell01_default'
default['base-was']['was']['profiles']['node01']['host'] = node['base-was']['hostname']
