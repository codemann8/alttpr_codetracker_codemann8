DungeonPrize = CustomItem:extend()
DungeonPrize.UnknownIcon = ImageReference:FromPackRelativePath("images/dungeon/prize-unknown.png")
DungeonPrize.CrystalIcon = ImageReference:FromPackRelativePath("images/dungeon/prize-crystal.png")
DungeonPrize.CrystalRedIcon = ImageReference:FromPackRelativePath("images/dungeon/prize-crystal56.png")
DungeonPrize.PendantIcon = ImageReference:FromPackRelativePath("images/dungeon/prize-pendant.png")
DungeonPrize.PendantGreenIcon = ImageReference:FromPackRelativePath("images/dungeon/prize-greenpendant.png")

function DungeonPrize:init(name, code, verboseCode)
    self:createItem(name)
    self.code = code
    self.verboseCode = verboseCode
    self.DungeonOverlay = "images/overlays/dungeons/" .. code

    self:setBoss(false)
    self:setState(0)
end

function DungeonPrize:getState()
    return self:getProperty("state")
end

function DungeonPrize:setState(state)
    self:setProperty("state", state)
end

function DungeonPrize:getBoss()
    return self:getProperty("bossDefeated")
end

function DungeonPrize:setBoss(state)
    if MODES["keysanity_prize"]:getState() == 0 then
        self.PrizeCollected = state
    end
    self:setProperty("bossDefeated", state)
end

function DungeonPrize:UpdateIcon()
    local prizeIcon = DungeonPrize.UnknownIcon
    if self:getState() == 1 then
        prizeIcon = DungeonPrize.CrystalIcon
    elseif self:getState() == 2 then
        prizeIcon = DungeonPrize.CrystalRedIcon
    elseif self:getState() == 3 then
        prizeIcon = DungeonPrize.PendantIcon
    elseif self:getState() == 4 then
        prizeIcon = DungeonPrize.PendantGreenIcon
    end
    if not self.PrizeCollected or MODES["keysanity_prize"]:getState() > 0 then
        prizeIcon = ImageReference:FromImageReference(prizeIcon, "@disabled")
    end
    if self:getBoss() then
        self.ItemInstance.Icon = ImageReference:FromImageReference(prizeIcon, "overlay|" .. self.DungeonOverlay .. ".png")
    else
        self.ItemInstance.Icon = ImageReference:FromImageReference(prizeIcon, "overlay|" .. self.DungeonOverlay .. "-disabled.png")
    end
end

function DungeonPrize:onLeftClick()
    self:setBoss(not self:getBoss())
end

function DungeonPrize:onRightClick()
    self:setState((self:getState() + 1) % 5)
end

function DungeonPrize:canProvideCode(code)
    if code == self.code or code == self.verboseCode then
        return true
    else
        return false
    end
end

function DungeonPrize:providesCode(code)
    if code == self.code or code == self.verboseCode then
        return (self:getBoss() and 1 or 0)
    elseif self.PrizeCollected and MODES["keysanity_prize"]:getState() == 0 then
        if code == "prize" then
            return 1
        elseif code == "crystal" then
            return ((self:getState() == 1 or self:getState() == 2) and 1 or 0)
        elseif code == "pendant" then
            return ((self:getState() == 3 or self:getState() == 4) and 1 or 0)
        elseif code == "crystal56" or code == "redcrystal" then
            return ((self:getState() == 2) and 1 or 0)
        elseif code == "greenpendant" then
            return ((self:getState() == 4) and 1 or 0)
        end
    end
    return 0
end

function DungeonPrize:advanceToCode(code)
    if code == nil or code == self.code then
        self:onLeftClick()
    end
end

function DungeonPrize:save()
    local data = {
        ["state"] = self:getState(),
        ["bossDefeated"] = self:getBoss(),
        ["prizeCollected"] = self.PrizeCollected
    }
    return data
end

function DungeonPrize:load(data)
    if data["state"] ~= nil then
        self:setState(data["state"])
    end
    if data["bossDefeated"] ~= nil then
        self:setBoss(data["bossDefeated"])
    end
    if data["prizeCollected"] ~= nil then
        self.PrizeCollected = data["prizeCollected"]
    end
    return true
end

function DungeonPrize:propertyChanged(key, value)
    self:UpdateIcon()
end
