system_user = node['system']['user']
system_group = node['system']['group']
repo_url = 'https://github.com/sloopstash/kickstart-hadoop.git'

deploy_dir = '/opt/kickstart-hadoop'

# Fetch Hadoop starter-kit Git repository.
git deploy_dir do
  repository repo_url
  revision 'master'
  user 'root'
  group 'root'
  enable_checkout false
  action 'sync'
end

# Change ownership of Hadoop starter-kit directory.
execute 'Change ownership of Hadoop starter-kit directory' do
  command "chown -R #{system_user}:#{system_group} #{deploy_dir}"
  user 'root'
  group 'root'
  returns [0]
  action 'run'
  only_if do
    File.exists?deploy_dir
  end
end

# Create Hadoop storage paths.
[
  '/mnt/kubernetes/hadoop/data/master/1',
  '/mnt/kubernetes/hadoop/data/slave/1',
  '/mnt/kubernetes/hadoop/data/slave/2',
  '/mnt/kubernetes/hadoop/data/slave/3'
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
