-- THESE LINES MUST BE ADDED TO QB-CORE/SERVER/COMMANDS.LUA TO MAKE THE COMMANDS AVAILABLE INGAME

QBCore.Commands.Add('permitentry', Lang:t("command.permitentry.help"), false, false, function(source, args)
    TriggerClientEvent('Chiller:Client:PermitEntry', source)
end, 'admin')

QBCore.Commands.Add('denyentry', Lang:t("command.denyentry.help"), false, false, function(source, args)
    TriggerClientEvent('Chiller:Client:DenyEntry', source)
end, 'admin')