function updateTitleFromMemorySegment(segment)
    if Tracker.ActiveVariantUID ~= "vanilla" then
        INSTANCE.VERSION_MAJOR = segment:ReadUInt16(0x701ffc)
        INSTANCE.VERSION_MINOR = segment:ReadUInt16(0x701ffe)
        local value = segment:ReadUInt8(0x702000)
        if value > 0 then
            value = string.char(segment:ReadUInt8(0x702013)) == 'O' and 1 or 0
            if OBJ_WORLDSTATE:getProperty("version") ~= value then
                OBJ_WORLDSTATE.clicked = true
                OBJ_WORLDSTATE.ignorePostUpdate = true
                OBJ_WORLDSTATE:setProperty("version", value)
            end

            INSTANCE.NEW_SRAM_SYSTEM = INSTANCE.VERSION_MINOR > 1
            if INSTANCE.NEW_SRAM_SYSTEM and STATUS.AutotrackerInGame then
                SEGMENTS.ShopData = ScriptHost:AddMemoryWatch("Shop Data", 0x7f64b8, 0x20, updateShopsFromMemorySegment)
                SEGMENTS.DungeonTotals = ScriptHost:AddMemoryWatch("Dungeon Totals", 0x7ef403, 2, updateDungeonTotalsFromMemorySegment)
                SEGMENTS.DungeonsCompleted = ScriptHost:AddMemoryWatch("Dungeons Completed", 0x7ef472, 2, updateDungeonsCompletedFromMemorySegment)
            end

            INSTANCE.NEW_POTDROP_SYSTEM = AutoTracker:ReadU8(0x28AA50, 0) > 0
            if INSTANCE.NEW_POTDROP_SYSTEM and STATUS.AutotrackerInGame then
                -- TODO: if this is brought back, remember to change the address
                --SEGMENTS.RoomPotData = ScriptHost:AddMemoryWatch("Room Pot Data", 0x7f6600, 0x250, updateRoomPotsFromMemorySegment)
                --SEGMENTS.RoomEnemyData = ScriptHost:AddMemoryWatch("Room Enemy Data", 0x7f6850, 0x250, updateRoomEnemiesFromMemorySegment)
            end
        end
    end
end
    
function updateModuleFromMemorySegment(segment)
    local moduleId = nil
    if segment then
        moduleId = segment:ReadUInt8(0x7e0010)
    else
        moduleId = AutoTracker:ReadU8(0x7e0010, 0)
    end

    if moduleId ~= CACHE.MODULE and moduleId ~= 0x0e then
        --Update Dungeon Id when starting at Sanctuary
        if CACHE.MODULE == 0x05 and moduleId == 0x07 then
            CACHE.MODULE = moduleId
            updateDungeonIdFromMemorySegment(nil)
        end

        CACHE.MODULE = moduleId

        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("CURRENT MODULE:", CACHE.MODULE, string.format("0x%2X", CACHE.MODULE))
        end

        if not STATUS.AutotrackerInGame and isInGameFromModule() then
            initMemoryWatch()
        end

        if CACHE.MODULE == 0x12 then
            STATUS.HealthState = 0
            sendExternalMessage("health", "dead")
        end

        if STATUS.AutotrackerInGame and (CACHE.MODULE == 0x19 or CACHE.MODULE == 0x1a) then
            --Post Game Actions
            STATUS.HealthState = 3
            sendExternalMessage("health", "win")

            doStatsMessage()
            disposeMemoryWatch()
        end
    end
end

function updateWorldFlagFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: World")
    end

    if segment then
        CACHE.WORLD = segment:ReadUInt8(0x7ef3ca)
    else
        CACHE.WORLD = AutoTracker:ReadU8(0x7ef3ca, 0)
    end
    local OWAREA = AutoTracker:ReadU8(0x7e008a, 0)
    local MODULE = AutoTracker:ReadU8(0x7e0010, 0)

    if not (CACHE.DUNGEON == 0xff and MODULE == 0x09) then --force OW transitions to retain OW ID
        if (OWAREA == 0 and (MODULE == 0x07 or MODULE == 0x05 or MODULE == 0x0e or MODULE == 0x17 or MODULE == 0x11 or MODULE == 0x06 or MODULE == 0x0f)) --transitioning into dungeons
                or OWAREA > 0x81 then --transitional OW IDs are ignored ie. 0x96
            OWAREA = 0xff
        end
    end

    if CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_DUNGEON_IMAGE and OWAREA < 0xff then
        --Update Dungeon Image
        if CACHE.WORLD == 0x40 then
            if CONFIG.BROADCAST_ALTERNATE_LAYOUT == 2 then
                sendExternalMessage("dungeon", "er-dw")
            else
                sendExternalMessage("dungeon", "dw")
            end
        else
            if CONFIG.BROADCAST_ALTERNATE_LAYOUT == 2 then
                sendExternalMessage("dungeon", "er-lw")
            else
                sendExternalMessage("dungeon", "lw")
            end
        end
    end

    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("CURRENT WORLD:", CACHE.WORLD, string.format("0x%2X", CACHE.WORLD))
    end
end

function updateOverworldIdFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: OverworldId")
    end

    local owarea = segment:ReadUInt8(0x7e008a)
    local MODULE = AutoTracker:ReadU8(0x7e0010, 0)
    if not (CACHE.DUNGEON == 0xff and MODULE == 0x09) then --force OW transitions to retain OW ID
        if (owarea == 0 and (
                MODULE == 0x07 or --in cave/dungeon
                MODULE == 0x05 or --on file select screen
                MODULE == 0x0e or --has dialogue/menu open
                MODULE == 0x12 or --game over
                MODULE == 0x17 or --is s+q
                MODULE == 0x1b or --on spawn select
                MODULE == 0x11 or --falling in dropdown entrance
                MODULE == 0x08 or --loading overworld
                MODULE == 0x0b or --special overworld areas
                MODULE == 0x06 or MODULE == 0x0f)) --transitioning into dungeons
                or owarea > 0x81 then --transitional OW IDs are ignored ie. 0x96
            owarea = 0xff
        end
    end

    if CACHE.OWAREA ~= owarea then
        if CACHE.OWAREA == 0xff then
            updateWorldFlagFromMemorySegment(nil)
        end

        CACHE.OWAREA = owarea

        if CACHE.OWAREA < 0xff and Tracker.ActiveVariantUID ~= "vanilla" and not INSTANCE.AUTOTRACKER_HAS_DONE_POST_GAME_SUMMARY then
            --OW Shuffle Autotracking
            if OBJ_OWSHUFFLE and OBJ_OWSHUFFLE:getState() > 0 then
                updateRoomSlots(CACHE.OWAREA + 0x1000)
            end

            --OW Mixed Autotracking
            if CACHE.OWAREA < 0x80 and OBJ_MIXED:getState() > 0 and not CONFIG.AUTOTRACKER_DISABLE_OWMIXED_TRACKING then
                if CACHE.OWAREA == 0 and MODULE ~= 0x09 then
                    print("NULL OW CASE NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL")
                    print("^ Module:", string.format("0x%02x", MODULE), "< REPORT THIS TO CODEMAN ^")
                end
                
                local swap = Tracker:FindObjectForCode("ow_swapped_" .. string.format("%02x", CACHE.OWAREA)).ItemState
                if not swap.modified then
                    CACHE.WORLD = AutoTracker:ReadU8(0x7ef3ca, 0)

                    local swapped = CACHE.OWAREA < CACHE.WORLD
                    swapped = swapped or (CACHE.OWAREA >= 0x40 and CACHE.WORLD == 0x00)
                    if OBJ_WORLDSTATE:getState() > 0 then
                        swapped = not swapped
                    end
                    swap:updateSwap(swapped and 1 or 0)
                    swap:updateItem()
                end
            end

            --Region Autotracking
            if (OBJ_ENTRANCE:getState() > 0 or OBJ_OWSHUFFLE:getState() > 0) and OBJ_RACEMODE:getState() == 0 and (not CONFIG.AUTOTRACKER_DISABLE_REGION_TRACKING) and Tracker.ActiveVariantUID == "full_tracker" then
                if CACHE.OWAREA < 0xff then
                    if DATA.OverworldIdRegionMap[CACHE.OWAREA] then
                        local region = Tracker:FindObjectForCode(DATA.OverworldIdRegionMap[CACHE.OWAREA])
                        if region then
                            region.Active = true
                        end
                    --TODO: Handle better with new mixed functionality
                    elseif CACHE.OWAREA < 0x80 and DATA.OverworldIdItemRegionMap[CACHE.OWAREA] then
                        local region = Tracker:FindObjectForCode(DATA.OverworldIdItemRegionMap[CACHE.OWAREA][1])
                        if not region.Active then
                            local swap = Tracker:FindObjectForCode("ow_swapped_" .. string.format("%02x", CACHE.OWAREA)).ItemState
                            if (not CONFIG.AUTOTRACKER_DISABLE_OWMIXED_TRACKING and ((CACHE.OWAREA < 0x40 and swap:getState() == 0) or (CACHE.OWAREA >= 0x40 and swap:getState() == 1))) or Tracker:FindObjectForCode('pearl').Active then
                                local canReach = true
                                if #DATA.OverworldIdItemRegionMap[CACHE.OWAREA][2] > 0 then
                                    for i, item in ipairs(DATA.OverworldIdItemRegionMap[CACHE.OWAREA][2]) do
                                        if Tracker:ProviderCountForCode(item) == 0 then
                                            canReach = false
                                            break
                                        end
                                    end
                                end
                                if canReach then
                                    region.Active = true
                                end
                            end
                        end
                    end  
                end
            end
        end

        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("CURRENT OW:", CACHE.OWAREA, string.format("0x%2X", CACHE.OWAREA))
        end
    end
end

