require 'chef/provider/lwrp_base'
require 'chef/search/query'

class Chef
  class Provider
    class WasManageProfile < Chef::Provider::LWRPBase
      
      provides :was_manage_profile if defined?(provides)

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        converge_by("Create and start profile called '#{new_resource.profile_name}' of type '#{new_resource.profile_type}'") do
          e = execute "create_profile_#{new_resource.profile_type}_#{new_resource.profile_name}" do
            command create_profile_command
            cwd "#{new_resource.install_dir}/bin"
            guard_interpreter :bash
            not_if "#{new_resource.install_dir}/bin/manageprofiles.sh -listProfiles | grep #{new_resource.profile_name}"
          end
          start
          if (!new_resource.updated_by_last_action?)
            new_resource.updated_by_last_action(e.updated_by_last_action?)
          end
        end
      end

      action :delete do
        converge_by("Stop and delete profile called '#{new_resource.profile_name}' of type '#{new_resource.profile_type}'") do
          stop
          e = execute "delete_profile_#{new_resource.profile_type}_#{new_resource.profile_name}" do
            command "#{new_resource.install_dir}/bin/manageprofiles.sh -delete "\
                    "-profileName #{new_resource.profile_name} "
            cwd "#{new_resource.install_dir}/bin"
            guard_interpreter :bash
            only_if "#{new_resource.install_dir}/bin/manageprofiles.sh -listProfiles | grep #{new_resource.profile_name}"
          end
          if (!new_resource.updated_by_last_action?)
            new_resource.updated_by_last_action(e.updated_by_last_action?)
          end
        end
      end

      action :start do
        converge_by("Start profile called '#{new_resource.profile_name}' of type '#{new_resource.profile_type}'") do
          start
        end
      end

      action :stop do
        converge_by("Stop profile called '#{new_resource.profile_name}' of type '#{new_resource.profile_type}'") do
          stop
        end
      end

      action :wsadmin_all_scripts do
        converge_by("Execute all #{new_resource.script_language} wasadmin scripts from the cookbook template folder '#{new_resource.script_path}'") do
          scripts_location = scripts_cache_dir
          # Copy all scripts from the templates scritps dir to the cache scripts dir
          run_context.cookbook_collection['base-was'].manifest['templates'].each do |tmplt|
            if tmplt['path'].include? new_resource.script_path
              execute_wasadmin_script(tmplt['name'], scripts_location)
            end
          end
        end
      end

      action :wasadmin_single_script do
        converge_by("Execute a single #{new_resource.script_language} wasadmin script called '#{new_resource.script_name}' from the cookbook template folder '#{new_resource.script_path}'") do
          scripts_location = scripts_cache_dir
          execute_wasadmin_script(new_resource.script_name, scripts_cache_dir)
        end
      end

      action :install_jdbc_library do
        converge_by("Installing  JDBC Library '#{new_resource.data[:jdbcName]}'") do
          # create jdbc lib directory
          directory "#{new_resource.install_dir}/#{new_resource.data[:jdbcName]}/lib" do
            recursive true
            not_if do ::File.exists?(new_resource.data[:driverPath]) end
          end

          # download jdbc libs
          r = remote_file new_resource.data[:driverPath] do
            source new_resource.data[:jdbcUrl]
            action :create
            not_if do ::File.exists?(new_resource.data[:driverPath]) end
          end

          if (!new_resource.updated_by_last_action?)
            new_resource.updated_by_last_action(r.updated_by_last_action?)
          end
        end
      end

      def scripts_cache_dir
        # Create stripts directory in the cache
        scripts_location = Chef::Config[:file_cache_path] + '/' + new_resource.script_path

        directory scripts_location do
          recursive true
          action :create
        end

        return scripts_location
      end

      def execute_wasadmin_script(script_name, scripts_location)
        template script_name do
          path scripts_location + '/' + script_name
          source new_resource.script_path + '/' + script_name
          sensitive true
          variables(
            :data => new_resource.data
          )
        end

        e = execute "execute_wasdmin_with_file_#{script_name}" do
          cwd "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin"
          command "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/wsadmin.sh "\
                  "-lang #{new_resource.script_language} "\
                  "-f #{scripts_location}/#{script_name} "\
                  "-conntype SOAP "\
                  "-user #{new_resource.admin_username} "\
                  "-password #{new_resource.admin_password}"
        end

        if (!new_resource.updated_by_last_action?)
          new_resource.updated_by_last_action(e.updated_by_last_action?)
        end

        file "#{scripts_location}/#{script_name}" do 
          action :delete
        end
      end

      def create_profile_command
        cmd = "#{new_resource.install_dir}/bin/manageprofiles.sh -create "\
                  "-profileName #{new_resource.profile_name} "\
                  "-templatePath #{new_resource.install_dir}/profileTemplates/#{new_resource.profile_type} "\
                  "-nodeName #{new_resource.node_name} "\
                  "-cellName #{new_resource.cell_name} "\
                  "-hostName #{new_resource.host_name} "
        if (new_resource.profile_type == 'dmgr') 
          cmd = cmd + "-enableAdminSecurity #{new_resource.enable_admin_security} "\
                  "-adminUserName #{new_resource.admin_username} "\
                  "-adminPassword #{new_resource.admin_password} "\
                  "-startingPort #{new_resource.starting_port}"
        else
          cmd = cmd + "-dmgrAdminUserName #{new_resource.admin_username} "\
                  "-dmgrAdminPassword #{new_resource.admin_password} "\
                  "-dmgrHost #{new_resource.dmgr_host} "\
                  "-dmgrPort #{new_resource.dmgr_port}"
        end
        return cmd
      end

      def start
        execute_command(new_resource.profile_type == 'dmgr' ? 'startManager' : 'startNode', 'STARTED')
      end

      def stop
        execute_command(new_resource.profile_type == 'dmgr' ? 'stopManager' : 'stopNode', 'stopped')
      end

      def execute_command(manage_cmd, current_status)
        type = new_resource.profile_type == 'dmgr' ? 'dmgr' : 'nodeagent'
        e = execute "#{manage_cmd}_#{new_resource.profile_type}_#{new_resource.profile_name}" do
          command "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/#{manage_cmd}.sh "\
                  "-username #{new_resource.admin_username} "\
                  "-password #{new_resource.admin_password}"
          cwd "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin"
          guard_interpreter :bash
          not_if "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/serverStatus.sh #{type} "\
                 "-profileName #{new_resource.profile_name} "\
                 "-username #{new_resource.admin_username} "\
                 "-password #{new_resource.admin_password} | grep #{current_status}"
        end
        if (!new_resource.updated_by_last_action?)
          new_resource.updated_by_last_action(e.updated_by_last_action?)
        end
      end

      def self.findDmgr(node)
        dmgr = {}
        node[:base_was][:was][:profiles].each do | name,  profile |
          if ('dmgr' == profile[:type])
            dmgr[:profile] = profile
            dmgr[:name] = name;
            return dmgr
          end
        end
        Chef::Log.error("The dmgr profile data has not been set for this node")
        return nil
      end
      
      def self.jdbcArray(node)
        jdbc_array = []
        jdbcs = node[:base_was][:was][:jdbc] rescue nil
        if !jdbcs.nil?
          jdbcs.each do | jdbcname,  jdbc |
            jdbc[:ds].each do |dsname, ds|
              jdbc_array << {
                :jdbcName => jdbcname,
                :jdbcUrl => jdbc[:url],
                :templateName => jdbc[:templateName],
                :driverPath => jdbc[:driverPath],
                :driverClass => jdbc[:driverClass],
                :jdbcDescription => jdbc[:jdbcDescription],
                :dataSourceName => dsname,
                :dsjndiname => ds[:dsjndiname],
                :dsUrl => search_DB_URL(dsname, ds, node.chef_environment),
                :cfname => ds[:cfname],
                :databasePasswordAlias => ds[:databasePasswordAlias],
                :databaseUserId => ds[:databaseUserId],
                :databasePassword => ds[:databasePassword],
                :databaseDescription => ds[:databaseDescription],
                :dsHelper => ds[:dsHelper]
              }
            end
          end
        end
        return jdbc_array
      end

      def self.search_DB_URL(dsname, ds, env_name)
        dbServers = Chef::Search::Query.new.search(:node, "role:#{ds[:chefRole]} AND chef_environment:#{env_name}")
        unless dbServers.empty?
          dbServers.each do | server |
            # require 'pry'
            # binding.pry
            unless ((server.is_a? Array) && server.empty?) || ((server.is_a? Fixnum) && server == 0)
              dbs = server[:oracle][:rdbms][:dbs] rescue nil
              if !dbs.nil?     
                dbs.each do | dbs_name, bool |
                  if (dbs_name == dsname)
                    searchUrl = "#{ds[:databaseURLPerfix]}#{server["fqdn"]}:#{ds[:databasePort]}/#{dsname}"
                    Chef::Log.info("The Chef search generated found this data source '#{dsname}' and generated this Oracle DB URL:- #{searchUrl}")
                    return searchUrl
                  end
                end
              end
            end
          end
        end
        Chef::Log.info("The Chef search found no servers based with a role '#{ds[:chefRole]} and an environment '#{env_name}'.  Using the default DB URL '#{ds[:defaultDatabaseURL]}'") 
        return ds[:defaultDatabaseURL]
      end
    end
  end
end