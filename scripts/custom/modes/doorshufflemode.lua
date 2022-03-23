DoorShuffleMode = SurrogateItem:extend()

function DoorShuffleMode:init(isAlt)
    self.baseCode = "door_shuffle"
    self.label = "Door Shuffle"

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(3)
    self:setState(0)
end

function DoorShuffleMode:providesCode(code)
    if self.suffix == "" then
        if code == "door_shuffle_off" and self:getState() == 0 then
            return 1
        elseif code == "door_shuffle_on" and self:getState() > 0 then
            return 1
        elseif code == "door_shuffle_crossed" and self:getState() == 2 then
            return 1
        elseif code == "door_shuffle_sameset" and self:getState() < 2 then
            return 1
        elseif code == "door_shuffle_basic" and self:getState() == 1 then
            return 1
        end
    end
    return 0
end

function DoorShuffleMode:updateIcon()
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/door_shuffle_off" .. self.suffix .. ".png")
    elseif self:getState() == 1 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/door_shuffle_basic" .. self.suffix .. ".png")
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/door_shuffle_crossed" .. self.suffix .. ".png")
    end
end

function DoorShuffleMode:updateItem()
    local mirror = Tracker:FindObjectForCode("mirror")
    if mirror.CurrentStage == 0 then
        if self:getState() == 0 then
            --Unacquired Mirror Item
            mirror.Stages[mirror.CurrentStage].Icon = ImageReference:FromPackRelativePath("images/items/mirror.png", "@disabled")
            mirror.Icon = mirror.Stages[mirror.CurrentStage].Icon
        else
            --Enable Mirror Scroll Item
            mirror.Stages[mirror.CurrentStage].Icon = ImageReference:FromPackRelativePath("images/items/mirror-scroll.png")
            mirror.Icon = mirror.Stages[mirror.CurrentStage].Icon
        end
    end
end

function DoorShuffleMode:postUpdate()
    if CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING then
        print("Door shuffle mode changed")
    end
    
    updateChests()

    if self:getState() == 0 then
        INSTANCE.NEW_KEY_SYSTEM = false
    end

    if self:getState() == 2 then
        Tracker.AutoUnpinLocationsOnClear = false
        Layout:FindLayout("shared_doortotal_v_grid").Root.MaxWidth = -1
    else
        Tracker.AutoUnpinLocationsOnClear = CONFIG.PREFERENCE_AUTO_UNPIN_LOCATIONS_ON_CLEAR
        Layout:FindLayout("shared_doortotal_v_grid").Root.MaxWidth = 0
    end
end
