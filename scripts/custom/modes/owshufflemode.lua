OverworldShuffleMode = SurrogateItem:extend()

function OverworldShuffleMode:init(isAlt)
    self.baseCode = "ow_shuffle"
    self.label = "Overworld Shuffle"

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(2)
    self:setState(0)
end

function OverworldShuffleMode:updateIcon()
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_ow_shuffle_off" .. self.suffix .. ".png")
    elseif self:getState() == 1 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_ow_shuffle_on" .. self.suffix .. ".png")
    end
end

function OverworldShuffleMode:postUpdate()
    if self.suffix == "" then
        if self:getState() > 0 then
            Tracker.DisplayAllLocations = true
            Tracker.AlwaysAllowClearing = true
        else
            Tracker.DisplayAllLocations = PREFERENCE_DISPLAY_ALL_LOCATIONS
            Tracker.AlwaysAllowClearing = PREFERENCE_ALWAYS_ALLOW_CLEARING_LOCATIONS
        end
    end
end
