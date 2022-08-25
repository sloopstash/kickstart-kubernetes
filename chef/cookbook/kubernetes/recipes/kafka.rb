system_user = node['system']['user']
system_group = node['system']['group']
repo_url = 'https://github.com/sloopstash/kickstart-kafka.git'

deploy_dir = '/opt/kickstart-kafka'

# Fetch Kafka starter-kit Git repository.
git deploy_dir do
  repository repo_url
  revision 'master'
  user 'root'
  group 'root'
  enable_checkout false
  action 'sync'
end

# Change ownership of Kafka starter-kit directory.
execute 'Change ownership of Kafka starter-kit directory' do
  command "chown -R #{system_user}:#{system_group} #{deploy_dir}"
  user 'root'
  group 'root'
  returns [0]
  action 'run'
  only_if do
    File.exists?deploy_dir
  end
end

# Create Kafka storage paths.
[
  '/mnt/kubernetes/kafka/data/controller/1',
  '/mnt/kubernetes/kafka/data/controller/2',
  '/mnt/kubernetes/kafka/data/controller/3',
  '/mnt/kubernetes/kafka/data/broker/1',
  '/mnt/kubernetes/kafka/data/broker/2',
  '/mnt/kubernetes/kafka/data/broker/3'
].each do |dir|
  directory dir do
    owner system_user
    group system_group
    recursive true
    mode 0777
    action 'create'
    not_if do
      File.exists?dir
    end
  end
end
