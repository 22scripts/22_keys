local function FlashLights(vehicle)
    SetVehicleLights(vehicle, 2) Wait(200) SetVehicleLights(vehicle, 0)
    Wait(200) SetVehicleLights(vehicle, 2) Wait(400) SetVehicleLights(vehicle, 0)
end

local function PlayKeyAnim(playerPed)
    RequestAnimDict('anim@mp_player_intmenu@key_fob@')
    while not HasAnimDictLoaded('anim@mp_player_intmenu@key_fob@') do Wait(100) end
    TaskPlayAnim(playerPed, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0, 8.0, -1, 48, 1, false, false, false)
end

local function LockVehicle(vehicle)
    local playerPed   = GetPlayerPed(-1)
    local isInVehicle = IsPedInAnyVehicle(playerPed, false)
    local locked      = GetVehicleDoorLockStatus(vehicle)
    local netId       = NetworkGetNetworkIdFromEntity(vehicle)

    if locked == 1 or locked == 0 then
        SetVehicleDoorsLocked(vehicle, 2)
        PlayVehicleDoorCloseSound(vehicle, 1)
        if not isInVehicle then PlayKeyAnim(playerPed) end
        Bridge.Notify(Lang.locked, 'success')
        FlashLights(vehicle)
        TriggerServerEvent('22keys:syncLock', netId, 2, true)
    elseif locked == 2 then
        SetVehicleDoorsLocked(vehicle, 1)
        PlayVehicleDoorOpenSound(vehicle, 0)
        if not isInVehicle then PlayKeyAnim(playerPed) end
        Bridge.Notify(Lang.unlocked, 'success')
        FlashLights(vehicle)
        TriggerServerEvent('22keys:syncLock', netId, 1, false)
    end
end

RegisterNetEvent('22keys:syncLockClient')
AddEventHandler('22keys:syncLockClient', function(netId, lockStatus, isLocking)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    SetVehicleDoorsLocked(vehicle, lockStatus)
    if isLocking then
        PlayVehicleDoorCloseSound(vehicle, 1)
    else
        PlayVehicleDoorOpenSound(vehicle, 0)
    end
    FlashLights(vehicle)
end)

RegisterNetEvent('22keys:syncDoor')
AddEventHandler('22keys:syncDoor', function(netId, doorId, isOpen)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    if isOpen then
        SetVehicleDoorOpen(vehicle, doorId, false, false)
    else
        SetVehicleDoorShut(vehicle, doorId, false)
    end
end)

local function OpenCloseVehicle()
    local playerPed    = GetPlayerPed(-1)
    local coords       = GetEntityCoords(playerPed, true)
    local vehicle, _   = Bridge.GetClosestVehicle(coords, 3.0)
    if vehicle then
        Bridge.TriggerCallback('22keys:GetKeyVehicle', function(hasKey)
            if hasKey then LockVehicle(vehicle) end
        end, GetVehicleNumberPlateText(vehicle))
    else
        Bridge.Notify(Lang.noVehicle, 'error')
    end
end

if Config.LockKeyEnabled ~= false then
    RegisterKeyMapping('lockcar', Lang.keymapLabel, 'keyboard', Config.LockKey or 'U')
    RegisterCommand('lockcar', function()
        OpenCloseVehicle()
    end)
end

if Config.ox_target and GetResourceState('ox_target') == 'started' then
    exports.ox_target:addGlobalVehicle({
        {
            name     = '22keys_toggle',
            icon     = 'fa-solid fa-key',
            label    = Lang.keymapLabel,
            onSelect = function()
                OpenCloseVehicle()
            end
        }
    })
end
