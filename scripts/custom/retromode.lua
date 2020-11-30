RetroMode = SurrogateItem:extend()

function RetroMode:init(isAlt)
    self.baseCode = "retro_mode"
    self.label = "Retro Mode"

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(2)
    self:setState(0)
end

function RetroMode:updateIcon()
    local item = Tracker:FindObjectForCode("takeanycave")

    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_retro_off" .. self.suffix .. ".png")
        item.Icon = ImageReference:FromPackRelativePath("images/takeanycave.png", "@disabled")
        item.IgnoreUserInput = true
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_retro_on" .. self.suffix .. ".png")
        item.Active = not item.Active
        item.Active = not item.Active
        item.IgnoreUserInput = false
        if TRACKER_READY then
            Tracker:FindObjectForCode("keysanity_smallkey_surrogate").ItemState:setState(2)
        end
    end
end
