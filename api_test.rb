#!/usr/bin/env ruby

require 'rest-client'
require 'json'
require 'yaml'
require 'oauth2'

config = YAML.load_file("secret.credentials.yml")
client_id = config["api"]["client_id"]
client_secret = config["api"]["client_secret"]

client = OAuth2::Client.new(client_id, client_secret, site: "https://api.intra.42.fr")

puts "Usuario para analizar"
user = gets.chomp
token = client.client_credentials.get_token
answer = token.get("/v2/users/#{user}").parsed
p "Full name: " + answer['usual_full_name']
p "E-mail: " + answer['email']
p "Evaluation points: " + answer['correction_point'].to_s
p "Piscine: "+ answer['pool_month'].capitalize + ' ' + answer['pool_year']
#print JSON.pretty_generate(answer) 
p answer['cursus_users'][3]['blackholed_at']
