# Create all the profiles bases on the data passed in
node[:base_was][:was][:profiles].each do | name,  profile |
  was_manage_profile "create_#{profile[:type]}_#{name}"  do
    install_dir node[:base_was][:was][:install_dir]
    profile_name name
    profile_type profile[:type]
    node_name name
    cell_name profile[:cell]
    host_name node[:base_was][:hostname]
    enable_admin_security profile[:enable_security]
    admin_username profile[:admin_username]
    admin_password profile[:admin_password]
    starting_port profile[:starting_port]
    dmgr_host node[:base_was][:hostname]
    dmgr_port profile[:dmgr_port]
    action :create
  end
end

node[:base_was][:was][:jdbc].each do | jdbcname,  jdbclib |
  was_manage_profile "install JDBC library #{jdbcname}" do
    jdbc jdbclib
    jdbc_name jdbcname
    install_dir node[:base_was][:was][:install_dir]
    action :install_jdbc_library
  end
end

# Execute the WASADMIN Scripts
node[:base_was][:was][:profiles].each do | name,  profile |
  if ('dmgr' == profile[:type])
    data = {}
    was_manage_profile "wsadmin_#{profile[:type]}_#{name}"  do
      install_dir node[:base_was][:was][:install_dir]
      profile_name name
      admin_username profile[:admin_username]
      admin_password profile[:admin_password]
      script_path "#{name}_jacl"
      script_language "jacl"
      script_data data
      action :wsadmin_all_scripts
    end

    was_manage_profile "wsadmin_#{profile[:type]}_#{name}"  do
      install_dir node[:base_was][:was][:install_dir]
      profile_name name
      admin_username profile[:admin_username]
      admin_password profile[:admin_password]
      script_path "#{name}_py"
      script_language "jython"
      script_name "installJDBC.py"
      script_data Chef::Provider::WasManageProfile.searchDBUrls(node)
      action :wasadmin_single_script
    end
  end
end