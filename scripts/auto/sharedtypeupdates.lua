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

function updateIdsFromModule(moduleId)
    if not isInGame() then
        return false
    end

    InvalidateReadCaches()

    if AUTOTRACKER_DISABLE_LOCATION_TRACKING then
        return false
    end

    if string.find(Tracker.ActiveVariantUID, "items_only") then
        return false
    end

    if not (SEGMENT_LASTROOMID and SEGMENT_OWID) then
        return false
    end

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

    if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("MODULE: ", moduleId)
    end

    --update dungeon image
    if moduleId == 0x07 then --underworld
        local dungeonId = dungeons[OBJ_DUNGEON.AcquiredCount]

        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print("DUNGEON: ", dungeonId)
        end

        if dungeonId then
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
            if OBJ_DUNGEON.AcquiredCount < 255 then
                OBJ_DOORDUNGEON.ItemState:setState(dungeonSelect[OBJ_DUNGEON.AcquiredCount])
            end
            if string.find(Tracker.ActiveVariantUID, "er_") then
                sendExternalMessage("dungeon", "er-" .. dungeonId)
            else
                sendExternalMessage("dungeon", dungeonId)
            end
        end
    elseif moduleId == 0x09 then --overworld
        local owarea = ReadU8(SEGMENT_OWID, 0x7e008a)
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print("OW: ", owarea)
        end

        if owarea >= 0x40 and owarea < 0x80 then
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
end
