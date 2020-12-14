print("")
print("Active Auto-Tracker Configuration")
print("---------------------------------------------------------------------")
print("Enable Item Tracking:       ", not AUTOTRACKER_DISABLE_ITEM_TRACKING)
print("Enable Location Tracking:   ", not AUTOTRACKER_DISABLE_LOCATION_TRACKING)
print("Enable Region Tracking:     ", not AUTOTRACKER_DISABLE_REGION_TRACKING)
if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
    print("Enable Debug Logging:       ", "true")
end
print("---------------------------------------------------------------------")
print("")

function autotracker_started()
    AUTOTRACKER_ON = true
    START_TIME = os.time()
end

function autotracker_stopped()
    AUTOTRACKER_ON = false
end

AUTOTRACKER_IS_IN_TRIFORCE_ROOM = false
AUTOTRACKER_HAS_DONE_POST_GAME_SUMMARY = false
AUTOTRACKER_STATS_MARKDOWN_FORMAT =
    [===[
### Post-Game Summary

Stat | Value
--|-
**Collection Rate** | %d
**Deaths** | %d
**Bonks** | %d
**Total Time** | %02d:%02d:%02d.%02d
]===]

U8_READ_CACHE = 0
U8_READ_CACHE_ADDRESS = 0

U16_READ_CACHE = 0
U16_READ_CACHE_ADDRESS = 0

--Shared Functions
function InvalidateReadCaches()
    U8_READ_CACHE_ADDRESS = 0
    U16_READ_CACHE_ADDRESS = 0
end

function ReadU8(segment, address)
    if U8_READ_CACHE_ADDRESS ~= address then
        U8_READ_CACHE = segment:ReadUInt8(address)
        U8_READ_CACHE_ADDRESS = address
    end

    return U8_READ_CACHE
end

function ReadU16(segment, address)
    if U16_READ_CACHE_ADDRESS ~= address then
        U16_READ_CACHE = segment:ReadUInt16(address)
        U16_READ_CACHE_ADDRESS = address
    end

    return U16_READ_CACHE
end

function testFlag(segment, address, flag)
    local value = ReadU8(segment, address)
    local flagTest = value & flag

    if flagTest ~= 0 then
        return true
    else
        return false
    end
end

function numberOfSetBits(value)
     value = value - ((value >> 1) & 0x55)
     value = (value & 0x33) + ((value >> 2) & 0x33)
     return (((value + (value >> 4)) & 0x0F) * 0x01)
end

function isInGame()
    local module = AutoTracker:ReadU8(0x7e0010, 0)
    return module > 0x05 and module < 0x55 and module ~= 0x14
end

function read32BitTimer(segment, baseAddress)
    local timer = 0
    timer = timer | (ReadU8(segment, baseAddress + 3) << 24)
    timer = timer | (ReadU8(segment, baseAddress + 2) << 16)
    timer = timer | (ReadU8(segment, baseAddress + 1) << 8)
    timer = timer | (ReadU8(segment, baseAddress + 0) << 0)

    local hours = timer // (60 * 60 * 60)
    local minutes = (timer % (60 * 60 * 60)) // (60 * 60)
    local seconds = (timer % (60 * 60)) // (60)
    local frames = timer % 60

    return hours, minutes, seconds, frames
end

--Load Functions
ScriptHost:LoadScript("scripts/auto/itemupdates.lua")
ScriptHost:LoadScript("scripts/auto/sharedtypeupdates.lua")
ScriptHost:LoadScript("scripts/auto/segmentupdates.lua")

--Add Memory Watches
-- Run the in-game status check more frequently (every 250ms) to catch save/quit scenarios more effectively
ScriptHost:AddMemoryWatch("LTTP Module Id", 0x7e0010, 2, updateModuleIdFromMemorySegment, 250)
--ScriptHost:AddMemoryWatch("LTTP In-Game status", 0x7e0010, 2, updateModuleIdFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Item Data", 0x7ef340, 0x90, updateItemsFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Room Data", 0x7ef000, 0x250, updateRoomsFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Overworld Event Data", 0x7ef280, 0x82, updateOverworldEventsFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP NPC Item Data", 0x7ef410, 2, updateNPCItemFlagsFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Heart Piece Data", 0x7ef448, 1, updateHeartPiecesFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Heart Container Data", 0x7ef36c, 1, updateHeartContainersFromMemorySegment)

ScriptHost:AddMemoryWatch("LTTP Dungeon Data", 0x7ef364, 0x26, updateDungeonItemsFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Dungeon Data", 0x7ef4a0, 0x50, updateDungeonKeysFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Dungeon Pendant Data", 0x7ef374, 1, updateDungeonPendantFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Dungeon Crystal Data", 0x7ef37a, 1, updateDungeonCrystalFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Overworld Id", 0x7e008a, 2, updateOverworldIdFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Dungeon Id", 0x7e040c, 1, updateDungeonIdFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Room Id", 0x7e00a0, 2, updateRoomIdFromMemorySegment)
SEGMENT_GTBIGKEYCOUNT = ScriptHost:AddMemoryWatch("LTTP GT BK Game", 0x7ef42a, 1, updateGTBKFromMemorySegment)
SEGMENT_GTTORCHROOM = ScriptHost:AddMemoryWatch("LTTP GT BK Game", 0x7ef118, 2, updateGTBKFromMemorySegment) --GT Torch Visit
ScriptHost:AddMemoryWatch("LTTP GT BK Game", 0x7ef0d6, 2, updateGTBKFromMemorySegment) --GT Gauntlet Climb Update
ScriptHost:AddMemoryWatch("LTTP GT BK Game", 0x7ef01a, 2, updateGTBKFromMemorySegment) --Aga2 Update
