OverworldMixedMode = SurrogateItem:extend()

function OverworldMixedMode:init(isAlt)
    self.baseCode = "ow_mixed"
    self.label = "Overworld Tile Swap"

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(4)
    self:setState(0)
end

function OverworldMixedMode:onLeftClick()
    self.clicked = true
    if self:getState() == 3 then
        self:setState(1)
    else
        self:setState((self:getState() + 1) % self:getCount())
    end
end

function OverworldMixedMode:onRightClick()
    if self:getState() > 0 then
        self.clicked = true
        if self:getState() == 3 then
            self:setState(1)
        else
            self:setState((self:getState() - 1) % self:getCount())
        end
    end
end

function OverworldMixedMode:updateIcon()
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/ow_mixed" .. self.suffix .. ".png", "@disabled")
    else
        if self.suffix == "" or self:getState() == 1 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/ow_mixed" .. self.suffix .. ".png")
        elseif self:getState() == 2 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/ow_mixed_edit.png")
        else
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/ow_mixed_editlocked.png")
        end
    end
end

function OverworldMixedMode:updateItem()
    for i = 1, #DATA.OverworldIds do
        local item = Tracker:FindObjectForCode("ow_swapped_" .. string.format("%02x", DATA.OverworldIds[i])).ItemState
        if not item.modified then
            item:setState(self:getState() == 0 and OBJ_WORLDSTATE:getState() or (OBJ_WORLDSTATE:getState() == 0 and 3 or 2))
        end
    end
end

function OverworldMixedMode:postUpdate()
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("OW Mixed updated")
    end

    Layout:FindLayout("map").Root.HitTestVisible = self:getState() < 2
end
