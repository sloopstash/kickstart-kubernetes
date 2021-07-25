# Install Docker.
execute 'Install Docker' do
  command 'amazon-linux-extras install -y docker'
  user 'root'
  group 'root'
  returns [0]
  action 'run'
end

# Include recipes.
include_recipe 'docker::configure'
include_recipe 'docker::start'
