DoorShuffleMode = CustomItem:extend()

function DoorShuffleMode:init(suffix)
    self:createItem("Door Shuffle" .. suffix)
    self.code = "door_shuffle_surrogate"
    self.suffix = suffix

    self:setState(0)
end

function DoorShuffleMode:setState(state)
    self:setProperty("state", state)
end

function DoorShuffleMode:getState()
    return self:getProperty("state")
end

function DoorShuffleMode:updateIcon()
    Tracker:FindObjectForCode("door_shuffle").CurrentStage = self:getState()

    local mirror = Tracker:FindObjectForCode("mirror")
    local item = Tracker:FindObjectForCode("gt_bkgame")

    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_door_shuffle_off" .. self.suffix .. ".png")
        item.MaxCount = 22
        if mirror.CurrentStage == 0 then
            mirror.Stages[mirror.CurrentStage].Icon = ImageReference:FromPackRelativePath("images/0018.png", "@disabled")
            mirror.Icon = ImageReference:FromPackRelativePath("images/0018.png", "@disabled")
        end
    elseif self:getState() == 1 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_door_shuffle_basic" .. self.suffix .. ".png")
        item.MaxCount = 27
        if mirror.CurrentStage == 0 then
            mirror.Stages[mirror.CurrentStage].Icon = ImageReference:FromPackRelativePath("images/mirrorscroll.png")
            mirror.Icon = ImageReference:FromPackRelativePath("images/mirrorscroll.png")
        end
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_door_shuffle_crossed" .. self.suffix .. ".png")
        item.MaxCount = 99
        if mirror.CurrentStage == 0 then
            mirror.Stages[mirror.CurrentStage].Icon = ImageReference:FromPackRelativePath("images/mirrorscroll.png")
            mirror.Icon = ImageReference:FromPackRelativePath("images/mirrorscroll.png")
        end
    end

    --Sync other surrogates
    local state = -1
    if self.suffix == "" then
        item = Tracker:FindObjectForCode(self.code .. "_small")
        if item then
            state = item:ProvidesCode(self.code .. "_small")
        end
    else
        item = Tracker:FindObjectForCode(self.code)
        if item then
            state = item:ProvidesCode(self.code)
        end
    end
    if item and self:getState() ~= state then
        if (self:getState() - state) % 3 == 1 then
            item:OnLeftClick()
        else
            item:OnRightClick()
        end
    end

    if self.suffix == "" and OBJ_KEYSANITY_BIG and OBJ_DOORSHUFFLE then
        if OBJ_DOORSHUFFLE.CurrentStage == 2 then
            local message = "NEW FEATURE: For Crossed Door Rando, new icons have been added to the lower right of the Dungeons section."
            message = message .. "\n\nThe Dungeon Selector icon will cycle thru each dungeon and Total Chests icon will set the total number of chests for that particular dungeon."
            message = message .. " Left click will increment the total chests and right click will reset it to 'unknown amount'."
            ScriptHost:PushMarkdownNotification(NotificationType.Message, message)
        end

        updateIcons()
    end
end

function DoorShuffleMode:onLeftClick()
    self:setState((self:getState() + 1) % 3)
end

function DoorShuffleMode:onRightClick()
    self:setState((self:getState() - 1) % 3)
end

function DoorShuffleMode:canProvideCode(code)
    if code == self.code .. self.suffix then
        return true
    else
        return false
    end
end

function DoorShuffleMode:providesCode(code)
    if code == self.code .. self.suffix and self:getState() ~= 0 then
        return self:getState()
    end
    return 0
end

function DoorShuffleMode:advanceToCode(code)
    if code == nil or code == self.code .. self.suffix then
        self:setState((self:getState() + 1) % 3)
    end
end

function DoorShuffleMode:save()
    return {}
end

function DoorShuffleMode:load(data)
    local item = Tracker:FindObjectForCode("door_shuffle")
    self:setState(item.CurrentStage)
    return true
end

function DoorShuffleMode:propertyChanged(key, value)
    if key == "state" then
        self:updateIcon()
    end
end
