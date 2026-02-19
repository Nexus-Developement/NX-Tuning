local Vehicles = {}

MySQL.ready(function()
    MySQL.Async.fetchAll('SELECT * FROM vehicles', {}, function(result)
        for i=1, #result, 1 do
            table.insert(Vehicles, {
                model = result[i].model,
                price = result[i].price
            })
        end
    end)
end)

ESX.RegisterServerCallback('nx_tuning:isAdmin', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin' then
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('nx_tuning:getVehiclesPrices', function(source, cb)
    cb(Vehicles)
end)

RegisterNetEvent('nx_tuning:startModing')
AddEventHandler('nx_tuning:startModing', function(props, netId)
end)

RegisterNetEvent('nx_tuning:stopModing')
AddEventHandler('nx_tuning:stopModing', function(plate)
end)

RegisterNetEvent('nx_tuning:buyMod')
AddEventHandler('nx_tuning:buyMod', function(price, isJob)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    price = tonumber(price)

    local playerGroup = xPlayer.getGroup()
    local isAdmin = (playerGroup == 'admin' or playerGroup == 'superadmin')

    if isAdmin then
        price = 0
    end

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        TriggerClientEvent('nx_tuning:installMod', _source)
        if price > 0 then
            TriggerClientEvent('esx:showNotification', _source, 'Du hast ~g~$' .. price .. '~s~ bezahlt.')
        else
            TriggerClientEvent('esx:showNotification', _source, '~b~Admin-Tuning:~s~ Kostenlos installiert.')
        end
    elseif xPlayer.getAccount('bank').money >= price then
        xPlayer.removeAccountMoney('bank', price)
        TriggerClientEvent('nx_tuning:installMod', _source)
        TriggerClientEvent('esx:showNotification', _source, 'Du hast ~g~$' .. price .. '~s~ via Bank bezahlt.')
    else
        TriggerClientEvent('nx_tuning:cancelInstallMod', _source)
        TriggerClientEvent('esx:showNotification', _source, '~r~Du hast nicht genug Geld!')
    end
end)

RegisterNetEvent('nx_tuning:refreshOwnedVehicle')
AddEventHandler('nx_tuning:refreshOwnedVehicle', function(vehicleProps, netId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    MySQL.Async.fetchAll('SELECT vehicle FROM owned_vehicles WHERE plate = @plate', {
        ['@plate'] = vehicleProps.plate
    }, function(result)
        if result[1] then
            MySQL.Async.execute('UPDATE owned_vehicles SET vehicle = @vehicle WHERE plate = @plate', {
                ['@vehicle'] = json.encode(vehicleProps),
                ['@plate']   = vehicleProps.plate
            })
        else
            TriggerClientEvent('esx:showNotification', _source, '~r~Das ist ein TestAuto')
        end
    end)
end)