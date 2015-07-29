require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class Iim < Chef::Provider::LWRPBase
      provides :iim if defined?(provides)

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :install_iim do
        download_cache_dir = Chef::Config[:file_cache_path] + '/iim'

        # create download cache directory
        directory download_cache_dir

        zip_file = "#{download_cache_dir}/" + ::File.basename(::URI.parse(new_resource.iim_uri).path)

        # download source package
        remote_file zip_file do
          source new_resource.iim_uri
          action :create
          not_if do ::File.directory?(new_resource.iim_install_dir) end
        end

        # upzip source package into cache
        execute "unzip_iis_pkg_to_cache" do
          command "/usr/bin/unzip -o #{zip_file} -d #{download_cache_dir}"
          cwd download_cache_dir
          only_if do ::File.exists?("#{zip_file}") end
        end

        # create iim installation directories
        directory new_resource.iim_install_dir do
          recursive true
        end
        
        directory new_resource.iim_data_dir do
          recursive true
        end

        # install IBM Installation Manager (iim)
        execute "install_iis" do
          command "#{download_cache_dir}/installc  -acceptLicense -accessRights admin -installationDirectory #{new_resource.iim_install_dir} -dataLocation #{new_resource.iim_data_dir} -silent"
          cwd download_cache_dir
          not_if do ::File.exists?(new_resource.iim_install_dir + "/eclipse/tools/imcl") end
        end
      end

      action :install_product do
        download_cache_dir = Chef::Config[:file_cache_path] + '/ibm_product'

        # create download cache directory
        directory download_cache_dir

        new_resource.product_uris.each do |uri|
          zip_file = "#{download_cache_dir}/" + ::File.basename(::URI.parse(uri).path)

          # download source package
          remote_file zip_file do
            source uri
            action :create
            not_if do ::File.directory?(new_resource.product_install_dir) end
          end

          # upzip source package into cache
          execute "unzip_was_pkg_to_cache" do
            command "/usr/bin/unzip -o #{zip_file} -d #{download_cache_dir}"
            cwd download_cache_dir
            only_if do ::File.exists?("#{zip_file}") end
          end
        end

        # create product installation directory
        directory new_resource.product_install_dir do
          recursive true
        end

        execute "install_product_#{new_resource.product_id}" do
          command "#{new_resource.iim_install_dir}/eclipse/tools/imcl install #{new_resource.product_id} -repositories #{download_cache_dir}/repository.config -acceptLicense -installationDirectory #{new_resource.product_install_dir} --launcher.suppressErrors -nosplash -showProgress -silent"
          cwd "#{new_resource.iim_install_dir}/eclipse/tools"
          only_if do ::File.exists?(new_resource.iim_install_dir + "/eclipse/tools/imcl") end
        end
      end

    end
  end
end