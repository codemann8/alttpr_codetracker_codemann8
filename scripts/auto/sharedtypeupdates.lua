function updateRoomLocation(segment, location, offset)
    offset = offset or 0
    local clearedCount = 0
    for i, slot in ipairs(offset == 0 and location[2] or location[3]) do
        local roomData = segment:ReadUInt16(0x7ef000 + offset + (slot[1] * 2))
        
        if (roomData & (1 << slot[2])) ~= 0 then
            clearedCount = clearedCount + 1
        elseif OBJ_ENTRANCE:getState() < 2 and OBJ_RACEMODE:getState() == 0 and slot[3] and roomData & slot[3] ~= 0 then
            if #location < 3 or Tracker:FindObjectForCode("ow_swapped_" .. string.format("%02x", (location[3] + 0x40) % 0x80)).ItemState:getState() == 0 or Tracker:FindObjectForCode("pearl").Active then
                clearedCount = clearedCount + 1
            end
        end
    end

    local remove = false
    for i, name in ipairs(location[1]) do
        loc = Tracker:FindObjectForCode(name)
        if loc then
            if not loc.Owner.ModifiedByUser then
                loc.AvailableChestCount = loc.ChestCount - clearedCount
            end
            
            if loc.AvailableChestCount == 0 then
                if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                    print("Location cleared:", location[1][1], clearedCount)
                end
                remove = true
            end
        else
            print("Couldn't find location", name)
        end
    end

    return remove
end

function updateChestCountFromDungeon(segment, dungeonPrefix, address)
    if OBJ_RACEMODE:getState() == 0 then
        local item = Tracker:FindObjectForCode(dungeonPrefix .. "_item").ItemState
        if item then
            if segment and OBJ_GLITCHMODE:getState() < 2 then
                local value = segment:ReadUInt8(address)
                if value > 0 then
                    INSTANCE.NEW_DUNGEONCOUNT_SYSTEM = true
                end
                if INSTANCE.NEW_SRAM_SYSTEM and dungeonPrefix == "hc" then
                    local otherValue = segment:ReadUInt8(address + 1)
                    if value ~= otherValue then
                        value = value + otherValue
                    end
                end
                item.CollectedCount = value

                -- TODO: Remove this when Dungeon Compass Count bitfield is properly flagged when 'always on'
                if value > 0 and INSTANCE.COMPASS_MODE & 0x02 > 0 then
                    updateDungeonTotal(dungeonPrefix, 0xffff)
                end
            elseif (not INSTANCE.NEW_DUNGEONCOUNT_SYSTEM or OBJ_GLITCHMODE:getState() > 1) and OBJ_DOORSHUFFLE:getState() < 2 then
                local chest = Tracker:FindObjectForCode(dungeonPrefix .. "_chest")
                local map = Tracker:FindObjectForCode(dungeonPrefix .. "_map")
                local compass = Tracker:FindObjectForCode(dungeonPrefix .. "_compass")
                local smallkey = Tracker:FindObjectForCode(dungeonPrefix .. "_smallkey")
                local bigkey = Tracker:FindObjectForCode(dungeonPrefix .. "_bigkey")
                local enemykey = Tracker:FindObjectForCode(dungeonPrefix .. "_enemykey")
                local potkey = Tracker:FindObjectForCode(dungeonPrefix .. "_potkey")
                local dungeonItems = 0

                if map.Active and OBJ_KEYMAP:getState() == 0 then
                    dungeonItems = dungeonItems + 1
                end

                if compass.Active and OBJ_KEYCOMPASS:getState() == 0 then
                    dungeonItems = dungeonItems + 1
                end

                if smallkey.AcquiredCount and OBJ_KEYSMALL:getState() == 0 then
                    dungeonItems = dungeonItems + smallkey.AcquiredCount
                end

                if bigkey.Active and OBJ_KEYBIG:getState() == 0 and dungeonPrefix ~= "hc" then
                    dungeonItems = dungeonItems + 1
                end

                if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                    print(dungeonPrefix .. " Dungeon Items:", dungeonItems)
                    print(dungeonPrefix .. " Chests:", chest.AcquiredCount)
                end

                local addedKeys = 0
                if OBJ_POOL_ENEMYDROP:getState() > 0 and enemykey then
                    addedKeys = addedKeys + enemykey.AcquiredCount
                    if OBJ_KEYBIG:getState() == 0 and dungeonPrefix == "hc" and bigkey.Active then
                        addedKeys = addedKeys - 1
                    end
                end
                if OBJ_POOL_DUNGEONPOT:getState() > 0  and potkey then
                    addedKeys = addedKeys + potkey.AcquiredCount
                end

                if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING and addedKeys > 0 then
                    print(dungeonPrefix .. " Key Drops:", addedKeys)
                end

                item.RemainingCount = math.max(item.MaxCount - ((chest.AcquiredCount - dungeonItems) + addedKeys), 0)

                if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                    print(dungeonPrefix .. " Items:", item.CollectedCount)
                end
            end
        end
    end
