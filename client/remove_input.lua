lib.callback.register('creator:client:removeGarage', function(_, garageList)

    if not Array.isArray(garageList) then
        return
    end

    local input = lib.inputDialog('Remove Garage', {
        { type = 'select', options = garageList, label = 'Select the garage you want to delete', required = true},
    })
    return input and not Utils.string.empty(input[1]) and input[1]
end)