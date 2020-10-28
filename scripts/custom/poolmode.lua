PoolMode = SurrogateItem:extend()

function PoolMode:init(isAlt)
    self.baseCode = "pool_mode"
    self.label = "Pool Mode"

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(2)
    self:setState(0)
end

function PoolMode:postUpdate()
    if self.suffix == "" and OBJ_KEYSANITY_BIG and OBJ_DOORSHUFFLE then
        updateIcons()
    end
end

function PoolMode:updateIcon()
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_pool_chest" .. self.suffix .. ".png")
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_pool_chestkeydrop" .. self.suffix .. ".png")
    end
end
