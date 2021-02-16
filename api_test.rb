require 'rest-client'
require 'json'
require 'yaml'

config = YAML.load_file("secret.credentials.yml")
client_id = config["api"]["client_id"]
client_secret = config["api"]["client_secret"]

puts "id #{client_id} secret #{client_secret}"
