local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('hud:server:GainStress', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Job = Player.PlayerData.job.name
    local JobType = Player.PlayerData.job.type
    local newStress
    if not Player or Config.stressWLJobs[JobType] or Config.stressWLJobs[Job] then return end
    if not Player.PlayerData.metadata['stress'] then
        Player.PlayerData.metadata['stress'] = 0
    end
    newStress = Player.PlayerData.metadata['stress'] + amount
    if newStress <= 0 then newStress = 0 end
    if newStress > 100 then
        newStress = 100
    end
    Player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    TriggerClientEvent('QBCore:Notify', src, 'Stress Gain', 'error', 1500)
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
    if Config.DisableStress then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local newStress
    if not Player then return end
    if not Player.PlayerData.metadata['stress'] then
        Player.PlayerData.metadata['stress'] = 0
    end
    newStress = Player.PlayerData.metadata['stress'] - amount
    if newStress <= 0 then newStress = 0 end
    if newStress > 100 then
        newStress = 100
    end
    Player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    TriggerClientEvent('QBCore:Notify', src, 'Stress Removed')
end)