QBCore = exports['qb-core']:GetCoreObject()

-- Check user verification/entry state

local newPlayer = false

local statusChecked = false

local notificationShown = false

RegisterNetEvent('Chiller:Client:SetNewPlayer', function(newPlayerStatus)
    newPlayer = newPlayerStatus
    statusChecked = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local sourcePlayerData = QBCore.Functions.GetPlayerData()

    TriggerServerEvent('Chiller:Server:CheckNewState', sourcePlayerData)
end)

AddEventHandler('onResourceStart', function (resourceName)
    if(GetCurrentResourceName() == "qbcore-userverification") then
        statusChecked = false
        local sourcePlayerData = QBCore.Functions.GetPlayerData()

        TriggerServerEvent('Chiller:Server:CheckNewState', sourcePlayerData)
      return
    end
  end)

AddEventHandler('onClientResourceStart', function (resourceName)
    if(GetCurrentResourceName() == "qbcore-userverification") then
        statusChecked = false
        local sourcePlayerData = QBCore.Functions.GetPlayerData()

        TriggerServerEvent('Chiller:Server:CheckNewState', sourcePlayerData)
      return
    end
  end)

-- Permit/deny entry Client Events

RegisterNetEvent('Chiller:Client:PermitEntry')
AddEventHandler('Chiller:Client:PermitEntry', function(source)
    local coords = GetEntityCoords(PlayerPedId())

    local closestPlayer, distance = QBCore.Functions.GetClosestPlayer(coords)
    local closestPlayerServerId = GetPlayerServerId(closestPlayer)

    if closestPlayer ~= null and closestPlayer ~= -1 then
        TriggerServerEvent('Chiller:Server:PermitEntry', closestPlayer, closestPlayerServerId)
    else
        exports['okokNotify']:Alert("User verification", "No player nearby.", 5000, 'warning')
    end
end)

RegisterNetEvent('Chiller:Client:DenyEntry')
AddEventHandler('Chiller:Client:DenyEntry', function(source)
    local coords = GetEntityCoords(PlayerPedId())

    local closestPlayer, distance = QBCore.Functions.GetClosestPlayer(coords)
    local closestPlayerServerId = GetPlayerServerId(closestPlayer)

    if closestPlayer ~= null and closestPlayer ~= -1 then
        TriggerServerEvent('Chiller:Server:DenyEntry', closestPlayerServerId)
    else
        exports['okokNotify']:Alert("User verification", "No player nearby.", 5000, 'warning')
    end
end)


-- Thread to monitor coords from player and reset if necessary when allowed radius is left
CreateThread(function()
    while true do
        Wait(1)
        if newPlayer then
            local spawnVec = Config.SpawnAreaVector
            local playerVec = GetEntityCoords(PlayerPedId())
            -- Calculate distance (ignore Z coord)
            local dist = #(spawnVec.xy - playerVec.xy)
            
            if dist > Config.FixedAreaRadius then
                SetEntityCoords(PlayerPedId(), spawnVec.x, spawnVec.y, spawnVec.z, false, false, false, true)
        	
                if not notificationShown then
                    exports['okokNotify']:Alert("User verification", "You must first complete the verification process before you can enter this region.", 30000, 'warning')
                    notificationShown = true
                end
            end
        else
            if statusChecked then
                return
            end
        end
    end
end)