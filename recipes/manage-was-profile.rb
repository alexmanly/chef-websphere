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
    if (!profile[:wsadmin_scripts].empty?)
      profile[:wsadmin_scripts].each do | wsadmin_script |
        was_manage_profile "wsadmin_#{profile[:type]}_#{name}"  do
          install_dir node[:base_was][:was][:install_dir]
          profile_name name
          admin_username profile[:admin_username]
          admin_password profile[:admin_password]
          wsadmin_jython_file wsadmin_script
          action :wsadmin
        end
      end
    else
      Chef::Log.info "No wsadmin scripts to run for dmgr #{name}"
    end
  end
end