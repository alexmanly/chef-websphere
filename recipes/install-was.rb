node['base-was']['packages'].each do |pkg|
  package pkg
end

iim 'install_iim' do
  iim_install_dir node['base-was']['iim']['install_dir']
  iim_data_dir node['base-was']['iim']['install_data_dir']
  iim_uri node['base-was']['iim']['install_file_uri']
  action :install_iim
  not_if do ::File.exists?(node['base-was']['iim']['install_dir'] + "/eclipse/tools/imcl") end
end

iim 'install_was' do
  iim_install_dir node['base-was']['iim']['install_dir']
  product_id node['base-was']['was']['product_id']
  product_uris node['base-was']['was']['install_file_uris']
  product_install_dir node['base-was']['was']['install_dir']
  action :install_product
  not_if do ::File.exists?(node['base-was']['was']['install_dir'] + "/bin/manageprofiles.sh") end
end