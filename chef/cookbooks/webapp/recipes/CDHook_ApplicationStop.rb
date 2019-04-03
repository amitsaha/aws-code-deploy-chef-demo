# Stop service container
docker_container 'service' do
    labels [
        'application:service'
    ]
    action 'stop'
end

# Remove service container
docker_container 'service' do
  labels [
      'application:service'
  ]
  action 'delete'
end