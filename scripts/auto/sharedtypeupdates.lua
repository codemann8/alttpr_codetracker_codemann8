function updateRoomLocation(segment, location, offset)
    offset = offset or 0
    local shouldRemove = false
    local function markLocation(locName, count)
        local remove = false
        loc = findObjectForCode(locName)
        if loc then
            if not loc.Owner.ModifiedByUser then
                loc.AvailableChestCount = loc.ChestCount - count
            end
            
            if loc.AvailableChestCount == 0 then
                if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                    print("Location cleared:", locName, count)
                end
                remove = true
            end
        else
            print("Couldn't find location", locName)
        end

        return remove
    end

    local clearedCount = 0
    if offset > 0 and type(location[1]) == "string" then
        -- Cave/Dungeon Pots
        for i, room in ipairs(location[2]) do
            local roomData = segment:ReadUInt16(0x7ef000 + offset + (room[1] * 2))
            for j, flag in ipairs(room[2]) do
                if (roomData & (1 << flag)) ~= 0 then
                    clearedCount = clearedCount + 1
                end
            end
        end

        shouldRemove = markLocation(location[1], clearedCount)
    else
        for i, slot in ipairs(offset == 0 and location[2] or location[3]) do
            local roomData = segment:ReadUInt16(0x7ef000 + offset + (slot[1] * 2))
            
            if (roomData & (1 << slot[2])) ~= 0 then
                clearedCount = clearedCount + 1
            elseif OBJ_ENTRANCE:getState() < 2 and OBJ_RACEMODE:getState() == 0 and slot[3] and roomData & slot[3] ~= 0 then
                if #location < 3 or Tracker:FindObjectForCode("ow_slot_" .. string.format("%02x", (location[3] + 0x40) % 0x80)).ItemState:getState() == 0 or Tracker:FindObjectForCode("pearl").Active then
                    clearedCount = clearedCount + 1
                end
            end
        end

        for i, name in ipairs(location[1]) do
            shouldRemove = markLocation(name, clearedCount)
        end
    end

    return shouldRemove
end

