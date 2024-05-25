function itemFlippedOn(item)
    if os.clock() - STATUS.LastMajorItem > 2 and STATUS.AutotrackerInGame then
        if item == "sword" then
            local object = Tracker:FindObjectForCode(item)
            if object.CurrentStage == 2 then
                sendExternalMessage("item", "sword")
            elseif object.CurrentStage == 3 then
                sendExternalMessage("item", "master")
            elseif object.CurrentStage == 4 then
                sendExternalMessage("item", "bacon")
            elseif object.CurrentStage == 5 then
                sendExternalMessage("item", "butter")
            end
        elseif item == "gloves" then
            local object = Tracker:FindObjectForCode(item)
            if object.CurrentStage == 1 then
                sendExternalMessage("item", "gloves")
            elseif object.CurrentStage == 2 then
                sendExternalMessage("item", "mitts")
            end
        elseif item == "bow" or item == "hammer" or item == "flute" or item == "boots"
                or item == "lamp" or item == "halfmagic" or item == "firerod" or item == "icerod"
                or item == "bombos" or item == "ether" or item == "quake" or item == "mushroom"
                or item == "powder" or item == "shovel" or item == "mirror" or item == "hookshot"
                or item == "book" or item == "cape" or item == "byrna" or item == "somaria"
                or item == "net" or item == "flippers" or item == "pearl" then
            sendExternalMessage("item", item)
        end
        
        STATUS.LastMajorItem = os.clock()
    end
end

function updateDungeonImage(dungeonId, owId, worldFlag)
    if CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_DUNGEON_IMAGE then
        local dungeonImage = ""
        if dungeonId ~= nil and dungeonId < 0xff then
            dungeonImage = (CONFIG.BROADCAST_ALTERNATE_LAYOUT == 2 and "er-" or "") .. DATA.DungeonIdMap[dungeonId]
        elseif owId < 0xff then
            --Update Dungeon Image
            dungeonImage = (CONFIG.BROADCAST_ALTERNATE_LAYOUT == 2 and "er-" or "") .. (worldFlag > 0 and "dw" or "lw")
        end
        if dungeonImage ~= "" and dungeonImage ~= CACHE.DungeonImage then
            CACHE.DungeonImage = dungeonImage
            sendExternalMessage("dungeon", CACHE.DungeonImage)
        end
    end
end

function sendExternalMessage(filename, value)
    if value then
        if (filename == "item" and not CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_ITEM_FILE)
                or (filename == "dungeon" and not CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_DUNGEON_IMAGE)
                or (filename == "health" and not CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_HEALTH_FILE) then
            return
        end
        local file = io.open(os.getenv("USERPROFILE") .. "\\Documents\\EmoTracker\\" .. filename .. ".txt", "w+")
        if file then
            io.output(file)
            io.write(value)
            io.close(file)
        end
    end
end

function overrideAppSettings()
    local fullDir, packRoot = getFullDir()

    if fullDir ~= nil and dirExists(fullDir) then
        local text = readFile(fullDir, "", "application_settings.json")
        if text then
            local ndiRate = "3.0"
            local shouldWrite = true
            if text == "" then
                text = '{\n  "ndi_frame_rate": ' .. ndiRate .. '\n}'
            else
                local idx = text:find("ndi_frame_rate")
                if idx then
                    local rest = text:find(",", idx)
                    if text:sub(rest - ndiRate:len(), rest - 1) == ndiRate then
                        shouldWrite = false
                    end
                    text = text:sub(1, idx + 14) .. ": " .. ndiRate .. text:sub(rest)
                else
                    text = '{\n  "ndi_frame_rate": ' .. ndiRate .. ',' .. text:sub(2)
                end
            end
            if shouldWrite then
                writeFile(fullDir, "", "application_settings.json", text)
            end
        end
    end
end

