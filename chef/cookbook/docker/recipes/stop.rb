# Stop Kubernetes Docker CRI.
# execute 'Stop Kubernetes Docker CRI' do
#   command 'systemctl stop cri-docker.service'
#   user 'root'
#   group 'root'
#   returns [0]
#   action 'run'
# end

# Stop Docker.
execute 'Stop Docker' do
  command 'systemctl stop docker.service'
  user 'root'
  group 'root'
  returns [0]
  action 'run'
end
