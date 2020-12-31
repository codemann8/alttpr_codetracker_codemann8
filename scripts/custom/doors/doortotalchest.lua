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

function DoorTotalChest:updateIcon()
    if OBJ_DOORSHUFFLE.CurrentStage == 2 then
        self.ItemInstance.Icon = self.Icon
        if self:getState() == 99 then
            self.ItemInstance.BadgeText = "?"
        else
            self.ItemInstance.BadgeText = string.format("%i", self:getState())
        end
    else
        self.ItemInstance.Icon = ""
        self.ItemInstance.BadgeText = nil
    end
end

function DoorTotalChest:onLeftClick()
    if OBJ_DOORSHUFFLE.CurrentStage == 2 then
        local dungeons = {
            [0] = "hc",
            [1] = "ep",
            [2] = "dp",
            [3] = "toh",
            [4] = "at",
            [5] = "pod",
            [6] = "sp",
            [7] = "sw",
            [8] = "tt",
            [9] = "ip",
            [10] = "mm",
            [11] = "tr",
            [12] = "gt"
        }
        local item = Tracker:FindObjectForCode(dungeons[OBJ_DOORDUNGEON.ItemState:getState()] .. "_" .. self:getProperty("itemType"))
        if item.ItemState and item.ItemState.MaxCount then
            item = item.ItemState
        end

        if self:getState() == 99 then
            if self:getProperty("itemType") == "smallkey" then
                item.MaxCount = item.AcquiredCount
                if item.MaxCount == 0 then
                    item.BadgeText = "0"
                end
            else
                item.MaxCount = item.MaxCount - item.AcquiredCount
            end
            self:setState(item.MaxCount)
        else
            item.MaxCount = item.MaxCount + 1
            self:setState(self:getState() + 1)
        end
    end
end

function DoorTotalChest:onRightClick()
    if OBJ_DOORSHUFFLE.CurrentStage == 2 and self:getState() < 99 then
        local dungeons = {
            [0] = "hc",
            [1] = "ep",
            [2] = "dp",
            [3] = "toh",
            [4] = "at",
            [5] = "pod",
            [6] = "sp",
            [7] = "sw",
            [8] = "tt",
            [9] = "ip",
            [10] = "mm",
            [11] = "tr",
            [12] = "gt"
        }
        local item = Tracker:FindObjectForCode(dungeons[OBJ_DOORDUNGEON.ItemState:getState()] .. "_" .. self:getProperty("itemType"))
        if item.ItemState and item.ItemState.MaxCount then
            item = item.ItemState
        end
        
        if item.MaxCount == item.AcquiredCount then
            item.MaxCount = 99
            if self:getProperty("itemType") == "item" then
                item.AcquiredCount = item.MaxCount - item.AcquiredCount
            end
        else
            item.MaxCount = item.MaxCount - 1
        end
        self:setState(item.MaxCount)
    end
end

function DoorTotalChest:canProvideCode(code)
    if code == self.code then
        return true
    else
        return false
    end
end

function DoorTotalChest:providesCode(code)
    if code == self.code and self:getState() ~= 0 then
        return self:getState()
    end
    return 0
end

function DoorTotalChest:advanceToCode(code)
    if code == nil or code == self.code then
        self:setState((self:getState() + 1) % 12)
    end
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
