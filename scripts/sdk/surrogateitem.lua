SurrogateItem = CustomItem:extend()

function SurrogateItem:init(baseCode, isAlt)
    self.baseCode = baseCode
    self.label = "Generic Item"
    self.clicked = false
    self.ignorePostUpdate = false

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(2)
    self:setState(0)
end

function SurrogateItem:initCode()
    self.code = self.baseCode
    
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

function SurrogateItem:linkSurrogate(item, onedirection)
    self.linkedItem = item
    if not onedirection then
        item.linkedItem = self
    end
    return self
end

function SurrogateItem:getState()
    return self:getProperty("state")
end

function SurrogateItem:setState(state)
    self:setProperty("state", state)
end

function SurrogateItem:setStateExternal(state)
    if self:getState() ~= state then
        self.clicked = true
        self:setState(state)
    end
end

function SurrogateItem:getCount()
    return self.numStates
end

function SurrogateItem:setCount(num)
    self.numStates = num
end

function SurrogateItem:updateIcon()
end

function SurrogateItem:updateSurrogate()
    if self.linkedItem and not self.linkedItem.clicked then
        self.linkedItem:setState(self:getState())
    end
end

function SurrogateItem:updateItem()
end

function SurrogateItem:postUpdate()
end

function SurrogateItem:onLeftClick()
    self.clicked = true
    self:setState((self:getState() + 1) % self:getCount())
end

function SurrogateItem:onRightClick()
    self.clicked = true
    self:setState((self:getState() - 1) % self:getCount())
end

function SurrogateItem:performUpdate()
    self:updateIcon()
    self:updateSurrogate()
    if self.clicked then
        --ensures only the one of the surrogate family items performs these steps
        self:updateItem()
        if not self.ignorePostUpdate then
            self:postUpdate()
        end
    end
    self.clicked = false
    self.ignorePostUpdate = false
end

function SurrogateItem:canProvideCode(code)
    return code == self.code .. self.suffix
end

function SurrogateItem:providesCode(code)
    if self.suffix == "" then
        if code == self.baseCode .. "_off" and self:getState() == 0 then
            return 1
        elseif code == self.baseCode .. "_on" and self:getState() == 1 then
            return 1
        end
    end
    return 0
end

function SurrogateItem:load(data)
    return true
end

function SurrogateItem:propertyChanged(key, value)
    if key == "state" then
        self:performUpdate()
    end
end
