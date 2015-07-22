bash 'iptables_for_was_console' do
  cwd node['base-was']['ibm_home']
  code <<-EOH
    /sbin/iptables -A INPUT -p tcp --dport 28001 -j ACCEPT
    /sbin/iptables -A INPUT -p tcp --dport 28000 -j ACCEPT
    /sbin/service iptables save
    EOH
end