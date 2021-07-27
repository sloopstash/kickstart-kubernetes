system_user = node['system']['user']
system_group = node['system']['group']
version = node['kubernetes']['version']
hostname = node['hostname']

repo_conf_path = node['kubernetes']['repo']['conf_path']

# Add Kubernetes repository.
template repo_conf_path do
  source 'yum.repo.erb'
  owner 'root'
  group 'root'
  mode 0600
  backup false
  action 'create'
end

if hostname.include?('-mtr-')
  user_home_dir = "/home/#{system_user}"
  client_conf_dir = "#{user_home_dir}/.kube"

  # Install Kubernetes.
  execute 'Install Kubernetes' do
    command "yum install -y kubelet-#{version} kubeadm-#{version} kubectl-#{version}"
    user 'root'
    group 'root'
    returns [0]
    action 'run'
  end

  # Create Kubernetes client configuration directory.
  directory client_conf_dir do
    owner system_user
    group system_group
    recursive true
    mode 0700
    action 'create'
    not_if do
      File.exists?client_conf_dir
    end
  end
else
  # Install Kubernetes.
  execute 'Install Kubernetes' do
    command "yum install -y kubelet-#{version} kubeadm-#{version}"
    user 'root'
    group 'root'
    returns [0]
    action 'run'
  end
end

# Include recipes.
include_recipe 'kubernetes::configure'
include_recipe 'kubernetes::start'
