# Start Docker.
execute 'Start Docker' do
  command 'systemctl start docker.service'
  user 'root'
  group 'root'
  returns [0]
  action 'run'
end

# Start Kubernetes Docker CRI.
# execute 'Start Kubernetes Docker CRI' do
#   command 'systemctl start cri-docker.service'
#   user 'root'
#   group 'root'
#   returns [0]
#   action 'run'
# end