function updateDungeonIdFromMemorySegment(segment)
    if not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: DungeonId")
    end

    if (segment) then
        CACHE.DUNGEON = segment:ReadUInt8(0x7e040c)
    else
        CACHE.DUNGEON = AutoTracker:ReadU8(0x7e040c, 0)
    end

    if CACHE.DUNGEON < 0xff then
        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("CURRENT DUNGEON:", DATA.DungeonIdMap[CACHE.DUNGEON], CACHE.DUNGEON, string.format("0x%2X", CACHE.DUNGEON))
        end

        --Set Door Dungeon Selector
        if Tracker.ActiveVariantUID ~= "vanilla" then
            OBJ_DOORDUNGEON:setState(DATA.DungeonData[DATA.DungeonIdMap[CACHE.DUNGEON]][2])
        end

        --Update Dungeon Image
        if CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_DUNGEON_IMAGE then
            if CONFIG.BROADCAST_ALTERNATE_LAYOUT == 2 then
                sendExternalMessage("dungeon", "er-" .. DATA.DungeonIdMap[CACHE.DUNGEON])
            else
                sendExternalMessage("dungeon", DATA.DungeonIdMap[CACHE.DUNGEON])
            end
        end

        --Auto-pin Dungeon Chests
        if Tracker.ActiveVariantUID == "full_tracker" and CONFIG.AUTOTRACKER_ENABLE_AUTOPIN_CURRENT_DUNGEON and OBJ_DOORSHUFFLE:getState() < 2 then
            for i = 0, 26, 2 do
                Tracker:FindObjectForCode(DATA.DungeonData[DATA.DungeonIdMap[i]][1]).Pinned = DATA.DungeonIdMap[i] == DATA.DungeonIdMap[CACHE.DUNGEON]
            end
        end
    end
end

function updateRoomIdFromMemorySegment(segment)
    if not isInGame() and CACHE.MODULE ~= 0x05 then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: RoomId")
    end

    CACHE.ROOM = segment:ReadUInt16(0x7e00a0)

    if OBJ_DOORSHUFFLE and OBJ_DOORSHUFFLE:getState() > 0 and CACHE.MODULE ~= 0x19 and CACHE.MODULE ~= 0x1a then
        updateRoomSlots(CACHE.ROOM)
    end

    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("CURRENT ROOM:", CACHE.ROOM, string.format("0x%4X", CACHE.ROOM))
        --print("CURRENT ROOM ORIGDUNGEON:", DATA.DungeonIdMap[DATA.RoomDungeons[CACHE.ROOM]], DATA.RoomDungeons[CACHE.ROOM], string.format("0x%2X", DATA.RoomDungeons[CACHE.ROOM]))
    end
end

DATA.MEMORY = {}
INSTANCE.MEMORY = {}

DATA.MEMORY.Items = {
    ["sword"] = { 0x7ef359, nil, 1 },
    ["shield"] = { 0x7ef35a, nil, 0 },
    ["armor"] = { 0x7ef35b, nil, 0 },
    ["gloves"] = { 0x7ef354, nil, 0 },
    ["mirror"] = { nil, nil, nil, updateProgressiveMirror },
    ["bottle"] = { nil, nil, nil, updateBottles },
    ["hookshot"] = { 0x7ef342 },
    ["bombs"] = { 0x7ef343 },
    ["firerod"] = { 0x7ef345 },
    ["icerod"] = { 0x7ef346 },
    ["bombos"] = { 0x7ef347 },
    ["ether"] = { 0x7ef348 },
    ["quake"] = { 0x7ef349 },
    ["lamp"] = { 0x7ef34a },
    ["hammer"] = { 0x7ef34b },
    ["net"] = { 0x7ef34d },
    ["book"] = { 0x7ef34e },
    ["somaria"] = { 0x7ef350 },
    ["byrna"] = { 0x7ef351 },
    ["cape"] = { 0x7ef352 },
    ["boots"] = { 0x7ef355 },
    ["flippers"] = { 0x7ef356 },
    ["pearl"] = { 0x7ef357 },

    ["bow"] = { nil, nil, nil, updateProgressiveBow },
    ["boomerang"] = { 0x7ef341, 0x01 },
    ["boomerang_red"] = { 0x7ef341, 0x02 },
    ["shovel"] = { 0x7ef34c, 0x01 },
    ["flute"] = { 0x7ef34c, 0x02 },
    ["mushroom"] = { 0x7ef344, 0x1 },
    ["powder"] = { 0x7ef344, 0x2 }
}

function updateItemsFromMemorySegment(segment)
    if not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Items")
    end

    for name, value in pairs(INSTANCE.MEMORY.Items) do
        local item = Tracker:FindObjectForCode(name)
        if item then
            if name == "bow" or #value == 2 then
                if Tracker.ActiveVariantUID == "vanilla" then
                    if name == "bow" then
                        value[4](segment)
                    else
                        if not item.Active or not STATUS.AutotrackerInGame then
                            item.Active = segment:ReadUInt8(value[1]) & value[2] > 0
        
                            if item.Active and STATUS.AutotrackerInGame then
                                if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                                    print("Item Got:", name)
                                end
                                itemFlippedOn(name)
                            end
                        end
                    end
                else
                    INSTANCE.MEMORY.Items[name] = nil
                end
            elseif #value == 4 then
                value[4](segment)
            elseif #value > 1 then
                local data = segment:ReadUInt8(value[1]) + value[3]
                if (item.CurrentStage >= value[3] or data > value[3]) and (data > item.CurrentStage or not STATUS.AutotrackerInGame) then
                    item.CurrentStage = data

                    if STATUS.AutotrackerInGame then
                        itemFlippedOn(name)
                    end
                end
            elseif name == "bombs" then
                local data = segment:ReadUInt8(value[1])
                if item.CurrentStage > 0 or data > 0 then
                    if item.CurrentStage == 0 and data > 0 and STATUS.AutotrackerInGame then
                        itemFlippedOn(name)
                    end
                    item.CurrentStage = data > 0 and 2 or 1
                end
            else
                local newStatus = segment:ReadUInt8(value[1]) > 0
                if not item.Active and newStatus and STATUS.AutotrackerInGame then
                    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                        print("Item Got:", name)
                    end
                    itemFlippedOn(name)
                end
                
                item.Active = newStatus
            end
        else
            print("Couldn't find item:", name)
        end
    end
end

DATA.MEMORY.ToggleItems = {
    ["bow"] =           { nil,      nil, updateProgressiveBow },
    ["flute"] =         { nil,      nil, updateFlute },
    ["boomerang"] =     { 0x7ef38c, 0x80 },
    ["boomerang_red"] = { 0x7ef38c, 0x40 },
    ["shovel"] =        { 0x7ef38c, 0x04 },
    ["mushroom"] =      { 0x7ef38c, 0x20 },
    ["powder"] =        { 0x7ef38c, 0x10 }
}

function updateToggleItemsFromMemorySegment(segment)
    if not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Toggle Items")
    end

    if Tracker.ActiveVariantUID ~= "vanilla" then
        for name, value in pairs(INSTANCE.MEMORY.ToggleItems) do
            local item = Tracker:FindObjectForCode(name)
            if item then
                if #value > 2 then
                    value[3](segment)
                elseif segment:ContainsAddress(value[1]) then
                    local itemActive = item.Active
                    item.Active = segment:ReadUInt8(value[1]) & value[2] > 0
    
                    if not itemActive and item.Active then
                        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                            print("Item Got:", name)
                        end
                        itemFlippedOn(name)
                    end
                end
            else
                print("Couldn't find item:", name)
            end
        end
    end
end

function updateHalfMagicFromMemorySegment(segment)
    if not isInGame() then
        return false
    end
    
    local value = segment:ReadUInt8(0x7ef37b)
    if value > 0 then
        local item = Tracker:FindObjectForCode("halfmagic")
        if value > item.CurrentStage or not STATUS.AutotrackerInGame then
            itemFlippedOn("halfmagic")
            item.CurrentStage = value
        end
    end
end

function updateHealthFromMemorySegment(segment)
    if not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Health")
    end
    
    if segment then
        local maxHealth = segment:ReadUInt8(0x7ef36c)
        local curHealth = segment:ReadUInt8(0x7ef36d)
        local stage = STATUS.HealthState
        local message = "dead"

        if curHealth > 0 then
            if curHealth == maxHealth then
                stage = 3
                message = "happy"
            elseif (maxHealth >= 0x78 and curHealth <= 0x18) or (maxHealth >= 0x40 and curHealth <= 0x10) or curHealth <= 0x08 then
                stage = 2
                message = "sad"
            else
                stage = 1
                message = "normal"
            end
        end

        if STATUS.HealthState ~= stage then
            STATUS.HealthState = stage
            sendExternalMessage("health", message)
        end
    end
end

DATA.MEMORY.Progress = {
    ["aga"] =                           { 0x7ef3c5, 0x03 },
    ["@Secret Passage/Uncle"] =         { 0x7ef3c6, 0x01 },
    ["@Hobo/Under The Bridge"] =        { 0x7ef3c9, 0x01 },
    ["@Bottle Vendor/This Jerk"] =      { 0x7ef3c9, 0x02 },
    ["@Purple Chest/Middle-Aged Man"] = { 0x7ef3c9, 0x10 }
}

function updateProgressFromMemorySegment(segment)
    if not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Progress")
    end

    for name, value in pairs(INSTANCE.MEMORY.Progress) do
        local item = Tracker:FindObjectForCode(name)
        if item then
            if string.sub(name, 1, 1) ~= "@" then
                if not item.Active or not STATUS.AutotrackerInGame then
                    item.Active = segment:ReadUInt8(value[1]) >= value[2]
                end

                if item.Active then
                    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                        print("Cleared:", name)
                    end
                end
            elseif not CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING and Tracker.ActiveVariantUID == "full_tracker" then
                if not item.Owner.ModifiedByUser then
                    if item.AvailableChestCount > 0 or not STATUS.AutotrackerInGame then
                        item.AvailableChestCount = (segment:ReadUInt8(value[1]) & value[2] == 0) and 1 or 0
                    end
                end
                if item.AvailableChestCount == 0 then
                    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                        print("Cleared:", name)
                    end
                    INSTANCE.MEMORY.Progress[name] = nil
                end
            end
        elseif Tracker.ActiveVariantUID == "items_only" then
            INSTANCE.MEMORY.Progress[name] = nil
        elseif CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING and Tracker.ActiveVariantUID == "full_tracker" then
            print("Couldn't find item:", name)
        end
    end
end

