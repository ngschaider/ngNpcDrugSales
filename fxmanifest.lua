fx_version 'cerulean'

description "Sell drugs to any NPC walking around"
author "Niklas Gschaider <niklas.gschaider@gschaider-systems.at>"

games {
	'gta5'
}

client_scripts {
	"@es_extended/locale.lua",
	"locales/de.lua",
	"config.lua",
	"client.lua",
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	"locales/de.lua",
	"config.lua",
	"server.lua",
}
