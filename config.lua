Config = {}

-- Framework : 'esx' | 'qb' | 'qbox'
Config.Framework = 'esx'
-- ESXMode : 'old' | 'new'  (ignoré si Framework != 'esx')
Config.ESXMode   = 'new'

Config.TerritoryVehicles = false   -- Activer les véhicules crew (22_territory)
Config.RentalVehicles    = false   -- Activer les véhicules de location (22_rental)
Config.LockKey           = 'U'
Config.LockKeyEnabled    = true
Config.ox_target         = false

-- Auto-configuré selon le Framework (modifiable manuellement si besoin)
if Config.Framework == 'esx' then
    Config.VehiclesTable       = 'owned_vehicles'
    Config.VehiclesOwnerColumn = 'OWNER'
else
    Config.VehiclesTable       = 'player_vehicles'
    Config.VehiclesOwnerColumn = 'citizenid'
end
