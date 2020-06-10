KeysanityMode = class(CustomItem)

function KeysanityMode:init(variant, suffix)
	self:createItem("Dungeon Items")
	self.code = "keysanity_mode_surrogate"
	self.suffix = suffix

	if variant == "items_only_keys" then
		self:setState(3)
	else
		self:setState(0)
	end
end

function KeysanityMode:setState(state)
	self:setProperty("state", state)
end

function KeysanityMode:getState()
	return self:getProperty("state")
end

function KeysanityMode:updateIcon()
	local item = Tracker:FindObjectForCode("keysanity_mode")
	item.CurrentStage = self:getState()

	if self:getState() == 0 then
		self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_keysanity_standard" .. self.suffix .. ".png")
		self.ItemInstance.Name = "Standard"
	elseif self:getState() == 1 then
		self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_keysanity_mapsanity" .. self.suffix .. ".png")
		self.ItemInstance.Name = "Mapsanity"
	elseif self:getState() == 2 then
		self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_keysanity_smallsanity" .. self.suffix .. ".png")
		self.ItemInstance.Name = "Smallsanity"
	else
		self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_keysanity_full" .. self.suffix .. ".png")
		self.ItemInstance.Name = "Full Keysanity"
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
		if (self:getState() - state) % 4 == 1 then
			item:OnLeftClick()
		else
			item:OnRightClick()
		end
	end

	local doorrando = Tracker:FindObjectForCode("door_shuffle")
	updateIcons(self:getState(), doorrando.CurrentStage)
end

function KeysanityMode:onLeftClick()
	self:setState((self:getState() + 1) % 4)
end

function KeysanityMode:onRightClick()
	self:setState((self:getState() - 1) % 4)
end

function KeysanityMode:canProvideCode(code)
	if code == self.code .. self.suffix then
		return true
	else
		return false
	end
end

function KeysanityMode:providesCode(code)
	if code == self.code .. self.suffix and self:getState() ~= 0 then
		return self:getState()
	end
	return 0
end

function KeysanityMode:advanceToCode(code)
	if code == nil or code == self.code .. self.suffix then
		self:setState((self:getState() + 1) % 4)
	end
end

function KeysanityMode:save()
	return { }
end

function KeysanityMode:load(data)
	local item = Tracker:FindObjectForCode("keysanity_mode")
	self:setState(item.CurrentStage)
end

function KeysanityMode:propertyChanged(key, value)
	if key == "state" then
		self:updateIcon()
	end
end