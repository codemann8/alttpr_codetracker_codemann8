function updateDungeonFromStatus(areaChanged)
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

    local dungeonMap =
    {
                      [0x01] = 254, [0x02] = 254,               [0x04] = 254,               [0x06] = 254, [0x07] = 254,               [0x09] = 254, [0x0a] = 254, [0x0b] = 254, [0x0c] = 26,  [0x0d] = 254, [0x0e] = 18,
                      [0x11] = 0,   [0x12] = 0,   [0x13] = 254, [0x14] = 254, [0x15] = 254, [0x16] = 254, [0x17] = 254,               [0x19] = 254, [0x1a] = 254, [0x1b] = 254, [0x1c] = 254, [0x1d] = 254, [0x1e] = 254, [0x1f] = 254,
        [0x20] = 254, [0x21] = 254, [0x22] = 254, [0x23] = 24,  [0x24] = 24,                [0x26] = 254, [0x27] = 254, [0x28] = 10,  [0x29] = 254, [0x2a] = 254, [0x2b] = 254,                             [0x2e] = 254,
        [0x30] = 254, [0x31] = 254, [0x32] = 254, [0x33] = 254, [0x34] = 254, [0x35] = 254, [0x36] = 254, [0x37] = 254, [0x38] = 254, [0x39] = 254, [0x3a] = 254, [0x3b] = 254,               [0x3d] = 254, [0x3e] = 254, [0x3f] = 254,
        [0x40] = 254, [0x41] = 254, [0x42] = 254, [0x43] = 254, [0x44] = 254, [0x45] = 254, [0x46] = 254,                             [0x49] = 254, [0x4a] = 12,  [0x4b] = 254, [0x4c] = 254, [0x4d] = 254, [0x4e] = 254, [0x4f] = 254,
        [0x50] = 254, [0x51] = 254, [0x52] = 254, [0x53] = 254, [0x54] = 254,               [0x56] = 16,  [0x57] = 16,  [0x58] = 16,  [0x59] = 16,  [0x5a] = 254, [0x5b] = 254, [0x5c] = 254, [0x5d] = 254, [0x5e] = 254, [0x5f] = 254,
        [0x60] = 2,   [0x61] = 2,   [0x62] = 2,   [0x63] = 6,   [0x64] = 254, [0x65] = 254, [0x66] = 254, [0x67] = 16,  [0x68] = 16,                [0x6a] = 254, [0x6b] = 254, [0x6c] = 254, [0x6d] = 254, [0x6e] = 254,
        [0x70] = 254, [0x71] = 254, [0x72] = 254, [0x73] = 254, [0x74] = 254, [0x75] = 254, [0x76] = 254, [0x77] = 20,                                            [0x7b] = 254, [0x7c] = 254, [0x7d] = 254, [0x7e] = 254, [0x7f] = 254,
        [0x80] = 254, [0x81] = 254, [0x82] = 254, [0x83] = 6,   [0x84] = 6,   [0x85] = 6,                 [0x87] = 254,               [0x89] = 254,               [0x8b] = 254, [0x8c] = 254, [0x8d] = 254, [0x8e] = 254,
        [0x90] = 254, [0x91] = 254, [0x92] = 254, [0x93] = 254,               [0x95] = 254, [0x96] = 254, [0x97] = 254, [0x98] = 14,  [0x99] = 254,               [0x9b] = 254, [0x9c] = 254, [0x9d] = 254, [0x9e] = 254, [0x9f] = 254,
        [0xa0] = 254, [0xa1] = 254, [0xa2] = 254, [0xa3] = 254, [0xa4] = 254, [0xa5] = 254, [0xa6] = 254, [0xa7] = 254, [0xa8] = 254, [0xa9] = 254, [0xaa] = 254, [0xab] = 254, [0xac] = 254,               [0xae] = 254, [0xaf] = 254,
        [0xb0] = 254, [0xb1] = 254, [0xb2] = 254, [0xb3] = 254, [0xb4] = 254, [0xb5] = 254, [0xb6] = 254, [0xb7] = 254, [0xb8] = 254, [0xb9] = 254, [0xba] = 254, [0xbb] = 254, [0xbc] = 254,               [0xbe] = 254, [0xbf] = 254,
        [0xc0] = 254, [0xc1] = 254, [0xc2] = 254, [0xc3] = 254, [0xc4] = 254, [0xc5] = 254, [0xc6] = 254, [0xc7] = 254, [0xc8] = 254, [0xc9] = 4,                 [0xcb] = 254, [0xcc] = 254,               [0xce] = 254,
        [0xd0] = 254, [0xd1] = 254, [0xd2] = 254,                             [0xd5] = 24,  [0xd6] = 24,                [0xd8] = 254, [0xd9] = 254, [0xda] = 254, [0xdb] = 22,  [0xdc] = 254,               [0xde] = 254,
        [0xe0] = 8
    }

    local overworldMap =
    {
        [0x02] = "light_world", [0x03] = "dm_west_bottom",
        [0x11] = "light_world", [0x13] = "light_world", [0x15] = "light_world", [0x11] = "lw_witch",
        [0x22] = "light_world", [0x1e] = "light_world",
        [0x28] = "light_world", [0x29] = "light_world", [0x2b] = "light_world", [0x2c] = "light_world",
        [0x32] = "light_world", [0x34] = "light_world", [0x37] = "light_world",
        [0x3a] = "light_world", [0x3b] = "light_world",
        [0x42] = "dw_west", [0x43] = "ddm_west", [0x47] = "ddm_top",
        [0x51] = "dw_west", [0x53] = "dw_west", [0x56] = "dw_witch",
        [0x5a] = "dw_west", [0x5b] = "dw_east", [0x5e] = "dw_east",
        [0x69] = "dw_south", [0x6b] = "dw_south", [0x6c] = "dw_south",
        [0x70] = "mire_area", [0x74] = "dw_south", [0x77] = "dw_southeast",
        [0x7b] = "dw_south"
    }

    local dungeons = {
        [0] = "hc", --sewer
        [2] = "hc",
        [4] = "ep",
        [6] = "dp",
        [8] = "at",
        [10] = "sp",
        [12] = "pod",
        [14] = "mm",
        [16] = "sw",
        [18] = "ip",
        [20] = "toh",
        [22] = "tt",
        [24] = "tr",
        [26] = "gt",
        [255] = "OW"
    }

    local dungeonSelect = {
        [0] = 0,
        [2] = 0,
        [4] = 1,
        [6] = 2,
        [8] = 4,
        [10] = 6,
        [12] = 5,
        [14] = 10,
        [16] = 7,
        [18] = 9,
        [20] = 3,
        [22] = 8,
        [24] = 11,
        [26] = 12
    }

    if OBJ_MODULE.AcquiredCount == 0x07 then --underworld
        OBJ_OWAREA.AcquiredCount = 0xff
        OBJ_ROOM.AcquiredCount = AutoTracker:ReadU16(0x7e00a0)

        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print("CURRENT ROOM:", OBJ_ROOM.AcquiredCount, string.format("0x%4X", OBJ_ROOM.AcquiredCount))
            print("CURRENT ROOM ORIGDUNGEON:", dungeons[roomMap[OBJ_ROOM.AcquiredCount]], roomMap[OBJ_ROOM.AcquiredCount], string.format("0x%2X", roomMap[OBJ_ROOM.AcquiredCount]))
        end

        local dungeonId = 0xff
        --dungeonId = ReadU8(segment, 0x7e040c) --to be used if 0x7e040c becomes unblocked

        if dungeonMap[OBJ_ROOM.AcquiredCount] then
            dungeonId = dungeonMap[OBJ_ROOM.AcquiredCount]
        end

        if dungeonId < 0xfe and OBJ_DUNGEON.AcquiredCount ~= dungeonLocal then
            OBJ_DUNGEON.AcquiredCount = dungeonId

            if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                print("CURRENT DUNGEON:", dungeons[OBJ_DUNGEON.AcquiredCount], OBJ_DUNGEON.AcquiredCount, string.format("0x%2X", OBJ_DUNGEON.AcquiredCount))
            end

            OBJ_DOORDUNGEON.ItemState:setState(dungeonSelect[OBJ_DUNGEON.AcquiredCount])

            --Update Dungeon Image
            if string.find(Tracker.ActiveVariantUID, "er_") then
                sendExternalMessage("dungeon", "er-" .. OBJ_DUNGEON.AcquiredCount)
            else
                sendExternalMessage("dungeon", OBJ_DUNGEON.AcquiredCount)
            end
        end
    elseif OBJ_MODULE.AcquiredCount == 0x09 then --overworld
        OBJ_ROOM.AcquiredCount = 0xffff
        OBJ_DUNGEON.AcquiredCount = 0xff

        local updateImage = true

        local owarea = AutoTracker:ReadU8(0x7e008a)
        if areaChanged then
            if owarea >= 0x40 and owarea < 0x80 and OBJ_OWAREA.AcquiredCount < 0x40 and OBJ_OWAREA.AcquiredCount >= 0x80 then
                updateImage = false
            end
        end

        OBJ_OWAREA.AcquiredCount = owarea

        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print("CURRENT OW:", OBJ_OWAREA.AcquiredCount, string.format("0x%2X", OBJ_OWAREA.AcquiredCount))
        end

        --Region Autotracking
        if OBJ_RACEMODE.CurrentStage == 0 and (not AUTOTRACKER_DISABLE_REGION_TRACKING) and OBJ_ENTRANCE.CurrentStage > 0 then
            if OBJ_OWAREA.AcquiredCount < 0xff and overworldMap[OBJ_OWAREA.AcquiredCount] then
                local region = Tracker:FindObjectForCode(overworldMap[OBJ_OWAREA.AcquiredCount])
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
    else
        OBJ_ROOM.AcquiredCount = 0xffff
    end