function saveBackup()
    local clock = os.clock()
    if CONFIG.ENABLE_BACKUP_FILE and clock - STATUS.GameStarted > 300 and clock - STATUS.LAST_BACKUP > 60 then
        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("Saving Backup File")
        end

        STATUS.LAST_BACKUP = clock

        local textOutput = ""
        
        textOutput = textOutput .. "BACKUP.MODE_SETTINGS = {\n"
        local objects = {
            "world_state_mode","entrance_shuffle","door_shuffle","ow_mixed","ow_layout",
            "keysanity_map","keysanity_compass","keysanity_smallkey","keysanity_bigkey","keysanity_prize",
            "pool_shopsanity","pool_bonkdrop","pool_enemydrop","pool_dungeonpot","pool_cavepot",
            "pool_district","retro_mode","glitch_mode","race_mode","gt_crystals"
        }
        for i, mode in pairs(objects) do
            textOutput = textOutput .. "    [\"" .. mode .. "\"] = " .. math.floor(MODES[mode]:getState()) .. ",\n"
        end
        textOutput = textOutput .. "    [\"world_state_mode_inverted\"] = " .. math.floor(OBJ_WORLDSTATE:getProperty("version")) .. "\n}\n\n"

        textOutput = textOutput .. "BACKUP.OWSWAPS = { \n"
        for i, swap in pairs(INSTANCE.OWSWAPS) do
            textOutput = textOutput .. "    [" .. i .. "] = " .. math.floor(swap:getState()) .. ",\n"
        end
        textOutput = string.sub(textOutput, 1, string.len(textOutput) - 2) .. "\n}\n\n"
        
        local toggles = {
            "dropdown_uncle", "dropdown_sanc", "dropdown_lumberjack", "dropdown_thief",
            "dropdown_well", "dropdown_bat", "dropdown_fairy", "dropdown_ganon",
            "dropdown_swpinball", "dropdown_swcompass", "dropdown_swbigchest", "dropdown_swhazard",
            "easternpalace", "desertpalace", "towerofhera", "palaceofdarkness", "swamppalace",
            "skullwoods", "thievestown", "icepalace", "miserymire", "turtlerock",
            "takeanycave"
        }
        local regions = {
            "ow_lost_woods_west", "ow_lost_woods_east", "ow_lumberjack", "ow_dm_west_top", "ow_dm_west_bottom",
            "ow_dm_east_top_hammer", "ow_dm_east_top", "ow_dm_east_spiral", "ow_dm_east_mimic", "ow_dm_east_connect", "ow_dm_east_bottom_hookshot", "ow_dm_east_bottom",
            "ow_trpegs", "ow_mountainentry", "ow_mountainentry_entry", "ow_mountainentry_ledge", "ow_zora_waterfall", "ow_zora_waterfall_fairy", "ow_zora",
            "ow_lost_woods_pass_west", "ow_lost_woods_pass_east_top", "ow_lost_woods_pass_east_bottom", "ow_kak_fortune", "ow_kak_pond", "ow_sanc_ledge", "ow_sanc",
            "ow_graveyard", "ow_graveyard_ledge", "ow_graveyard_tomb", "ow_river_west", "ow_river_east", "ow_river_water", "ow_witch", "ow_witch_east", "ow_witch_water",
            "ow_zora_approach", "ow_kakariko", "ow_kak_grasshouse", "ow_kak_bombhut", "ow_forest",
            "ow_castle", "ow_castle_southwest", "ow_castle_east", "ow_castle_ledge", "ow_castle_courtyard",
            "ow_wooden_bridge", "ow_wooden_bridge_northeast", "ow_eastern_palace", "ow_blacksmith", "ow_sand_dunes", "ow_race_game", "ow_race_ledge",
            "ow_kak_suburb", "ow_flute_pass", "ow_flute", "ow_central_bonk", "ow_links", "ow_stone_bridge", "ow_stone_bridge_water",
            "ow_treeline", "ow_treeline_water", "ow_eastern_nook", "ow_desert", "ow_desert_tablet", "ow_desert_ledge", "ow_desert_back", "ow_desert_front",
            "ow_cave45", "ow_cave45_bush", "ow_cwhirlpool_west", "ow_cwhirlpool_east", "ow_statues",
            "ow_hylia_northwest", "ow_hylia_northeast", "ow_hylia_shore", "ow_hylia_water", "ow_hylia_upgrade",
            "ow_ice_cave", "ow_desert_pass_ledge", "ow_desert_pass", "ow_desert_pass_southeast", "ow_dam", "ow_south_pass", "ow_octoballoon", "ow_octoballoon_waterfall",
            "ow_sw_path_west", "ow_sw_path_east", "ow_sw_front", "ow_sw_portal", "ow_sw_back", "ow_dark_lumberjack", "ow_ddm_west_top", "ow_ddm_west_bottom",
            "ow_ddm_east_top", "ow_ddm_east_deadend", "ow_ddm_east_bottom", "ow_ddm_floating", "ow_ddm_tr_bridge", "ow_ddm_tr_safety", "ow_turtlerock",
            "ow_bumper", "ow_bumper_ledge", "ow_bumper_entry", "ow_catfish", "ow_sw_pass_west", "ow_sw_pass_east_top", "ow_sw_pass_east_bottom", "ow_outcast_fortune",
            "ow_outcast_pond", "ow_chapel", "ow_dark_graveyard", "ow_qirn_west", "ow_qirn_east", "ow_qirn_water",
            "ow_dark_witch", "ow_dark_witch_east", "ow_dark_witch_water", "ow_catfish_approach", "ow_outcasts", "ow_outcasts_hammer", "ow_shield_shop",
            "ow_pyramid", "ow_pyramid_pass", "ow_broken_bridge_west", "ow_broken_bridge_east_top", "ow_broken_bridge_east_bottom", "ow_dark_palace",
            "ow_hammerpegs_entry", "ow_hammerpegs", "ow_dark_dunes", "ow_dig_game", "ow_dig_ledge", "ow_frog", "ow_archery", "ow_stumpy_pass", "ow_stumpy",
            "ow_dark_bonk", "ow_bomb_shop", "ow_hammer_bridge_top", "ow_hammer_bridge_bottom", "ow_dark_treeline", "ow_dark_treeline_water", "ow_dark_nook",
            "ow_mire", "ow_bush_circle", "ow_bush_circle_blocked", "ow_dark_cwhirlpool_west", "ow_dark_cwhirlpool_east", "ow_hype",
            "ow_ice_northwest", "ow_ice_northeast", "ow_ice_southwest", "ow_ice_southeast", "ow_ice_water", "ow_ice_palace",
            "ow_shopping_mall", "ow_swamp_nook", "ow_swamp", "ow_dark_south_pass", "ow_bomber_corner", "ow_bomber_corner_waterfall"
        }
        local progressives = {
            "bombs","bombos","ether","quake","sword",

            "takeanycave", "flute_shuffle", "whirlpool_shuffle", "goal_setting",
            "easternpalace", "desertpalace", "towerofhera", "palaceofdarkness", "swamppalace",
            "skullwoods", "thievestown", "icepalace", "miserymire", "turtlerock"
        }
        local items = {
            "bow", "boomerang_blue", "boomerang_red", "hookshot", "bombs", "powder", "mushroom", "boots", "sword",
            "firerod", "icerod", "bombos", "ether", "quake", "halfmagic", "lift1", "shield",
            "lamp", "hammer", "ocarina", "net", "book", "shovel", "flippers", "armor",
            "bottle", "somaria", "byrna", "cape", "mirror", "aga", "aga2", "moonpearl", "gomode"
        }
        for i, itemCode in pairs(items) do
            local item = Tracker:FindObjectForCode(itemCode)
            if type(item.Active) == "boolean" then
                table.insert(toggles, itemCode)
            end
            if type(item.CurrentStage) == "number" then
                table.insert(progressives, itemCode)
            end
        end

        textOutput = textOutput .. "BACKUP.TOGGLE_ITEMS = {\n"
        for i, icon in pairs(toggles) do
            textOutput = textOutput .. "    [\"" .. icon .. "\"] = " .. (Tracker:FindObjectForCode(icon).Active and "true" or "false") .. ",\n"
        end
        for i, icon in pairs(regions) do
            local reg = Tracker:FindObjectForCode(icon)
            if reg.Active then
                textOutput = textOutput .. "    [\"" .. icon .. "\"] = " .. (reg.Active and "true" or "false") .. ",\n"
            end
        end
        textOutput = string.sub(textOutput, 1, string.len(textOutput) - 2) .. "\n}\n\n"

        textOutput = textOutput .. "BACKUP.PROGRESSIVE_ITEMS = {\n"
        for i, icon in pairs(progressives) do
            textOutput = textOutput .. "    [\"" .. icon .. "\"] = " .. math.floor(Tracker:FindObjectForCode(icon).CurrentStage) .. ",\n"
        end
        textOutput = string.sub(textOutput, 1, string.len(textOutput) - 2) .. "\n}\n\n"

        textOutput = textOutput .. "BACKUP.LOCATION_CAPTURES = { \n"
        for i, section in pairs(DATA.CaptureBadgeOverworld) do
            if CACHE.CaptureBadges[section] ~= nil and CACHE.CaptureBadges[section][4] ~= nil then
                textOutput = textOutput .. "    [\"" .. section .. "\"] = \"" .. CACHE.CaptureBadges[section][4].Name .. "\",\n"
            end
        end
        for i, section in pairs(DATA.CaptureBadgeUnderworld) do
            if CACHE.CaptureBadges[section] ~= nil and CACHE.CaptureBadges[section][4] ~= nil then
                textOutput = textOutput .. "    [\"" .. section .. "\"] = \"" .. CACHE.CaptureBadges[section][4].Name .. "\",\n"
            end
        end
        for i, section in pairs(DATA.CaptureBadgeDungeons) do
            if CACHE.CaptureBadges[section] ~= nil and CACHE.CaptureBadges[section][4] ~= nil then
                textOutput = textOutput .. "    [\"" .. section .. "\"] = \"" .. CACHE.CaptureBadges[section][4].Name .. "\",\n"
            end
        end
        for i, section in pairs(DATA.CaptureBadgeEntrances) do
            if CACHE.CaptureBadges[section] ~= nil and CACHE.CaptureBadges[section][4] ~= nil then
                textOutput = textOutput .. "    [\"" .. section .. "\"] = \"" .. CACHE.CaptureBadges[section][4].Name .. "\",\n"
            end
        end
        for i, section in pairs(DATA.CaptureBadgeConnectors) do
            if CACHE.CaptureBadges[section] ~= nil and CACHE.CaptureBadges[section][4] ~= nil then
                textOutput = textOutput .. "    [\"" .. section .. "\"] = \"" .. CACHE.CaptureBadges[section][4].Name .. "\",\n"
            end
        end
        for i, section in pairs(DATA.CaptureBadgeDropdowns) do
            if CACHE.CaptureBadges[section] ~= nil and CACHE.CaptureBadges[section][4] ~= nil then
                textOutput = textOutput .. "    [\"" .. section .. "\"] = \"" .. CACHE.CaptureBadges[section][4].Name .. "\",\n"
            end
        end
        for i, section in pairs(DATA.CaptureBadgeSWDungeons) do
            if CACHE.CaptureBadges[section] ~= nil and CACHE.CaptureBadges[section][4] ~= nil then
                textOutput = textOutput .. "    [\"" .. section .. "\"] = \"" .. CACHE.CaptureBadges[section][4].Name .. "\",\n"
            end
        end
        for i, section in pairs(DATA.CaptureBadgeSWDropdowns) do
            if CACHE.CaptureBadges[section] ~= nil and CACHE.CaptureBadges[section][4] ~= nil then
                textOutput = textOutput .. "    [\"" .. section .. "\"] = \"" .. CACHE.CaptureBadges[section][4].Name .. "\",\n"
            end
        end
        for i, section in pairs(DATA.CaptureBadgeInsanity) do
            if CACHE.CaptureBadges[section] ~= nil and CACHE.CaptureBadges[section][4] ~= nil then
                textOutput = textOutput .. "    [\"" .. section .. "\"] = \"" .. CACHE.CaptureBadges[section][4].Name .. "\",\n"
            end
        end
        textOutput = string.sub(textOutput, 1, string.len(textOutput) - 2) .. "\n}\n\n"

        textOutput = textOutput .. "BACKUP.CLEARED_LOCATIONS = { \n"
        for locName, loc in pairs(INSTANCE.LOCATION_CACHE) do
            if loc.ModifiedByUser and loc.AccessibilityLevel.Cleared then
                local sections = loc.Sections:GetEnumerator()
                sections:MoveNext()
                while (sections.Current ~= nil) do
                    if sections.Current.Visible then
                        textOutput = textOutput .. "    \"@" .. locName .. "/" .. sections.Current.Name .. "\",\n"
                    end
                    sections:MoveNext()
                end
            end
        end
        textOutput = string.sub(textOutput, 1, string.len(textOutput) - 2) .. "\n}\n\n"
        
        textOutput = textOutput .. "BACKUP.DUNGEON_COUNTS = {\n"
        for i = 1, #DATA.DungeonList do
            local item = Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_item").ItemState
            local key = Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_smallkey")
            local mcbk = Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_mcbk").ItemState
            textOutput = textOutput .. "    [\"" .. DATA.DungeonList[i] .. "\"] = {" .. math.floor(item.CollectedCount) .. "," .. math.floor(item.MaxCount) .. "," .. math.floor(key.AcquiredCount) .. "," .. math.floor(key.MaxCount) .. "," .. math.floor(mcbk:getState()) .. "},\n"
        end
        textOutput = string.sub(textOutput, 1, string.len(textOutput) - 2) .. "\n}\n\n"
        
        textOutput = textOutput .. "BACKUP.MULTIDUNGEONCAPTURES = { \n"
        for roomId, data in pairs(INSTANCE.MULTIDUNGEONCAPTURES) do
            local key = roomId
            if type(key) == "number" then
                key = math.floor(roomId) .. ""
            else
                key = "\"" .. key .. "\""
            end
            textOutput = textOutput .. "    [" .. key .. "] = \"" .. data .. "\",\n"
        end
        textOutput = string.sub(textOutput, 1, string.len(textOutput) - 2) .. "\n}\n\n"

        textOutput = textOutput .. "BACKUP.DUNGEON_PRIZE_DATA = " .. math.floor(INSTANCE.DUNGEON_PRIZE_DATA) .. "\n"
        textOutput = textOutput .. "BACKUP.ROOMCURSORPOSITION = " .. math.floor(INSTANCE.ROOMCURSORPOSITION) .. "\n"

        textOutput = textOutput .. "BACKUP.ROOMSLOTS = { "
        for s = 1, #INSTANCE.ROOMSLOTS do
            textOutput = textOutput .. "{" .. math.floor(INSTANCE.ROOMSLOTS[s][1]) .. ", " .. math.floor(INSTANCE.ROOMSLOTS[s][2]) .. "}, "
        end
        textOutput = string.sub(textOutput, 1, string.len(textOutput) - 2) .. " }\n\n"

        textOutput = textOutput .. "BACKUP.DOORSLOTS = {\n"
        for roomId, data in pairs(INSTANCE.DOORSLOTS) do
            textOutput = textOutput .. "    [" .. math.floor(roomId) .. "] = {"
            for s = 1, #data do
                textOutput = textOutput .. math.floor(data[s]) .. ", "
            end
            textOutput = string.sub(textOutput, 1, string.len(textOutput) - 2)
            textOutput = textOutput .. "},\n"
        end
        textOutput = string.sub(textOutput, 1, string.len(textOutput) - 2) .. "\n}\n\n"

        writeOverride("settings\\", "backup.lua", textOutput)
    end
