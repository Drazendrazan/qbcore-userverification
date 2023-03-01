Config = {}

Config.SpawnAreaVector = vector3(-1080.05, -2823.5, 27.7) -- Spawn vector (used for teleporting non-verified players back/fixing player location)
Config.FixedAreaRadius = 80 -- Radius around the spawn vector in which a non-verified player is allowed to move (otherwise he will be teleported back)
Config.EntryTpVector = vector4(-1041.73, -2745.14, 21.36, 327.18) -- Vector the player is teleported to after being verified
Config.DenyEntryBanDuration = 600 -- Ban duration in seconds if verification is unsuccessful/entry is denied

-- AUTHORIZED ROLES ARE MANAGED IN QB-CORE/SERVER/COMMANDS.LUA!