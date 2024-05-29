function updateTitleFromMemorySegment(segment)
    if Tracker.ActiveVariantUID ~= "vanilla" then
        INSTANCE.VERSION_MAJOR = segment:ReadUInt16(0x701ffc)
        INSTANCE.VERSION_MINOR = segment:ReadUInt16(0x701ffe)
        if INSTANCE.VERSION_MAJOR == 0xffff then
            INSTANCE.VERSION_MAJOR = 0
        end
        if INSTANCE.VERSION_MINOR == 0xffff then
            INSTANCE.VERSION_MINOR = 0
        end
        local value = segment:ReadUInt8(0x702000)
        if value > 0 then
            if string.char(value) == 'O' then
                value = 1
            elseif string.char(segment:ReadUInt8(0x702001)) == 'R' then
                value = string.char(segment:ReadUInt8(0x702013)) == 'O' and 1 or 0
            else
                value = string.char(AutoTracker:ReadU8(0x2a8000, 0)) == 'O' and 1 or 0
            end
            if OBJ_WORLDSTATE:getProperty("version") ~= value then
                OBJ_WORLDSTATE.clicked = true
                OBJ_WORLDSTATE.ignorePostUpdate = true
                OBJ_WORLDSTATE:setProperty("version", value)
                if OBJ_WORLDSTATE.linkedSettingAlt then
                    OBJ_WORLDSTATE.linkedSettingAlt.CurrentStage = value
                end
            end

            INSTANCE.NEW_SRAM_SYSTEM = INSTANCE.VERSION_MINOR > 1
            INSTANCE.NEW_POTDROP_SYSTEM = AutoTracker:ReadU8(0x28AA50, 0) > 0

            if SEGMENTS.ShopData == nil or SEGMENTS.ShopData:ContainsAddress(0x7f64b8) ~= INSTANCE.NEW_SRAM_SYSTEM then
                if SEGMENTS.ShopData then
                    ScriptHost:RemoveMemoryWatch(SEGMENTS.ShopData)
                end
                if INSTANCE.NEW_SRAM_SYSTEM then
                    SEGMENTS.ShopData = ScriptHost:AddMemoryWatch("Shop Data", 0x7f64b8, 0x20, updateShopsFromMemorySegment)
                else
                    SEGMENTS.ShopData = ScriptHost:AddMemoryWatch("Shop Data", 0x7ef302, 0x20, updateShopsFromMemorySegment)
                end
            end
            
            if INSTANCE.NEW_POTDROP_SYSTEM then
                if SEGMENTS.RoomPotData == nil then
                    SEGMENTS.RoomPotData = ScriptHost:AddMemoryWatch("Room Pot Data", INSTANCE.VERSION_MINOR < 2 and 0x7f6600 or 0x7f6018, 0x250, updateRoomPotsFromMemorySegment)
                end
                if SEGMENTS.RoomEnemyData == nil then
                    SEGMENTS.RoomEnemyData = ScriptHost:AddMemoryWatch("Room Enemy Data", INSTANCE.VERSION_MINOR < 2 and 0x7f6850 or 0x7f6268, 0x250, updateRoomEnemiesFromMemorySegment)
                end
            else
                if SEGMENTS.RoomPotData then
                    ScriptHost:RemoveMemoryWatch(SEGMENTS.RoomPotData)
                    SEGMENTS.RoomPotData = nil
                end
                if SEGMENTS.RoomEnemyData then
                    ScriptHost:RemoveMemoryWatch(SEGMENTS.RoomEnemyData)
                    SEGMENTS.RoomEnemyData = nil
                end
            end
        end
    end
end

function updateLocationFromMemorySegment(segment)
    local clock = os.clock()
    updateModuleFromMemorySegment(segment)

    if isInGameFromModule() and segment:ReadUInt8(0x7e0010) ~= 0x0e then
        local indoor = segment:ReadUInt8(0x7e001b) == 1
        
        -- Overworld Id
        local owChanged = false
        if not indoor or indoor ~= CACHE.INDOOR then
            owChanged = updateOverworldIdFromMemorySegment(segment)
        end

        if os.clock() - clock > 0.005 then
            printLog(string.format("Update LocationOW LAG: %f", os.clock() - clock), 1)
        end

        -- Room Id
        local uwChanged = false
        if indoor or indoor ~= CACHE.INDOOR then
            uwChanged = updateRoomIdFromMemorySegment(segment)
        end

        if os.clock() - clock > 0.005 then
            printLog(string.format("Update LocationRoom LAG: %f", os.clock() - clock), 1)
        end

        -- Coordinates
        updateCoordinateFromMemorySegment(segment)

        if os.clock() - clock > 0.010 then
            printLog(string.format("Update Location LAG: %f", os.clock() - clock), 1)
        end
        
        updateDungeonImage(CACHE.DUNGEON, CACHE.OWAREA, CACHE.WORLD)
        
        if CACHE.MODULE ~= 0x06 and CACHE.MODULE ~= 0x08 and owChanged ~= uwChanged then
            saveBackup()
        end
    end
end

function updateDungeonWorksheetFromMemorySegment(segment)
    local clock = os.clock()
    if not isInGame() then
        return false
    end

    if CACHE.DUNGEON ~= segment:ReadUInt8(0x7e040c) then
        updateDungeonIdFromMemorySegment(segment)
    end

    if CACHE.DUNGEON < 0xff and not INSTANCE.NEW_KEY_SYSTEM and OBJ_DOORSHUFFLE:getState() == 0 and not CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING and Tracker.ActiveVariantUID ~= "vanilla" then
        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("Segment: Temp Room/Doors")
        end
    
        CACHE.ROOM = AutoTracker:ReadU16(0x7e00a0, 0)
        if CACHE.ROOM > 0 then
            local dungeonPrefix = DATA.RoomDungeons[CACHE.ROOM]
            if dungeonPrefix then
                dungeonPrefix = DATA.DungeonIdMap[dungeonPrefix]
                local valueDoor = segment:ReadUInt8(0x7e0400) << 8
                local valueRoom = segment:ReadUInt8(0x7e0403) << 4
                
                if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                    print(dungeonPrefix, string.format("0x%2X:", CACHE.ROOM), string.format("0x%2X", valueDoor), string.format("0x%2X", valueRoom))
                end

                local modified = updateDoorKeyFromTempRoom(dungeonPrefix .. "_door", DATA.MEMORY.DungeonFlags[dungeonPrefix][3], valueDoor)
                modified = updateDoorKeyFromTempRoom(dungeonPrefix .. "_enemykey", DATA.MEMORY.DungeonFlags[dungeonPrefix][1], valueRoom) or modified
                modified = updateDoorKeyFromTempRoom(dungeonPrefix .. "_potkey", DATA.MEMORY.DungeonFlags[dungeonPrefix][2], valueRoom) or modified
                
                if modified then
                    --Refresh Dungeon Calc
                    updateChestCountFromDungeon(nil, dungeonPrefix, nil)
                end
            end
        end
    end
    
    if os.clock() - clock > 0.010 then
        printLog(string.format("Update Dungeon Worksheet LAG: %f", os.clock() - clock), 1)
    end
end

function updateRandoDataFromMemorySegment(segment)
    local clock = os.clock()
    if not isInGame() then
        return false
    end

    if INSTANCE.NEW_SRAM_SYSTEM and shouldChestCountUp() and CACHE.DungeonsSeen ~= segment:ReadUInt16(0x7ef403) then
        updateDungeonTotalsFromMemorySegment(segment)
    end

    if Tracker.ActiveVariantUID == "full_tracker" then
        if CACHE.NPCData ~= segment:ReadUInt16(0x7ef410) then
            updateNPCFromMemorySegment(segment)
        end
    end

    if CACHE.CollectionRate & 0xff ~= segment:ReadUInt8(0x7ef423) then
        updateCollectionFromMemorySegment(segment)
    end
    
    if os.clock() - clock > 0.005 then
        printLog(string.format("Update Rando LAG: %f", os.clock() - clock), 1)
    end
end

function updateDungeonAdditionalFromMemorySegment(segment)
    if not isInGame() then
        return false
    end

    if INSTANCE.VERSION_MINOR >= 5 and CACHE.KeysSeen ~= segment:ReadUInt16(0x7ef474) then
        updateKeyTotalsFromMemorySegment(segment)
    end

    updateDungeonKeysFromMemorySegment(segment)

    if INSTANCE.NEW_SRAM_SYSTEM and CACHE.DungeonsCompleted ~= segment:ReadUInt16(0x7ef472) then
        updateDungeonsCompletedFromMemorySegment(segment)
    end
end

function updateMiscFromMemorySegment(segment)
    local clock = os.clock()
    if not isInGame() then
        return false
    end

    if CACHE.WORLD ~= segment:ReadUInt8(0x7ef3ca) then
        updateWorldFlagFromMemorySegment(segment)
    end

    local data = segment:ReadUInt16(0x7ef3c5) + segment:ReadUInt16(0x7ef3c7) + segment:ReadUInt8(0x7ef3c9)
    if CACHE.ProgressData ~= data then
        CACHE.ProgressData = data
        updateProgressFromMemorySegment(segment)
    end

    if Tracker.ActiveVariantUID ~= "vanilla" then
        if OBJ_GLITCHMODE:getState() <= 3 then
            if CACHE.CrystalData ~= segment:ReadUInt8(0x7ef37a)
                    or CACHE.PendantData ~= segment:ReadUInt8(0x7ef374) then
                updatePrizeFromMemorySegment(segment)
            end
        end
    end

    data = segment:ReadUInt16(0x7ef38c) + segment:ReadUInt8(0x7ef38e) + segment:ReadUInt8(0x7ef377)
    if CACHE.ToggleItemData ~= data then
        CACHE.ToggleItemData = data
        updateToggleItemsFromMemorySegment(segment)
    end

    if CACHE.HalfMagicData ~= segment:ReadUInt8(0x7ef37b) then
        updateHalfMagicFromMemorySegment(segment)
    end

    data = segment:ReadUInt16(0x7ef36c)
    if CACHE.HealthData ~= data then
        CACHE.HealthData = data
        updateHealthFromMemorySegment(segment)
    end
    
    if os.clock() - clock > 0.010 then
        printLog(string.format("Update Misc LAG: %f", os.clock() - clock), 1)
    end
end
    
function updateModuleFromMemorySegment(segment)
    local moduleId = nil
    if segment then
        moduleId = segment:ReadUInt8(0x7e0010)
    else
        moduleId = AutoTracker:ReadU8(0x7e0010, 0)
    end

    if moduleId ~= CACHE.MODULE and moduleId ~= 0x0e and moduleId ~= 0x0f then
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
            STATUS.AutotrackerInGame = true
            STATUS.GameStarted = os.clock()
            STATUS.LastMajorItem = os.clock()
        end

        if not isInGameFromModule() then
            resetCoords()
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

            STATUS.AutotrackerInGame = false
        end
    end
end

