local QBCore = exports['qb-core']:GetCoreObject()
local spawnedMoney = {}

-- Function to spawn money
function spawnMoney()
    local playerPed = PlayerPedId()
    if IsPedOnFoot(playerPed) then
        local playerCoords = GetEntityCoords(playerPed)
        local moneyCoords = vector3(playerCoords.x + math.random(-5, 5), playerCoords.y + math.random(-5, 5), playerCoords.z)
        local moneyAmount = math.random(Config.MinMoney, Config.MaxMoney)

        TriggerEvent('QBCore:Notify', "You found money on the ground! Pick it up before it blows away", 'success', 5000)

        -- Creating the money object
        local moneyObject = CreateObject(GetHashKey('prop_cash_pile_01'), moneyCoords.x, moneyCoords.y, moneyCoords.z, true, true, true)
        PlaceObjectOnGroundProperly(moneyObject)

        table.insert(spawnedMoney, { object = moneyObject, amount = moneyAmount, coords = moneyCoords, time = GetGameTimer() })

        -- Remove the money after the specified time
        Citizen.SetTimeout(Config.RemoveTime * 1000, function()
            if DoesEntityExist(moneyObject) then
                DeleteObject(moneyObject)
                TriggerEvent('QBCore:Notify', "The money blew away!", 'error', 5000)
            end
        end)
    end
end

-- Function to check for money pickup
CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for i, money in ipairs(spawnedMoney) do
            local moneyCoords = money.coords
            local distance = #(playerCoords - moneyCoords)

            if distance < 1.5 then
                DrawText3Ds(moneyCoords.x, moneyCoords.y, moneyCoords.z + 0.5, '[E] Pick Up Money')

                if IsControlJustReleased(0, 38) then
                    -- Play pickup animation
                    TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
                    Wait(2000)
                    ClearPedTasks(playerPed)

                    -- Pickup the money
                    TriggerServerEvent('tropic-moneyspawn:pickupMoney', money.amount)
                    DeleteObject(money.object)
                    table.remove(spawnedMoney, i)
                    TriggerEvent('QBCore:Notify', string.format(Config.PickupNotification, money.amount), 'success', 5000)
                end
            end
        end
    end
end)

-- Function to draw 3D text
function DrawText3Ds(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0150, 0.015 + factor, 0.03, 0, 0, 0, 75)
end

-- Money spawn interval
CreateThread(function()
    while true do
        Wait(Config.SpawnInterval * 1000)
        spawnMoney()
    end
end)
