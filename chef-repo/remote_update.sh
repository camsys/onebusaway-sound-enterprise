#!/bin/bash 
ssh -i ~/.ec2/obawmata_dev.pem ubuntu@$1 -n "\
cd wmata-devops && \
git pull && \
cd .. && \
sudo chef-solo -l debug -L /tmp/chef.log -c wmata-devops/chef-repo/solo.rb -E dev -j wmata-devops/chef-repo/$2.json"