function updateChestCountFromDungeon(segment, dungeonPrefix, address)
    local item = Tracker:FindObjectForCode(dungeonPrefix .. "_item")
    if item then
        item = item.ItemState
        local chest = Tracker:FindObjectForCode(dungeonPrefix .. "_chest")
        local enemykey = Tracker:FindObjectForCode(dungeonPrefix .. "_enemykey")
        local potkey = Tracker:FindObjectForCode(dungeonPrefix .. "_potkey")
        local map = Tracker:FindObjectForCode(dungeonPrefix .. "_map")
        local compass = Tracker:FindObjectForCode(dungeonPrefix .. "_compass")
        local smallkey = Tracker:FindObjectForCode(dungeonPrefix .. "_smallkey")
        local bigkey = Tracker:FindObjectForCode(dungeonPrefix .. "_bigkey")
        local prize = Tracker:FindObjectForCode(dungeonPrefix)
        local dungeonItems = 0
        local clock = os.clock()

        if map.Active and OBJ_KEYMAP:getState() == 0 then
            dungeonItems = dungeonItems + 1
        end

        doMetric(METRICS.GETSTATE, "getState", clock)

        if compass.Active and OBJ_KEYCOMPASS:getState() == 0 then
            dungeonItems = dungeonItems + 1
        end

        if smallkey.AcquiredCount > 0 and OBJ_KEYSMALL:getState() == 0 then
            dungeonItems = dungeonItems + smallkey.AcquiredCount
        end

        if bigkey.Active and OBJ_KEYBIG:getState() == 0 and (dungeonPrefix ~= "hc" or OBJ_POOL_ENEMYDROP:getState() > 0) then
            dungeonItems = dungeonItems + 1
        end

        if OBJ_DOORSHUFFLE:getState() < 2 and OBJ_GLITCHMODE:getState() < 2 then
            item.DeductedCount = dungeonItems
        else
            item.DeductedCount = 0
        end

        if segment and OBJ_GLITCHMODE:getState() < 2 then
            clock = os.clock()
            local value = 0
            if INSTANCE.VERSION_MINOR < 5 then
                value = segment:ReadUInt8(address)
            else
                value = segment:ReadUInt16(address)
            end
            doMetric(METRICS.SEGMENTREAD, "segmentRead", clock)
            if value > 0 then
                INSTANCE.NEW_DUNGEONCOUNT_SYSTEM = true
            end
            if INSTANCE.NEW_SRAM_SYSTEM and dungeonPrefix == "hc" then
                local otherValue = 0
                if INSTANCE.VERSION_MINOR < 5 then
                    otherValue = segment:ReadUInt8(address + 1)
                else
                    otherValue = segment:ReadUInt16(address + 2)
                end
                if value ~= otherValue then
                    value = value + otherValue
                end
            end
            if (DATA.DungeonData[dungeonPrefix][10] > 0) and prize.Active and OBJ_KEYPRIZE:getState() > 0 then
                value = value + 1
            end
            if value ~= item.CollectedCount and CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                print(dungeonPrefix .. " from direct memory:")
                print(dungeonPrefix .. " Dungeon Items:", item.DeductedCount .. "/" .. item.ExemptedCount)
                print(dungeonPrefix .. " Checks:", value .. "/" .. item.MaxCount)
            end
            item.CollectedCount = value

            if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                print(dungeonPrefix .. " Dungeon Items:", item.DeductedCount)
                print(dungeonPrefix .. " Checks:", item.CollectedCount)
            end
        elseif (not INSTANCE.NEW_DUNGEONCOUNT_SYSTEM and OBJ_GLITCHMODE:getState() < 2) and not shouldChestCountUp() then
            local value = chest.AcquiredCount
            if enemykey and OBJ_POOL_ENEMYDROP:getState() > 0 then
                value = value + enemykey.AcquiredCount
            end
            if potkey and OBJ_POOL_DUNGEONPOT:getState() > 0 then
                value = value + potkey.AcquiredCount
            end
            if (DATA.DungeonData[dungeonPrefix][10] > 0) and prize.Active and OBJ_KEYPRIZE:getState() > 0 then
                value = value + 1
            end
            if value ~= item.CollectedCount and CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                print(dungeonPrefix .. " after calculation:")
                print(dungeonPrefix .. " Dungeon Items:", item.DeductedCount .. "/" .. item.ExemptedCount)
                print(dungeonPrefix .. " Checks:", value .. "/" .. item.MaxCount)
            end
            item.CollectedCount = value
        elseif OBJ_GLITCHMODE:getState() < 2 and address then
            local value = 0
            if INSTANCE.VERSION_MINOR < 5 then
                value = segment:ReadUInt8(address)
            else
                value = segment:ReadUInt16(address)
            end
            if value > 0 then
                INSTANCE.NEW_DUNGEONCOUNT_SYSTEM = true
            end
            if INSTANCE.NEW_SRAM_SYSTEM and dungeonPrefix == "hc" then
                local otherValue = 0
                if INSTANCE.VERSION_MINOR < 5 then
                    otherValue = segment:ReadUInt8(address + 1)
                else
                    otherValue = segment:ReadUInt16(address + 2)
                end
                if value ~= otherValue then
                    value = value + otherValue
                end
            end
            if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                print(dungeonPrefix .. " adhoc direct memory:")
                print(dungeonPrefix .. " Dungeon Items:", item.DeductedCount .. "/" .. item.ExemptedCount)
                print(dungeonPrefix .. " Checks:", value .. "/" .. item.MaxCount)
            end
            item.CollectedCount = value
        end
    end
end

