EntranceShuffleMode = SurrogateItem:extend()

function EntranceShuffleMode:init(isAlt)
    self.baseCode = "entrance_shuffle"
    self.label = "Entrance Shuffle"

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(4)
    self:setState(0)
end

function EntranceShuffleMode:updateIcon()
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_entrance_shuffle_off" .. self.suffix .. ".png")
    elseif self:getState() == 1 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_entrance_shuffle_dungeon" .. self.suffix .. ".png")
    elseif self:getState() == 2 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_entrance_shuffle_entrance" .. self.suffix .. ".png")
    else 
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_entrance_shuffle_insanity" .. self.suffix .. ".png")
    end
end

function EntranceShuffleMode:postUpdate()
    if self.suffix == "" then
        --Activate Dropdowns
        local drops =  { "swpinball", "swcompass", "swbigchest", "swhazard" }
        for i = 1, #drops do
            local drop = Tracker:FindObjectForCode("dropdown_" .. drops[i])
            if self:getState() > 2 then
                drop.ActiveIcon = drop.ActiveIcon
                drop.IgnoreUserInput = false
            else
                drop.Icon = ""
                drop.IgnoreUserInput = true
            end
        end

        --Change Dropdown Capture Layouts
        for i = 1, #CaptureBadgeDropdowns do
            local drop = Tracker:FindObjectForCode(CaptureBadgeDropdowns[i])
            if self:getState() > 2 then
                drop.ItemCaptureLayout = "tracker_capture_dropdown_insanity"
            else
                drop.ItemCaptureLayout = "tracker_capture_dropdown"
            end
        end

        --Change Entrance Capture Layouts
        for i = 1, #CaptureBadgeEntrances do
            local drop = Tracker:FindObjectForCode(CaptureBadgeEntrances[i])
            if self:getState() > 2 then
                drop.ItemCaptureLayout = "tracker_capture_entrance_insanity"
            elseif self:getState() > 1 then
                drop.ItemCaptureLayout = "tracker_capture_entrance"
            else
                drop.ItemCaptureLayout = "tracker_capture_entrance_dungeon"
            end
        end

        if self:getState() > 0 then
            Tracker.DisplayAllLocations = true
            Tracker.AlwaysAllowClearing = true
        else
            Tracker.DisplayAllLocations = PREFERENCE_DISPLAY_ALL_LOCATIONS
            Tracker.AlwaysAllowClearing = PREFERENCE_ALWAYS_ALLOW_CLEARING_LOCATIONS
        end
    end
end
