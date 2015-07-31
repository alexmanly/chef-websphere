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

dmgr = Chef::Provider::WasManageProfile.findDmgr(node)
unless dmgr.empty?
  # Execute the WASADMIN Scripts
  current_data = {}
  was_manage_profile "wsadmin_#{dmgr[:profile][:type]}_#{dmgr[:name]}"  do
    install_dir node[:base_was][:was][:install_dir]
    profile_name dmgr[:name]
    admin_username dmgr[:profile][:admin_username]
    admin_password dmgr[:profile][:admin_password]
    script_path "#{dmgr[:name]}_jacl"
    script_language "jacl"
    data current_data
    action :wsadmin_all_scripts
  end

  jdbcs = Chef::Provider::WasManageProfile.jdbcArray(node)
  unless jdbcs.empty?
    jdbcs.each do | current_jdbc |

      was_manage_profile "install JDBC library #{current_jdbc[:jdbcName]}" do
        data current_jdbc
        install_dir node[:base_was][:was][:install_dir]
        action :install_jdbc_library
      end

      was_manage_profile "create JDBC-DataSource #{current_jdbc[:jdbcName]}-#{current_jdbc[:dataSourceName]}"  do
        install_dir node[:base_was][:was][:install_dir]
        profile_name dmgr[:name]
        admin_username dmgr[:profile][:admin_username]
        admin_password dmgr[:profile][:admin_password]
        script_path "#{dmgr[:name]}_py"
        script_language "jython"
        script_name "installJDBC.py"
        data current_jdbc
        action :wasadmin_single_script
      end
    end
  end
end