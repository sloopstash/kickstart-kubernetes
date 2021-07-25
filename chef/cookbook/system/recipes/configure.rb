system_user = node['system']['user']
system_group = node['system']['group']
kernel_params = node['system']['kernel']
security_limit_params = node['system']['security_limit']

kernel_conf_path = '/etc/sysctl.d/90-custom.conf'
security_limit_conf_path = '/etc/security/limits.d/10-custom.conf'

# Set custom Linux kernel params.
template kernel_conf_path do
  source 'kernel.conf.erb'
  owner 'root'
  group 'root'
  variables(
    'params'=>kernel_params
  )
  mode 0600
  backup false
  action 'create'
  notifies 'run','execute[Apply custom Linux kernel params]','immediately'
end

# Apply custom Linux kernel params.
execute 'Apply custom Linux kernel params' do
  command "sysctl -p #{kernel_conf_path}"
  user 'root'
  group 'root'
  returns [0,255]
  action 'nothing'
end

# Set custom Linux security limit params.
template security_limit_conf_path do
  source 'security-limit.conf.erb'
  owner 'root'
  group 'root'
  variables(
    'system_user'=>system_user,
    'params'=>security_limit_params
  )
  mode 0600
  backup false
  action 'create'
end
