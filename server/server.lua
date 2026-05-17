local function CheckJobVehicle(source, jobName, plate, cb)
    MySQL.Async.fetchAll('SELECT 1 FROM ' .. Config.VehiclesTable .. ' WHERE plate = @plate AND job = @job', {
        ['@plate'] = plate,
        ['@job']   = jobName
    }, function(res)
        if res[1] then
            cb(true)
        else
            cb(false)
            Bridge.NotifyPlayer(source, Lang.noKeys, 'error')
        end
    end)
end

local function CheckTerritoryAccess(source, identifier, jobName, plate, cb)
    if not Config.TerritoryVehicles then
        CheckJobVehicle(source, jobName, plate, cb)
        return
    end
    MySQL.Async.fetchAll(
        'SELECT cm.id_crew, cg.key_vehicle FROM crew_membres cm LEFT JOIN crew_grades cg ON cm.id_grade = cg.id_grade WHERE cm.identifier = @id',
        { ['@id'] = identifier },
        function(crew)
            if crew[1] and crew[1].id_crew and crew[1].key_vehicle == 1 then
                MySQL.Async.fetchAll('SELECT 1 FROM ' .. Config.VehiclesTable .. ' WHERE plate = @plate AND crew = @crew', {
                    ['@plate'] = plate,
                    ['@crew']  = crew[1].id_crew
                }, function(crewVeh)
                    if crewVeh[1] then cb(true) else CheckJobVehicle(source, jobName, plate, cb) end
                end)
            else
                CheckJobVehicle(source, jobName, plate, cb)
            end
        end
    )
end

local function CheckKeyPermission(source, plate, cb)
    local identifier = Bridge.GetIdentifier(source)
    local jobName    = Bridge.GetJob(source)
    if not identifier then cb(false) return end

    -- 1. Propriétaire du véhicule
    MySQL.Async.fetchAll('SELECT 1 FROM ' .. Config.VehiclesTable .. ' WHERE ' .. Config.VehiclesOwnerColumn .. ' = @id AND plate = @plate', {
        ['@id']    = identifier,
        ['@plate'] = plate
    }, function(owned)
        if owned[1] then cb(true) return end

        -- 2. Clé directe
        MySQL.Async.fetchAll('SELECT 1 FROM vehicle_key WHERE identifier = @id AND plate = @plate', {
            ['@id']    = identifier,
            ['@plate'] = plate
        }, function(keys)
            if keys[1] then cb(true) return end

            -- 3. Véhicule de location
            if Config.RentalVehicles then
                MySQL.Async.fetchAll('SELECT 1 FROM rented_vehicles WHERE identifier = @id AND plate = @plate', {
                    ['@id']    = identifier,
                    ['@plate'] = plate
                }, function(rented)
                    if rented[1] then cb(true) return end
                    CheckTerritoryAccess(source, identifier, jobName, plate, cb)
                end)
            else
                CheckTerritoryAccess(source, identifier, jobName, plate, cb)
            end
        end)
    end)
end

-- Donner une clé à un joueur cible
RegisterNetEvent('22keys:addKeyVehicle')
AddEventHandler('22keys:addKeyVehicle', function(target, plate)
    local identifier = Bridge.GetIdentifier(target)
    local fullName   = Bridge.GetFullName(target)
    if not identifier or not plate then return end
    MySQL.Async.execute('INSERT INTO vehicle_key (identifier, plate, label) VALUES (@id, @plate, @label)', {
        ['@id']    = identifier,
        ['@plate'] = plate,
        ['@label'] = fullName
    })
end)

Bridge.RegisterCallback('22keys:GetKeyVehicle', function(source, cb, plate)
    CheckKeyPermission(source, plate, cb)
end)

RegisterNetEvent('22keys:syncLock')
AddEventHandler('22keys:syncLock', function(netId, lockStatus, isLocking)
    local src     = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    CheckKeyPermission(src, GetVehicleNumberPlateText(vehicle), function(hasKey)
        if hasKey then
            TriggerClientEvent('22keys:syncLockClient', -1, netId, lockStatus, isLocking)
        end
    end)
end)

RegisterNetEvent('22keys:syncDoor')
AddEventHandler('22keys:syncDoor', function(netId, doorId, isOpen)
    local src     = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    CheckKeyPermission(src, GetVehicleNumberPlateText(vehicle), function(hasKey)
        if hasKey then
            TriggerClientEvent('22keys:syncDoor', -1, netId, doorId, isOpen)
        end
    end)
end)
