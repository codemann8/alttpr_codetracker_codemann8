GlitchMode = SurrogateItem:extend()

function GlitchMode:init(isAlt)
    self.baseCode = "glitch_mode"
    self.label = "Glitch Logic"

    self:initSuffix(isAlt)
    self:initCode()

    self:setCount(4)
    self:setState(0)
end

function GlitchMode:providesCode(code)
    if self.suffix == "" then
        if code == "glitch_mode_none" and self:getState() == 0 then
            return 1
        elseif code == "glitch_mode_owg" and self:getState() > 0 then
            return 1
        elseif code == "glitch_mode_hybrid" and self:getState() > 1 then
            return 1
        elseif code == "glitch_mode_major" and self:getState() == 3 then
            return 1
        end
    end
    return 0
end

function GlitchMode:updateIcon()
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/glitches_none" .. self.suffix .. ".png")
    elseif self:getState() == 1 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/glitches_ow" .. self.suffix .. ".png")
    elseif self:getState() == 2 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/glitches_hybrid" .. self.suffix .. ".png")
    else
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/modes/glitches_major" .. self.suffix .. ".png")
    end
end
