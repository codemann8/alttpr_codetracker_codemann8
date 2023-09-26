SEGMENTS = {}

function autotracker_started()
    name = getmetatable(AutoTracker.ActiveConnector)["__name"]
    if (string.sub(name, 14, 16) == "Lua") then
        updateModal("Your autotracking method is outdated!", "...and will be DISABLED in the future!\nUsing the LUA autotracking method is outdated and very slow\ncompared to the SD2SNES option, even if you are using an emulator.\nIt is recommended to install and use SNI to connect the autotracker.", "For more info and support, please ask in the EmoTracker Discord.")
        Layout:FindLayout("ref_dyk_grid").Root.Layout = Layout:FindLayout("shared_dyk_grid")
    end
end

function autotracker_stopped()
    disposeMemoryWatch()
end

function isInGame()
    updateModuleFromMemorySegment(nil)
    return isInGameFromModule()
end

function isInGameFromModule(moduleId)
    local function foo(mod)
        return mod > 0x05 and mod < 0x1c and mod ~= 0x14 and mod ~= 0x19 and mod ~= 0x1a
    end
    if moduleId then
        return foo(moduleId)
    end
    return foo(CACHE.MODULE)
end


--Load Functions
ScriptHost:LoadScript("scripts/auto/itemupdates.lua")
ScriptHost:LoadScript("scripts/auto/sharedtypeupdates.lua")
ScriptHost:LoadScript("scripts/auto/segmentupdates.lua")


function initMemoryWatch()
    INSTANCE.MEMORY.Items = {}
    INSTANCE.MEMORY.ToggleItems = {}
    INSTANCE.MEMORY.Progress = {}
    INSTANCE.MEMORY.Overworld = {}
    INSTANCE.MEMORY.OverworldItems = {}
    INSTANCE.MEMORY.Shops = {}
    INSTANCE.MEMORY.Npc = {}
    INSTANCE.MEMORY.DungeonChests = {}
    INSTANCE.MEMORY.DungeonEnemyKeys = {}
    INSTANCE.MEMORY.DungeonPotKeys = {}
    INSTANCE.MEMORY.DungeonPotDrops = {}
    INSTANCE.MEMORY.CavePotDrops = {}
    INSTANCE.MEMORY.Bosses = {}
    INSTANCE.MEMORY.BossLocations = {}
    INSTANCE.MEMORY.Underworld = {}
    INSTANCE.MEMORY.UnderworldItems = {}

    for k, v in pairs(DATA.MEMORY.Items) do
        INSTANCE.MEMORY.Items[k] = v
    end
    for k, v in pairs(DATA.MEMORY.Progress) do
        INSTANCE.MEMORY.Progress[k] = v
    end
    for k, v in pairs(DATA.MEMORY.OverworldItems) do
        INSTANCE.MEMORY.OverworldItems[k] = v
    end
    for i, v in ipairs(DATA.MEMORY.DungeonChests) do
        INSTANCE.MEMORY.DungeonChests[i] = v
    end
    for i, v in ipairs(DATA.MEMORY.DungeonEnemyKeys) do
        INSTANCE.MEMORY.DungeonEnemyKeys[i] = v
    end
    for i, v in ipairs(DATA.MEMORY.DungeonPotKeys) do
        INSTANCE.MEMORY.DungeonPotKeys[i] = v
    end
    for i, v in ipairs(DATA.MEMORY.DungeonPotDrops) do
        INSTANCE.MEMORY.DungeonPotDrops[i] = v
    end
    for i, v in ipairs(DATA.MEMORY.CavePotDrops) do
        INSTANCE.MEMORY.CavePotDrops[i] = v
    end
    for i, v in ipairs(DATA.MEMORY.Bosses) do
        INSTANCE.MEMORY.Bosses[i] = v
    end
    for i, v in ipairs(DATA.MEMORY.BossLocations) do
        INSTANCE.MEMORY.BossLocations[i] = v
    end
    if Tracker.ActiveVariantUID == "full_tracker" then
        for k, v in pairs(DATA.MEMORY.Overworld) do
            INSTANCE.MEMORY.Overworld[k] = v
        end
        for k, v in pairs(DATA.MEMORY.Shops) do
            INSTANCE.MEMORY.Shops[k] = v
        end
        for k, v in pairs(DATA.MEMORY.Npc) do
            INSTANCE.MEMORY.Npc[k] = v
        end
        for i, v in ipairs(DATA.MEMORY.Underworld) do
            INSTANCE.MEMORY.Underworld[i] = v
        end
    end
    for i, v in ipairs(DATA.MEMORY.UnderworldItems) do
        INSTANCE.MEMORY.UnderworldItems[i] = v
    end
    
    SEGMENTS.DungeonWorksheet = ScriptHost:AddMemoryWatch("Dungeon Worksheet", 0x7e0400, 0xd, updateDungeonWorksheetFromMemorySegment, 200)
    
    SEGMENTS.ItemData = ScriptHost:AddMemoryWatch("Item Data", 0x7ef340, 0x20, updateItemsFromMemorySegment)
    SEGMENTS.MiscData = ScriptHost:AddMemoryWatch("Misc Data", 0x7ef36c, 0x5f, updateMiscFromMemorySegment)
    if Tracker.ActiveVariantUID ~= "vanilla" then
        for k, v in pairs(DATA.MEMORY.ToggleItems) do
            INSTANCE.MEMORY.ToggleItems[k] = v
        end
        SEGMENTS.RoomData = ScriptHost:AddMemoryWatch("Room Data", 0x7ef000, 0x250, updateRoomsFromMemorySegment)
        SEGMENTS.RandoData = ScriptHost:AddMemoryWatch("Rando Data", 0x7ef403, 0x22, updateRandoDataFromMemorySegment)
        SEGMENTS.DungeonData = ScriptHost:AddMemoryWatch("Dungeon Items", 0x7ef364, 0x26, updateDungeonItemsFromMemorySegment)
        SEGMENTS.DungeonAdditional = ScriptHost:AddMemoryWatch("Dungeon Additional", 0x7ef472, 0x7e, updateDungeonAdditionalFromMemorySegment)
    end
    if Tracker.ActiveVariantUID == "full_tracker" then
        SEGMENTS.OverworldData = ScriptHost:AddMemoryWatch("Overworld Data", 0x7ef280, 0x82, updateOverworldFromMemorySegment)
    end
end

function disposeMemoryWatch()
    STATUS.AutotrackerInGame = false

    local function disposeSegment(segment)
        if segment then
            ScriptHost:RemoveMemoryWatch(segment)
        end
        segment = nil
    end

    disposeSegment(SEGMENTS.ItemData)
    disposeSegment(SEGMENTS.RoomData)
    disposeSegment(SEGMENTS.RoomPotData)
    disposeSegment(SEGMENTS.RoomEnemyData)
    disposeSegment(SEGMENTS.OverworldData)
    disposeSegment(SEGMENTS.ShopData)

    disposeSegment(SEGMENTS.RandoData)
    disposeSegment(SEGMENTS.DungeonData)
    disposeSegment(SEGMENTS.DungeonAdditional)
end


--Base Memory Watches
ScriptHost:AddMemoryWatch("ROM Title", 0x701ffc, 25, updateTitleFromMemorySegment)
ScriptHost:AddMemoryWatch("Location State", 0x7e0010, 0x92, updateLocationFromMemorySegment, 80)
initMemoryWatch()

function numberOfSetBits(value)
    value = value - ((value >> 1) & 0x55)
    value = (value & 0x33) + ((value >> 2) & 0x33)
    return (((value + (value >> 4)) & 0x0F) * 0x01)
end