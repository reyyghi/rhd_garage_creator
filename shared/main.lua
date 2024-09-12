Math = lib.Math
Array = lib.array

Utils = {}
Utils.string = {}

_Invoking = GetInvokingResource
_IsServer = IsDuplicityVersion()

function Utils.string.empty(value)
    return value:match("^%s*$")
end