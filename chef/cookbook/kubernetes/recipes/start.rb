# Start Kubernetes agent.
execute 'Start Kubernetes agent' do
  command 'systemctl start kubelet.service'
  user 'root'
  group 'root'
  returns [0]
  action 'run'
end
