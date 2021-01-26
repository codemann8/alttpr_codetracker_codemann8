DoorSlotSelection = CustomItem:extend()
DoorSlotSelection.Types = {
    [2] = "x",
    [3] = "trap",
    [4] = "keys",
    [6] = "boss",
    [7] = "crystalpegs",
    [10] = "bow",
    [11] = "hookshot",
    [12] = "fire",
    [16] = "hammer",
    [17] = "somaria",
    [18] = "aitem",
    [21] = "sword"
}
DoorSlotSelection.Groups = { --[index of header] = index of last item in group
    [4] = {5, "keys"},
    [7] = {9, "crystalswitch"},
    [12] = {15, "firesource"},
    [18] = {20, "aitem"},
    [21] = {22, "0023"}
}
DoorSlotSelection.Selection = 2

function DoorSlotSelection:init(index)
    self:createItem("Door Slot Selection")
    self.index = index
    self.code = "doorslot_" .. DoorSlotSelection.Types[index]
    if DoorSlotSelection.Groups[index] then
        self.image = DoorSlotSelection.Groups[index][2]
    else
        self.image = DoorSlot.Icons[index]
    end

    self:setState(0)
end

function DoorSlotSelection:setState(state)
    self:setProperty("state", state)
end

function DoorSlotSelection:getState()
    return self:getProperty("state")
end

function DoorSlotSelection:updateIcon()
    local overlay = ""
    if DoorSlotSelection.Groups[self.index] and self:getState() > 0 then
        overlay = "overlay|images/overlayPlus.png,overlay|images/selected.png"
    elseif DoorSlotSelection.Groups[self.index] then
        overlay = "overlay|images/overlayPlus.png"
    elseif self:getState() > 0 then
        overlay = "overlay|images/selected.png"
    end

    self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/" .. self.image .. ".png", overlay)
end

function DoorSlotSelection:updateNeighbors()
    for i = 1, #DoorSlot.Icons do
        if DoorSlotSelection.Types[i] and self.index ~= i then
            local item = Tracker:FindObjectForCode("doorslot_" .. DoorSlotSelection.Types[i])
            if item then
                item.ItemState:setState(0)
            end
        end
    end
end

function DoorSlotSelection:onLeftClick()
    DoorSlotSelection.Selection = self.index
    self:setState(1)
    self:updateIcon()
    self:updateNeighbors()
end

function DoorSlotSelection:onRightClick()
    self:onLeftClick()
end

function DoorSlotSelection:canProvideCode(code)
    if code == self.code then
        return true
    else
        return false
    end
end

function DoorSlotSelection:providesCode(code)
    if code == self.code and self:getState() ~= 0 then
        return self:getState()
    end
    return 0
end

function DoorSlotSelection:advanceToCode(code)
    if code == nil or code == self.code then
        self:setState((self:getState() + 1) % 2)
    end
end

function DoorSlotSelection:propertyChanged(key, value)
    if key == "state" then
        self:updateIcon()
    end
end
