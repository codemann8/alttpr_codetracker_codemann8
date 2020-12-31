DynamicRequirement = CustomItem:extend()

function DynamicRequirement:init(dungeonCode, imageCode, num, x, y)
    self:createItem("Dynamic Requirement")
    if (num == nil) then
        print(dungeonCode)
    end
    self.code = "dynreq_" .. dungeonCode .. num .. "_sur"
    self.dungeon = dungeonCode
    self.imageCode = imageCode
    self.num = num
    self.x = x
    self.y = y

    self.ItemInstance.MaskInput = true

    self:setState(0)
end

function DynamicRequirement:setState(state)
    self:setProperty("state", state)
end

function DynamicRequirement:getState()
    return self:getProperty("state")
end

function DynamicRequirement:updateIcon()
    local items = {
        [1] = "capture",
        [2] = "bow",
        [3] = "hookshot",
        [4] = "firerod",
        [5] = "lamp",
        [6] = "hammer",
        [7] = "somaria",
        [8] = "boots",
        [9] = "glove",
        [10] = "flippers",
        [11] = "sword"
    }

    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/base-transparent.png")
    else
        --Use below code if ImageReference:FromExternalURI becomes available
        --local url = "https://zelda.codemann8.com/tools/emoimage.php?item=" .. items[self:getState()] .. "&x=" .. self.x .. "&y=" .. self.y
        --self.ItemInstance.Icon = ImageReference:FromExternalURI(url)

        local imgPath = "images/dynreq/dynreq_" .. self.imageCode .. self.num .. "_" .. items[self:getState()] .. ".png"
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath(imgPath)
    end
end

function DynamicRequirement:onLeftClick()
    local doorrando = Tracker:FindObjectForCode("door_shuffle")
    local state = (self:getState() + 1) % 12

    if doorrando and doorrando.CurrentStage == 2 and state == 0 then
        state = 1
    end
    self:setState(state)
end

function DynamicRequirement:onRightClick()
    local doorrando = Tracker:FindObjectForCode("door_shuffle")
    local state = (self:getState() - 1) % 12

    if doorrando and doorrando.CurrentStage == 2 and state == 0 then
        state = 1
    end
    self:setState(state)
end

function DynamicRequirement:canProvideCode(code)
    if code == self.code then
        return true
    else
        return false
    end
end

function DynamicRequirement:providesCode(code)
    if code == self.code and self:getState() ~= 0 then
        return self:getState()
    end
    return 0
end

function DynamicRequirement:advanceToCode(code)
    if code == nil or code == self.code then
        self:setState((self:getState() + 1) % 12)
    end
end

function DynamicRequirement:save()
    local saveData = {}
    saveData["state"] = self:getState()
    return saveData
end

function DynamicRequirement:load(data)
    if data["state"] ~= nil then
        self:setState(data["state"])
    end
    return true
end

function DynamicRequirement:propertyChanged(key, value)
    if key == "state" then
        self:updateIcon()
    end
end
