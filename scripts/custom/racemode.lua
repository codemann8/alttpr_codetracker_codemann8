RaceMode = CustomItem:extend()

function RaceMode:init(suffix)
    self:createItem("Race Mode" .. suffix)
    self.code = "race_mode_surrogate"
    self.suffix = suffix

    self:setState(0)
end

function RaceMode:setState(state)
    self:setProperty("state", state)
end

function RaceMode:getState()
    return self:getProperty("state")
end

function RaceMode:updateIcon()
    local item = Tracker:FindObjectForCode("race_mode")
    item.CurrentStage = self:getState()

    item = Tracker:FindObjectForCode("gt_bkgame")
    item.AcquiredCount = 0
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_race_off" .. self.suffix .. ".png")
        item.Icon = ImageReference:FromPackRelativePath("images/BigKey.png", "@disabled")
        item.IgnoreUserInput = false;
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_race_on" .. self.suffix .. ".png")
        item.Icon = ImageReference:FromPackRelativePath("images/race-flag.png")
        item.IgnoreUserInput = true;
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
        item:OnLeftClick()
    end
end

function RaceMode:onLeftClick()
    self:setState((self:getState() + 1) % 2)
end

function RaceMode:onRightClick()
    self:setState((self:getState() - 1) % 2)
end

function RaceMode:canProvideCode(code)
    if code == self.code .. self.suffix then
        return true
    else
        return false
    end
end

function RaceMode:providesCode(code)
    if code == self.code .. self.suffix and self:getState() ~= 0 then
        return self:getState()
    end
    return 0
end

function RaceMode:advanceToCode(code)
    if code == nil or code == self.code .. self.suffix then
        self:OnLeftClick()
    end
end

function RaceMode:save()
    return {}
end

function RaceMode:load(data)
    local item = Tracker:FindObjectForCode("race_mode")
    self:setState(item.CurrentStage)
    return true
end

function RaceMode:propertyChanged(key, value)
    if key == "state" then
        self:updateIcon()
    end
end
