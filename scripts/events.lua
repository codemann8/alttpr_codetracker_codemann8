function tracker_on_finish_loading_save_file()
    if OBJ_RETRO then
        Tracker:FindObjectForCode("retro_mode_surrogate").ItemState:updateIcon()
    end
end