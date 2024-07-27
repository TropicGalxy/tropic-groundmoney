local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('tropic-moneyspawn:pickupMoney')
AddEventHandler('tropic-moneyspawn:pickupMoney', function(amount)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    xPlayer.Functions.AddMoney('cash', amount, 'Found money on ground')
end)