end

function updateProgressiveItemFromByte(segment, code, address, offset)
    local item = Tracker:FindObjectForCode(code)
    if item then
        -- Do not auto-track this the user has manually modified it
        if item.Owner.ModifiedByUser then
            return
        end

        local value = ReadU8(segment, address)
        if value + (offset or 0) - item.CurrentStage == 1 then
            itemFlippedOn(code)
        end
        item.CurrentStage = value + (offset or 0)
    end
end

function updateToggleItemFromByte(segment, code, address)
    local item = Tracker:FindObjectForCode(code)
    if item then
        -- Do not auto-track this the user has manually modified it
        if item.Owner.ModifiedByUser then
            return
        end

        local value = ReadU8(segment, address)
        if value > 0 then
            if not item.Active then
                itemFlippedOn(code)
            end
            item.Active = true
        else
            item.Active = false
        end
    end
end

function updateToggleItemFromByteAndFlag(segment, code, address, flag)
    local item = Tracker:FindObjectForCode(code)
    if item then
        -- Do not auto-track this the user has manually modified it
        if item.Owner.ModifiedByUser then
            return
        end

        local value = ReadU8(segment, address)
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(item.Name, code, flag)
        end

        local flagTest = value & flag

        if flagTest ~= 0 then
            if not item.Active then
                itemFlippedOn(code)
            end
            item.Active = true
        else
            item.Active = false
        end
    else
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print("Cannot find item", code)
        end
    end
