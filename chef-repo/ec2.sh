#!/bin/bash 
ssh -i ~/.ec2/obawmata_dev.pem ubuntu@$1 -n "\
apt-get update && \
apt-get install -y ruby2.0 ruby2.0-dev build-essential wget git && \
gem update --no-rdoc --no-ri && \
gem install ohai chef --no-rdoc --no-ri && \
git clone https://github.com/camsys/wmata-devops.git &&\
chef-solo -c wmata-devops/chef-repo/solo.rb -E dev -j wmata-devops/chef-repo/transitime-web.json"