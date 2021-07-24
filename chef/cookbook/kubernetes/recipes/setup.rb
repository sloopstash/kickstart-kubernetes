system_user = node['system']['user']
system_group = node['system']['group']
version = node['kubernetes']['version']
hostname = node['hostname']

client_conf_dir = node['kubernetes']['client']['conf_dir']

repo_conf_path = node['kubernetes']['repo']['conf_path']

# Add Kubernetes repository to package manager source list.
template repo_conf_path do
  source 'yum.repo.erb'
  owner 'root'
  group 'root'
  mode 0600
  backup false
  action 'create'
end

# Install Kubernetes.
yum_package 'Install Kubernetes' do
  package_name [
    "kubelet-#{version}",
    "kubeadm-#{version}",
    "kubectl-#{version}"
  ]
  action 'install'
end

if hostname.include?('-mtr-')
  # Install Kubernetes.
  yum_package 'Install Kubernetes' do
    package_name [
      "kubelet-#{version}",
      "kubeadm-#{version}",
      "kubectl-#{version}"
    ]
    action 'install'
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
  yum_package 'Install Kubernetes' do
    package_name [
      "kubelet-#{version}",
      "kubeadm-#{version}"
    ]
    action 'install'
  end
end