end

function updateToggleFromRoomSlot(segment, code, slot)
    local item = Tracker:FindObjectForCode(code)
    if item then
        -- Do not auto-track this the user has manually modified it
        if item.Owner.ModifiedByUser then
            return
        end

        local roomData = ReadU16(segment, 0x7ef000 + (slot[1] * 2))

        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(roomData)
        end

        item.Active = (roomData & (1 << slot[2])) ~= 0
    end
end

function updateConsumableItemFromByte(segment, code, address)
    local item = Tracker:FindObjectForCode(code)
    if item then
        -- Do not auto-track this the user has manually modified it
        if item.Owner.ModifiedByUser then
            return
        end

        local value = ReadU8(segment, address)
        item.AcquiredCount = value
    else
        print("Couldn't find item: ", code)
    end
end

function updatePseudoProgressiveItemFromByteAndFlag(segment, code, address, flag)
    local item = Tracker:FindObjectForCode(code)
    if item then
        if item.Owner.ModifiedByUser then
            return
        end

        local value = ReadU8(segment, address)
        local flagTest = value & flag

        if flagTest ~= 0 then
            if item.CurrentStage == 0 then
                itemFlippedOn(code)
            end
            item.CurrentStage = math.max(1, item.CurrentStage)
        else
            item.CurrentStage = 0
        end
    end
end

