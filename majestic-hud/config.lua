Config = {}

Config.useMPH = true
Config.minimapWalking = false
Config.fuel = 'LegacyFuel'

Config.noHudVehicles = {
    [`bmx`] = true,
}

Config.useStress = {
    shooting = true,
    driving = true,
}
Config.screenShake = 50 -- Minimum stress level for screen shaking
Config.shootingStressChance = 0.1 -- Percentage stress chance when shooting (0-1) (default = 10%)
Config.unbuckledSpeed = 50 -- Going over this Speed will cause stress
Config.minimumSpeed = 100 -- Going over this Speed will cause stress
Config.stressWLJobs = {
    --police = true,
    --ambulance = true,
}

Config.weaponWLStress = { -- Disable gaining stress from weapons in this table
    [`weapon_petrolcan`] = true,
    [`weapon_hazardcan`] = true,
    [`weapon_fireextinguisher`] = true
}

Config.intensity = {
    [1] = {
        min = 50,
        max = 60,
        intensity = 1500,
    },
    [2] = {
        min = 60,
        max = 70,
        intensity = 2000,
    },
    [3] = {
        min = 70,
        max = 80,
        intensity = 2500,
    },
    [4] = {
        min = 80,
        max = 90,
        intensity = 2700,
    },
    [5] = {
        min = 90,
        max = 100,
        intensity = 3000,
    },
}

Config.effectInterval = {
    [1] = {
        min = 50,
        max = 60,
        timeout = math.random(50000, 60000)
    },
    [2] = {
        min = 60,
        max = 70,
        timeout = math.random(40000, 50000)
    },
    [3] = {
        min = 70,
        max = 80,
        timeout = math.random(30000, 40000)
    },
    [4] = {
        min = 80,
        max = 90,
        timeout = math.random(20000, 30000)
    },
    [5] = {
        min = 90,
        max = 100,
        timeout = math.random(15000, 20000)
    }
}