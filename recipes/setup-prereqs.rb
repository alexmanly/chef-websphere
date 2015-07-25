template "/etc/sysconfig/network" do
  source "network.erb"
  owner "root"
  group "root"
  mode "0644"
end

execute "set_hostname" do
  command "hostname " + node[:base_was][:hostname]
  not_if "hostname | grep " + node[:base_was][:hostname]
end

node[:base_was]['hosts'].each do |host, ip|
  hostsfile_entry ip do
    hostname  host
    unique    true
    aliases   ["#{host}.local"]
    comment   'Append by Recipe base-was::setup-hostsfile'
    action    :create_if_missing
  end
end

partition 'create partition' do
  device_id node[:base_was][:device_id]
  partition_number node[:base_was][:partition_number]
  mount_dir node[:base_was][:ibm_home]
  partition_size node[:base_was][:partition_size]
  fs_type node[:base_was][:fs_type]
  action :partition_and_mount
end

# bash 'iptables_for_was_console' do
#   code <<-EOH
#     /sbin/iptables -A INPUT -p tcp --dport 28001 -j ACCEPT
#     /sbin/iptables -A INPUT -p tcp --dport 28000 -j ACCEPT
#     /sbin/service iptables save
#     EOH
# end

service 'iptables' do
  action :stop
end