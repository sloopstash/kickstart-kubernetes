kernel_params = node['system']['kernel']

kernel_conf_path = '/etc/sysctl.d/90-custom.conf'

# Set required Linux kernel params.
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
  notifies 'run','execute[Apply kernel configuration]','immediately'
end

# Apply kernel configuration.
execute 'Apply kernel configuration' do
  command "sysctl -p #{kernel_conf_path}"
  user 'root'
  group 'root'
  returns [0,255]
  action 'nothing'
end
