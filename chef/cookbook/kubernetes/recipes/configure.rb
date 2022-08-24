system_user = node['system']['user']
system_group = node['system']['group']
hostname = node['hostname']

conf_dir = node['kubernetes']['conf_dir']

cri_conf_path = node['kubernetes']['cri']['conf_path']
cri_socket_path = node['kubernetes']['cri']['socket_path']

if hostname.include?('-mtr-1')
  ip_address = node['ipaddress']
  flannel_template_url = node['kubernetes']['flannel']['template_url']
  user_home_dir = "/home/#{system_user}"
  client_conf_dir = "#{user_home_dir}/.kube"
  admin_conf_path = "#{conf_dir}/admin.conf"
  client_conf_path = "#{client_conf_dir}/config"
  flannel_conf_path = node['kubernetes']['flannel']['conf_path']

  # Initialize Kubernetes cluster.
  execute 'Initialize Kubernetes cluster' do
    command "kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=#{ip_address} --cri-socket=#{cri_socket_path}"
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
    command <<-EOH
      cp -i #{admin_conf_path} #{client_conf_path}
      chown #{system_user}:#{system_group} #{client_conf_path}
    EOH
    user 'root'
    group 'root'
    returns [0]
    action 'run'
    only_if do
      File.exists?admin_conf_path
    end
  end

  # Create Flannel network.
  execute 'Create Flannel network' do
    command "kubectl apply -f #{flannel_template_url}"
    cwd user_home_dir
    user system_user
    group system_group
    environment({
      'KUBECONFIG'=>client_conf_path
    })
    returns [0]
    action 'run'
    only_if do
      File.exists?client_conf_path
    end
    not_if do
      File.exists?flannel_conf_path
    end
  end

  # Enable master Kubernetes node to run pods.
  execute 'Enable master Kubernetes node to run pods' do
    command 'kubectl taint nodes --all node-role.kubernetes.io/master-'
    cwd user_home_dir
    user system_user
    group system_group
    environment({
      'KUBECONFIG'=>client_conf_path
    })
    returns [0,1]
    action 'run'
    only_if do
      File.exists?client_conf_path
    end
  end
else
  master_ip_address = node['kubernetes']['master']['ip_address']
  token = node['kubernetes']['token']
  token_hash = node['kubernetes']['token_hash']
  agent_conf_path = "#{conf_dir}/kubelet.conf"

  # Join worker Kubernetes node.
  execute 'Join worker Kubernetes node' do
    command "kubeadm join #{master_ip_address}:6443 --token #{token} --discovery-token-ca-cert-hash #{token_hash} --cri-socket=#{cri_socket_path}"
    user 'root'
    group 'root'
    returns [0]
    action 'run'
    not_if do
      File.exists?agent_conf_path
    end
  end
end

# Configure Kubernetes CRI client.
template cri_conf_path do
  source 'cri/client.yml.erb'
  owner 'root'
  group 'root'
  variables(
    'socket_path'=>cri_socket_path
  )
  mode 0600
  backup false
  action 'create'
end