DATA.MEMORY.Overworld = {
    ["@Lost Woods Hideout Tree/Tree"] =                 { 0x00, 0x10 },
    ["@Spectacle Rock/Up On Top"] =                     { 0x03, 0x40 },
    ["@Floating Island/Island"] =                       { 0x05, 0x40 },
    ["@Death Mountain Bonk Rocks/Rock"] =               { 0x05, 0x10 },
    ["@Mountain Entry Pull Tree/Tree"] =                { 0x0a, 0x10 },
    ["@Mountain Entry Southeast Tree/Tree"] =           { 0x0a, 0x08 },
    ["@Lost Woods Pass West Tree/Tree"] =               { 0x10, 0x10 },
    ["@Kakariko Portal Tree/Tree"] =                    { 0x10, 0x08 },
    ["@Fortune Bonk Rocks/Rock"] =                      { 0x11, 0x10 },
    ["@Kakariko Pond Tree/Tree"] =                      { 0x12, 0x10 },
    ["@Bonk Rocks Tree/Tree"] =                         { 0x13, 0x10 },
    ["@Sanctuary Tree/Tree"] =                          { 0x13, 0x08 },
    ["@River Bend West Tree/Tree"] =                    { 0x15, 0x10 },
    ["@River Bend East Tree/Tree"] =                    { 0x15, 0x08 },
    ["@Blinds Hideout Tree/Tree"] =                     { 0x18, 0x10 },
    ["@Kakariko Welcome Tree/Tree"] =                   { 0x18, 0x08 },
    ["@Forgotten Forest Trees/Trees"] =                 { 0x1a, 0x18 },
    ["@Hyrule Castle Tree/Tree"] =                      { 0x1b, 0x10 },
    ["@Wooden Bridge Tree/Tree"] =                      { 0x1d, 0x10 },
    ["@Eastern Palace Tree/Tree"] =                     { 0x1e, 0x10 },
    ["@Race Game/Take This Trash"] =                    { 0x28, 0x40 },
    ["@Grove Digging Spot/Hidden Treasure"] =           { 0x2a, 0x40, updateShovelIndicatorStatus },
    ["@Flute Boy Trees/Trees"] =                        { 0x2a, 0x18 },
    ["@Central Bonk Rocks Tree/Tree"] =                 { 0x2b, 0x10 },
    ["@Tree Line Trees/Tree 2\\Tree 4"] =               { 0x2e, 0x1c },
    ["@Desert Ledge/Ledge"] =                           { 0x30, 0x40 },
    ["@Flute Boy Approach Trees/East Trees"] =          { 0x32, 0x18 },
    ["@Lake Hylia Island/Island"] =                     { 0x35, 0x40 },
    ["@Dam/Outside"] =                                  { 0x3b, 0x40 },
    ["@Sunken Treasure/Drain The Dam"] =                { 0x3b, 0x40 },
    ["@Dark Lumberjack Tree/Tree"] =                    { 0x42, 0x10 },
    ["@Bumper Ledge/Ledge"] =                           { 0x4a, 0x40 },
    ["@Dark Fortune Bonk Rocks/Rock"] =                 { 0x51, 0x18 },
    ["@Dark Graveyard Bonk Rocks/Rocks"] =              { 0x54, 0x1c },
    ["@Qirn Jump West Tree/Tree"] =                     { 0x55, 0x10 },
    ["@Qirn Jump East Tree/Tree"] =                     { 0x55, 0x08 },
    ["@Dark Witch Tree/Tree"] =                         { 0x56, 0x10 },
    ["@Pyramid Ledge/Ledge"] =                          { 0x5b, 0x40 },
    ["@Pyramid Tree/Tree"] =                            { 0x5b, 0x10 },
    ["@Palace of Darkness Tree/Tree"] =                 { 0x5e, 0x10 },
    ["@Digging Game/Dig For Treasure"] =                { 0x68, 0x40 },
    ["@Dark Tree Line Trees/Tree 2\\Tree 3\\Tree 4"] =  { 0x6e, 0x1c },
    ["@Hype Cave Statue/Statue"] =                      { 0x74, 0x10 },
    ["@Master Sword Pedestal/Pedestal"] =               { 0x80, 0x40 },
    ["@Zora's Domain/Ledge"] =                          { 0x81, 0x40 }
}

DATA.MEMORY.OverworldItems = {
    ["dam"] =   { 0x3b, 0x20, true, nil }
    --["bombs"] = { 0x5b, 0x02, nil, 1 } -- pyramid crack
}

function updateOverworldFromMemorySegment(segment)
    if CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID ~= "full_tracker" or not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Overworld")
    end

    for name, value in pairs(INSTANCE.MEMORY.Overworld) do
        local location = Tracker:FindObjectForCode(name)
        if location then
            if not location.Owner.ModifiedByUser then -- Do not auto-track this the user has manually modified it
                location.AvailableChestCount = location.ChestCount - numberOfSetBits(segment:ReadUInt8(0x7ef280 + value[1]) & value[2])
                
                if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING and location.AvailableChestCount == 0 then
                    print("Overworld Check:", name)
                end

                if #value > 2 then
                    value[3](location.AvailableChestCount == 0)
                end
            end

            if location.AvailableChestCount == 0 then
                INSTANCE.MEMORY.Overworld[name] = nil
            end
        else
            print("Couldn't find overworld:", name)
        end
    end

    if OBJ_RACEMODE:getState() > 0 then
        return true
    end

    for name, value in pairs(INSTANCE.MEMORY.OverworldItems) do
        local item = Tracker:FindObjectForCode(name)
        if item then
            local cleared = segment:ReadUInt8(0x7ef280 + value[1]) & value[2] > 0

            if value[3] then
                item.Active = cleared
            elseif value[4] ~= nil then
                item.CurrentStage = cleared and value[4] or item.CurrentStage
            end
            
            if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING and cleared then
                print("Overworld Check:", name)
            end

            if value[4] ~= nil and cleared then
                INSTANCE.MEMORY.OverworldItems[name] = nil
            end
        else
            print("Couldn't find overworld:", name)
        end
    end
end

DATA.MEMORY.Shops = {
    ["@Dark Death Mountain Shop/Items"] = { {0x7ef302, 0x7ef303, 0x7ef304}, 0xff },
    ["@Shield Shop/Items"] =              { {0x7ef305, 0x7ef306, 0x7ef307}, 0xff },
    ["@Dark Lake Shop/Items"] =           { {0x7ef308, 0x7ef309, 0x7ef30a}, 0xff },
    ["@Dark Lumberjack Shop/Items"] =     { {0x7ef30b, 0x7ef30c, 0x7ef30d}, 0xff },
    ["@Village of Outcasts Shop/Items"] = { {0x7ef30e, 0x7ef30f, 0x7ef310}, 0xff },
    ["@Dark Witch's Hut/Items"] =         { {0x7ef311, 0x7ef312, 0x7ef313}, 0xff },
    ["@Paradox Cave Shop/Items"] =        { {0x7ef314, 0x7ef315, 0x7ef316}, 0xff },
    ["@Kakariko Shop/Items"] =            { {0x7ef317, 0x7ef318, 0x7ef319}, 0xff },
    ["@Lake Shop/Items"] =                { {0x7ef31a, 0x7ef31b, 0x7ef31c}, 0xff },
    ["@Potion Shop/Items"] =              { {0x7ef31d, 0x7ef31e, 0x7ef31f}, 0xff },
    ["@Pond of Happiness/Items"] =        { {0x7ef320, 0x7ef321},           0xff }
}

function updateShopsFromMemorySegment(segment)
    if CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID ~= "full_tracker" or not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Shops")
    end

    offset = INSTANCE.NEW_SRAM_SYSTEM and 0x71b6 or 0

    for name, value in pairs(INSTANCE.MEMORY.Shops) do
        local location = Tracker:FindObjectForCode(name)
        if location then
            if not location.Owner.ModifiedByUser then -- Do not auto-track this the user has manually modified it
                local clearedCount = 0
                for i, slot in ipairs(value[1]) do
                    clearedCount = clearedCount + (segment:ReadUInt8(slot + offset) > 0 and 1 or 0)
                end
                
                if location.AvailableChestCount ~= location.ChestCount - clearedCount and CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                    print("Location checked: ", name, clearedCount)
                end

                location.AvailableChestCount = location.ChestCount - clearedCount
            end

            if location.AvailableChestCount == 0 then
                INSTANCE.MEMORY.Shops[name] = nil
            end
        else
            print("Couldn't find shop:", name)
        end
    end
end

DATA.MEMORY.Npc = {
    ["@Old Man/Bring Him Home"] =        { 0x0001 },
    ["@Zora's Domain/King Zora"] =       { 0x0002 },
    ["@Sick Kid/By The Bed"] =           { 0x0004 },
    ["@Stumpy/Farewell"] =               { 0x0008 },
    ["@Sahasrahla's Hut/Sahasrahla"] =   { 0x0010 },
    ["@Catfish/Ring of Stones"] =        { 0x0020 },
    ["@Library/On The Shelf"] =          { 0x0080 },
    ["@Ether Tablet/Tablet"] =           { 0x0100 },
    ["@Bombos Tablet/Tablet"] =          { 0x0200 },
    ["@Dwarven Smiths/Bring Him Home"] = { 0x0400 },
    ["@Mushroom Spot/Shroom"] =          { 0x1000 },
    ["@Potion Shop/Assistant"] =         { 0x2000 },
    ["@Magic Bat/Magic Bowl"] =          { 0x8000, updateBatIndicatorStatus }
}

function updateNPCFromMemorySegment(segment)
    if CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID ~= "full_tracker" or not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: NPC")
    end

    local data = segment:ReadUInt16(0x7ef410)

    for name, value in pairs(INSTANCE.MEMORY.Npc) do
        local location = Tracker:FindObjectForCode(name)
        if location then
            if not location.Owner.ModifiedByUser then -- Do not auto-track this the user has manually modified it
                local clearedCount = (data & value[1]) ~= 0 and 1 or 0
                if location.AvailableChestCount ~= location.ChestCount - clearedCount and CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                    print("Location cleared: ", name, clearedCount)
                end

                location.AvailableChestCount = location.ChestCount - clearedCount

                if #value > 1 then
                    value[2](location.AvailableChestCount == 0)
                end
            end

            if location.AvailableChestCount == 0 then
                INSTANCE.MEMORY.Npc[name] = nil
            end
        else
            print("Couldn't find location", name)
        end
    end
