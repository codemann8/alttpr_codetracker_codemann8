OWSwap = SurrogateItem:extend()

function OWSwap:init(owid)
    self.owid = owid
    self.code = "ow_slot_" .. string.format("%02x", self.owid)
    self.label = "OW " .. (owid < 0x40 and "LW " or "DW ") .. string.format("%02x", self.owid)
    self.modified = false
    self.clicked = false
    self.ignorePostUpdate = false
    if owid < 0x40 then
        self.linkedSwap = Tracker:FindObjectForCode("ow_swap_" .. string.format("%02x", self.owid))
    end

    self:createItem("")

    self:setCount(2)
    self:setState(0)
end

function OWSwap:canProvideCode(code)
    return code == self.code
end

function OWSwap:providesCode(code)
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
    if OBJ_MIXED:getState() > 1 then
        if self:getState() < 2 then
            self:updateSwap(3) -- reset to unknown
        else
            self:updateSwap(self:getState() % self:getCount()) -- set to flipped
        end
        if OBJ_MIXED:getState() < 3 then
            OBJ_MIXED:onRightClick()
        end
    end
end

function OWSwap:updateSwap(state)
    self.modified = state < 2
    self.clicked = true
    self:setState(state)
    if self.linkedSwap then
        self.linkedSwap.CurrentStage = state
    end
end

function OWSwap:updateSurrogate()
    if self.linkedItem and not self.linkedItem.clicked then
        self.linkedItem:setState(self:getState())
        self.linkedItem.modified = self.modified
    end
    if self.linkedSwap then
        self.linkedSwap.CurrentStage = self:getState()
    end
end

function OWSwap:updateIcon()
    local border = CONFIG.LAYOUT_SHOW_MAP_GRIDLINES or OBJ_MIXED:getState() > 0 or OBJ_OWSHUFFLE:getState() > 0
    border = border and "overlay|images/maps/overworld/ow-tile-border" .. (DATA.MegatileOverworlds[self.owid % 0x40] and "-half" or "") .. ".png" or ""
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/maps/overworld/" .. string.format("%02x", self.owid) .. ".png", "saturation|0.75," .. border)
    elseif self:getState() == 1 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/maps/overworld/" .. string.format("%02x", (self.owid + 0x40) % 0x80)  .. ".png", "saturation|0.75," .. border)
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
        local item = Tracker:FindObjectForCode("ow_slot_" .. DATA.LinkedOverworldScreens[self.owid % 0x40]).ItemState
        if item:getState() ~= self:getState() then
            item:updateSwap(self:getState())
        end
    end
end