function updateWorldFlagFromMemorySegment(segment)
    if not segment and not isInGameFromModule() then
        return false
    end

    local MODULE = CACHE.MODULE
    local OWAREA = CACHE.OWAREA
    local WORLD = 0xff
    if segment then
        WORLD = segment:ReadUInt8(0x7ef3ca)
        MODULE = AutoTracker:ReadU8(0x7e0010, 0)
        OWAREA = AutoTracker:ReadU8(0x7e008a, 0)
    else
        WORLD = AutoTracker:ReadU8(0x7ef3ca, 0)
    end

    if WORLD ~= CACHE.WORLD then
        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("Segment: World")
        end

        CACHE.WORLD = WORLD

        if MODULE ~= 0x09 then --force OW transitions to retain OW ID
            if (OWAREA == 0 and (MODULE == 0x07 or MODULE == 0x05 or MODULE == 0x0e or MODULE == 0x17 or MODULE == 0x11 or MODULE == 0x06 or MODULE == 0x0f)) --transitioning into dungeons
                    or OWAREA > 0x81 then --transitional OW IDs are ignored ie. 0x96
                OWAREA = 0xff
            end
        end

        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("CURRENT WORLD:", CACHE.WORLD, string.format("0x%2X", CACHE.WORLD))
        end
    end
end

function updateOverworldIdFromMemorySegment(segment)
    if not isInGameFromModule() then
        return false
    end

    local owarea = 0xffff
    if segment then
        owarea = segment:ReadUInt8(0x7e008a)
    else
        owarea = AutoTracker:ReadU8(0x7e008a, 0)
    end

    if CACHE.MODULE ~= 0x09 then --force OW transitions to retain OW ID
        if (owarea == 0 and (
                CACHE.MODULE == 0x07 or --in cave/dungeon
                CACHE.MODULE == 0x05 or --on file select screen
                CACHE.MODULE == 0x0e or --has dialogue/menu open
                CACHE.MODULE == 0x12 or --game over
                CACHE.MODULE == 0x17 or --is s+q
                CACHE.MODULE == 0x1b or --on spawn select
                CACHE.MODULE == 0x11 or --falling in dropdown entrance
                CACHE.MODULE == 0x08 or --loading overworld
                CACHE.MODULE == 0x0b or --special overworld areas
                CACHE.MODULE == 0x06 or CACHE.MODULE == 0x0f or --transitioning into dungeons
                CACHE.MODULE == 0x13 or CACHE.MODULE == 0x16 or --post-boss defeated
                CACHE.MODULE == 0x15 or --aga mirror warp
                CACHE.MODULE == 0x18)) --ganon emerging from aga2 defeat
                or owarea > 0x81 then --transitional OW IDs are ignored ie. 0x96
            owarea = 0xff
        end
    end

    if owarea ~= CACHE.OWAREA then
        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("Segment: OverworldId")
        end

        CACHE.OWAREA = owarea

        if CACHE.OWAREA < 0xff and Tracker.ActiveVariantUID ~= "vanilla" and not INSTANCE.AUTOTRACKER_HAS_DONE_POST_GAME_SUMMARY then
            --OW Shuffle Autotracking
            if OBJ_OWSHUFFLE and OBJ_OWSHUFFLE:getState() > 0 then
                updateRoomSlots(CACHE.OWAREA + 0x1000)
            end

            --OW Mixed Autotracking
            if CACHE.OWAREA < 0x80 and OBJ_MIXED:getState() > 0 and not CONFIG.AUTOTRACKER_DISABLE_OWMIXED_TRACKING then
                if CACHE.OWAREA == 0 and (CACHE.MODULE ~= 0x09 and CACHE.MODULE ~= 0x10) then
                    print("NULL OW CASE NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL NULL")
                    print("^ Module:", string.format("0x%02X", CACHE.MODULE), "< REPORT THIS TO CODEMAN ^")
                end
                
                local swap = findObjectForCode("ow_slot_" .. string.format("%02x", CACHE.OWAREA)).ItemState
                if not swap.modified and swap:getState() > 1 then
                    updateWorldFlagFromMemorySegment(nil)

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
            if (OBJ_ENTRANCE:getState() > 0 or OBJ_OWSHUFFLE:getState() > 0) and OBJ_RACEMODE:getState() == 0 and (not CONFIG.AUTOTRACKER_DISABLE_ENTRANCE_TRACKING) and Tracker.ActiveVariantUID == "full_tracker" then
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
                            local swap = findObjectForCode("ow_slot_" .. string.format("%02x", CACHE.OWAREA)).ItemState
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

        return true
    end

    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("CURRENT OW:", CACHE.OWAREA, string.format("0x%2X", CACHE.OWAREA))
    end
end

function updateDungeonIdFromMemorySegment(segment)
    if not segment and not isInGame() then
        return false
    end

    local DUNGEON = 0xffff
    if (segment) then
        DUNGEON = segment:ReadUInt8(0x7e040c)
    else
        DUNGEON = AutoTracker:ReadU8(0x7e040c, 0)
    end

    if DUNGEON ~= CACHE.DUNGEON then
        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("Segment: DungeonId")
        end

        CACHE.DUNGEON = DUNGEON

        if CACHE.DUNGEON < 0xff then
            if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                print("CURRENT DUNGEON:", DATA.DungeonIdMap[CACHE.DUNGEON], CACHE.DUNGEON, string.format("0x%2X", CACHE.DUNGEON))
            end

            --Set Door Dungeon Selector
            if Tracker.ActiveVariantUID ~= "vanilla" then
                OBJ_DOORDUNGEON:setState(DATA.DungeonData[DATA.DungeonIdMap[CACHE.DUNGEON]][2])
            end

            --Auto-pin Dungeon Chests
            if Tracker.ActiveVariantUID == "full_tracker" and CONFIG.AUTOTRACKER_ENABLE_AUTOPIN_CURRENT_DUNGEON and OBJ_DOORSHUFFLE:getState() < 2 then
                for i = 0, 26, 2 do
                    Tracker:FindObjectForCode(DATA.DungeonData[DATA.DungeonIdMap[i]][1]).Pinned = DATA.DungeonIdMap[i] == DATA.DungeonIdMap[CACHE.DUNGEON]
                end
            end
        end
    end
end

function updateRoomIdFromMemorySegment(segment)
    if not isInGameFromModule() and CACHE.MODULE ~= 0x05 then
        return false
    end

    local room = 0xffff
    if segment then
        room = segment:ReadUInt16(0x7e00a0)
    else
        room = AutoTracker:ReadU16(0x7e00a0, 0)
    end

    if room ~= CACHE.ROOM then
        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("Segment: RoomId")
        end

        CACHE.ROOM = room

        if OBJ_DOORSHUFFLE and OBJ_DOORSHUFFLE:getState() > 0 and CACHE.MODULE ~= 0x19 and CACHE.MODULE ~= 0x1a then
            updateRoomSlots(CACHE.ROOM)
        end

        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("CURRENT ROOM:", CACHE.ROOM, string.format("0x%4X", CACHE.ROOM))
            --print("CURRENT ROOM ORIGDUNGEON:", DATA.DungeonIdMap[DATA.RoomDungeons[CACHE.ROOM]], DATA.RoomDungeons[CACHE.ROOM], string.format("0x%2X", DATA.RoomDungeons[CACHE.ROOM]))
        end

        return true
    end
end

