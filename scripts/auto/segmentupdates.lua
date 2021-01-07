function updateModuleIdFromMemorySegment(segment)
    local mainModuleIdx = segment:ReadUInt8(0x7e0010)

    if mainModuleIdx == 0 then
        START_TIME = os.time()
    end

    if mainModuleIdx ~= OBJ_MODULE.AcquiredCount and mainModuleIdx ~= 0x0e then
        --Update Dungeon Id when starting at Sanctuary
        if OBJ_MODULE.AcquiredCount == 0x05 and mainModuleIdx == 0x07 then
            updateDungeonIdFromMemorySegment(nil)
        end

        OBJ_MODULE.AcquiredCount = mainModuleIdx

        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print("CURRENT MODULE:", mainModuleIdx, string.format("0x%2X", mainModuleIdx))
        end

        if mainModuleIdx == 0x07 or mainModuleIdx == 0x09 then
        elseif mainModuleIdx == 0x12 then
            sendExternalMessage("health", "dead")
        end
    end

    local wasInTriforceRoom = AUTOTRACKER_IS_IN_TRIFORCE_ROOM
    AUTOTRACKER_IS_IN_TRIFORCE_ROOM = (mainModuleIdx == 0x19 or mainModuleIdx == 0x1a)

    if AUTOTRACKER_IS_IN_TRIFORCE_ROOM and not wasInTriforceRoom then
        updateHealth(nil)
        ScriptHost:AddMemoryWatch("LTTP Statistics", 0x7ef420, 0x46, updateStatisticsFromMemorySegment)
    end

    if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        if isInGame() then
            --print("Current Room Index: ", segment:ReadUInt16(0x7e00a0))
            --print("Current OW     Index: ", segment:ReadUInt16(0x7e008a))
        end
    end

    return true
end

function updateOverworldIdFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    local owarea = ReadU8(segment, 0x7e008a)
    if not (OBJ_DUNGEON.AcquiredCount == 0xff and OBJ_MODULE.AcquiredCount == 0x09) then --force OW transitions to retain OW ID
        if (owarea == 0 and (OBJ_MODULE.AcquiredCount == 0x06 or OBJ_MODULE.AcquiredCount == 0x0f)) --transitioning into dungeons
                or owarea > 0x81 then --transitional OW IDs are ignored ie. 0x96
            owarea = 0xff
        end
    end

    if OBJ_OWAREA.AcquiredCount ~= owarea then
        --Update Dungeon Image (Prep)
        local updateImage = false
        if OBJ_OWAREA.AcquiredCount == 255
                or (owarea >= 0x40 and owarea < 0x80 and OBJ_OWAREA.AcquiredCount < 0x40) 
                or (owarea < 0x40 and OBJ_OWAREA.AcquiredCount >= 0x40 and OBJ_OWAREA.AcquiredCount < 0x80) then
            updateImage = true
        end

        OBJ_OWAREA.AcquiredCount = owarea

        if OBJ_OWAREA.AcquiredCount < 0xff then
            --Region Autotracking
            if OBJ_ENTRANCE.CurrentStage > 0 and OBJ_RACEMODE.CurrentStage == 0 and (not AUTOTRACKER_DISABLE_REGION_TRACKING) and Tracker.ActiveVariantUID ~= "items_only" then
                if OBJ_OWAREA.AcquiredCount < 0xff and OverworldIdRegionMap[OBJ_OWAREA.AcquiredCount] then
                    local region = Tracker:FindObjectForCode(OverworldIdRegionMap[OBJ_OWAREA.AcquiredCount])
                    if region then
                        region.Active = true
                    end
                end
            end

            --Update Dungeon Image
            if updateImage then
                if OBJ_OWAREA.AcquiredCount >= 0x40 and OBJ_OWAREA.AcquiredCount < 0x80 then
                    if string.find(Tracker.ActiveVariantUID, "er_") then
                        sendExternalMessage("dungeon", "er-dw")
                    else
                        sendExternalMessage("dungeon", "dw")
                    end
                else
                    if string.find(Tracker.ActiveVariantUID, "er_") then
                        sendExternalMessage("dungeon", "er-lw")
                    else
                        sendExternalMessage("dungeon", "lw")
                    end
                end
            end

            if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                print("CURRENT OW:", OBJ_OWAREA.AcquiredCount, string.format("0x%2X", OBJ_OWAREA.AcquiredCount))
            end
        end
    end
end

function updateDungeonIdFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if (segment) then
        OBJ_DUNGEON.AcquiredCount = ReadU8(segment, 0x7e040c)
    else
        OBJ_DUNGEON.AcquiredCount = AutoTracker:ReadU8(0x7e040c, 0)
    end

    if OBJ_DUNGEON.AcquiredCount < 0xff then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print("CURRENT DUNGEON:", DungeonIdMap[OBJ_DUNGEON.AcquiredCount], OBJ_DUNGEON.AcquiredCount, string.format("0x%2X", OBJ_DUNGEON.AcquiredCount))
        end

        --Set Door Dungeon Selector
        if Tracker.ActiveVariantUID ~= "items_only" then
            OBJ_DOORDUNGEON.ItemState:setState(DungeonData[DungeonIdMap[OBJ_DUNGEON.AcquiredCount]][4])
        end

        --Update Dungeon Image
        if string.find(Tracker.ActiveVariantUID, "er_") then
            sendExternalMessage("dungeon", "er-" .. DungeonIdMap[OBJ_DUNGEON.AcquiredCount])
        else
            sendExternalMessage("dungeon", DungeonIdMap[OBJ_DUNGEON.AcquiredCount])
        end

        --Auto-pin Dungeon Chests
        if AUTOTRACKER_ENABLE_AUTOPIN_CURRENT_DUNGEON and OBJ_DOORSHUFFLE.CurrentStage < 2 then
            for i = 0, 26, 2 do
                Tracker:FindObjectForCode(DungeonData[DungeonIdMap[i]][1]).Pinned = DungeonIdMap[i] == DungeonIdMap[OBJ_DUNGEON.AcquiredCount]
            end
        end
    end
end