function updateSectionChestCountFromByteAndFlag(segment, locationRef, address, flag, callback)
    local location = Tracker:FindObjectForCode(locationRef)
    if location then
        -- Do not auto-track this the user has manually modified it
        if location.Owner.ModifiedByUser then
            return
        end

        local value = ReadU8(segment, address)

        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(locationRef, value)
        end

        if (value & flag) ~= 0 then
            location.AvailableChestCount = 0
            if callback then
                callback(true)
            end
        else
            location.AvailableChestCount = location.ChestCount
            if callback then
                callback(false)
            end
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find location", locationRef)
    end
end

function updateSectionChestCountFromOverworldIndexAndFlag(segment, locationRef, index, callback)
    updateSectionChestCountFromByteAndFlag(segment, locationRef, 0x7ef280 + index, 0x40, callback)
end

function updateSectionChestCountFromRoomSlotList(segment, locationRef, roomSlots, callback)
    local location = Tracker:FindObjectForCode(locationRef)
    if location then
        -- Do not auto-track this the user has manually modified it
        if location.Owner.ModifiedByUser then
            return
        end

        local clearedCount = 0
        for i, slot in ipairs(roomSlots) do
            local roomData = ReadU16(segment, 0x7ef000 + (slot[1] * 2))

            if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                print(locationRef, roomData, 1 << slot[2])
            end

            if (roomData & (1 << slot[2])) ~= 0 then
                clearedCount = clearedCount + 1
            elseif OBJ_ENTRANCE.CurrentStage == 0 and slot[3] and roomData & slot[3] ~= 0 then
                clearedCount = clearedCount + 1
            end
        end

        location.AvailableChestCount = location.ChestCount - clearedCount

        if callback then
            callback(clearedCount > 0)
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find location", locationRef)
    end
end

function updateDungeonChestCountFromRoomSlotList(segment, chestRef, roomSlots, callback)
    local chest = Tracker:FindObjectForCode(chestRef)
    if chest then
        -- Do not auto-track this the user has manually modified it
        if chest.Owner.ModifiedByUser then
            return
        end

        local clearedCount = 0
        for i, slot in ipairs(roomSlots) do
            local roomData = ReadU16(segment, 0x7ef000 + (slot[1] * 2))

            if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                print(chestRef, roomData, 1 << slot[2])
            end

            if (roomData & (1 << slot[2])) ~= 0 then
                clearedCount = clearedCount + 1
            end
        end

        chest.AcquiredCount = chest.MaxCount - clearedCount

        if callback then
            callback(clearedCount > 0)
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find chest", chestRef)
    end
end

function updateDoorKeyCountFromRoomSlotList(segment, doorKeyRef, roomSlots, callback)
    local doorKey = Tracker:FindObjectForCode(doorKeyRef)
    if doorKey then
        local clearedCount = 0
        for i, slot in ipairs(roomSlots) do
            local roomData = ReadU16(segment, 0x7ef000 + (slot[1] * 2))

            if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                print(doorKeyRef, roomData, 1 << slot[2])
            end

            if (roomData & (1 << slot[2])) ~= 0 then
                clearedCount = clearedCount + 1
            elseif #slot > 2 then
                roomData = ReadU16(segment, 0x7ef000 + (slot[3] * 2))

                if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                    print(doorKeyRef, roomData, 1 << slot[2])
                end

                if (roomData & (1 << slot[4])) ~= 0 then
                    clearedCount = clearedCount + 1
                end
            end
        end

        doorKey.AcquiredCount = clearedCount

        if callback then
            callback(clearedCount > 0)
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find door/key", doorKeyRef)
    end
end

