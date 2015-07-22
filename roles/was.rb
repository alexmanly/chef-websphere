name 'was'
description 'WebSphere Administration Server role for Centos nodes'
run_list 'recipe[base-was]'
override_attributes(
  :base_was => {
    :hostname => 'websphere',
    :internal_ip => '10.0.0.91',
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
        :dmgr => {
          :name => 'Dmgr01',
          :type => 'dmgr',
          :cell => 'cell01',
          :host => 'websphere',
          :enable_security => 'true',
          :admin_username => 'wasadmin',
          :admin_password => 'wasadmin',
          :starting_port => '28000',
          :dmgr_port => '28003'
        },
        :node01 => {
          :name => 'node01',
          :type => 'managed',
          :cell => 'cell01_default',
          :host => 'websphere'
        }
      }
    }
  }
)