end

DATA.MEMORY.DungeonChests = {
    { {"@Hyrule Castle & Escape/First", "@HC Key Guard/Chest"}, {{114, 4}} },
    { {"@Hyrule Castle & Escape/Boomerang", "@HC Boomerang/Chest"}, {{113, 4}} },
    { {"@Hyrule Castle & Escape/Prison", "@HC Prison/Chest"}, {{128, 4}} },
    { {"@Hyrule Castle & Escape/Dark Cross", "@HC Dark Cross/Chest"}, {{50, 4}} },
    { {"@Hyrule Castle & Escape/Back", "@HC Back/Chest"}, {{17, 4}, {17, 5}, {17, 6}} },
    { {"@Hyrule Castle & Escape/Sanctuary", "@HC Sanctuary/Chest"}, {{18, 4}} },

    { {"@Eastern Palace/Cannonball Chest", "@EP Cannonball/Chest"}, {{185, 4}} },
    { {"@Eastern Palace/Hook Chest", "@EP Hook/Chest"}, {{170, 4}} },
    { {"@Eastern Palace/Stalfos Spawn", "@EP Stalfos Spawn/Chest"}, {{168, 4}} },
    { {"@Eastern Palace/Big Chest", "@EP Big Chest/Chest"}, {{169, 4}} },
    { {"@Eastern Palace/Big Key Chest", "@EP Big Key Chest/Chest"}, {{184, 4}} },
    { {"@Eastern Palace/Armos", "@EP Armos/Prize"}, {{200, 11}} },

    { {"@Desert Palace/Eyegore Switch", "@DP Eyegore Switch/Chest"}, {{116, 4}} },
    { {"@Desert Palace/Popo Chest", "@DP Popo Chest/Chest"}, {{133, 4}} },
    { {"@Desert Palace/Cannonball Chest", "@DP Cannonball/Chest"}, {{117, 4}} },
    { {"@Desert Palace/Torch", "@DP Torch/Torch"}, {{115, 10}} },
    { {"@Desert Palace/Big Chest", "@DP Big Chest/Chest"}, {{115, 4}} },
    { {"@Desert Palace/Lanmolas", "@DP Lanmolas/Prize"}, {{51, 11}} },

    { {"@Tower of Hera/Lobby", "@TH Lobby/Chest"}, {{119, 4}} },
    { {"@Tower of Hera/Cage", "@TH Cage/Item"}, {{135, 10}} },
    { {"@Tower of Hera/Basement", "@TH Basement/Chest"}, {{135, 4}} },
    { {"@Tower of Hera/Compass Chest", "@TH Compass Chest/Chest"}, {{39, 5}} },
    { {"@Tower of Hera/Big Chest", "@TH Big Chest/Chest"}, {{39, 4}} },
    { {"@Tower of Hera/Moldorm", "@TH Moldorm/Prize"}, {{7, 11}} },

    { {"@Agahnim's Tower/Lobby", "@AT Lobby/Chest"}, {{224, 4}} },
    { {"@Agahnim's Tower/Dark Chest", "@AT Dark Chest/Chest"}, {{208, 4}} },

    { {"@Palace of Darkness/Shooter Chest", "@PoD Shooter/Chest"}, {{9, 4}} },
    { {"@Palace of Darkness/Bow Side", "@PoD Bow Side/Chest"}, {{43, 4}} },
    { {"@Palace of Darkness/Arena Ledge", "@PoD Arena Ledge/Chest"}, {{42, 4}} },
    { {"@Palace of Darkness/Arena Chest", "@PoD Arena/Chest"}, {{42, 5}} },
    { {"@Palace of Darkness/Stalfos Basement", "@PoD Stalfos Basement/Chest"}, {{10, 4}} },
    { {"@Palace of Darkness/Big Key Chest", "@PoD Big Key Chest/Chest"}, {{58, 4}} },
    { {"@Palace of Darkness/Dark Maze", "@PoD Dark Maze/Chest"}, {{25, 4}, {25, 5}} },
    { {"@Palace of Darkness/Big Chest", "@PoD Big Chest/Chest"}, {{26, 4}} },
    { {"@Palace of Darkness/Turtle Room", "@PoD Turtle Room/Chest"}, {{26, 5}} },
    { {"@Palace of Darkness/Rupee Basement", "@PoD Rupee Basement/Chest"}, {{106, 4}, {106, 5}} },
    { {"@Palace of Darkness/Harmless Hellway", "@PoD Harmless Hellway/Chest"}, {{26, 6}} },
    { {"@Palace of Darkness/King Helmasaur", "@PoD King Helmasaur/Prize"}, {{90, 11}} },

    { {"@Swamp Palace/Entrance Chest", "@SP Entrance/Chest"}, {{40, 4}} },
    { {"@Swamp Palace/Bomb Wall", "@SP Bomb Wall/Chest"}, {{55, 4}} },
    { {"@Swamp Palace/South Side", "@SP South Side/Chest"}, {{70, 4}} },
    { {"@Swamp Palace/Far Left Chest", "@SP Far Left Chest/Chest"}, {{52, 4}} },
    { {"@Swamp Palace/Big Key Chest", "@SP Big Key Chest/Chest"}, {{53, 4}} },
    { {"@Swamp Palace/Big Chest", "@SP Big Chest/Chest"}, {{54, 4}} },
    { {"@Swamp Palace/Flooded Treasure", "@SP Flooded Treasure/Chest"}, {{118, 4}, {118, 5}} },
    { {"@Swamp Palace/Snake Waterfall", "@SP Snake Waterfall/Chest"}, {{102, 4}} },
    { {"@Swamp Palace/Arrghus", "@SP Arrghus/Prize"}, {{6, 11}} },

    { {"@Skull Woods/Map Chest", "@SW Map Chest/Chest"}, {{88, 5}} },
    { {"@Skull Woods/Gibdo Prison", "@SW Gibdo Prison/Chest"}, {{87, 5}} },
    { {"@Skull Woods/Compass Chest", "@SW Compass Chest/Chest"}, {{103, 4}} },
    { {"@Skull Woods/Pinball", "@SW Pinball/Chest"}, {{104, 4}} },
    { {"@Skull Woods/Statue Switch", "@SW Statue Switch/Chest"}, {{87, 4}} },
    { {"@Skull Woods/Big Chest", "@SW Big Chest/Chest"}, {{88, 4}} },
    { {"@Skull Woods/Bridge", "@SW Bridge/Chest"}, {{89, 4}} },
    { {"@Skull Woods/Mothula", "@SW Mothula/Prize"}, {{41, 11}} },

    { {"@Thieves Town/Main Lobby", "@TT Main Lobby/Chest"}, {{219, 4}} },
    { {"@Thieves Town/Ambush", "@TT Ambush/Chest"}, {{203, 4}} },
    { {"@Thieves Town/SE Lobby", "@TT SE Lobby/Chest"}, {{220, 4}} },
    { {"@Thieves Town/Big Key Chest", "@TT Big Key Chest/Chest"}, {{219, 5}} },
    { {"@Thieves Town/Attic Chest", "@TT Attic/Chest"}, {{101, 4}} },
    { {"@Thieves Town/Prison Cell", "@TT Prison Cell/Chest"}, {{69, 4}} },
    { {"@Thieves Town/Big Chest", "@TT Big Chest/Chest"}, {{68, 4}} },
    { {"@Thieves Town/Blind", "@TT Blind/Prize"}, {{172, 11}} },

    { {"@Ice Palace/Pengator Room", "@IP Pengator Room/Chest"}, {{46, 4}} },
    { {"@Ice Palace/Spike Room", "@IP Spike Room/Chest"}, {{95, 4}} },
    { {"@Ice Palace/Ice Breaker", "@IP Ice Breaker/Chest"}, {{31, 4}} },
    { {"@Ice Palace/Tongue Pull", "@IP Tongue Pull/Chest"}, {{63, 4}} },
    { {"@Ice Palace/Freezor Chest", "@IP Freezor/Chest"}, {{126, 4}} },
    { {"@Ice Palace/Ice T", "@IP Ice T/Chest"}, {{174, 4}} },
    { {"@Ice Palace/Big Chest", "@IP Big Chest/Chest"}, {{158, 4}} },
    { {"@Ice Palace/Kholdstare", "@IP Kholdstare/Prize"}, {{222, 11}} },

    { {"@Misery Mire/Spike Switch", "@MM Spike Room/Chest"}, {{179, 4}} },
    { {"@Misery Mire/Bridge", "@MM Bridge/Chest"}, {{162, 4}} },
    { {"@Misery Mire/Main Hub", "@MM Main Hub/Chest"}, {{194, 4}} },
    { {"@Misery Mire/Torch Tiles Chest", "@MM Torch Tiles/Chest"}, {{193, 4}} },
    { {"@Misery Mire/Torch Cutscene", "@MM Torch Cutscene/Chest"}, {{209, 4}} },
    { {"@Misery Mire/Right Blue Pegs Chest", "@MM Right Blue Pegs/Chest"}, {{195, 5}} },
    { {"@Misery Mire/Big Chest", "@MM Big Chest/Chest"}, {{195, 4}} },
    { {"@Misery Mire/Vitreous", "@MM Vitreous/Prize"}, {{144, 11}} },

    { {"@Turtle Rock/Compass Room", "@TR Compass Chest/Chest"}, {{214, 4}} },
    { {"@Turtle Rock/Roller Room", "@TR Roller Room/Chest"}, {{183, 4}, {183, 5}} },
    { {"@Turtle Rock/Chain Chomp", "@TR Chain Chomp/Chest"}, {{182, 4}} },
    { {"@Turtle Rock/Lava Chest", "@TR Lava/Chest"}, {{20, 4}} },
    { {"@Turtle Rock/Big Chest", "@TR Big Chest/Chest"}, {{36, 4}} },
    { {"@Turtle Rock/Crystaroller Chest", "@TR Crystaroller/Chest"}, {{4, 4}} },
    { {"@Turtle Rock/Laser Bridge", "@TR Laser Bridge/Chest"}, {{213, 4}, {213, 5}, {213, 6}, {213, 7}} },
    { {"@Turtle Rock/Trinexx", "@TR Trinexx/Prize"}, {{164, 11}} },

    { {"@Ganon's Tower/Hope Room", "@GT Hope Room/Chest"}, {{140, 5}, {140, 6}} },
    { {"@Ganon's Tower/Torch", "@GT Torch/Torch"}, {{140, 3}} },
    { {"@Ganon's Tower/Stalfos Room", "@GT Stalfos Room/Chest"}, {{123, 4}, {123, 5}, {123, 6}, {123, 7}} },
    { {"@Ganon's Tower/Map Chest", "@GT Map Chest/Chest"}, {{139, 4}} },
    { {"@Ganon's Tower/Firesnake", "@GT Firesnake/Chest"}, {{125, 4}} },
    { {"@Ganon's Tower/Rando Room", "@GT Rando Room/Chest"}, {{124, 4}, {124, 5}, {124, 6}, {124, 7}} },
    { {"@Ganon's Tower/Compass Room", "@GT Compass Room/Chest"}, {{157, 4}, {157, 5}, {157, 6}, {157, 7}} },
    { {"@Ganon's Tower/Bob", "@GT Bob/Chest"}, {{140, 7}} },
    { {"@Ganon's Tower/Ice Armos", "@GT Ice Armos/Chest"}, {{28, 4}, {28, 5}, {28, 6}} },
    { {"@Ganon's Tower/Tile Room", "@GT Tile Room/Chest"}, {{141, 4}} },
    { {"@Ganon's Tower/Big Chest", "@GT Big Chest/Chest"}, {{140, 4}} },
    { {"@Ganon's Tower/Mini Helmasaur", "@GT Mini Helmasaur/Chest"}, {{61, 4}, {61, 5}} },
    { {"@Ganon's Tower/Pre-Moldorm", "@GT Pre-Moldorm/Chest"}, {{61, 6}} },
    { {"@Ganon's Tower/Validation", "@GT Validation/Chest"}, {{77, 4}} }
}

