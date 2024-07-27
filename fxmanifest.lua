fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Random Money Spawn Script'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'qb-core',
    -- 'qb-target',  -- uncomment if you are using qb-target
    'ox_target'   -- comment if you are using ox_target
}
