RetroMode = SurrogateItem:extend()

function RetroMode:init(isAlt)
    self.baseCode = "retro_mode"
    self.label = "Retro Mode"

    self.linkedSetting = Tracker:FindObjectForCode("retro_mode_off")

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(2)
    self:setState(0)
end

function RetroMode:updateIcon()
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/retro_off" .. self.suffix .. ".png")
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/retro_on" .. self.suffix .. ".png")
    end
end

function RetroMode:updateItem()
    local item = Tracker:FindObjectForCode("takeanycave")

    if self:getState() == 0 then
        item.Icon = ImageReference:FromPackRelativePath("images/icons/takeanycave.png", "@disabled")
        item.IgnoreUserInput = true
    else
        item.Active = not item.Active
        item.Active = not item.Active
        item.IgnoreUserInput = false
    end
end

function RetroMode:providesCode(code)
    return 0
end

function RetroMode:postUpdate()
    if self.linkedSetting then
        self.linkedSetting.CurrentStage = self:getState()
    end
end
