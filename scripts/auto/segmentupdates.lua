function updateTitleFromMemorySegment(segment)
    if Tracker.ActiveVariantUID ~= "vanilla" then
        local value = segment:ReadUInt8(0x007fd3)
        if value > 0 then
            if string.char(value) == "O" then
                if OBJ_WORLDSTATE:getProperty("version") ~= 1 then
                    OBJ_WORLDSTATE.clicked = true
                    OBJ_WORLDSTATE.ignorePostUpdate = true
                    OBJ_WORLDSTATE:setProperty("version", 1)
                end
            else
                if OBJ_WORLDSTATE:getProperty("version") ~= 0 then
                    OBJ_WORLDSTATE.clicked = true
                    OBJ_WORLDSTATE.ignorePostUpdate = true
                    OBJ_WORLDSTATE:setProperty("version", 0)
                end
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
        if (owarea == 0 and (MODULE == 0x07 or MODULE == 0x05 or MODULE == 0x0e or MODULE == 0x17 or MODULE == 0x11 or MODULE == 0x06 or MODULE == 0x0f)) --transitioning into dungeons
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
                if CACHE.OWAREA == 0 then
                    print("NULL OW CASE NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL")
                    print("^ Module:", string.format("0x%02x", MODULE))
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
                                        if not Tracker:FindObjectForCode(item).Active then
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
        local roomMap =
        {
                         [0x01] = 2,  [0x02] = 0,               [0x04] = 24,              [0x06] = 10, [0x07] = 20,              [0x09] = 12, [0x0a] = 12, [0x0b] = 12, [0x0c] = 26, [0x0d] = 26, [0x0e] = 18,
                         [0x11] = 0,  [0x12] = 0,  [0x13] = 24, [0x14] = 24, [0x15] = 24, [0x16] = 10, [0x17] = 20,              [0x19] = 12, [0x1a] = 12, [0x1b] = 12, [0x1c] = 26, [0x1d] = 26, [0x1e] = 18, [0x1f] = 18,
            [0x20] = 8,  [0x21] = 0,  [0x22] = 0,  [0x23] = 24, [0x24] = 24,              [0x26] = 10, [0x27] = 20, [0x28] = 10, [0x29] = 16, [0x2a] = 12, [0x2b] = 12,                           [0x2e] = 18,
            [0x30] = 8,  [0x31] = 20, [0x32] = 0,  [0x33] = 6,  [0x34] = 10, [0x35] = 10, [0x36] = 10, [0x37] = 10, [0x38] = 10, [0x39] = 16, [0x3a] = 12, [0x3b] = 12,              [0x3d] = 26, [0x3e] = 18, [0x3f] = 18,
            [0x40] = 8,  [0x41] = 0,  [0x42] = 0,  [0x43] = 6,  [0x44] = 22, [0x45] = 22, [0x46] = 10,                           [0x49] = 16, [0x4a] = 12, [0x4b] = 12, [0x4c] = 26, [0x4d] = 26, [0x4e] = 18, [0x4f] = 18,
            [0x50] = 2,  [0x51] = 2,  [0x52] = 2,  [0x53] = 6,  [0x54] = 10,              [0x56] = 16, [0x57] = 16, [0x58] = 16, [0x59] = 16, [0x5a] = 12, [0x5b] = 26, [0x5c] = 26, [0x5d] = 26, [0x5e] = 18, [0x5f] = 18,
            [0x60] = 2,  [0x61] = 2,  [0x62] = 2,  [0x63] = 6,  [0x64] = 22, [0x65] = 22, [0x66] = 10, [0x67] = 16, [0x68] = 16,              [0x6a] = 12, [0x6b] = 26, [0x6c] = 26, [0x6d] = 26, [0x6e] = 18,
            [0x70] = 2,  [0x71] = 2,  [0x72] = 2,  [0x73] = 6,  [0x74] = 6,  [0x75] = 6,  [0x76] = 10, [0x77] = 20,                                        [0x7b] = 26, [0x7c] = 26, [0x7d] = 26, [0x7e] = 18, [0x7f] = 18,
            [0x80] = 2,  [0x81] = 2,  [0x82] = 2,  [0x83] = 6,  [0x84] = 6,  [0x85] = 6,               [0x87] = 20,              [0x89] = 4,               [0x8b] = 26, [0x8c] = 26, [0x8d] = 26, [0x8e] = 18,
            [0x90] = 14, [0x91] = 14, [0x92] = 14, [0x93] = 14,              [0x95] = 26, [0x96] = 26, [0x97] = 14, [0x98] = 14, [0x99] = 4,               [0x9b] = 26, [0x9c] = 26, [0x9d] = 26, [0x9e] = 18, [0x9f] = 18,
            [0xa0] = 14, [0xa1] = 14, [0xa2] = 14, [0xa3] = 14, [0xa4] = 24, [0xa5] = 26, [0xa6] = 26, [0xa7] = 20, [0xa8] = 4,  [0xa9] = 4,  [0xaa] = 4,  [0xab] = 22, [0xac] = 22,              [0xae] = 18, [0xaf] = 18,
            [0xb0] = 8,  [0xb1] = 14, [0xb2] = 14, [0xb3] = 14, [0xb4] = 24, [0xb5] = 24, [0xb6] = 24, [0xb7] = 24, [0xb8] = 4,  [0xb9] = 4,  [0xba] = 4,  [0xbb] = 22, [0xbc] = 22,              [0xbe] = 18, [0xbf] = 18,
            [0xc0] = 8,  [0xc1] = 14, [0xc2] = 14, [0xc3] = 14, [0xc4] = 24, [0xc5] = 24, [0xc6] = 24, [0xc7] = 24, [0xc8] = 4,  [0xc9] = 4,               [0xcb] = 22, [0xcc] = 22,              [0xce] = 18,
            [0xd0] = 8,  [0xd1] = 14, [0xd2] = 14,                           [0xd5] = 24, [0xd6] = 24,              [0xd8] = 4,  [0xd9] = 4,  [0xda] = 4,  [0xdb] = 22, [0xdc] = 22,              [0xde] = 18,
            [0xe0] = 8
        }
        
        print("CURRENT ROOM:", CACHE.ROOM, string.format("0x%4X", CACHE.ROOM))
        --print("CURRENT ROOM ORIGDUNGEON:", DATA.DungeonIdMap[roomMap[CACHE.ROOM]], roomMap[CACHE.ROOM], string.format("0x%2X", roomMap[CACHE.ROOM]))
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
                        end
        
                        if item.Active then
                            if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                                print("Item Got:", name)
                            end
                            itemFlippedOn(name)
                        end
                    end
                else
                    INSTANCE.MEMORY.Items[name] = nil
                end
            elseif #value == 4 then
                value[4](segment)
            elseif #value > 1 then
                local data = segment:ReadUInt8(value[1]) + value[3]
                if data > item.CurrentStage or not STATUS.AutotrackerInGame then
                    itemFlippedOn(name)
                    item.CurrentStage = data
                end
            else
                if not item.Active or not STATUS.AutotrackerInGame then
                    item.Active = segment:ReadUInt8(value[1]) > 0
                end

                if item.Active then
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
                    if not item.Active or not STATUS.AutotrackerInGame then
                        item.Active = segment:ReadUInt8(value[1]) & value[2] > 0
                    end
    
                    if item.Active then
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
        elseif CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING and Tracker.ActiveVariantUID ~= "vanilla" then
            print("Couldn't find item:", name)
        end
    end