function updateDoorKeyCountFromRoomSlotList(segment, doorKeyRef, roomSlots, offset, potSlots)
    offset = offset or 0
    local doorKey = Tracker:FindObjectForCode(doorKeyRef)
    if doorKey then
        local function countSlot(roomId, roomSlot, otherRoomId, otherSlot)
            local clearedCount = 0
            local roomData = segment:ReadUInt16(0x7ef000 + offset + (roomId * 2))
            
            if CACHE.ROOM == roomId and CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                if not (string.sub(doorKeyRef, -5) == "_door" and INSTANCE.NEW_KEY_SYSTEM) then
                    print(doorKeyRef, string.format("0x%04x", roomData), roomSlot)
                end
            end
            
            if (roomData & (1 << roomSlot)) ~= 0 then
                clearedCount = clearedCount + 1
            elseif otherRoomId then
                roomData = segment:ReadUInt16(0x7ef000 + offset + (otherRoomId * 2))

                if (roomData & (1 << otherSlot)) ~= 0 then
                    clearedCount = clearedCount + 1
                end
            end
            return clearedCount
        end

        local clearedCount = 0
        if roomSlots then
            for i, slot in ipairs(roomSlots) do
                if #slot > 2 then
                    clearedCount = clearedCount + countSlot(slot[1], slot[2], slot[3], slot[4])
                else
                    clearedCount = clearedCount + countSlot(slot[1], slot[2])
                end
            end
        end
        if potSlots then
            for i, room in ipairs(potSlots) do
                for i, slot in ipairs(room[2]) do
                    clearedCount = clearedCount + countSlot(room[1], slot)
                end
            end
        end

        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING and doorKey.AcquiredCount ~= clearedCount then
            print(doorKeyRef, clearedCount)
        end

        if doorKey.AcquiredCount ~= clearedCount then
            doorKey.AcquiredCount = clearedCount
            return true
        end
    else
        print("Couldn't find door/key", doorKeyRef)
    end
    return false
end

function updateDoorKeyFromTempRoom(doorKeyRef, data, tempValue, dataMore)
    local modified = false
    if data then
        local function countSlot(roomId, roomSlot)
            local clearedCount = 0
            if roomId == CACHE.ROOM then
                if (tempValue & (1 << roomSlot)) ~= 0 then
                    clearedCount = clearedCount + 1
                end
            else
                local roomData = AutoTracker:ReadU16(0x7ef000 + (roomId * 2), 0)
                if (roomData & (1 << roomSlot)) ~= 0 then
                    clearedCount = clearedCount + 1
                end
            end
            return clearedCount
        end

        local doorKey = Tracker:FindObjectForCode(doorKeyRef)
        local clearedCount = 0
        
        for i, slot in ipairs(data) do
            clearedCount = clearedCount + countSlot(slot[1], slot[2])
        end

        if dataMore then
            for i, room in ipairs(dataMore) do
                for j, slot in ipairs(room[2]) do
                    clearedCount = clearedCount + countSlot(room[1], slot)
                end
            end
        end

        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print(doorKeyRef, clearedCount)
        end

        if doorKey.AcquiredCount ~= clearedCount then
            doorKey.AcquiredCount = clearedCount
            modified = true
        end
    end

    return modified
end

function updateDungeonChestCountFromRoomSlotList(segment, dungeonPrefix, roomSlots)
    local item = Tracker:FindObjectForCode(dungeonPrefix .. "_chest")
    if item then
        if not shouldChestCountUp() then
            local clearedCount = 0
            if segment then
                for i, slot in ipairs(roomSlots) do
                    local roomData = segment:ReadUInt16(0x7ef000 + (slot[1] * 2))

                    -- if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                    --     print(dungeonPrefix, roomData, 1 << slot[2])
                    -- end

                    if (roomData & (1 << slot[2])) ~= 0 then
                        clearedCount = clearedCount + 1
                    end
                end

                if item.AcquiredCount ~= clearedCount then
                    item.AcquiredCount = clearedCount
                    return true
                end
            end
        end
    else
        print("Couldn't find chest:", dungeonPrefix)
    end
    return false
end

