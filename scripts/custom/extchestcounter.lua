ExtendedChestCounter = ChestCounter:extend()
ExtendedChestCounter:set {
    CollectedCount = {
        value = 0,
        set = function(self, value) return math.min(math.max(value, self.DeductedCount), self.MaxCount) end,
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
        get = function(self) return math.max(0, (self.MaxCount - self.ExemptedCount) - math.max(0, (self.CollectedCount + self.ManualCount) - self.DeductedCount)) end
    },
    ManualCount = {
        value = 0,
        afterSet = function(self)
                self.CollectedCount = self.CollectedCount
            end
    },
}

function ExtendedChestCounter:init(name, dungeonCode, sectionName, initialMaxCount, initialExemptCount)
    self:createItem(name)
    self.code = dungeonCode .. "_item"
    self:setProperty("dungeon", dungeonCode)
    self:setProperty("sectionName", sectionName)
    self.MaxCount = initialMaxCount
    self.ExemptedCount = initialExemptCount
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

function ExtendedChestCounter:Increment(count)
    count = count or 1
    self.ManualCount = self.ManualCount + (self.CountIncrement * count)
    return num
end

function ExtendedChestCounter:Decrement(count)
    count = count or 1
    self.ManualCount = self.ManualCount - (self.CountIncrement * count)
    return num
end

function ExtendedChestCounter:save()
    local data = {}
    data["min_count"] = self.MinCount
    data["max_count"] = self.MaxCount
    data["collected_count"] = self.CollectedCount
    data["manual_count"] = self.ManualCount
    data["exempted_count"] = self.ExemptedCount
    data["deducted_count"] = self.DeductedCount
    return data
end

function ExtendedChestCounter:load(data)
    if data["max_count"] ~= nil then
        self.MaxCount = data["max_count"]
    end
    if data["min_count"] ~= nil then
        self.MinCount = data["min_count"]
    end
    if data["collected_count"] ~= nil then
        self.CollectedCount = data["collected_count"]
    end
    if data["manual_count"] ~= nil then
        self.ManualCount = data["manual_count"]
    end
    if data["exempted_count"] ~= nil then
        self.ExemptedCount = data["exempted_count"]
    end
    if data["deducted_count"] ~= nil then
        self.DeductedCount = data["deducted_count"]
    end
    
    return true
end
