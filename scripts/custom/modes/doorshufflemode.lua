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
            --Update Dungeon Chest/Key Counts
            for i = 1, #DungeonList do
                local item = Tracker:FindObjectForCode(DungeonList[i] .. "_item").ItemState
                local key = Tracker:FindObjectForCode(DungeonList[i] .. "_smallkey")
                if item.MaxCount ~= 99 then
                    item.MaxCount = 99
                    item.AcquiredCount = 99
                end
                item.SwapActions = true
                key.MaxCount = 99
                key.Icon = ImageReference:FromPackRelativePath("images/SmallKey2.png", "@disabled")

                if (OBJ_POOL_KEYDROP.CurrentStage == 0 and DungeonList[i] == "hc") or DungeonList[i] == "at" then
                    Tracker:FindObjectForCode(DungeonList[i] .. "_bigkey").Icon = ImageReference:FromPackRelativePath("images/BigKey.png", "@disabled")
                end
            end
        end

        updateIcons()

        if self:getState() == 0 then
            NEW_KEY_SYSTEM = false
        end

        if self:getState() == 2 then
            Tracker.AutoUnpinLocationsOnClear = false

            --Default Entrance Mode to Dungeon if Crossed Door is selected
            if OBJ_ENTRANCE.CurrentStage == 0 then
                Tracker:FindObjectForCode("entrance_shuffle_surrogate").ItemState:setState(1)
            end
        else
            Tracker.AutoUnpinLocationsOnClear = PREFERENCE_AUTO_UNPIN_LOCATIONS_ON_CLEAR
        end
    end
end
