RoomSelectSlot = CustomItem:extend()

function RoomSelectSlot:init(index)
    self:createItem("Room Select Slot " .. index)
    self.code = "roomselect_" .. index
    self.index = index
    self.roomId = 0
end

function RoomSelectSlot:onLeftClick()
    if self.roomId > 0 then
        updateRoomSlots(self.roomId)
    end
end

function RoomSelectSlot:onRightClick()
    self:onLeftClick()
end

function RoomSelectSlot:canProvideCode(code)
    return code == self.code
end