end

function updateDoorKeyCountFromRoomSlotList(segment, doorKeyRef, roomSlots, offset)
    offset = offset or 0
    local doorKey = Tracker:FindObjectForCode(doorKeyRef)
    if doorKey then
        local clearedCount = 0
        for i, slot in ipairs(roomSlots) do
            local roomData = segment:ReadUInt16(0x7ef000 + offset + (slot[1] * 2))

            if (roomData & (1 << slot[2])) ~= 0 then
                clearedCount = clearedCount + 1
            elseif #slot > 2 then
                roomData = segment:ReadUInt16(0x7ef000 + offset + (slot[3] * 2))

                if (roomData & (1 << slot[4])) ~= 0 then
                    clearedCount = clearedCount + 1
                end
            end
        end

        -- if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        --     print(doorKeyRef, clearedCount)
        -- end

        doorKey.AcquiredCount = clearedCount
    else
        print("Couldn't find door/key", doorKeyRef)
    end
end

function updateDoorKeyFromTempRoom(doorKeyRef, data, tempValue)
    local modified = false
    if data then
        local doorKey = Tracker:FindObjectForCode(doorKeyRef)
        local clearedCount = 0
        
        for i, slot in ipairs(data) do
            if slot[1] == CACHE.ROOM then
                if (tempValue & (1 << slot[2])) ~= 0 then
                    clearedCount = clearedCount + 1
                end
            else
                local roomData = AutoTracker:ReadU16(0x7ef000 + (slot[1] * 2), 0)
                if (roomData & (1 << slot[2])) ~= 0 then
                    clearedCount = clearedCount + 1
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
        if OBJ_DOORSHUFFLE:getState() < 2 then
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

                item.AcquiredCount = clearedCount
            end
        end
    else
        print("Couldn't find chest:", dungeonPrefix)
    end
end

function updateDungeonKeysFromPrefix(segment, dungeonPrefix, address)
    local chestKeys = Tracker:FindObjectForCode(dungeonPrefix .. "_smallkey")

    if OBJ_DOORSHUFFLE:getState() > 0 then
        INSTANCE.NEW_KEY_SYSTEM = true
    elseif not INSTANCE.NEW_KEY_SYSTEM then
        local offset = 0x7ef4e0
        while (offset <= 0x7ef4ed) do
            if AutoTracker:ReadU16(offset) > 0 then
                INSTANCE.NEW_KEY_SYSTEM = true
                break
            end
            offset = offset + 2
        end
    end

    if INSTANCE.NEW_KEY_SYSTEM then
        if address > 0x7ef400 then
            chestKeys.AcquiredCount = segment:ReadUInt8(address) + (dungeonPrefix == "hc" and segment:ReadUInt8(address + 1) or 0)
        end
    elseif OBJ_KEYSMALL:getState() < 2 and address < 0x7ef400 then
        local doorsOpened = Tracker:FindObjectForCode(dungeonPrefix .. "_door")
        local currentKeys = 0

        if DATA.DungeonIdMap[CACHE.DUNGEON] == dungeonPrefix and segment:ReadUInt8(0x7ef36f) ~= 0xff then
            currentKeys = segment:ReadUInt8(0x7ef36f)
        else
            currentKeys = segment:ReadUInt8(address)
        end

        local enemyKeys = Tracker:FindObjectForCode(dungeonPrefix .. "_enemykey")
        local potKeys = Tracker:FindObjectForCode(dungeonPrefix .. "_potkey")
        local addedKeys = 0
        if enemyKeys and OBJ_POOL_ENEMYDROP:getState() == 0 then
            addedKeys = addedKeys + potKeys.AcquiredCount
            if dungeonPrefix == "hc" and Tracker:FindObjectForCode("hc_bigkey").Active then
                addedKeys = addedKeys - 1
            end
        end
        if potKeys and OBJ_POOL_DUNGEONPOT:getState() == 0 then
            addedKeys = addedKeys + potKeys.AcquiredCount
        end
        chestKeys.AcquiredCount = currentKeys + doorsOpened.AcquiredCount - addedKeys
    end
end

function updateDungeonTotal(dungeonPrefix, seenFlags)
    if INSTANCE.NEW_SRAM_SYSTEM and seenFlags & DATA.DungeonData[dungeonPrefix][3] > 0 then
        local item = Tracker:FindObjectForCode(dungeonPrefix .. "_item").ItemState
        if item.MaxCount == 999 then
            local value = AutoTracker:ReadU8(0x7f5410 + DATA.DungeonData[dungeonPrefix][4], 0)
            if dungeonPrefix == "hc" then
                value = math.max(value, AutoTracker:ReadU8(0x7f5410 + DATA.DungeonData[dungeonPrefix][4] + 1, 0))
            end
            item.MaxCount = value

            if OBJ_DOORDUNGEON:getState() == DATA.DungeonData[dungeonPrefix][2] then
                OBJ_DOORCHEST:setState(item.MaxCount)
            end
        end
    end
end