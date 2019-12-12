MapCompassBK = class(CustomItem)

function MapCompassBK:init(name, dungeonCode)
	self:createItem(name)
	self.code = dungeonCode .. "_mcbk"
	self:setProperty("dungeon", dungeonCode)
	self:setProperty("state", 0)
	self.activeImage = ImageReference:FromPackRelativePath("images/mapcompassbigKey000.png")
	--self.disabledImage = ImageReference:FromImageReference(self.activeImage, "@disabled")
	self.ItemInstance.PotentialIcon = self.activeImage

	self:updateIcon()		
end

function MapCompassBK:setState(state)
	self:setProperty("state", state)
end

function MapCompassBK:getState()
	return self:getProperty("state")
end

function MapCompassBK:updateIcon()
	if self:getState() < 4 then
		if self:getState() < 2 then
			if self:getState() < 1 then
				self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mapcompassbigKey000.png")
			else
				self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mapcompassbigKey001.png")
			end
		else
			if self:getState() < 3 then
				self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mapcompassbigKey010.png")
			else
				self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mapcompassbigKey011.png")
			end
		end
	else
		if self:getState() < 6 then
			if self:getState() < 5 then
				self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mapcompassbigKey100.png")
			else
				self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mapcompassbigKey101.png")
			end
		else
			if self:getState() < 7 then
				self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mapcompassbigKey110.png")
			else
				self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mapcompassbigKey111.png")
			end
		end
	end
end

function MapCompassBK:onLeftClick()
	local newState = (self:getState() + 4) % 8
		
	local item = Tracker:FindObjectForCode(self:getProperty("dungeon") .. "_bigkey")
	if item then
		self:setState(newState)
		
		item.Active = newState & 0x4 > 0
	end
end

function MapCompassBK:onRightClick()
	local newState = (self:getState() & 0x4) + ((self:getState() & 0x3) + 1) % 4
	
	if math.abs(newState - self:getState()) & 0x1 == 1 then
		local item = Tracker:FindObjectForCode(self:getProperty("dungeon") .. "_compass")
		
		if item then
			self:setState(newState)
			
			item.Active = newState & 0x1 > 0
		else
			newState = (newState & 0x4) + ((newState & 0x3) + 1) % 4
		end
	end
		
	if math.abs(newState - self:getState()) & 0x2 == 2 then
		local item = Tracker:FindObjectForCode(self:getProperty("dungeon") .. "_map")
		
		if item then
			self:setState(newState)
			
			item.Active = newState & 0x2 > 0
		else
			newState = (newState & 0x4) + ((newState & 0x3) + 1) % 4
		end
	end
end

function MapCompassBK:canProvideCode(code)
	if code == self.code then
		return true
	else
		return false
	end
end

function MapCompassBK:providesCode(code)
	if code == self.code and self:getState() ~= 0 then
		return 1
	end
	return 0
end

function MapCompassBK:advanceToCode(code)
	if code == nil or code == self.code then
		self:setState((self:getState() + 1) % 8)
	end
end

function MapCompassBK:save()
	local saveData = {}
	saveData["state"] = self.getState()
	return saveData
end

function MapCompassBK:Load(data)
	if data["state"] ~= nil then
		self:setState(data["state"])
	end
	return true
end

function MapCompassBK:propertyChanged(key, value)
		if key == "state" then
		self:updateIcon()
	end
end