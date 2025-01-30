local QBCore = exports['qb-core']:GetCoreObject()
local playerData = QBCore.Functions.GetPlayerData()
local speedMultiplier = Config.useMPH and 2.23694 or 3.6
local showingHUD = true
local health = 0
local armor = 0
local isTalking = false
local talkingOnRadio = false
local onRadio = false
local onPhone = false
local voiceRange = 2
local stats = {}
local vehicleStats = {}
local lastFuelUpdate = 0
local lastFuelCheck = nil
local lastCrossroadUpdate = 0
local lastCrossroadCheck = nil

local function updateStats()
    SendNUIMessage({
        action = 'updateStats', 
        data = {
            showing = IsPauseMenuActive() == false and showingHUD or false,
            health = health,
            armor = armor,
            isTalking = isTalking,
            talkingOnRadio = talkingOnRadio,
            onRadio = onRadio,
            onPhone = onPhone,
            voiceRange = voiceRange,
            stats = stats
        }
    })
end

local function updateVehicleStats()
    if not cache.vehicle then return end
    local veh = cache.vehicle
    SendNUIMessage({
        action = 'updateVehicle', 
        data = {
            showing = IsPauseMenuActive() == false and showingHUD or false,
            rpm = GetVehicleCurrentRpm(veh),
            speed = math.ceil(GetEntitySpeed(veh) * speedMultiplier),
            fuel = vehicleStats.fuel,
            engineOn = vehicleStats.engineOn,
            beltOn = vehicleStats.beltOn,
        }
    })
end

local function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num + 0.5 * mult)
end

local function getFuelLevel(vehicle)
    local updateTick = GetGameTimer()
    if (updateTick - lastFuelUpdate) > 2000 then
        lastFuelUpdate = updateTick
        lastFuelCheck = math.floor(exports[Config.fuel]:GetFuel(vehicle))
    end
    return lastFuelCheck
end

local function getCrossroads()
    local updateTick = GetGameTimer()
    if updateTick - lastCrossroadUpdate > 1500 then
        local pos = GetEntityCoords(cache.ped)
        local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
        lastCrossroadUpdate = updateTick
        local street1 = GetStreetNameFromHashKey(street1)
        local street2 = GetStreetNameFromHashKey(street2)
        if street2 then
            lastCrossroadCheck = street1..' x '..street2
        else
            lastCrossroadCheck = street1
        end
    end
    return lastCrossroadCheck
end

local directions = {"N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"}
local function getCardinalDirection(heading)
    local index = math.floor(((heading % 360) + 22.5) / 45) + 1
    return directions[index]
end

local function loadMap()
    CreateThread(function()
        Wait(50)
        local defaultAspectRatio = 1920 / 1080
        local resolutionX, resolutionY = GetActiveScreenResolution()
        local aspectRatio = resolutionX / resolutionY
        local minimapOffset = 0
        if aspectRatio > defaultAspectRatio then
            minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6) - 0.008
        end
        lib.requestStreamedTextureDict('majestic_minimap')
        SetMinimapClipType(1)
        AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'majestic_minimap', 'radarmasksm')
        AddReplaceTexture('platform:/textures/graphics', 'radarmask1g', 'majestic_minimap', 'radarmasksm')
        SetMinimapComponentPosition('minimap', 'L', 'B', 0.0 + minimapOffset, -0.047, 0.1638, 0.183)
        SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.0 + minimapOffset, 0.0, 0.128, 0.20)
        SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01 + minimapOffset, 0.025, 0.262, 0.300)
        SetBlipAlpha(GetNorthRadarBlip(), 0)
        SetMinimapClipType(1)
        SetBigmapActive(true, false)
        Wait(50)
        SetBigmapActive(false, false)
        SetStreamedTextureDictAsNoLongerNeeded('majestic_minimap')
    end)
end

local function vehicleStressLoop(veh)
    CreateThread(function()
        while veh == cache.vehicle do
            local vehClass = GetVehicleClass(veh)
            local speed = GetEntitySpeed(veh) * speedMultiplier
            local vehHash = GetEntityModel(veh)
            local stressSpeed
            if vehClass == 8 then -- Motorcycle exception for seatbelt
                stressSpeed = Config.minimumSpeed
            else
                stressSpeed = vehicleStats.beltOn and Config.minimumSpeed or Config.unbuckledSpeed
            end
            if speed >= stressSpeed then
                TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
            end
            Wait(10000)
        end
    end)
end

local function vehicleLoop(veh)
    if Config.noHudVehicles[GetEntityModel(veh)] then return end
    if Config.useStress.driving then
        vehicleStressLoop(veh)
    end
    CreateThread(function()
        while veh == cache.vehicle do
            SendNUIMessage({
                action = 'compasstick',
                data  = {
                    direction = getCardinalDirection(GetGameplayCamRot(0).z),
                    roads = getCrossroads(),
                    zone = GetLabelText(GetNameOfZone(GetEntityCoords(cache.ped))),
                },
            })
            updateVehicleStats()
            Wait(50)
        end
        SendNUIMessage({
            action = 'updateVehicle', 
            data = {showing = false, rpm = 0, speed = 0}
        })
    end)
end

local function holdingWeaponLoop()
    CreateThread(function()
        while cache.weapon do
            if IsPedShooting(cache.ped) and not Config.weaponWLStress[cache.weapon] then
                if math.random() < Config.shootingStressChance then
                    TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                end
            end
            Wait(0)
        end
    end)
end

