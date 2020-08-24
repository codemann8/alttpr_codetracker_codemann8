EntranceShuffleMode = CustomItem:extend()

function EntranceShuffleMode:init(suffix)
    self:createItem("Entrance Shuffle" .. suffix)
    self.code = "entrance_shuffle_surrogate"
    self.suffix = suffix

    self:setState(0)
end

function EntranceShuffleMode:setState(state)
    self:setProperty("state", state)
end

function EntranceShuffleMode:getState()
    return self:getProperty("state")
end

function EntranceShuffleMode:updateIcon()
    local item = Tracker:FindObjectForCode("entrance_shuffle")
    item.CurrentStage = self:getState()

    if self:getState() == 0 then
        self.ItemInstance.Icon =
            ImageReference:FromPackRelativePath("images/mode_entrance_shuffle_off" .. self.suffix .. ".png")
    else
        self.ItemInstance.Icon =
            ImageReference:FromPackRelativePath("images/mode_entrance_shuffle_on" .. self.suffix .. ".png")
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

function EntranceShuffleMode:onLeftClick()
    self:setState((self:getState() + 1) % 2)
end

function EntranceShuffleMode:onRightClick()
    self:setState((self:getState() - 1) % 2)
end

function EntranceShuffleMode:canProvideCode(code)
    if code == self.code .. self.suffix then
        return true
    else
        return false
    end
end

function EntranceShuffleMode:providesCode(code)
    if code == self.code .. self.suffix and self:getState() ~= 0 then
        return self:getState()
    end
    return 0
end

function EntranceShuffleMode:advanceToCode(code)
    if code == nil or code == self.code .. self.suffix then
        self:setState((self:getState() + 1) % 2)
    end
end

function EntranceShuffleMode:save()
    return {}
end

function EntranceShuffleMode:load(data)
    local item = Tracker:FindObjectForCode("entrance_shuffle")
    self:setState(item.CurrentStage)
    return true
end

function EntranceShuffleMode:propertyChanged(key, value)
    if key == "state" then
        self:updateIcon()
    end
end
