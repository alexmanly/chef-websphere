require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class WasManageProfile < Chef::Provider::LWRPBase
      provides :was_manage_profile if defined?(provides)

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :manage_dmgr do
        execute "create_profile_#{new_resource.profile_name}" do
          command "#{new_resource.install_dir}/bin/manageprofiles.sh -create "\
                  "-profileName #{new_resource.profile_name} "\
                  "-templatePath #{new_resource.install_dir}/profileTemplates/#{new_resource.profile_type} "\
                  "-nodeName #{new_resource.node_name} "\
                  "-cellName #{new_resource.cell_name} "\
                  "-hostName #{new_resource.host_name} "\
                  "-enableAdminSecurity #{new_resource.enable_admin_security} "\
                  "-adminUserName #{new_resource.admin_username} "\
                  "-adminPassword #{new_resource.admin_password} "\
                  "-startingPort #{new_resource.starting_port}"
          cwd "#{new_resource.install_dir}/bin"
          not_if do ::File.exists?("#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/serverStatus.sh") end
        end
      end

      action :start_dmgr do
        execute "start_dmgr_#{new_resource.profile_name}" do
          command "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/startManager.sh"
          cwd "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin"
          guard_interpreter :bash
          not_if "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/serverStatus.sh dmgr "\
                 "-profileName #{new_resource.profile_name} "\
                 "-username #{new_resource.admin_username} "\
                 "-password #{new_resource.admin_password} | grep STARTED"
        end
      end

      action :stop_dmgr do
        execute "stop_dmgr_#{new_resource.profile_name}" do
          command "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/stopManager.sh "\
                  "-user #{new_resource.admin_username} "\
                  "-password #{new_resource.admin_password}"
          cwd "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin"
          guard_interpreter :bash
          only_if "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/serverStatus.sh dmgr "\
                  "-profileName #{new_resource.profile_name} "\
                  "-username #{new_resource.admin_username} "\
                  "-password #{new_resource.admin_password} | grep STARTED"
        end
      end

      action :manage_node do
        execute "create_profile_#{new_resource.profile_name}" do
          command "#{new_resource.install_dir}/bin/manageprofiles.sh -create "\
                  "-profileName #{new_resource.profile_name} "\
                  "-templatePath #{new_resource.install_dir}/profileTemplates/#{new_resource.profile_type} "\
                  "-nodeName #{new_resource.node_name} "\
                  "-cellName #{new_resource.cell_name} "\
                  "-hostName #{new_resource.host_name} "\
                  "-dmgrAdminUserName #{new_resource.admin_username} "\
                  "-dmgrAdminPassword #{new_resource.admin_password} "\
                  "-dmgrHost #{new_resource.dmgr_host} "\
                  "-dmgrPort #{new_resource.dmgr_port}"
          cwd "#{new_resource.install_dir}/bin"
          not_if do ::File.exists?("#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/serverStatus.sh") end
        end
      end

      action :start_node do
        execute "start_node_#{new_resource.profile_name}" do
          command "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/startNode.sh"
          cwd "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin"
          guard_interpreter :bash
          not_if "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/serverStatus.sh nodeagent "\
                  "-profileName #{new_resource.profile_name} "\
                  "-username #{new_resource.admin_username} "\
                  "-password #{new_resource.admin_password} | grep STARTED"
        end
      end

      action :stop_node do
        execute "stop_node_#{new_resource.profile_name}" do
          command "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/stopNode.sh -user #{new_resource.admin_username} -password #{new_resource.admin_password}"
          cwd "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin"
          guard_interpreter :bash
          only_if "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/serverStatus.sh nodeagent "\
                  "-profileName #{new_resource.profile_name} "\
                  "-username #{new_resource.admin_username} "\
                  "-password #{new_resource.admin_password} | grep STARTED"
        end
      end

    end
  end
end