end

DATA.MEMORY.Overworld = {
    ["@Spectacle Rock/Up On Top"] =           { 0x03 },
    ["@Floating Island/Island"] =             { 0x05 },
    ["@Race Game/Take This Trash"] =          { 0x28 },
    ["@Grove Digging Spot/Hidden Treasure"] = { 0x2a, updateShovelIndicatorStatus },
    ["@Desert Ledge/Ledge"] =                 { 0x30 },
    ["@Lake Hylia Island/Island"] =           { 0x35 },
    ["@Dam/Outside"] =                        { 0x3b },
    ["@Sunken Treasure/Drain The Dam"] =      { 0x3b },
    ["@Bumper Ledge/Ledge"] =                 { 0x4a },
    ["@Pyramid Ledge/Ledge"] =                { 0x5b },
    ["@Digging Game/Dig For Treasure"] =      { 0x68 },
    ["@Master Sword Pedestal/Pedestal"] =     { 0x80 },
    ["@Zora's Domain/Ledge"] =                { 0x81 }
}

DATA.MEMORY.OverworldItems = {
    ["dam"] =   { 0x3b, 0x20, true, nil },
    ["bombs"] = { 0x5b, 0x02, nil, 1 }
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
                location.AvailableChestCount = location.ChestCount - (segment:ReadUInt8(0x7ef280 + value[1]) & 0x40 > 0 and 1 or 0)
                
                if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING and location.AvailableChestCount == 0 then
                    print("Overworld Check:", name)
                end

                if #value > 1 then
                    value[2](location.AvailableChestCount == 0)
                end
            end

            if location.AvailableChestCount == 0 then
                INSTANCE.MEMORY.Overworld[name] = nil
            end
        else
            print("Couldn't find overworld:", name)
        end
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

    for name, value in pairs(INSTANCE.MEMORY.Shops) do
        local location = Tracker:FindObjectForCode(name)
        if location then
            if not location.Owner.ModifiedByUser then -- Do not auto-track this the user has manually modified it
                local clearedCount = 0
                for i, slot in ipairs(value[1]) do
                    clearedCount = clearedCount + (segment:ReadUInt8(slot) > 0 and 1 or 0)
                end
                
                if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                    print(name, clearedCount)
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
                if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                    print(name, (data & value[1]) ~= 0 and 1 or 0)
                end

                location.AvailableChestCount = location.ChestCount - ((data & value[1]) ~= 0 and 1 or 0)

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
    { {"@Ganon's Tower/Bob\\Ice Armos"}, {{140, 7}, {28, 4}, {28, 5}, {28, 6}} },
    { {"@GT Bob/Chest"}, {{140, 7}} },
    { {"@GT Ice Armos/Chest"}, {{28, 4}, {28, 5}, {28, 6}} },
    { {"@Ganon's Tower/Tile Room", "@GT Tile Room/Chest"}, {{141, 4}} },
    { {"@Ganon's Tower/Big Chest", "@GT Big Chest/Chest"}, {{140, 4}} },
    { {"@Ganon's Tower/Mini Helmasaur", "@GT Mini Helmasaur/Chest"}, {{61, 4}, {61, 5}} },
    { {"@Ganon's Tower/Pre-Moldorm", "@GT Pre-Moldorm/Chest"}, {{61, 6}} },
    { {"@Ganon's Tower/Validation", "@GT Validation/Chest"}, {{77, 4}} }
}

