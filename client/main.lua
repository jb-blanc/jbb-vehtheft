local QBCore = exports['qb-core']:GetCoreObject()
local dropZone = nil
local insideDropZone = false
local inProgress = false


local function CreateBlips(coords, blipNumber, blipColor, blipName)
    local Blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(Blip, blipNumber)
    SetBlipDisplay(Blip, 4)
    SetBlipScale(Blip, 0.60)
    SetBlipAsShortRange(Blip, true)
    SetBlipColour(Blip, blipColor)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(blipName)
    EndTextCommandSetBlipName(Blip)
end

local function CreateZones()
    if dropZone == nil then
        dropZone = PolyZone:Create(Config.Zones["jbb-veh-disguise"].coords,Config.Zones["jbb-veh-disguise"].options);
        CreateBlips(dropZone:getBoundingBoxCenter(), 811, 64 ,"Vehicle disguise")
        dropZone:onPlayerInOut(function(isPointInside, point)
            if not inProgress then
                ShowMenu(isPointInside)
            end
        end)
    end
end

function ShowMenu(isPointInside)
    local currentVehicle = GetVehiclePedIsUsing(PlayerPedId())
    if isPointInside then
        insideDropZone = true
        if not inProgress then
            CreateThread(function()
                while insideDropZone do
                    Wait(0)
                    if IsControlJustReleased(0, 38) then
                        if currentVehicle ~= 0 then
                            local netId = NetworkGetNetworkIdFromEntity(currentVehicle)
                            local currentPlate = QBCore.Functions.GetPlate(currentVehicle)
                            local currentMods = QBCore.Functions.GetVehicleProperties(currentVehicle)

                            
                            print("Now trigerring callback : "..tostring(netId))
                            QBCore.Functions.TriggerCallback("jbb:vehicles:server:askDisguise", function(accepted, reason)
                                if accepted then
                                    inProgress = true
                                    QBCore.Functions.Notify("Disguise started, you'll be notified when finished", "success", 5000)
                                    QBCore.Functions.Progressbar('disguising_vehicle', "Disguising vehicle", Config.Disguise.duration, false, false, {
                                        disableMovement = false,
                                        disableCarMovement = false,
                                        disableMouse = false,
                                        disableCombat = false,
                                    }, {}, {}, {})
                                else
                                    QBCore.Functions.Notify("You can't disguise this vehicle : "..tostring(reason), "error", 5000)
                                end
                            end, netId, currentPlate, currentMods)
                        else
                            print("Vehicle not found for ped")
                        end
                    end
                end
            end)
        end

        exports['qb-core']:DrawText("E - Start disguise ("..tostring(Config.Disguise.price).."$)", 'left')
    else
        insideDropZone = false
        exports['qb-core']:HideText()
    end
end


local function getNearbyVehicle()
    local vehicle, distance = QBCore.Functions.GetClosestVehicle()
    if distance > 8 then
        QBCore.Functions.Notify("Vehicle is too far", "error")
        return
    end
    return vehicle
end

local function canHackVehicle(veh)
    local hasKeys = exports['qb-vehiclekeys']:HasKeys(QBCore.Functions.GetPlate(veh))
    local hasItem = QBCore.Functions.HasItem('car_unlocker')
    return not hasKeys and hasItem
end

local function hackVehicle(veh)
    QBCore.Functions.Progressbar('hacking_vehicle', "Hacking vehicle", Config.Hacking.duration, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = false,
    }, {
        animDict = Config.Hacking.animation.anim_dict,
        anim = Config.Hacking.animation.anim_name,
    }, {
        model = Config.Hacking.animation.prop_model,
        bone = Config.Hacking.animation.attached_bone,
        coords = Config.Hacking.animation.prop_coord,
        rotation = Config.Hacking.animation.prop_rotaton,
    }, {}, function()
        QBCore.Functions.Notify("You've hacked the vehicle", "success")
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', QBCore.Functions.GetPlate(veh))
    end)
end

-- Events
RegisterNetEvent('QBCore:Client:UpdateObject', function()
    QBCore = exports['qb-core']:GetCoreObject()
end)

RegisterNetEvent('jbb:vehicles:client:hack', function()
    local veh = getNearbyVehicle()
    if veh then
        if canHackVehicle(veh) then
            hackVehicle(veh)
        end
    end
end)

RegisterNetEvent('jbb:vehicles:client:successDisguise', function(netId, newPlate)
    inProgress = false
    local veh = NetToVeh(netId)
    TriggerEvent("vehiclekeys:client:SetOwner", newPlate)
    SetVehicleEngineOn(veh, true, true)
    QBCore.Functions.Notify("All done, your new plate number is "..newPlate, "success", 5000)
end)


AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    CreateZones()
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    CreateZones()
end)

-- Threads

