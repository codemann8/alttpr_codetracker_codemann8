DoorSlot = CustomItem:extend()
DoorSlot.Icons = {
    [0] = "none",
    [1] = "doortracker/unknown",
    [2] = "overlays/overlay-x",
    [3] = "doortracker/caution",
    [4] = "doortracker/exit",
    [5] = "items/smallkey",
    [6] = "items/bigkey",
    [7] = "doortracker/boss",
    [8] = "doortracker/crystalswitch",
    [9] = "doortracker/peg-blue",
    [10] = "doortracker/peg-red",
    [11] = "doortracker/firesource",
    [12] = "items/firerod",
    [13] = "items/lamp",
    [14] = "items/bombos",
    [15] = "items/somaria",
    [16] = "items/hammer",
    [17] = "items/hookshot",
    [18] = "items/bow",
    [19] = "items/flippers",
    [20] = "items/glove-1",
    [21] = "items/boots",
    [22] = "items/sword",
    [23] = "doortracker/weapon",
    [24] = "doortracker/1",
    [25] = "doortracker/2",
    [26] = "doortracker/3",
    [27] = "doortracker/4",
    [28] = "doortracker/5",
    [29] = "doortracker/6"
}
DoorSlot.OWIcons = {
    [4] = "items/portal",
    [5] = "items/smallkey",
    [6] = "items/bigkey",
    [7] = "doortracker/boss",
    [8] = "items/frog",
    [9] = "items/purplechest",
    [10] = "icons/entrances/potionshop",
    [11] = "items/firerod",
    [12] = "items/lamp",
    [13] = "items/bombos",
    [15] = "items/mirror",
    [16] = "items/book",
    [17] = "items/hammer",
    [18] = "items/hookshot",
    [22] = "doortracker/weapon",
    [23] = "",
    [24] = "doortracker/1",
    [25] = "doortracker/2",
    [26] = "doortracker/3",
    [27] = "doortracker/4",
    [28] = "doortracker/5",
    [29] = "doortracker/6"
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
    local img = ""
    if INSTANCE.ROOMSLOTS[self.roomSlot][1] > 0x1000 then
        img = DoorSlot.OWIcons[self:getState()]
    end
    if not img or img == "" then
        img = DoorSlot.Icons[self:getState()]
    end
    local imgPath = "images/" .. img .. ".png"
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

    if INSTANCE.DOORSLOTS[INSTANCE.ROOMSLOTS[self.roomSlot][1]] then
        INSTANCE.DOORSLOTS[INSTANCE.ROOMSLOTS[self.roomSlot][1]][self.doorSlot] = state
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

    if INSTANCE.DOORSLOTS[INSTANCE.ROOMSLOTS[self.roomSlot][1]] then
        INSTANCE.DOORSLOTS[INSTANCE.ROOMSLOTS[self.roomSlot][1]][self.doorSlot] = state
    end
    self:setState(state)
    refreshDoorSlots()
end

function DoorSlot:canProvideCode(code)
    return code == self.code
end

function DoorSlot:propertyChanged(key, value)
    if key == "state" then
        self:updateIcon()
        self:setDisabled()
    end
end
