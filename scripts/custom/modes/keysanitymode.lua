KeysanityMode = SurrogateItem:extend()

function KeysanityMode:init(isAlt, item)
    self.itemCode = item:lower():gsub(" ", "")
    self.baseCode = "keysanity_" .. self.itemCode
    self.label = item .. " Shuffle"

    self.linkedSetting = Tracker:FindObjectForCode("keysanity_" .. self.itemCode .. "_off")

    self:initSuffix(isAlt)
    self:initCode()

    if self.itemCode == "smallkey" then
        self:setCount(3)
    else
        self:setCount(2)
    end
    
    self:setState(0)
end

function KeysanityMode:providesCode(code)
    return 0
end

function KeysanityMode:updateIcon()
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/keysanity_" .. self.itemCode .. self.suffix .. ".png", "@disabled")
    elseif self.itemCode == "smallkey" and self:getState() == 2 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/keysanity_" .. self.itemCode .. "_universal" .. self.suffix .. ".png")
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/keysanity_" .. self.itemCode .. self.suffix .. ".png")
    end
end

function KeysanityMode:postUpdate()
    if self.linkedSetting then
        self.linkedSetting.CurrentStage = self:getState()
    end
    
    updateChests()
end

function KeysanityMode:onRightClick()
    function setState(item, state)
        local itemToPostUpdate = nil
        if item:getState() ~= state then
            item.ignorePostUpdate = true
            itemToPostUpdate = item
        end
        item:setStateExternal(state)
        return itemToPostUpdate
    end

    local items =  { "map", "compass", "smallkey", "bigkey" }
    local state = 1
    local itemToPostUpdate = nil
    for i = 1, #items do
        local changedItem = nil

        if items[i] == self.itemCode then
            changedItem = setState(self, state)
            state = 0
        else
            changedItem = setState(Tracker:FindObjectForCode("keysanity_" .. items[i]).ItemState, state)
            changedItem.linkedSetting.CurrentStage = state
        end

        if changedItem then
            itemToPostUpdate = changedItem
        end
    end
    if itemToPostUpdate then
        itemToPostUpdate.ignorePostUpdate = false
    end
end
