device = node[:base_was][:device_id] + node[:base_was][:partition_number]

directory "#{node[:base_was][:ibm_home]}"

package 'parted' do
  action :upgrade
end

bash "fdisk_#{device}" do
	user 'root'
	cwd '/tmp'
  not_if "/sbin/fdisk -l #{node[:base_was][:device_id]} | grep #{device}"
	## Setup the partition
	code <<-EOF
/sbin/fdisk /dev/xvde <<EOC || true
n
p
#{node[:base_was][:partition_number]}

#{node[:base_was][:partition_size]}
w
EOC
EOF
end

execute "partx_#{node[:base_was][:device_id]}" do
  command "partx -a #{node[:base_was][:device_id]}"
  not_if "/sbin/fdisk -l #{node[:base_was][:device_id]} | grep #{device}"
end

execute "partprobe_#{device}" do
  command "partprobe #{device}"
  not_if "/sbin/fdisk -l #{node[:base_was][:device_id]} | grep #{device}"
end

execute 'mkfs' do
  command "mkfs -t #{node[:base_was][:fs_type]} #{device}"
  # only if it's not mounted already
  not_if "grep -qs #{node[:base_was][:ibm_home]} /proc/mounts"
end

mount "#{node[:base_was][:ibm_home]}" do
  device "#{device}"
  action [:enable, :mount]
end
