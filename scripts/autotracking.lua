SEGMENTS = {}

function autotracker_started()
    STATUS.AutotrackerInGame = false
end

function autotracker_stopped()
    STATUS.AutotrackerInGame = false
    disposeMemoryWatch()
end

function isInGame(segment)
    updateModuleFromMemorySegment(nil)
    return isInGameFromModule()
end

function isInGameFromModule()
    return CACHE.MODULE > 0x05 and CACHE.MODULE < 0x1c and CACHE.MODULE ~= 0x14 and CACHE.MODULE ~= 0x19 and CACHE.MODULE ~= 0x1a
end


--Load Functions
ScriptHost:LoadScript("scripts/auto/itemupdates.lua")
ScriptHost:LoadScript("scripts/auto/sharedtypeupdates.lua")
ScriptHost:LoadScript("scripts/auto/segmentupdates.lua")


function initMemoryWatch()
    STATUS.LastMajorItem = os.time()

    INSTANCE.MEMORY.Items = {}
    INSTANCE.MEMORY.ToggleItems = {}
    INSTANCE.MEMORY.Progress = {}
    INSTANCE.MEMORY.Overworld = {}
    INSTANCE.MEMORY.OverworldItems = {}
    INSTANCE.MEMORY.Shops = {}
    INSTANCE.MEMORY.Npc = {}
    INSTANCE.MEMORY.DungeonChests = {}
    INSTANCE.MEMORY.DungeonEnemyDrops = {}
    INSTANCE.MEMORY.DungeonPotDrops = {}
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
    for i, v in ipairs(DATA.MEMORY.DungeonEnemyDrops) do
        INSTANCE.MEMORY.DungeonEnemyDrops[i] = v
    end
    for i, v in ipairs(DATA.MEMORY.DungeonPotDrops) do
        INSTANCE.MEMORY.DungeonPotDrops[i] = v
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
    
    SEGMENTS.DungeonId = ScriptHost:AddMemoryWatch("Dungeon Id", 0x7e040c, 1, updateDungeonIdFromMemorySegment)
    SEGMENTS.RoomId = ScriptHost:AddMemoryWatch("Room Id", 0x7e00a0, 2, updateRoomIdFromMemorySegment)
    SEGMENTS.OverworldId = ScriptHost:AddMemoryWatch("Overworld Id", 0x7e008a, 1, updateOverworldIdFromMemorySegment)
    SEGMENTS.WorldFlag = ScriptHost:AddMemoryWatch("World Flag", 0x7ef3ca, 1, updateWorldFlagFromMemorySegment)
    SEGMENTS.HealthData = ScriptHost:AddMemoryWatch("Health Data", 0x7ef36c, 2, updateHealthFromMemorySegment)
    
    SEGMENTS.ItemData = ScriptHost:AddMemoryWatch("Item Data", 0x7ef340, 0x20, updateItemsFromMemorySegment)
    SEGMENTS.HalfMagicData = ScriptHost:AddMemoryWatch("Half Magic Data", 0x7ef37b, 1, updateHalfMagicFromMemorySegment)
    SEGMENTS.ProgressData = ScriptHost:AddMemoryWatch("Progress Data", 0x7ef3c5, 5, updateProgressFromMemorySegment)
    if Tracker.ActiveVariantUID ~= "vanilla" then
        for k, v in pairs(DATA.MEMORY.ToggleItems) do
            INSTANCE.MEMORY.ToggleItems[k] = v
        end
        SEGMENTS.ToggleItemData = ScriptHost:AddMemoryWatch("Toggle Item Data", 0x7ef38c, 3, updateToggleItemsFromMemorySegment)
        SEGMENTS.ArrowData = ScriptHost:AddMemoryWatch("Arrow Data", 0x7ef377, 1, updateToggleItemsFromMemorySegment)
    end
    SEGMENTS.RoomData = ScriptHost:AddMemoryWatch("Room Data", 0x7ef000, 0x250, updateRoomsFromMemorySegment)
    if INSTANCE.NEW_POTDROP_SYSTEM then
        SEGMENTS.RoomPotData = ScriptHost:AddMemoryWatch("Room Pot Data", 0x7f6600, 0x250, updateRoomPotsFromMemorySegment)
        SEGMENTS.RoomEnemyData = ScriptHost:AddMemoryWatch("Room Enemy Data", 0x7f6850, 0x250, updateRoomEnemiesFromMemorySegment)
    end
    if Tracker.ActiveVariantUID == "full_tracker" then
        SEGMENTS.OverworldData = ScriptHost:AddMemoryWatch("Overworld Data", 0x7ef280, 0x82, updateOverworldFromMemorySegment)
        SEGMENTS.NPCData = ScriptHost:AddMemoryWatch("NPC Data", 0x7ef410, 2, updateNPCFromMemorySegment)
        SEGMENTS.ShopData = ScriptHost:AddMemoryWatch("Shop Data", 0x7ef302, 0x20, updateShopsFromMemorySegment)
    end
    
    if Tracker.ActiveVariantUID ~= "vanilla" then
        SEGMENTS.Collection = ScriptHost:AddMemoryWatch("Collection Rate", 0x7ef423, 2, updateCollectionFromMemorySegment)
        SEGMENTS.DungeonData = ScriptHost:AddMemoryWatch("Dungeon Items", 0x7ef364, 0x26, updateDungeonItemsFromMemorySegment)
        SEGMENTS.DungeonKeyData = ScriptHost:AddMemoryWatch("Dungeon Keys", 0x7ef4a0, 0x50, updateDungeonKeysFromMemorySegment)
        SEGMENTS.PendantData = ScriptHost:AddMemoryWatch("Pendant Data", 0x7ef374, 1, updateDungeonPendantFromMemorySegment)
        SEGMENTS.CrystalData = ScriptHost:AddMemoryWatch("Crystal Data", 0x7ef37a, 1, updateDungeonCrystalFromMemorySegment)
    end
    
    STATUS.AutotrackerInGame = true
