node[:base_was][:was][:profiles].each do | name,  profile |
  was_manage_profile "create_#{profile[:type]}_#{name}"  do
    install_dir node[:base_was][:was][:install_dir]
    profile_name name
    profile_type profile[:type]
    node_name name
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

node[:base_was][:was][:profiles].each do | name,  profile |
  if ('dmgr' == profile[:type])
    was_manage_profile "wsadmin_#{profile[:type]}_#{name}"  do
      install_dir node[:base_was][:was][:install_dir]
      profile_name name
      admin_username profile[:admin_username]
      admin_password profile[:admin_password]
      action :wsadmin
    end
  end
end
