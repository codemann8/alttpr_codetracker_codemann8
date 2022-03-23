ExtendedChestCounter = ChestCounter:extend()

function ExtendedChestCounter:init(name, dungeonCode, sectionName, initialMaxCount)
    self:createItem(name)
    self.code = dungeonCode .. "_item"
    self:setProperty("dungeon", dungeonCode)
    self:setProperty("sectionName", sectionName)
    self.MaxCount = initialMaxCount
end

function ExtendedChestCounter:UpdateBadgeAndIcon()
    -- if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
    --     print("Updating chest icon for: " .. self:getProperty("dungeon"))
    -- end
    if OBJ_DOORSHUFFLE:getState() < 2 and self.RemainingCount == 0 then
        self.ItemInstance.Icon = self.RemainingCount > 0 and self.FullIcon or self.EmptyIcon
        self.ItemInstance.BadgeText = nil
    else
        if OBJ_DOORSHUFFLE:getState() == 2 and self.MaxCount ~= 999 and self.CollectedCount >= self.MaxCount then
            self.ItemInstance.Icon = self.EmptyIcon
        else
            self.ItemInstance.Icon = self.FullIcon
        end
        local text = nil
        if OBJ_DOORSHUFFLE:getState() == 2 then
            if self.MaxCount == 999 then
                text = tostring(math.floor(self.CollectedCount))
            elseif self.CollectedCount == self.MaxCount then
                text = tostring(math.floor(self.MaxCount))
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
    if OBJ_DOORSHUFFLE:getState() < 2 and Tracker.ActiveVariantUID == "full_tracker" and self:getProperty("section") then
        self.ItemInstance.BadgeTextColor = Layout:GetColorForAccessibility(self:getProperty("section").AccessibilityLevel)
    elseif OBJ_DOORSHUFFLE:getState() == 2 then
        if self.MaxCount == 999 then
            self.ItemInstance.BadgeTextColor = Layout:GetColorForAccessibility(AccessibilityLevel.SequenceBreak)
        else
            if self.CollectedCount >= self.MaxCount then
                self.ItemInstance.BadgeTextColor = Layout:GetColorForAccessibility(AccessibilityLevel.None)
            else
                self.ItemInstance.BadgeTextColor = Layout:GetColorForAccessibility(AccessibilityLevel.Partial)
            end
        end
    else
        if self.RemainingCount >= self.MaxCount then
            self.ItemInstance.BadgeTextColor = Layout:GetColorForAccessibility(AccessibilityLevel.Normal)
        else
            self.ItemInstance.BadgeTextColor = "WhiteSmoke"
        end
    end
end

function ExtendedChestCounter:InvalidateAccessibility()
    
end
