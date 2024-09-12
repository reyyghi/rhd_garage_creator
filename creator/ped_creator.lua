local pedlist = lib.loadJson('data.peds')

local curPed
local busycreate = false
local glm = require "glm"

local function CancelPlacement()
    DeletePed(curPed)
    busycreate = false
    curPed = nil
end


---@param coords vector3[]
local function tovec3(coords)
    local results = {}
    if Array.isArray(coords) then
        Array.forEach(coords, function (c)
            results[#results+1] = vec3(c.x, c.y, c.z)
        end)
    end
    return results
end

---@param zone {points: vector3[], thickness: number}
function CreateGaragePed(zone)
    if not zone then return end
    if busycreate then return end
    
    local pedIndex = 1
    local pedmodels = pedlist[pedIndex]
    local points = tovec3(zone.points)
    local polygon = glm.polygon.new(points)

    local text = [[
    [X]: Cancel
    [Enter]: Confirm
    [Arrow Right/Left]: Rotate Ped
    [Mouse Scroll Up/Down]: Change Ped
    ]]

    lib.showTextUI(text, {
        style = {
            borderRadius = 2
        }
    })

    lib.requestModel(pedmodels, 1500)
    curPed = CreatePed(0, pedmodels, 1.0, 1.0, 1.0, 0.0, false, false)
    SetEntityAlpha(curPed, 150, false)
    SetEntityCollision(curPed, false, false)
    FreezeEntityPosition(curPed, true)

    local notif = false
    local pc = nil
    local heading = 0.0

    local p = promise.new()
    CreateThread(function()
        busycreate = true
        while busycreate do
            local hit, coords = Utils.raycastCam(20.0)
            CurrentCoords = GetEntityCoords(curPed)
            
            local inZone = glm.polygon.contains(polygon, CurrentCoords, zone.thickness / 4)
            local debugColor = inZone and {r = 10, g = 244, b = 115, a = 50} or {r = 240, g = 5, b = 5, a = 50}
            DebugZone(polygon, zone.thickness, debugColor)

            if hit == 1 then
                SetEntityCoords(curPed, coords.x, coords.y, coords.z)
            end

            DisableControlAction(0, 174, true)
            DisableControlAction(0, 175, true)
            DisableControlAction(0, 73, true)
            DisableControlAction(0, 176, true)
            DisableControlAction(0, 14, true)
            DisableControlAction(0, 15, true)
            DisableControlAction(0, 172, true)
            DisableControlAction(0, 173, true)
            
            if IsDisabledControlPressed(0, 174) then
                heading = heading + 0.5
                if heading > 360 then heading = 0.0 end
            end
    
            if IsDisabledControlPressed(0, 175) then
                heading = heading - 0.5
                if heading < 0 then heading = 360.0 end
            end

            if IsDisabledControlJustPressed(0, 14) then
                local newIndex = pedIndex+1
                local newModel = pedlist[newIndex]
                if newModel then
                    DeleteEntity(curPed)
                    lib.requestModel(newModel)
                    local newped = CreatePed(0, newModel, 1.0, 1.0, 1.0, 0.0, false, false)
                    SetEntityAlpha(newped, 150, false)
                    SetEntityCollision(newped, false, false)
                    FreezeEntityPosition(newped, true)
                    curPed = newped
                    pedIndex = newIndex
                end
            end

            if IsDisabledControlJustPressed(0, 15) then
                local newIndex = pedIndex-1

                if newIndex >= 1 then
                    local newModel = pedlist[newIndex]
                    if newModel then
                        DeleteEntity(curPed)
                        lib.requestModel(newModel)
                        local newped = CreatePed(0, newModel, 1.0, 1.0, 1.0, 0.0, false, false)
                        SetEntityAlpha(newped, 150, false)
                        SetEntityCollision(newped, false, false)
                        FreezeEntityPosition(newped, true)
                        curPed = newped
                        pedIndex = newIndex
                    end
                end
            end
            
            SetEntityHeading(curPed, heading)

            if IsDisabledControlJustPressed(0, 176) then
                if hit == 1 then
                    if inZone then
                        pc = {
                            model = pedlist[pedIndex],
                            coords = vec(CurrentCoords.x, CurrentCoords.y, CurrentCoords.z, heading)
                        }
                        Utils.notify("Ped location successfully set", "success", 8000)
                        CancelPlacement()
                        p:resolve(pc)
                        if notif then notif = false end
                    else
                        if not notif then
                            Utils.notify("Can only be in the zone !", "error", 8000)
                            notif = true
                        end
                    end
                end
            end
            Wait(1)
        end
        lib.hideTextUI()
    end)

    return Citizen.Await(p)
end