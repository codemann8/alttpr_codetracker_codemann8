KeysanityMode = CustomItem:extend()

function KeysanityMode:init(item, suffix)
    self.item = item
    self.itemCode = item:lower():gsub(" ", "")
    self.suffix = suffix

    self:createItem(self.item .. " Shuffle" .. self.suffix)
    self.code = "keysanity_" .. self.itemCode .. "_surrogate"

    self.numStates = 2
    if self.itemCode == "smallkey" then
        self.numStates = 3
    end
    
    self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_keysanity_" .. self.itemCode .. self.suffix .. ".png", "@disabled")
    self:setState(0)
end

function KeysanityMode:setState(state)
    self:setProperty("state", state)
end

function KeysanityMode:getState()
    return self:getProperty("state")
end

function KeysanityMode:updateIcon()
    Tracker:FindObjectForCode("keysanity_" .. self.itemCode).CurrentStage = self:getState()

    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_keysanity_" .. self.itemCode .. self.suffix .. ".png", "@disabled")
    elseif self.itemCode == "smallkey" and self:getState() == 2 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_keysanity_" .. self.itemCode .. "_universal" .. self.suffix .. ".png")
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_keysanity_" .. self.itemCode .. self.suffix .. ".png")
    end

    --Sync other surrogates
    local state = -1
    if self.suffix == "" then
        item = Tracker:FindObjectForCode(self.code .. "_small")
        if item then
            state = item.ItemState:getState()
        end
    else
        item = Tracker:FindObjectForCode(self.code)
        if item then
            state = item.ItemState:getState()
        end
    end
    if item and self:getState() ~= state then
        item.ItemState:setState(self:getState())
    end

    if self.suffix == "" and OBJ_KEYSANITY_BIG and OBJ_DOORSHUFFLE then
        updateIcons()
    end
end

function KeysanityMode:onLeftClick()
    self:setState((self:getState() + 1) % self.numStates)
end

function KeysanityMode:onRightClick()
    local items =  { "map", "compass", "smallkey", "bigkey" }
    local state = 1
    for i = 1, #items do
        if items[i] == self.itemCode then
            if items[i] == "smallkey" and OBJ_RETRO.CurrentStage > 0 then
                self:setState(2)
            else
                self:setState(state)
            end
            state = 0
        else
            if items[i] == "smallkey" and OBJ_RETRO.CurrentStage > 0 then
                Tracker:FindObjectForCode("keysanity_" .. items[i] .. "_surrogate").ItemState:setState(2)
            else
                Tracker:FindObjectForCode("keysanity_" .. items[i] .. "_surrogate").ItemState:setState(state)
            end
        end
    end
end

function KeysanityMode:canProvideCode(code)
    if code == self.code .. self.suffix then
        return true
    else
        return false
    end
end

function KeysanityMode:providesCode(code)
    if code == self.code .. self.suffix and self:getState() ~= 0 then
        return self:getState()
    end
    return 0
end

function KeysanityMode:advanceToCode(code)
    if code == nil or code == self.code .. self.suffix then
        self:OnLeftClick()
    end
end

function KeysanityMode:save()
    return {}
end

function KeysanityMode:load(data)
    local item = Tracker:FindObjectForCode("keysanity_" .. self.itemCode)
    self:setState(item.CurrentStage)
    return true
end

function KeysanityMode:propertyChanged(key, value)
    if key == "state" then
        self:updateIcon()
    end
end
