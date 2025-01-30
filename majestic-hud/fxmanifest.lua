fx_version 'cerulean'
game "gta5"

description 'SkeletonNetworks'
version '1.0.0'
lua54 'yes'

ui_page 'build/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

client_script 'client.lua'

files {
    'locales/*.json',
    'build/**',
}

dependency '/assetpacks'