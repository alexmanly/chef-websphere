node[:base_was][:packages].each do |pkg|
  package pkg
end

iim 'install_iim' do
  iim_install_dir node[:base_was][:iim][:install_dir]
  iim_data_dir node[:base_was][:iim][:install_data_dir]
  iim_uri node[:base_was][:iim][:install_file_uri]
  action :install_iim
  not_if do ::File.exists?(node[:base_was][:iim][:install_dir] + "/eclipse/tools/imcl") end
end

iim 'install_was' do
  iim_install_dir node[:base_was][:iim][:install_dir]
  product_id node[:base_was][:was][:product_id]
  product_uris node[:base_was][:was][:install_file_uris]
  product_install_dir node[:base_was][:was][:install_dir]
  action :install_product
  not_if do ::File.exists?(node[:base_was][:was][:install_dir] + "/bin/manageprofiles.sh") end
end

file "/etc/profile.d/websphere.sh" do
  action :create_if_missing
  mode "0755"
  content <<-EOD
# Increase the file descriptor limit to support WAS
# See http://pic.dhe.ibm.com/infocenter/iisinfsv/v8r5/topic/com.ibm.swg.im.iis.found.admin.common.doc/topics/t_admappsvclstr_ulimits.html
ulimit -n 20480
EOD
end

file "/etc/security/limits.d/websphere.conf" do
  action :create_if_missing
  mode "0755"
  content <<-EOD
# Increase the limits for the number of open files for the pam_limits module to support WAS
# See http://pic.dhe.ibm.com/infocenter/iisinfsv/v8r5/topic/com.ibm.swg.im.iis.found.admin.common.doc/topics/t_admappsvclstr_ulimits.html
* soft nofile 20480
* hard nofile 20480
EOD
end