ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- give car with a random plate- 1: playerID 2: carModel (3: plate)
RegisterCommand("givecar", function(source, args)
    if source == 0 or IsPlayerAceAllowed(source, "givecar") then
        local sourceID = args[1]
        if args[1] == nil or args[2] == nil then
            if source ~= 0 then
                TriggerClientEvent("chatMessage", source,
                                   "SYNTAX ERROR: givecar [playerID] [carModel] <plate>")
            else
                print("SYNTAX ERROR: givecar [playerID] [carModel] <plate>")
            end
        elseif args[3] ~= nil then
            local playerName = GetPlayerName(sourceID)
            if playerName ~= nil then
                local plate = args[3]
                if #args > 3 then
                    for i = 4, #args do
                        plate = plate .. " " .. args[i]
                    end
                end
                plate = string.upper(plate)
                TriggerClientEvent('esx_giveownedcar:spawnVehiclePlate',
                                   sourceID, args[1], args[2], plate,
                                   playerName, 'console')
            else
                if source ~= 0 then
                    TriggerClientEvent("chatMessage", source, "Player ID " ..
                                           args[1] .. " not available")
                else
                    print("Player ID " .. args[1] .. " not available")
                end
            end
        else
            local playerName = GetPlayerName(args[1])
            if playerName ~= nil then
                TriggerClientEvent('esx_giveownedcar:spawnVehicle', sourceID,
                                   args[1], args[2], playerName, 'console')
            else
                if source ~= 0 then
                    TriggerClientEvent("chatMessage", source, "Player ID " ..
                                           args[1] .. " not available")
                else
                    print("Player ID " .. args[1] .. " not available")
                end
            end
        end
    end
end)

RegisterCommand("delcarplate", function(source, args)
    if source == 0 or IsPlayerAceAllowed(source, "givecar") then
        if args[1] == nil then
            if source ~= 0 then
                TriggerClientEvent("chatMessage", source,
                                   "SYNTAX ERROR: _delcarplate [plate]")
            else
                print("SYNTAX ERROR: _delcarplate [plate]")
            end
        else
            local plate = args[1]
            if #args > 1 then
                for i = 2, #args do
                    plate = plate .. " " .. args[i]
                end
            end
            plate = string.upper(plate)

            local result = MySQL.Sync.execute(
                               'DELETE FROM owned_vehicles WHERE plate = @plate',
                               {['@plate'] = plate})
            if result == 1 then
                if source ~= 0 then
                    TriggerClientEvent("chatMessage", source,
                                       "Deleted car plate: " .. plate)
                else
                    print('Deleted car plate: ' .. plate)
                end
            elseif result == 0 then
                if source ~= 0 then
                    TriggerClientEvent("chatMessage", source,
                                       'Can\'t find car with plate is ' .. plate)
                else
                    print('Can\'t find car with plate is ' .. plate)
                end
            end
        end
    end
end)

-- functions--

RegisterServerEvent('esx_giveownedcar:setVehicle')
AddEventHandler('esx_giveownedcar:setVehicle',
                function(vehicleProps, playerID, model)
    local _source = playerID
    local xPlayer = ESX.GetPlayerFromId(_source)
    MySQL.Async.execute(
        'INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored) VALUES (@owner, @plate, @vehicle, @type, @stored)',
        {
            ['@owner'] = xPlayer.identifier,
            ['@plate'] = vehicleProps.plate,
            ['@vehicle'] = json.encode(vehicleProps),
            ['@type'] = 'car',
            ['@stored'] = 1
        }, function(rowsChanged)
            if Config.ReceiveMsg then
                TriggerClientEvent('esx:showNotification', _source, _U(
                                       'received_car',
                                       string.upper(vehicleProps.plate)))
            end
        end)
end)

RegisterServerEvent('esx_giveownedcar:printToConsole')
AddEventHandler('esx_giveownedcar:printToConsole', function(msg) print(msg) end)