lib.onCache('vehicle', function(value) if value then vehicleLoop(value) end end)
lib.onCache('weapon', function(hash)
    if not Config.useStress.shooting then return end
    if hash then
        if cache.weapon then
            cache.weapon = false
            Wait(1000)
        end
        holdingWeaponLoop()
    end
end)

local function GetBlurIntensity(stresslevel)
    for _, v in pairs(Config.intensity) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.intensity
        end
    end
    return 1500
end

local function GetEffectInterval(stresslevel)
    for _, v in pairs(Config.effectInterval) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.timeout
        end
    end
    return 60000
end

CreateThread(function()
    stats.stress = stats.stress or 0
    while true do
        local effectInterval = GetEffectInterval(stats.stress)
        if stats.stress >= 100 then
            local BlurIntensity = GetBlurIntensity(stats.stress)
            local FallRepeat = math.random(2, 4)
            local RagdollTimeout = FallRepeat * 1750
            TriggerScreenblurFadeIn(1000.0)
            Wait(BlurIntensity)
            TriggerScreenblurFadeOut(1000.0)
            if not IsPedRagdoll(cache.ped) and IsPedOnFoot(cache.ped) and not IsPedSwimming(cache.ped) then
                SetPedToRagdollWithFall(cache.ped, RagdollTimeout, RagdollTimeout, 1, GetEntityForwardVector(cache.ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            end
            Wait(1000)
            for _ = 1, FallRepeat, 1 do
                Wait(750)
                DoScreenFadeOut(200)
                Wait(1000)
                DoScreenFadeIn(200)
                TriggerScreenblurFadeIn(1000.0)
                Wait(BlurIntensity)
                TriggerScreenblurFadeOut(1000.0)
            end
        elseif stats.stress >= Config.screenShake then
            local BlurIntensity = GetBlurIntensity(stats.stress)
            TriggerScreenblurFadeIn(1000.0)
            Wait(BlurIntensity)
            TriggerScreenblurFadeOut(1000.0)
        end
        Wait(effectInterval)
    end
end)

CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do DisplayRadar(false) Wait(1000) end
    loadMap()
    while true do        
        Wait(500)
        local ped = cache.ped
        local playerId = cache.playerId
        health = math.floor((GetEntityHealth(ped) - 100)/(GetEntityMaxHealth(ped) - 100)*100)
        local isDead = IsEntityDead(ped) or playerData.metadata["inlaststand"] or playerData.metadata["isdead"] or false
        if isDead then health = 0 end
        armor = GetPedArmour(ped)
        isTalking = NetworkIsPlayerTalking(playerId) == 1
        onRadio = LocalPlayer.state['radioChannel'] > 0
        onPhone = LocalPlayer.state['callChannel'] > 0
        --parachute = GetPedParachuteState(ped)   Maybe...?
        --if IsEntityInWater(ped) then
            -- oxygen = GetPlayerUnderwaterTimeRemaining(playerId) * 10
        --end         
        if cache.vehicle and not IsThisModelABicycle(cache.vehicle) then
            vehicleStats.fuel = getFuelLevel(cache.vehicle)
            vehicleStats.engine = (GetVehicleEngineHealth(cache.vehicle) / 10) < 50
            vehicleStats.engineOn = GetIsVehicleEngineRunning(cache.vehicle)
            DisplayRadar(true)
        else
            DisplayRadar(Config.minimapWalking)
        end
        updateStats()
    end
end)

CreateThread(function()
    local minimap = RequestScaleformMovie('minimap')
    if not HasScaleformMovieLoaded(minimap) then
        RequestScaleformMovie(minimap)
        while not HasScaleformMovieLoaded(minimap) do
            Wait(1)
        end
    end
    while true do
        SetBigmapActive(false, false)
        SetRadarZoom(1000)
        Wait(500)
    end
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    Wait(2000)
    playerData = QBCore.Functions.GetPlayerData()
    stats.hunger = playerData.metadata.hunger
    stats.thirst = playerData.metadata.thirst
    stats.stress = playerData.metadata.stress
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
    playerData = {}
end)

RegisterNetEvent("QBCore:Player:SetPlayerData", function(val)
    playerData = val
    stats.hunger = playerData.metadata.hunger
    stats.thirst = playerData.metadata.thirst
    stats.stress = playerData.metadata.stress
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(1000)
    playerData = QBCore.Functions.GetPlayerData()
    stats.hunger = playerData.metadata.hunger
    stats.thirst = playerData.metadata.thirst
    stats.stress = playerData.metadata.stress
end)

RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst) -- Triggered in qb-core
    stats.hunger = newHunger
    stats.thirst = newThirst
end)

RegisterNetEvent('hud:client:UpdateStress', function(newStress) -- Add this event with adding stress elsewhere
    stats.stress = newStress
end)

AddEventHandler("pma-voice:setTalkingMode", function(mode)
    voiceRange = tonumber(mode)
    updateStats()
end)

AddEventHandler("pma-voice:radioActive", function(radioTalking)
    talkingOnRadio = radioTalking
    updateStats()
end)

RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function() -- Triggered in smallresources
    vehicleStats.beltOn = not vehicleStats.beltOn
    if vehicleStats.beltOn then
        lib.notify({title = 'Seatbelt On', type = 'success'})
    else
        lib.notify({title = 'Seatbelt Off', type = 'error'})
    end
    updateVehicleStats()
end)

RegisterNetEvent('hud:client:ToggleShowSeatbelt', function()
    vehicleStats.beltOn = not vehicleStats.beltOn
    updateVehicleStats()
end)