CACHE.COORDS = { PREVIOUS = { X = 0xffff, Y = 0xffff, S = 0xffff, D = 0xff }, CURRENT = { X = 0xffff, Y = 0xffff, S = 0xffff, D = 0xff }}
function updateCoordinateFromMemorySegment(segment)
    local yCoord = 0
    local xCoord = 0
    local prevIndoor = CACHE.INDOOR
    if segment then
        yCoord = segment:ReadUInt16(0x7e0020)
        xCoord = segment:ReadUInt16(0x7e0022)
        CACHE.INDOOR = segment:ReadUInt8(0x7e001b) == 1
    else
        yCoord = AutoTracker:ReadU16(0x7e0020, 0)
        xCoord = AutoTracker:ReadU16(0x7e0022, 0)
        CACHE.INDOOR = AutoTracker:ReadU8(0x7e001b, 0) == 1
    end

    if CONFIG.AUTOTRACKER_DISABLE_ENTRANCE_TRACKING or OBJ_RACEMODE:getState() > 0 or OBJ_ENTRANCE:getState() == 0 or not isInGameFromModule() then
        return false
    end
    
    local function findClosestEntrance(owid, coordX, coordY, entrance, room)
        local minDistance = 9999
        local closestEntrance = nil
        if DATA.OverworldEntranceData[owid] ~= nil then
            if type(DATA.OverworldEntranceData[owid]) == "string" then
                entrance = DATA.OverworldEntranceData[owid]
                minDistance = 0
            else
                for i,ent in ipairs(DATA.OverworldEntranceData[owid]) do
                    local e = ent[1]
                    if owid & 0x3f == 0x1b and e:find("^Ganon") then
                        local is_swapped = Tracker:FindObjectForCode("ow_slot_" .. string.format("%02x", owid | 0x40)).ItemState:getState()
                        if is_swapped < 2 and is_swapped << 6 == owid & 0x40 then
                            goto continue
                        end
                    end
                    if DATA.DropdownCouples[e] ~= nil and OBJ_ENTRANCE:getState() < 4 then
                        e = DATA.DropdownCouples[e]
                    end
                    if not room or (room:find("^cap_drop_") ~= nil == ent[1]:find("Dropdown") ~= nil) or OBJ_ENTRANCE:getState() == 4 then
                        local offset = (not ent[5]) and 0x08 or 0x0 -- dropdowns/tavern shouldn't use offset
                        local distance = calcDistance(coordX, coordY, ent[2], ent[3] + offset, ent[5])
                        minDistance = math.min(distance, minDistance)
                        if distance == minDistance then
                            closestEntrance = e
                        end
                    end
                    ::continue::
                end
            end
        else
            printLog(string.format("MISSING OW SCREEN: 0x%2X: ", owid), 1)
        end
        if closestEntrance ~= nil and minDistance < 60 then
            entrance = closestEntrance
        end
        if entrance == nil then
            printLog(string.format("NO ENTRANCE: %f 0x%2X: %4Xx%4X", minDistance, owid, coordX, coordY), 1)
        end
        return entrance, minDistance
    end

    local function findRoom(dungeonId, roomId, coordX, coordY)
        if dungeonId < 0xff then
            local data = DATA.DungeonData[DATA.DungeonIdMap[dungeonId]]
            if type(data[11]) == "string" then
                return data[11]
            end
        end
        if DATA.RoomLobbyData[roomId] ~= nil then
            if type(DATA.RoomLobbyData[roomId]) == "string" then
                return DATA.RoomLobbyData[roomId]
            elseif type(DATA.RoomLobbyData[roomId][1]) == "string" then
                if DATA.RoomLobbyData[roomId][2] and dungeonId == 0xff then
                    return ""
                end
                if #DATA.RoomLobbyData[roomId] > 2 and DATA.RoomLobbyData[roomId][3] and not Tracker:FindObjectForCode("lamp").Active then
                    --dark room and no lamp
                    return "cap_darkunknown"
                end
                return DATA.RoomLobbyData[roomId][1]
            else
                for i,uw in ipairs(DATA.RoomLobbyData[roomId]) do
                    if calcDistance(coordX, coordY, uw[1], uw[2]) < 0x40 then
                        if #uw > 4 and OBJ_POOL_BONK:getState() > 0 then
                            return uw[5]
                        elseif #uw > 3 and OBJ_POOL_CAVEPOT:getState() > 0 then
                            return uw[4]
                        end
                        return uw[3]
                    end
                end
                if dungeonId < 0xff then
                    printLog("generic dungeon lobby????", 1)
                    return ""
                end
                printLog(string.format("MULTIPLE ROOM: 0x%4X: %4Xx%4X", roomId, coordX, coordY), 1)
            end
        elseif dungeonId < 0xff then
            printLog("generic dungeon lobby", 1)
            return ""
        else
            printLog(string.format("MISSING ROOM: 0x%4X: ", roomId), 1)
        end
        return nil
    end

    local function adjustRoom(dungeonId, roomId, room, entrance)
        -- this is meant for multi entrance dungeons, to better place an icon considering lobby shuffle
        if dungeonId < 0xff then
            local dungeonPrefix = DATA.DungeonIdMap[dungeonId]
            local data = DATA.DungeonData[dungeonPrefix]
            if room:find("^cap_drop_") or type(data[11]) == "string" then
                printLog("drop case", 1)
                return room
            end
            local section = findObjectForCode(entrance)
            if INSTANCE.MULTIDUNGEONCAPTURES[section.Owner.Name .. "/" .. section.Name] ~= nil then
                printLog("prev used case", 1)
                return INSTANCE.MULTIDUNGEONCAPTURES[section.Owner.Name .. "/" .. section.Name]
            end
            if OBJ_ENTRANCE:getState() < 4 then
                if dungeonPrefix == "sw" then
                    room = "cap_sw"
                    if entrance:find("Skull Woods") and entrance ~= "@Skull Woods Back/Entrance" then
                        suppressLog = true
                        printLog("SW METRO AREA - ICON SKIPPED", 1)
                        return nil
                    end
                elseif dungeonPrefix == "hc" then
                    printLog(string.format("hc case %s %s 0x%4X", entrance, room, roomId), 1)
                    if DATA.DropdownCouples[entrance] ~= nil or entrance:find("Dropdown") then
                        return "cap_drop_sanc"
                    end
                end
            end

            local function pickNext(fullList)
                --return value must meet the following conditions:
                --1) value must exist in data[11], static list of all icons for this dungeon
                --2) value cannot be in MULTIDUNGEONCAPTURES, list of already used icons
                --3) value must prefer to use existing value of room, or else use the first of the remaining icons
                local remaining = {}
                local rI = 1
                for i,v in ipairs(fullList) do
                    remaining[rI] = v
                    for e,c in pairs(INSTANCE.MULTIDUNGEONCAPTURES) do
                        cAlt = c
                        if OBJ_ENTRANCE:getState() == 4 and c == "cap_swback" then
                            cAlt = "cap_sw"
                        end
                        if cAlt == v then
                            remaining[rI] = nil
                            rI = rI - 1
                            break
                        end
                    end
                    rI = rI + 1
                end

                local ret = ""
                for i,v in ipairs(remaining) do
                    if v == room then
                        ret = v
                        break
                    end
                end
                if ret == "" then
                    ret = remaining[1]
                end

                if OBJ_ENTRANCE:getState() == 4 and ret == "cap_sw" then
                    return "cap_swback"
                end
                return ret
            end
            
            room = pickNext(data[11])
        end
        return room
    end

    local function updateCoords(x, y, transition)
        local clock = os.clock()
        local mod = 0
        if segment then
            mod = segment:ReadUInt8(0x7e0010)
        else
            mod = AutoTracker:ReadU8(0x7e0010, 0)
        end
        local s = 0xffff
        if not CACHE.INDOOR then
            if mod == 0x11 then
                -- gets cached y position before it was modified by hole drop
                if segment then
                    y = segment:ReadUInt16(0x7e0051)
                else
                    y = AutoTracker:ReadU16(0x7e0051, 0)
                end
            end
            if mod == 0x09 or mod == 0x10 or mod == 0x11 then
                if segment then
                    local submod = segment:ReadUInt8(0x7e0011)
                else
                    local submod = AutoTracker:ReadU8(0x7e0011, 0)
                end
                if submod ~= 0x07 then
                    s = ((y >> 9) << 3) + (x >> 9)
                    if DATA.OverworldSlotAliases[s] ~= nil then
                        s = DATA.OverworldSlotAliases[s]
                    end
                    if s == CACHE.OWAREA & 0x3f and CACHE.OWAREA ~= 0xff then
                        s = CACHE.OWAREA
                    else
                        if transition then
                            printLog(string.format("OW MISMATCH: 0x%2X: 0x%2X: 0x%2X", s, CACHE.OWAREA, CACHE.MODULE), 1)
                        end
                        s = 0xffff
                    end
                end
            end
        elseif mod == 0x07 then
            s = ((y >> 9) << 4) + (x >> 9)
            CACHE.COORDS.CURRENT.S = s
            if s ~= CACHE.ROOM then
                if s ~= CACHE.ROOM then
                    if transition then
                        printLog(string.format("ROOM MISMATCH: 0x%4X: 0x%4X: 0x%2X", s, CACHE.ROOM, CACHE.MODULE), 1)
                    end
                    s = 0xffff
                end
            end
        end
        if s ~= 0xffff then
            STATUS.LAST_COORD = {clock, clock - STATUS.LAST_COORD[1]}
            CACHE.COORDS.CURRENT.X = x
            CACHE.COORDS.CURRENT.Y = y
            CACHE.COORDS.CURRENT.S = s
            CACHE.COORDS.CURRENT.D = CACHE.DUNGEON
        end
    end

    local function waitForBetterState()
        STATUS.COORD_NOT_READY = true
    end

        -- TODO: This process doesn't quite work for autotracking DR and OWR connections
    if prevIndoor ~= CACHE.INDOOR or STATUS.COORD_NOT_READY then
        if xCoord == CACHE.COORDS.CURRENT.X and yCoord == CACHE.COORDS.CURRENT.Y then
            waitForBetterState()
            return false
        end
        local mod = 0
        if segment then
            mod = segment:ReadUInt8(0x7e0010)
        else
            mod = AutoTracker:ReadU8(0x7e0010, 0)
        end
        if not CACHE.INDOOR then
            sId = ((yCoord >> 9) << 3) + (xCoord >> 9)
            if DATA.OverworldSlotAliases[sId] ~= nil then
                sId = DATA.OverworldSlotAliases[sId]
            end
            if (mod ~= 0x09 and mod ~= 0x10) or CACHE.OWAREA > 0x90 or sId ~= CACHE.OWAREA & 0x3f then
                waitForBetterState()
                return false
            end
            sId = CACHE.OWAREA
        else
            if mod == 0x11 then
                if segment then
                    local submod = segment:ReadUInt8(0x7e0011)
                else
                    local submod = AutoTracker:ReadU8(0x7e0011, 0)
                end
                if submod == 0x07 then
                    -- gets cached y position before it was modified by hole drop
                    if segment then
                        yCoord = segment:ReadUInt16(0x7e0051)
                    else
                        yCoord = AutoTracker:ReadU16(0x7e0051, 0)
                    end
                else
                    waitForBetterState()
                    return false
                end
            end
            sId = ((yCoord >> 9) << 4) + (xCoord >> 9)
            if (mod ~= 0x07 and mod ~= 0x11) or sId ~= CACHE.ROOM then
                waitForBetterState()
                return false
            end
            if CACHE.ROOM < 0xe1 and CACHE.DUNGEON == 0xff then
                updateDungeonIdFromMemorySegment(nil)
            end
        end
        STATUS.COORD_NOT_READY = false

        if sId ~= CACHE.COORDS.CURRENT.S or xCoord & 0xfe00 ~= CACHE.COORDS.CURRENT.X & 0xfe00 or yCoord & 0xfe00 ~= CACHE.COORDS.CURRENT.Y & 0xfe00 then
            CACHE.COORDS.PREVIOUS.X = CACHE.COORDS.CURRENT.X
            CACHE.COORDS.PREVIOUS.Y = CACHE.COORDS.CURRENT.Y
            CACHE.COORDS.PREVIOUS.S = CACHE.COORDS.CURRENT.S
            CACHE.COORDS.PREVIOUS.D = CACHE.COORDS.CURRENT.D
            
            printLog("----------------------------------", 1)
            updateCoords(xCoord, yCoord, true)
            printLog(string.format("Last Update: %f @ %f", STATUS.LAST_COORD[2], os.clock()), 1)
            printLog(string.format("Coord Change: 0x%4X: %4Xx%4X @ 0x%2X | 0x%2X: %4Xx%4X", CACHE.COORDS.PREVIOUS.S, CACHE.COORDS.PREVIOUS.X, CACHE.COORDS.PREVIOUS.Y, CACHE.DUNGEON, CACHE.COORDS.CURRENT.S, CACHE.COORDS.CURRENT.X, CACHE.COORDS.CURRENT.Y), 1)
            
            if CACHE.COORDS.PREVIOUS.S ~= 0xffff and CACHE.COORDS.CURRENT.S ~= 0xffff and STATUS.LAST_COORD[2] < 4.0 then
                local function findEntranceRoomPair(owCoord, uwCoord)
                    local ent, dist = findClosestEntrance(owCoord.S, owCoord.X, owCoord.Y)
                    local room = nil
                    if ent ~= nil then
                        printLog(string.format("Entrance: %s %f", ent, dist), 1)
                        room = findRoom(uwCoord.D, uwCoord.S, uwCoord.X, uwCoord.Y)
                        if room ~= nil then
                            printLog(string.format("Room: %s", room), 1)
                            local newroom = adjustRoom(uwCoord.D, uwCoord.S, room, ent)
                            if room ~= newroom then
                                printLog(string.format("Adjusted Room: %s", newroom == "" and "(blank)" or newroom), 1)
                            end
                            room = newroom
                        end
                        ent, dist = findClosestEntrance(owCoord.S, owCoord.X, owCoord.Y, ent, room)
                    end
                    return ent, room
                end

                local owEntrance = nil
                local uwRoom = nil
                local owId = nil
                local roomId = nil
                local dungeonId = nil
                local suppressLog = false
                if not CACHE.INDOOR then
                    --UW->OW
                    owId = CACHE.COORDS.CURRENT.S
                    roomId = CACHE.COORDS.PREVIOUS.S
                    dungeonId = CACHE.COORDS.PREVIOUS.D
                    if OBJ_ENTRANCE:getState() < 4 then
                        if CACHE.COORDS.PREVIOUS.S ~= 0x0d and CACHE.COORDS.PREVIOUS.S ~= 0x20 -- aga bosses
                                and CACHE.COORDS.PREVIOUS.S ~= 0x33 and CACHE.COORDS.PREVIOUS.S ~= 0x29 and CACHE.COORDS.PREVIOUS.S ~= 0xa4 then -- multi-entrance bosses
                            owEntrance, uwRoom = findEntranceRoomPair(CACHE.COORDS.CURRENT, CACHE.COORDS.PREVIOUS)
                        else
                            suppressLog = true
                            printLog("BOSS DEFEATED - ICON SKIPPED", 1)
                        end
                    else
                        --TODO: this else case isnt necessary if there is no print statement down below
                        updateCoords(xCoord, yCoord, false)
                        return nil
                    end
                else
                    --OW->UW
                    owId = CACHE.COORDS.PREVIOUS.S
                    roomId = CACHE.COORDS.CURRENT.S
                    dungeonId = CACHE.COORDS.CURRENT.D
                    owEntrance, uwRoom = findEntranceRoomPair(CACHE.COORDS.PREVIOUS, CACHE.COORDS.CURRENT)
                end

                if owEntrance ~= nil and uwRoom ~= nil then
                    local section = findObjectForCode(owEntrance)
                    local darkReplacement = section.CapturedItem and section.CapturedItem.Name == "Unknown Dark Connector"
                        and (uwRoom == "cap_darkmountain" or uwRoom == "cap_oldman" or uwRoom == "cap_mtncave_back")
                    if not (section.CapturedItem or section.AvailableChestCount == 0) or darkReplacement then
                        local skipIcon = false
                        if owEntrance == "@Tavern Back/Entrance" then
                            local item = Tracker:FindObjectForCode("tavern_mode")
                            if roomId ~= 0x103 or uwRoom == "" then
                                item.CurrentStage = 2
                            else
                                item.CurrentStage = 1
                                skipIcon = true
                            end
                        end
                        if not skipIcon then
                            if uwRoom ~= "" then
                                section.CapturedItem = findObjectForCode(uwRoom)
                                updateGhost(owEntrance, true, true)
                            else
                                section.AvailableChestCount = 0
                                if section.HostedItem then
                                    section.HostedItem.Active = true
                                end
                            end
                        end
                        if OBJ_ENTRANCE:getState() < 4 then
                            resetCoords()
                        end
                    end
                end
            end
        end
    end

    updateCoords(xCoord, yCoord, false)
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
    local clock = os.clock()
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
    
    if os.clock() - clock > 0.010 then
        printLog(string.format("Update Items LAG: %f", os.clock() - clock), 1)
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
    CACHE.HalfMagicData = segment:ReadUInt8(0x7ef37b)
    if CACHE.HalfMagicData > 0 then
        local item = Tracker:FindObjectForCode("halfmagic")
        if CACHE.HalfMagicData > item.CurrentStage or not STATUS.AutotrackerInGame then
            itemFlippedOn("halfmagic")
            item.CurrentStage = CACHE.HalfMagicData
        end
    end
