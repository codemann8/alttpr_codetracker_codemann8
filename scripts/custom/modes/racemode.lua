RaceMode = SurrogateItem:extend()

function RaceMode:init(isAlt)
    self.baseCode = "race_mode"
    self.label = "Race Mode"

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(2)
    self:setState(0)
end

function RaceMode:updateIcon()
    local item = Tracker:FindObjectForCode("gt_bkgame")

    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_race_off" .. self.suffix .. ".png")
        item.DisplayAsFractionOfMax = true
        item.DisplayAsFractionOfMax = false
        item.IgnoreUserInput = false;
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_race_on" .. self.suffix .. ".png")
        item.Icon = ImageReference:FromPackRelativePath("images/race-flag.png")
        item.BadgeText = nil
        item.IgnoreUserInput = true;
    end
end
