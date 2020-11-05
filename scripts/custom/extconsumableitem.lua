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
        if not self.DisplayAsFractionOfMax or self.MaxCount == 0x7fffffff then
            self.ItemInstance.BadgeText = tostring(math.floor(self.AvailableCount))
        else
            self.ItemInstance.BadgeText = tostring(math.floor(self.AvailableCount)) .. "/" .. tostring(math.floor(self.MaxCount))
        end
    end
    if not self.SwapActions and self:getProperty("section") then
        local access = tostring(self:getProperty("section").AccessibilityLevel)
        access = access:sub(0, access:find(":") - 1)

        if access == "Normal" then
            self.ItemInstance.BadgeTextColor = "#00ff00"
        elseif access == "None" then
            self.ItemInstance.BadgeTextColor = "#ff3030"
        elseif access == "Partial" then
            self.ItemInstance.BadgeTextColor = "DarkOrange"
        elseif access == "SequenceBreak" then
            self.ItemInstance.BadgeTextColor = "Yellow"
        elseif access == "Inspect" then
            self.ItemInstance.BadgeTextColor = "CornflowerBlue"
        elseif access == "Unlockable" then
            self.ItemInstance.BadgeTextColor = "MediumPurple"
        elseif access == "Glitch" then
            self.ItemInstance.BadgeTextColor = "#b399c1"
        --elseif access == "Cleared" then
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
