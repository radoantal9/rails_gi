rails_env = new_resource.environment["RAILS_ENV"]
Chef::Log.info("Running deploy/before_restart.rb...")

deploy_url  = node["webhook"]["deploy_url"]
email_list  = node["webhook"]["email_addresses"]
layer       = node[:opsworks][:layers]['rails-app'][:name]

Chef::Log.info("Got server value from JSON:#{deploy_url}")

revision = `git --git-dir=/srv/www/getinclusive/current/.git --work-tree=/srv/www/getinclusive/current rev-parse --short HEAD`
revision = revision.strip

host = 'host:[' + `hostname`.strip + ']'

Chef::Log.info("Revision just deployed:#{revision}")

node_layers = node[:opsworks][:instance][:layers]
Chef::Log.info("Layers: #{node_layers}")

if node_layers.include?("rails-app")
  Chef::Log.info("Inside Rails-App Layer")
end

# Append /? to URL end if necessary
if !deploy_url.include?"/?"
  deploy_url << "/?"
end

url_str = "#{deploy_url}&revision=#{revision}&env=#{rails_env}&email_list=#{email_list}"
Chef::Log.info("URL String: #{url_str}")

bash 'Sending deploy email and calling the webhook' do
  code <<-EOH
  curl -i "#{url_str}"
  echo "Subject: Deploy Complete Layer: #{rails_env}:#{host} #{revision} -  #{layer}] Deploy Complete - " |  sendmail #{email_list}
  EOH
end