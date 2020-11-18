SurrogateItem = CustomItem:extend()

function SurrogateItem:init(baseCode, isAlt)
    self.baseCode = baseCode
    self.label = "Generic Item"

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(2)
    self:setState(0)
end

function SurrogateItem:initCode()
    self.code = self.baseCode .. "_surrogate"
    
    if self.suffix == "" then
        self:createItem(self.label .. " Base")
    else
        self:createItem(self.label)
    end
end

function SurrogateItem:initSuffix(isAlt)
    if isAlt then
        self.suffix = "_small"
    else
        self.suffix = ""
    end
end

function SurrogateItem:linkSurrogate(item)
    self.linkedItem = item
    item.linkedItem = self
end

function SurrogateItem:getState()
    return self:getProperty("state")
end

function SurrogateItem:setState(state)
    self:setProperty("state", state)
end

function SurrogateItem:getCount()
    return self.numStates
end

function SurrogateItem:setCount(num)
    self.numStates = num
end

function SurrogateItem:updateItem()
    Tracker:FindObjectForCode(self.baseCode).CurrentStage = self:getState()
end

function SurrogateItem:updateIcon()
end

function SurrogateItem:updateSurrogate()
    if self.linkedItem and self:getState() ~= self.linkedItem:getState() then
        self.linkedItem:setState(self:getState())
    end
end

function SurrogateItem:postUpdate()
end

function SurrogateItem:onLeftClick()
    self:setState((self:getState() + 1) % self:getCount())
end

function SurrogateItem:onRightClick()
    self:setState((self:getState() - 1) % self:getCount())
end

function SurrogateItem:canProvideCode(code)
    return code == self.code .. self.suffix
end

function SurrogateItem:providesCode(code)
    if code == self.code .. self.suffix then
        return self:getState()
    end
    return 0
end

function SurrogateItem:advanceToCode(code)
    if code == nil or code == self.code .. self.suffix then
        self:OnLeftClick()
    end
end

function SurrogateItem:save()
    return {}
end

function SurrogateItem:load(data)
    self:setState(Tracker:FindObjectForCode(self.baseCode).CurrentStage)
    return true
end

function SurrogateItem:propertyChanged(key, value)
    if key == "state" then
        self:updateItem()
        self:updateIcon()
        self:updateSurrogate()
        self:postUpdate()
    end
end
