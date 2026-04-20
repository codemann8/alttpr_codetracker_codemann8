function tracker_on_begin_loading_save_file()
    STATUS.TRACKER_READY = false
    prepareForSaveLoad()
end

function tracker_on_finish_loading_save_file()
    updateChests()
    updateLayout()
    STATUS.TRACKER_READY = true
end

--function tracker_on_accessibility_updating() end

function tracker_on_accessibility_updated()
    if STATUS.TRACKER_READY then
        STATUS.ACCESS_COUNTER = STATUS.ACCESS_COUNTER + 1
        if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
            print("Access Update #" .. math.floor(STATUS.ACCESS_COUNTER))
        end

        -- local loc = Tracker:FindObjectForCode("@NEDW Access")
        -- print("1 = " .. tostring(loc.AccessibilityLevel))
        -- loc = Tracker:FindObjectForCode("@EDW Access")
        -- print("2 = " .. tostring(loc.AccessibilityLevel))
        -- loc = Tracker:FindObjectForCode("@EDW Access To NEDW")
        -- print("3 = " .. tostring(loc.AccessibilityLevel))
        -- loc = Tracker:FindObjectForCode("@East Top Dark Death Mountain")
        -- print("4 = " .. tostring(loc.AccessibilityLevel))
        -- loc = Tracker:FindObjectForCode("@TR Bridge Test")
        -- print("TR Bridge Test = " .. tostring(loc.AccessibilityLevel))

        if INSTANCE.BACKUP_RUNNING then
            postRestoreBackup()
        end
    end
end

function tracker_on_pack_ready()
    STATUS.TRACKER_READY = true
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Package ready at: " .. os.clock() - STATUS.START_CLOCK)
    end
    deleteOverride("", "autoerlog.txt")
    printLog("**********************************", 1)
    printLog("**********************************", 1)
    printLog("**********************************", 1)

    local clearSectionLists = {
        DATA.CaptureBadgeDungeons,
        DATA.CaptureBadgeEntrances,
        DATA.CaptureBadgeConnectors,
        DATA.CaptureBadgeDropdowns,
        DATA.CaptureBadgeSWDungeons,
        DATA.CaptureBadgeSWDropdowns,
        DATA.CaptureBadgeInsanity
    }
    for _, list in ipairs(clearSectionLists) do
        for _, code in ipairs(list) do
            CACHE.CaptureBadges[code] = true
        end
    end
end

function tracker_on_location_updating(section)
    local key = "@" .. section.Owner.Name .. "/" .. section.Name
    CACHE.CurrentCapture[key] = section.CapturedItem
end

function tracker_on_location_updated(section)
    if Tracker.ActiveVariantUID ~= "vanilla" then
        local key = "@" .. section.Owner.Name .. "/" .. section.Name
        if CACHE.CaptureBadges[key] then
            cacheManualIcon(section, true)
        end
        if section.CapturedItem ~= CACHE.CurrentCapture[key] then
            if STATUS.GameStarted == 0 then
                STATUS.GameStarted = os.clock()
            end
            saveBackup()
            local capturedItem = section.CapturedItem
            if capturedItem then
                if OBJ_DOORSHUFFLE:getState() == 2 and not section.Owner.Pinned and (string.match(tostring(capturedItem.Icon.URI), "capture/dungeons") or capturedItem.Name == "Sanctuary Dropdown" or string.match(capturedItem.Name, "^SW .* Dropdown")) then
                    section.Owner.Pinned = true
                elseif CONFIG.PREFERENCE_PIN_LOCATIONS_ON_ITEM_CAPTURE and not section.Owner.Pinned and (string.match(tostring(capturedItem.Icon.URI), "capture/items") or string.match(tostring(capturedItem.Icon.URI), "capture/misc")) then
                    section.Owner.Pinned = true
                end

                if section.Owner.Pinned and capturedItem.Name == "Dead Entrance" then
                    section.Owner.Pinned = false
                end
            end
        end

        --Update Dungeon Chest Icons
        -- if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        --     print("Before chest update: " .. os.clock() - STATUS.START_CLOCK)
        -- end
        for i = 1, #DATA.DungeonList do
            local item = Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_item").ItemState
            if item then
                item:UpdateBadgeAndIcon()
            end
        end
        -- if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        --     print("After chest update: " .. os.clock() - STATUS.START_CLOCK)
        -- end
    end
end
