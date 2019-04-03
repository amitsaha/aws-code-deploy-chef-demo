require 'aws-sdk'
module Route53Update

  def get_ip_records(client)
    resp = client.list_resource_record_sets({
      hosted_zone_id: "Z1NRW4OEE6EQFG",
      start_record_name: "webappdemo.echorand.me",
      start_record_type: "A",
      max_items: 1,
    })

    resp.resource_record_sets[0].resource_records    
  end

  def update_dns_record(client, dns_record)
    resp = client.change_resource_record_sets({
        hosted_zone_id: "Z1NRW4OEE6EQFG", # required
        change_batch: {
        comment: "Deployment updates",
        changes: [dns_record],
        },
    })
    change_status = resp["change_info"]["status"]
    while change_status != "INSYNC"
        resp = client.get_change({
        id: resp["change_info"]["id"]
        })
        change_status = resp["change_info"]["status"]
        sleep 5
    end
    puts resp
  end 

  def remove_ip()
    client = route53 = Aws::Route53::Client.new(
        region: 'ap-southeast-2'
    )

    resp = client.list_resource_record_sets({
      hosted_zone_id: "Z1NRW4OEE6EQFG",
      start_record_name: "webapp.echorand.me",
      start_record_type: "A",
      max_items: 1,
    })

    # Remove the current instance from the DNS pool
    # If the only record is 127.0.0.1 (initialization), we don't need
    # to do DNS updation
    ip_records = get_ip_records(client)
    if ip_records.length == 1 && ip_records[0].value == "127.0.0.1"
      puts '127.0.0.1 is the only DNS record. Skipping DNS updates.'
    else
        dns_record =  {
                action: "UPSERT",
                resource_record_set: {
                name: "webapp.echorand.me",
                type: "A",
                ttl: 60,
                resource_records: [],
                },
        }

        ip_records.each do |ip|
            if ip.value != ip_address
              dns_record[:resource_record_set][:resource_records].push({value: ip.value})
            end
    end

    puts "Updating DNS record with: #{dns_record}"
    update_dns_record(client, dns_record)
  end

  def add_ip()
    ip_address = `curl http://169.254.169.254/latest/meta-data/local-ipv4`.chomp

    client = route53 = Aws::Route53::Client.new(
        region: 'ap-southeast-2'
    )
    
    # Add the current instance to the DNS pool
    ip_records = get_ip_records(client)
    dns_record =  {
        action: "UPSERT",
        resource_record_set: {
        name: "webapp.echorand.me",
        type: "A",
        ttl: 60,
        resource_records: [{value: ip_address}],
        },
    }

    ip_records.each do |ip|
        if ip.value != "127.0.0.1"
        dns_record[:resource_record_set][:resource_records].push({value: ip.value})
        end
    end
    puts "Updating DNS record with: #{dns_record}"
    update_dns_record(client, dns_record)
  end
end