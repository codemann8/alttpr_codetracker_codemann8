function refreshMCBK()
    local dungeons =  {"hc", "ep", "dp", "at", "sp", "pod", "mm", "sw", "ip", "toh", "tt", "tr", "gt"}
    for i = 1, #dungeons do
        local state = 0
        local item = Tracker:FindObjectForCode(dungeons[i] .. "_bigkey")
        if item and item.Active then
            state = state + 0x4
        end

        item = Tracker:FindObjectForCode(dungeons[i] .. "_compass")
        if item and item.Active then
            state = state + 0x2
        end

        item = Tracker:FindObjectForCode(dungeons[i] .. "_map")
        if item and item.Active then
            state = state + 0x1
        end

        item = Tracker:FindObjectForCode(dungeons[i] .. "_mcbk")
        if item then
            item:Set("state", state)
        end
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

function updateToggleItemFromByteAndValue(segment, code, address, value)
    local item = Tracker:FindObjectForCode(code)
    if item then
        -- Do not auto-track this the user has manually modified it
        if item.Owner.ModifiedByUser then
            return
        end

        local slotValue = ReadU8(segment, address)
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(item.Name, code, flag)
        end

        if slotValue == value then
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
            location.AvailableChestCount = location.AvailableChestCount

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

function updateSectionChestCountFromRoomSlotList(segment, locationRef, roomSlots, altLocationRef)
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
            elseif OBJ_ENTRANCE.CurrentStage == 0 and OBJ_RACEMODE.CurrentStage == 0 and slot[3] and roomData & slot[3] ~= 0 then
                clearedCount = clearedCount + 1
            end
        end

        location.AvailableChestCount = location.ChestCount - clearedCount

        if altLocationRef then
            location = Tracker:FindObjectForCode(altLocationRef)
            if location then
                location.AvailableChestCount = location.ChestCount - clearedCount
            end
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
    -- Do not auto-track this the user has manually modified it
    if chestKeys.Owner.ModifiedByUser then
        return
    end

    InvalidateReadCaches()

    if OBJ_DOORSHUFFLE then
        if OBJ_DOORSHUFFLE.CurrentStage > 0 then
            NEW_KEY_SYSTEM = true
        elseif not NEW_KEY_SYSTEM then
            local offset = 0x7ef4e0
            while (offset <= 0x7ef4ed)
            do
                if AutoTracker:ReadU16(offset) > 0 then
                    NEW_KEY_SYSTEM = true
                    break
                end
                offset = offset + 2
            end
        end
    end

    if NEW_KEY_SYSTEM and ((OBJ_DOORSHUFFLE and OBJ_DOORSHUFFLE.CurrentStage > 0) or dungeonPrefix ~= "toh") then
    --if NEW_KEY_SYSTEM then --remove previous line if alttpr.com fixes ToH Cage issue
        if address > 0x7ef400 then
            chestKeys.AcquiredCount = ReadU8(segment, address) + (dungeonPrefix == "hc" and ReadU8(segment, address + 1) or 0)
        end
    elseif OBJ_KEYSANITY_SMALL.CurrentStage < 2 and address < 0x7ef400 then
        local doorsOpened = Tracker:FindObjectForCode(dungeonPrefix .. "_door")
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
        if potKeys and OBJ_POOL.CurrentStage == 0 then
            local offsetKey = 0
            if dungeonPrefix == "hc" and Tracker:FindObjectForCode("hc_bigkey").Active then
                offsetKey = 1
            end
            chestKeys.AcquiredCount = currentKeys + doorsOpened.AcquiredCount - (potKeys.AcquiredCount - offsetKey)
        else
            chestKeys.AcquiredCount = currentKeys + doorsOpened.AcquiredCount
        end
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

function updateChestCountFromDungeon(segment, dungeonPrefix, address)
    local item = Tracker:FindObjectForCode(dungeonPrefix .. "_item").ItemState
    if item then
        if OBJ_DOORSHUFFLE.CurrentStage == 2 then
            if segment then
                local chestCount = ReadU8(segment, address)
                if item.MaxCount < 99 then
                    item.AcquiredCount = chestCount
                else
                    item.AcquiredCount = item.MaxCount - chestCount
                end
            end
        else
            local chest = Tracker:FindObjectForCode(dungeonPrefix .. "_chest")
            local map = Tracker:FindObjectForCode(dungeonPrefix .. "_map")
            local compass = Tracker:FindObjectForCode(dungeonPrefix .. "_compass")
            local smallkey = Tracker:FindObjectForCode(dungeonPrefix .. "_smallkey")
            local bigkey = Tracker:FindObjectForCode(dungeonPrefix .. "_bigkey")
            local potkey = Tracker:FindObjectForCode(dungeonPrefix .. "_potkey")
            local dungeonItems = 0

            if map.Active and Tracker:FindObjectForCode("keysanity_map").CurrentStage == 0 then
                dungeonItems = dungeonItems + 1
            end

            if compass.Active and Tracker:FindObjectForCode("keysanity_compass").CurrentStage == 0 then
                dungeonItems = dungeonItems + 1
            end

            if smallkey.AcquiredCount and OBJ_KEYSANITY_SMALL.CurrentStage == 0 then
                dungeonItems = dungeonItems + smallkey.AcquiredCount
            end

            if bigkey.Active and OBJ_KEYSANITY_BIG.CurrentStage == 0 and dungeonPrefix ~= "hc" then
                dungeonItems = dungeonItems + 1
            end

            if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                print(dungeonPrefix .. " Dungeon Items", dungeonItems)
                print(dungeonPrefix .. " Chests", chest.MaxCount - chest.AcquiredCount)
            end

            if potkey and OBJ_POOL.CurrentStage > 0 then
                local addedKeys = potkey.AcquiredCount
                if OBJ_KEYSANITY_BIG.CurrentStage == 0 and dungeonPrefix == "hc" and bigkey.Active then
                    addedKeys = addedKeys - 1
                end
                item.AcquiredCount = math.max(item.MaxCount - (((chest.MaxCount - chest.AcquiredCount) - dungeonItems) + addedKeys), 0)
            else
                item.AcquiredCount = math.max(item.MaxCount - ((chest.MaxCount - chest.AcquiredCount) - dungeonItems), 0)
            end
        end
    end
end

