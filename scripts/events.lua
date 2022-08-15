function tracker_on_begin_loading_save_file()
    STATUS.TRACKER_READY = false
end

function tracker_on_finish_loading_save_file()
    updateAllGhosts()
    updateLayout()
    STATUS.TRACKER_READY = true
end

function tracker_on_accessibility_updating() end

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

        if Tracker.ActiveVariantUID ~= "vanilla" then
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

            updateAllGhosts()
        end
    end
end

function tracker_on_pack_ready()
    STATUS.TRACKER_READY = true
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Package ready at: " .. os.clock() - STATUS.START_CLOCK)
    end
end
