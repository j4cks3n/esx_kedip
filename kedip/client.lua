ESX = exports['es_extended']:getSharedObject()

local isInSolo = false
local isOnCooldown = false
local inCombat = false
local combatTimer = 0

function DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
    end
end

RegisterCommand("kedip", function()
    if isInSolo then
        exports['mythic_notify']:DoCustomHudText('inform', 'kedip ...',5000)
        return
    end
    if isOnCooldown then
        exports['mythic_notify']:DoCustomHudText('inform', 'cooldown kedip',5000)
        return
    end

    local ped = PlayerPedId()
    if Config.DisableWhileDead and IsEntityDead(ped) then
        exports['mythic_notify']:DoCustomHudText('error', 'kamu sedang pingsan',5000)
        return
    end
    if Config.DisableWhileInVehicle and IsPedInAnyVehicle(ped, false) then
        exports['mythic_notify']:DoCustomHudText('error', 'kamu sedang di dalam kendaraan',5000)
        return
    end
    if Config.DisableWhileArmed and IsPedArmed(ped, 7) then
        exports['mythic_notify']:DoCustomHudText('error', 'kamu sedang memengang senjata',5000)
        return
    end
    if Config.DisableWhileInCombat and inCombat then
        exports['mythic_notify']:DoCustomHudText('error', 'kamu sedang dalam peperangan',5000)
        return
    end
    if Config.DisableWhileinWater and IsPedSwimming(ped) then
        exports['mythic_notify']:DoCustomHudText('error', 'kamu sedang berenang',5000)
        return
    end
    if Config.DisableWhilefalling and (IsPedInParachuteFreeFall(ped) or IsPedRagdoll(ped)) then
        exports['mythic_notify']:DoCustomHudText('error', 'Tidak bisa kedip saat jatuh!',5000)
        return
    end

    StartKedip()
end)

function StartKedip()
    local ped = PlayerPedId()
    local playerId = PlayerId()
    isInSolo = true
    isOnCooldown = true

    exports['mythic_notify']:DoCustomHudText('inform', 'kedip ...',5000)

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    ClearPedTasksImmediately(ped)
    for _, id in ipairs(GetActivePlayers()) do
        if id ~= playerId then
            NetworkConcealPlayer(id, true, true)
        end
    end
    for veh in EnumerateVehicles() do
        SetEntityVisible(veh, false)
    end

    TriggerServerEvent("esx_kedip:setKedip", true)

    Citizen.SetTimeout(Config.SoloDuration * 1000, function()
        for _, id in ipairs(GetActivePlayers()) do
            if id ~= playerId then
                NetworkConcealPlayer(id, false, false)
            end
        end
        for veh in EnumerateVehicles() do
            SetEntityVisible(veh, true)
        end

        TriggerServerEvent("esx_kedip:setKedip", false)
        isInSolo = false
        exports['mythic_notify']:DoCustomHudText('inform', 'kedip selesai',5000)
        FreezeEntityPosition(ped, false)
        SetEntityInvincible(ped, false)

        Citizen.SetTimeout(Config.Cooldown * 1000, function()
            isOnCooldown = false
            exports['mythic_notify']:DoCustomHudText('inform', 'kamu sudah bisa kedip lagi',5000)
        end)
    end)
end

AddEventHandler("gameEventTriggered", function(event, data)
    if event == "CEventNetworkEntityDamage" then
        local victim, attacker = data[1], data[2]
        if victim == PlayerPedId() or attacker == PlayerPedId() then
            inCombat = true
            combatTimer = GetGameTimer() + (Config.CombatTimer * 1000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if inCombat and GetGameTimer() > combatTimer then
            inCombat = false
        end
        Citizen.Wait(1000)
    end
end)

local playersKedip = {}

RegisterNetEvent("esx_kedip:syncKedip")
AddEventHandler("esx_kedip:syncKedip", function(id, state)
    playersKedip[id] = state
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for _, id in ipairs(GetActivePlayers()) do
            if playersKedip[GetPlayerServerId(id)] then
                local targetPed = GetPlayerPed(id)
                local targetCoords = GetEntityCoords(targetPed)
                if #(coords - targetCoords) < 15.0 then
                    DrawText3D(targetCoords + vector3(0,0,1.0), "[kedip]Tunggu ...")
                end
            end
        end
        Citizen.Wait(0)
    end
end)

function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, veh = FindFirstVehicle()
        if not veh or veh == 0 then
            EndFindVehicle(handle)
            return
        end
        repeat
            coroutine.yield(veh)
            success, veh = FindNextVehicle(handle)
        until not success
        EndFindVehicle(handle)
    end)
end