DATA.MEMORY.DungeonEnemyKeys = {
    { {"@Hyrule Castle & Escape/Key Guard", "@HC Key Guard/Guard"}, {{114, 10}}, {{114, 15}} },
    { {"@Hyrule Castle & Escape/Boomerang Guard", "@HC Boomerang/Guard"}, {{113, 10}}, {{113, 14}} },
    { {"@Hyrule Castle & Escape/Ball 'N Chain Guard", "@HC Ball 'N Chain/Guard"}, {{128, 10}}, {{128, 13}} },
    { {"@Hyrule Castle & Escape/Key Rat", "@HC Key Rat/Rat"}, {{33, 10}}, {{33, 15}} },

    { {"@Eastern Palace/Dark Eyegore", "@EP Dark Eyegore/Eyegore"}, {{153, 10}}, {{153, 12}} },

    { {"@Agahnim's Tower/Bow Guard", "@AT Bow Guard/Guard"}, {{192, 10}}, {{192, 12}} },
    { {"@Agahnim's Tower/Circle of Pots Key", "@AT Circle of Pots/Guard"}, {{176, 10}}, {{176, 5}} },

    { {"@Skull Woods/Gibdo Key", "@SW Gibdo/Gibdo"}, {{57, 10}}, {{57, 14}} },

    { {"@Ice Palace/Lobby Key", "@IP Lobby/Bari"}, {{14, 10}}, {{14, 12}} },
    { {"@Ice Palace/Conveyor Key", "@IP Conveyor/Bari"}, {{62, 10}}, {{62, 7}} },
    
    { {"@Misery Mire/Conveyor Jelly", "@MM Conveyor Switch/Bari"}, {{193, 10}}, {{193, 6}} },

    { {"@Turtle Rock/Chain Chomp Pokey", "@TR Chain Chomp/Pokey"}, {{182, 10}}, {{182, 10}} },
    { {"@Turtle Rock/Lava Pokey", "@TR Lava Pokey/Pokey"}, {{19, 10}}, {{19, 9}} },

    { {"@Ganon's Tower/Mini Helmasaur Key", "@GT Mini Helmasaur/Mini Helmasaur"}, {{61, 10}}, {{61, 13}} }
}

DATA.MEMORY.DungeonPotKeys = {
    { {"@Eastern Palace/Dark Pot Key", "@EP Dark Pot/Pot"}, {{186, 10}}, {{186, 11}} },
    
    { {"@Desert Palace/Back Lobby Key", "@DP Back Lobby/Pot"}, {{99, 10}}, {{99, 10}} },
    { {"@Desert Palace/Beamos Hall Key", "@DP Beamos Hall/Pot"}, {{83, 10}}, {{83, 13}} },
    { {"@Desert Palace/Back Tiles Key", "@DP Back Tiles/Pot"}, {{67, 10}}, {{67, 8}} },

    { {"@Swamp Palace/Pot Row Key", "@SP Pot Row/Pot"}, {{56, 10}}, {{56, 12}} },
    { {"@Swamp Palace/Front Flood Key", "@SP Front Flood Pot/Pot"}, {{55, 10}}, {{55, 15}} },
    { {"@Swamp Palace/Hookshot Key", "@SP Hookshot Pot/Pot"}, {{54, 10}}, {{54, 11}} },
    { {"@Swamp Palace/Left Flood Key", "@SP Left Flood Pot/Pot"}, {{53, 10}}, {{53, 15}} },
    { {"@Swamp Palace/Waterway Key", "@SP Waterway/Pot"}, {{22, 10}}, {{22, 7}} },

    { {"@Skull Woods/West Lobby Key", "@SW West Lobby/Pot"}, {{86, 10}}, {{86, 2}} },

    { {"@Thieves Town/Hallway Key", "@TT Hallway/Pot"}, {{188, 10}}, {{188, 14}} },
    { {"@Thieves Town/Spike Switch Key", "@TT Spike Switch/Pot"}, {{171, 10}}, {{171, 15}} },

    { {"@Ice Palace/Boulder Key", "@IP Tongue Pull/Boulder"}, {{63, 10}}, {{63, 9}} },
    { {"@Ice Palace/Ice Hell Key", "@IP Hell on Ice/Pot"}, {{159, 10}}, {{159, 11}} },

    { {"@Misery Mire/Spike Key", "@MM Spike Room/Pot"}, {{179, 10}}, {{179, 15}} },
    { {"@Misery Mire/Fishbone Key", "@MM Fishbone Room/Pot"}, {{161, 10}}, {{161, 15}} },

    { {"@Ganon's Tower/Conveyor Bumper Key", "@GT Conveyor Bumper/Pot"}, {{139, 10}}, {{139, 14}} },
    { {"@Ganon's Tower/Double Switch Key", "@GT Double Switch/Pot"}, {{155, 10}}, {{155, 14}} },
    { {"@Ganon's Tower/Post-Compass Key", "@GT Post-Compass/Pot"}, {{123, 10}}, {{123, 11}} }
}

DATA.MEMORY.DungeonPotDrops = {

}

DATA.MEMORY.CavePotDrops = {
    { "@Lumberjack House/Pots",           {{0x11f, {14, 15}}} },
    { "@Death Mountain Descent/Pots",     {{0xe6,  {12, 13, 14, 15}}, {0xe7, {14, 15}}} },
    { "@Old Man/Pot",                     {{0xf1,  {15}}} },
    { "@Old Man Home/West Pots",          {{0xe4,  {14, 15}}} },
    { "@Old Man Home/Dark Pots",          {{0xe5,  {12, 13, 14, 15}}} },
    { "@Fairy Ascension/Fairy Pots",      {{0xfd,  {14, 15}}} },
    { "@Fairy Ascension/Superbunny Pots", {{0xfd,  {12, 13}}} },
    { "@Hookshot Fairy Cave/Pot",         {{0x10c, {15}}} },
    { "@Paradox Cave/Bomb Wall Pots",     {{0xff,  {14, 15}}} },
    { "@Paradox Cave/Block Pot",          {{0xff,  {13}}} },
    { "@Graveyard Ledge/Pots",            {{0x11b, {2, 3, 4, 5, 6, 7, 8, 9}}} },
    { "@Kakariko Well/Bomb Wall Pots",    {{0x2f,  {12, 13, 14, 15}}} },
    { "@Kakariko Well/Chest Pots",        {{0x2f,  {10, 11}}} },
    { "@Kakariko Well/Exit Pots",         {{0x2f,  {8, 9}}} },
    { "@Blind's House/Entry Pots",        {{0x119, {12, 13, 14, 15}}} },
    { "@Blind's House/Bomb Wall Pots",    {{0x11d, {10, 11, 12, 13, 14, 15}}} },
    { "@Elder House/Pots",                {{0xf3,  {13, 14, 15}}} },
    { "@Left Snitch House/Pots",          {{0x101, {13, 14}}} },
    { "@Right Snitch House/Pot",          {{0x101, {15}}} },
    { "@Chicken House/Pot",               {{0x108, {15}}} },
    { "@Sick Kid/Pots",                   {{0x102, {14, 15}}} },
    { "@Bomb Hut/Pots",                   {{0x107, {8, 9, 10, 11, 12, 13, 14, 15}}} },
    { "@Tavern/Back Pots",                {{0x103, {14, 15}}} },
    { "@Tavern/Front Pot",                {{0x103, {13}}} },
    { "@Secret Passage/Pots",             {{0x55,  {14, 15}}} },
    { "@Sahasrahla's Hut/Pots",           {{0x105, {13, 14, 15}}} },
    { "@Magic Bat/Pots",                  {{0xe3,  {14, 15}}} },
    { "@Link's House/Pots",               {{0x104, {13, 14, 15}}} },
    { "@Cave 45/Pots",                    {{0x11b, {10, 11, 12, 13, 14, 15}}} },
    { "@Twenty Rupee Cave/Pots",          {{0x125, {12, 13, 14, 15}}} },
    { "@Fifty Rupee Cave/Pots",           {{0x124, {6, 7, 8, 9, 10, 11, 12, 13, 14, 15}}} },
    { "@Spike Cave/Boulder",              {{0x117, {7}}} },
    { "@Spike Cave/Pots",                 {{0x117, {8, 9, 10, 11, 12, 13, 14, 15}}} },
    { "@Hookshot Cave/Front Pot",         {{0x3c,  {10}}} },
    { "@Hookshot Cave/Bonk Pots",         {{0x3c,  {8, 9, 11}}} },
    { "@Hookshot Cave/Hook Pots",         {{0x3c,  {12, 13, 14, 15}}} },
    { "@Hookshot Cave/Back Pots",         {{0x2c,  {14, 15}}} },
    { "@Superbunny Cave/Pots",            {{0xe8,  {15}}, {0xf8, {15}}} },
    { "@Bumper Cave/Pots",                {{0xeb,  {11, 12, 13, 14, 15}}} },
    { "@Brewery/Pot",                     {{0x106, {15}}} },
    { "@Dark Sahasrahla/Pots",            {{0x11a, {12, 13, 14, 15}}} },
    { "@Hammer Pegs/Pots",                {{0x127, {12, 13, 14, 15} }} },
    { "@Mire Hint Cave/Pots",             {{0x114, {10, 11, 12, 13, 14, 15}}} },
    { "@Spike Hint Cave/Pots",            {{0x125, {8, 9, 10, 11}}} }
}

