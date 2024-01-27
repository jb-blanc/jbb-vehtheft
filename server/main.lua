local QBCore = exports['qb-core']:GetCoreObject()
QBCore.Functions.AddItems(Config.Items)

-- Functions

local function getVehicleFromVehList(hash)
    for _, v in pairs(QBCore.Shared.Vehicles) do
        if hash == v.hash then
            return v.model
        end
    end
end

local GeneratePlate = function()
    local plate = QBCore.Shared.RandomInt(1)..QBCore.Shared.RandomStr(2)..QBCore.Shared.RandomInt(3)..QBCore.Shared.RandomStr(2)
    local result = MySQL.Sync.fetchScalar('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if result then
        return GeneratePlate()
    else
        return plate:upper()
    end
end

local function StartDisguiseThread(src, netId, veh, plate, props)
    Citizen.CreateThread(function()
        local Player = QBCore.Functions.GetPlayer(src)
        local hash = props.model
        local vehname = getVehicleFromVehList(hash)

        if QBCore.Shared.Vehicles[vehname] ~= nil and next(QBCore.Shared.Vehicles[vehname]) ~= nil then
            Player.Functions.RemoveMoney('cash', Config.Disguise.price, 'paid-vehicle-disguise')
            
            Wait(Config.Disguise.duration)
            local newPlate = GeneratePlate()
            SetVehicleNumberPlateText(veh, newPlate)
            props.plate = newPlate
            
            local result = MySQL.query.await('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })
            if result[1] == nil then
                MySQL.insert.await('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
                    Player.PlayerData.license,
                    Player.PlayerData.citizenid,
                    vehname,
                    hash,
                    json.encode(props),
                    newPlate,
                    0
                })
                TriggerClientEvent('jbb:vehicles:client:successDisguise', src, netId, newPlate)
            else
                MySQL.update.await('UPDATE player_vehicles SET license = ?, citizenid = ?, plate = ? WHERE plate = ?', {Player.PlayerData.license, Player.PlayerData.citizenid, newPlate, plate})
                TriggerClientEvent('jbb:vehicles:client:successDisguise', src, netId, newPlate)
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "Error on vehicle search in DB", 'error', 3000)
        end
    end)
end

-- Callbacks

-- Events

RegisterNetEvent('QBCore:Server:UpdateObject', function()
	if source ~= '' then return false end
	QBCore = exports['qb-core']:GetCoreObject()
end)

QBCore.Functions.CreateCallback('jbb:vehicles:server:askDisguise', function(source, cb, netId, plate, props, price, time)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cashBalance = Player.PlayerData.money['cash']
    local owned = MySQL.query.await('SELECT plate FROM player_vehicles WHERE plate = ? AND citizenid = ?', { plate , Player.PlayerData.citizenid})
    
    if cashBalance < Config.Disguise.price then
        cb(false, "Not enough cash on you pal !")
    elseif owned[1] ~= nil then
        cb(false, "This vehicle is already yours !")
    else
        local veh = NetworkGetEntityFromNetworkId(tonumber(netId))
        if veh then
            StartDisguiseThread(src, tonumber(netId), veh, plate, props)
            cb(true, "I'm taking that money now")
        else
            cb(false, "I can't take that vehicle")
        end
    end
end)

-- Commands

QBCore.Functions.CreateUseableItem(Config.Items["car_unlocker"].name, function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    TriggerClientEvent('jbb:vehicles:client:hack', source)
end)

