GoalSetting = CustomItem:extend()

function GoalSetting:init()
    self:createItem("Goal")
    self.code = "goal_setting"

    self:setState(8)
end

function GoalSetting:setState(state)
    self:setProperty("state", state)
end

function GoalSetting:getState()
    return self:getProperty("state")
end

function GoalSetting:updateIcon()
    if self:getState() == 9 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/pedestal.png")
    elseif self:getState() == 10 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/goal_alldungeons.png")
    elseif self:getState() == 11 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/triforce.png")
    else
        if self:getState() == 0 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/ganon_crystals.png", "overlay|images/overlay0.png")
        elseif self:getState() == 1 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/ganon_crystals.png", "overlay|images/overlay1.png")
        elseif self:getState() == 2 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/ganon_crystals.png", "overlay|images/overlay2.png")
        elseif self:getState() == 3 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/ganon_crystals.png", "overlay|images/overlay3.png")
        elseif self:getState() == 4 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/ganon_crystals.png", "overlay|images/overlay4.png")
        elseif self:getState() == 5 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/ganon_crystals.png", "overlay|images/overlay5.png")
        elseif self:getState() == 6 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/ganon_crystals.png", "overlay|images/overlay6.png")
        elseif self:getState() == 7 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/ganon_crystals.png", "overlay|images/overlay7.png")
        elseif self:getState() == 8 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/ganon_crystals.png", "overlay|images/overlayNA.png")
        end
    end
end

function GoalSetting:onLeftClick()
    self:setState((self:getState() - 1) % 12)
end

function GoalSetting:onRightClick()
    self:setState((self:getState() + 1) % 12)
end

function GoalSetting:canProvideCode(code)
    if code == self.code then
        return true
    else
        return false
    end
end

function GoalSetting:providesCode(code)
    if code == self.code and self:getState() ~= 0 then
        return self:getState()
    end
    return 0
end

function GoalSetting:advanceToCode(code)
    if code == nil or code == self.code then
        self:setState((self:getState() + 1) % 12)
    end
end

function GoalSetting:save()
    local saveData = {}
    saveData["state"] = self:getState()
    return saveData
end

function GoalSetting:load(data)
    if data["state"] ~= nil then
        self:setState(data["state"])
    end
    return true
end

function GoalSetting:propertyChanged(key, value)
    if key == "state" then
        self:updateIcon()
    end
end
