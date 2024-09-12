fx_version 'cerulean'
game 'gta5'

name "rhd_garage_creator"
description "Garage creator for RHD Garage"
author "RHD Team"
version "1.0.0"

lua54 'yes'

shared_scripts {
	'@ox_lib/init.lua',
	'shared/*.lua'
}

client_scripts {
	'client/*.lua',
	'functions/*.lua'
}

server_scripts {
	'server/*.lua'
}

files {
	'data/garages.json'
}