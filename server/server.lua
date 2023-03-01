local QBCore = exports['qb-core']:GetCoreObject()

local permissions = {
    ['kill'] = 'god',
    ['ban'] = 'admin',
    ['noclip'] = 'admin',
    ['kickall'] = 'admin',
    ['kick'] = 'admin',
}

-- COMMAND PERMISSIONS ARE REGISTERED IN QB-CORE/SERVER/COMMANDS.LUA

-- Check verification state

RegisterServerEvent("Chiller:Server:CheckNewState")
AddEventHandler("Chiller:Server:CheckNewState", function(sourcePlayerData)
    local sourcePlayerServerId = source

    local sourceCitizenId = sourcePlayerData.citizenid

    local result = MySQL.query.await('SELECT new FROM players WHERE citizenid = ?', {sourceCitizenId})

    if result[1] ~= nil then
        if result[1].new == true then
            TriggerClientEvent('Chiller:Client:SetNewPlayer', sourcePlayerServerId, true)
            return
            -- Notify mod/support team?
        else
            TriggerClientEvent('Chiller:Client:SetNewPlayer', sourcePlayerServerId, false)
            return
        end
    else
        -- Notify mod/support team?
        TriggerClientEvent('Chiller:Client:SetNewPlayer', sourcePlayerServerId, true)
    end
end)

-- Permit/deny entry Server Events

RegisterServerEvent("Chiller:Server:PermitEntry")
AddEventHandler("Chiller:Server:PermitEntry", function(closestPlayer, closestPlayerServerId)
    local sourcePlayerServerId = source
    local qbPlayer = QBCore.Functions.GetPlayer(closestPlayerServerId)
    local closestPlayerCitizenId = qbPlayer.PlayerData.citizenid
    local tpVec = Config.EntryTpVector

    local result = MySQL.query.await('SELECT new FROM players WHERE citizenid = ?', {closestPlayerCitizenId})

    if result[1] ~= nil then
        if result[1].new == true then
            -- New player
            MySQL.update('UPDATE players SET new = ? WHERE citizenid = ?', { 0, closestPlayerCitizenId})
            TriggerClientEvent('okokNotify:Alert', closestPlayerServerId, 'Entry permitted', 'You were successfully verified. Have fun playing!', 5000, 'success')
            TriggerClientEvent('okokNotify:Alert', sourcePlayerServerId, 'Entry permitted', 'You successfully verified "' .. qbPlayer.PlayerData.name .. '".', 5000, 'success')
            
            TriggerClientEvent('Chiller:Client:SetNewPlayer', closestPlayerServerId, false)
            TriggerClientEvent('QBCore:Command:TeleportToCoords', closestPlayerServerId, tpVec.x, tpVec.y, tpVec.z, tpVec.w)
        elseif result[1].new == false then
            -- Player already verified
            TriggerClientEvent('okokNotify:Alert', sourcePlayerServerId, 'User verification', 'Player is already verified', 5000, 'warning')
        else
            -- Error
            TriggerClientEvent('okokNotify:Alert', sourcePlayerServerId, 'User verification', 'Invalid database values, please contact a developer, USERVERIFY:002', 5000, 'error')
        end
    else
            -- Error
        TriggerClientEvent('okokNotify:Alert', sourcePlayerServerId, 'User verification', 'Invalid database values, please contact a developer, USERVERIFY:001', 5000, 'error')
    end
end)

RegisterServerEvent("Chiller:Server:DenyEntry")
AddEventHandler("Chiller:Server:DenyEntry", function(closestPlayerServerId)
    local sourcePlayerServerId = source
    local qbPlayer = QBCore.Functions.GetPlayer(closestPlayerServerId)
    local closestPlayerCitizenId = qbPlayer.PlayerData.citizenid
    local time = Config.DenyEntryBanDuration
    local reason = 'Entry denied'

    local result = MySQL.query.await('SELECT new FROM players WHERE citizenid = ?', {closestPlayerCitizenId})

    if result[1] ~= nil then
        if result[1].new == false then
            TriggerClientEvent('okokNotify:Alert', sourcePlayerServerId, 'Entry denied', 'Player "' .. qbPlayer.PlayerData.name .. '" is already verified, you cannot use the permit entry command', 5000, 'error')
            return
        end
    end
    
    if QBCore.Functions.HasPermission(sourcePlayerServerId, permissions['ban']) or IsPlayerAceAllowed(sourcePlayerServerId, 'command') then
        time = tonumber(time)
        local banTime = tonumber(os.time() + time)
        if banTime > 2147483647 then
            banTime = 2147483647
        end
        local timeTable = os.date('*t', banTime)
        MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            GetPlayerName(closestPlayerServerId),
            QBCore.Functions.GetIdentifier(closestPlayerServerId, 'license'),
            QBCore.Functions.GetIdentifier(closestPlayerServerId, 'discord'),
            QBCore.Functions.GetIdentifier(closestPlayerServerId, 'ip'),
            reason,
            banTime,
            GetPlayerName(sourcePlayerServerId)
        })

        TriggerEvent('qb-log:server:CreateLog', 'bans', 'Player Banned', 'red', string.format('%s was banned by %s for %s', GetPlayerName(closestPlayerServerId), GetPlayerName(sourcePlayerServerId), reason), true)
        TriggerClientEvent('okokNotify:Alert', sourcePlayerServerId, 'Entry denied', 'You have banned "' .. qbPlayer.PlayerData.name .. '" for a duration of ' .. Config.DenyEntryBanDuration .. ' seconds', 5000, 'success')
        DropPlayer(closestPlayerServerId, "You were banned (Entry denied)\n\n Ban expiry date:\n" .. timeTable['day'] .. '/' .. timeTable['month'] .. '/' .. timeTable['year'] .. ' ' .. timeTable['hour'] .. ':' .. timeTable['min'])
    end
end)



-- no longer used (role is checked in qb-core/server/commands.lua)
local function isRolePermissioned (rolle)
    for index, value in ipairs(Config.PermissionedRoles) do
        if value == rolle then
            return true
        end
    end

    return false
end