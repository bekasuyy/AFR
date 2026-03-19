-- offset for sa v2.00

local ffi  = require("ffi")
local hook = require("monethook")
local gta  = ffi.load("GTASA")

local cast = ffi.cast
local base = MONET_GTASA_BASE

ffi.cdef([[
    typedef struct { float x, y, z; } vec3;
    void _ZN6CRadar12DrawRadarMapEv(void* self);
    void _Z29FindPlayerCentreOfWorldForMapi(vec3* out, int player_id);
]])

local POSITION_SHIFT_VALUE = ((350.0 / 180.0) + (215.0 / 140.0)) / 2.0
local HALF_PI = math.pi / 2

local pRadarRange       = cast("float*", base + 0x994DAC)
local pRadarOrientation = cast("float*", base + 0x994EC8)
local pRadarOriginX     = cast("float*", base + 0x994DA4)
local pRadarOriginY     = cast("float*", base + 0x994DA8)

local outVec = ffi.new("vec3")

local radarMapHook
radarMapHook = hook.new(
    "void(*)(void*)",
    function(self)
        gta._Z29FindPlayerCentreOfWorldForMapi(outVec, -1)

        local posShift = pRadarRange[0] / POSITION_SHIFT_VALUE
        local angle    = pRadarOrientation[0] - HALF_PI

        pRadarOriginX[0] = outVec.x - math.cos(angle) * posShift
        pRadarOriginY[0] = outVec.y - math.sin(angle) * posShift

        radarMapHook(self)
    end,
    cast("uintptr_t", cast("void*", gta._ZN6CRadar12DrawRadarMapEv))
)

function main() wait(-1) end
