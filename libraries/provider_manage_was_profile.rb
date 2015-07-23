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
        start(true)
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
        start(false)
      end

      action :start_dmgr do
        start(true)
      end

      action :stop_dmgr do
        stop(true)
      end

      action :start_node do
        start(false)
      end

      action :stop_node do
        stop(false)
      end

      def start(is_dmgr)
        type = is_dmgr ? "dmgr" : "nodeagent"
        cmd = is_dmgr ? "startManager.sh" : "startNode.sh"
        execute "start_#{type}_#{new_resource.profile_name}" do
          command "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/#{cmd}"
          cwd "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin"
          guard_interpreter :bash
          not_if "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/serverStatus.sh #{type} "\
                 "-profileName #{new_resource.profile_name} "\
                 "-username #{new_resource.admin_username} "\
                 "-password #{new_resource.admin_password} | grep STARTED"
        end
      end

      def stop(is_dmgr)
        type = is_dmgr ? "dmgr" : "nodeagent"
        cmd = is_dmgr ? "stopManager.sh" : "stopNode.sh"
        execute "stop_#{type}_#{new_resource.profile_name}" do
          command "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/#{cmd} "\
                  "-user #{new_resource.admin_username} "\
                  "-password #{new_resource.admin_password}"
          cwd "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin"
          guard_interpreter :bash
          only_if "#{new_resource.install_dir}/profiles/#{new_resource.profile_name}/bin/serverStatus.sh #{type} "\
                  "-profileName #{new_resource.profile_name} "\
                  "-username #{new_resource.admin_username} "\
                  "-password #{new_resource.admin_password} | grep STARTED"
        end
      end
    end
  end
end