end

function restoreBackup()
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Restoring Backup File")
    end
    INSTANCE.BACKUP_RUNNING = true

    if BACKUP.MODE_SETTINGS ~= nil then
        for mode, value in pairs(BACKUP.MODE_SETTINGS) do
            if mode == "world_state_mode_inverted" then
                OBJ_WORLDSTATE:setProperty("version", value)
                if OBJ_WORLDSTATE.linkedSettingAlt then
                    OBJ_WORLDSTATE.linkedSettingAlt.CurrentStage = value
                end
            else
                MODES[mode]:setStateExternal(value)
            end
        end
    end

    if BACKUP.OWSWAPS ~= nil then
        for i, value in pairs(BACKUP.OWSWAPS) do
            INSTANCE.OWSWAPS[i]:setStateExternal(value)
            if value < 2 then
                INSTANCE.OWSWAPS[i].modified = true
                Tracker:FindObjectForCode("ow_slot_" .. string.format("%02x", INSTANCE.OWSWAPS[i].owid + 0x40)).ItemState.modified = true
            end
        end
    end

    if BACKUP.TOGGLE_ITEMS ~= nil then
        for item, value in pairs(BACKUP.TOGGLE_ITEMS) do
            Tracker:FindObjectForCode(item).Active = value
        end
    end

    if BACKUP.PROGRESSIVE_ITEMS ~= nil then
        for item, value in pairs(BACKUP.PROGRESSIVE_ITEMS) do
            Tracker:FindObjectForCode(item).CurrentStage = value
        end
    end

    if BACKUP.CLEARED_LOCATIONS ~= nil then
        for i, sectionName in pairs(BACKUP.CLEARED_LOCATIONS) do
            local section = findObjectForCode(sectionName)
            section.AvailableChestCount = 0
            section.Owner.ModifiedByUser = true
        end
    end

    local captureLayouts = { "tracker_capture_item", "tracker_capture_entrance_insanity", "tracker_capture_dropdown_insanity" }
    local captureItems = {}
    for l = 1, #captureLayouts do
        local e = Layout:FindLayout(captureLayouts[l]).Root.Items:GetEnumerator()
        e:MoveNext()
        e = e.Current.Data.Rows:GetEnumerator()
        e:MoveNext()
        while e.Current ~= nil do
            local f = e.Current:GetEnumerator()
            f:MoveNext()
            while f.Current ~= nil do
                captureItems[f.Current.Name] = f.Current
                f:MoveNext()
            end
            e:MoveNext()
        end
    end

    if BACKUP.LOCATION_CAPTURES ~= nil then
        for sectionName, captureName in pairs(BACKUP.LOCATION_CAPTURES) do
            if captureItems[captureName] ~= nil then
                local section = Tracker:FindObjectForCode(sectionName)
                section.CapturedItem = captureItems[captureName]
            else
                print("Could not find capture item '" .. captureName .. "' at '" .. sectionName .. "'")
            end
        end
    end

    if BACKUP.MULTIDUNGEONCAPTURES ~= nil then
        for roomId, data in pairs(BACKUP.MULTIDUNGEONCAPTURES) do
            INSTANCE.MULTIDUNGEONCAPTURES[roomId] = data
        end
    end

    if BACKUP.DUNGEON_PRIZE_DATA ~= nil then
        INSTANCE.DUNGEON_PRIZE_DATA = BACKUP.DUNGEON_PRIZE_DATA
    end

    if BACKUP.ROOMCURSORPOSITION ~= nil then
        INSTANCE.ROOMCURSORPOSITION = BACKUP.ROOMCURSORPOSITION
    end

    if BACKUP.ROOMSLOTS ~= nil then
        for s = 1, #BACKUP.ROOMSLOTS do
            INSTANCE.ROOMSLOTS[s][1] = BACKUP.ROOMSLOTS[s][1]
            INSTANCE.ROOMSLOTS[s][2] = BACKUP.ROOMSLOTS[s][2]
        end
    end

    if BACKUP.DOORSLOTS ~= nil then
        for roomId, data in pairs(BACKUP.DOORSLOTS) do
            for s = 1, #data do
                INSTANCE.DOORSLOTS[roomId][s] = data[s]
            end
        end
    end

    refreshDoorSlots()
