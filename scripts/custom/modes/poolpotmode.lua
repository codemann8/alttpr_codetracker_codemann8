PoolPotMode = PoolMode:extend()

function PoolPotMode:init(altNum, item)
    self.itemCode = item:lower():gsub(" ", "")
    self.baseCode = "pool_" .. self.itemCode
    self.label = item .. " Shuffle"

    self.linkedSetting = Tracker:FindObjectForCode(self.baseCode .. "_off")

    self:initSuffix(altNum)
    self:initCode()

    self:setCount(2)
    self:setState(0)

    if self.itemCode == "dungeonpot" then
        self:setCount(4)
    end
end

function PoolPotMode:onLeftClick()
    if self.suffix ~= "_small" then
        self.clicked = true
        self:setState((self:getState() + 1) % self:getCount())
    else
        OBJ_POOL_DUNGEONPOT:setStateExternal((OBJ_POOL_DUNGEONPOT:getState() + 1) % OBJ_POOL_DUNGEONPOT:getCount())
    end
end

function PoolPotMode:onRightClick()
    if self.suffix ~= "_small" then
        self.clicked = true
        self:setState((self:getState() - 1) % self:getCount())
    else
        OBJ_POOL_CAVEPOT:setStateExternal((OBJ_POOL_CAVEPOT:getState() + 1) % OBJ_POOL_CAVEPOT:getCount())
    end
end

function PoolPotMode:updateIcon()
    if self.suffix == "_small" and self.itemCode == "dungeonpot" then
        if OBJ_POOL_CAVEPOT == nil or OBJ_POOL_CAVEPOT:getState() == 0 then
            if OBJ_POOL_DUNGEONPOT:getState() == 0 then
                self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_cavekeypot_small.png", "@disabled")
            elseif OBJ_POOL_DUNGEONPOT:getState() == 1 then
                self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_keypot_small.png")
            elseif OBJ_POOL_DUNGEONPOT:getState() == 2 then
                self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_variedpot_small.png")
            else
                self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_dungeonpot_small.png")
            end
        else
            if OBJ_POOL_DUNGEONPOT:getState() == 0 then
                self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_cavepot_small.png")
            elseif OBJ_POOL_DUNGEONPOT:getState() == 1 then
                self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_cavekeypot_small.png")
            elseif OBJ_POOL_DUNGEONPOT:getState() == 2 then
                self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_cavevariedpot_small.png")
            else
                self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_allpot_small.png")
            end
        end
    else
        itemCodeLocal = self.itemCode == "dungeonpot" and (self:getState() == 2 and "variedpot" or "keypot") or self.itemCode
        if self:getState() == 0 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_" .. itemCodeLocal .. self.suffix .. ".png", "@disabled")
        elseif self.itemCode == "dungeonpot" and (self:getState() == 1 or self:getState() == 2) then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_" .. itemCodeLocal .. self.suffix .. ".png")
        else
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/pool_" .. self.itemCode .. self.suffix .. ".png")
        end
    end
end

function PoolPotMode:postUpdate()
    if self.linkedSetting then
        self.linkedSetting.CurrentStage = self:getState()
    end

    if self.itemCode == "dungeonpot" then
        updateChests()

        if shouldChestCountUp() then
            Tracker.AutoUnpinLocationsOnClear = false
            Layout:FindLayout("shared_doortotal_v_grid").Root.MaxWidth = -1
        else
            Tracker.AutoUnpinLocationsOnClear = CONFIG.PREFERENCE_AUTO_UNPIN_LOCATIONS_ON_CLEAR
            Layout:FindLayout("shared_doortotal_v_grid").Root.MaxWidth = 0
        end
    elseif self.itemCode == "cavepot" then
        Tracker:FindObjectForCode("pool_dungeonpot_small").ItemState:updateIcon()
    end
end

function PoolPotMode:providesCode(code)
    return 0
end
