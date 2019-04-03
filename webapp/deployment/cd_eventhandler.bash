#!/bin/bash
set -eu

# We need to do the below steps once per deployment and not every lifecycle stage
# Hence, we use the first lifecycle event, APPLICATION_STOP to do this.
if [ "$LIFECYCLE_EVENT" == "ApplicationStop" ]; then
    pushd /etc
    aws s3 cp s3://aws-codedeploy-chef-demo/chef.zip /etc/
    rm -rf chef
    unzip -o chef.zip
    pushd chef
    chef-solo -c ./solo.rb --override-runlist "recipe[webapp::base]"
    popd
    popd
fi

# For the first deployment to an EC2 instance, the ApplicationStop lifecycle
# hook is not executed, hence, we download the chef cookbooks if the /etc/chef
# directory does not exist and execute the base recipe
if [ ! -d "/etc/chef" ]; then
   aws s3 cp s3://aws-codedeploy-chef-demo/chef.zip /etc/
   pushd /etc
   unzip -o chef.zip
   pushd chef
   chef-solo -c ./solo.rb --override-runlist "recipe[webapp::base]"
   popd
   popd
fi


pushd /etc/chef
chef-solo -c ./solo.rb --override-runlist "recipe[webapp::CDHook_$LIFECYCLE_EVENT]"
popd