function updateRoomIdFromMemorySegment(segment)
    if not isInGame() and OBJ_MODULE.AcquiredCount ~= 0x05 then
        return false
    end

    InvalidateReadCaches()

    OBJ_ROOM.AcquiredCount = ReadU16(segment, 0x7e00a0)

    if OBJ_DOORSHUFFLE and OBJ_DOORSHUFFLE.CurrentStage == 2 and not AUTOTRACKER_HAS_DONE_POST_GAME_SUMMARY then
        updateDoorSlots(OBJ_ROOM.AcquiredCount)
    end

    if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
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
        
        print("CURRENT ROOM:", OBJ_ROOM.AcquiredCount, string.format("0x%4X", OBJ_ROOM.AcquiredCount))
        print("CURRENT ROOM ORIGDUNGEON:", DungeonIdMap[roomMap[OBJ_ROOM.AcquiredCount]], roomMap[OBJ_ROOM.AcquiredCount], string.format("0x%2X", roomMap[OBJ_ROOM.AcquiredCount]))
    end
end

function updateItemsFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if not AUTOTRACKER_DISABLE_ITEM_TRACKING then
        updateProgressiveItemFromByte(segment, "sword", 0x7ef359, 1)
        updateProgressiveItemFromByte(segment, "shield", 0x7ef35a, 0)
        updateProgressiveItemFromByte(segment, "armor", 0x7ef35b, 0)
        updateProgressiveItemFromByte(segment, "gloves", 0x7ef354, 0)
        updateProgressiveItemFromByte(segment, "halfmagic", 0x7ef37b)

        updateToggleItemFromByte(segment, "hookshot", 0x7ef342)
        updateToggleItemFromByte(segment, "bombs", 0x7ef343)
        updateToggleItemFromByte(segment, "firerod", 0x7ef345)
        updateToggleItemFromByte(segment, "icerod", 0x7ef346)
        updateToggleItemFromByte(segment, "bombos", 0x7ef347)
        updateToggleItemFromByte(segment, "ether", 0x7ef348)
        updateToggleItemFromByte(segment, "quake", 0x7ef349)
        updateToggleItemFromByte(segment, "lamp", 0x7ef34a)
        updateToggleItemFromByte(segment, "hammer", 0x7ef34b)
        updateToggleItemFromByte(segment, "net", 0x7ef34d)
        updateToggleItemFromByte(segment, "book", 0x7ef34e)
        updateToggleItemFromByte(segment, "somaria", 0x7ef350)
        updateToggleItemFromByte(segment, "byrna", 0x7ef351)
        updateToggleItemFromByte(segment, "cape", 0x7ef352)
        updateToggleItemFromByte(segment, "boots", 0x7ef355)
        updateToggleItemFromByte(segment, "flippers", 0x7ef356)
        updateToggleItemFromByte(segment, "pearl", 0x7ef357)

        if Tracker.ActiveVariantUID == "items_only" then
            updateToggleItemFromByteAndFlag(segment, "blue_boomerang", 0x7ef341, 0x01)
            updateToggleItemFromByteAndFlag(segment, "red_boomerang", 0x7ef341, 0x02)
            updateToggleItemFromByteAndValue(segment, "shovel", 0x7ef34c, 0x01)
            updateToggleItemFromByteAndFlag(segment, "flute", 0x7ef34c, 0x02)
            updateToggleItemFromByteAndFlag(segment, "mushroom", 0x7ef344, 0x1)
            updateToggleItemFromByteAndFlag(segment, "powder", 0x7ef344, 0x2)
        else
            updateToggleItemFromByteAndFlag(segment, "blue_boomerang", 0x7ef38c, 0x80)
            updateToggleItemFromByteAndFlag(segment, "red_boomerang", 0x7ef38c, 0x40)
            updateToggleItemFromByteAndFlag(segment, "shovel", 0x7ef38c, 0x04)
            updateToggleItemFromByteAndFlag(segment, "mushroom", 0x7ef38c, 0x20)
            updateToggleItemFromByteAndFlag(segment, "powder", 0x7ef38c, 0x10)
        end

        updateProgressiveBow(segment)
        updateFlute(segment)
        updateProgressiveMirror(segment)
        updateBottles(segment)
        updateAga1(segment)
        updateHealth(segment)
    end

    if AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID == "items_only" then
        return true
    end

    --    It may seem unintuitive, but these locations are controlled by flags stored adjacent to the item data,
    --    which makes it more efficient to update them here.
    updateSectionChestCountFromByteAndFlag(segment, "@Secret Passage/Uncle", 0x7ef3c6, 0x01)
    updateSectionChestCountFromByteAndFlag(segment, "@Hobo/Under The Bridge", 0x7ef3c9, 0x01)
    updateSectionChestCountFromByteAndFlag(segment, "@Bottle Vendor/This Jerk", 0x7ef3c9, 0x02)
    updateSectionChestCountFromByteAndFlag(segment, "@Purple Chest/Middle-Aged Man", 0x7ef3c9, 0x10)
end

function updateOverworldEventsFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    if AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID == "items_only" then
        return true
    end

    InvalidateReadCaches()

    updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Spectacle Rock/Up On Top", 3)
    updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Floating Island/Island", 5)
    updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Race Game/Take This Trash", 40)
    updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Grove Digging Spot/Hidden Treasure", 42, updateShovelIndicatorStatus)
    updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Desert Ledge/Ledge", 48)
    updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Lake Hylia Island/Island", 53)
    updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Dam/Outside", 59)
    updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Sunken Treasure/Drain The Dam", 59)
    updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Bumper Ledge/Ledge", 74)
    updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Pyramid Ledge/Ledge", 91)
    updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Digging Game/Dig For Treasure", 104)
    updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Master Sword Pedestal/Pedestal", 128)
    updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Zora's Domain/Ledge", 129)

    updateBigBomb(segment)
    updateDam(segment)
end

function updateNPCItemFlagsFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    if AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID == "items_only" then
        return true
    end

    InvalidateReadCaches()

    updateSectionChestCountFromByteAndFlag(segment, "@Old Man/Bring Him Home",          0x7ef410, 0x01)
    updateSectionChestCountFromByteAndFlag(segment, "@Zora's Domain/King Zora",         0x7ef410, 0x02)
    updateSectionChestCountFromByteAndFlag(segment, "@Sick Kid/By The Bed",             0x7ef410, 0x04)
    updateSectionChestCountFromByteAndFlag(segment, "@Stumpy/Farewell",                 0x7ef410, 0x08)
    updateSectionChestCountFromByteAndFlag(segment, "@Sahasrala's Hut/Sahasrala",       0x7ef410, 0x10)
    updateSectionChestCountFromByteAndFlag(segment, "@Catfish/Ring of Stones",          0x7ef410, 0x20)
    -- 0x40 is unused
    updateSectionChestCountFromByteAndFlag(segment, "@Library/On The Shelf",            0x7ef410, 0x80)

    updateSectionChestCountFromByteAndFlag(segment, "@Ether Tablet/Tablet",             0x7ef411, 0x01)
    updateSectionChestCountFromByteAndFlag(segment, "@Bombos Tablet/Tablet",            0x7ef411, 0x02)
    updateSectionChestCountFromByteAndFlag(segment, "@Dwarven Smiths/Bring Him Home",   0x7ef411, 0x04)
    -- 0x08 is no longer relevant
    updateSectionChestCountFromByteAndFlag(segment, "@Mushroom Spot/Shroom",            0x7ef411, 0x10)
    updateSectionChestCountFromByteAndFlag(segment, "@Potion Shop/Assistant",           0x7ef411, 0x20)
    -- 0x40 is unused
    updateSectionChestCountFromByteAndFlag(segment, "@Magic Bat/Magic Bowl",            0x7ef411, 0x80, updateBatIndicatorStatus)
end

function updateRoomsFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    --Dungeon Data
    if not AUTOTRACKER_DISABLE_ITEM_TRACKING then
        if Tracker.ActiveVariantUID ~= "items_only" and OBJ_DOORSHUFFLE.CurrentStage == 0 then
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

        --Boss Prizes
        updateToggleFromRoomSlot(segment, "ep", {200, 11})
        updateToggleFromRoomSlot(segment, "dp", {51, 11})
        updateToggleFromRoomSlot(segment, "toh", {7, 11})
        updateToggleFromRoomSlot(segment, "pod", {90, 11})
        updateToggleFromRoomSlot(segment, "sp", {6, 11})
        updateToggleFromRoomSlot(segment, "sw", {41, 11})
        updateToggleFromRoomSlot(segment, "tt", {172, 11})
        updateToggleFromRoomSlot(segment, "ip", {222, 11})
        updateToggleFromRoomSlot(segment, "mm", {144, 11})
        updateToggleFromRoomSlot(segment, "tr", {164, 11})

        --Mushroom
        updateMushroomIndicator(segment)
    end

    if AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID == "items_only" then
        return true
    end

    if OBJ_RACEMODE.CurrentStage == 0 then
        --Dungeon Chests
        updateDungeonChestCountFromRoomSlotList(segment, "hc_chest", {{114, 4}, {113, 4}, {128, 4}, {50, 4}, {17, 4}, {17, 5}, {17, 6}, {18, 4}})
        updateDungeonChestCountFromRoomSlotList(segment, "ep_chest", {{185, 4}, {170, 4}, {168, 4}, {169, 4}, {184, 4}, {200, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "dp_chest", {{115, 4}, {115, 10}, {116, 4}, {133, 4}, {117, 4}, {51, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "toh_chest", {{135, 10}, {119, 4}, {135, 4}, {39, 4}, {39, 5}, {7, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "at_chest", {{224, 4}, {208, 4}})
        updateDungeonChestCountFromRoomSlotList(segment, "pod_chest", {{9, 4}, {43, 4}, {42, 4}, {42, 5}, {58, 4}, {10, 4}, {26, 4}, {26, 5}, {26, 6}, {25, 4},  {25, 5}, {106, 4}, {106, 5}, {90, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "sp_chest", {{40, 4}, {55, 4}, {54, 4}, {53, 4}, {52, 4}, {70, 4}, {118, 4}, {118, 5}, {102, 4}, {6, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "sw_chest", {{103, 4}, {104, 4}, {87, 4}, {87, 5}, {88, 4}, {88, 5}, {89, 4}, {41, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "tt_chest", {{219, 4}, {219, 5}, {203, 4}, {220, 4}, {101, 4}, {69, 4}, {68, 4}, {172, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "ip_chest", {{46, 4}, {63, 4}, {31, 4}, {95, 4}, {126, 4}, {174, 4}, {158, 4}, {222, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "mm_chest", {{162, 4}, {179, 4}, {194, 4}, {193, 4}, {209, 4}, {195, 4}, {195, 5}, {144, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "tr_chest", {{214, 4}, {183, 4}, {183, 5}, {182, 4}, {20, 4}, {36, 4}, {4, 4}, {213, 4}, {213, 5}, {213, 6}, {213, 7}, {164, 11}})
        updateDungeonChestCountFromRoomSlotList(segment, "gt_chest", {{140, 10}, {123, 4}, {123, 5}, {123, 6}, {123, 7}, {139, 4}, {125, 4}, {124, 4}, {124, 5}, {124, 6}, {124, 7}, {140, 4}, {140, 5}, {140, 6}, {140, 7}, {28, 4}, {28, 5}, {28, 6}, {141, 4}, {157, 4}, {157, 5}, {157, 6}, {157, 7}, {61, 4}, {61, 5}, {61, 6}, {77, 4}})

        --Keysanity Dungeon Map Locations
        updateSectionChestCountFromRoomSlotList(segment, {"@Hyrule Castle & Escape/First", "@HC Key Guard/Chest"}, {{114, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Hyrule Castle & Escape/Boomerang", "@HC Boomerang/Chest"}, {{113, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Hyrule Castle & Escape/Prison", "@HC Prison/Chest"}, {{128, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Hyrule Castle & Escape/Dark Cross", "@HC Dark Cross/Chest"}, {{50, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Hyrule Castle & Escape/Back", "@HC Back/Chest"}, {{17, 4}, {17, 5}, {17, 6}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Hyrule Castle & Escape/Sanctuary", "@HC Sanctuary/Chest"}, {{18, 4}})

        updateSectionChestCountFromRoomSlotList(segment, {"@Eastern Palace/Front"}, {{185, 4}, {170, 4}, {168, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Eastern Palace/Big Chest", "@EP Big Chest/Chest"}, {{169, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Eastern Palace/Big Key Chest", "@EP Big Key Chest/Chest"}, {{184, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Eastern Palace/Armos", "@EP Armos/Prize"}, {{200, 11}})

        updateSectionChestCountFromRoomSlotList(segment, {"@Desert Palace/Eyegore Switch", "@DP Eyegore Switch/Chest"}, {{116, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Desert Palace/Popo Chest", "@DP Popo Chest/Chest"}, {{133, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Desert Palace/Cannonball Chest", "@DP Cannonball/Chest"}, {{117, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Desert Palace/Torch", "@DP Torch/Torch"}, {{115, 10}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Desert Palace/Big Chest", "@DP Big Chest/Chest"}, {{115, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Desert Palace/Lanmolas", "@DP Lanmolas/Prize"}, {{51, 11}})

        updateSectionChestCountFromRoomSlotList(segment, {"@Tower of Hera/Lobby\\Cage"}, {{135, 10}, {119, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Tower of Hera/Basement", "@TH Basement/Chest"}, {{135, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Tower of Hera/Compass Chest", "@TH Compass Chest/Chest"}, {{39, 5}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Tower of Hera/Big Chest", "@TH Big Chest/Chest"}, {{39, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Tower of Hera/Moldorm", "@TH Moldorm/Prize"}, {{7, 11}})

        updateSectionChestCountFromRoomSlotList(segment, {"@Agahnim's Tower/Lobby", "@AT Lobby/Chest"}, {{224, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Agahnim's Tower/Dark Chest", "@AT Dark Chest/Chest"}, {{208, 4}})

        updateSectionChestCountFromRoomSlotList(segment, {"@Palace of Darkness/Shooter Chest", "@PoD Shooter/Chest"}, {{9, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Palace of Darkness/Bow Side", "@PoD Bow Side/Chest"}, {{43, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Palace of Darkness/Arena Ledge", "@PoD Arena Ledge/Chest"}, {{42, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Palace of Darkness/Arena Chest", "@PoD Arena/Chest"}, {{42, 5}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Palace of Darkness/Stalfos Basement", "@PoD Stalfos Basement/Chest"}, {{10, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Palace of Darkness/Big Key Chest", "@PoD Big Key Chest/Chest"}, {{58, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Palace of Darkness/Dark Maze", "@PoD Dark Maze/Chest"}, {{25, 4}, {25, 5}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Palace of Darkness/Big Chest", "@PoD Big Chest/Chest"}, {{26, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Palace of Darkness/Turtle Room", "@PoD Turtle Room/Chest"}, {{26, 5}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Palace of Darkness/Rupee Basement", "@PoD Rupee Basement/Chest"}, {{106, 4}, {106, 5}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Palace of Darkness/Harmless Hellway", "@PoD Harmless Hellway/Chest"}, {{26, 6}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Palace of Darkness/King Helmasaur", "@PoD King Helmasaur/Prize"}, {{90, 11}})

        updateSectionChestCountFromRoomSlotList(segment, {"@Swamp Palace/Entrance Chest", "@SP Entrance/Chest"}, {{40, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Swamp Palace/Bomb Wall", "@SP Bomb Wall/Chest"}, {{55, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Swamp Palace/South Side", "@SP South Side/Chest"}, {{70, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Swamp Palace/Left Side"}, {{53, 4}, {52, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Swamp Palace/Big Chest", "@SP Big Chest/Chest"}, {{54, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Swamp Palace/Back"}, {{118, 4}, {118, 5}, {102, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Swamp Palace/Arrghus", "@SP Arrghus/Prize"}, {{6, 11}})

        updateSectionChestCountFromRoomSlotList(segment, {"@Skull Woods/Front"}, {{103, 4}, {104, 4}, {87, 4}, {87, 5}, {88, 5}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Skull Woods/Big Chest", "@SW Big Chest/Chest"}, {{88, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Skull Woods/Bridge", "@SW Bridge/Chest"}, {{89, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Skull Woods/Mothula", "@SW Mothula/Prize"}, {{41, 11}})

        updateSectionChestCountFromRoomSlotList(segment, {"@Thieves Town/Front"}, {{219, 4}, {219, 5}, {203, 4}, {220, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Thieves Town/Attic Chest", "@TT Attic/Chest"}, {{101, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Thieves Town/Prison Cell", "@TT Prison Cell/Chest"}, {{69, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Thieves Town/Big Chest", "@TT Big Chest/Chest"}, {{68, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Thieves Town/Blind", "@TT Blind/Prize"}, {{172, 11}})

        updateSectionChestCountFromRoomSlotList(segment, {"@Ice Palace/Pengator Room", "@IP Pengator Room/Chest"}, {{46, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ice Palace/Spike Room", "@IP Spike Room/Chest"}, {{95, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ice Palace/Ice Breaker", "@IP Ice Breaker/Chest"}, {{31, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ice Palace/Tongue Pull", "@IP Tongue Pull/Chest"}, {{63, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ice Palace/Freezor Chest", "@IP Freezor/Chest"}, {{126, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ice Palace/Ice T", "@IP Ice T/Chest"}, {{174, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ice Palace/Big Chest", "@IP Big Chest/Chest"}, {{158, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ice Palace/Kholdstare", "@IP Kholdstare/Prize"}, {{222, 11}})

        updateSectionChestCountFromRoomSlotList(segment, {"@Misery Mire/Spike Switch", "@MM Spike Room/Chest"}, {{179, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Misery Mire/Bridge", "@MM Bridge/Chest"}, {{162, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Misery Mire/Main Hub", "@MM Main Hub/Chest"}, {{194, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Misery Mire/Left Side"}, {{193, 4}, {209, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Misery Mire/Blue Peg Chest", "@MM Blue Pegs/Chest"}, {{195, 5}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Misery Mire/Big Chest", "@MM Big Chest/Chest"}, {{195, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Misery Mire/Vitreous", "@MM Vitreous/Prize"}, {{144, 11}})

        updateSectionChestCountFromRoomSlotList(segment, {"@Turtle Rock/Compass Room", "@TR Compass Chest/Chest"}, {{214, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Turtle Rock/Roller Room", "@TR Roller Room/Chest"}, {{183, 4}, {183, 5}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Turtle Rock/Chain Chomp", "@TR Chain Chomp/Chest"}, {{182, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Turtle Rock/Lava Chest", "@TR Lava/Chest"}, {{20, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Turtle Rock/Big Chest", "@TR Big Chest/Chest"}, {{36, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Turtle Rock/Crystaroller Chest", "@TR Crystaroller/Chest"}, {{4, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Turtle Rock/Laser Bridge", "@TR Laser Bridge/Chest"}, {{213, 4}, {213, 5}, {213, 6}, {213, 7}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Turtle Rock/Trinexx", "@TR Trinexx/Prize"}, {{164, 11}})

        updateSectionChestCountFromRoomSlotList(segment, {"@Ganon's Tower/Hope Room", "@GT Hope Room/Chest"}, {{140, 5}, {140, 6}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ganon's Tower/Torch", "@GT Torch/Torch"}, {{140, 3}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ganon's Tower/Stalfos Room", "@GT Stalfos Room/Chest"}, {{123, 4}, {123, 5}, {123, 6}, {123, 7}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ganon's Tower/Map Chest", "@GT Map Chest/Chest"}, {{139, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ganon's Tower/Firesnake", "@GT Firesnake/Chest"}, {{125, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ganon's Tower/Rando Room", "@GT Rando Room/Chest"}, {{124, 4}, {124, 5}, {124, 6}, {124, 7}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ganon's Tower/Compass Room", "@GT Compass Room/Chest"}, {{157, 4}, {157, 5}, {157, 6}, {157, 7}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ganon's Tower/Bob\\Ice Armos"}, {{140, 7}, {28, 4}, {28, 5}, {28, 6}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ganon's Tower/Tile Room", "@GT Tile Room/Chest"}, {{141, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ganon's Tower/Big Chest", "@GT Big Chest/Chest"}, {{140, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ganon's Tower/Mini Helmasaur", "@GT Mini Helmasaur/Chest"}, {{61, 4}, {61, 5}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ganon's Tower/Pre-Moldorm", "@GT Pre-Moldorm/Chest"}, {{61, 6}})
        updateSectionChestCountFromRoomSlotList(segment, {"@Ganon's Tower/Validation", "@GT Validation/Chest"}, {{77, 4}})

        --Key Drop Locations
        if OBJ_POOL and OBJ_POOL.CurrentStage > 0 then
            updateSectionChestCountFromRoomSlotList(segment, {"@Hyrule Castle & Escape/Key Guard", "@HC Key Guard/Guard"}, {{114, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Hyrule Castle & Escape/Boomerang Guard", "@HC Boomerang/Guard"}, {{113, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Hyrule Castle & Escape/Ball 'N Chain Guard", "@HC Ball 'N Chain/Guard"}, {{128, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Hyrule Castle & Escape/Key Rat", "@HC Key Rat/Rat"}, {{33, 10}})

            updateSectionChestCountFromRoomSlotList(segment, {"@Eastern Palace/Dark Pot Key", "@EP Dark Pot/Pot"}, {{186, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Eastern Palace/Dark Eyegore", "@EP Dark Eyegore/Eyegore"}, {{153, 10}})

            updateSectionChestCountFromRoomSlotList(segment, {"@Desert Palace/Back Lobby Key", "@DP Back Lobby/Pot"}, {{99, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Desert Palace/Beamos Hall Key", "@DP Beamos Hall/Pot"}, {{83, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Desert Palace/Back Tiles Key", "@DP Back Tiles/Pot"}, {{67, 10}})

            updateSectionChestCountFromRoomSlotList(segment, {"@Agahnim's Tower/Bow Guard", "@AT Bow Guard/Guard"}, {{192, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Agahnim's Tower/Circle of Pots Key", "@AT Circle of Pots/Guard"}, {{176, 10}})

            updateSectionChestCountFromRoomSlotList(segment, {"@Swamp Palace/Pot Row Key", "@SP Pot Row/Pot"}, {{56, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Swamp Palace/Front Flood Key", "@SP Front Flood Pot/Pot"}, {{55, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Swamp Palace/Hookshot Key", "@SP Hookshot Pot/Pot"}, {{54, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Swamp Palace/Left Flood Key", "@SP Left Flood Pot/Pot"}, {{53, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Swamp Palace/Waterway Key", "@SP Waterway/Pot"}, {{22, 10}})

            updateSectionChestCountFromRoomSlotList(segment, {"@Skull Woods/West Lobby Key", "@SW West Lobby/Pot"}, {{86, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Skull Woods/Gibdo Key", "@SW Gibdo/Gibdo"}, {{57, 10}})

            updateSectionChestCountFromRoomSlotList(segment, {"@Thieves Town/Hallway Key", "@TT Hallway/Pot"}, {{188, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Thieves Town/Spike Switch Key", "@TT Spike Switch/Pot"}, {{171, 10}})

            updateSectionChestCountFromRoomSlotList(segment, {"@Ice Palace/Lobby Key", "@IP Lobby/Bari"}, {{14, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Ice Palace/Conveyor Key", "@IP Conveyor/Bari"}, {{62, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Ice Palace/Boulder Key", "@IP Tongue Pull/Boulder"}, {{63, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Ice Palace/Ice Hell Key", "@IP Hell on Ice/Pot"}, {{159, 10}})

            updateSectionChestCountFromRoomSlotList(segment, {"@Misery Mire/Spike Key", "@MM Spike Room/Pot"}, {{179, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Misery Mire/Fishbone Key", "@MM Fishbone Room/Pot"}, {{161, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Misery Mire/Conveyor Jelly", "@MM Conveyor Switch/Bari"}, {{193, 10}})

            updateSectionChestCountFromRoomSlotList(segment, {"@Turtle Rock/Chain Chomp Pokey", "@TR Chain Chomp/Pokey"}, {{182, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Turtle Rock/Lava Pokey", "@TR Lava Pokey/Pokey"}, {{19, 10}})

            updateSectionChestCountFromRoomSlotList(segment, {"@Ganon's Tower/Conveyor Bumper Key", "@GT Conveyor Bumper/Pot"}, {{139, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Ganon's Tower/Double Switch Key", "@GT Double Switch/Pot"}, {{155, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Ganon's Tower/Post-Compass Key", "@GT Post-Compass/Pot"}, {{123, 10}})
            updateSectionChestCountFromRoomSlotList(segment, {"@Ganon's Tower/Mini Helmasaur Key", "@GT Mini Helmasaur/Mini Helmasaur"}, {{61, 10}})
        end

        --Dungeon Map Locations
        updateSectionChestCountFromRoomSlotList(segment, {"@EP Cannonball/Chest"}, {{185, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@EP Hook/Chest"}, {{170, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@EP Stalfos Spawn/Chest"}, {{168, 4}})

        updateSectionChestCountFromRoomSlotList(segment, {"@TH Lobby/Chest"}, {{119, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@TH Cage/Item"}, {{135, 10}})

        updateSectionChestCountFromRoomSlotList(segment, {"@SP Left Side Chest/Chest"}, {{52, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@SP Big Key Chest/Chest"}, {{53, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@SP Flooded Treasure/Chest"}, {{118, 4}, {118, 5}})
        updateSectionChestCountFromRoomSlotList(segment, {"@SP Snake Waterfall/Chest"}, {{102, 4}})

        updateSectionChestCountFromRoomSlotList(segment, {"@SW Map Chest/Chest"}, {{88, 5}})
        updateSectionChestCountFromRoomSlotList(segment, {"@SW Gibdo Prison/Chest"}, {{87, 5}})
        updateSectionChestCountFromRoomSlotList(segment, {"@SW Compass Chest/Chest"}, {{103, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@SW Pinball/Chest"}, {{104, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@SW Statue Switch/Chest"}, {{87, 4}})

        updateSectionChestCountFromRoomSlotList(segment, {"@TT Main Lobby/Chest"}, {{219, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@TT Ambush/Chest"}, {{203, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@TT SE Lobby/Chest"}, {{220, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@TT Big Key Chest/Chest"}, {{219, 5}})

        updateSectionChestCountFromRoomSlotList(segment, {"@MM Torch Tiles/Chest"}, {{193, 4}})
        updateSectionChestCountFromRoomSlotList(segment, {"@MM Torch Cutscene/Chest"}, {{209, 4}})

        updateSectionChestCountFromRoomSlotList(segment, {"@GT Bob/Chest"}, {{140, 7}})
        updateSectionChestCountFromRoomSlotList(segment, {"@GT Ice Armos/Chest"}, {{28, 4}, {28, 5}, {28, 6}})
    else
        --Marking Bosses as Complete
        updateBossChestCountFromRoom(segment, "@Eastern Palace/Armos", {200, 11})
        updateBossChestCountFromRoom(segment, "@Desert Palace/Lanmolas", {51, 11})
        updateBossChestCountFromRoom(segment, "@Tower of Hera/Moldorm", {7, 11})
        updateBossChestCountFromRoom(segment, "@Palace of Darkness/King Helmasaur", {90, 11})
        updateBossChestCountFromRoom(segment, "@Swamp Palace/Arrghus", {6, 11})
        updateBossChestCountFromRoom(segment, "@Skull Woods/Mothula", {41, 11})
        updateBossChestCountFromRoom(segment, "@Thieves Town/Blind", {172, 11})
        updateBossChestCountFromRoom(segment, "@Ice Palace/Kholdstare", {222, 11})
        updateBossChestCountFromRoom(segment, "@Misery Mire/Vitreous", {144, 11})
        updateBossChestCountFromRoom(segment, "@Turtle Rock/Trinexx", {164, 11})
    end

    --Refresh Dungeon Calc
    updateDungeonKeysFromMemorySegment(nil)

    --Miscellaneous
    if OBJ_RACEMODE.CurrentStage == 0 then
        updateToggleItemFromByteAndFlag(segment, "attic", 0x7ef0cb, 0x01)
    end
    updateToggleItemFromByteAndFlag(segment, "aga2", 0x7ef01b, 0x08)

    --Underworld Locations
    updateSectionChestCountFromRoomSlotList(segment, {"@Link's House/By The Door"}, {{0, 10}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Kakariko Well/Cave"}, {{47, 5}, {47, 6}, {47, 7}, {47, 8}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Kakariko Well/Bombable Wall"}, {{47, 4}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Hookshot Cave/Bonkable Chest"}, {{60, 7}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Hookshot Cave/Back"}, {{60, 4}, {60, 5}, {60, 6}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Secret Passage/Hallway"}, {{85, 4}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Forest Hideout/Stash"}, {{225, 9, 4}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Lumberjack Cave/Cave"}, {{226, 9}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Spectacle Rock/Cave"}, {{234, 10, 2}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Paradox Cave/Top"}, {{239, 4}, {239, 5}, {239, 6}, {239, 7}, {239, 8}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Superbunny Cave/Cave"}, {{248, 4}, {248, 5}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Spiral Cave/Cave"}, {{254, 4}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Paradox Cave/Bottom"}, {{255, 4}, {255, 5}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Tavern/Back Room"}, {{259, 4}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Link's House/By The Door"}, {{260, 4}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Sahasrala's Hut/Closet"}, {{261, 4}, {261, 5}, {261, 6}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Brewery/Downstairs"}, {{262, 4}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Chest Game/Prize"}, {{262, 10}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Chicken House/Bombable Wall"}, {{264, 4}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Aginah's Cave/Cave"}, {{266, 4}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Dam/Inside"}, {{267, 4}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Mimic Cave/Cave"}, {{268, 4}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Mire Shed/Shed"}, {{269, 4}, {269, 5}})
    updateSectionChestCountFromRoomSlotList(segment, {"@King's Tomb/The Crypt"}, {{275, 4}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Waterfall Fairy/Cave"}, {{276, 4}, {276, 5}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Pyramid Fairy/Big Bomb Spot"}, {{278, 4}, {278, 5}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Spike Cave/Cave"}, {{279, 4}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Graveyard Ledge/Cave"}, {{283, 9, 8}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Cave 45/Circle of Bushes"}, {{283, 10}}) --2, Game is bugged and uses the same sub-room slot as the front part of Graveyard Ledge
    updateSectionChestCountFromRoomSlotList(segment, {"@C-Shaped House/House"}, {{284, 4}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Blind's House/Basement"}, {{285, 5}, {285, 6}, {285, 7}, {285, 8}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Blind's House/Bombable Wall"}, {{285, 4}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Hype Cave/Cave"}, {{286, 4}, {286, 5}, {286, 6}, {286, 7}, {286, 10}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Ice Rod Cave/Cave"}, {{288, 4}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Mini Moldorm Cave/Cave"}, {{291, 4}, {291, 5}, {291, 6}, {291, 7}, {291, 10}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Bonk Rocks/Cave"}, {{292, 4}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Checkerboard Cave/Cave"}, {{294, 9, 1}})
    updateSectionChestCountFromRoomSlotList(segment, {"@Hammer Pegs/Cave"}, {{295, 10, 2}})
end

function updateDungeonItemsFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    --Dungeon Data
    if not AUTOTRACKER_DISABLE_ITEM_TRACKING and Tracker.ActiveVariantUID ~= "items_only" then
        --Dungeon Items
        updateToggleItemFromByteAndFlag(segment, "gt_bigkey", 0x7ef366, 0x04)
        updateToggleItemFromByteAndFlag(segment, "tr_bigkey", 0x7ef366, 0x08)
        updateToggleItemFromByteAndFlag(segment, "tt_bigkey", 0x7ef366, 0x10)
        updateToggleItemFromByteAndFlag(segment, "toh_bigkey", 0x7ef366, 0x20)
        updateToggleItemFromByteAndFlag(segment, "ip_bigkey", 0x7ef366, 0x40)
        updateToggleItemFromByteAndFlag(segment, "sw_bigkey", 0x7ef366, 0x80)
        updateToggleItemFromByteAndFlag(segment, "mm_bigkey", 0x7ef367, 0x01)
        updateToggleItemFromByteAndFlag(segment, "pod_bigkey", 0x7ef367, 0x02)
        updateToggleItemFromByteAndFlag(segment, "sp_bigkey", 0x7ef367, 0x04)
        updateToggleItemFromByteAndFlag(segment, "at_bigkey", 0x7ef367, 0x08)
        updateToggleItemFromByteAndFlag(segment, "dp_bigkey", 0x7ef367, 0x10)
        updateToggleItemFromByteAndFlag(segment, "ep_bigkey", 0x7ef367, 0x20)
        updateToggleItemFromByteAndFlag(segment, "hc_bigkey", 0x7ef367, 0xc0)

        updateToggleItemFromByteAndFlag(segment, "gt_map", 0x7ef368, 0x04)
        updateToggleItemFromByteAndFlag(segment, "tr_map", 0x7ef368, 0x08)
        updateToggleItemFromByteAndFlag(segment, "tt_map", 0x7ef368, 0x10)
        updateToggleItemFromByteAndFlag(segment, "toh_map", 0x7ef368, 0x20)
        updateToggleItemFromByteAndFlag(segment, "ip_map", 0x7ef368, 0x40)
        updateToggleItemFromByteAndFlag(segment, "sw_map", 0x7ef368, 0x80)
        updateToggleItemFromByteAndFlag(segment, "mm_map", 0x7ef369, 0x01)
        updateToggleItemFromByteAndFlag(segment, "pod_map", 0x7ef369, 0x02)
        updateToggleItemFromByteAndFlag(segment, "sp_map", 0x7ef369, 0x04)
        updateToggleItemFromByteAndFlag(segment, "at_map", 0x7ef369, 0x08)
        updateToggleItemFromByteAndFlag(segment, "dp_map", 0x7ef369, 0x10)
        updateToggleItemFromByteAndFlag(segment, "ep_map", 0x7ef369, 0x20)
        updateToggleItemFromByteAndFlag(segment, "hc_map", 0x7ef369, 0xc0)

        updateToggleItemFromByteAndFlag(segment, "gt_compass", 0x7ef364, 0x04)
        updateToggleItemFromByteAndFlag(segment, "tr_compass", 0x7ef364, 0x08)
        updateToggleItemFromByteAndFlag(segment, "tt_compass", 0x7ef364, 0x10)
        updateToggleItemFromByteAndFlag(segment, "toh_compass", 0x7ef364, 0x20)
        updateToggleItemFromByteAndFlag(segment, "ip_compass", 0x7ef364, 0x40)
        updateToggleItemFromByteAndFlag(segment, "sw_compass", 0x7ef364, 0x80)
        updateToggleItemFromByteAndFlag(segment, "mm_compass", 0x7ef365, 0x01)
        updateToggleItemFromByteAndFlag(segment, "pod_compass", 0x7ef365, 0x02)
        updateToggleItemFromByteAndFlag(segment, "sp_compass", 0x7ef365, 0x04)
        updateToggleItemFromByteAndFlag(segment, "at_compass", 0x7ef365, 0x08)
        updateToggleItemFromByteAndFlag(segment, "dp_compass", 0x7ef365, 0x10)
        updateToggleItemFromByteAndFlag(segment, "ep_compass", 0x7ef365, 0x20)
        updateToggleItemFromByteAndFlag(segment, "hc_compass", 0x7ef365, 0xc0)

        refreshMCBK()

        --Small Keys
        if OBJ_DOORSHUFFLE.CurrentStage == 0 then
            updateDungeonKeysFromPrefix(segment, "hc", 0x7ef37c)
            updateDungeonKeysFromPrefix(segment, "ep", 0x7ef37e)
            updateDungeonKeysFromPrefix(segment, "dp", 0x7ef37f)
            updateDungeonKeysFromPrefix(segment, "toh", 0x7ef386)
            updateDungeonKeysFromPrefix(segment, "at", 0x7ef380)
            updateDungeonKeysFromPrefix(segment, "pod", 0x7ef382)
            updateDungeonKeysFromPrefix(segment, "sp", 0x7ef381)
            updateDungeonKeysFromPrefix(segment, "sw", 0x7ef384)
            updateDungeonKeysFromPrefix(segment, "tt", 0x7ef387)
            updateDungeonKeysFromPrefix(segment, "ip", 0x7ef385)
            updateDungeonKeysFromPrefix(segment, "mm", 0x7ef383)
            updateDungeonKeysFromPrefix(segment, "tr", 0x7ef388)
            updateDungeonKeysFromPrefix(segment, "gt", 0x7ef389)
        end

        --Refresh Dungeon Calc
        updateDungeonKeysFromMemorySegment(nil)
    end
end

function updateDungeonKeysFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    if AUTOTRACKER_DISABLE_ITEM_TRACKING or Tracker.ActiveVariantUID == "items_only" then
        return true
    end

    InvalidateReadCaches()

    --Small Keys
    if segment then
        updateDungeonKeysFromPrefix(segment, "hc", 0x7ef4e0)
        updateDungeonKeysFromPrefix(segment, "ep", 0x7ef4e2)
        updateDungeonKeysFromPrefix(segment, "dp", 0x7ef4e3)
        updateDungeonKeysFromPrefix(segment, "toh", 0x7ef4ea)
        updateDungeonKeysFromPrefix(segment, "at", 0x7ef4e4)
        updateDungeonKeysFromPrefix(segment, "pod", 0x7ef4e6)
        updateDungeonKeysFromPrefix(segment, "sp", 0x7ef4e5)
        updateDungeonKeysFromPrefix(segment, "sw", 0x7ef4e8)
        updateDungeonKeysFromPrefix(segment, "tt", 0x7ef4eb)
        updateDungeonKeysFromPrefix(segment, "ip", 0x7ef4e9)
        updateDungeonKeysFromPrefix(segment, "mm", 0x7ef4e7)
        updateDungeonKeysFromPrefix(segment, "tr", 0x7ef4ec)
        updateDungeonKeysFromPrefix(segment, "gt", 0x7ef4ed)
    end

    if AUTOTRACKER_DISABLE_LOCATION_TRACKING then
        return true
    end

    if OBJ_RACEMODE.CurrentStage == 0 then
        --Collected Chests/Items In Dungeons
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
    if not isInGame() then
        return false
    end

    if AUTOTRACKER_DISABLE_ITEM_TRACKING or OBJ_RACEMODE.CurrentStage > 0 then
        return true
    end

    InvalidateReadCaches()

    local dungeon = Tracker:FindObjectForCode(DungeonIdMap[OBJ_DUNGEON.AcquiredCount])
    if dungeon and (dungeon.Active or dungeon.CurrentStage > 0) then
        dungeon = nil
    end

    local pendantData = ReadU8(segment, 0x7ef374)

    if dungeon then
        local diffData = ((DUNGEON_PRIZE_DATA & 0xff00) >> 8) ~ pendantData
        if numberOfSetBits(diffData) == 1 and diffData & pendantData > 0 then
            if diffData & pendantData == 4 then
                dungeon.CurrentStage = 4
            else
                dungeon.CurrentStage = 3
            end
        end
    end

    DUNGEON_PRIZE_DATA = (DUNGEON_PRIZE_DATA & 0x00ff) + (pendantData << 8)
end

function updateDungeonCrystalFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    if AUTOTRACKER_DISABLE_ITEM_TRACKING or OBJ_RACEMODE.CurrentStage > 0 then
        return true
    end

    InvalidateReadCaches()

    local dungeon = Tracker:FindObjectForCode(DungeonIdMap[OBJ_DUNGEON.AcquiredCount])
    if dungeon and (dungeon.Active or dungeon.CurrentStage > 0) then
        dungeon = nil
    end

    local crystalData = ReadU8(segment, 0x7ef37a)

    if dungeon then
        local diffData = (DUNGEON_PRIZE_DATA & 0xff) ~ crystalData
        if numberOfSetBits(diffData) == 1 and diffData & crystalData > 0 then
            dungeon.CurrentStage = 1
        end
    end

    DUNGEON_PRIZE_DATA = (DUNGEON_PRIZE_DATA & 0xff00) + crystalData
end

function updateGTBKFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if not (SEGMENT_GTTORCHROOM and SEGMENT_GTBIGKEYCOUNT) then
        return false
    end

    if Tracker.ActiveVariantUID == "items_only" or OBJ_RACEMODE.CurrentStage > 0 then
        return true
    end

    local gtBK = Tracker:FindObjectForCode("gt_bkgame")

    if gtBK and OBJ_DUNGEON.AcquiredCount == 26 then --if in GT
        local gtTorchRoom = 0
        if OBJ_DOORSHUFFLE.CurrentStage < 2 then
            gtTorchRoom = ReadU16(SEGMENT_GTTORCHROOM, 0x7ef118) --TODO: Fix this so then the torch can count in crossed door shuffle
        end
        local gtCount = ReadU8(SEGMENT_GTBIGKEYCOUNT, 0x7ef42a) & 0x1f

        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print("GT Torch Visited:", (gtTorchRoom & 0x8) > 0)
            print("GT Torch Collected:", (gtTorchRoom & 0x400) > 0)
            print("GT Raw Count:", gtCount)
        end

        if gtCount and (gtTorchRoom & 0x400) == 0 and (gtTorchRoom & 0x8) > 0 then
            gtBK.AcquiredCount = gtCount + 1
        else
            gtBK.AcquiredCount = gtCount
        end
    end
end

function updateHeartPiecesFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if not AUTOTRACKER_DISABLE_ITEM_TRACKING then
        updateConsumableItemFromByte(segment, "heartpiece", 0x7ef448)
    end
end

function updateHeartContainersFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if not AUTOTRACKER_DISABLE_ITEM_TRACKING then
        local pieces = Tracker:FindObjectForCode("heartpiece")
        local containers = Tracker:FindObjectForCode("heartcontainer")

        if pieces and containers then
            local maxHealth = (ReadU8(segment, 0x7ef36c) // 8) - 3

            if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                print("Pieces: ", pieces.AcquiredCount)
                print("Max Health: ", maxHealth)
            end

            containers.AcquiredCount = maxHealth - (pieces.AcquiredCount // 4)
        end
    end
end

function updateStatisticsFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if not AUTOTRACKER_HAS_DONE_POST_GAME_SUMMARY then
        -- Read completion timer
        local hours, minutes, seconds, frames = read32BitTimer(segment, 0x7ef43e)

        local collection_rate = ReadU8(segment, 0x7ef423)
        local deaths = ReadU8(segment, 0x7ef449)
        local bonks = ReadU8(segment, 0x7ef420)

        local markdown = string.format(AUTOTRACKER_STATS_MARKDOWN_FORMAT, collection_rate, deaths, bonks, hours, minutes, seconds, frames)
        ScriptHost:PushMarkdownNotification(NotificationType.Celebration, markdown)
    end

    AUTOTRACKER_HAS_DONE_POST_GAME_SUMMARY = true

    return true
end
