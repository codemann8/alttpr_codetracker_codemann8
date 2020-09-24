RetroMode = CustomItem:extend()

function RetroMode:init(suffix)
    self:createItem("Retro Mode" .. suffix)
    self.code = "retro_mode_surrogate"
    self.suffix = suffix

    self:setState(0)
end

function RetroMode:setState(state)
    self:setProperty("state", state)
end

function RetroMode:getState()
    return self:getProperty("state")
end

function RetroMode:updateIcon()
    local item = Tracker:FindObjectForCode("retro_mode")
    item.CurrentStage = self:getState()

    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_retro_off" .. self.suffix .. ".png")
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_retro_on" .. self.suffix .. ".png")
        Tracker:FindObjectForCode("keysanity_smallkey_surrogate").ItemState:setState(2)

    end

    --Sync other surrogates
    local state = -1
    if self.suffix == "" then
        item = Tracker:FindObjectForCode(self.code .. "_small")
        if item then
            state = item:ProvidesCode(self.code .. "_small")
        end
    else
        item = Tracker:FindObjectForCode(self.code)
        if item then
            state = item:ProvidesCode(self.code)
        end
    end
    if item and self:getState() ~= state then
        if (self:getState() - state) % 2 == 1 then
            item:OnLeftClick()
        else
            item:OnRightClick()
        end
    end
end

function RetroMode:onLeftClick()
    self:setState((self:getState() + 1) % 2)
end

function RetroMode:onRightClick()
    self:setState((self:getState() - 1) % 2)
end

function RetroMode:canProvideCode(code)
    if code == self.code .. self.suffix then
        return true
    else
        return false
    end
end

function RetroMode:providesCode(code)
    if code == self.code .. self.suffix and self:getState() ~= 0 then
        return self:getState()
    end
    return 0
end

function RetroMode:advanceToCode(code)
    if code == nil or code == self.code .. self.suffix then
        self:OnLeftClick()
    end
end

function RetroMode:save()
    return {}
end

function RetroMode:load(data)
    local item = Tracker:FindObjectForCode("retro_mode")
    self:setState(item.CurrentStage)
    return true
end

function RetroMode:propertyChanged(key, value)
    if key == "state" then
        self:updateIcon()
    end
end
