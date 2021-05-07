#!/usr/bin/env ruby

require 'yaml'
require 'discordrb'
require 'json'
require 'oauth2'
require "pp"

#bot config
begin
	bot_config = YAML.load_file("secret.credentials.yml")
	bot_token  = bot_config["bot_discord"]["bot_token"]
	bot_id     = bot_config["bot_discord"]["bot_id"]
	bot_prefix = bot_config["bot_discord"]["bot_prefix"]
rescue
	puts "Wrong secret.credentials.yml file, are you sure it exist and is formated ok?"
	exit
end


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
#Receives username, returns full name, email, ev points piscine and blackhole days"
bot.command :info do |msg|
	user = msg.content.split[2]
	begin
		token = client.client_credentials.get_token
		answer = token.get("/v2/users/#{user}").parsed
		coalition = token.get("/v2/users/#{user}/coalitions").parsed[0]
		msg.channel.send_embed do |embed|
			embed.title = "#{user.capitalize}"
			embed.colour = coalition['color']
			embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: answer['image_url'])
			embed.add_field(name: "Nombre completo", value: answer['usual_full_name'])
			embed.add_field(name: "Coalition", value: coalition['name'])
			embed.add_field(name: "Email", value: answer['email'])
			embed.add_field(name: "Piscine", value: answer['pool_month'].capitalize + ' ' + answer['pool_year'])
			embed.add_field(name: "Evaluation points", value: answer['correction_point'].to_s, inline: true)
			str_date = answer['cursus_users'].last['blackholed_at']
			date = DateTime.parse(str_date)
			time_to_blackhole = date - DateTime.now
			embed.add_field(name: "Blackholed in", value: "#{time_to_blackhole.to_i} days", inline: true)
		end
	rescue
		msg.respond "Something went wrong"
	end
end

#MEGATRON
#Receives month (in english) and year, returns user with achievement. Receives nothing and returns list of last wining users
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
# Mini game. Starts with empty barrel, loads a bullet, fires until bang
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
	event.channel.send_embed() do |embed|
  	embed.title = "Hello sir, I'm Jarvis and I'm here to help you"
  	embed.url = "https://profile.intra.42.fr/users/bazuara"
	embed.description = "This Bot is brought to you by [bazuara](https://profile.intra.42.fr/users/bazuara) for anyone who dares to use it. This are my actual commands:"

	embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "https://raw.githubusercontent.com/bazuara/ruby-tool-for-42/master/resources/JARVIS.png")
	embed.footer = Discordrb::Webhooks::EmbedFooter.new(icon_url: "https://cdn.discordapp.com/embed/avatars/0.png")

	embed.add_field(name: "Ping!", value: "Returns a timed \"pong\" back")
	embed.add_field(name: "help", value: "Returns this menu")
	embed.add_field(name: "!42 info USERNAME", value: "Receives username, returns full name, email, ev points piscine and blackhole days")
	embed.add_field(name: "!42 megatron MONTH YEAR", value: "Receives month (in english) and year, returns user with achievement. Or receives nothing and returns list of last wining users")
	embed.add_field(name: "!42 rr", value: "Roussian Roulette mini game. Starts with empty barrel, loads a bullet, fires until bang")
	end
end

#exit command
at_exit {bot.stop}
bot.run