end

function updateHealthFromMemorySegment(segment)
    if segment then
        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("Segment: Health")
        end

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
    local clock = os.clock()
    if CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID ~= "full_tracker" or not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Overworld")
    end

    for name, value in pairs(INSTANCE.MEMORY.Overworld) do
        local location = findObjectForCode(name)
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
    
    if os.clock() - clock > 0.005 then
        printLog(string.format("Update OW LAG: %f", os.clock() - clock), 1)
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
    local clock = os.clock()
    if CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID ~= "full_tracker" or not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Shops")
    end

    offset = INSTANCE.NEW_SRAM_SYSTEM and 0x71b6 or 0

    for name, value in pairs(INSTANCE.MEMORY.Shops) do
        local location = findObjectForCode(name)
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
    
    if os.clock() - clock > 0.005 then
        printLog(string.format("Update Shops LAG: %f", os.clock() - clock), 1)
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
    if CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID ~= "full_tracker" or (not segment and not isInGame()) then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: NPC")
    end

    CACHE.NPCData = segment:ReadUInt16(0x7ef410)

    for name, value in pairs(INSTANCE.MEMORY.Npc) do
        local location = findObjectForCode(name)
        if location then
            if not location.Owner.ModifiedByUser then -- Do not auto-track this the user has manually modified it
                local clearedCount = (CACHE.NPCData & value[1]) ~= 0 and 1 or 0
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
    { {"@Eastern Palace/Armos", "@EP Armos/Boss"}, {{200, 11}} },

    { {"@Desert Palace/Eyegore Switch", "@DP Eyegore Switch/Chest"}, {{116, 4}} },
    { {"@Desert Palace/Popo Chest", "@DP Popo Chest/Chest"}, {{133, 4}} },
    { {"@Desert Palace/Cannonball Chest", "@DP Cannonball/Chest"}, {{117, 4}} },
    { {"@Desert Palace/Torch", "@DP Torch/Torch"}, {{115, 10}} },
    { {"@Desert Palace/Big Chest", "@DP Big Chest/Chest"}, {{115, 4}} },
    { {"@Desert Palace/Lanmolas", "@DP Lanmolas/Boss"}, {{51, 11}} },

    { {"@Tower of Hera/Lobby", "@TH Lobby/Chest"}, {{119, 4}} },
    { {"@Tower of Hera/Cage", "@TH Cage/Item"}, {{135, 10}} },
    { {"@Tower of Hera/Basement", "@TH Basement/Chest"}, {{135, 4}} },
    { {"@Tower of Hera/Compass Chest", "@TH Compass Room/Chest"}, {{39, 5}} },
    { {"@Tower of Hera/Big Chest", "@TH Big Chest/Chest"}, {{39, 4}} },
    { {"@Tower of Hera/Moldorm", "@TH Moldorm/Boss"}, {{7, 11}} },

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
    { {"@Palace of Darkness/King Helmasaur", "@PoD King Helmasaur/Boss"}, {{90, 11}} },

    { {"@Swamp Palace/Entrance Chest", "@SP Entrance/Chest"}, {{40, 4}} },
    { {"@Swamp Palace/Bomb Wall", "@SP Bomb Wall/Chest"}, {{55, 4}} },
    { {"@Swamp Palace/South Side", "@SP South Side/Chest"}, {{70, 4}} },
    { {"@Swamp Palace/Far Left Chest", "@SP Far Left Chest/Chest"}, {{52, 4}} },
    { {"@Swamp Palace/Big Key Chest", "@SP Big Key Chest/Chest"}, {{53, 4}} },
    { {"@Swamp Palace/Big Chest", "@SP Big Chest/Chest"}, {{54, 4}} },
    { {"@Swamp Palace/Flooded Treasure", "@SP Flooded Treasure/Chest"}, {{118, 4}, {118, 5}} },
    { {"@Swamp Palace/Snake Waterfall", "@SP Snake Waterfall/Chest"}, {{102, 4}} },
    { {"@Swamp Palace/Arrghus", "@SP Arrghus/Boss"}, {{6, 11}} },

    { {"@Skull Woods/Map Chest", "@SW Map Chest/Chest"}, {{88, 5}} },
    { {"@Skull Woods/Gibdo Prison", "@SW Gibdo Prison/Chest"}, {{87, 5}} },
    { {"@Skull Woods/Compass Chest", "@SW Compass Room/Chest"}, {{103, 4}} },
    { {"@Skull Woods/Pinball", "@SW Pinball/Chest"}, {{104, 4}} },
    { {"@Skull Woods/Statue Switch", "@SW Statue Switch/Chest"}, {{87, 4}} },
    { {"@Skull Woods/Big Chest", "@SW Big Chest/Chest"}, {{88, 4}} },
    { {"@Skull Woods/Bridge", "@SW Bridge/Chest"}, {{89, 4}} },
    { {"@Skull Woods/Mothula", "@SW Mothula/Boss"}, {{41, 11}} },

    { {"@Thieves Town/Main Lobby", "@TT Main Lobby/Chest"}, {{219, 4}} },
    { {"@Thieves Town/Ambush", "@TT Ambush/Chest"}, {{203, 4}} },
    { {"@Thieves Town/SE Lobby", "@TT SE Lobby/Chest"}, {{220, 4}} },
    { {"@Thieves Town/Big Key Chest", "@TT Big Key Chest/Chest"}, {{219, 5}} },
    { {"@Thieves Town/Attic Chest", "@TT Attic/Chest"}, {{101, 4}} },
    { {"@Thieves Town/Prison Cell", "@TT Prison Cell/Chest"}, {{69, 4}} },
    { {"@Thieves Town/Big Chest", "@TT Big Chest/Chest"}, {{68, 4}} },
    { {"@Thieves Town/Blind", "@TT Blind/Boss"}, {{172, 11}} },

    { {"@Ice Palace/Pengator Room", "@IP Pengator Room/Chest"}, {{46, 4}} },
    { {"@Ice Palace/Spike Room", "@IP Spike Room/Chest"}, {{95, 4}} },
    { {"@Ice Palace/Ice Breaker", "@IP Ice Breaker/Chest"}, {{31, 4}} },
    { {"@Ice Palace/Tongue Pull", "@IP Tongue Pull/Chest"}, {{63, 4}} },
    { {"@Ice Palace/Freezor Chest", "@IP Freezor/Chest"}, {{126, 4}} },
    { {"@Ice Palace/Ice T", "@IP Ice T/Chest"}, {{174, 4}} },
    { {"@Ice Palace/Big Chest", "@IP Big Chest/Chest"}, {{158, 4}} },
    { {"@Ice Palace/Kholdstare", "@IP Kholdstare/Boss"}, {{222, 11}} },

    { {"@Misery Mire/Spike Switch", "@MM Spike Room/Chest"}, {{179, 4}} },
    { {"@Misery Mire/Bridge", "@MM Bridge/Chest"}, {{162, 4}} },
    { {"@Misery Mire/Main Hub", "@MM Main Hub/Chest"}, {{194, 4}} },
    { {"@Misery Mire/Torch Tiles Chest", "@MM Torch Tiles/Chest"}, {{193, 4}} },
    { {"@Misery Mire/Torch Cutscene", "@MM Torch Cutscene/Chest"}, {{209, 4}} },
    { {"@Misery Mire/Right Blue Pegs Chest", "@MM Right Blue Pegs/Chest"}, {{195, 5}} },
    { {"@Misery Mire/Big Chest", "@MM Big Chest/Chest"}, {{195, 4}} },
    { {"@Misery Mire/Vitreous", "@MM Vitreous/Boss"}, {{144, 11}} },

    { {"@Turtle Rock/Compass Room", "@TR Compass Room/Chest"}, {{214, 4}} },
    { {"@Turtle Rock/Roller Room", "@TR Roller Room/Chest"}, {{183, 4}, {183, 5}} },
    { {"@Turtle Rock/Chain Chomp", "@TR Chain Chomp/Chest"}, {{182, 4}} },
    { {"@Turtle Rock/Lava Chest", "@TR Lava/Chest"}, {{20, 4}} },
    { {"@Turtle Rock/Big Chest", "@TR Big Chest/Chest"}, {{36, 4}} },
    { {"@Turtle Rock/Crystaroller Chest", "@TR Crystaroller/Chest"}, {{4, 4}} },
    { {"@Turtle Rock/Laser Bridge", "@TR Laser Bridge/Chest"}, {{213, 4}, {213, 5}, {213, 6}, {213, 7}} },
    { {"@Turtle Rock/Trinexx", "@TR Trinexx/Boss"}, {{164, 11}} },

    { {"@Ganon's Tower/Hope Room", "@GT Hope Room/Chest"}, {{140, 5}, {140, 6}} },
    { {"@Ganon's Tower/Torch", "@GT Torch/Torch"}, {{140, 10}} },
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
    { {"@Eastern Palace/Dark Pot Key", "@EP Dark Pots/Key Pot"}, {{186, 10}}, {{186, 11}} },
    
    { {"@Desert Palace/Back Lobby Key", "@DP Back Lobby/Key Pot"}, {{99, 10}}, {{99, 10}} },
    { {"@Desert Palace/Beamos Hall Key", "@DP Beamos Hall/Key Pot"}, {{83, 10}}, {{83, 13}} },
    { {"@Desert Palace/Back Tiles Key", "@DP Back Tiles/Key Pot"}, {{67, 10}}, {{67, 8}} },

    { {"@Swamp Palace/Pot Row Key", "@SP Pot Row/Key Pot"}, {{56, 10}}, {{56, 12}} },
    { {"@Swamp Palace/Front Flood Key", "@SP Front Flood Pot/Pot"}, {{55, 10}}, {{55, 15}} },
    { {"@Swamp Palace/Hookshot Key", "@SP Hookshot Ledges/Key Pot"}, {{54, 10}}, {{54, 11}} },
    { {"@Swamp Palace/Left Flood Key", "@SP Left Flood Key/Pot"}, {{53, 10}}, {{53, 15}} },
    { {"@Swamp Palace/Waterway Key", "@SP Waterway/Key Pot"}, {{22, 10}}, {{22, 7}} },

    { {"@Skull Woods/West Lobby Key", "@SW West Lobby/Key Pot"}, {{86, 10}}, {{86, 2}} },

    { {"@Thieves Town/Hallway Key", "@TT Hallway/Key Pot"}, {{188, 10}}, {{188, 14}} },
    { {"@Thieves Town/Spike Switch Key", "@TT Spike Switch/Pot"}, {{171, 10}}, {{171, 15}} },

    { {"@Ice Palace/Boulder Key", "@IP Tongue Pull/Boulder"}, {{63, 10}}, {{63, 9}} },
    { {"@Ice Palace/Ice Hell Key", "@IP Hell on Ice/Key Pot"}, {{159, 10}}, {{159, 11}} },

    { {"@Misery Mire/Spike Key", "@MM Spike Room/Key Pot"}, {{179, 10}}, {{179, 15}} },
    { {"@Misery Mire/Fishbone Key", "@MM Fishbone/Key Pot"}, {{161, 10}}, {{161, 15}} },

    { {"@Ganon's Tower/Conveyor Bumper Key", "@GT Conveyor Bumper/Key Pot"}, {{139, 10}}, {{139, 14}} },
    { {"@Ganon's Tower/Double Switch Key", "@GT Double Switch/Key Pot"}, {{155, 10}}, {{155, 14}} },
    { {"@Ganon's Tower/Post-Compass Key", "@GT Post-Compass/Key Pot"}, {{123, 10}}, {{123, 11}} }
}

