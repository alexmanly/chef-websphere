mount_point = node['base-was']['ibm_home']
device = node['base-was']['device_id'] + node['base-was']['partition_number']

directory "#{mount_point}"

package 'parted' do
  action :upgrade
end

bash "fdisk_#{device}" do
	user 'root'
	cwd '/tmp'
  not_if "/sbin/fdisk -l #{node['base-was']['device_id']} | grep #{device}"
	## Setup the partition
	code <<-EOF
/sbin/fdisk /dev/xvde <<EOC || true
n
p
#{node['base-was']['partition_number']}

#{node['base-was']['partition_size']}
w
EOC
EOF
end

execute "partx_#{node['base-was']['device_id']}" do
  command "partx -a #{node['base-was']['device_id']}"
end

execute "partprobe_#{device}" do
  command "partprobe #{device}"
end

execute 'mkfs' do
  command "mkfs -t #{node['base-was']['fs_type']} #{device}"
  # only if it's not mounted already
  not_if "grep -qs #{mount_point} /proc/mounts"
end

mount "#{mount_point}" do
  device "#{device}"
  action [:enable, :mount]
end
