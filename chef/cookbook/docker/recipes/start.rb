# Start Docker.
execute 'Start Docker' do
  command 'systemctl start docker.service'
  user 'root'
  group 'root'
  returns [0]
  action 'run'
end
