# Create all the profiles bases on the data passed in
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

# Download JDBC Lib Jar file
node[:base_was][:was][:jdbc].each do | name,  jdbc |
  # create jdbc lib directory
  directory node[:base_was][:was][:install_dir] + "/" + name + "/lib" do
    recursive true
  end

  # download jdbc libs
  remote_file jdbc[:driverPath] do
    source jdbc[:url]
    action :create
    not_if do ::File.exists?(jdbc[:driverPath]) end
  end
end

node[:base_was][:was][:profiles].each do | name,  profile |
  if ('dmgr' == profile[:type])
    was_manage_profile "wsadmin_#{profile[:type]}_#{name}"  do
      install_dir node[:base_was][:was][:install_dir]
      profile_name name
      admin_username profile[:admin_username]
      admin_password profile[:admin_password]
      script_path "#{name}_jacl"
      script_language "jacl"
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
      action :wasadmin_single_script
    end
  end
end

