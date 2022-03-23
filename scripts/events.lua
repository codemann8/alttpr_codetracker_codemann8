function tracker_on_begin_loading_save_file()
    STATUS.TRACKER_READY = false
    print("start loading save")
end

function tracker_on_finish_loading_save_file()
    -- if OBJ_RETRO then
    -- TODO: Use OBJ references instead below
    --     Tracker:FindObjectForCode("retro_mode_surrogate").ItemState:updateIcon()
    --     Tracker:FindObjectForCode("entrance_shuffle_surrogate").ItemState:postUpdate()
    --     updateIcons()
    --     STATUS.TRACKER_READY = true
    --     tracker_on_accessibility_updated()
    -- end
    
    STATUS.TRACKER_READY = true
    print("loaded save")
end

function tracker_on_accessibility_updating()
    if STATUS.TRACKER_READY then
        --local last_location = Layout:FindLayout("shared_last_cleared").Root.Location
        --print(last_location.Name)
    end
end

function tracker_on_accessibility_updated()
    if STATUS.TRACKER_READY then
        STATUS.ACCESS_COUNTER = STATUS.ACCESS_COUNTER + 1
        if true or CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
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

        if Tracker.ActiveVariantUID == "full_tracker" then
            --Update Dungeon Chest Icons
            if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                print("Before chest update: " .. os.clock() - STATUS.START_CLOCK)
            end
            for i = 1, #DATA.DungeonList do
                local item = Tracker:FindObjectForCode(DATA.DungeonList[i] .. "_item").ItemState
                if item then
                    item:UpdateBadgeAndIcon()
                end
            end
            if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                print("After chest update: " .. os.clock() - STATUS.START_CLOCK)
            end

    --     --Auto-Mark Medallions On Capture
    --     if false and OBJ_ENTRANCE then
    --         local medallion = Tracker:FindObjectForCode("bombos")
    --         local medallionFlag = medallion.CurrentStage & 0x3
    --         if medallionFlag ~= 0x3 then
    --             medallion = Tracker:FindObjectForCode("ether")
    --             medallionFlag = medallionFlag | medallion.CurrentStage
    --             if medallionFlag ~= 0x3 then
    --                 medallion = Tracker:FindObjectForCode("quake")
    --                 medallionFlag = medallionFlag | medallion.CurrentStage
    --             end
    --         end

    --         local loc = nil
    --         if medallionFlag & 0x1 == 0 then
    --             loc = Tracker:FindObjectForCode(OBJ_ENTRANCE.CurrentStage == 0 and "@Misery Mire/Medallion" or "@Misery Mire Entrance/Entrance").CapturedItem
    --             if loc then
    --                 medallion = Tracker:FindObjectForCode(string.lower(loc.Name))
    --                 medallion.CurrentStage = medallion.CurrentStage | 0x1
    --             end
    --         end
    --         if medallionFlag & 0x2 == 0 then
    --             loc = Tracker:FindObjectForCode(OBJ_ENTRANCE.CurrentStage == 0 and "@Turtle Rock/Medallion" or "@Turtle Rock Entrance/Entrance").CapturedItem
    --             if loc then
    --                 medallion = Tracker:FindObjectForCode(string.lower(loc.Name))
    --                 medallion.CurrentStage = medallion.CurrentStage | 0x2
    --             end
    --         end
    --     end

            --Update Ghost Badges
            if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                print("Before ghost update: " .. os.clock() - STATUS.START_CLOCK)
            end

            updateGhosts(DATA.CaptureBadgeOverworld, false, false)
            if OBJ_ENTRANCE:getState() < 2 then
                updateGhosts(DATA.CaptureBadgeUnderworld, false, true)
            end
            if OBJ_ENTRANCE:getState() > 0 then
                updateGhosts(DATA.CaptureBadgeEntrances, true, true)
                updateGhosts(DATA.CaptureBadgeDungeons, true, true)
                
                if OBJ_ENTRANCE:getState() > 1 then
                    updateGhosts(DATA.CaptureBadgeConnectors, true, true)
                    updateGhosts(DATA.CaptureBadgeDropdowns, true, true)

                    if OBJ_ENTRANCE:getState() == 4 then
                        updateGhosts(DATA.CaptureBadgeInsanity, true, true)
                    end
                end
            end
            if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
                print("After ghost update: " .. os.clock() - STATUS.START_CLOCK)
            end
        end
    end
end

function tracker_on_pack_ready()
    -- if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
    --     print("Before Map Location Data Load: " .. os.clock() - STATUS.START_CLOCK)
    -- end

    -- --testing changing BadgeMargin --doesnt work
    -- local maps = Layout:FindLayout("dummymap").Root.Maps:GetEnumerator()
    -- maps:MoveNext()
    -- --LW
    -- local locations = maps.Current.Locations:GetEnumerator()
    -- locations:MoveNext()
    -- local dummy = locations.Current
    -- print(dummy.Size)
    -- print(dummy.BadgeSize)
    -- print(dummy.BadgeMargin.Left)
    -- print(dummy.Location.Name)

    -- maps = Layout:FindLayout("map").Root.Maps:GetEnumerator()
    -- maps:MoveNext()
    -- --LW
    -- locations = maps.Current.Locations:GetEnumerator()
    -- locations:MoveNext()
    -- while (locations.Current ~= nil) do
    --     if locations.Current.Location.Name == 'Master Sword Pedestal' then
    --         if locations.Current.BadgeSize > 99 and locations.Current.BadgeSize < 101 then
    --             print(locations.Current.BadgeMargin.Left)
    --             print(locations.Current.BadgeMargin.Top)
    --             print(locations.Current.BadgeMargin.Right)
    --             print(locations.Current.BadgeMargin.Bottom)
    --             --locations.Current.BadgeMargin.Left = locations.Current.BadgeMargin.Right
    --             --locations.Current.BadgeMargin.Top = locations.Current.BadgeMargin.Bottom
    --             locations.Current.BadgeMargin = dummy.BadgeMargin
    --             print(locations.Current.BadgeMargin.Left)
    --             print(locations.Current.BadgeMargin.Top)
    --             print(locations.Current.BadgeMargin.Right)
    --             print(locations.Current.BadgeMargin.Bottom)
    --         end
    --     end
    --     locations:MoveNext()
    -- end


    --Layout:FindLayout("tracker_horizontal"):Clear()
    --Layout:FindLayout("tracker_horizontal"):Clear()
    --Layout:FindLayout("settings_layout"):Clear()
    --Layout:FindLayout("settings_layout").Root.Background = "#ff0000"

    
    -- layout = Layout:FindLayout("shared_map").Root
    -- print(layout)
    -- --layout = layout.Items[2]
    -- e = layout.Items:GetEnumerator()
    -- e:MoveNext()
    -- e:MoveNext()
    -- print(e.Current)
    -- layout = e.Current
    -- e = layout.Maps:GetEnumerator()
    -- e:MoveNext()
    -- layout = e.Current
    -- print(layout)
    -- layout.Image = ImageReference:FromPackRelativePath("images/maps/overworld/07.png") --works!

    -- layout = Layout:FindLayout("shared_map").Root
    -- print(layout)
    -- --layout = layout.Items[2]
    -- e = layout.Items:GetEnumerator()
    -- e:MoveNext()
    -- layout = e.Current
    -- layout.Layout = Layout:FindLayout("shared_item_grid")
    
    STATUS.TRACKER_READY = true
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Package ready at: " .. os.clock() - STATUS.START_CLOCK)
    end
end
