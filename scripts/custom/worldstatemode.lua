WorldStateMode = CustomItem:extend()

function WorldStateMode:init(suffix)
    self:createItem("World State" .. suffix)
    self.code = "world_state_mode_surrogate"
    self.suffix = suffix

    self:setState(0)
end

function WorldStateMode:setState(state)
    self:setProperty("state", state)
end

function WorldStateMode:getState()
    return self:getProperty("state")
end

function WorldStateMode:updateIcon()
    local item = Tracker:FindObjectForCode("world_state_mode")
    item.CurrentStage = self:getState()

    if self:getState() == 0 then
        self.ItemInstance.Icon =
            ImageReference:FromPackRelativePath("images/mode_world_state_open" .. self.suffix .. ".png")
    else
        self.ItemInstance.Icon =
            ImageReference:FromPackRelativePath("images/mode_world_state_inverted" .. self.suffix .. ".png")
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

function WorldStateMode:onLeftClick()
    self:setState((self:getState() + 1) % 2)
end

function WorldStateMode:onRightClick()
    self:setState((self:getState() - 1) % 2)
end

function WorldStateMode:canProvideCode(code)
    if code == self.code .. self.suffix then
        return true
    else
        return false
    end
end

function WorldStateMode:providesCode(code)
    if code == self.code .. self.suffix and self:getState() ~= 0 then
        return self:getState()
    end
    return 0
end

function WorldStateMode:advanceToCode(code)
    if code == nil or code == self.code .. self.suffix then
        self:setState((self:getState() + 1) % 2)
    end
end

function WorldStateMode:save()
    return {}
end

function WorldStateMode:load(data)
    local item = Tracker:FindObjectForCode("world_state_mode")
    self:setState(item.CurrentStage)
    return true
end

function WorldStateMode:propertyChanged(key, value)
    if key == "state" then
        self:updateIcon()
    end
end