DATA.MEMORY.DungeonPotDrops = {
    { "@HC West Lobby/Pots",             {{0x60, {14, 15}}} },
    { "@HC West Corridor/Pots",          {{0x50, {14, 15}}} },
    { "@HC East Lobby/Pot",              {{0x62, {15}}} },
    { "@HC East Corridor/Pots",          {{0x52, {14, 15}}} },
    { "@HC Basement Abyss/Pots",         {{0x82, {13, 14, 15}}} },
    { "@HC Prison/Pots",                 {{0x80, {13, 14, 15}}} },
    { "@HC Escape Trap/Pots",            {{0x41, {12, 13, 14, 15}}} },
    { "@HC Dark Cross/Pot",              {{0x32, {15}}} },
    { "@HC Damp Rats/Pots",              {{0x21, {10, 11, 12, 13, 14, 15}}} },
    { "@HC Back/Pots",                   {{0x11, {10, 11, 12, 13, 14, 15}}} },
    { "@HC Rat Switch/Pots",             {{0x02, {12, 13, 14, 15}}} },

    { "@EP Lobby/Pots",                  {{0xc9, {13, 14, 15}}} }, --switch is 13
    { "@EP Cannonball/Pots",             {{0xb9, {12, 13, 14, 15}}} },
    { "@EP Decision/Pots",               {{0xa9, {8, 9, 10, 11}}} },
    { "@EP East Switch/Pots",            {{0xaa, {11, 12, 13, 14, 15}}} }, --switch is 11
    { "@EP Hook/Hidden Pots",            {{0xaa, {8, 9, 10}}} },
    { "@EP Stalfos Spawn/Pots",          {{0xa8, {11, 12, 13, 14, 15}}} },
    { "@EP Big Chest Room/Pots",         {{0xa9, {12, 13, 14, 15}}} },
    { "@EP Dark Pots/Pots",              {{0xba, {8, 9, 10, 12, 13, 14, 15}}} },
    { "@EP Big Key Chest/Pots",          {{0xb8, {13, 14, 15}}} }, --switch is 15
    { "@EP Dark Eyegore/Pots",           {{0x99, {14, 15}}} },
    { "@EP Dual Antifairy/Pots",         {{0xda, {12, 13, 14, 15}}} }, --switch is 13
    { "@EP Cannonball Rapid Fire/Pots",  {{0xd9, {14, 15}}} },
    { "@EP Red Eyegore/Pots",            {{0xd8, {8, 9}}} },
    { "@EP Boss Guards/Pots",            {{0xd8, {10, 11, 12, 13, 14, 15}}} },

    { "@DP Main Lobby/Pots",             {{0x84, {8, 9, 10, 11, 12, 13, 14, 15}}} },
    { "@DP Eyegore Switch/Pots",         {{0x74, {9, 10, 11, 12, 13, 14, 15}}} }, --switch is 14
    { "@DP Northeast Corner/Pots",       {{0x75, {13, 14, 15}}} },
    { "@DP East Lobby/Pots",             {{0x85, {14, 15}}} },
    { "@DP Big Chest Approach/Pots",     {{0x73, {6, 7, 8, 9, 10, 11, 12, 13, 14, 15}}} }, --switch is 13
    { "@DP West Lobby/Pots",             {{0x83, {12, 13, 14, 15}}} },
    { "@DP Back Lobby/Pots",             {{0x63, {11, 12, 13, 14, 15}}} },
    { "@DP Beamos Hall/Pots",            {{0x53, {12, 14, 15}}} },
    { "@DP Back Tiles/Pots",             {{0x43, {9, 10, 11}}} },
    { "@DP Pre-Lanmolas/Pots",           {{0x43, {12, 13, 14, 15}}} },

    { "@TH Basement Switch/Pots",        {{0x87, {10, 11, 12, 13, 14, 15}}} },
    { "@TH Basement/Pots",               {{0x87, {8, 9}}} },
    { "@TH Second Floor/Pots",           {{0x31, {14, 15}}} },
    { "@TH Compass Room/Pots",           {{0x27, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}}} },
    { "@TH Imprisoned Pots/Pots",        {{0x17, {4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}}} },

    { "@AT Dark Chest/Pots",             {{0xd0, {9, 10, 11, 12, 13, 14, 15}}} },
    { "@AT Dark Pits/Pots",              {{0xc0, {12, 13, 14, 15}}} },
    { "@AT Circle of Pots/Pots",         {{0xb0, {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}}} },

    { "@PoD Lobby/West Pots",            {{0x4a, {12, 13, 14, 15}}} }, --switch is 15
    { "@PoD Lobby/Pots",                 {{0x4a, {6, 7, 8, 9, 10, 11}}} }, --switch is 8
    { "@PoD Shooter/Pots",               {{0x09, {13, 14, 15}}} }, --switch is 13
    { "@PoD Mimics 1/Pots",              {{0x4b, {14, 15}}} },
    { "@PoD Bow Side/Pots",              {{0x2b, {6, 7, 8, 9}}} },
    { "@PoD Arena/Pots",                 {{0x2a, {14, 15}}} },
    { "@PoD Basement Ledge/Pots",        {{0x0a, {9, 10}}} },
    { "@PoD Stalfos Basement/Pots",      {{0x0a, {11, 12, 13, 14, 15}}} }, --switch is 13
    { "@PoD Falling Bridge/Pots",        {{0x1a, {12, 13, 14, 15}}} },
    { "@PoD Harmless Hellway/Pots",      {{0x1a, {10, 11}}} },
    { "@PoD Sexy Statue/Pots",           {{0x2b, {10, 11, 12, 13, 14, 15}}} }, --switch is 14
    { "@PoD Mimics 2/Pots",              {{0x1b, {14, 15}}} },
    { "@PoD Lonely Turtle/Pots",         {{0x0b, {14, 15}}} },

    { "@SP Pot Row/Pots",                {{0x38, {13, 14, 15}}} },
    { "@SP Front Flood Upper/Pot",       {{0x37, {14}}} },
    { "@SP Isolated Ledge/Pots",         {{0x36, {14, 15}}} },
    { "@SP Hookshot Ledges/Pot",         {{0x36, {10}}} },
    { "@SP Hookshot Ledges/West Pots",   {{0x36, {12, 13}}} },
    { "@SP Hookshot Ledges/North Pots",  {{0x36, {8, 9}}} },
    { "@SP South Pots/Pots",             {{0x46, {14, 15}}} },
    { "@SP Left Flood Area/Pots",        {{0x35, {3, 4, 5, 6, 7, 8}}} },
    { "@SP Left Flood Area West/Pot",    {{0x35, {9}}} },
    { "@SP Attic/Pots",                  {{0x54, {12, 13, 14, 15}}} },
    { "@SP Far Left Chest/Pots",         {{0x34, {14, 15}}} },
    { "@SP Big Key Chest/Pots",          {{0x35, {10, 11, 12, 13, 14}}} },
    { "@SP Statue Switch/Pots",          {{0x26, {11, 12, 13}}} }, --switch is 13
    { "@SP Medusa Protection/Pots",      {{0x26, {14, 15}}} },
    { "@SP Drain Switch/Pot",            {{0x76, {15}}} },
    { "@SP Flooded Treasure/Pots",       {{0x76, {13, 14}}} },
    { "@SP Waterfall Storage Room/Pots", {{0x66, {10, 11, 12, 13, 14, 15}}} },
    { "@SP Waterfall Hidden Path/Pots",  {{0x66, {6, 7, 8, 9}}} },
    { "@SP Waterway/Pots",               {{0x16, {8, 9, 10, 11, 12, 13, 14, 15}}} },

    { "@SW Circle of Pots/Pots",         {{0x58, {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}}} },
    { "@SW Behind Big Chest/Pots",       {{0x58, {12, 13, 14, 15}}} },
    { "@SW Gibdo Prison/Pots",           {{0x57, {10, 11, 12, 13}}} },
    { "@SW Compass Room/Pots",           {{0x67, {5, 6, 7, 8, 9}}} },
    { "@SW Firebar Dropdown/Pots",       {{0x67, {10, 11, 12, 13, 14, 15}}} },
    { "@SW Pinball/Pots",                {{0x68, {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}}} },
    { "@SW Statue Switch/Pots",          {{0x57, {7, 8, 9}}} }, --switch is 7
    { "@SW Statue Switch/Pot",           {{0x57, {14}}} },
    { "@SW Small Room/Pot",              {{0x57, {15}}} },
    { "@SW West Lobby/Pot",              {{0x56, {1}}} },
    { "@SW West Lobby/Dropdown Pots",    {{0x56, {13, 14, 15}}} },
    { "@SW Many Pots/Pots",              {{0x56, {3, 4, 5, 6, 7, 8, 9, 10, 11, 12}}} },
    { "@SW Bridge/Hidden Pots",          {{0x59, {14, 15}}} },
    { "@SW Bridge/Catwalk Pots",         {{0x59, {12, 13}}} },
    { "@SW Star Pots/Pots",              {{0x49, {5, 6, 7, 8, 9, 10, 11, 12, 13}}} },
    { "@SW Torch Pots/Pots",             {{0x49, {14, 15}}} },
    { "@SW Gibdo/Pots",                  {{0x39, {14, 15}}} },
    { "@SW Mothula Hole/Pots",           {{0x39, {12, 13}}} },

    { "@TT Main Lobby/Pots",             {{0xdb, {12, 13, 14, 15}}} },
    { "@TT Ambush/Pots",                 {{0xcb, {12, 13, 14, 15}}} },
    { "@TT NE Lobby/West Pots",          {{0xcc, {14, 15}}} },
    { "@TT NE Lobby/East Pots",          {{0xcc, {12, 13}}} },
    { "@TT SE Lobby/Pots",               {{0xdc, {12, 13, 14, 15}}} },
    { "@TT Hallway/Pot",                 {{0xbc, {15}}} },
    { "@TT Pot Alcove Top/Pots",         {{0xbc, {4, 5}}} },
    { "@TT Pot Alcove Main/Pots",        {{0xbc, {6, 7, 8, 9}}} },
    { "@TT Pot Alcove Bottom/Pots",      {{0xbc, {2, 3}}} },
    { "@TT Attic Switch Pots/Pots",      {{0x64, {9, 10, 11, 12, 13, 14, 15}}} }, --switch is 9
    { "@TT Attic/Pots",                  {{0x65, {14, 15}}} },
    { "@TT Toilet Bowl/Pots",            {{0xbc, {10, 11, 12, 13}}} }, --switch is 12
    { "@TT Basement Entry/Pots",         {{0x45, {14, 15}}} },
    { "@TT Basement Entry/Boulder",      {{0x45, {9}}} },
    { "@TT Basement Conveyor/Boulder",   {{0x44, {15}}} },
    { "@TT Prison Cell/Pots",            {{0x45, {10, 11, 12, 13}}} },

    { "@IP Pengator Switch/Pot",         {{0x1f, {14, 15}}} }, --switch is 15
    { "@IP Bomb Pit/Pot",                {{0x1e, {15}}} },
    { "@IP Stalfos Knights/Pots",        {{0x3e, {12, 13, 14, 15}}} },
    { "@IP Tongue Pull/Pots",            {{0x3f, {10, 11, 12, 13, 14, 15}}} }, --switch is 11
    { "@IP Ice Breaker/Pots",            {{0x1f, {12, 13}}} },
    { "@IP Bomb Jump/Pots",              {{0x4e, {12, 13, 14, 15}}} }, --switch is 13
    { "@IP Bomb Jump/Solo Pot",          {{0x4e, {11}}} },
    { "@IP Falling Square/Pots",         {{0x5e, {12, 13, 14, 15}}} },
    { "@IP Tall Ice/Pots",               {{0x7e, {12, 13, 14, 15}}} }, --switch is 13
    { "@IP Hell on Ice/Pots",            {{0x9f, {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15}}} }, --switch is 12
    { "@IP Lonely Freezor/Pots",         {{0x8e, {14, 15}}} },
    { "@IP Basement Switch/Pots",        {{0xbf, {10, 11, 12, 13, 14, 15}}} },
    { "@IP Pre-Kholdstare/Pots",         {{0xce, {14, 15}}} },
    { "@IP Pre-Kholdstare/Boulder",      {{0xce, {10}}} },
    { "@IP Pre-Kholdstare/Hammer Pots",  {{0xce, {12, 13}}} },

    { "@MM Main Hub/Pots",               {{0xc2, {12, 13, 14, 15}}} }, --switch is 15
    { "@MM Spike Room/Pot",              {{0xb3, {13, 14}}} }, --switch is 13
    { "@MM Fishbone/North Pots",         {{0xa1, {11, 12, 13, 14}}} },
    { "@MM Fishbone/South Pots",         {{0xa1, {5, 6, 7, 8, 9, 10}}} },
    { "@MM Hourglass/Pots",              {{0xb1, {14, 15}}} },
    { "@MM Neglected Room/Pots",         {{0xd1, {10, 11, 12, 13}}} },
    { "@MM Conveyor Wall/Pots",          {{0xd1, {14, 15}}} },
    { "@MM Big Door/Pots",               {{0xb2, {10, 11, 12, 13, 14, 15}}} },
    { "@MM Bridge/Pot",                  {{0xa2, {15}}} },
    { "@MM Dark Shooter/Pot",            {{0x93, {13, 15}}} }, --switch is 15
    { "@MM Block X/Boulder",             {{0x93, {14}}} },
    { "@MM Dark Crystal/Pots",           {{0x92, {12, 13, 14, 15}}} },
    { "@MM Falling Foes/Pots",           {{0x91, {14, 15}}} },

    { "@TR Lobby/Pots",                  {{0xd6, {14, 15}}} },
    { "@TR Hub/Pots",                    {{0xc6, {14, 15}}} },
    { "@TR Torches Ledge/Pots",          {{0xc7, {12, 13}}} },
    { "@TR Torches/Pots",                {{0xc7, {14, 15}}} },
    { "@TR Roller Room/Pot",             {{0xb7, {15}}} },
    { "@TR Tile Room/Pot",               {{0xb6, {15}}} },
    { "@TR Pipes/Northeast Pots",        {{0x15, {11, 12, 13, 14, 15}}} },
    { "@TR Pipes/Northwest Pots",        {{0x15, {8, 9, 10}}} },
    { "@TR Pipes/Pot",                   {{0x15, {7}}} },
    { "@TR Double Pokey/Pots",           {{0x24, {12, 13, 14, 15}}} },
    { "@TR Laser Death/Pots",            {{0x23, {11, 12, 13, 14, 15}}} },
    { "@TR Pokey Dash/Pots",             {{0x04, {12, 13, 14, 15}}} },
    { "@TR Tongue Pull/Pots",            {{0x04, {10, 11}}} },
    { "@TR Dark Room/Pots",              {{0xb5, {10, 11, 12, 13, 14, 15}}} }, --switch is 13
    { "@TR Peg Maze/Pots",               {{0xc4, {8, 9, 10, 11, 12, 13, 14, 15}}} },
    { "@TR Final Ride/Pots",             {{0xb4, {14, 15}}} },

    { "@GT Hope Room/Pot",               {{0x8c, {14, 15}}} }, --switch is 15
    { "@GT Conveyor Bumper/Pot",         {{0x8b, {15}}} },
    { "@GT Hookshot Pits/Island Pot",    {{0x8b, {11}}} },
    { "@GT Hookshot Pits/Pots",          {{0x8b, {12, 13}}} },
    { "@GT Map Chest/Pots",              {{0x8b, {9, 10}}} },
    { "@GT Double Switch/Pot",           {{0x9b, {15}}} },
    { "@GT Firesnake/Pots",              {{0x7d, {13, 14, 15}}} },
    { "@GT Warps/Pots",                  {{0x9b, {12, 13}}} },
    { "@GT Mini Warp/Pot",               {{0x7d, {12}}} },
    { "@GT Petting Zoo/Pots",            {{0x7d, {10, 11}}} },
    { "@GT Conveyor Torches/Pots",       {{0x8d, {14, 15}}} },
    { "@GT Checkerboard Pots/Pots",      {{0x8d, {11, 12, 13}}} },
    { "@GT Conveyor Crystal/Pots",       {{0x9d, {14, 15}}} },
    { "@GT Compass Room/Pots",           {{0x9d, {12, 13}}} },
    { "@GT Post-Compass/Pots",           {{0x7b, {12, 13, 14, 15}}} },
    { "@GT Falling Bridge/Pots",         {{0x7c, {12, 13, 14, 15}}} },
    { "@GT Invisifloor/Pots",            {{0x9c, {14, 15}}} },
    { "@GT Bob/Pots",                    {{0x8c, {9, 10, 11, 12, 13}}} },
    { "@GT Crystal Paths/Pots",          {{0x6b, {10, 11, 12, 13, 14, 15}}} },
    { "@GT Mimics/Pots",                 {{0x6b, {8, 9}}} },
    { "@GT Sneaky Spikes/Pots",          {{0x5b, {13, 14, 15}}} }, --switch is 14
    { "@GT Refill/Pots",                 {{0x5c, {8, 9, 10, 11, 12, 13, 14, 15}}} },
    { "@GT Gauntlet Conveyor/Pots",      {{0x5d, {12, 13, 14, 15}}} },
    { "@GT Conveyor Spikes/Pots",        {{0x5d, {8, 9, 10, 11}}} },
    { "@GT Ice Gauntlet/Pots",           {{0x6d, {12, 13, 14, 15}}} },
    { "@GT Post Lanmolas/Pots",          {{0x6c, {12, 13, 14, 15}}} },
    { "@GT Climb Torches/Pots",          {{0x96, {10, 11, 12, 13, 14, 15}}} },
    { "@GT Staredown/Pots",              {{0x96, {8, 9}}} },
    { "@GT Mini Helmasaur/Pots",         {{0x3d, {14, 15}}} },
    { "@GT Pre-Moldorm/Pots",            {{0x3d, {9, 10, 11, 12, 13}}} }
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
    { "@Tavern Back/Back Pots",           {{0x103, {14, 15}}} },
    { "@Tavern Back/Front Pot",           {{0x103, {13}}} },
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
    { "@Superbunny Cave/Top Pot",         {{0xe8,  {15}}} },
    { "@Superbunny Cave/Pot",             {{0xf8,  {15}}} },
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
    { "@Eastern Palace/Armos", "@Eastern Palace/Prize", "@EP Armos/Prize" },
    { "@Desert Palace/Lanmolas", "@Desert Palace/Prize", "@DP Lanmolas/Prize" },
    { "@Tower of Hera/Moldorm", "@Tower of Hera/Prize", "@TH Moldorm/Prize" },
    { "@Palace of Darkness/King Helmasaur", "@Palace of Darkness/Prize", "@PoD King Helmasaur/Prize" },
    { "@Swamp Palace/Arrghus", "@Swamp Palace/Prize", "@SP Arrghus/Prize" },
    { "@Skull Woods/Mothula", "@Skull Woods/Prize", "@SW Mothula/Prize" },
    { "@Thieves Town/Blind", "@Thieves Town/Prize", "@TT Blind/Prize" },
    { "@Ice Palace/Kholdstare", "@Ice Palace/Prize", "@IP Kholdstare/Prize" },
    { "@Misery Mire/Vitreous", "@Misery Mire/Prize", "@MM Vitreous/Prize" },
    { "@Turtle Rock/Trinexx", "@Turtle Rock/Prize", "@TR Trinexx/Prize" }
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
    { {"@Tavern Back/Back Room"},        {{259, 4}} },
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
    { {"@Cold Bee Cave/Fairy Statue"},   {{288, 9}} },
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
    local clock = os.clock()
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

                --Key/Dungeon Pots
                if data[2] and OBJ_POOL_DUNGEONPOT:getState() < 2 then
                    updateDoorKeyCountFromRoomSlotList(segment, dungeonPrefix .. "_potkey", data[2])
                end
            end
        end
    end

    for i, boss in ipairs(INSTANCE.MEMORY.Bosses) do
        local bossflag = segment:ReadUInt16(0x7ef000 + (boss[2][1] * 2)) & (1 << boss[2][2])
        local item = findObjectForCode(boss[1])
        if item and OBJ_GLITCHMODE:getState() < 3 and not INSTANCE.NEW_SRAM_SYSTEM then
            item.Active = bossflag > 0
        end

        if INSTANCE.MEMORY.BossLocations[i] and not CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING and Tracker.ActiveVariantUID ~= "vanilla" then
            item = findObjectForCode(INSTANCE.MEMORY.BossLocations[i][1])
            if item then
                item.AvailableChestCount = bossflag == 0 and 1 or 0
                
                if item.AvailableChestCount == 0 then
                    --INSTANCE.MEMORY.BossLocations[i] = nil

                    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                        print("Boss Defeated:", INSTANCE.MEMORY.BossLocations[i][1])
                    end
                end
            else
                print("Couldn't find location", item)
            end
            if not INSTANCE.NEW_SRAM_SYSTEM then
                item = findObjectForCode(INSTANCE.MEMORY.BossLocations[i][2])
                if item then
                    item.AvailableChestCount = bossflag == 0 and 1 or 0
                    item = findObjectForCode(INSTANCE.MEMORY.BossLocations[i][3])
                    item.AvailableChestCount = bossflag == 0 and 1 or 0
                    
                    if item.AvailableChestCount == 0 then
                        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                            print("Boss Defeated:", INSTANCE.MEMORY.BossLocations[i][2])
                        end
                    end
                end
            end
        end
    end

    if CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID == "vanilla" then
        return true
    end

    local function updateChest(dungeonPrefix, slotList)
        if updateDungeonChestCountFromRoomSlotList(segment, dungeonPrefix, slotList) then
            --Refresh Dungeon Calc
            if OBJ_GLITCHMODE:getState() >= 2 or dungeonPrefix == DATA.DungeonIdMap[CACHE.DUNGEON] then
                updateChestCountFromDungeon(nil, dungeonPrefix, nil)
            end
        end
    end

    --Dungeon Chests
    updateChest("hc", {{114, 4}, {113, 4}, {128, 4}, {50, 4}, {17, 4}, {17, 5}, {17, 6}, {18, 4}})
    updateChest("ep", {{185, 4}, {170, 4}, {168, 4}, {169, 4}, {184, 4}, {200, 11}})
    updateChest("dp", {{115, 4}, {115, 10}, {116, 4}, {133, 4}, {117, 4}, {51, 11}})
    updateChest("toh", {{135, 10}, {119, 4}, {135, 4}, {39, 4}, {39, 5}, {7, 11}})
    updateChest("at", {{224, 4}, {208, 4}})
    updateChest("pod", {{9, 4}, {43, 4}, {42, 4}, {42, 5}, {58, 4}, {10, 4}, {26, 4}, {26, 5}, {26, 6}, {25, 4},  {25, 5}, {106, 4}, {106, 5}, {90, 11}})
    updateChest("sp", {{40, 4}, {55, 4}, {54, 4}, {53, 4}, {52, 4}, {70, 4}, {118, 4}, {118, 5}, {102, 4}, {6, 11}})
    updateChest("sw", {{103, 4}, {104, 4}, {87, 4}, {87, 5}, {88, 4}, {88, 5}, {89, 4}, {41, 11}})
    updateChest("tt", {{219, 4}, {219, 5}, {203, 4}, {220, 4}, {101, 4}, {69, 4}, {68, 4}, {172, 11}})
    updateChest("ip", {{46, 4}, {63, 4}, {31, 4}, {95, 4}, {126, 4}, {174, 4}, {158, 4}, {222, 11}})
    updateChest("mm", {{162, 4}, {179, 4}, {194, 4}, {193, 4}, {209, 4}, {195, 4}, {195, 5}, {144, 11}})
    updateChest("tr", {{214, 4}, {183, 4}, {183, 5}, {182, 4}, {20, 4}, {36, 4}, {4, 4}, {213, 4}, {213, 5}, {213, 6}, {213, 7}, {164, 11}})
    updateChest("gt", {{140, 10}, {123, 4}, {123, 5}, {123, 6}, {123, 7}, {139, 4}, {125, 4}, {124, 4}, {124, 5}, {124, 6}, {124, 7}, {140, 4}, {140, 5}, {140, 6}, {140, 7}, {28, 4}, {28, 5}, {28, 6}, {141, 4}, {157, 4}, {157, 5}, {157, 6}, {157, 7}, {61, 4}, {61, 5}, {61, 6}, {77, 4}})

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
    
    if os.clock() - clock > 0.005 then
        printLog(string.format("Update UW LAG: %f", os.clock() - clock), 1)
    end
