math = lib.math
Array = lib.array

Utils = {}
Utils.string = {}

_Invoking = GetInvokingResource
_IsServer = IsDuplicityVersion()

---@param rot vector3
local RotationToDirection = function(rot)
    local rotZ = math.rad(rot.z)
    local rotX = math.rad(rot.x)
    local cosOfRotX = math.abs(math.cos(rotX))
    return vector3(-math.sin(rotZ) * cosOfRotX, math.cos(rotZ) * cosOfRotX, math.sin(rotX))
end

function Utils.string.empty(value)
    return value:match("^%s*$")
end

function math.round(val, dec)
    if not dec then return math.floor(val + 0.5) end
    local power = 10 ^ dec
    return math.floor((val * power) + 0.5) / power
end

function Utils.notify(msg, type, dur)
    return lib.notify({
        description = msg,
        type = type,
        duration = dur
    })
end

function Utils.raycastCam(distance)
    local camRot = GetGameplayCamRot()
    local camPos = GetGameplayCamCoord()
    local dir = RotationToDirection(camRot)
    local dest = camPos + (dir * distance)
    local ray = StartShapeTestRay(camPos, dest, 17, -1, 0)
    local _, hit, endPos = GetShapeTestResult(ray)
    if hit == 0 then endPos = dest end
    local inwater, watercoords = TestProbeAgainstWater(camPos.x, camPos.y, camPos.z, endPos.x, endPos.y, endPos.z)
    return hit, endPos, inwater, watercoords
end