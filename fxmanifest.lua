fx_version 'adamant'
-- fx_version 'cerulean'
-- fx_version 'bodacious'

game 'gta5'

description '/givecar command for esx_giveownedcar, original script by MEENO, modified by Sacrefi'

server_scripts {
    '@mysql-async/lib/MySQL.lua', '@es_extended/locale.lua', 'server/main.lua',
    'config.lua', 'locales/tw.lua', 'locales/en.lua', 'locales/pt.lua'
}

client_scripts {
    '@es_extended/locale.lua', 'client/main.lua', 'config.lua',
    'locales/tw.lua', 'locales/en.lua', 'locales/pt.lua'
}

dependency {'es_extended', 'essentialmode', 'esx_advancedvehicleshop'}
