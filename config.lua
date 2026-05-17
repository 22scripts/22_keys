Config = {}

-- Framework : 'esx' | 'qb' | 'qbox'
Config.Framework = 'qb'
-- ESXMode : 'old' | 'new'  (ignoré si Framework != 'esx')
Config.ESXMode   = 'new'

Config.TerritoryVehicles = true   -- Activer les véhicules crew (22_territory)
Config.RentalVehicles    = true   -- Activer les véhicules de location (22_rental)
Config.LockKey           = 'U'
Config.LockKeyEnabled    = true
Config.ox_target         = false

-- ESX   : 'owned_vehicles' / 'identifier'
-- QB/QBox: 'player_vehicles' / 'citizenid'
Config.VehiclesTable       = 'player_vehicles'
Config.VehiclesOwnerColumn = 'citizenid'