end

DATA.MEMORY.NewDropData = {
    --          enemy drops                                  pot keys
    ["hc"] =  { {{114, 15}, {113, 14}, {128, 13}, {33, 15}}, nil,                                               {{0x60, {14, 15}}, {0x50, {14, 15}}, {0x62, {15}}, {0x52, {14, 15}}, {0x82, {13, 14, 15}}, {0x80, {13, 14, 15}}, {0x41, {12, 13, 14, 15}}, {0x32, {15}}, {0x21, {10, 11, 12, 13, 14, 15}}, {0x11, {10, 11, 12, 13, 14, 15}}, {0x02, {12, 13, 14, 15}}} },
    ["ep"] =  { {{153, 12}},                                 {{186, 11}},                                       {{0xc9, {13, 14, 15}}, {0xb9, {12, 13, 14, 15}}, {0xa9, {8, 9, 10, 11}}, {0xaa, {11, 12, 13, 14, 15}}, {0xaa, {8, 9, 10}}, {0xa8, {11, 12, 13, 14, 15}}, {0xa9, {12, 13, 14, 15}}, {0xba, {8, 9, 10, 12, 13, 14, 15}}, {0xb8, {13, 14, 15}}, {0x99, {14, 15}}, {0xda, {12, 13, 14, 15}}, {0xd9, {14, 15}}, {0xd8, {8, 9}}, {0xd8, {10, 11, 12, 13, 14, 15}}} },
    ["dp"] =  { nil,                                         {{99, 10}, {83, 13}, {67, 8}},                     {{0x84, {8, 9, 10, 11, 12, 13, 14, 15}}, {0x74, {9, 10, 11, 12, 13, 14, 15}}, {0x75, {13, 14, 15}}, {0x85, {14, 15}}, {0x73, {6, 7, 8, 9, 10, 11, 12, 13, 14, 15}}, {0x83, {12, 13, 14, 15}}, {0x63, {11, 12, 13, 14, 15}}, {0x53, {12, 14, 15}}, {0x43, {9, 10, 11}}, {0x43, {12, 13, 14, 15}}} },
    ["toh"] = { nil,                                         nil,                                               {{0x87, {10, 11, 12, 13, 14, 15}}, {0x87, {8, 9}}, {0x31, {14, 15}}, {0x27, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}}, {0x17, {4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}}} },
    ["at"] =  { {{192, 12}, {176, 5}},                       nil,                                               {{0xd0, {9, 10, 11, 12, 13, 14, 15}}, {0xc0, {12, 13, 14, 15}}, {0xb0, {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}}} },
    ["pod"] = { nil,                                         nil,                                               {{0x4a, {12, 13, 14, 15}}, {0x4a, {6, 7, 8, 9, 10, 11}}, {0x09, {13, 14, 15}}, {0x4b, {14, 15}}, {0x2b, {6, 7, 8, 9}}, {0x2a, {14, 15}}, {0x0a, {9, 10, 11, 12, 13, 14, 15}}, {0x1a, {12, 13, 14, 15}}, {0x1a, {10, 11}}, {0x2b, {10, 11, 12, 13, 14, 15}}, {0x1b, {14, 15}}, {0x0b, {14, 15}}} },
    ["sp"] =  { nil,                                         {{56, 12}, {55, 15}, {54, 11}, {53, 15}, {22, 7}}, {{0x38, {13, 14, 15}}, {0x37, {14}}, {0x36, {14, 15}}, {0x36, {10}}, {0x36, {12, 13}}, {0x36, {8, 9}}, {0x46, {14, 15}}, {0x35, {3, 4, 5, 6, 7, 8}}, {0x35, {9}}, {0x54, {12, 13, 14, 15}}, {0x34, {14, 15}}, {0x35, {10, 11, 12, 13, 14}}, {0x26, {11, 12, 13}}, {0x26, {14, 15}}, {0x76, {15}}, {0x76, {13, 14}}, {0x66, {10, 11, 12, 13, 14, 15}}, {0x66, {6, 7, 8, 9}}, {0x16, {8, 9, 10, 11, 12, 13, 14, 15}}} },
    ["sw"] =  { {{57, 14}},                                  {{86, 2}},                                         {{0x58, {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}}, {0x58, {12, 13, 14, 15}}, {0x57, {10, 11, 12, 13}}, {0x67, {5, 6, 7, 8, 9}}, {0x67, {10, 11, 12, 13, 14, 15}}, {0x68, {3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}}, {0x57, {7, 8, 9}}, {0x57, {14}}, {0x57, {15}}, {0x56, {1}}, {0x56, {13, 14, 15}}, {0x56, {3, 4, 5, 6, 7, 8, 9, 10, 11, 12}}, {0x59, {14, 15}}, {0x59, {12, 13}}, {0x49, {5, 6, 7, 8, 9, 10, 11, 12, 13}}, {0x49, {14, 15}}, {0x39, {14, 15}}, {0x39, {12, 13}}} },
    ["tt"] =  { nil,                                         {{188, 14}, {171, 15}},                            {{0xdb, {12, 13, 14, 15}}, {0xcb, {12, 13, 14, 15}}, {0xcc, {14, 15}}, {0xcc, {12, 13}}, {0xdc, {12, 13, 14, 15}}, {0xbc, {15}}, {0xbc, {4, 5}}, {0xbc, {6, 7, 8, 9}}, {0xbc, {2, 3}}, {0x64, {9, 10, 11, 12, 13, 14, 15}}, {0x65, {14, 15}}, {0xbc, {10, 11, 12, 13}}, {0x45, {14, 15}}, {0x45, {9}}, {0x44, {15}}, {0x45, {10, 11, 12, 13}}} },
    ["ip"] =  { {{14, 12}, {62, 7}},                         {{63, 9}, {159, 11}},                              {{0x1f, {14, 15}}, {0x1e, {15}}, {0x3e, {12, 13, 14, 15}}, {0x3f, {10, 11, 12, 13, 14, 15}}, {0x1f, {12, 13}}, {0x4e, {12, 13, 14, 15}}, {0x4e, {11}}, {0x5e, {12, 13, 14, 15}}, {0x7e, {12, 13, 14, 15}}, {0x9f, {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15}}, {0x8e, {14, 15}}, {0xbf, {10, 11, 12, 13, 14, 15}}, {0xce, {14, 15}}, {0xce, {10}}, {0xce, {12, 13}}} },
    ["mm"] =  { {{193, 6}},                                  {{179, 15}, {161, 15}},                            {{0xc2, {12, 13, 14, 15}}, {0xb3, {13, 14}}, {0xa1, {11, 12, 13, 14}}, {0xa1, {5, 6, 7, 8, 9, 10}}, {0xb1, {14, 15}}, {0xd1, {10, 11, 12, 13}}, {0xd1, {14, 15}}, {0xb2, {10, 11, 12, 13, 14, 15}}, {0xa2, {15}}, {0x93, {13, 15}}, {0x93, {14}}, {0x92, {12, 13, 14, 15}}, {0x91, {14, 15}}} },
    ["tr"] =  { {{182, 10}, {19, 9}},                        nil,                                               {{0xd6, {14, 15}}, {0xc6, {14, 15}}, {0xc7, {12, 13}}, {0xc7, {14, 15}}, {0xb7, {15}}, {0xb6, {15}}, {0x15, {11, 12, 13, 14, 15}}, {0x15, {8, 9, 10}}, {0x15, {7}}, {0x24, {12, 13, 14, 15}}, {0x23, {11, 12, 13, 14, 15}}, {0x04, {12, 13, 14, 15}}, {0x04, {10, 11}}, {0xb5, {10, 11, 12, 13, 14, 15}}, {0xc4, {8, 9, 10, 11, 12, 13, 14, 15}}, {0xb4, {14, 15}}} },
    ["gt"] =  { {{61, 13}},                                  {{139, 14}, {155, 14}, {123, 11}},                 {{0x8c, {14, 15}}, {0x8b, {15}}, {0x8b, {11}}, {0x8b, {12, 13}}, {0x8b, {9, 10}}, {0x9b, {15}}, {0x7d, {13, 14, 15}}, {0x9b, {12, 13}}, {0x7d, {12}}, {0x7d, {10, 11}}, {0x8d, {14, 15}}, {0x8d, {11, 12, 13}}, {0x9d, {14, 15}}, {0x9d, {12, 13}}, {0x7b, {12, 13, 14, 15}}, {0x7c, {12, 13, 14, 15}}, {0x9c, {14, 15}}, {0x8c, {9, 10, 11, 12, 13}}, {0x6b, {10, 11, 12, 13, 14, 15}}, {0x6b, {8, 9}}, {0x5b, {13, 14, 15}}, {0x5c, {8, 9, 10, 11, 12, 13, 14, 15}}, {0x5d, {12, 13, 14, 15}}, {0x5d, {8, 9, 10, 11}}, {0x6d, {12, 13, 14, 15}}, {0x6c, {12, 13, 14, 15}}, {0x96, {10, 11, 12, 13, 14, 15}}, {0x96, {8, 9}}, {0x3d, {14, 15}}, {0x3d, {9, 10, 11, 12, 13}}} }
}