function updateDungeonKeysFromPrefix(segment, dungeonPrefix, address)
    local chestKeys = Tracker:FindObjectForCode(dungeonPrefix .. "_smallkey")

    if not INSTANCE.NEW_KEY_SYSTEM then
        if INSTANCE.NEW_SRAM_SYSTEM then
            INSTANCE.NEW_KEY_SYSTEM = true
        else
            local offset = 0x7ef4e0
            while (offset <= 0x7ef4ed) do
                if AutoTracker:ReadU16(offset) > 0 then
                    INSTANCE.NEW_KEY_SYSTEM = true
                    break
                end
                offset = offset + 2
            end
        end
    end

    if INSTANCE.NEW_KEY_SYSTEM then
        if address > 0x7ef400 then
            local newkeys = math.max(segment:ReadUInt8(address), (dungeonPrefix == "hc" and segment:ReadUInt8(address + 1) or 0))
            if chestKeys.AcquiredCount ~= newkeys then
                chestKeys.AcquiredCount = newkeys
                return true
            end
        end
    elseif OBJ_KEYSMALL:getState() < 2 and address < 0x7ef400 then
        local doorsOpened = Tracker:FindObjectForCode(dungeonPrefix .. "_door")
        local currentKeys = AutoTracker:ReadU8(0x7ef36f, 0)

        if DATA.DungeonIdMap[CACHE.DUNGEON] ~= dungeonPrefix or currentKeys == 0xff then
            currentKeys = segment:ReadUInt8(address)
        else
            currentKeys = 0
        end

        local enemyKeys = Tracker:FindObjectForCode(dungeonPrefix .. "_enemykey")
        local potKeys = Tracker:FindObjectForCode(dungeonPrefix .. "_potkey")
        local addedKeys = 0
        if enemyKeys and OBJ_POOL_ENEMYDROP:getState() == 0 then
            addedKeys = addedKeys + enemyKeys.AcquiredCount
            if dungeonPrefix == "hc" and Tracker:FindObjectForCode("hc_bigkey").Active then
                addedKeys = addedKeys - 1
            end
        end
        if potKeys and OBJ_POOL_DUNGEONPOT:getState() == 0 then
            addedKeys = addedKeys + potKeys.AcquiredCount
        end
        local newkeys = currentKeys + doorsOpened.AcquiredCount - addedKeys
        if chestKeys.AcquiredCount ~= newkeys then
            chestKeys.AcquiredCount = newkeys
            return true
        end
    end
    return false
end

function updateDungeonTotal(dungeonPrefix, seenFlags)
    if INSTANCE.NEW_SRAM_SYSTEM and seenFlags & DATA.DungeonData[dungeonPrefix][3] > 0 then
        local item = Tracker:FindObjectForCode(dungeonPrefix .. "_item").ItemState
        if item.MaxCount == 999 then
            local value = 0
            if INSTANCE.VERSION_MINOR < 5 then
                value = AutoTracker:ReadU8(0x7f5410 + DATA.DungeonData[dungeonPrefix][4] + (dungeonPrefix == "hc" and 1 or 0), 0)
            else
                value = AutoTracker:ReadU16(0x7f5410 + (DATA.DungeonData[dungeonPrefix][4] + (dungeonPrefix == "hc" and 1 or 0)) * 2, 0)
            end
            item.MaxCount = value

            if OBJ_DOORDUNGEON:getState() == DATA.DungeonData[dungeonPrefix][2] then
                OBJ_DOORCHEST:setState(item.MaxCount)
            end
        end
    end
end

function updateKeyTotal(dungeonPrefix, seenFlags)
    if OBJ_DOORSHUFFLE:getState() == 2 and INSTANCE.VERSION_MINOR >= 5 and seenFlags & DATA.DungeonData[dungeonPrefix][3] > 0 then
        local key = Tracker:FindObjectForCode(dungeonPrefix .. "_smallkey")
        if key.MaxCount == 999 then
            local value = AutoTracker:ReadU8(0x7f5430 + (DATA.DungeonData[dungeonPrefix][4] + (dungeonPrefix == "hc" and 1 or 0)), 0)
            key.MaxCount = value

            if OBJ_DOORDUNGEON:getState() == DATA.DungeonData[dungeonPrefix][2] then
                OBJ_DOORKEY:setState(key.MaxCount)
            end
        end
    end
end