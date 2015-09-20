# See https://docs.getchef.com/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "nick"
client_key               "#{current_dir}/nick.pem"
validation_client_name   "ops-validator"
validation_key           "#{current_dir}/ops-validator.pem"
chef_server_url          "https://chefserver1/organizations/ops"
cookbook_path            ["#{current_dir}/../cookbooks"]
