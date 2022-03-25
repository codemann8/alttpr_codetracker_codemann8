Setting = CustomItem:extend()

function Setting:init(name, code, file, textcode, count, default, current)
    default = default or (count > 2 and 1 or false)
    self:createItem(name)
    self.code = code
    self.file = file
    self.textcode = textcode
    self.count = count
    self.default = default

    if (count == 2 and type(current) ~= "boolean") or (count > 2 and type(current) ~= "number") then
        current = default
    end

    self:setState(current and current or default)
end

function Setting:setState(state)
    self:setProperty("state", state)
end

function Setting:getState()
    return self:getProperty("state")
end

function Setting:updateIcon()
    if self.count == 2 then
        if self:getState() then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/overlays/box-solid.png", "overlay|images/overlays/overlay-x.png")
        else
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/overlays/box-solid.png")
        end
    elseif self.code == "settings_broadcast_mapdirection" then
        if self:getState() == 1 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/overlays/box-solid.png", "overlay|images/icons/misc/arrow-left.png")
        elseif self:getState() == 2 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/overlays/box-solid.png", "overlay|images/icons/misc/arrow-up.png")
        elseif self:getState() == 3 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/overlays/box-solid.png", "overlay|images/icons/misc/arrow-right.png")
        elseif self:getState() == 4 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/overlays/box-solid.png", "overlay|images/icons/misc/arrow-down.png")
        else
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/overlays/box-solid.png", "overlay|images/overlays/overlay-x.png")
        end
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/overlays/box-solid.png", "overlay|images/doortracker/" .. math.floor(self:getState()) .. ".png")
    end
end

function Setting:updateSetting()
    if self.file == "defaults.lua" then
        if self.textcode == "CONFIG.PREFERENCE_DISPLAY_ALL_LOCATIONS" then
            CONFIG.PREFERENCE_DISPLAY_ALL_LOCATIONS = self:getState()
        elseif self.textcode == "CONFIG.PREFERENCE_ALWAYS_ALLOW_CLEARING_LOCATIONS" then
            CONFIG.PREFERENCE_ALWAYS_ALLOW_CLEARING_LOCATIONS = self:getState()
        elseif self.textcode == "CONFIG.PREFERENCE_PIN_LOCATIONS_ON_ITEM_CAPTURE" then
            CONFIG.PREFERENCE_PIN_LOCATIONS_ON_ITEM_CAPTURE = self:getState()
        elseif self.textcode == "CONFIG.PREFERENCE_AUTO_UNPIN_LOCATIONS_ON_CLEAR" then
            CONFIG.PREFERENCE_AUTO_UNPIN_LOCATIONS_ON_CLEAR = self:getState()
        elseif self.textcode == "CONFIG.PREFERENCE_DEFAULT_RACE_MODE_ON" then
            CONFIG.PREFERENCE_DEFAULT_RACE_MODE_ON = self:getState()
        elseif self.textcode == "CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING" then
            CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING = self:getState()
        end
    elseif self.file == "layout.lua" then
        if self.textcode == "CONFIG.LAYOUT_ENABLE_ALTERNATE_DUNGEON_VIEW" then
            CONFIG.LAYOUT_ENABLE_ALTERNATE_DUNGEON_VIEW = self:getState()
        elseif self.textcode == "CONFIG.LAYOUT_USE_THIN_HORIZONTAL_PANE" then
            CONFIG.LAYOUT_USE_THIN_HORIZONTAL_PANE = self:getState()
        elseif self.textcode == "CONFIG.LAYOUT_ROOM_SLOT_METHOD" then
            CONFIG.LAYOUT_ROOM_SLOT_METHOD = self:getState()
        end
    elseif self.file == "broadcast.lua" then
        if self.textcode == "CONFIG.BROADCAST_MAP_DIRECTION" then
            CONFIG.BROADCAST_MAP_DIRECTION = self:getState()
        elseif self.textcode == "CONFIG.BROADCAST_ALTERNATE_LAYOUT" then
            CONFIG.BROADCAST_ALTERNATE_LAYOUT = self:getState()
        end
    elseif self.file == "tracking.lua" then
        if self.textcode == "CONFIG.AUTOTRACKER_ENABLE_AUTOPIN_CURRENT_DUNGEON" then
            CONFIG.AUTOTRACKER_ENABLE_AUTOPIN_CURRENT_DUNGEON = self:getState()
        elseif self.textcode == "CONFIG.AUTOTRACKER_DISABLE_DUNGEON_ITEM_TRACKING" then
            CONFIG.AUTOTRACKER_DISABLE_DUNGEON_ITEM_TRACKING = self:getState()
        elseif self.textcode == "CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING" then
            CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING = self:getState()
        elseif self.textcode == "CONFIG.AUTOTRACKER_DISABLE_OWMIXED_TRACKING" then
            CONFIG.AUTOTRACKER_DISABLE_OWMIXED_TRACKING = self:getState()
        elseif self.textcode == "CONFIG.AUTOTRACKER_DISABLE_REGION_TRACKING" then
            CONFIG.AUTOTRACKER_DISABLE_REGION_TRACKING = self:getState()
        end
    elseif self.file == "fileio.lua" then
        if self.textcode == "CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_ITEM_FILE" then
            CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_ITEM_FILE = self:getState()
        elseif self.textcode == "CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_DUNGEON_IMAGE" then
            CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_DUNGEON_IMAGE = self:getState()
        elseif self.textcode == "CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_HEALTH_FILE" then
            CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_HEALTH_FILE = self:getState()
        end
    end
    if STATUS.TRACKER_READY then
        saveSettings(self)
    end
end

function Setting:onLeftClick()
    if self.count == 2 then
        self:setState(not self:getState())
    else
        self:setState((self:getState() % self.count) + 1)
    end
end

function Setting:onRightClick()
    if self.count == 2 then
        self:setState(not self:getState())
    else
        self:setState(((self:getState() - 2) % self.count) + 1)
    end
end

function Setting:canProvideCode(code)
    return code == self.code
end

function Setting:propertyChanged(key, value)
    if key == "state" then
        self:updateSetting()
        self:updateIcon()
        if STATUS.TRACKER_READY then
            updateLayout(self)
        end
    end
end
