local playersKedip = {}

RegisterServerEvent("esx_kedip:setKedip")
AddEventHandler("esx_kedip:setKedip", function(state)
    local src = source
    playersKedip[src] = state
    TriggerClientEvent("esx_kedip:syncKedip", -1, src, state)
end)

AddEventHandler("playerDropped", function()
    local src = source
    playersKedip[src] = nil
    TriggerClientEvent("esx_kedip:syncKedip", -1, src, false)
end)