end

function disposeMemoryWatch()
    STATUS.AutotrackerInGame = false

    ScriptHost:RemoveMemoryWatch(SEGMENTS.ItemData)
    ScriptHost:RemoveMemoryWatch(SEGMENTS.HealthData)
    ScriptHost:RemoveMemoryWatch(SEGMENTS.HalfMagicData)
    if Tracker.ActiveVariantUID ~= "vanilla" then
        ScriptHost:RemoveMemoryWatch(SEGMENTS.ToggleItemData)
        ScriptHost:RemoveMemoryWatch(SEGMENTS.ArrowData)
    end
    ScriptHost:RemoveMemoryWatch(SEGMENTS.ProgressData)
    ScriptHost:RemoveMemoryWatch(SEGMENTS.RoomData)
    ScriptHost:RemoveMemoryWatch(SEGMENTS.RoomPotData)
    ScriptHost:RemoveMemoryWatch(SEGMENTS.RoomEnemyData)
    ScriptHost:RemoveMemoryWatch(SEGMENTS.OverworldData)
    ScriptHost:RemoveMemoryWatch(SEGMENTS.ShopData)
    ScriptHost:RemoveMemoryWatch(SEGMENTS.NPCData)
    ScriptHost:RemoveMemoryWatch(SEGMENTS.Collection)

    ScriptHost:RemoveMemoryWatch(SEGMENTS.DungeonData)
    ScriptHost:RemoveMemoryWatch(SEGMENTS.DungeonKeyData)
    ScriptHost:RemoveMemoryWatch(SEGMENTS.PendantData)
    ScriptHost:RemoveMemoryWatch(SEGMENTS.CrystalData)
    ScriptHost:RemoveMemoryWatch(SEGMENTS.DungeonId)
    ScriptHost:RemoveMemoryWatch(SEGMENTS.RoomId)
    ScriptHost:RemoveMemoryWatch(SEGMENTS.OverworldId)
    ScriptHost:RemoveMemoryWatch(SEGMENTS.WorldFlag)
end


--Base Memory Watches
ScriptHost:AddMemoryWatch("ROM Title", 0x701ffc, 25, updateTitleFromMemorySegment)
ScriptHost:AddMemoryWatch("Module Id", 0x7e0010, 1, updateModuleFromMemorySegment, 1000)


function numberOfSetBits(value)
    value = value - ((value >> 1) & 0x55)
    value = (value & 0x33) + ((value >> 2) & 0x33)
    return (((value + (value >> 4)) & 0x0F) * 0x01)
end