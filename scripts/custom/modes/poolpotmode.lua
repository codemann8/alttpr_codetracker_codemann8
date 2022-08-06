PoolPotMode = PoolMode:extend()

function PoolPotMode:init(altNum, item)
    self.itemCode = item:lower():gsub(" ", "")
    self.baseCode = "pool_" .. self.itemCode
    self.label = item .. " Shuffle"

    self:initSuffix(altNum)
    self:initCode()

    self:setCount(2)
    self:setState(0)

    if self.itemCode == "dungeonpot" then
        self:setCount(3)
    end
end

function PoolPotMode:onLeftClick()
    if self.suffix ~= "_small" then
        self.clicked = true
        self:setState((self:getState() + 1) % self:getCount())
    else
        if OBJ_POOL_DUNGEONPOT:getState() == OBJ_POOL_DUNGEONPOT:getCount() - 1 then
            OBJ_POOL_CAVEPOT:setStateExternal((OBJ_POOL_CAVEPOT:getState() + 1) % OBJ_POOL_CAVEPOT:getCount())
        end
        OBJ_POOL_DUNGEONPOT:setStateExternal((OBJ_POOL_DUNGEONPOT:getState() + 1) % OBJ_POOL_DUNGEONPOT:getCount())
    end
end

function PoolPotMode:onRightClick()
    if self.suffix ~= "_small" then
        self.clicked = true
        self:setState((self:getState() - 1) % self:getCount())
    else
        if OBJ_POOL_DUNGEONPOT:getState() == 0 then
            OBJ_POOL_CAVEPOT:setStateExternal((OBJ_POOL_CAVEPOT:getState() - 1) % OBJ_POOL_CAVEPOT:getCount())
        end
        OBJ_POOL_DUNGEONPOT:setStateExternal((OBJ_POOL_DUNGEONPOT:getState() - 1) % OBJ_POOL_DUNGEONPOT:getCount())
    end
end

function PoolPotMode:updateIcon()
    if self.suffix == "_small" and self.itemCode == "dungeonpot" then
        if OBJ_POOL_CAVEPOT == nil or OBJ_POOL_CAVEPOT:getState() == 0 then
            if OBJ_POOL_DUNGEONPOT:getState() == 0 then
                self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_cavekeypot_small.png", "@disabled")
            elseif OBJ_POOL_DUNGEONPOT:getState() == 1 then
                self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_keypot_small.png")
            else
                self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_dungeonpot_small.png")
            end
        else
            if OBJ_POOL_DUNGEONPOT:getState() == 0 then
                self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_cavepot_small.png")
            elseif OBJ_POOL_DUNGEONPOT:getState() == 1 then
                self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_cavekeypot_small.png")
            else
                self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_allpot_small.png")
            end
        end
    else
        itemCodeLocal = self.itemCode == "dungeonpot" and "keypot" or self.itemCode
        if self:getState() == 0 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_" .. itemCodeLocal .. self.suffix .. ".png", "@disabled")
        elseif self.itemCode == "dungeonpot" and self:getState() == 1 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_" .. itemCodeLocal .. self.suffix .. ".png")
        else
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_" .. self.itemCode .. self.suffix .. ".png")
        end
    end
end

function PoolPotMode:postUpdate()
    if self.itemCode == "dungeonpot" then
        updateChests()
    elseif self.itemCode == "cavepot" then
        Tracker:FindObjectForCode("pool_dungeonpot_small").ItemState:updateIcon()
    end
end

function PoolPotMode:providesCode(code)
    if self.suffix == "" then
        if self.baseCode ~= "pool_dungeonpot" then
            if code == self.baseCode .. "_off" and self:getState() == 0 then
                return 1
            elseif code == self.baseCode .. "_on" and self:getState() == 1 then
                return 1
            end
        else
            if code == "pool_keypot_off" and self:getState() == 0 then
                return 1
            elseif code == "pool_keypot_on" and self:getState() > 0 then
                return 1
            elseif code == "pool_dungeonpot_off" and self:getState() < 2 then
                return 1
            elseif code == "pool_dungeonpot_on" and self:getState() == 2 then
                return 1
            end
        end
    end
    return 0
end
