DoorSlot = CustomItem:extend()
DoorSlot.Icons = {
    [0] = "none",
    [1] = "unknown",
    [2] = "overlayX",
    [3] = "caution",
    [4] = "exit",
    [5] = "SmallKey2",
    [6] = "BigKey",
    [7] = "boss",
    [8] = "crystalswitch",
    [9] = "peg-blue",
    [10] = "peg-red",
    [11] = "bow",
    [12] = "0002",
    [13] = "firesource",
    [14] = "0005",
    [15] = "0010",
    [16] = "0007",
    [17] = "0011",
    [18] = "0015",
    [19] = "0021",
    [20] = "0019",
    [21] = "0020",
    [22] = "0023",
    [23] = "weapon"
}

function DoorSlot:init(roomSlotNum, doorSlotNum)
    self:createItem("Door Slot " .. (string.char(string.byte("A") + (roomSlotNum - 1))) .. doorSlotNum)
    self.code = "doorSlot" .. roomSlotNum .. "_" .. doorSlotNum
    self.roomSlot = roomSlotNum
    self.doorSlot = doorSlotNum

    self:setState(0)
end

function DoorSlot:setState(state)
    self:setProperty("state", state)
end

function DoorSlot:getState()
    return self:getProperty("state")
end

function DoorSlot:setDisabled()
    self.ItemInstance.IgnoreUserInput = self:getState() == 0
end

function DoorSlot:updateIcon()
    local imgPath = "images/" .. DoorSlot.Icons[self:getState()] .. ".png"
    self.ItemInstance.Icon = ImageReference:FromPackRelativePath(imgPath)
end

function DoorSlot:onLeftClick()
    local state = self:getState()
    if DoorSlotSelection.Selection == 0 then
        state = (state % #DoorSlot.Icons) + 1
    else
        if DoorSlotSelection.Groups[DoorSlotSelection.Selection] and state >= DoorSlotSelection.Selection and state <= DoorSlotSelection.Groups[DoorSlotSelection.Selection][1] then
            state = (((state - DoorSlotSelection.Selection) + 1) % ((DoorSlotSelection.Groups[DoorSlotSelection.Selection][1] - DoorSlotSelection.Selection) + 1)) + DoorSlotSelection.Selection
        else
            state = DoorSlotSelection.Selection
        end
    end

    if DOORSLOTS[ROOMSLOTS[self.roomSlot]] then
        DOORSLOTS[ROOMSLOTS[self.roomSlot]][self.doorSlot] = state
    end
    self:setState(state)
    refreshDoorSlots()
end

function DoorSlot:onRightClick()
    local state = self:getState()
    if DoorSlotSelection.Selection == 0 then
        state = (state - 2) % #DoorSlot.Icons + 1
    else
        state = 1
    end

    if DOORSLOTS[ROOMSLOTS[self.roomSlot]] then
        DOORSLOTS[ROOMSLOTS[self.roomSlot]][self.doorSlot] = state
    end
    self:setState(state)
    refreshDoorSlots()
end

function DoorSlot:canProvideCode(code)
    if code == self.code then
        return true
    else
        return false
    end
end

function DoorSlot:providesCode(code)
    if code == self.code and self:getState() ~= 0 then
        return self:getState()
    end
    return 0
end

function DoorSlot:advanceToCode(code)
    if code == nil or code == self.code then
        self:setState((self:getState() + 1) % #self.Icons)
    end
end

function DoorSlot:propertyChanged(key, value)
    if key == "state" then
        self:updateIcon()
        self:setDisabled()
    end
end
