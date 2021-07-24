name 'docker'
maintainer 'Tuto'
maintainer_email 'tuto@sloopstash.com'
license 'Apache License 2.0'
description 'Deploy and manage Docker service in the machine.'
long_description 'Deploy and manage Docker service in the machine.'
version '1.1.1'
chef_version '>= 12' if respond_to?(:chef_version)
depends 'system'
