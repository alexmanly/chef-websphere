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
        execute "#{manage_cmd}_#{new_resource.profile_type}_#{new_resource.profile_name}" do
          command "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/#{manage_cmd}.sh "\
                  "-username #{new_resource.admin_username} "\
                  "-password #{new_resource.admin_password}"
          cwd "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin"
          guard_interpreter :bash
          not_if "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/serverStatus.sh #{new_resource.profile_type} "\
                 "-profileName #{new_resource.profile_name} "\
                 "-username #{new_resource.admin_username} "\
                 "-password #{new_resource.admin_password} | grep #{current_status}"
        end
      end
    end
  end
end