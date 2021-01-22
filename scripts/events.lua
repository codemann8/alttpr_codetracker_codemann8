function tracker_on_begin_loading_save_file()
    TRACKER_READY = false
end

function tracker_on_finish_loading_save_file()
    if OBJ_RETRO then
        Tracker:FindObjectForCode("retro_mode_surrogate").ItemState:updateIcon()
        Tracker:FindObjectForCode("entrance_shuffle_surrogate").ItemState:postUpdate()
        updateIcons()
        TRACKER_READY = true
        tracker_on_accessibility_updated()
    end
    
    TRACKER_READY = true
end

function tracker_on_accessibility_updated()
    if TRACKER_READY then
        if OBJ_WORLDSTATE then
            --Update Dungeon Chest Icons
            for i = 1, #DungeonList do
                local item = Tracker:FindObjectForCode(DungeonList[i] .. "_item").ItemState
                if item then
                    item:UpdateBadgeAndIcon()
                end
            end
        end

        --Auto-Mark Medallions On Capture
        if false and OBJ_ENTRANCE then
            local medallion = Tracker:FindObjectForCode("bombos")
            local medallionFlag = medallion.CurrentStage & 0x3
            if medallionFlag ~= 0x3 then
                medallion = Tracker:FindObjectForCode("ether")
                medallionFlag = medallionFlag | medallion.CurrentStage
                if medallionFlag ~= 0x3 then
                    medallion = Tracker:FindObjectForCode("quake")
                    medallionFlag = medallionFlag | medallion.CurrentStage
                end
            end

            local loc = nil
            if medallionFlag & 0x1 == 0 then
                loc = Tracker:FindObjectForCode(OBJ_ENTRANCE.CurrentStage == 0 and "@Misery Mire/Medallion" or "@Misery Mire Entrance/Entrance").CapturedItem
                if loc then
                    medallion = Tracker:FindObjectForCode(string.lower(loc.Name))
                    medallion.CurrentStage = medallion.CurrentStage | 0x1
                end
            end
            if medallionFlag & 0x2 == 0 then
                loc = Tracker:FindObjectForCode(OBJ_ENTRANCE.CurrentStage == 0 and "@Turtle Rock/Medallion" or "@Turtle Rock Entrance/Entrance").CapturedItem
                if loc then
                    medallion = Tracker:FindObjectForCode(string.lower(loc.Name))
                    medallion.CurrentStage = medallion.CurrentStage | 0x2
                end
            end
        end

        --Update Ghost Badges
        if Tracker.ActiveVariantUID ~= "items_only" then
            updateGhosts(CaptureBadgeOverworld, false, false)
            updateGhosts(CaptureBadgeUnderworld, false, true)
            updateGhosts(CaptureBadgeEntrances, true, true)
            updateGhosts(CaptureBadgeDropdowns, true, true)
            updateGhosts(CaptureBadgeInsanity, true, true)
        end
    end
end