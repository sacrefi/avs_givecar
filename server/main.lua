ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- give car with a random plate- 1: playerID 2: carModel (3: plate)
TriggerEvent('es:addGroupCommand', 'givecar', 'admin',
             function(source, args, user)
    if args[1] == nil or args[2] == nil then
        TriggerClientEvent('esx:showNotification', source,
                           '~r~/givecar [playerID] [carModel] <plate>')
    elseif args[3] ~= nil then
        local playerName = GetPlayerName(args[1])
        local plate = args[3]
        if #args > 3 then
            for i = 4, #args do plate = plate .. " " .. args[i] end
        end
        plate = string.upper(plate)
        TriggerClientEvent('esx_giveownedcar:spawnVehiclePlate', source,
                           args[1], args[2], plate, playerName, 'player')
    else
        local playerName = GetPlayerName(args[1])
        TriggerClientEvent('esx_giveownedcar:spawnVehicle', source, args[1],
                           args[2], playerName, 'player')
    end
end, function(source, args, user)
    TriggerClientEvent('chat:addMessage', source,
                       {args = {'^1SYSTEM', 'Insufficient Permissions.'}})
end, {
    help = 'Give a car to the target player',
    params = {
        {name = "id", help = 'The ID of player'},
        {name = "vehicle", help = 'Name of the car model'}, {
            name = "<plate>",
            help = 'Custom plate name, if none will randomly generate a new plate'
        }
    }
})

RegisterCommand('_givecar', function(source, args)
    if source == 0 then
        local sourceID = args[1]
        if args[1] == nil or args[2] == nil then
            print("SYNTAX ERROR: _givecar [playerID] [carModel] <plate>")
        elseif args[3] ~= nil then
            local playerName = GetPlayerName(sourceID)
            local plate = args[3]
            if #args > 3 then
                for i = 4, #args do
                    plate = plate .. " " .. args[i]
                end
            end
            plate = string.upper(plate)
            TriggerClientEvent('esx_giveownedcar:spawnVehiclePlate', sourceID,
                               args[1], args[2], plate, playerName, 'console')
        else
            local playerName = GetPlayerName(args[1])
            TriggerClientEvent('esx_giveownedcar:spawnVehicle', sourceID,
                               args[1], args[2], playerName, 'console')
        end
    end
end)

TriggerEvent('es:addGroupCommand', 'delcarplate', 'admin',
             function(source, args, user)
    if args[1] == nil then
        TriggerClientEvent('esx:showNotification', source,
                           '~r~/delcarplate [plate]')
    else
        local plate = args[1]
        if #args > 1 then
            for i = 2, #args do plate = plate .. " " .. args[i] end
        end
        plate = string.upper(plate)

        local result = MySQL.Sync.execute(
                           'DELETE FROM owned_vehicles WHERE plate = @plate',
                           {['@plate'] = plate})
        if result == 1 then
            TriggerClientEvent('esx:showNotification', source,
                               _U('del_car', plate))
        elseif result == 0 then
            TriggerClientEvent('esx:showNotification', source,
                               _U('del_car_error', plate))
        end
    end
end, function(source, args, user)
    TriggerClientEvent('chat:addMessage', source,
                       {args = {'^1SYSTEM', 'Insufficient Permissions.'}})
end, {
    help = 'Delete a owned car by plate',
    params = {{name = "plate", help = 'The car plate'}}
})

RegisterCommand('_delcarplate', function(source, args)
    if source == 0 then
        if args[1] == nil then
            print("SYNTAX ERROR: _delcarplate [plate]")
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
                print('Deleted car plate: ' .. plate)
            elseif result == 0 then
                print('Can\'t find car with plate is ' .. plate)
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
        'INSERT INTO owned_vehicles (owner, plate, vehicle, type) VALUES (@owner, @plate, @vehicle, @type)',
        {
            ['@owner'] = xPlayer.identifier,
            ['@plate'] = vehicleProps.plate,
            ['@vehicle'] = json.encode(vehicleProps),
            ['@type'] = 'car',
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
