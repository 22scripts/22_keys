Bridge = {}

if Config.Framework == 'esx' then
    if Config.ESXMode == 'old' then
        ESX = nil
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    else
        ESX = exports['es_extended']:getSharedObject()
    end
else
    QBCore = exports['qb-core']:GetCoreObject()
end

function Bridge.Notify(message, notifyType)
    if Config.Framework == 'esx' then
        ESX.ShowNotification(message)
    elseif Config.Framework == 'qbox' then
        exports.ox_lib:notify({ description = message, type = notifyType or 'inform' })
    else
        QBCore.Functions.Notify(message, notifyType or 'primary')
    end
end

function Bridge.TriggerCallback(name, cb, ...)
    if Config.Framework == 'esx' then
        ESX.TriggerServerCallback(name, cb, ...)
    else
        QBCore.Functions.TriggerCallback(name, cb, ...)
    end
end

-- Retourne (vehicle, distance) ou (nil, nil)
function Bridge.GetClosestVehicle(coords, maxDist)
    if Config.Framework == 'esx' then
        return ESX.Game.GetClosestVehicle(coords)
    else
        local vehicles    = GetGamePool('CVehicle')
        local closest     = nil
        local closestDist = maxDist or 3.0
        for _, v in ipairs(vehicles) do
            local d = #(coords - GetEntityCoords(v))
            if d < closestDist then
                closest     = v
                closestDist = d
            end
        end
        return closest, closestDist
    end
end
