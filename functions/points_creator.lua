local busy = true


local function updateText(text)
    lib.showTextUI(text, {
        style = {
            borderRadius = 2
        }
    })
end

local function existPoints(points, coords)
    return lib.array.find(points, function (c)
        local dist = #(c.xyz - coords.xyz)
        if dist < 5 then
            return true
        end
    end)
end

local function start(promise)

    local points = {}
	local length, width, prefxZ, height, rotY, markerType

    updateText([[
        Enter - Add Points
        Backspace - Edit previous points
        ESC - Exit Creator
        
        Type: Take Vehicle
    ]])

    busy = true
	CreateThread(function()
		while busy do
			local coords = GetEntityCoords(cache.ped)
			local x = coords.x
			local y = coords.y
			local z = coords.z
			local heading = GetEntityHeading(cache.ped)

			DisableControlAction(0, 200, true)
			DisableControlAction(0, 201, true)
            DisableControlAction(0, 194, true)

            if points[1] then
                length = 3.0
                width = 5.0
                prefxZ = 2.0
                height = 2.5
                rotY = 180.0
                markerType = 43
            else
                length = 1.0
                width = 1.0
                prefxZ = -1
                height = 1.0
                rotY = 0.0
                markerType = 1
            end

            DrawMarker(markerType,
                x,
                y,
                z + prefxZ,
                0.0, 0.0, 0.0,
                0.0, rotY, -heading,
                length --[[scale x]], width --[[scale y]], height --[[scale z]],
                198, 255, 9, 150,
                false, false, 2, false, nil, nil, false
            )
		
			if IsDisabledControlJustPressed(0, 201) then
                local new = vec(x, y, z, heading)
                if #points < 2 then
                    if not existPoints(points, new) then
                        points[#points+1] = new
                        updateText([[
            Enter - Add Points
            Backspace - Edit previous points
            ESC - Exit Creator
            
            Type: Spawn & Save Vehicle]])
                        
                        if #points == 2 then
                            busy = false
    
                            local results = {
                                take = vec(points[1].x, points[1].y, points[1].z, points[1].w),
                                save = vec(points[2].x, points[2].y, points[2].z, points[2].w),
                            }
    
                            local alert = lib.alertDialog({
                                header = 'Point Creator',
                                content = 'All points have been created successfully. Would you like to display markers for these points to help players see them more easily?',
                                centered = true,
                                cancel = true,
                                labels = {
                                    confirm = 'Yes',
                                    cancel = 'No'
                                }
                            })
                            
                            results.useMarker = alert == 'confirm'
                            promise:resolve(results)

                            local tformat = [[
                                local points = {
                                    take = vec(%.2f, %.2f, %.2f, %.2f),
                                    save = vec(%.2f, %.2f, %.2f, %.2f),
                                    useMarker = %s
                                }
                            ]]
                            
                            lib.setClipboard(tformat:format(
                                points[1].x, points[1].y, points[1].z, points[1].w,
                                points[2].x, points[2].y, points[2].z, points[2].w,
                                results.useMarker
                            ))
                        end
                    else
                        lib.notify({
                            title = 'Point Creator',
                            description = 'Point distance must be above 5',
                            type = 'error'
                        })
                    end
                end
			end

			if IsDisabledControlJustPressed(0, 194) then
				table.remove(points, #points)
                updateText([[
        Enter - Add Points
        Backspace - Edit previous points
        ESC - Exit Creator
        
        Type: Take Vehicle]])
			end

			if IsDisabledControlJustPressed(0, 200) then
				busy = false
                promise:resolve(false)
			end
			Wait(0)
		end
        lib.hideTextUI()
	end)
end

function CreateGaragePoints()
    local p = promise.new()
    start(p)
    return Citizen.Await(p)
end