end

function postRestoreBackup()
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Restoring Backup File")
    end
    INSTANCE.BACKUP_RUNNING = false

    if BACKUP.DUNGEON_COUNTS ~= nil then
        for dungeonPrefix, data in pairs(BACKUP.DUNGEON_COUNTS) do
            local item = Tracker:FindObjectForCode(dungeonPrefix .. "_item").ItemState
            local key = Tracker:FindObjectForCode(dungeonPrefix .. "_smallkey")
            local mcbk = Tracker:FindObjectForCode(dungeonPrefix .. "_mcbk").ItemState
            local bk = Tracker:FindObjectForCode(dungeonPrefix .. "_bigkey")
            local map = Tracker:FindObjectForCode(dungeonPrefix .. "_map")
            local compass = Tracker:FindObjectForCode(dungeonPrefix .. "_compass")
            item.MaxCount = data[2]
            item.CollectedCount = data[1]
            key.MaxCount = data[4]
            key.AcquiredCount = data[3]
            mcbk:setState(data[5])
            bk.Active = data[5] & 4 > 0
            compass.Active = data[5] & 2 > 0
            map.Active = data[5] & 1 > 0
        end
    end

    for i = 1, #DATA.OverworldIds do
        local item = Tracker:FindObjectForCode("ow_slot_" .. string.format("%02x", DATA.OverworldIds[i])).ItemState
        if item.modified then
            item:updateIcon()
        end
        item = Tracker:FindObjectForCode("ow_slot_" .. string.format("%02x", DATA.OverworldIds[i] + 0x40)).ItemState
        if item.modified then
            item:updateIcon()
        end
    end
