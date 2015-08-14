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
        converge_by("Install IBM Installation Manager into directory #{new_resource.iim_install_dir}") do
          
          if new_resource.access_mode == 'admin' and new_resource.user != 'root' 
            raise "Installing im with admin access rights requires that node[:base_was][:user] is set to root"
          end

          if !(new_resource.access_mode == 'admin' || new_resource.access_mode == 'nonAdmin' || new_resource.access_mode == 'group')
            raise "Only the following values for node[:base_was][:iim][:access_mode] are allowed: admin nonAdmin group."
          end

          iim_cache_dir = "#{::File.join(Chef::Config[:file_cache_path], 'iim')}"
          iim_install_dir = new_resource.iim_install_dir
          iim_data_dir = new_resource.iim_data_dir

          updates = []

          # create download cache directory
          [iim_cache_dir, iim_install_dir, iim_data_dir].each do | dirname |
            dir = directory dirname do
              group new_resource.group
              owner new_resource.user
              mode '0755'
              recursive true
            end
            updates << [dir.updated?]
          end

          zip_file = "#{::File.join(iim_cache_dir, ::File.basename(::URI.parse(new_resource.iim_uri).path))}"

          # download source package
          rfile = remote_file zip_file do
            source new_resource.iim_uri
            user new_resource.user
            group new_resource.group
            not_if do ::File.exists?(zip_file) end
          end
          updates << [rfile.updated?]

          # upzip source package into cache
          e1 = execute "unzip_iis_pkg_to_cache" do
            command "#{::File.join('/usr', 'bin' ,'unzip')} -o #{zip_file} -d #{iim_cache_dir}"
            cwd iim_cache_dir
            user new_resource.user
            group new_resource.group
            only_if do ::File.exists?("#{zip_file}") end
          end
          updates << [e1.updated?]

          # install IBM Installation Manager (iim)
          e2 = execute "install_iis" do
            command "#{::File.join(iim_cache_dir, 'installc')} \
                    -acceptLicense \
                    -accessRights #{new_resource.access_mode} \
                    -installationDirectory #{new_resource.iim_install_dir} \
                    -dataLocation #{new_resource.iim_data_dir} -silent \
                    -log #{::File.join(iim_cache_dir, 'iis_install.log')}"
            cwd iim_cache_dir
            user new_resource.user
            group new_resource.group
            not_if do ::File.exists?(::File.join(iim_install_dir, 'eclipse', 'tools', 'imcl')) end
          end
          updates << [e2.updated?]

          new_resource.updated_by_last_action(updates.any?)
        end # converge_by
      end # action :install_iim

      action :install_product do
        converge_by("Install IBM product '#{new_resource.product_id}' into directory #{new_resource.product_install_dir}") do
          product_cache_dir = "#{::File.join(Chef::Config[:file_cache_path], 'ibm_product')}"

          updates = []

          # create download cache directory
          dir1_resource = directory product_cache_dir do
            group new_resource.group
            owner new_resource.user
            mode '0755'
            recursive true
          end
          updates << [dir1_resource.updated?]

          new_resource.product_uris.each do |uri|
            zip_file = "#{::File.join(product_cache_dir, ::File.basename(::URI.parse(uri).path))}"

            # download source package
            rfile_resource = remote_file zip_file do
              source uri
              user new_resource.user
              group new_resource.group
              not_if do ::File.directory?(new_resource.product_install_dir) end
            end
            updates << [rfile_resource.updated?]

            # upzip source package into cache
            exe1_resource = execute "unzip_was_pkg_to_cache" do
              command "#{::File.join('/usr', 'bin' ,'unzip')} -o #{zip_file} -d #{product_cache_dir}"
              cwd product_cache_dir
              user new_resource.user
              group new_resource.group
              only_if do ::File.exists?("#{zip_file}") end
            end
            updates << [exe1_resource.updated?]
          end # each loop

          # create product installation directory
          dir2_resource = directory new_resource.product_install_dir do
            group new_resource.group
            owner new_resource.user
            mode '0755'
            recursive true
          end
          updates << [dir2_resource.updated?]

          exe2_resource = execute "install_product_#{new_resource.product_id}" do
            command "#{::File.join(new_resource.iim_install_dir, 'eclipse', 'tools' ,'imcl')} \
                    install #{new_resource.product_id} \
                    -repositories #{product_cache_dir}/repository.config \
                    -acceptLicense \
                    -installationDirectory #{new_resource.product_install_dir} \
                    --launcher.suppressErrors \
                    -nosplash \
                    -showProgress \
                    -silent\
                    -log #{::File.join(product_cache_dir, '#{new_resource.product_id}_install.log')}"
            cwd "#{::File.join(new_resource.iim_install_dir, 'eclipse', 'tools')}"
            user new_resource.user
            group new_resource.group
            only_if do ::File.exists?(::File.join(new_resource.iim_install_dir, 'eclipse', 'tools', 'imcl')) end
          end
          updates << [exe2_resource.updated?]

          if new_resource.product_id.include? "websphere"
            f1_resource = file "#{::File.join('/etc', 'profile.d', 'websphere.sh')}" do
              action :create_if_missing
              mode "0755"
              group new_resource.group
              owner new_resource.user
              content <<-EOD
            # Increase the file descriptor limit to support WAS
            # See http://pic.dhe.ibm.com/infocenter/iisinfsv/v8r5/topic/com.ibm.swg.im.iis.found.admin.common.doc/topics/t_admappsvclstr_ulimits.html
            ulimit -n 20480
            EOD
            end
            updates << [f1_resource.updated?]

            f2_resource = file "#{::File.join('/etc', 'security', 'limits.d', 'websphere.conf')}" do
              action :create_if_missing
              mode "0755"
              group new_resource.group
              owner new_resource.user
              content <<-EOD
            # Increase the limits for the number of open files for the pam_limits module to support WAS
            # See http://pic.dhe.ibm.com/infocenter/iisinfsv/v8r5/topic/com.ibm.swg.im.iis.found.admin.common.doc/topics/t_admappsvclstr_ulimits.html
            * soft nofile 20480
            * hard nofile 20480
            EOD
            end
            updates << [f2_resource.updated?]
          end # if

          new_resource.updated_by_last_action(updates.any?)
        end # converge_by
      end # action :install_product
    end # class Iim
  end # class Provider
end # class Chef