DATA.MEMORY.Bosses = {
    { "ep",  {200, 11} },
    { "dp",  {51, 11} },
    { "toh", {7, 11} },
    { "pod", {90, 11} },
    { "sp",  {6, 11} },
    { "sw",  {41, 11} },
    { "tt",  {172, 11} },
    { "ip",  {222, 11} },
    { "mm",  {144, 11} },
    { "tr",  {164, 11} }
}

DATA.MEMORY.BossLocations = {
    "@Eastern Palace/Armos",
    "@Desert Palace/Lanmolas",
    "@Tower of Hera/Moldorm",
    "@Palace of Darkness/King Helmasaur",
    "@Swamp Palace/Arrghus",
    "@Skull Woods/Mothula",
    "@Thieves Town/Blind",
    "@Ice Palace/Kholdstare",
    "@Misery Mire/Vitreous",
    "@Turtle Rock/Trinexx"
}

DATA.MEMORY.Underworld = {
    { {"@Kakariko Well/Cave"},           {{47, 5}, {47, 6}, {47, 7}, {47, 8}} },
    { {"@Kakariko Well/Bombable Wall"},  {{47, 4}} },
    { {"@Hookshot Cave/Bonkable Chest"}, {{60, 7}} },
    { {"@Hookshot Cave/Back"},           {{60, 4}, {60, 5}, {60, 6}} },
    { {"@Secret Passage/Hallway"},       {{85, 4}} },
    { {"@Forest Hideout/Stash"},         {{225, 9, 4}},              0x00 },
    { {"@Lumberjack Cave/Cave"},         {{226, 9}} },
    { {"@Spectacle Rock/Cave"},          {{234, 10, 2}} },
    { {"@Paradox Cave/Top"},             {{239, 4}, {239, 5}, {239, 6}, {239, 7}, {239, 8}} },
    { {"@Superbunny Cave/Cave"},         {{248, 4}, {248, 5}} },
    { {"@Spiral Cave/Cave"},             {{254, 4}} },
    { {"@Paradox Cave/Bottom"},          {{255, 4}, {255, 5}} },
    { {"@Tavern/Back Room"},             {{259, 4}} },
    { {"@Link's House/By The Door"},     {{260, 4}} },
    { {"@Sahasrahla's Hut/Closet"},      {{261, 4}, {261, 5}, {261, 6}} },
    { {"@Brewery/Downstairs"},           {{262, 4}} },
    { {"@Chest Game/Prize"},             {{262, 10}} },
    { {"@Chicken House/Bombable Wall"},  {{264, 4}} },
    { {"@Aginah's Cave/Cave"},           {{266, 4}} },
    { {"@Dam/Inside"},                   {{267, 4}} },
    { {"@Mimic Cave/Cave"},              {{268, 4}} },
    { {"@Mire Shed/Shed"},               {{269, 4}, {269, 5}} },
    { {"@King's Tomb/The Crypt"},        {{275, 4}} },
    { {"@Waterfall Fairy/Cave"},         {{276, 4}, {276, 5}} },
    { {"@Pyramid Fairy/Big Bomb Spot"},  {{278, 4}, {278, 5}} },
    { {"@Spike Cave/Cave"},              {{279, 4}} },
    { {"@Graveyard Ledge/Cave"},         {{283, 9, 8}},              0x14 },
    { {"@Cave 45/Circle of Bushes"},     {{283, 10}} }, --2, Game is bugged and uses the same sub-room slot as the front part of Graveyard Ledge
    { {"@C-Shaped House/House"},         {{284, 4}} },
    { {"@Blind's House/Basement"},       {{285, 5}, {285, 6}, {285, 7}, {285, 8}} },
    { {"@Blind's House/Bombable Wall"},  {{285, 4}} },
    { {"@Hype Cave/Cave"},               {{286, 4}, {286, 5}, {286, 6}, {286, 7}, {286, 10}} },
    { {"@Ice Rod Cave/Cave"},            {{288, 4}} },
    { {"@Mini Moldorm Cave/Cave"},       {{291, 4}, {291, 5}, {291, 6}, {291, 7}, {291, 10}} },
    { {"@Bonk Rocks/Cave"},              {{292, 4}} },
    { {"@Checkerboard Cave/Cave"},       {{294, 9, 1}} },
    { {"@Hammer Pegs/Cave"},             {{295, 10, 2}} }
}

DATA.MEMORY.UnderworldItems = {
    { "attic",         0x7ef0cb, 0x01, false },
    { "aga2",          0x7ef01b, 0x08, true },
    { "mushroom_used", 0x7ef212, 0x80, true }
}

DATA.MEMORY.DungeonFlags = {
    --          enemy drops                                  pot keys                                            doors
    ["hc"] =  { {{114, 10}, {113, 10}, {128, 10}, {33, 10}}, nil,                                                {{114, 15}, {113, 15}, {50, 15, 34, 15}, {17, 13, 33, 15}} },
    ["ep"] =  { {{153, 10}},                                 {{186, 10}},                                        {{186, 15, 185, 15}, {153, 15}} },
    ["dp"] =  { nil,                                         {{99, 10}, {83, 10}, {67, 10}},                     {{133, 14}, {99, 15}, {83, 13, 67, 13}, {67, 14}} },
    ["toh"] = { nil,                                         nil,                                                {{119, 15}} },
    ["at"] =  { {{192, 10}, {176, 10}},                      nil,                                                {{224, 13}, {208, 15}, {192, 13}, {176, 13}}},
    ["pod"] = { nil,                                         nil,                                                {{74, 13, 58, 15}, {10, 15}, {42, 14, 26, 12}, {26, 14, 25, 14}, {26, 15}, {11, 13}} },
    ["sp"] =  { nil,                                         {{56, 10}, {55, 10}, {54, 10}, {53, 10}, {22, 10}}, {{40, 15}, {56, 14, 55, 12}, {55, 13}, {54, 13, 53, 15}, {54, 14, 38, 15}, {22, 14}} },
    ["sw"] =  { {{57, 10}},                                  {{86, 10}},                                         {{87, 13, 88, 14}, {104, 14, 88, 13}, {86, 15}, {89, 15, 73, 13}, {57, 14}} },
    ["tt"] =  { nil,                                         {{188, 10}, {171, 10}},                             {{188, 15}, {171, 15}, {68, 14}} },
    ["ip"] =  { {{14, 10}, {62, 10}},                        {{63, 10}, {159, 10}},                              {{14, 15}, {62, 14, 78, 14}, {94, 15, 95, 15}, {126, 15, 142, 15}, {158, 15}, {190, 14, 191, 15}} },
    ["mm"] =  { {{193, 10}},                                 {{179, 10}, {161, 10}},                             {{179, 15}, {194, 14, 193, 14}, {193, 15}, {194, 15, 195, 15}, {161, 15, 177, 14}, {147, 14}} },
    ["tr"] =  { {{182, 10}, {19, 10}},                       nil,                                                {{198, 15, 182, 13}, {182, 12}, {182, 15}, {19, 15, 20, 14}, {4, 15}, {197, 15, 196, 15}} },
    ["gt"] =  { {{61, 10}},                                  {{139, 10}, {155, 10}, {123, 10}},                  {{140, 13}, {139, 14}, {155, 15}, {125, 13}, {141, 14}, {123, 14, 124, 13}, {61, 14}, {61, 13, 77, 15}} }
}

