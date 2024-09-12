CREATED_GARAGE = lib.loadJson('data.garages')

function SaveFile(data)
    SaveResourceFile(cache.resource, 'data/garages.json', json.encode(data), -1)
end

RegisterNetEvent('garage_creator:server:insertData', function(clientData)
    if not Array.find(CREATED_GARAGE, function (data)
        if data.label == clientData.label then
            return true
        end
    end) then
        CREATED_GARAGE[#CREATED_GARAGE+1] = clientData
        exports.rhd_garage:AddGarage(clientData)

        SetTimeout(5000, function ()
            SaveFile(CREATED_GARAGE)
        end)
    end
end)