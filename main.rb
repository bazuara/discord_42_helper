#!/usr/bin/env ruby

require 'yaml'
require 'discordrb'
require 'json'
require 'oauth2'

#bot config
bot_config = YAML.load_file("secret.credentials.yml")
bot_token  = bot_config["bot_discord"]["bot_token"]
bot_id     = bot_config["bot_discord"]["bot_id"]
bot_prefix = bot_config["bot_discord"]["bot_prefix"]

bot = Discordrb::Commands::CommandBot.new token: "#{bot_token}",
	client_id: "#{bot_id}" , prefix: "#{bot_prefix}"

# api config
config = YAML.load_file("secret.credentials.yml")
client_id = config["api"]["client_id"]
client_secret = config["api"]["client_secret"]

client = OAuth2::Client.new(client_id, client_secret, site: "https://api.intra.42.fr")

#info command
bot.command :info do |msg|
	user = msg.content.split[2]
	unless user == nil
		token = client.client_credentials.get_token
		answer = token.get("/v2/users/#{user}").parsed
		msg.respond "Aquí tienes la info de #{user}"
		msg.respond "Full name: " + answer['usual_full_name']
		msg.respond "E-mail: " + answer['email']
		msg.respond "Evaluation points: " + answer['correction_point'].to_s
		msg.respond "Piscine: " + answer['pool_month'].capitalize + ' ' + answer['pool_year']
		str_date = answer['cursus_users'].last['blackholed_at']
		date = DateTime.parse(str_date)
		time_to_blackhole = date - DateTime.now
		msg.respond "Blackhole in #{time_to_blackhole.to_i} days"
	else
		msg.respond "Necesito un usuario para hacer eso"
	end
end

#megatron command
bot.command :megatron do |msg|
	str = ""
	month = msg.content.split[2]
	year = msg.content.split[3]
	unless month == nil
		token = client.client_credentials.get_token
		answer = token.get("/v2/achievements/63/users?filter[pool_year]=#{year}\
			&filter[pool_month]=#{month}&filter[primary_campus_id]=22").parsed[0]
		msg.respond "Ganador del megatron de la piscina de #{month} #{year} " + answer['login']
		msg.respond "Link al perfil https://profile.intra.42.fr/users/" + answer['login']
	else
		msg.respond "No has introducido mes y año, mostrando los últimos ganadores"
		token = client.client_credentials.get_token
		answer = token.get("/v2/achievements/63/users?&filter[primary_campus_id]=22").parsed
		answer.each do |student|
			str += "#{student['login']} Link -> https://profile.intra.42.fr/users/#{student['login']}\n"
		end
		msg.respond str
	end
end


bot.command :repeat do |msg|
	msg.respond "#{msg.content}"
end

#exit command
at_exit {bot.stop}
bot.run
