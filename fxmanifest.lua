--[[ FX Information ]] --
fx_version 'cerulean'
lua54 'yes'
game 'gta5'

version '1.2.5'


shared_scripts {
	'@ox_lib/init.lua',
	'**/shared/*.lua',
}

server_scripts {
	'version.lua',
	'**/server/*.lua',
}

client_scripts {
	'**/client/*.lua',
}

files {
	'**/config.lua',
	'**/imports/*.lua'
}

dependencies {
	'ox_lib',
	'ox_inventory',
}
