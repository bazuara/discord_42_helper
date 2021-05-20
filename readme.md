# Hello sir, I'm Jarvis-42

Im a discrod bot, coded in ruby. I run some usefull commands against 42 API to make your life easier. I also run some not so usefull commands, just for fun.

## Installation

1. Clone this repo inside a docker machine.
2. Run `docker build -t jarvis-42 .`
3. Copy credentials.yml to secret.credentials.yml and fill your api and bot credentials.
4. Run `docker-compose up -d`
5. Enjoy and report any bug you find.

Note: You will need a 42 API id and secret, and a registered discord bot. All commands are preceeded by `!42`, but you can change the prefix inside your secret.credentials.yml file.

## Commands
### Ping!

Sends back a 'Pong' and edits it with the time it took.

### !42 help

Returns a help menu, listing all available commands.

### !42 info *USERNAME*

Returns *USERNAME* info as the following image indicates:

![User_info](resources/info_sample.png)

### !42 megatron *MONTH YEAR*

Returns name and profile of a specific *MONTH YEAR* megatron winner.

If *MONTH YEAR* is empty, return a list of the latest megatron winners.

### !42 rr
Roussian Roulette mini game. Starts with an empty barrel, loads a bullet, fires until bang.
Just tipe `!42rr` until someone loses.
Ideal minigame to figure who pays the coffe during your next break.

### !42 repeat
Just a parrot-like function, it quotes back your message, probably will be deleted in a near future.

 
