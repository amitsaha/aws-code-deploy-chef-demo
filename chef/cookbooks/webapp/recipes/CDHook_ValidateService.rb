#
# Cookbook:: webapp
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

# Check if the new container is up/running/healthy

`curl -I http://localhost`
if $?.success?
  puts 'Service backup'  
else
  raise 'Service not up yet'
end