end

function saveSettings(setting)
    local textOutput = ""
    local isDefault = true
    for textcode, data in pairs(DATA.SettingsData[setting.file]) do
        local name = data[1]
        local code = data[2]
        local default = data[4]
        local otherSetting = Tracker:FindObjectForCode(code).ItemState
        if otherSetting.default ~= otherSetting:getState() then
            isDefault = false
        end
        textOutput = textOutput .. textcode .. " = " .. tostring(otherSetting:getState()) .. "\n"
    end
    if isDefault then
        deleteOverride("settings\\", setting.file)
    else
        writeOverride("settings\\", setting.file, textOutput)
    end

    postSettings()
end

function postSettings()
end

function writeOverride(path, filename, text)
    local fullDir, packRoot = getFullDir()

    local written = false
    if fullDir ~= nil then
        written = writeFile(fullDir .. "user_overrides\\" .. packRoot, path, filename, text)
    
        if dirExists(fullDir .. "dev\\") then
            written = writeFile(fullDir .. "dev\\user_overrides\\" .. packRoot, path, filename, text) or written
        end

        if not written then
            print("ERROR: User hasn't overridden any settings files yet. Press F1 to read the documentation for steps to resolve.")
        end
    end

    Layout:FindLayout("ref_settings_message").Root.Layout = not written and Layout:FindLayout("settings_message") or nil
    Layout:FindLayout("ref_settings_v_message").Root.Layout = not written and Layout:FindLayout("settings_v_message") or nil
