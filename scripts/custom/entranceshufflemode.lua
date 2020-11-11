EntranceShuffleMode = SurrogateItem:extend()

function EntranceShuffleMode:init(isAlt)
    self.baseCode = "entrance_shuffle"
    self.label = "Entrance Shuffle"

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(3)
    self:setState(0)
end

function EntranceShuffleMode:updateIcon()
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_entrance_shuffle_off" .. self.suffix .. ".png")
    elseif self:getState() == 1 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_entrance_shuffle_on" .. self.suffix .. ".png")
    else 
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_entrance_shuffle_insanity" .. self.suffix .. ".png")
    end
end

function EntranceShuffleMode:postUpdate()
    if self.suffix == "" then
        local drops =  { "swpinball", "swcompass", "swbigchest", "swhazard" }
        for i = 1, #drops do
            local drop = Tracker:FindObjectForCode("dropdown_" .. drops[i])
            if self:getState() > 1 then
                drop.ActiveIcon = drop.ActiveIcon
                drop.IgnoreUserInput = false
            else
                drop.Icon = ""
                drop.IgnoreUserInput = true
            end
        end

        --Change Dropdown Capture Layouts
        for i = 1, #CaptureBadgeDropdowns do
            local drop = Tracker:FindObjectForCode(CaptureBadgeDropdowns[i])
            if self:getState() > 1 then
                drop.ItemCaptureLayout = "tracker_capture_dropdown_insanity"
            else
                drop.ItemCaptureLayout = "tracker_capture_dropdown"
            end
        end
    end
end
