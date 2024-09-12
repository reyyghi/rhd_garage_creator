local BLIP_DEFAULT = {
    default = {
        sprite = 357,
        colour = 3
    },
    shared = {
        sprite = 357,
        colour = 3
    },
    depot = {
        sprite = 68,
        colour = 3
    }
}

local function groupsInput()
    local input = lib.inputDialog('Garage Groups', {
        { type = 'input', label = 'Name', placeholder = 'Enter job/gang name', required = true, description = 'The name of the job or gang you want to add.' },
        { type = 'number', label = 'Rank', required = true, description = 'Enter the rank for this job/gang. The rank determines the hierarchy or priority level.' },
    })

    return input and {
        name = input[1],
        rank = input[2]
    }
end

local function blipInput(default)
    local input = lib.inputDialog('Garage Blip', {
        { type = 'number', label = 'Sprite', default = default.sprite, description = 'Enter the sprite ID for the blip. This determines the icon that will appear on the map.', required = true },
        { type = 'number', label = 'Colour', default = default.colour, description = 'Enter the color ID for the blip. This sets the color of the icon on the map.', required = true }
    }, {
        allowCancel = true
    })

    return input and {
        sprite = input[1],
        colour = input[2],
    }
end

local function createGarageData(zones)
    local input = lib.inputDialog('Garage Creator (Zones)', {
        { type = 'input', label = 'Label', description = 'Enter a label for the garage zone. This will be used to identify the zone.', required = true },
        { type = 'checkbox', label = 'Blip', description = 'Enable a blip on the map to make this garage zone visible to players.' },
        { type = 'checkbox', label = 'Groups', description = 'Select if this garage zone should be accessible to specific jobs or gangs.' },
    
        { type = 'select', label = 'Type', description = 'Choose the type of garage. This determines how the garage behaves and interacts with players.', options = {
            { label = 'Depot', value = 'depot' },
            { label = 'Default', value = 'default' },
            { label = 'Shared', value = 'shared' }
        }},
    
        { type = 'multi-select', label = 'Vehicle Class', description = 'Select the types of vehicles that can be stored in this garage.', options = {
            { label = 'Car', value = 'car' },
            { label = 'Motorcycle', value = 'motorcycle' },
            { label = 'Bicycle', value = 'bicycle' },
            { label = 'Truck', value = 'truck' },
            { label = 'Helicopter', value = 'helicopter' },
            { label = 'Boat', value = 'boat' },
        }},

        { type = 'select', label = "Interaction", options = {
            {value = "radial", label = "Radial Menu"},
            {value = "keypressed", label = "Key Pressed"},
            {value = "targetped", label = "Target Ped"}
        }, required = true},
    })

    if not input then return end

    local label = input[1]
    local garageType = input[4]
    local garageClass = input[5]
    
    local blip = input[2] and blipInput(BLIP_DEFAULT[garageType])
    local groups = input[3] and groupsInput()
    
    local sp = CreateSpawnPoint(zones, false, nil, garageClass) ---@type table<string, vector3[]|string[]> | nil
    
    if not sp then
        return
    end
    
    local tPed = input[6] == 'targetped'
    local interact = tPed and CreateGaragePed(zones) or input[6]

    local data = {
        type = garageType,
        blip = blip,
        label = label,
        class = garageClass,
        groups = groups and {
            [groups.name] = groups.rank
        },
        interaction = interact,
        zones = zones,
        spawnPoint = sp and sp.c or sp,
        spawnPointVehicle = sp and sp.v or sp,
    }

    TriggerServerEvent('garage_creator:server:insertData', data)
end

RegisterNetEvent('garage_creator:client:createZone', function ()
    if _Invoking() then
        return
    end
    CreateZone(function (zones)
        if not zones then return end
        createGarageData(zones)
    end)
end)