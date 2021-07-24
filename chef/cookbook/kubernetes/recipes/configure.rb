system_user = node['system']['user']
system_group = node['system']['group']
hostname = node['hostname']
ip_address = node['ipaddress']
flannel_template_url = node['kubernetes']['flannel']['template_url']

conf_dir = node['kubernetes']['conf_dir']

if hostname.include?('-mtr-')
  client_conf_dir = node['kubernetes']['client']['conf_dir']
  admin_conf_path = "#{conf_dir}/admin.conf"
  client_conf_path = "#{client_conf_dir}/config/admin.conf"

  # Initialize Kubernetes cluster.
  execute 'Initialize Kubernetes cluster' do
    command "kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=#{ip_address}"
    user 'root'
    group 'root'
    returns [0]
    action 'run'
    not_if do
      File.exists?admin_conf_path
    end
  end

  # Configure Kubernetes client.
  execute 'Configure Kubernetes client' do
    command "cp -i #{admin_conf_path} #{client_conf_dir}/config"
    user system_user
    group system_group
    returns [0]
    action 'run'
    only_if do
      File.exists?admin_conf_path
    end
  end

  # Create Flannel network.
  execute 'Create Flannel network' do
    command "kubectl apply -f #{flannel_template_url}"
    user system_user
    group system_group
    returns [0]
    action 'run'
    only_if do
      File.exists?client_conf_path
    end
  end

  # Enable master Kubernetes node to run pods.
  execute 'Enable master Kubernetes node to run pods' do
    command 'kubectl taint nodes --all node-role.kubernetes.io/master-'
    user system_user
    group system_group
    returns [0,1]
    action 'run'
    only_if do
      File.exists?client_conf_path
    end
  end
else
  agent_conf_path = "#{conf_dir}/kubelet.conf"

  # Join worker Kubernetes node.
  execute 'Join worker Kubernetes node' do
    command "kubeadm join #{}:6443 --token #{} --discovery-token-ca-cert-hash #{}"
    user 'root'
    group 'root'
    returns [0]
    action 'run'
    not_if do
      File.exists?agent_conf_path
    end
  end
end