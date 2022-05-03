DoorTotalChest = CustomItem:extend()

function DoorTotalChest:init(name, suffix, itemType, img)
    self:createItem("Door Rando Total " .. name)
    self.code = "door_total" .. suffix

    self.Icon = ImageReference:FromPackRelativePath(img)
    self:setProperty("itemType", itemType)
end

function DoorTotalChest:setState(state)
    self:setProperty("state", state)
end

function DoorTotalChest:getState()
    return self:getProperty("state")
end

function DoorTotalChest:isEnabled()
    return not(OBJ_DOORSHUFFLE:getState() < 2 or (self:getProperty("itemType") == "smallkey" and OBJ_KEYSMALL:getState() == 2))
end

function DoorTotalChest:updateIcon()
    if not(self:isEnabled()) then
        self.ItemInstance.Icon = ""
        self.ItemInstance.BadgeText = nil
    else
        self.ItemInstance.Icon = self.Icon
        if self:getState() == 999 then
            self.ItemInstance.BadgeText = "?"
        else
            self.ItemInstance.BadgeText = string.format("%i", self:getState())
        end
    end
end

function DoorTotalChest:onLeftClick()
    if self:isEnabled() then
        local item = Tracker:FindObjectForCode(DATA.DungeonList[OBJ_DOORDUNGEON:getState()] .. "_" .. self:getProperty("itemType"))
        if item.ItemState and item.ItemState.MaxCount then
            item = item.ItemState
        end

        if self:getState() == 999 then
            if self:getProperty("itemType") == "smallkey" then
                item.MaxCount = item.AcquiredCount
                if item.MaxCount == 0 then
                    item.BadgeText = "0"
                end
            else
                item.MaxCount = item.CollectedCount
            end
            self:setState(item.MaxCount)
        else
            item.MaxCount = item.MaxCount + 1
            self:setState(self:getState() + 1)
        end
    end
end

function DoorTotalChest:onRightClick()
    if self:isEnabled() and self:getState() < 999 then
        local item = Tracker:FindObjectForCode(DATA.DungeonList[OBJ_DOORDUNGEON:getState()] .. "_" .. self:getProperty("itemType"))
        if item.ItemState and item.ItemState.MaxCount then
            item = item.ItemState
        end
        
        if item.MaxCount == (item.AcquiredCount and item.AcquiredCount or item.CollectedCount) then
            item.MaxCount = 999
        else
            item.MaxCount = item.MaxCount - 1
        end
        self:setState(item.MaxCount)
    end
end

function DoorTotalChest:canProvideCode(code)
    return code == self.code
end

function DoorTotalChest:save()
    return {}
end

function DoorTotalChest:load(data)
    self:updateIcon()
    return true
end

function DoorTotalChest:propertyChanged(key, value)
    if key == "state" then
        self:updateIcon()
    end
end
