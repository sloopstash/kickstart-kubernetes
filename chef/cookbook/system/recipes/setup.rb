# Disable Postfix service.
execute 'Disable Postfix service' do
  command <<-EOH
    systemctl stop postfix.service
    systemctl disable postfix.service
  EOH
  user 'root'
  group 'root'
  returns [0]
  action 'run'
  only_if do
    File.exists?'/sbin/postfix'
  end
end

# Enable netfilter Linux kernel module.
execute 'Enable netfilter Linux kernel module' do
  command 'modprobe br_netfilter'
  user 'root'
  group 'root'
  returns [0]
  action 'run'
end

# Disable Linux swap memory.
execute 'Disable Linux swap memory' do
  command 'swapoff -a'
  user 'root'
  group 'root'
  returns [0]
  action 'run'
end

# Include recipes.
include_recipe 'system::configure'
include_recipe 'system::start'
