DoorDungeonSelect = CustomItem:extend()

function DoorDungeonSelect:init()
    self:createItem("Door Rando Dungeon Selection")
    self.code = "door_dungeonselect"

    self:setState(0)
end

function DoorDungeonSelect:setState(state)
    self:setProperty("state", state)
end

function DoorDungeonSelect:getState()
    return self:getProperty("state")
end

function DoorDungeonSelect:updateIcon()
    if OBJ_DOORSHUFFLE ~= nil and OBJ_DOORSHUFFLE.CurrentStage == 2 then
        local dungeons = {
            [0] = "hc",
            [1] = "ep",
            [2] = "dp",
            [3] = "toh",
            [4] = "at",
            [5] = "pod",
            [6] = "sp",
            [7] = "sw",
            [8] = "tt",
            [9] = "ip",
            [10] = "mm",
            [11] = "tr",
            [12] = "gt"
        }
        local item = Tracker:FindObjectForCode(dungeons[self:getState()] .. "_item").ItemState
        OBJ_DOORCHEST.ItemState:setState(item.MaxCount)
        item = Tracker:FindObjectForCode(dungeons[self:getState()] .. "_smallkey")
        OBJ_DOORKEY.ItemState:setState(item.MaxCount)

        if self:getState() == 0 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/HC.png")
        elseif self:getState() == 1 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/EP.png")
        elseif self:getState() == 2 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/DP.png")
        elseif self:getState() == 3 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/TH.png")
        elseif self:getState() == 4 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/AT.png")
        elseif self:getState() == 5 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/PD.png")
        elseif self:getState() == 6 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/SP.png")
        elseif self:getState() == 7 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/SW.png")
        elseif self:getState() == 8 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/TT.png")
        elseif self:getState() == 9 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/IP.png")
        elseif self:getState() == 10 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/MM.png")
        elseif self:getState() == 11 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/TR.png")
        elseif self:getState() == 12 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/GT.png")
        end
    else
        self.ItemInstance.Icon = ""
    end
end

function DoorDungeonSelect:onLeftClick()
    if OBJ_DOORSHUFFLE.CurrentStage == 2 then
        self:setState((self:getState() + 1) % 13)
    end
end

function DoorDungeonSelect:onRightClick()
    if OBJ_DOORSHUFFLE.CurrentStage == 2 then
        self:setState((self:getState() - 1) % 13)
    end
end

function DoorDungeonSelect:canProvideCode(code)
    if code == self.code then
        return true
    else
        return false
    end
end

function DoorDungeonSelect:providesCode(code)
    if code == self.code and self:getState() ~= 0 then
        return self:getState()
    end
    return 0
end

function DoorDungeonSelect:advanceToCode(code)
    if code == nil or code == self.code then
        self:setState((self:getState() + 1) % 13)
    end
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
