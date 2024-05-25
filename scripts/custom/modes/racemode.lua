RaceMode = SurrogateItem:extend()

function RaceMode:init(isAlt)
    self.baseCode = "race_mode"
    self.label = "Race Mode"

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(2)
    self:setState(0)
end

function RaceMode:updateIcon()
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/race_off" .. self.suffix .. ".png")
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/race_on" .. self.suffix .. ".png")
    end
    self:updateText(nil)
end

function RaceMode:updateText(collection)
    if self.suffix == "_small" then
        collection = collection or CACHE.CollectionRate
        self.ItemInstance.BadgeText = tostring(math.floor(collection))
    end
end
