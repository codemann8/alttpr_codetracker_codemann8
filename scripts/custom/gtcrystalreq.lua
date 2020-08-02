GTCrystalReq = class(CustomItem)

function GTCrystalReq:init()
	self:createItem("GT Crystal Requirement")
    self.code = "gt_crystals_surrogate"
    self.ItemInstance.Name = "GT Crystal Requirement"
    
    self:setState(8)
end

function GTCrystalReq:setState(state)
	self:setProperty("state", state)
end

function GTCrystalReq:getState()
	return self:getProperty("state")
end

function GTCrystalReq:updateIcon()
    local item = Tracker:FindObjectForCode("gt_crystals")
    
	if self:getState() == 8 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/GTSign.png", "overlay|images/overlayNA.png")
        item.AcquiredCount = 7
    else
        if self:getState() == 0 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/GTSign.png", "overlay|images/overlay0.png")
        elseif self:getState() == 1 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/GTSign.png", "overlay|images/overlay1.png")
        elseif self:getState() == 2 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/GTSign.png", "overlay|images/overlay2.png")
        elseif self:getState() == 3 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/GTSign.png", "overlay|images/overlay3.png")
        elseif self:getState() == 4 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/GTSign.png", "overlay|images/overlay4.png")
        elseif self:getState() == 5 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/GTSign.png", "overlay|images/overlay5.png")
        elseif self:getState() == 6 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/GTSign.png", "overlay|images/overlay6.png")
        elseif self:getState() == 7 then
            self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/GTSign.png", "overlay|images/overlay7.png")
        end
        item.AcquiredCount = self:getState()
    end
end

function GTCrystalReq:onLeftClick()
	self:setState((self:getState() - 1) % 9)
end

function GTCrystalReq:onRightClick()
	self:setState((self:getState() + 1) % 9)
end

function GTCrystalReq:canProvideCode(code)
	if code == self.code then
		return true
	else
		return false
	end
end

function GTCrystalReq:providesCode(code)
	if code == self.code and self:getState() ~= 0 then
		return self:getState()
	end
	return 0
end

function GTCrystalReq:advanceToCode(code)
	if code == nil or code == self.code then
		self:setState((self:getState() + 1) % 9)
	end
end

function GTCrystalReq:save()
	local saveData = {}
	saveData["state"] = self:getState()
	return saveData
end

function GTCrystalReq:load(data)
	if data["state"] ~= nil then
		self:setState(data["state"])
	end
	return true
end

function GTCrystalReq:propertyChanged(key, value)
	if key == "state" then
		self:updateIcon()
	end
end