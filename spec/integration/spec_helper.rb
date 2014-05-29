require_relative '../../lib/vmonkey'

unless File.exists? ENV['VMONKEY_YML']
  raise "
  For the integration tests to run, place the following in #{ENV['VMONKEY_YML']}
    host: host_name_or_ip_address
    user: user_name
    password: password
    insecure: true
    ssl: true
    datacenter: datacenter_name
    cluster: cluster_name
  "
end

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.formatter = :documentation
end

