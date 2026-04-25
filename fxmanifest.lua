fx_version 'cerulean'
game 'gta5'

author '你的伺服器'
description '車輛生成 + 改裝選單 (ox_lib)'
version '1.0.0'

dependencies {
    'ox_lib',
}

client_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'client.lua'
}

server_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'server.lua'
}
