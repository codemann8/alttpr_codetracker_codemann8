OverworldLayoutMode = SurrogateItem:extend()

function OverworldLayoutMode:init(isAlt)
    self.baseCode = "ow_layout"
    self.label = "Overworld Shuffle"

    self.linkedSetting = Tracker:FindObjectForCode("ow_layout_off")

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(2)
    self:setState(0)
end

function OverworldLayoutMode:providesCode(code)
    return 0
end

function OverworldLayoutMode:updateIcon()
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/ow_layout" .. self.suffix .. ".png", "@disabled")
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/ow_layout" .. self.suffix .. ".png")
    end
end

function OverworldLayoutMode:postUpdate()
    if self.linkedSetting then
        self.linkedSetting.CurrentStage = self:getState()
    end

    if self:getState() > 0 then
        Tracker.DisplayAllLocations = true
        Tracker.AlwaysAllowClearing = true
    else
        -- Tracker.DisplayAllLocations = CONFIG.PREFERENCE_DISPLAY_ALL_LOCATIONS
        Tracker.AlwaysAllowClearing = CONFIG.PREFERENCE_ALWAYS_ALLOW_CLEARING_LOCATIONS
    end

    for i = 1, #DATA.OverworldIds do
        Tracker:FindObjectForCode("ow_slot_" .. string.format("%02x", DATA.OverworldIds[i])).ItemState:updateIcon()
        Tracker:FindObjectForCode("ow_slot_" .. string.format("%02x", DATA.OverworldIds[i] + 0x40)).ItemState:updateIcon()
    end
end
