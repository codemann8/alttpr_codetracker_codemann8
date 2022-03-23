DoorSlotSelection = CustomItem:extend()
DoorSlotSelection.Types = {
    [2] = "x",
    [3] = "signs",
    [5] = "keys",
    [7] = "boss",
    [8] = "crystalpegs",
    [11] = "fire",
    [15] = "yitem",
    [19] = "aitem",
    [22] = "sword",
    [24] = "number"
}
DoorSlotSelection.Groups = { --[index of header] = index of last item in group
    [3] = {4, "doortracker/signs"},
    [5] = {6, "doortracker/keys"},
    [8] = {10, "doortracker/crystalswitch"},
    [11] = {14, "doortracker/firesource"},
    [15] = {18, "doortracker/yitem"},
    [19] = {21, "doortracker/aitem"},
    [22] = {23, "items/sword"},
    [24] = {29, "doortracker/number"}
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
        overlay = "overlay|images/doortracker/overlays/plus.png,overlay|images/doortracker/overlays/selected.png"
    elseif DoorSlotSelection.Groups[self.index] then
        overlay = "overlay|images/doortracker/overlays/plus.png"
    elseif self:getState() > 0 then
        overlay = "overlay|images/doortracker/overlays/selected.png"
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
    return code == self.code
end

function DoorSlotSelection:propertyChanged(key, value)
    if key == "state" then
        self:updateIcon()
    end
end
