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

    # Generate the db URL based on a Chef search of the date source defined role and matching environments
    db_urls = {}
    node[:base_was][:was][:jdbc].each do | jdbcname,  jdbc |
      jdbc[:ds].each do |dsname, ds|
        db_urls[dsname] = ''
        search(:node, "role:#{ds[:chefRole]} AND chef_environment:#{node.chef_environment}").each do | server |
          if server.nil?
            log "The Chef search found no servers based with a role 'role:#{ds[:chefRole]} and an environment '#{node.chef_environment}'.  Using the default DB URL '#{ds[:defaultDatabaseURL]}'" 
          else 
            server[:oracle][:rdbms][:dbs].each do | dbs_name, bool |
              if (dbs_name == dsname)
                db_url = "#{ds[:databaseURLPerfix]}#{server["fqdn"]}:#{ds[:databasePort]}/#{dsname}"
                db_urls[dbs_name] = db_url
                log "The Chef search generated found this data source '#{dbs_name}' and generated this Oracle DB URL:- #{db_url}" 
              end
            end
          end
        end
      end
    end

    was_manage_profile "wsadmin_#{profile[:type]}_#{name}"  do
      install_dir node[:base_was][:was][:install_dir]
      profile_name name
      admin_username profile[:admin_username]
      admin_password profile[:admin_password]
      script_path "#{name}_py"
      script_language "jython"
      script_name "installJDBC.py"
      script_data db_urls
      action :wasadmin_single_script
    end
  end
end