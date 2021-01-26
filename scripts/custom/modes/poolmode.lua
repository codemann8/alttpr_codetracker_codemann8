PoolMode = SurrogateItem:extend()

function PoolMode:init(altNum, item)
    self.itemCode = item:lower():gsub(" ", "")
    self.baseCode = "pool_" .. self.itemCode
    self.label = item .. " Shuffle"

    self:initSuffix(altNum)
    self:initCode()

    self:setCount(2)
    
    self:setState(0)
end

function PoolMode:initSuffix(altNum)
    if altNum == 2 then
        self.suffix = "_base"
    elseif altNum == 1 then
        self.suffix = "_small"
    else
        self.suffix = ""
    end
end

function PoolMode:updateIcon()
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_pool_" .. self.itemCode .. self.suffix .. ".png", "@disabled")
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_pool_" .. self.itemCode .. self.suffix .. ".png")
    end
end

function PoolMode:postUpdate()
    if self.suffix == "" and OBJ_KEYSANITY_BIG and OBJ_DOORSHUFFLE then
        updateIcons()
    end
end
