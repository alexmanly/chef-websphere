require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class WasManageProfile < Chef::Resource::LWRPBase
      provides :was_manage_profile

      self.resource_name = :was_manage_profile
      actions :manage_dmgr, :start_dmgr, :stop_dmgr, :manage_node, :start_node, :stop_node
      default_action :start_node

      attribute :install_dir, :name_attribute => true, :kind_of => String
      attribute :profile_name, :name_attribute => true, :kind_of => String
      attribute :profile_type, :name_attribute => true, :kind_of => String
      attribute :node_name, :name_attribute => true, :kind_of => String
      attribute :cell_name, :name_attribute => true, :kind_of => String
      attribute :host_name, :name_attribute => true, :kind_of => String
      attribute :enable_admin_security, :name_attribute => true, :kind_of => String
      attribute :admin_username, :name_attribute => true, :kind_of => String
      attribute :admin_password, :name_attribute => true, :kind_of => String
      attribute :starting_port, :name_attribute => true, :kind_of => String
      attribute :dmgr_host, :name_attribute => true, :kind_of => String
      attribute :dmgr_port, :name_attribute => true, :kind_of => String

    end
  end
end