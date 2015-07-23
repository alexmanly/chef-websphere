was_manage_profile "create_dmgr_#{node[:base_was][:was][:profiles][:dmgr][:name]}"  do
  install_dir node[:base_was][:was][:install_dir]
  profile_name node[:base_was][:was][:profiles][:dmgr][:name]
  profile_type node[:base_was][:was][:profiles][:dmgr][:type]
  node_name node[:base_was][:was][:profiles][:dmgr][:name]
  cell_name node[:base_was][:was][:profiles][:dmgr][:cell]
  host_name node[:base_was][:was][:profiles][:dmgr][:host]
  enable_admin_security node[:base_was][:was][:profiles][:dmgr][:enable_security]
  admin_username node[:base_was][:was][:profiles][:dmgr][:admin_username]
  admin_password node[:base_was][:was][:profiles][:dmgr][:admin_password]
  starting_port node[:base_was][:was][:profiles][:dmgr][:starting_port]
  action :manage_dmgr
end

was_manage_profile "create_node_#{node[:base_was][:was][:profiles][:node01][:name]}"  do
  install_dir node[:base_was][:was][:install_dir]
  profile_name node[:base_was][:was][:profiles][:node01][:name]
  profile_type node[:base_was][:was][:profiles][:node01][:type]
  node_name node[:base_was][:was][:profiles][:node01][:name]
  cell_name node[:base_was][:was][:profiles][:node01][:cell]
  host_name node[:base_was][:was][:profiles][:node01][:host]
  admin_username node[:base_was][:was][:profiles][:dmgr][:admin_username]
  admin_password node[:base_was][:was][:profiles][:dmgr][:admin_password]
  dmgr_host node[:base_was][:was][:profiles][:dmgr][:host]
  dmgr_port node[:base_was][:was][:profiles][:dmgr][:dmgr_port]
  action :manage_node
end