function updateRoomsFromMemorySegment(segment)
    if not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Rooms")
    end

    --Dungeon Data
    if Tracker.ActiveVariantUID ~= "vanilla" then
        for dungeonPrefix, data in pairs(DATA.MEMORY.DungeonFlags) do
            --Doors Opened
            if OBJ_DOORSHUFFLE:getState() == 0 then
                updateDoorKeyCountFromRoomSlotList(segment, dungeonPrefix .. "_door", data[3])
            end

            if not INSTANCE.NEW_POTDROP_SYSTEM then
                --Enemy Keys
                if data[1] then
                    updateDoorKeyCountFromRoomSlotList(segment, dungeonPrefix .. "_enemykey", data[1])
                end

                --Pot Keys
                if data[2] then
                    updateDoorKeyCountFromRoomSlotList(segment, dungeonPrefix .. "_potkey", data[2])
                end
            end
        end
    end

    for i, boss in ipairs(INSTANCE.MEMORY.Bosses) do
        local bossflag = segment:ReadUInt16(0x7ef000 + (boss[2][1] * 2)) & (1 << boss[2][2])
        local item = Tracker:FindObjectForCode(boss[1])
        if item and OBJ_GLITCHMODE:getState() < 3 and not INSTANCE.NEW_SRAM_SYSTEM then
            item.Active = bossflag > 0
        end

        if INSTANCE.MEMORY.BossLocations[i] and not CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING and Tracker.ActiveVariantUID ~= "vanilla" then
            item = Tracker:FindObjectForCode(INSTANCE.MEMORY.BossLocations[i])
            if item then
                item.AvailableChestCount = bossflag == 0 and 1 or 0
                
                if item.AvailableChestCount == 0 then
                    INSTANCE.MEMORY.BossLocations[i] = nil

                    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                        print("Boss Defeated:", INSTANCE.MEMORY.BossLocations[i])
                    end
                end
            else
                print("Couldn't find location", item)
            end
        end
    end

    if CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID == "vanilla" then
        return true
    end

    if OBJ_RACEMODE:getState() == 0 then
        --Dungeon Chests
        updateDungeonChestCountFromRoomSlotList(segment, "hc", {{114, 4}, {113, 4}, {128, 4}, {50, 4}, {17, 4}, {17, 5}, {17, 6}, {18, 4}})
        updateDungeonChestCountFromRoomSlotList(segment, "ep", {{185, 4}, {170, 4}, {168, 4}, {169, 4}, {184, 4}, {200, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "dp", {{115, 4}, {115, 10}, {116, 4}, {133, 4}, {117, 4}, {51, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "toh", {{135, 10}, {119, 4}, {135, 4}, {39, 4}, {39, 5}, {7, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "at", {{224, 4}, {208, 4}})
        updateDungeonChestCountFromRoomSlotList(segment, "pod", {{9, 4}, {43, 4}, {42, 4}, {42, 5}, {58, 4}, {10, 4}, {26, 4}, {26, 5}, {26, 6}, {25, 4},  {25, 5}, {106, 4}, {106, 5}, {90, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "sp", {{40, 4}, {55, 4}, {54, 4}, {53, 4}, {52, 4}, {70, 4}, {118, 4}, {118, 5}, {102, 4}, {6, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "sw", {{103, 4}, {104, 4}, {87, 4}, {87, 5}, {88, 4}, {88, 5}, {89, 4}, {41, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "tt", {{219, 4}, {219, 5}, {203, 4}, {220, 4}, {101, 4}, {69, 4}, {68, 4}, {172, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "ip", {{46, 4}, {63, 4}, {31, 4}, {95, 4}, {126, 4}, {174, 4}, {158, 4}, {222, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "mm", {{162, 4}, {179, 4}, {194, 4}, {193, 4}, {209, 4}, {195, 4}, {195, 5}, {144, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "tr", {{214, 4}, {183, 4}, {183, 5}, {182, 4}, {20, 4}, {36, 4}, {4, 4}, {213, 4}, {213, 5}, {213, 6}, {213, 7}, {164, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "gt", {{140, 10}, {123, 4}, {123, 5}, {123, 6}, {123, 7}, {139, 4}, {125, 4}, {124, 4}, {124, 5}, {124, 6}, {124, 7}, {140, 4}, {140, 5}, {140, 6}, {140, 7}, {28, 4}, {28, 5}, {28, 6}, {141, 4}, {157, 4}, {157, 5}, {157, 6}, {157, 7}, {61, 4}, {61, 5}, {61, 6}, {77, 4}})

        --Keysanity Dungeon Map Locations
        local i = 1
        while i <= #INSTANCE.MEMORY.DungeonChests do
            if updateRoomLocation(segment, INSTANCE.MEMORY.DungeonChests[i]) then
                table.remove(INSTANCE.MEMORY.DungeonChests, i)
            else
                i = i + 1
            end
        end

        --Key Drop Locations
        if OBJ_POOL_ENEMYDROP and OBJ_POOL_ENEMYDROP:getState() > 0 then
            if not INSTANCE.NEW_POTDROP_SYSTEM then
                i = 1
                while i <= #INSTANCE.MEMORY.DungeonEnemyKeys do
                    if updateRoomLocation(segment, INSTANCE.MEMORY.DungeonEnemyKeys[i]) then
                        table.remove(INSTANCE.MEMORY.DungeonEnemyKeys, i)
                    else
                        i = i + 1
                    end
                end
            end
        end
        if OBJ_POOL_DUNGEONPOT and OBJ_POOL_DUNGEONPOT:getState() > 0 then
            if not INSTANCE.NEW_POTDROP_SYSTEM then
                i = 1
                while i <= #INSTANCE.MEMORY.DungeonPotKeys do
                    if updateRoomLocation(segment, INSTANCE.MEMORY.DungeonPotKeys[i]) then
                        table.remove(INSTANCE.MEMORY.DungeonPotKeys, i)
                    else
                        i = i + 1
                    end
                end
            end
        end

        --Refresh Dungeon Calc
        if OBJ_GLITCHMODE:getState() < 2 then
            updateChestCountFromDungeon(nil, DATA.DungeonIdMap[CACHE.DUNGEON], nil)
        else
            for i, dungeonPrefix in ipairs(DATA.DungeonList) do
                updateChestCountFromDungeon(nil, dungeonPrefix, nil)
            end
        end
    end

    --Miscellaneous
    for i, value in ipairs(INSTANCE.MEMORY.UnderworldItems) do
        local remove = false
        if value[4] or OBJ_RACEMODE:getState() == 0 then
            local roomData = segment:ReadUInt16(value[2])

            if (roomData & value[3]) ~= 0 then
                Tracker:FindObjectForCode(value[1]).Active = true
                
                if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                    print("Obtained:", value[1])
                end
            end
        end
    end

    --Underworld Locations
    local i = 1
    while i <= #INSTANCE.MEMORY.Underworld do
        if updateRoomLocation(segment, INSTANCE.MEMORY.Underworld[i]) then
            table.remove(INSTANCE.MEMORY.Underworld, i)
        else
            i = i + 1
        end
    end
end

DATA.MEMORY.NewDropData = {
    --          enemy drops                                  pot keys
    ["hc"] =  { {{114, 15}, {113, 14}, {128, 13}, {33, 15}}, nil },
    ["ep"] =  { {{153, 12}},                                 {{186, 11}} },
    ["dp"] =  { nil,                                         {{99, 10}, {83, 13}, {67, 8}} },
    ["toh"] = { nil,                                         nil },
    ["at"] =  { {{192, 12}, {176, 5}},                       nil },
    ["pod"] = { nil,                                         nil },
    ["sp"] =  { nil,                                         {{56, 12}, {55, 15}, {54, 11}, {53, 15}, {22, 7}} },
    ["sw"] =  { {{57, 14}},                                  {{86, 2}} },
    ["tt"] =  { nil,                                         {{188, 14}, {171, 15}} },
    ["ip"] =  { {{14, 12}, {62, 7}},                         {{63, 9}, {159, 11}} },
    ["mm"] =  { {{193, 6}},                                  {{179, 15}, {161, 15}} },
    ["tr"] =  { {{182, 10}, {19, 9}},                        nil },
    ["gt"] =  { {{61, 13}},                                  {{139, 14}, {155, 14}, {123, 11}} }
}

function updateRoomEnemiesFromMemorySegment(segment)
    if CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID == "vanilla" or not INSTANCE.NEW_POTDROP_SYSTEM or not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Room Enemies")
    end

    --Enemy Keys
    for dungeonPrefix, data in pairs(DATA.MEMORY.NewDropData) do
        if data[1] then
            updateDoorKeyCountFromRoomSlotList(segment, dungeonPrefix .. "_enemykey", data[1], INSTANCE.VERSION_MINOR < 2 and 0x7850 or 0x7268)
        end
    end

    if OBJ_RACEMODE:getState() == 0 then
        --Enemy Key Drop Locations
        if OBJ_POOL_ENEMYDROP and OBJ_POOL_ENEMYDROP:getState() > 0 then
            i = 1
            while i <= #INSTANCE.MEMORY.DungeonEnemyKeys do
                if updateRoomLocation(segment, INSTANCE.MEMORY.DungeonEnemyKeys[i], INSTANCE.VERSION_MINOR < 2 and 0x7850 or 0x7268) then
                    table.remove(INSTANCE.MEMORY.DungeonEnemyKeys, i)
                else
                    i = i + 1
                end
            end
        end

        --Refresh Dungeon Calc
        if OBJ_GLITCHMODE:getState() < 2 then
            updateChestCountFromDungeon(nil, DATA.DungeonIdMap[CACHE.DUNGEON], nil)
        else
            for i, dungeonPrefix in ipairs(DATA.DungeonList) do
                updateChestCountFromDungeon(nil, dungeonPrefix, nil)
            end
        end
    end
end

function updateRoomPotsFromMemorySegment(segment)
    if CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID == "vanilla" or not INSTANCE.NEW_POTDROP_SYSTEM or not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Room Pots")
    end

    --Pot Keys
    for dungeonPrefix, data in pairs(DATA.MEMORY.NewDropData) do
        if data[2] then
            updateDoorKeyCountFromRoomSlotList(segment, dungeonPrefix .. "_potkey", data[2], INSTANCE.VERSION_MINOR < 2 and 0x7600 or 0x7018)
        end
    end

    --Cave Pot Drop Locations
    if OBJ_POOL_CAVEPOT and OBJ_POOL_CAVEPOT:getState() > 0 then
        i = 1
        while i <= #INSTANCE.MEMORY.CavePotDrops do
            if updateRoomLocation(segment, INSTANCE.MEMORY.CavePotDrops[i], INSTANCE.VERSION_MINOR < 2 and 0x7600 or 0x7018) then
                table.remove(INSTANCE.MEMORY.CavePotDrops, i)
            else
                i = i + 1
            end
        end
    end

    if OBJ_RACEMODE:getState() == 0 then
        if OBJ_POOL_DUNGEONPOT and OBJ_POOL_DUNGEONPOT:getState() > 0 then
            --Key Pot Locations
            i = 1
            while i <= #INSTANCE.MEMORY.DungeonPotKeys do
                if updateRoomLocation(segment, INSTANCE.MEMORY.DungeonPotKeys[i], INSTANCE.VERSION_MINOR < 2 and 0x7600 or 0x7018) then
                    table.remove(INSTANCE.MEMORY.DungeonPotKeys, i)
                else
                    i = i + 1
                end
            end

            --Dungeon Pot Drop Locations
            if OBJ_POOL_DUNGEONPOT:getState() > 1 then
                i = 1
                while i <= #INSTANCE.MEMORY.DungeonPotDrops do
                    if updateRoomLocation(segment, INSTANCE.MEMORY.DungeonPotDrops[i], INSTANCE.VERSION_MINOR < 2 and 0x7600 or 0x7018) then
                        table.remove(INSTANCE.MEMORY.DungeonPotDrops, i)
                    else
                        i = i + 1
                    end
                end
            end
        end

        --Refresh Dungeon Calc
        if OBJ_GLITCHMODE:getState() < 2 then
            updateChestCountFromDungeon(nil, DATA.DungeonIdMap[CACHE.DUNGEON], nil)
        else
            for i, dungeonPrefix in ipairs(DATA.DungeonList) do
                updateChestCountFromDungeon(nil, dungeonPrefix, nil)
            end
        end
    end
end

function updateTempDoorsFromMemorySegment(segment)
    if INSTANCE.NEW_KEY_SYSTEM or OBJ_DOORSHUFFLE:getState() > 0 or CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID == "vanilla" or not isInGame() then
        return false
    end

    CACHE.DUNGEON = AutoTracker:ReadU8(0x7e040c, 0)
    if CACHE.DUNGEON < 0xff then
        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("Segment: Temp Doors")
        end

        CACHE.ROOM = AutoTracker:ReadU16(0x7e00a0, 0)
        if CACHE.ROOM > 0 then
            local dungeonPrefix = DATA.RoomDungeons[CACHE.ROOM]
            if dungeonPrefix then
                dungeonPrefix = DATA.DungeonIdMap[dungeonPrefix]
                local value = segment:ReadUInt8(0x7e0400) << 8
                
                if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                    print(dungeonPrefix, string.format("0x%2X:", CACHE.ROOM), string.format("0x%2X", value))
                end

                if updateDoorKeyFromTempRoom(dungeonPrefix .. "_door", DATA.MEMORY.DungeonFlags[dungeonPrefix][3], value) then
                    --Refresh Dungeon Calc
                    updateChestCountFromDungeon(nil, dungeonPrefix, nil)
                end
            end
        end
    end
end

function updateTempRoomFromMemorySegment(segment)
    if INSTANCE.NEW_POTDROP_SYSTEM or CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID == "vanilla" or OBJ_DOORSHUFFLE:getState() > 0 or not isInGame() then
        return false
    end
    
    CACHE.DUNGEON = AutoTracker:ReadU8(0x7e040c, 0)
    if CACHE.DUNGEON < 0xff then
        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("Segment: Temp Room")
        end

        CACHE.ROOM = AutoTracker:ReadU16(0x7e00a0, 0)
        if CACHE.ROOM > 0 then
            local dungeonPrefix = DATA.RoomDungeons[CACHE.ROOM]
            if dungeonPrefix then
                dungeonPrefix = DATA.DungeonIdMap[dungeonPrefix]
                local value = segment:ReadUInt8(0x7e0403) << 4
                
                if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                    print(dungeonPrefix, string.format("0x%2X:", CACHE.ROOM), string.format("0x%2X", value))
                end

                local modified = updateDoorKeyFromTempRoom(dungeonPrefix .. "_enemykey", DATA.MEMORY.DungeonFlags[dungeonPrefix][1], value)
                if modified or updateDoorKeyFromTempRoom(dungeonPrefix .. "_potkey", DATA.MEMORY.DungeonFlags[dungeonPrefix][2], value) then
                    --Refresh Dungeon Calc
                    updateChestCountFromDungeon(nil, dungeonPrefix, nil)
                end
            end
        end
    end
end

function updateDungeonItemsFromMemorySegment(segment)
    if CONFIG.AUTOTRACKER_DISABLE_DUNGEON_ITEM_TRACKING or not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Dungeon Items")
    end

    --Dungeon Items
    local bkdata = segment:ReadUInt16(0x7ef366)
    local mapdata = segment:ReadUInt16(0x7ef368)
    local compassdata = segment:ReadUInt16(0x7ef364)

    for i = 1, #DATA.DungeonList do
        local item = Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_bigkey")
        item.Active = bkdata & DATA.DungeonData[DATA.DungeonList[i]][3] > 0
        local mcbk = item.Active and 4 or 0
        
        item = Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_map")
        item.Active = mapdata & DATA.DungeonData[DATA.DungeonList[i]][3] > 0
        mcbk = mcbk + (item.Active and 1 or 0)
        
        item = Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_compass")
        item.Active = compassdata & DATA.DungeonData[DATA.DungeonList[i]][3] > 0
        mcbk = mcbk + (item.Active and 2 or 0)

        item = Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_mcbk")
        item:Set("state", mcbk)

        --Small Keys
        if OBJ_DOORSHUFFLE:getState() == 0 then
            updateDungeonKeysFromPrefix(segment, DATA.DungeonList[i], 0x7ef37c + DATA.DungeonData[DATA.DungeonList[i]][4])
        end

        --Refresh Dungeon Calc
        updateChestCountFromDungeon(nil, DATA.DungeonList[i], nil)
    end
end

function updateDungeonKeysFromMemorySegment(segment)
    if not segment or not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Dungeon Keys")
    end

    --Small Keys
    if segment and not CONFIG.AUTOTRACKER_DISABLE_DUNGEON_ITEM_TRACKING then
        for i = 1, #DATA.DungeonList do
            updateDungeonKeysFromPrefix(segment, DATA.DungeonList[i], 0x7ef4e0 + DATA.DungeonData[DATA.DungeonList[i]][4])
        end
    end

    if CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING then
        return true
    end

    --Collected Chests/Items In Dungeons
    if OBJ_RACEMODE:getState() == 0 then
        if shouldChestCountUp() then
            if INSTANCE.NEW_SRAM_SYSTEM then
                for dungeonPrefix, data in pairs(DATA.DungeonData) do
                    updateChestCountFromDungeon(segment, dungeonPrefix, 0x7ef4c0 + data[4])
                end
            else
                updateChestCountFromDungeon(segment, "hc", 0x7ef4c0)
                updateChestCountFromDungeon(segment, "ep", 0x7ef4c1)
                updateChestCountFromDungeon(segment, "dp", 0x7ef4c2)
                updateChestCountFromDungeon(segment, "toh", 0x7ef4c9)
                updateChestCountFromDungeon(segment, "at", 0x7ef4c3)
                updateChestCountFromDungeon(segment, "pod", 0x7ef4c5)
                updateChestCountFromDungeon(segment, "sp", 0x7ef4c4)
                updateChestCountFromDungeon(segment, "sw", 0x7ef4c7)
                updateChestCountFromDungeon(segment, "tt", 0x7ef4ca)
                updateChestCountFromDungeon(segment, "ip", 0x7ef4c8)
                updateChestCountFromDungeon(segment, "mm", 0x7ef4c6)
                updateChestCountFromDungeon(segment, "tr", 0x7ef4cb)
                updateChestCountFromDungeon(segment, "gt", 0x7ef4cc)
            end
        else
            for i, dungeonPrefix in ipairs(DATA.DungeonList) do
                updateChestCountFromDungeon(nil, dungeonPrefix, nil)
            end
        end
    end
end

function updateDungeonTotalsFromMemorySegment(segment)
    if not segment or (not shouldChestCountUp()) or OBJ_RACEMODE:getState() > 0 or not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Dungeon Totals")
    end

    --Dungeon Total Checks Seen
    local seenFlags = segment:ReadUInt16(0x7ef403)
    for dungeonPrefix, data in pairs(DATA.DungeonData) do
        updateDungeonTotal(dungeonPrefix, seenFlags)
    end
end

function updateDungeonsCompletedFromMemorySegment(segment)
    if not segment or not INSTANCE.NEW_SRAM_SYSTEM or not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Dungeons Completed")
    end

    local data = segment:ReadUInt16(0x7ef472)
    for i, boss in ipairs(INSTANCE.MEMORY.Bosses) do
        local item = Tracker:FindObjectForCode(boss[1])
        if item then
            item.Active = data & DATA.DungeonData[boss[1]][3] > 0
        end
    end
end

function updateDungeonPendantFromMemorySegment(segment)
    if OBJ_RACEMODE:getState() > 0 or OBJ_GLITCHMODE:getState() > 2 or not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Pendant")
    end

    if CACHE.DUNGEON < 0 then
        updateDungeonIdFromMemorySegment(nil)
    end
    
    local pendantData = segment:ReadUInt8(0x7ef374)

    local dungeon = Tracker:FindObjectForCode(DATA.DungeonIdMap[CACHE.DUNGEON])
    if dungeon and dungeon.CurrentStage == 0 then

        local diffData = ((INSTANCE.DUNGEON_PRIZE_DATA & 0xff00) >> 8) ~ pendantData
        if numberOfSetBits(diffData) == 1 and diffData & pendantData > 0 then
            dungeon.CurrentStage = diffData & pendantData == 4 and 4 or 3
        end
    end

    INSTANCE.DUNGEON_PRIZE_DATA = (INSTANCE.DUNGEON_PRIZE_DATA & 0x00ff) + (pendantData << 8)
end

function updateDungeonCrystalFromMemorySegment(segment)
    if OBJ_RACEMODE:getState() > 0 or OBJ_GLITCHMODE:getState() > 2 or not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Crystal")
    end

    if CACHE.DUNGEON < 0 then
        updateDungeonIdFromMemorySegment(nil)
    end

    local crystalData = segment:ReadUInt8(0x7ef37a)

    local dungeon = Tracker:FindObjectForCode(DATA.DungeonIdMap[CACHE.DUNGEON])
    if dungeon and dungeon.CurrentStage == 0 then
        local diffData = (INSTANCE.DUNGEON_PRIZE_DATA & 0xff) ~ crystalData
        if numberOfSetBits(diffData) == 1 and diffData & crystalData > 0 then
            dungeon.CurrentStage = 1
        end
    end

    INSTANCE.DUNGEON_PRIZE_DATA = (INSTANCE.DUNGEON_PRIZE_DATA & 0xff00) + crystalData
end

function updateCollectionFromMemorySegment(segment)
    if not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Collection")
    end
    
    if CACHE.CollectionMax == nil then
        CACHE.CollectionMax = AutoTracker:ReadU16(0x7ef33e, 0)
    end

    if CACHE.CollectionMax == 0 then
        CACHE.CollectionRate = segment:ReadUInt8(0x7ef423)
    else
        CACHE.CollectionRate = segment:ReadUInt16(0x7ef423)
    end

    Tracker:FindObjectForCode("race_mode_small").ItemState:updateText()
end