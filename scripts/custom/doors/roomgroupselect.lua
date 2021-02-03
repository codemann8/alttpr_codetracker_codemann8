RoomGroupSelection = CustomItem:extend()
RoomGroupSelection.Groups = { "hc", "lw", "pd", "sp", "sw", "tt", "ip", "mm", "tr", "gt" }
RoomGroupSelection.Content = {
    ["hc"] = { 0x60, 0x61, 0x62, 0x01, 0x52, 0x72, 0x81, 0x11 },
    ["lw"] = { 0xa8, 0xa9, 0x84, 0x85, 0x74, 0x77, 0x31, 0x27, 0x17 }, --0x07, --Moldorm Boss Arena
    ["pd"] = { 0x4a, 0x3a, 0x09, 0x2a, 0x2b, 0x1a },
    ["sp"] = { 0x34, 0x35, 0x36, 0x37, 0x38, 0x26, 0x76 },
    ["sw"] = { 0x56, 0x58, 0x67, 0x68 },
    ["tt"] = { 0xdb, 0xdc, 0xcb, 0xcc, 0xbb, 0xbc, 0x45 },
    ["ip"] = { 0x1e, 0x5e, 0x5f, 0x7e, 0x9e, 0xbe, },
    ["mm"] = { 0xc1, 0xc2, 0xc3, 0xb1, 0xb2, 0xb3, 0xa2, 0x97, 0xd1 },
    ["tr"] = { 0xc6, 0x14, 0x15, 0xc5, 0x24 },
    ["gt"] = { 0x0c, 0x8b, 0x8c, 0x8d, 0x7d, 0x9c, 0x96, 0x3d, 0x4d }
}
RoomGroupSelection.Selection = 1

function RoomGroupSelection:init(index)
    self:createItem("Room Group Selection")
    self.index = index
    self.code = "roomgroup_" .. RoomGroupSelection.Groups[self.index]

    self:setState(0)
end

function RoomGroupSelection:setState(state)
    self:setProperty("state", state)
end

function RoomGroupSelection:getState()
    return self:getProperty("state")
end

function RoomGroupSelection:updateIcon()
    if self:getState() > 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/" .. string.upper(RoomGroupSelection.Groups[self.index]) .. ".png", "overlay|images/selectedlabel.png")
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/" .. string.upper(RoomGroupSelection.Groups[self.index]) .. ".png")
    end
end

function RoomGroupSelection:postUpdate()
    --update neighbors
    for i = 1, #RoomGroupSelection.Groups do
        if RoomGroupSelection.Groups[i] and self.index ~= i then
            local item = Tracker:FindObjectForCode("roomgroup_" .. RoomGroupSelection.Groups[i])
            if item then
                item.ItemState:setState(0)
            end
        end
    end
    --update room select slots
    for i = 1, 9 do
        local item = Tracker:FindObjectForCode("roomselect_" .. i)
        if item then
            if RoomGroupSelection.Selection > 0 and RoomGroupSelection.Content[RoomGroupSelection.Groups[RoomGroupSelection.Selection]][i] then
                item.ItemState.roomId = RoomGroupSelection.Content[RoomGroupSelection.Groups[RoomGroupSelection.Selection]][i]
                item.Icon = ImageReference:FromPackRelativePath("images/rooms/" .. string.format("%02x", item.ItemState.roomId) .. ".png")
            else
                item.ItemState.roomId = 0
                item.Icon = nil
            end
        end
    end
end

function RoomGroupSelection:onLeftClick()
    local state = (self:getState() + 1) % 2
    RoomGroupSelection.Selection = state * self.index
    self:setState(state)
    self:updateIcon()
    self:postUpdate()
end

function RoomGroupSelection:onRightClick()
    self:onLeftClick()
end

function RoomGroupSelection:canProvideCode(code)
    if code == self.code then
        return true
    else
        return false
    end
end

function RoomGroupSelection:providesCode(code)
    if code == self.code and self:getState() ~= 0 then
        return self:getState()
    end
    return 0
end

function RoomGroupSelection:advanceToCode(code)
    if code == nil or code == self.code then
        self:setState((self:getState() + 1) % 2)
    end
end

function RoomGroupSelection:propertyChanged(key, value)
    if key == "state" then
        self:updateIcon()
    end
end