end

function deleteOverride(path, filename)
    local fullDir, packRoot = getFullDir()

    if dirExists(fullDir .. "user_overrides\\" .. packRoot .. path .. filename) then
        os.remove(fullDir .. "user_overrides\\" .. packRoot .. path .. filename)
    end
    
    if dirExists(fullDir .. "dev\\user_overrides\\" .. packRoot .. path .. filename) then
        os.remove(fullDir .. "dev\\user_overrides\\" .. packRoot .. path .. filename)
    end
end

function printLog(text, action)
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print(text)
    end
    
    if action == 1 then
        if CACHE.PRINTLOG == nil then
            CACHE.PRINTLOG = {}
            --CACHE.PRINTLOGSIZE = 0
        end
        table.insert(CACHE.PRINTLOG, text)
    else
        local fullDir, packRoot = getFullDir()
        local written = false
        if fullDir ~= nil then
            if dirExists(fullDir .. "user_overrides\\" .. packRoot) then
                local file = io.open(fullDir .. "user_overrides\\" .. packRoot .. "autoerlog.txt", "a")
                if file then
                    io.output(file)
                    if action == 2 then
                        for i, t in ipairs(CACHE.PRINTLOG) do
                            io.write(t .. "\n")
                        end
                    else
                        io.write(text .. "\n")
                    end
                    io.close(file)
                    return true
                end
            end
        end
    end
