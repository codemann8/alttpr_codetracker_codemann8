ChestCounter = CustomItem:extend()
ChestCounter:set {
    FullIcon = ImageReference:FromPackRelativePath("images/items/chest.png"),
    EmptyIcon = ImageReference:FromPackRelativePath("images/items/chest-opened.png"),
    MaxCount = {
        value = 0x7fffffff,
        afterSet = function(self)
                self.CollectedCount = self.CollectedCount
            end
    },
    MinCount = {
        value = 0,
        afterSet = function(self)
                self.CollectedCount = self.CollectedCount
            end
    },
    CollectedCount = {
        value = 0,
        set = function(self, value) return math.min(math.max(value, self.MinCount), self.MaxCount) end,
        afterSet = function(self)
                self:UpdateBadgeAndIcon()
                self:InvalidateAccessibility()
            end
    },
    RemainingCount = {
        get = function(self) return self.MaxCount - self.CollectedCount end
    },
    DisplayFractionOfMax = {
        value = false,
        afterSet = function(self) self:UpdateBadgeAndIcon() end
    },
    CountIncrement = 1,
    SwapActions = false
}

function ChestCounter:init(name, code, maxqty, img, disabledImg, imgMods, disabledImgMods)
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

function ChestCounter:UpdateBadgeAndIcon()
    if self.RemainingCount == 0 then
        self.ItemInstance.Icon = self.EmptyIcon
        self.ItemInstance.BadgeText = nil
    else
        self.ItemInstance.Icon = self.FullIcon
        if not self.DisplayAsFractionOfMax then
            self.ItemInstance.BadgeText = tostring(math.floor(self.RemainingCount))
        else
            self.ItemInstance.BadgeText = tostring(math.floor(self.RemainingCount)) .. "/" .. tostring(math.floor(self.MaxCount))
        end
    end
    if self.CollectedCount == 0 then
        self.ItemInstance.BadgeTextColor = Layout:GetColorForAccessibility(AccessibilityLevel.Normal)
    else
        self.ItemInstance.BadgeTextColor = "WhiteSmoke"
    end
end

function ChestCounter:InvalidateAccessibility()
    --self.ItemInstance:InvalidateAccessibility()
end

function ChestCounter:Increment(count)
    count = count or 1
    self.CollectedCount = math.min(self.MaxCount, math.max(self.MinCount, self.CollectedCount + (self.CountIncrement * count)))
    return num
end

function ChestCounter:Decrement(count)
    count = count or 1
    self.CollectedCount = math.min(self.MaxCount, math.max(self.MinCount, self.CollectedCount - (self.CountIncrement * count)))
    return num
end

function ChestCounter:onLeftClick()
    self:Increment()
end

function ChestCounter:onRightClick()
    self:Decrement()
end

function ChestCounter:canProvideCode(code)
    if code == self.code then
        return true
    else
        return false
    end
end

function ChestCounter:providesCode(code)
    if code == self.code then
        return self.CollectedCount
    end
    return 0
end

function ChestCounter:advanceToCode(code)
    if code == nil or code == self.code then
        self:onLeftClick()
    end
end

function ChestCounter:save()
    local data = {}
    data["min_count"] = self.MinCount
    data["max_count"] = self.MaxCount
    data["collected_count"] = self.CollectedCount
    return data
end

function ChestCounter:load(data)
    if data["max_count"] ~= nil then
        self.MaxCount = data["max_count"]
    end
    if data["min_count"] ~= nil then
        self.MinCount = data["min_count"]
    end
    if data["collected_count"] ~= nil then
        local num = -1
        num = data["collected_count"]
        if num < 0 then
            return false
        end
        self.CollectedCount = data["collected_count"]
    end
    
    return true
end
