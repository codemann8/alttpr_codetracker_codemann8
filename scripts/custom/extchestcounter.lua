ExtendedChestCounter = ChestCounter:extend()
ExtendedChestCounter:set {
    CollectedCount = {
        value = 0,
        set = function(self, value) return math.min(math.max(value, self.MinCount), self.MaxCount - self.ExemptedCount) end,
        afterSet = function(self)
                self:UpdateBadgeAndIcon()
                self:InvalidateAccessibility()
            end
    },
    ExemptedCount = {
        value = 0,
        afterSet = function(self)
                self.CollectedCount = self.CollectedCount
            end
    },
    DeductedCount = {
        value = 0,
        afterSet = function(self)
                self.CollectedCount = self.CollectedCount
            end
    },
    RemainingCount = {
        get = function(self) return self.MaxCount - self.CollectedCount - self.ExemptedCount + self.DeductedCount end
    },
}

function ExtendedChestCounter:init(name, dungeonCode, sectionName, initialMaxCount)
    self:createItem(name)
    self.code = dungeonCode .. "_item"
    self:setProperty("dungeon", dungeonCode)
    self:setProperty("sectionName", sectionName)
    self.MaxCount = initialMaxCount
end

function ExtendedChestCounter:UpdateBadgeAndIcon()
    if (not shouldChestCountUp()) and self.RemainingCount == 0 then
        self.ItemInstance.Icon = self.RemainingCount > 0 and self.FullIcon or self.EmptyIcon
        self.ItemInstance.BadgeText = nil
    else
        if shouldChestCountUp() and self.MaxCount ~= 999 and self.CollectedCount - self.DeductedCount >= self.MaxCount - self.ExemptedCount then
            self.ItemInstance.Icon = self.EmptyIcon
        else
            self.ItemInstance.Icon = self.FullIcon
        end
        local text = nil
        if shouldChestCountUp() then
            if self.MaxCount == 999 then
                text = tostring(math.floor(self.CollectedCount - self.DeductedCount))
            elseif self.CollectedCount - self.DeductedCount >= self.MaxCount - self.ExemptedCount then
                text = tostring(math.floor(self.MaxCount - self.ExemptedCount))
            else
                text = tostring(math.floor(self.RemainingCount))
            end
        else
            text = tostring(math.floor(self.RemainingCount))
        end
        if not self.DisplayAsFractionOfMax then
            self.ItemInstance.BadgeText = text
        else
            self.ItemInstance.BadgeText = text .. "/" .. tostring(math.floor(self.MaxCount))
        end
    end
    if (not shouldChestCountUp()) and Tracker.ActiveVariantUID == "full_tracker" and self:getProperty("section") then
        local access = self:getProperty("section").AccessibilityLevel
        if access == AccessibilityLevel.Cleared then
            self.ItemInstance.BadgeTextColor = "#666"
        else
            self.ItemInstance.BadgeTextColor = Layout:GetColorForAccessibility(access)
        end
    elseif shouldChestCountUp() then
        if self.MaxCount == 999 then
            self.ItemInstance.BadgeTextColor = Layout:GetColorForAccessibility(AccessibilityLevel.SequenceBreak)
        else
            if self.CollectedCount - self.DeductedCount >= self.MaxCount - self.ExemptedCount then
                self.ItemInstance.BadgeTextColor = Layout:GetColorForAccessibility(AccessibilityLevel.None)
            else
                self.ItemInstance.BadgeTextColor = Layout:GetColorForAccessibility(AccessibilityLevel.Partial)
            end
        end
    else
        if self.RemainingCount >= self.MaxCount - self.ExemptedCount then
            self.ItemInstance.BadgeTextColor = Layout:GetColorForAccessibility(AccessibilityLevel.Normal)
        else
            self.ItemInstance.BadgeTextColor = "WhiteSmoke"
        end
    end
end

function ExtendedChestCounter:InvalidateAccessibility()
    
end