end

function getFullDir()
    local emoDir = "Documents\\EmoTracker\\"
    local packRoot = "alttpr_codetracker_codemann8\\"
    local baseDir = ""
    
    if dirExists(CONFIG.DOCUMENTS_FOLDER .. emoDir) then
        baseDir = CONFIG.DOCUMENTS_FOLDER
    elseif os.getenv("OneDrive") and dirExists(os.getenv("OneDrive") .. "\\" .. emoDir) then
        baseDir = os.getenv("OneDrive") .. "\\"
    else
        print("ERROR: User has changed the location of their 'Documents' folder. Press F1 to read the documentation for steps to resolve.")
        print("OneDrive:", os.getenv("OneDrive"))
        print("UserProfile:", os.getenv("UserProfile"))
        return nil, nil
    end

    if baseDir == "" then
        return nil, nil
    end

    return baseDir .. emoDir, packRoot
end

function readFile(rootpath, localpath, filename)
    if not dirExists(rootpath .. localpath) then
        return false
    end

    local file = io.open(rootpath .. localpath .. filename, "r")
    if file then
        local text = file:read("*a")
        io.close(file)
        return text
    end

    return ""
end

function writeFile(rootpath, localpath, filename, text)
    if not dirExists(rootpath .. localpath) then
        --Tracker.ActiveGamePackage:ExportUserOverride(localpath .. filename)
        --TODO: Revisit when Emo adds ability to export overrides from code
        return false
    end

    local file = io.open(rootpath .. localpath .. filename, "w+")
    if file then
        io.output(file)
        io.write(text)
        io.close(file)
        return true
    end

    return false
end

function dirExists(path)
    local ok, err, code = os.rename(path, path)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    return ok, err
end