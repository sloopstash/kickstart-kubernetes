# Stop Docker.
execute 'Stop Docker' do
  command 'systemctl stop docker.service'
  user 'root'
  group 'root'
  returns [0]
  action 'run'
end
