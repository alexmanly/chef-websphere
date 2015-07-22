name "was"
description "WebSphere Administration Server role for Centos nodes"
run_list "recipe[base-was]"
override_attributes(
  "base-was" => {
    "hostname" => "websphere",
    "internal_ip" => "10.0.0.91",
    "packages" => ["wget", "unzip", "gtk2.i686", "libXtst.i686"],
    "ibm_home" => "/opt/IBM",
    "was" => {
      "install_dir" => "/opt/IBM/WebSphere85",
      "install_file_uris" => [
        "https://s3-eu-west-1.amazonaws.com/websphere-demo/WASND_v8.5.5_1of3.zip",
        "https://s3-eu-west-1.amazonaws.com/websphere-demo/WASND_v8.5.5_2of3.zip",
        "https://s3-eu-west-1.amazonaws.com/websphere-demo/WASND_v8.5.5_3of3.zip"
      ]
    },
    "iim" => {
      "install_dir" => "/opt/IBM/iim",
      "install_data_dir" => "/opt/IBM/iim-data",
      "install_file_uri" => "https://s3-eu-west-1.amazonaws.com/websphere-demo/Install_Mgr_v1.6.2_Lnx_WASv8.5.5.zip"
    }
  }
)