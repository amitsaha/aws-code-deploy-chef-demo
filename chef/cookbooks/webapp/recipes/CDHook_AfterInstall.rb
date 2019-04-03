#
# Cookbook:: webapp
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.


image = "amitsaha/webapp-demo"
docker_image image do
    tag "golang"
    action :pull
    notifies :redeploy, 'docker_container[service]'
end


docker_container 'service' do
    repo image
    tag "golang"
    port '80:8080'
    action 'run_if_missing'
    restart_policy 'always'
end
