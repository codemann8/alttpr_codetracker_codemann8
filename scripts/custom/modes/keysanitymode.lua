KeysanityMode = SurrogateItem:extend()

function KeysanityMode:init(isAlt, item)
    self.itemCode = item:lower():gsub(" ", "")
    self.baseCode = "keysanity_" .. self.itemCode
    self.label = item .. " Shuffle"

    self.linkedSetting = Tracker:FindObjectForCode("keysanity_" .. self.itemCode .. "_off")

    self:initSuffix(isAlt)
    self:initCode()

    if self.itemCode == "smallkey" or self.itemCode == "prize" then
        self:setCount(3)
    else
        self:setCount(2)
    end

    if self.itemCode == "prize" and isAlt then
        self.ItemInstance.MaskInput = true
    end
    
    self:setState(0)
end

function KeysanityMode:providesCode(code)
    return 0
end

function KeysanityMode:updateIcon()
    if self:getState() == 0 and self.itemCode == "prize" then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/keysanity_" .. self.itemCode .. "_wild"  .. self.suffix .. ".png", "@disabled")
    elseif self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/keysanity_" .. self.itemCode .. self.suffix .. ".png", "@disabled")
    elseif self.itemCode == "smallkey" and self:getState() == 2 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/keysanity_" .. self.itemCode .. "_universal" .. self.suffix .. ".png")
    elseif self.itemCode == "prize" and self:getState() == 2 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/keysanity_" .. self.itemCode .. "_wild" .. self.suffix .. ".png")
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/keysanity_" .. self.itemCode .. self.suffix .. ".png")
    end
end

function KeysanityMode:postUpdate()
    if self.linkedSetting then
        self.linkedSetting.CurrentStage = self:getState()
    end

    if self.itemCode == "prize" then
        if self:getState() > 0 then
            Layout:FindLayout("ref_pendant_grid").Root.Layout = Layout:FindLayout("shared_pendant_grid")
            Layout:FindLayout("ref_crystal_grid").Root.Layout = Layout:FindLayout("shared_crystal_grid")
        else
            Layout:FindLayout("ref_pendant_grid").Root.Layout = nil
            Layout:FindLayout("ref_crystal_grid").Root.Layout = nil
        end
        updateLayout("nothing")
    end
    
    updateChests()
end

function KeysanityMode:onRightClick()
    local items =  { "map", "compass", "smallkey", "bigkey" }
    local itemList = {}
    for i = 1, #items do
        itemList[items[i]] = i
    end
    if itemList[self.itemCode] == nil then
        self.clicked = true
        self:setState((self:getState() - 1) % self:getCount())
    else
        function setState(item, state)
            local itemToPostUpdate = nil
            if item:getState() ~= state then
                item.ignorePostUpdate = true
                itemToPostUpdate = item
            end
            item:setStateExternal(state)
            return itemToPostUpdate
        end

        local state = 1
        local itemToPostUpdate = nil
        for i = 1, #items do
            local changedItem = nil

            if items[i] == self.itemCode then
                changedItem = setState(self, state)
                state = 0
            else
                changedItem = setState(Tracker:FindObjectForCode("keysanity_" .. items[i]).ItemState, state)
                if changedItem then
                    changedItem.linkedSetting.CurrentStage = state
                end
            end

            if changedItem then
                itemToPostUpdate = changedItem
            end
        end
        if itemToPostUpdate then
            itemToPostUpdate.ignorePostUpdate = false
        end
    end
end
