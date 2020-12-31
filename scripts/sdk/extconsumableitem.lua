ExtendedConsumableItem = ConsumableItem:extend()

function ExtendedConsumableItem:init(name, dungeonCode, sectionName)
    self:createItem(name)
    self.code = dungeonCode .. "_item"
    self:setProperty("dungeon", dungeonCode)
    self:setProperty("sectionName", sectionName)
end

function ExtendedConsumableItem:UpdateBadgeAndIcon()
    if not self.SwapActions and self.AvailableCount == 0 then
        self.ItemInstance.Icon = self.AcquiredCount > 0 and self.FullIcon or self.EmptyIcon
        self.ItemInstance.BadgeText = nil
    else
        if self.SwapActions and self.MaxCount ~= 99 and self.AcquiredCount == self.MaxCount then
            self.ItemInstance.Icon = self.EmptyIcon
        else
            self.ItemInstance.Icon = self.FullIcon
        end
        local text = nil
        if self.SwapActions then
            if self.MaxCount == 99 then
                text = tostring(math.floor(self.MaxCount - self.AcquiredCount))
            elseif self.AcquiredCount == self.MaxCount then
                text = tostring(math.floor(self.MaxCount))
            else
                text = tostring(math.floor(self.MaxCount - self.AcquiredCount))
            end
        else
            text = tostring(math.floor(self.AvailableCount))
        end
        if not self.DisplayAsFractionOfMax or self.MaxCount == 0x7fffffff or (self.SwapActions and self.MaxCount == 99) then
            self.ItemInstance.BadgeText = text
        else
            self.ItemInstance.BadgeText = text .. "/" .. tostring(math.floor(self.MaxCount))
        end
    end
    if not self.SwapActions and self:getProperty("section") then
        local access = self:getProperty("section").AccessibilityLevel

        if access == AccessibilityLevel.Normal then
            self.ItemInstance.BadgeTextColor = "#00ff00"
        elseif access == AccessibilityLevel.None then
            self.ItemInstance.BadgeTextColor = "#ff3030"
        elseif access == AccessibilityLevel.Partial then
            self.ItemInstance.BadgeTextColor = "DarkOrange"
        elseif access == AccessibilityLevel.SequenceBreak then
            self.ItemInstance.BadgeTextColor = "Yellow"
        elseif access == AccessibilityLevel.Inspect then
            self.ItemInstance.BadgeTextColor = "CornflowerBlue"
        elseif access == AccessibilityLevel.Unlockable then
            self.ItemInstance.BadgeTextColor = "MediumPurple"
        elseif access == AccessibilityLevel.Glitch then
            self.ItemInstance.BadgeTextColor = "#b399c1"
        --elseif access == AccessibilityLevel.Cleared then
            --self.ItemInstance.BadgeTextColor = "#333333"
        else
            self.ItemInstance.BadgeTextColor = "WhiteSmoke"
        end
    elseif self.SwapActions then
        if self.MaxCount == 99 then
            self.ItemInstance.BadgeTextColor = "Yellow"
        else
            if self.AcquiredCount >= self.MaxCount then
                self.ItemInstance.BadgeTextColor = "#ff3030"
            else
                self.ItemInstance.BadgeTextColor = "DarkOrange"
            end
        end
    else
        if self.AcquiredCount >= self.MaxCount then
            self.ItemInstance.BadgeTextColor = "#00ff00"
        else
            self.ItemInstance.BadgeTextColor = "WhiteSmoke"
        end
    end
end

function ExtendedConsumableItem:onLeftClick()
    if self.SwapActions and self.MaxCount ~= 99 then
        self:Increment(1)
    else
        self:Decrement(1)
    end
end

function ExtendedConsumableItem:onRightClick()
    if self.SwapActions and self.MaxCount ~= 99 then
        self:Decrement(1)
    else
        self:Increment(1)
    end
end
