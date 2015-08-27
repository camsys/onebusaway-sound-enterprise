name             "ec2_bootstrap"
maintainer       "Sheldon A. Brown"
maintainer_email "sheldonb@gmail.com"
license          "Apache 2.0"
description      "Configuration for bootstrapping chef-solo on AWS EC2"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

%w{ git }.each do |cb|
  depends cb
end

%w{ ubuntu debian }.each do |os|
  supports os
end

recipe "ec2_boostrap::default", "Configuration for bootstrapping chef-solo on AWS EC2"

