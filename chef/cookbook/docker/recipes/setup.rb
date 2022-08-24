kubernetes_cri_package_url = node['docker']['kubernetes']['cri']['package_url']

# Install Docker.
execute 'Install Docker' do
  command 'amazon-linux-extras install -y docker'
  user 'root'
  group 'root'
  returns [0]
  action 'run'
end

# Download Kubernetes Docker CRI.
remote_file "/tmp/cri-dockerd.rpm" do
  source kubernetes_cri_package_url
  mode 0644
  not_if do
    File.exists?"/tmp/cri-dockerd.rpm"
  end
end

# Install Kubernetes Docker CRI.
# yum_package 'Install Kubernetes Docker CRI' do
#   source "/tmp/cri-dockerd.rpm"
#   action :install
#   not_if do
#     File.exists?"/usr/bin/cri-dockerd"
#   end
# end

# Include recipes.
include_recipe 'docker::configure'
include_recipe 'docker::start'
