#!/bin/bash
set -e

cd /deploy/chef
berks vendor public-cookbooks
cd ..

zip -FSr /tmp/chef.zip chef
aws s3 cp /tmp/chef.zip s3://aws-codedeploy-chef-demo