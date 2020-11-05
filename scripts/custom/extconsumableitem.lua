ExtendedConsumableItem = ConsumableItem:extend()

function ExtendedConsumableItem:init(name, dungeonCode)
    self:createItem(name)
    self.code = dungeonCode .. "_item"
    self:setProperty("dungeon", dungeonCode)
end

function ExtendedConsumableItem:UpdateBadgeAndIcon()
    if self.AvailableCount == 0 then
        self.ItemInstance.Icon = self.AcquiredCount > 0 and self.FullIcon or self.EmptyIcon
        self.ItemInstance.BadgeText = nil
    else
        self.ItemInstance.Icon = self.FullIcon
        if not self.DisplayAsFractionOfMax then
            self.ItemInstance.BadgeText = tostring(math.floor(self.AvailableCount))
        else
            self.ItemInstance.BadgeText = tostring(math.floor(self.AvailableCount)) .. "/" .. tostring(math.floor(self.MaxCount))
        end
    end
    if self.AcquiredCount >= self.MaxCount then
        self.ItemInstance.BadgeTextColor = "#00ff00"
    else
        self.ItemInstance.BadgeTextColor = "WhiteSmoke"
    end
end
