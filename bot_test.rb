#!/usr/bin/env ruby

require 'yaml'
require 'discordrb'

bot_config = YAML.load_file("secret.credentials.yml")
bot_token  = bot_config["bot_discord"]["bot_token"]
bot_id     = bot_config["bot_discord"]["bot_id"]
bot_secret = bot_config["bot_discord"]["bot_secret"]
bot_prefix = bot_config["bot_discord"]["bot_prefix"]

bot = Discordrb::Commands::CommandBot.new token: "#{bot_token}", client_id: "#{bot_id}" , prefix: "#{bot_prefix}"

bot.command :ping do |msg|
	msg.respond "pero tu eres tonto? ya está bien con tanto ping!"
end

at_exit {bot.stop}
bot.run
