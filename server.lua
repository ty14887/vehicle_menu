-- server.lua

-- 刪除舊車（由客戶端傳來 networkId）
RegisterNetEvent('vmenu:deleteVehicle')
AddEventHandler('vmenu:deleteVehicle', function(netId)
    local veh = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(veh) then
        DeleteEntity(veh)
    end
end)
