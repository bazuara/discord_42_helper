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

#classic ping
bot.message(with_text: 'Ping!') do |event|
  m = event.respond 'Pong!'
  m.edit "Pong! Time taken: #{Time.now - event.timestamp} seconds."
end

#INFO
info_desc = "info: Receives username, returns full name, email, ev points piscine and blackhole days"
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

#MEGATRON
mega_desc = "megatron: Receives month (in english) and year, returns user with achievement. Receives nothing and returns list of last wining users"
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

# Russian Roulette
rr_desc = "rr: Mini game. Starts with empty barrel, loads a bullet, fires until bang"
bullet = 6
barrel = 0
tries = 0
bot.command :rr do |msg|
	if tries == 0
		bullet = rand(6) + 1
		msg.respond "Loading new barrel \xE2\x99\xBB"
		tries = 1
	end
	if tries != 0
		barrel += 1
		if barrel == bullet	
			msg.respond "Bang! You are dead \xF0\x9F\x98\xB5"
			puts tries = 0
			puts barrel = 0
			#msg.respond "Debug: bullet: #{bullet.to_s} barrel #{barrel.to_s} tries #{tries}"
		else
			msg.respond "Click (#{tries}/6) \xF0\x9F\x98\xB0"
			puts tries += 1
			#msg.respond "Debug: bullet: #{bullet.to_s} barrel #{barrel.to_s} tries #{tries}"
		end
	end
end

# repeat command. Receives a string and repeats it
bot.command :repeat do |msg|
msg.respond "#{msg.content}"
end

#help function. List all avalible bot functions
bot.message(with_text: 'help') do |event|
	event.respond "All commands except Ping! and help must be preceeded with '!42 '"
	event.respond "Ping!: Returns a timed pong back\n"
	event.respond "help: Returns this menu\n"
	event.respond "#{info_desc} \n"
	event.respond "#{mega_desc} \n"
	event.respond "#{rr_desc} \n"
end

#exit command
at_exit {bot.stop}
bot.run
