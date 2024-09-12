lib.addCommand('creategarage', {
    help = 'Create new garage',
    params = {
        {
            name = 'type',
            type = 'string',
            help = 'Type [zones or points]'
        }
    }
}, function (source, args)
    if args.type == 'points' then
        TriggerClientEvent('rhd_garage:client:createPoints', source)
    end
end)

lib.addCommand('removeGarage', {
    help = 'Remove created garage',
}, function (source, args)
    local list = {}
    Array.forEach(CREATED_GARAGE, function (data)
        list[#list+1] = {
            value = data.label
        }
    end)

    local selected = lib.callback.await('creator:client:removeGarage', source, list)

    local index = Array.findIndex(CREATED_GARAGE, function (data)
        if data.label == selected then
            return true
        end
    end)

    if CREATED_GARAGE[index] then
        table.remove(CREATED_GARAGE, index)
        exports.rhd_garage:RemoveGarage(selected)
        
        SetTimeout(5000, function ()
            SaveFile(CREATED_GARAGE)
        end)
    end
end)