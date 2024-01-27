fx_version 'cerulean'
game 'gta5'

description 'jbb-vehtheft'
version '1.0.0'


shared_scripts {
    'config.lua'
}

server_script {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    'client/main.lua'
}

dependencies {
    'qb-core',
    'qb-inventory',
    'qb-vehiclekeys',
    'PolyZone',
    'oxmysql'
}

lua54 'yes'
use_fxv2_oal 'yes'
