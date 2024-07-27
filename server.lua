local QBCore = exports['qb-core']:GetCoreObject()
local spawnedMoney = {}

-- Function to register money server-side
RegisterServerEvent('tropic-moneyspawn:registerMoney')
AddEventHandler('tropic-moneyspawn:registerMoney', function(entityID, coords)
    local src = source
    local moneyAmount = math.random(Config.MinMoney, Config.MaxMoney)
    
    table.insert(spawnedMoney, { entityID = entityID, amount = moneyAmount, coords = coords, player = src, time = os.time() })

    -- Notify the player about the money spawn
    TriggerClientEvent('tropic-randommoney:notifyMoneySpawned', src, { x = coords.x, y = coords.y, z = coords.z, entityID = entityID })

    -- Remove the money after the specified time
    SetTimeout(Config.RemoveTime * 1000, function()
        for i, money in ipairs(spawnedMoney) do
            if money.entityID == entityID then
                table.remove(spawnedMoney, i)
                TriggerClientEvent('tropic-randommoney:removeMoney', -1, entityID)
                TriggerClientEvent('QBCore:Notify', src, "The money blew away!", 'error', 5000)
                break
            end
        end
    end)
end)

RegisterServerEvent('tropic-moneyspawn:pickupMoney')
AddEventHandler('tropic-moneyspawn:pickupMoney', function(netID)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    local entity = NetworkGetEntityFromNetworkId(netID)

    for i, money in ipairs(spawnedMoney) do
        if money.entityID == netID then
            local distance = #(playerCoords - money.coords)
            if distance < 1.5 and DoesEntityExist(entity) then
                xPlayer.Functions.AddMoney('cash', money.amount, 'Found money on the ground')
                TriggerClientEvent('QBCore:Notify', src, "You picked up the money!", 'success', 5000)
                table.remove(spawnedMoney, i)
                TriggerClientEvent('tropic-randommoney:removeMoney', -1, netID)
                break
            else
                print('Money entity does not exist or is too far away')
            end
        else
            print('Entity ID does not match stored money')
        end
    end
end)
