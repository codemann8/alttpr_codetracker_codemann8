WorldStateMode = SurrogateItem:extend()

function WorldStateMode:init(isAlt)
    self.baseCode = "world_state_mode"
    self.label = "World State"

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(2)
    self:setState(0)
    self:setProperty("version", 0)
end

function WorldStateMode:onRightClick()
    self.clicked = true
    self.ignorePostUpdate = true
    self:setProperty("version", (self:getProperty("version") + 1) % 2)
end

function WorldStateMode:updateSurrogate()
    if self.linkedItem and not self.linkedItem.clicked then
        self.linkedItem:setState(self:getState())
        self.linkedItem:setProperty("version", self:getProperty("version"))
    end
end

function WorldStateMode:providesCode(code)
    if self.suffix == "" then
        if code == "world_state_open" and self:getState() == 0 then
            return 1
        elseif code == "world_state_inverted" and self:getState() == 1 then
            return 1
        elseif code == "inverted_orig" and self:getProperty("version") == 0 then
            return 1
        elseif code == "inverted_new" and self:getProperty("version") == 1 then
            return 1
        end
    end
    return 0
end

function WorldStateMode:updateIcon()
    local overlay = ""
    if self:getProperty("version") == 1 then
        overlay = "overlay|images/modes/world_state_inverted2" .. self.suffix .. ".png"
    end

    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/world_state_open" .. self.suffix .. ".png", overlay)
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/world_state_inverted" .. self.suffix .. ".png", overlay)
    end
end

function WorldStateMode:postUpdate()
    for i = 1, #DATA.OverworldIds do
        local item = Tracker:FindObjectForCode("ow_swapped_" .. string.format("%02x", DATA.OverworldIds[i])).ItemState
        item.clicked = true
        item.ignorePostUpdate = true

        if item:getState() > 1 then --if tile is currently unknown
            item:setStateExternal(self:getState() == 0 and 3 or 2)
        else
            item:setStateExternal((item:getState() + 1) % item:getCount())
        end
    end
end

function WorldStateMode:save()
    local data = {
        ["state"] = self:getState(),
        ["version"] = self:getProperty("version")
    }
    return data
end

function WorldStateMode:load(data)
    if data["state"] ~= nil then
        self:setState(data["state"])
    end
    if data["version"] ~= nil then
        self:setProperty("version", data["version"])
    end
    return true
end

function WorldStateMode:propertyChanged(key, value)
    if key == "state" or key == "version" then
        self:performUpdate()
    end
end
