DoorDungeonSelect = CustomItem:extend()

function DoorDungeonSelect:init()
    self:createItem("Door Rando Dungeon Selection")
    self.code = "door_dungeonselect"

    self:setState(1)
end

function DoorDungeonSelect:setState(state)
    self:setProperty("state", state)
end

function DoorDungeonSelect:getState()
    return self:getProperty("state")
end

function DoorDungeonSelect:updateIcon()
    if OBJ_DOORSHUFFLE:getState() == 2 or OBJ_POOL_DUNGEONPOT:getState() > 1 then
        local item = Tracker:FindObjectForCode(DATA.DungeonList[self:getState()] .. "_item").ItemState
        OBJ_DOORCHEST:setState(item.MaxCount)
        item = Tracker:FindObjectForCode(DATA.DungeonList[self:getState()] .. "_smallkey")
        OBJ_DOORKEY:setState(item.MaxCount)

        if self:getState() == 1 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/dungeon/HC.png")
        elseif self:getState() == 2 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/dungeon/EP.png")
        elseif self:getState() == 3 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/dungeon/DP.png")
        elseif self:getState() == 4 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/dungeon/TH.png")
        elseif self:getState() == 5 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/dungeon/AT.png")
        elseif self:getState() == 6 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/dungeon/PD.png")
        elseif self:getState() == 7 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/dungeon/SP.png")
        elseif self:getState() == 8 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/dungeon/SW.png")
        elseif self:getState() == 9 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/dungeon/TT.png")
        elseif self:getState() == 10 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/dungeon/IP.png")
        elseif self:getState() == 11 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/dungeon/MM.png")
        elseif self:getState() == 12 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/dungeon/TR.png")
        elseif self:getState() == 13 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/dungeon/GT.png")
        end
    else
        self.ItemInstance.Icon = ""
    end
end

function DoorDungeonSelect:onLeftClick()
    if OBJ_DOORSHUFFLE:getState() == 2 or OBJ_POOL_DUNGEONPOT:getState() > 1 then
        self:setState((self:getState()) % 13 + 1)
    end
end

function DoorDungeonSelect:onRightClick()
    if OBJ_DOORSHUFFLE:getState() == 2 or OBJ_POOL_DUNGEONPOT:getState() > 1 then
        self:setState((self:getState() - 2) % 13 + 1)
    end
end

function DoorDungeonSelect:canProvideCode(code)
    return code == self.code
end

function DoorDungeonSelect:save()
    return {}
end

function DoorDungeonSelect:load(data)
    self:updateIcon()
    return true
end

function DoorDungeonSelect:propertyChanged(key, value)
    if key == "state" then
        self:updateIcon()
    end
end
