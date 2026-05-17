fx_version 'cerulean'
game 'gta5'
author '22scripts, xLaugh'
version '1.0.1'

lua54 'yes'

escrow_ignore {
    'config.lua',
    'lang.lua',
    'bridge/client.lua',
    'bridge/server.lua',
    'client/client.lua',
    'server/server.lua'
}

shared_scripts {
    'config.lua',
    'lang.lua'
}

client_scripts {
    'bridge/client.lua',
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/server.lua',
    'server/server.lua'
}
