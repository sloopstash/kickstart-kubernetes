# Stop Kubernetes agent.
execute 'Stop Kubernetes agent' do
  command 'systemctl stop kubelet.service'
  user 'root'
  group 'root'
  returns [0]
  action 'run'
end
