DoorShuffleMode = SurrogateItem:extend()

function DoorShuffleMode:init(isAlt)
    self.baseCode = "door_shuffle"
    self.label = "Door Shuffle"

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(3)
    self:setState(0)
end

function DoorShuffleMode:updateIcon()
    local mirror = Tracker:FindObjectForCode("mirror")

    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_door_shuffle_off" .. self.suffix .. ".png")
        if mirror.CurrentStage == 0 then
            mirror.Stages[mirror.CurrentStage].Icon = ImageReference:FromPackRelativePath("images/0018.png", "@disabled")
            mirror.Icon = ImageReference:FromPackRelativePath("images/0018.png", "@disabled")
        end
    elseif self:getState() == 1 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_door_shuffle_basic" .. self.suffix .. ".png")
        if mirror.CurrentStage == 0 then
            mirror.Stages[mirror.CurrentStage].Icon = ImageReference:FromPackRelativePath("images/mirrorscroll.png")
            mirror.Icon = ImageReference:FromPackRelativePath("images/mirrorscroll.png")
        end
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_door_shuffle_crossed" .. self.suffix .. ".png")
        if mirror.CurrentStage == 0 then
            mirror.Stages[mirror.CurrentStage].Icon = ImageReference:FromPackRelativePath("images/mirrorscroll.png")
            mirror.Icon = ImageReference:FromPackRelativePath("images/mirrorscroll.png")
        end
    end
end

function DoorShuffleMode:postUpdate()
    if self.suffix == "" then
        if OBJ_DOORSHUFFLE and OBJ_DOORSHUFFLE.CurrentStage == 2 then
            local message = "NEW FEATURE: For Crossed Door Rando, new icons have been added to the lower right of the Dungeons section."
            message = message .. "\n\nThe Dungeon Selector icon will cycle thru each dungeon and Total Chests icon will set the total number of chests for that particular dungeon."
            message = message .. " Left click will increment the total chests and right click will reset it to 'unknown amount'."
            ScriptHost:PushMarkdownNotification(NotificationType.Message, message)
        end

        updateIcons()

        if self:getState() == 0 then
            NEW_KEY_SYSTEM = false
        end

        if self:getState() == 2 then
            Tracker.AutoUnpinLocationsOnClear = false
            if OBJ_ENTRANCE.CurrentStage == 0 then
                Tracker:FindObjectForCode("entrance_shuffle_surrogate").ItemState:setState(1)
            end
        else
            Tracker.AutoUnpinLocationsOnClear = PREFERENCE_AUTO_UNPIN_LOCATIONS_ON_CLEAR
        end
    end
end
