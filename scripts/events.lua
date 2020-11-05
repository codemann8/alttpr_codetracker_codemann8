function tracker_on_finish_loading_save_file()
    if OBJ_RETRO then
        Tracker:FindObjectForCode("retro_mode_surrogate").ItemState:updateIcon()
    end
end

function tracker_on_accessibility_updated()
    if OBJ_WORLDSTATE then
        local dungeons =  {"hc", "ep", "dp", "at", "sp", "pod", "mm", "sw", "ip", "toh", "tt", "tr", "gt"}
        for i = 1, #dungeons do
            local item = Tracker:FindObjectForCode(dungeons[i] .. "_item").ItemState
            if item then
                item:UpdateBadgeAndIcon()
            end
        end
    end
end