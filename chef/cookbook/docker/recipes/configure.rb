conf_dir = node['docker']['conf_dir']

server_conf_path = "#{conf_dir}/daemon.json"

# Configure Docker.
template server_conf_path do
  source 'server.json.erb'
  owner 'root'
  group 'root'
  mode 0600
  backup false
  action 'create'
end

# Enable Docker service at boot.
execute 'Enable Docker service at boot' do
  command 'systemctl enable docker.service'
  user 'root'
  group 'root'
  returns [0]
  action 'run'
end

# Enable Kubernetes Docker CRI service at boot.
# execute 'Enable Kubernetes Docker CRI service at boot' do
#   command 'systemctl enable cri-docker.service'
#   user 'root'
#   group 'root'
#   returns [0]
#   action 'run'
# end
