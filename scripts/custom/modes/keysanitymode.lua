KeysanityMode = SurrogateItem:extend()

function KeysanityMode:init(isAlt, item)
    self.itemCode = item:lower():gsub(" ", "")
    self.baseCode = "keysanity_" .. self.itemCode
    self.label = item .. " Shuffle"

    self:initSuffix(isAlt)
    self:initCode()

    if self.itemCode == "smallkey" then
        self:setCount(3)
    else
        self:setCount(2)
    end
    
    self:setState(0)
end

function KeysanityMode:updateIcon()
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_keysanity_" .. self.itemCode .. self.suffix .. ".png", "@disabled")
    elseif self.itemCode == "smallkey" and self:getState() == 2 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_keysanity_" .. self.itemCode .. "_universal" .. self.suffix .. ".png")
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_keysanity_" .. self.itemCode .. self.suffix .. ".png")
    end
end

function KeysanityMode:postUpdate()
    if self.suffix == "" and OBJ_KEYSANITY_BIG and OBJ_DOORSHUFFLE then
        updateIcons()
    end
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