function updateRoomEnemiesFromMemorySegment(segment)
    local clock = os.clock()
    if CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID == "vanilla" or not INSTANCE.NEW_POTDROP_SYSTEM or not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Room Enemies")
    end

    --Enemy Keys
    local modified = false
    for dungeonPrefix, data in pairs(DATA.MEMORY.NewDropData) do
        if data[1] then
            if updateDoorKeyCountFromRoomSlotList(segment, dungeonPrefix .. "_enemykey", data[1], INSTANCE.VERSION_MINOR < 2 and 0x7850 or 0x7268) then
                modified = true
            end
        end
    end

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
    if modified and CACHE.DUNGEON ~= 0xff then
        --Refresh Dungeon Calc
        updateChestCountFromDungeon(nil, DATA.DungeonIdMap[CACHE.DUNGEON], nil)
    end
    
    if os.clock() - clock > 0.005 then
        printLog(string.format("Update Drops LAG: %f", os.clock() - clock), 1)
    end
end

function updateRoomPotsFromMemorySegment(segment)
    local clock = os.clock()
    if CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING or Tracker.ActiveVariantUID == "vanilla" or not INSTANCE.NEW_POTDROP_SYSTEM or not isInGame() then
        return false
    end
    
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Room Pots")
    end

    --Key/Dungeon Pots
    local modified = false
    for dungeonPrefix, data in pairs(DATA.MEMORY.NewDropData) do
        if updateDoorKeyCountFromRoomSlotList(segment, dungeonPrefix .. "_potkey", data[2], INSTANCE.VERSION_MINOR < 2 and 0x7600 or 0x7018, OBJ_POOL_DUNGEONPOT:getState() >= 2 and data[3] or nil) then
            modified = true
        end
    end

    --Cave Pot Drop Locations
    if OBJ_POOL_CAVEPOT and OBJ_POOL_CAVEPOT:getState() > 0 then
        i = 1
        while i <= #INSTANCE.MEMORY.CavePotDrops do
            if updateRoomLocation(segment, INSTANCE.MEMORY.CavePotDrops[i], 0x7018) then
                table.remove(INSTANCE.MEMORY.CavePotDrops, i)
            else
                i = i + 1
            end
        end
    end

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
                if updateRoomLocation(segment, INSTANCE.MEMORY.DungeonPotDrops[i], 0x7018) then
                    table.remove(INSTANCE.MEMORY.DungeonPotDrops, i)
                else
                    i = i + 1
                end
            end
        end
    end
    if modified and CACHE.DUNGEON ~= 0xff then
        --Refresh Dungeon Calc
        updateChestCountFromDungeon(nil, DATA.DungeonIdMap[CACHE.DUNGEON], nil)
    end
    
    if os.clock() - clock > 0.005 then
        printLog(string.format("Update Pots LAG: %f", os.clock() - clock), 1)
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

    for dungeonPrefix, data in pairs(DATA.DungeonData) do
        local modified = false
        local item = findObjectForCode(dungeonPrefix .. "_bigkey")
        item.Active = bkdata & data[3] > 0
        local mcbk = item.Active and 4 or 0
        
        item = findObjectForCode(dungeonPrefix .. "_map")
        item.Active = mapdata & data[3] > 0
        mcbk = mcbk + (item.Active and 1 or 0)
        
        item = findObjectForCode(dungeonPrefix .. "_compass")
        item.Active = compassdata & data[3] > 0
        mcbk = mcbk + (item.Active and 2 or 0)

        item = findObjectForCode(dungeonPrefix .. "_mcbk").ItemState
        if item:getState() ~= mcbk then
            modified = true
            item:setState(mcbk)
        end

        --Small Keys
        if OBJ_DOORSHUFFLE:getState() == 0 then
            modified = updateDungeonKeysFromPrefix(segment, dungeonPrefix, 0x7ef37c + data[4]) or modified
            if modified then
                --Refresh Dungeon Calc
                updateChestCountFromDungeon(nil, dungeonPrefix, nil)
            end
        end
    end
