OWSwap = SurrogateItem:extend()

function OWSwap:init(owid)
    self.owid = owid
    self.code = "ow_swapped_" .. string.format("%02x", self.owid)
    self.label = "OW " .. (owid < 0x40 and "LW " or "DW ") .. string.format("%02x", self.owid)
    self.modified = false
    self.clicked = false
    self.ignorePostUpdate = false

    self:createItem("")

    self:setCount(2)
    self:setState(0)
end

function OWSwap:canProvideCode(code)
    return code == self.code
end

function OWSwap:providesCode(code) --TODO: Not efficient, logical rules referencing this is calcing way too many times, update a new base item instead
    if code == self.code then
        if (self:getState() == 0 and self.owid >= 0x40) or (self:getState() == 1 and self.owid < 0x40) then
            return 1
        end
    elseif self.owid < 0x40 and code:find("^ow_swapped_") then
        local owid = tonumber(code:sub(12, 13), 16)
        if self.owid == owid % 0x40 then
            if (self:getState() == 0 and owid >= 0x40) or (self:getState() == 1 and owid < 0x40) then
                return 1
            end
        end
    end
    return 0
end

function OWSwap:onLeftClick()
    if OBJ_MIXED:getState() > 1 then
        self:updateSwap((self:getState() + 1) % self:getCount())
        if OBJ_MIXED:getState() < 3 then
            OBJ_MIXED:onRightClick()
        end
    end
end

function OWSwap:onRightClick()
    self:onLeftClick()
end

function OWSwap:updateSwap(state)
    self.modified = true
    self.clicked = true
    self:setState(state)
end

function OWSwap:updateSurrogate()
    if self.linkedItem and not self.linkedItem.clicked then
        self.linkedItem:setState(self:getState())
        self.linkedItem.modified = self.modified
    end
end

function OWSwap:updateIcon()
    local border = CONFIG.LAYOUT_HIDE_MAP_GRIDLINES and OBJ_MIXED:getState() == 0 and OBJ_OWSHUFFLE:getState() == 0
    border = border and "" or "overlay|images/maps/overworld/ow-tile-border" .. (DATA.MegatileOverworlds[self.owid % 0x40] and "-half" or "") .. ".png"
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/maps/overworld/" .. string.format("%02x", self.owid) .. ".png", border)
    elseif self:getState() == 1 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/maps/overworld/" .. string.format("%02x", (self.owid + 0x40) % 0x80)  .. ".png", border)
    elseif self:getState() == 2 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/maps/overworld/" .. string.format("%02x", (self.owid + 0x40) % 0x80)  .. ".png", "saturation|0.2," .. border)
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/maps/overworld/" .. string.format("%02x", self.owid) .. ".png", "saturation|0.2," .. border)
    end
end

function OWSwap:postUpdate()
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Screen " .. string.format("%02x", self.owid) .. " swapped")
    end
    if DATA.LinkedOverworldScreens[self.owid % 0x40] ~= nil then
        local item = Tracker:FindObjectForCode("ow_swapped_" .. DATA.LinkedOverworldScreens[self.owid % 0x40]).ItemState
        if item:getState() ~= self:getState() then
            item:updateSwap(self:getState())
        end
    end
end
