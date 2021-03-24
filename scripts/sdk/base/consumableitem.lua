ConsumableItem = CustomItem:extend()
ConsumableItem:set {
    FullIcon = ImageReference:FromPackRelativePath("images/0058.png"),
    EmptyIcon = ImageReference:FromPackRelativePath("images/0059.png"),
    MaxCount = {
        value = 0x7fffffff,
        afterSet = function(self)
                self.AcquiredCount = self.AcquiredCount
                self.ConsumedCount = self.ConsumedCount
                self:UpdateBadgeAndIcon()
            end
    },
    MinCount = {
        value = 0,
        afterSet = function(self)
                self.AcquiredCount = self.AcquiredCount
                self.ConsumedCount = self.ConsumedCount
                self:UpdateBadgeAndIcon()
            end
    },
    AcquiredCount = {
        value = 0x7fffffff,
        set = function(self, value) return math.min(math.max(math.max(value, self.ConsumedCount), self.MinCount), self.MaxCount) end,
        afterSet = function(self)
                self:UpdateBadgeAndIcon()
                self:InvalidateAccessibility()
            end
    },
    ConsumedCount = {
        value = 0,
        set = function(self, value) return math.max(math.min(value, self.AvailableCount), 0) end,
        afterSet = function(self)
                self:UpdateBadgeAndIcon()
                self:InvalidateAccessibility()
            end
    },
    AvailableCount = {
        get = function(self) return self.AcquiredCount - self.ConsumedCount end
    },
    DisplayFractionOfMax = {
        value = false,
        afterSet = function(self) self:UpdateBadgeAndIcon() end
    },
    CountIncrement = 1,
    SwapActions = false
}

function ConsumableItem:init(name, code, maxqty, img, disabledImg, imgMods, disabledImgMods)
    maxqty = maxqty or self.MaxCount

    self:createItem(name)
    self.code = code

    self.MaxCount = maxqty
    if img then
        self.FullIcon = ImageReference:FromPackRelativePath(img, imgMods or "")
    end
    if disabledImg then
        self.EmptyIcon = ImageReference:FromPackRelativePath(disabledImg, disabledImgMods or "")
    end
end

function ConsumableItem:UpdateBadgeAndIcon()
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

function ConsumableItem:InvalidateAccessibility()
    self.ItemInstance:InvalidateAccessibility()
end

function ConsumableItem:Increment(count)
    count = count or 1
    local num = math.min(self.MaxCount, math.max(self.MinCount, self.AcquiredCount + (self.CountIncrement * count)))
    self.AcquiredCount = num
    return num
end

function ConsumableItem:Decrement(count)
    count = count or 1
    local num = math.min(self.MaxCount, math.max(self.MinCount, self.AcquiredCount - (self.CountIncrement * count)))
    self.AcquiredCount = num
    return num
end

function ConsumableItem:Consume(quantity)
    quantity = quantity or 1
    if self.AvailableCount < quantity then
        return false
    end
    self.ConsumedCount = self.ConsumedCount + quantity
    return true
end

function ConsumableItem:Release(quantity)
    quantity = quantity or 1
    if self.ConsumedCount < quantity then
        return false
    end
    self.ConsumedCount = self.ConsumedCount - quantity
    return true
end

function ConsumableItem:onLeftClick()
    if self.SwapActions then
        self:Increment(1)
    else
        self:Decrement(1)
    end
end

function ConsumableItem:onRightClick()
    if self.SwapActions then
        self:Decrement(1)
    else
        self:Increment(1)
    end
end

function ConsumableItem:canProvideCode(code)
    if code == self.code then
        return true
    else
        return false
    end
end

function ConsumableItem:providesCode(code)
    if code == self.code then
        return self.AcquiredCount
    end
    return 0
end

function ConsumableItem:advanceToCode(code)
    if code == nil or code == self.code then
        self:OnLeftClick()
    end
end

function ConsumableItem:save()
    local data = {}
    data["min_count"] = self.MinCount
    data["max_count"] = self.MaxCount
    data["consumed_count"] = self.ConsumedCount
    data["acquired_count"] = self.AcquiredCount
    return data
end

function ConsumableItem:load(data)
    local num = -1
    local num2 = -1
    if data["acquired_count"] ~= nil then
        num = data["acquired_count"]
    end
    if data["consumed_count"] ~= nil then
        num2 = data["consumed_count"]
    end
    if num < 0 or num2 < 0 then
        return false
    end
    if data["max_count"] ~= nil then
        self.MaxCount = data["max_count"]
    end
    if data["min_count"] ~= nil then
        self.MinCount = data["min_count"]
    end
    self.AcquiredCount = num
    self.ConsumedCount = num2
    return true
end
