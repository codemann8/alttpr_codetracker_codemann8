WorldStateMode = SurrogateItem:extend()

function WorldStateMode:init(isAlt)
    self.baseCode = "world_state_mode"
    self.label = "World State"

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(2)
    self:setState(0)
end

function WorldStateMode:updateIcon()
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_world_state_open" .. self.suffix .. ".png")
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_world_state_inverted" .. self.suffix .. ".png")
    end
end
