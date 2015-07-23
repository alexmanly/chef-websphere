node[:base_was][:was][:profiles].each do | profile_name,  profile |
  was_manage_profile "create_#{profile[:type]}_#{profile_name}"  do
    install_dir node[:base_was][:was][:install_dir]
    profile_name "#{profile_name}"
    profile_type profile[:type]
    node_name "#{profile_name}"
    cell_name profile[:cell]
    host_name profile[:host]
    enable_admin_security profile[:enable_security]
    admin_username profile[:admin_username]
    admin_password profile[:admin_password]
    starting_port profile[:starting_port]
    dmgr_host profile[:dmgr_host]
    dmgr_port profile[:dmgr_port]
    action :create
  end
end