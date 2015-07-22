require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class Iim < Chef::Resource::LWRPBase
      provides :iim

      self.resource_name = :iim
      actions :install_iim, :install_product
      default_action :install_iim

      attribute :iim_install_dir, :name_attribute => true, :kind_of => String
      attribute :iim_data_dir, :name_attribute => true, :kind_of => String
      attribute :iim_uri, :name_attribute => true, :kind_of => String
      attribute :product_uris, :name_attribute => true, :kind_of => Array
      attribute :product_id, :name_attribute => true, :kind_of => String
      attribute :product_install_dir, :name_attribute => true, :kind_of => String

    end
  end
end