DATA.MEMORY.DungeonKeyDrops = {
    { {"@Hyrule Castle & Escape/Key Guard", "@HC Key Guard/Guard"}, {{114, 10}} },
    { {"@Hyrule Castle & Escape/Boomerang Guard", "@HC Boomerang/Guard"}, {{113, 10}} },
    { {"@Hyrule Castle & Escape/Ball 'N Chain Guard", "@HC Ball 'N Chain/Guard"}, {{128, 10}} },
    { {"@Hyrule Castle & Escape/Key Rat", "@HC Key Rat/Rat"}, {{33, 10}} },

    { {"@Eastern Palace/Dark Pot Key", "@EP Dark Pot/Pot"}, {{186, 10}} },
    { {"@Eastern Palace/Dark Eyegore", "@EP Dark Eyegore/Eyegore"}, {{153, 10}} },

    { {"@Desert Palace/Back Lobby Key", "@DP Back Lobby/Pot"}, {{99, 10}} },
    { {"@Desert Palace/Beamos Hall Key", "@DP Beamos Hall/Pot"}, {{83, 10}} },
    { {"@Desert Palace/Back Tiles Key", "@DP Back Tiles/Pot"}, {{67, 10}} },

    { {"@Agahnim's Tower/Bow Guard", "@AT Bow Guard/Guard"}, {{192, 10}} },
    { {"@Agahnim's Tower/Circle of Pots Key", "@AT Circle of Pots/Guard"}, {{176, 10}} },

    { {"@Swamp Palace/Pot Row Key", "@SP Pot Row/Pot"}, {{56, 10}} },
    { {"@Swamp Palace/Front Flood Key", "@SP Front Flood Pot/Pot"}, {{55, 10}} },
    { {"@Swamp Palace/Hookshot Key", "@SP Hookshot Pot/Pot"}, {{54, 10}} },
    { {"@Swamp Palace/Left Flood Key", "@SP Left Flood Pot/Pot"}, {{53, 10}} },
    { {"@Swamp Palace/Waterway Key", "@SP Waterway/Pot"}, {{22, 10}} },

    { {"@Skull Woods/West Lobby Key", "@SW West Lobby/Pot"}, {{86, 10}} },
    { {"@Skull Woods/Gibdo Key", "@SW Gibdo/Gibdo"}, {{57, 10}} },

    { {"@Thieves Town/Hallway Key", "@TT Hallway/Pot"}, {{188, 10}} },
    { {"@Thieves Town/Spike Switch Key", "@TT Spike Switch/Pot"}, {{171, 10}} },

    { {"@Ice Palace/Lobby Key", "@IP Lobby/Bari"}, {{14, 10}} },
    { {"@Ice Palace/Conveyor Key", "@IP Conveyor/Bari"}, {{62, 10}} },
    { {"@Ice Palace/Boulder Key", "@IP Tongue Pull/Boulder"}, {{63, 10}} },
    { {"@Ice Palace/Ice Hell Key", "@IP Hell on Ice/Pot"}, {{159, 10}} },

    { {"@Misery Mire/Spike Key", "@MM Spike Room/Pot"}, {{179, 10}} },
    { {"@Misery Mire/Fishbone Key", "@MM Fishbone Room/Pot"}, {{161, 10}} },
    { {"@Misery Mire/Conveyor Jelly", "@MM Conveyor Switch/Bari"}, {{193, 10}} },

    { {"@Turtle Rock/Chain Chomp Pokey", "@TR Chain Chomp/Pokey"}, {{182, 10}} },
    { {"@Turtle Rock/Lava Pokey", "@TR Lava Pokey/Pokey"}, {{19, 10}} },

    { {"@Ganon's Tower/Conveyor Bumper Key", "@GT Conveyor Bumper/Pot"}, {{139, 10}} },
    { {"@Ganon's Tower/Double Switch Key", "@GT Double Switch/Pot"}, {{155, 10}} },
    { {"@Ganon's Tower/Post-Compass Key", "@GT Post-Compass/Pot"}, {{123, 10}} },
    { {"@Ganon's Tower/Mini Helmasaur Key", "@GT Mini Helmasaur/Mini Helmasaur"}, {{61, 10}} }
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
    { {"@Link's House/By The Door"},     {{0, 10}} },
    { {"@Kakariko Well/Cave"},           {{47, 5}, {47, 6}, {47, 7}, {47, 8}} },
    { {"@Kakariko Well/Bombable Wall"},  {{47, 4}} },
    { {"@Hookshot Cave/Bonkable Chest"}, {{60, 7}} },
    { {"@Hookshot Cave/Back"},           {{60, 4}, {60, 5}, {60, 6}} },
    { {"@Secret Passage/Hallway"},       {{85, 4}} },
    { {"@Forest Hideout/Stash"},         {{225, 9, 4}},                     0x00 },
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
    { {"@Graveyard Ledge/Cave"},         {{283, 9, 8}} },
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

function updateRoomsFromMemorySegment(segment)
    if not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Rooms")
    end

    --Dungeon Data
    if Tracker.ActiveVariantUID == "full_tracker" then
        if OBJ_DOORSHUFFLE:getState() == 0 then
            --Doors Opened
            updateDoorKeyCountFromRoomSlotList(segment, "hc_door", {{114, 15}, {113, 15}, {50, 15, 34, 15}, {17, 13, 33, 15}})
            updateDoorKeyCountFromRoomSlotList(segment, "ep_door", {{186, 15, 185, 15}, {153, 15}})
            updateDoorKeyCountFromRoomSlotList(segment, "dp_door", {{133, 14}, {99, 15}, {83, 13, 67, 13}, {67, 14}})
            updateDoorKeyCountFromRoomSlotList(segment, "toh_door", {{119, 15}})
            updateDoorKeyCountFromRoomSlotList(segment, "at_door", {{224, 13}, {208, 15}, {192, 13}, {176, 13}})
            updateDoorKeyCountFromRoomSlotList(segment, "pod_door", {{74, 13, 58, 15}, {10, 15}, {42, 14, 26, 12}, {26, 14, 25, 14}, {26, 15}, {11, 13}})
            updateDoorKeyCountFromRoomSlotList(segment, "sp_door", {{40, 15}, {56, 14, 55, 12}, {55, 13}, {54, 13, 53, 15}, {54, 14, 38, 15}, {22, 14}})
            updateDoorKeyCountFromRoomSlotList(segment, "sw_door", {{87, 13, 88, 14}, {104, 14, 88, 13}, {86, 15}, {89, 15, 73, 13}, {57, 14}})
            updateDoorKeyCountFromRoomSlotList(segment, "tt_door", {{188, 15}, {171, 15}, {68, 14}})
            updateDoorKeyCountFromRoomSlotList(segment, "ip_door", {{14, 15}, {62, 14, 78, 14}, {94, 15, 95, 15}, {126, 15, 142, 15}, {158, 15}, {190, 14, 191, 15}})
            updateDoorKeyCountFromRoomSlotList(segment, "mm_door", {{179, 15}, {194, 14, 193, 14}, {193, 15}, {194, 15, 195, 15}, {161, 15, 177, 14}, {147, 14}})
            updateDoorKeyCountFromRoomSlotList(segment, "tr_door", {{198, 15, 182, 13}, {182, 12}, {182, 15}, {19, 15, 20, 14}, {4, 15}, {197, 15, 196, 15}})
            updateDoorKeyCountFromRoomSlotList(segment, "gt_door", {{140, 13}, {139, 14}, {155, 15}, {125, 13}, {141, 14}, {123, 14, 124, 13}, {61, 14}, {61, 13, 77, 15}})
        end

        --Pot and Enemy Keys
        updateDoorKeyCountFromRoomSlotList(segment, "hc_potkey", {{114, 10}, {113, 10}, {128, 10}, {33, 10}})
        updateDoorKeyCountFromRoomSlotList(segment, "ep_potkey", {{186, 10}, {153, 10}})
        updateDoorKeyCountFromRoomSlotList(segment, "dp_potkey", {{99, 10}, {83, 10}, {67, 10}})
        updateDoorKeyCountFromRoomSlotList(segment, "at_potkey", {{192, 10}, {176, 10}})
        updateDoorKeyCountFromRoomSlotList(segment, "sp_potkey", {{56, 10}, {55, 10}, {54, 10}, {53, 10}, {22, 10}})
        updateDoorKeyCountFromRoomSlotList(segment, "sw_potkey", {{86, 10}, {57, 10}})
        updateDoorKeyCountFromRoomSlotList(segment, "tt_potkey", {{188, 10}, {171, 10}})
        updateDoorKeyCountFromRoomSlotList(segment, "ip_potkey", {{14, 10}, {62, 10}, {63, 10}, {159, 10}})
        updateDoorKeyCountFromRoomSlotList(segment, "mm_potkey", {{179, 10}, {193, 10}, {161, 10}})
        updateDoorKeyCountFromRoomSlotList(segment, "tr_potkey", {{182, 10}, {19, 10}})
        updateDoorKeyCountFromRoomSlotList(segment, "gt_potkey", {{139, 10}, {155, 10}, {123, 10}, {61, 10}})
    end

    for i, boss in ipairs(INSTANCE.MEMORY.Bosses) do
        local bossflag = segment:ReadUInt16(0x7ef000 + (boss[2][1] * 2)) & (1 << boss[2][2])
        local item = Tracker:FindObjectForCode(boss[1])
        if item then
            item.Active = bossflag > 0
        end

        if INSTANCE.MEMORY.BossLocations[i] and not CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING and Tracker.ActiveVariantUID == "full_tracker" then
            item = Tracker:FindObjectForCode(INSTANCE.MEMORY.BossLocations[i])
            if item then
                item.AvailableChestCount = bossflag == 0 and 1 or 0
                INSTANCE.MEMORY.BossLocations[i] = nil
            else
                print("Couldn't find location", item)
            end
        end

        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("Boss Defeated:", INSTANCE.MEMORY.BossLocations[i])
        end
    end

    if CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID ~= "full_tracker" then
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
        if OBJ_POOL_KEYDROP and OBJ_POOL_KEYDROP:getState() > 0 then
            i = 1
            while i <= #INSTANCE.MEMORY.DungeonKeyDrops do
                if updateRoomLocation(segment, INSTANCE.MEMORY.DungeonKeyDrops[i]) then
                    table.remove(INSTANCE.MEMORY.DungeonKeyDrops, i)
                else
                    i = i + 1
                end
            end
        end
    end

    --Refresh Dungeon Calc
    updateDungeonKeysFromMemorySegment(nil)

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
    end

    --Refresh Dungeon Calc
    updateDungeonKeysFromMemorySegment(nil)
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
    if OBJ_DOORSHUFFLE:getState() == 2 and OBJ_RACEMODE:getState() == 0 then
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
end

function updateDungeonPendantFromMemorySegment(segment)
    if OBJ_RACEMODE:getState() > 0 or not isInGame() then
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
    if dungeon and not dungeon.Active and dungeon.CurrentStage == 0 then

        local diffData = ((INSTANCE.DUNGEON_PRIZE_DATA & 0xff00) >> 8) ~ pendantData
        if numberOfSetBits(diffData) == 1 and diffData & pendantData > 0 then
            dungeon.CurrentStage = diffData & pendantData == 4 and 4 or 3
        end
    end

    INSTANCE.DUNGEON_PRIZE_DATA = (INSTANCE.DUNGEON_PRIZE_DATA & 0x00ff) + (pendantData << 8)
end

function updateDungeonCrystalFromMemorySegment(segment)
    if OBJ_RACEMODE:getState() > 0 or not isInGame() then
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
    if dungeon and (not dungeon.Active and dungeon.CurrentStage == 0) then
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