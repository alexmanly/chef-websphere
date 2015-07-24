name 'was'
description 'WebSphere Administration Server role for Centos nodes'
run_list 'recipe[base-was]'
override_attributes(
  :base_was => {
    :hostname => 'websphere',
    :internal_ip => '10.0.0.90',
    :packages => ['wget', 'unzip', 'gtk2.i686', 'libXtst.i686'],
    :ibm_home => '/opt/IBM',
    :iim => {
      :install_dir => '/opt/IBM/iim',
      :install_data_dir => '/opt/IBM/iim-data',
      :install_file_uri => 'https://s3-eu-west-1.amazonaws.com/websphere-demo/Install_Mgr_v1.6.2_Lnx_WASv8.5.5.zip'
    },
    :was => {
      :install_dir => '/opt/IBM/WebSphere85',
      :product_id => 'com.ibm.websphere.ND.v85_8.5.5000.20130514_1044',
      :install_file_uris => [
        'https://s3-eu-west-1.amazonaws.com/websphere-demo/WASND_v8.5.5_1of3.zip',
        'https://s3-eu-west-1.amazonaws.com/websphere-demo/WASND_v8.5.5_2of3.zip',
        'https://s3-eu-west-1.amazonaws.com/websphere-demo/WASND_v8.5.5_3of3.zip'
      ],
      :profiles => {
        :Dmgr01 => {
          :type => 'dmgr',
          :cell => 'cell01',
          :host => 'websphere',
          :enable_security => 'true',
          :admin_username => 'wasadmin',
          :admin_password => 'wasadmin',
          :starting_port => '28000'
        },
        :node01 => {
          :type => 'managed',
          :cell => 'cell01_default',
          :host => 'websphere',
          :dmgr_host => 'websphere',
          :admin_username => 'wasadmin',
          :admin_password => 'wasadmin',
          :dmgr_port => '28003'
        }
      },
      :application => {
        :perf_servlet_app => {
          :node_name => 'node01',
          :server_name => 'server01',
          :path => '/opt/IBM/WebSphere85/installableApps/PerfServletApp.ear'
        }
      },
      :jdbc => {
        :my_jdbc => {
          :driverPath => '/opt/IBM/WebSphere85/oracle/lib/ojdbc6.jar',
          :dsname => 'my_ds',
          :dsjndiname => 'jndi_my_ds',
          :databaseURL => 'jdbc:oracle:thin:@//10.0.0.80:1521/DB1',
          :cfname => '',
          :databasePasswordAlias => 'demo_user',
          :databaseUserId => 'demo',
          :databasePassword => 'demo',
          :databaseDescription => 'demo oracle database',
          :agedTimeout => '0',
          :connectionTimeout => '1900',
          :maxConnections => '50',
          :minConnections => '5',
          :purgePolicy => 'EntirePool',
          :dsReapTime => '180',
          :dsUnusedTimeout => '1800',
          :stmentCacheSize => '10',
          :jdbcj2eeAttr => '',
          :jdbcimplclass => '',
          :jdbcdesc => '',
          :dsHelper => '',
          :dsj2eeAttr => '',
          :stuckTime => '0',
          :stuckTimerTime => '0',
          :stuckThreshold => '0'
        }
      }
    }
  }
)