function updateDungeonKeysFromPrefix(segment, dungeonPrefix, address)
    local chestKeys = Tracker:FindObjectForCode(dungeonPrefix .. "_smallkey")
    if chestKeys then
        -- Do not auto-track this the user has manually modified it
        if chestKeys.Owner.ModifiedByUser then
            return
        end

        if OBJ_DOORSHUFFLE and OBJ_DOORSHUFFLE.CurrentStage > 0 then
            chestKeys.AcquiredCount = ReadU8(segment, address)
        else
            local doorsOpened = Tracker:FindObjectForCode(dungeonPrefix .. "_door")
            if doorsOpened then
                local currentKeys = 0

                local dungeons = {
                    [0] = "hc", --sewer
                    [2] = "hc",
                    [4] = "ep",
                    [6] = "dp",
                    [8] = "at",
                    [10] = "sp",
                    [12] = "pod",
                    [14] = "mm",
                    [16] = "sw",
                    [18] = "ip",
                    [20] = "toh",
                    [22] = "tt",
                    [24] = "tr",
                    [26] = "gt",
                    [255] = "OW"
                }

                if dungeons[OBJ_DUNGEON.AcquiredCount] == dungeonPrefix and ReadU8(segment, 0x7ef36f) ~= 0xff then
                    currentKeys = ReadU8(segment, 0x7ef36f)
                else
                    currentKeys = ReadU8(segment, address)
                end
                local potKeys = Tracker:FindObjectForCode(dungeonPrefix .. "_potkey")
                if potKeys then
                    chestKeys.AcquiredCount = currentKeys + doorsOpened.AcquiredCount - potKeys.AcquiredCount
                else
                    chestKeys.AcquiredCount = currentKeys + doorsOpened.AcquiredCount
                end
            end
        end
    end

    --update map/compass/big key
    local state = 0
    local item = Tracker:FindObjectForCode(dungeonPrefix .. "_bigkey")
    if item and item.Active then
        state = state + 0x4
    end

    item = Tracker:FindObjectForCode(dungeonPrefix .. "_compass")
    if item and item.Active then
        state = state + 0x2
    end

    item = Tracker:FindObjectForCode(dungeonPrefix .. "_map")
    if item and item.Active then
        state = state + 0x1
    end

    item = Tracker:FindObjectForCode(dungeonPrefix .. "_mcbk")
    if item then
        item:Set("state", state)
    end
end

function updateBossChestCountFromRoom(segment, locationRef, roomSlot)
    local location = Tracker:FindObjectForCode(locationRef)
    if location then
        -- Do not auto-track this the user has manually modified it
        if location.Owner.ModifiedByUser then
            return
        end

        local roomData = ReadU16(segment, 0x7ef000 + (roomSlot[1] * 2))

        if (roomData & (1 << roomSlot[2])) ~= 0 then
            location.AvailableChestCount = 0
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find location", locationRef)
    end
end

function updateSectionChestCountFromDungeon(locationRef, dungeonPrefix, address)
    local location = Tracker:FindObjectForCode(locationRef)
    if location then
        -- Do not auto-track this the user has manually modified it
        --if location.Owner.ModifiedByUser then
        --    return
        --end

        if OBJ_DOORSHUFFLE.CurrentStage == 2 then
            if SEGMENT_DUNGEONKEYS then
                location.AvailableChestCount = ReadU8(SEGMENT_DUNGEONKEYS, address)
            end
        else
            local chest = Tracker:FindObjectForCode(dungeonPrefix .. "_chest")
            if chest then
                local bigkey = Tracker:FindObjectForCode(dungeonPrefix .. "_bigkey")
                local map = Tracker:FindObjectForCode(dungeonPrefix .. "_map")
                local compass = Tracker:FindObjectForCode(dungeonPrefix .. "_compass")
                local smallkey = Tracker:FindObjectForCode(dungeonPrefix .. "_smallkey")
                local dungeonItems = 0

                if bigkey and bigkey.Active and OBJ_KEYSANITY.CurrentStage < 3 and dungeonPrefix ~= "hc" then
                    dungeonItems = dungeonItems + 1
                end

                if map and map.Active and OBJ_KEYSANITY.CurrentStage < 1 then
                    dungeonItems = dungeonItems + 1
                end

                if compass and compass.Active and OBJ_KEYSANITY.CurrentStage < 1 then
                    dungeonItems = dungeonItems + 1
                end

                if smallkey and smallkey.AcquiredCount and OBJ_KEYSANITY.CurrentStage < 2 then
                    dungeonItems = dungeonItems + smallkey.AcquiredCount
                end

                if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                    print(dungeonPrefix .. " Items", dungeonItems)
                    print(dungeonPrefix .. " Chests", chest.MaxCount - chest.AcquiredCount)
                end

                location.AvailableChestCount = math.max(location.ChestCount - ((chest.MaxCount - chest.AcquiredCount) - dungeonItems), 0)
            end
        end
    end
end

