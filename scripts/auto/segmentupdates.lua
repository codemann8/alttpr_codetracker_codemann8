function updateModuleIdFromMemorySegment(segment)
    local mainModuleIdx = segment:ReadUInt8(0x7e0010)

    if mainModuleIdx == 0 then
        START_TIME = os.time()
    end

    if mainModuleIdx ~= OBJ_MODULE.AcquiredCount and mainModuleIdx ~= 0x0e then
        OBJ_MODULE.AcquiredCount = mainModuleIdx

        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print("CURRENT MODULE:", mainModuleIdx, string.format("0x%2X", mainModuleIdx))
        end

        if mainModuleIdx == 0x07 or mainModuleIdx == 0x09 then
            updateDungeonFromStatus(false)
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

    local owarea = ReadU16(segment, 0x7e008a)

    if OBJ_OWAREA.AcquiredCount ~= owarea then
        if owarea > 0 and OBJ_OWAREA.AcquiredCount > 0 then
            updateDungeonFromStatus(true)
        else
            OBJ_OWAREA.AcquiredCount = owarea
        end
    end
end

function updateRoomIdFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    OBJ_ROOM.AcquiredCount = ReadU16(segment, 0x7e00a0)

    --updateDungeonFromStatus(true) --call if wanting to track room changes within a dungeon
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
    updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Spec Rock/Up On Top", 3)
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
    updateSectionChestCountFromByteAndFlag(segment, "@Lost Woods/Mushroom Spot",        0x7ef411, 0x10)
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
            updateDoorKeyCountFromRoomSlotList(segment, "hc_potkey", {{114, 10}, {113, 10}, {33, 10}})
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
        updateSectionChestCountFromRoomSlotList(segment, "@Hyrule Castle & Sanctuary/First", {{114, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Hyrule Castle & Sanctuary/Boomerang\\Prison", {{113, 4}, {128, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Hyrule Castle & Sanctuary/Dark Cross", {{50, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Hyrule Castle & Sanctuary/Back", {{17, 4}, {17, 5}, {17, 6}})
        updateSectionChestCountFromRoomSlotList(segment, "@Hyrule Castle & Sanctuary/Sanctuary", {{18, 4}})

        updateSectionChestCountFromRoomSlotList(segment, "@Eastern Palace/Front", {{185, 4}, {170, 4}, {168, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Eastern Palace/Big Chest", {{169, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Eastern Palace/Big Key Chest", {{184, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Eastern Palace/Armos", {{200, 11}})

        updateSectionChestCountFromRoomSlotList(segment, "@Desert Palace/Eyegore Room", {{116, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Desert Palace/Popo Chest", {{133, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Desert Palace/Cannonball Chest", {{117, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Desert Palace/Torch", {{115, 10}})
        updateSectionChestCountFromRoomSlotList(segment, "@Desert Palace/Big Chest", {{115, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Desert Palace/Lanmolas", {{51, 11}})

        updateSectionChestCountFromRoomSlotList(segment, "@Tower of Hera/Lobby\\Cage", {{135, 10}, {119, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Tower of Hera/Basement", {{135, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Tower of Hera/Compass Chest", {{39, 5}})
        updateSectionChestCountFromRoomSlotList(segment, "@Tower of Hera/Big Chest", {{39, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Tower of Hera/Moldorm", {{7, 11}})

        updateSectionChestCountFromRoomSlotList(segment, "@Agahnim's Tower/Front", {{224, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Agahnim's Tower/Back", {{208, 4}})

        updateSectionChestCountFromRoomSlotList(segment, "@Palace of Darkness/Shooter Chest", {{9, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Palace of Darkness/Bow Side", {{43, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Palace of Darkness/Arena Ledge", {{42, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Palace of Darkness/Arena Chest", {{42, 5}})
        updateSectionChestCountFromRoomSlotList(segment, "@Palace of Darkness/Stalfos Basement", {{10, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Palace of Darkness/Big Key Chest", {{58, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Palace of Darkness/Dark Maze", {{25, 4}, {25, 5}})
        updateSectionChestCountFromRoomSlotList(segment, "@Palace of Darkness/Big Chest", {{26, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Palace of Darkness/Turtle Room", {{26, 5}})
        updateSectionChestCountFromRoomSlotList(segment, "@Palace of Darkness/Rupee Basement", {{106, 4}, {106, 5}})
        updateSectionChestCountFromRoomSlotList(segment, "@Palace of Darkness/Harmless Hellway", {{26, 6}})
        updateSectionChestCountFromRoomSlotList(segment, "@Palace of Darkness/Helmasaur", {{90, 11}})

        updateSectionChestCountFromRoomSlotList(segment, "@Swamp Palace/Entrance Chest", {{40, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Swamp Palace/Bomb Wall", {{55, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Swamp Palace/Left\\South Side", {{53, 4}, {52, 4}, {70, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Swamp Palace/Big Chest", {{54, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Swamp Palace/Back", {{118, 4}, {118, 5}, {102, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Swamp Palace/Arrghus", {{6, 11}})

        updateSectionChestCountFromRoomSlotList(segment, "@Skull Woods/Front", {{103, 4}, {104, 4}, {87, 4}, {87, 5}, {88, 5}})
        updateSectionChestCountFromRoomSlotList(segment, "@Skull Woods/Big Chest", {{88, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Skull Woods/Bridge", {{89, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Skull Woods/Mothula", {{41, 11}})

        updateSectionChestCountFromRoomSlotList(segment, "@Thieves Town/Front", {{219, 4}, {219, 5}, {203, 4}, {220, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Thieves Town/Attic Chest", {{101, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Thieves Town/Prison Cell", {{69, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Thieves Town/Big Chest", {{68, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Thieves Town/Blind", {{172, 11}})

        updateSectionChestCountFromRoomSlotList(segment, "@Ice Palace/Pengator Room", {{46, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ice Palace/Spike Room", {{95, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ice Palace/Ice Breaker", {{31, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ice Palace/Tongue Pull", {{63, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ice Palace/Freezor Chest", {{126, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ice Palace/Ice T", {{174, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ice Palace/Big Chest", {{158, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ice Palace/Khold", {{222, 11}})

        updateSectionChestCountFromRoomSlotList(segment, "@Misery Mire/Front", {{162, 4}, {179, 4}, {194, 4}, {195, 5}})
        updateSectionChestCountFromRoomSlotList(segment, "@Misery Mire/Left Side", {{193, 4}, {209, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Misery Mire/Big Chest", {{195, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Misery Mire/Vitreous", {{144, 11}})

        updateSectionChestCountFromRoomSlotList(segment, "@Turtle Rock/Compass Room", {{214, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Turtle Rock/Roller Room", {{183, 4}, {183, 5}})
        updateSectionChestCountFromRoomSlotList(segment, "@Turtle Rock/Chain Chomp", {{182, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Turtle Rock/Lava Chest", {{20, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Turtle Rock/Big Chest", {{36, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Turtle Rock/Crystaroller Chest", {{4, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Turtle Rock/Laser Bridge", {{213, 4}, {213, 5}, {213, 6}, {213, 7}})
        updateSectionChestCountFromRoomSlotList(segment, "@Turtle Rock/Trinexx", {{164, 11}})

        updateSectionChestCountFromRoomSlotList(segment, "@Ganon's Tower/Hope Room", {{140, 5}, {140, 6}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ganon's Tower/Torch", {{140, 3}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ganon's Tower/Stalfos Room", {{123, 4}, {123, 5}, {123, 6}, {123, 7}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ganon's Tower/Map Chest", {{139, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ganon's Tower/Firesnake\\Rando", {{125, 4}, {124, 4}, {124, 5}, {124, 6}, {124, 7}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ganon's Tower/Compass Room", {{157, 4}, {157, 5}, {157, 6}, {157, 7}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ganon's Tower/Bob\\Ice Armos", {{140, 7}, {28, 4}, {28, 5}, {28, 6}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ganon's Tower/Tile Room", {{141, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ganon's Tower/Big Chest", {{140, 4}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ganon's Tower/Mini Helmasaur", {{61, 4}, {61, 5}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ganon's Tower/Pre-Moldorm", {{61, 6}})
        updateSectionChestCountFromRoomSlotList(segment, "@Ganon's Tower/Validation", {{77, 4}})
    end

    --Marking Bosses as Complete
    updateBossChestCountFromRoom(segment, "@Eastern Palace/Armos", {200, 11})
    updateBossChestCountFromRoom(segment, "@Desert Palace/Lanmolas", {51, 11})
    updateBossChestCountFromRoom(segment, "@Tower of Hera/Moldorm", {7, 11})
    updateBossChestCountFromRoom(segment, "@Palace of Darkness/Helmasaur", {90, 11})
    updateBossChestCountFromRoom(segment, "@Swamp Palace/Arrghus", {6, 11})
    updateBossChestCountFromRoom(segment, "@Skull Woods/Mothula", {41, 11})
    updateBossChestCountFromRoom(segment, "@Thieves Town/Blind", {172, 11})
    updateBossChestCountFromRoom(segment, "@Ice Palace/Khold", {222, 11})
    updateBossChestCountFromRoom(segment, "@Misery Mire/Vitreous", {144, 11})
    updateBossChestCountFromRoom(segment, "@Turtle Rock/Trinexx", {164, 11})

    --Refresh Dungeon Calc
    updateDungeonKeysFromMemorySegment(nil)

    --Miscellaneous
    updateToggleItemFromByteAndFlag(segment, "attic", 0x7ef0cb, 0x01)
    updateToggleItemFromByteAndFlag(segment, "aga2", 0x7ef01b, 0x08)

    --Underworld Locations
    updateSectionChestCountFromRoomSlotList(segment, "@Link's House/By The Door", {{0, 10}})
    updateSectionChestCountFromRoomSlotList(segment, "@The Well/Cave", {{47, 5}, {47, 6}, {47, 7}, {47, 8}})
    updateSectionChestCountFromRoomSlotList(segment, "@The Well/Bombable Wall", {{47, 4}})
    updateSectionChestCountFromRoomSlotList(segment, "@Hookshot Cave/Bonkable Chest", {{60, 7}})
    updateSectionChestCountFromRoomSlotList(segment, "@Hookshot Cave/Back", {{60, 4}, {60, 5}, {60, 6}})
    updateSectionChestCountFromRoomSlotList(segment, "@Secret Passage/Hallway", {{85, 4}})
    updateSectionChestCountFromRoomSlotList(segment, "@Lost Woods/Forest Hideout", {{225, 9, 4}})
    updateSectionChestCountFromRoomSlotList(segment, "@Forest Hideout/Cave", {{225, 9, 4}})
    updateSectionChestCountFromRoomSlotList(segment, "@Lumberjack Cave/Cave", {{226, 9}})
    updateSectionChestCountFromRoomSlotList(segment, "@Paradox Cave/Top", {{239, 4}, {239, 5}, {239, 6}, {239, 7}, {239, 8}})
    updateSectionChestCountFromRoomSlotList(segment, "@Super-Bunny Cave/Cave", {{248, 4}, {248, 5}})
    updateSectionChestCountFromRoomSlotList(segment, "@Spiral Cave/Cave", {{254, 4}})
    updateSectionChestCountFromRoomSlotList(segment, "@Paradox Cave/Bottom", {{255, 4}, {255, 5}})
    updateSectionChestCountFromRoomSlotList(segment, "@Tavern/Back Room", {{259, 4}})
    updateSectionChestCountFromRoomSlotList(segment, "@Link's House/By The Door", {{260, 4}})
    updateSectionChestCountFromRoomSlotList(segment, "@Sahasrala's Hut/Closet", {{261, 4}, {261, 5}, {261, 6}})
    updateSectionChestCountFromRoomSlotList(segment, "@Brewery/Downstairs", {{262, 4}})
    updateSectionChestCountFromRoomSlotList(segment, "@Chest Game/Prize", {{262, 10}})
    updateSectionChestCountFromRoomSlotList(segment, "@Chicken House/Bombable Wall", {{264, 4}})
    updateSectionChestCountFromRoomSlotList(segment, "@Aginah's Cave/Cave", {{266, 4}})
    updateSectionChestCountFromRoomSlotList(segment, "@Dam/Inside", {{267, 4}})
    updateSectionChestCountFromRoomSlotList(segment, "@Mimic Cave/Cave", {{268, 4}})
    updateSectionChestCountFromRoomSlotList(segment, "@Mire Shed/Shed", {{269, 4}, {269, 5}})
    updateSectionChestCountFromRoomSlotList(segment, "@King's Tomb/The Crypt", {{275, 4}})
    updateSectionChestCountFromRoomSlotList(segment, "@Waterfall Fairy/Cave", {{276, 4}, {276, 5}})
    updateSectionChestCountFromRoomSlotList(segment, "@Pyramid Fairy/Big Bomb Spot", {{278, 4}, {278, 5}})
    updateSectionChestCountFromRoomSlotList(segment, "@Spike Cave/Cave", {{279, 4}})
    updateSectionChestCountFromRoomSlotList(segment, "@C-Shaped House/House", {{284, 4}})
    updateSectionChestCountFromRoomSlotList(segment, "@Blind's House/Basement", {{285, 5}, {285, 6}, {285, 7}, {285, 8}})
    updateSectionChestCountFromRoomSlotList(segment, "@Blind's House/Bombable Wall", {{285, 4}})
    updateSectionChestCountFromRoomSlotList(segment, "@Hype Cave/Cave", {{286, 4}, {286, 5}, {286, 6}, {286, 7}, {286, 10}})
    updateSectionChestCountFromRoomSlotList(segment, "@Ice Rod Cave/Cave", {{288, 4}})
    updateSectionChestCountFromRoomSlotList(segment, "@Mini Moldorm Cave/Cave", {{291, 4}, {291, 5}, {291, 6}, {291, 7}, {291, 10}})
    updateSectionChestCountFromRoomSlotList(segment, "@Bonk Rocks/Cave", {{292, 4}})
	
	if OBJ_RACEMODE.CurrentStage == 0 then
		updateSectionChestCountFromRoomSlotList(segment, "@Checkerboard Cave/Cave", {{294, 9, 1}})
		updateSectionChestCountFromRoomSlotList(segment, "@Hammer Pegs/Cave", {{295, 10, 2}})
		updateSectionChestCountFromRoomSlotList(segment, "@Graveyard Ledge/Cave", {{283, 9, 8}})
		updateSectionChestCountFromRoomSlotList(segment, "@Spectacle Rock/Cave", {{234, 10, 2}})
		updateSectionChestCountFromRoomSlotList(segment, "@Cave 45/Circle of Bushes", {{283, 10}}) --2, Game is bugged and uses the same sub-room slot as the front part of Graveyard Ledge
	else
		updateSectionChestCountFromRoomSlotList(segment, "@Checkerboard Cave/Cave", {{294, 9}})
		updateSectionChestCountFromRoomSlotList(segment, "@Hammer Pegs/Cave", {{295, 10}})
		updateSectionChestCountFromRoomSlotList(segment, "@Graveyard Ledge/Cave", {{283, 9}})
		updateSectionChestCountFromRoomSlotList(segment, "@Spectacle Rock/Cave", {{234, 10}})
		updateSectionChestCountFromRoomSlotList(segment, "@Cave 45/Circle of Bushes", {{283, 10}}) --2, seperated this out in case a fix for cave 45 ever comes out.
	end
end

function updateDungeonItemsFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    --Dungeon Data
    if not AUTOTRACKER_DISABLE_ITEM_TRACKING and Tracker.ActiveVariantUID ~= "items_only"then
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
    if segment and OBJ_DOORSHUFFLE.CurrentStage > 0 then
        updateDungeonKeysFromPrefix(segment, "hc", 0x7ef4e1)
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
