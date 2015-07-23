require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class WasManageProfile < Chef::Provider::LWRPBase
      provides :was_manage_profile if defined?(provides)

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        execute "create_profile_#{new_resource.profile_type}_#{new_resource.profile_name}" do
          command create_profile_command
          cwd "#{new_resource.install_dir}/bin"
          guard_interpreter :bash
          not_if "#{new_resource.install_dir}/bin/manageprofiles.sh -listProfiles | grep #{new_resource.profile_name}"
        end
        start
      end

      action :delete do
        stop
        execute "delete_profile_#{new_resource.profile_type}_#{new_resource.profile_name}" do
          command "#{new_resource.install_dir}/bin/manageprofiles.sh -delete "\
                  "-profileName #{new_resource.profile_name} "
          cwd "#{new_resource.install_dir}/bin"
          guard_interpreter :bash
          only_if "#{new_resource.install_dir}/bin/manageprofiles.sh -listProfiles | grep #{new_resource.profile_name}"
        end
      end

      action :start do
        start
      end

      action :stop do
        stop
      end

      action :wsadmin do

        # Create stripts directory in the cache
        scripts_location = Chef::Config[:file_cache_path] + '/' + new_resource.profile_name
        directory scripts_location do
          recursive true
          action :delete
        end
        directory scripts_location do
          recursive true
          action :create
        end

        # Copy all scripts from the templates scritps dir to the cache scripts dir
        run_context.cookbook_collection['base-was'].manifest['templates'].each do |tmplt|
          if tmplt['path'].include? new_resource.profile_name
            template tmplt['name'] do
              path scripts_location + '/' + tmplt['name']
              source new_resource.profile_name + '/' + tmplt['name']
            end

            execute "execute_wasdmin_with_file_#{tmplt['name']}" do
              cwd "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin"
              command "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/wsadmin.sh "\
                      "-lang jython "\
                      "-f #{scripts_location}/#{tmplt['name']} "\
                      "-conntype SOAP "\
                      "-user #{new_resource.admin_username} "\
                      "-password #{new_resource.admin_password}"
            end
          end
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
        execute "#{manage_cmd}_#{new_resource.profile_type}_#{new_resource.profile_name}" do
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
      end
    end
  end
end