EntranceShuffleMode = SurrogateItem:extend()

function EntranceShuffleMode:init(isAlt)
    self.baseCode = "entrance_shuffle"
    self.label = "Entrance Shuffle"

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(5)
    self:setState(0)
end

function EntranceShuffleMode:providesCode(code)
    if self.suffix == "" then
        if code == "entrance_shuffle_off" and self:getState() == 0 then
            return 1
        elseif code == "entrance_shuffle_on" and self:getState() > 0 then
            return 1
        elseif code == "entrance_shuffle_minor" and self:getState() < 2 then
            return 1
        elseif code == "entrance_shuffle_crossed" and self:getState() == 3 then
            return 1
        elseif code == "entrance_shuffle_all" and self:getState() > 1 then
            return 1
        elseif code == "entrance_shuffle_dungeon" and self:getState() == 1 then
            return 1
        elseif code == "entrance_shuffle_lite" and self:getState() == 2 then
            return 1
        elseif code == "entrance_shuffle_insanity" and self:getState() == 4 then
            return 1
        end
    end
    return 0
end

function EntranceShuffleMode:updateIcon()
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/entrance_shuffle_off" .. self.suffix .. ".png")
    elseif self:getState() == 1 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/entrance_shuffle_dungeon" .. self.suffix .. ".png")
    elseif self:getState() == 2 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/entrance_shuffle_lite" .. self.suffix .. ".png")
    elseif self:getState() == 3 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/entrance_shuffle_entrance" .. self.suffix .. ".png")
    else 
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/entrance_shuffle_insanity" .. self.suffix .. ".png")
    end
end

function EntranceShuffleMode:postUpdate()
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Entrance shuffle mode changed")
    end

    --Change Dropdown Capture Layouts
    for i = 1, #DATA.CaptureBadgeDropdowns do
        local drop = Tracker:FindObjectForCode(DATA.CaptureBadgeDropdowns[i])
        if self:getState() > 3 then
            drop.ItemCaptureLayout = "tracker_capture_dropdown_insanity"
        else
            drop.ItemCaptureLayout = "tracker_capture_dropdown"
        end
    end

    --Change Entrance Capture Layouts
    for i = 1, #DATA.CaptureBadgeEntrances do
        local drop = Tracker:FindObjectForCode(DATA.CaptureBadgeEntrances[i])
        if self:getState() > 3 then
            drop.ItemCaptureLayout = "tracker_capture_entrance_insanity"
        --elseif self:getState() == 2 then
        --    drop.ItemCaptureLayout = "tracker_capture_entrance_location"
        elseif self:getState() > 1 then
            drop.ItemCaptureLayout = "tracker_capture_entrance"
        else
            drop.ItemCaptureLayout = "tracker_capture_entrance_dungeon"
        end
    end

    for i = 1, #DATA.CaptureBadgeDungeons do
        local drop = Tracker:FindObjectForCode(DATA.CaptureBadgeDungeons[i])
        if self:getState() > 3 then
            drop.ItemCaptureLayout = "tracker_capture_entrance_insanity"
        --elseif self:getState() == 2 then
        --    drop.ItemCaptureLayout = "tracker_capture_entrance_dungeon"
        elseif self:getState() > 1 then
            drop.ItemCaptureLayout = "tracker_capture_entrance"
        else
            drop.ItemCaptureLayout = "tracker_capture_entrance_dungeon"
        end
    end

    for i = 1, #DATA.CaptureBadgeConnectors do
        local drop = Tracker:FindObjectForCode(DATA.CaptureBadgeConnectors[i])
        if self:getState() > 3 then
            drop.ItemCaptureLayout = "tracker_capture_entrance_insanity"
        --elseif self:getState() == 2 then
        --    drop.ItemCaptureLayout = "tracker_capture_entrance_connector"
        elseif self:getState() > 1 then
            drop.ItemCaptureLayout = "tracker_capture_entrance"
        else
            drop.ItemCaptureLayout = "tracker_capture_entrance_dungeon"
        end
    end

    
    --Change Dropdown Layouts
    local e = Layout:FindLayout("shared_dropdown_grid").Root.Items:GetEnumerator()
    e:MoveNext()
    e = e.Current.Children:GetEnumerator()
    e:MoveNext()
    e:MoveNext()
    e.Current.MaxWidth = self:getState() == 4 and -1 or 0
    
    Layout:FindLayout("shared_bottom_grid").Root.Layout = self:getState() < 2 and Layout:FindLayout("shared_bottom_misc_grid") or Layout:FindLayout("shared_bottom_all_grid")

    e = Layout:FindLayout("shared_dropdown_vertical_grid").Root
    e.MaxWidth = self:getState() == 4 and -1 or self:getState() < 2 and 0 or 107
    e.Margin = self:getState() < 2 and 0 or "0,0,2,0"
    
    e = Layout:FindLayout("shared_dropdown_v_grid").Root
    e.MaxHeight = self:getState() < 2 and 0 or -1
    e = e.Items:GetEnumerator()
    e:MoveNext()
    e.Current.Margin = self:getState() == 4 and "0,0,0,22" or 0

    Layout:FindLayout("ref_dropdown_insanity_grid").Root.Layout = (self:getState() == 4 and Layout:FindLayout("shared_dropdown_insanity_grid") or nil)
    
    e = Layout:FindLayout("shared_misc_v_grid").Root
    e.Margin = self:getState() == 4 and "-196,-74,0,0" or 0
    e.MaxWidth = self:getState() == 4 and 180 or -1
    e.Background = self:getState() == 4 and "#00000000" or ""
    
    
    if self:getState() > 0 then
        Tracker.DisplayAllLocations = true
        Tracker.AlwaysAllowClearing = true
    else
        Tracker.DisplayAllLocations = CONFIG.PREFERENCE_DISPLAY_ALL_LOCATIONS
        Tracker.AlwaysAllowClearing = CONFIG.PREFERENCE_ALWAYS_ALLOW_CLEARING_LOCATIONS
    end
end