end

function updateDungeonKeysFromMemorySegment(segment)
    --Small Keys
    if segment and not CONFIG.AUTOTRACKER_DISABLE_DUNGEON_ITEM_TRACKING then
        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("Segment: Dungeon Keys")
        end
        for dungeonPrefix, data in pairs(DATA.DungeonData) do
            updateDungeonKeysFromPrefix(segment, dungeonPrefix, 0x7ef4e0 + data[4])
            
            --Collected Chests/Items In Dungeons
            if not CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING
                    and (CACHE.DUNGEON == 0xff or dungeonPrefix == DATA.DungeonIdMap[CACHE.DUNGEON]) then
                if shouldChestCountUp() then
                    if INSTANCE.VERSION_MINOR >= 5 then
                        updateChestCountFromDungeon(segment, dungeonPrefix, 0x7ef4b0 + (data[4] * 2))
                    elseif INSTANCE.NEW_SRAM_SYSTEM then
                        updateChestCountFromDungeon(segment, dungeonPrefix, 0x7ef4c0 + data[4])
                    else
                        updateChestCountFromDungeon(segment, dungeonPrefix, (dungeonPrefix == 'hc' and 0x7ef4c0 or 0x7ef4bf) + data[4])
                    end
                else
                    updateChestCountFromDungeon(nil, dungeonPrefix, nil)
                end
            end
        end
    end
end

function updateDungeonTotalsFromMemorySegment(segment)
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Dungeon Totals")
    end

    --Dungeon Total Checks Seen
    CACHE.DungeonsSeen = segment:ReadUInt16(0x7ef403)
    for i, dungeonPrefix in ipairs(DATA.DungeonList) do
        updateDungeonTotal(dungeonPrefix, CACHE.DungeonsSeen)
    end
end

function updateKeyTotalsFromMemorySegment(segment)
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Key Totals")
    end

    --Key Totals and Prizes Seen
    CACHE.KeysSeen = segment:ReadUInt16(0x7ef474)
    for i, dungeonPrefix in ipairs(DATA.DungeonList) do
        updateKeyTotal(dungeonPrefix, CACHE.KeysSeen)
        local dungData = DATA.DungeonData[dungeonPrefix]
        if dungData[10] > 0 and OBJ_KEYPRIZE:getState() > 0 and INSTANCE.VERSION_MINOR >= 5 and CACHE.KeysSeen & DATA.DungeonData[dungeonPrefix][3] > 0 then
            local prizeIdx = AutoTracker:ReadU8(0x30efe0+dungData[4], 0)
            if prizeIdx > 0 then
                local dungeon = Tracker:FindObjectForCode(dungeonPrefix)
                if prizeIdx == 5 or prizeIdx == 6 then
                    dungeon.CurrentStage = 2
                elseif prizeIdx == 8 then
                    dungeon.CurrentStage = 4
                elseif prizeIdx > 8 then
                    dungeon.CurrentStage = 3
                else
                    dungeon.CurrentStage = 1
                end
            else
                print('error', dungeonPrefix, prizeIdx, dungData[4])
            end
        end
    end
end

function updateDungeonsCompletedFromMemorySegment(segment)
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Dungeons Completed")
    end

    CACHE.DungeonsCompleted = segment:ReadUInt16(0x7ef472)
    for i, boss in ipairs(INSTANCE.MEMORY.Bosses) do
        local item = findObjectForCode(boss[1])
        if item then
            item.Active = CACHE.DungeonsCompleted & DATA.DungeonData[boss[1]][3] > 0
        end
        item = findObjectForCode(INSTANCE.MEMORY.BossLocations[i][2])
        if item and item.AvailableChestCount > 0 then
            item.AvailableChestCount = (CACHE.DungeonsCompleted & DATA.DungeonData[boss[1]][3]) == 0 and 1 or 0
            item = findObjectForCode(INSTANCE.MEMORY.BossLocations[i][3])
            item.AvailableChestCount = (CACHE.DungeonsCompleted & DATA.DungeonData[boss[1]][3]) == 0 and 1 or 0
            
            if item.AvailableChestCount == 0 then
                if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                    print("Boss Defeated:", INSTANCE.MEMORY.BossLocations[i][2])
                end
            end
        end
    end
end

function updatePrizeFromMemorySegment(segment)
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Segment: Prize")
    end

    local function setPrize(value)
        local dungeon = Tracker:FindObjectForCode(DATA.DungeonIdMap[CACHE.DUNGEON])
        if dungeon and dungeon.CurrentStage == 0 then
            dungeon.CurrentStage = value
        end
    end

    if CACHE.DUNGEON == 0xff then
        updateDungeonIdFromMemorySegment(nil)
    end
    
    CACHE.PendantData = segment:ReadUInt8(0x7ef374)
    CACHE.CrystalData = segment:ReadUInt8(0x7ef37a)

    if OBJ_KEYPRIZE:getState() < 2 then
        local diffPendants = ((INSTANCE.DUNGEON_PRIZE_DATA & 0xff00) >> 8) ~ CACHE.PendantData
        local diffCrystals = (INSTANCE.DUNGEON_PRIZE_DATA & 0xff) ~ CACHE.CrystalData
        if numberOfSetBits(diffPendants) == 1 and diffPendants & CACHE.PendantData > 0 then
            setPrize(diffPendants & CACHE.PendantData == 4 and 4 or 3)
        elseif numberOfSetBits(diffCrystals) == 1 and diffCrystals & CACHE.CrystalData > 0 then
            setPrize(1)
        end
    end

    INSTANCE.DUNGEON_PRIZE_DATA = (CACHE.PendantData << 8) + CACHE.CrystalData
    
    if OBJ_KEYPRIZE:getState() > 0 then
        local prizes = {
            ["greenpendantalt"] = 0x0400,
            ["bluependantalt"] = 0x0200,
            ["redpendantalt"] = 0x0100,
            ["crystal1"] = 0x0002,
            ["crystal2"] = 0x0010,
            ["crystal3"] = 0x0040,
            ["crystal4"] = 0x0020,
            ["crystal5"] = 0x0004,
            ["crystal6"] = 0x0001,
            ["crystal7"] = 0x0008
        }
        for prize, mask in pairs(prizes) do
            local item = Tracker:FindObjectForCode(prize)
            item.Active = INSTANCE.DUNGEON_PRIZE_DATA & mask > 0
        end
    end
end

function updateCollectionFromMemorySegment(segment)
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