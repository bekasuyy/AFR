local ffi  = require("ffi")
local hook = require("monethook")
local gta  = ffi.load("GTASA")

local cast = ffi.cast
local base = MONET_GTASA_BASE

ffi.cdef([[
    typedef struct { float x, y, z; } vec3;
    void _ZN6CRadar12DrawRadarMapEv(void* self);
    void _ZN6CRadar21CalculateCachedSinCosEv(void* self);
    void _Z29FindPlayerCentreOfWorldForMapi(vec3* out, int player_id);
]])

local POSITION_SHIFT_VALUE = ((350.0 / 180.0) + (215.0 / 140.0)) / 2.0
local HALF_PI  = math.pi / 2
local ZOOM     = 180.0  -- default 180

local pRadarRange   = cast("float*", base + 0x994DAC)
local pRadarOriginX = cast("float*", base + 0x994DA4)
local pRadarOriginY = cast("float*", base + 0x994DA8)
local pSin          = cast("float*", base + 0x994EEC)
local pCos          = cast("float*", base + 0x994EE8)

local outVec = ffi.new("vec3")

local calcSinCosHook
calcSinCosHook = hook.new(
    "void(*)(void*)",
    function(self)
        pCos[0] = 1.0
        pSin[0] = 0.0
    end,
    cast("uintptr_t", cast("void*", gta._ZN6CRadar21CalculateCachedSinCosEv))
)

local radarMapHook
radarMapHook = hook.new(
    "void(*)(void*)",
    function(self)
        pRadarRange[0] = ZOOM

        gta._Z29FindPlayerCentreOfWorldForMapi(outVec, -1)

        local posShift = ZOOM / POSITION_SHIFT_VALUE
        pRadarOriginX[0] = outVec.x - math.cos(-HALF_PI) * posShift
        pRadarOriginY[0] = outVec.y - math.sin(-HALF_PI) * posShift

        radarMapHook(self)
    end,
    cast("uintptr_t", cast("void*", gta._ZN6CRadar12DrawRadarMapEv))
)

function main() wait(-1) end

-- my fav lol
