KeysanityMode = class(CustomItem)

function KeysanityMode:init(variant)
	self:createItem("Dungeon Items")
	self.code = "keysanity_mode_surrogate"
	self.activeImage = ImageReference:FromPackRelativePath("images/mode_keysanity_standard.png")
	self.ItemInstance.PotentialIcon = self.activeImage

	if variant == "items_only_keys" then
		self:setState(3)
	else
		self:setState(0)
	end
	
	self:updateIcon()
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

	item = Tracker:FindObjectForCode("gt_bkgame")
	item.MaxCount = 22

	if self:getState() == 0 then
		self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_keysanity_standard.png")
	elseif self:getState() == 1 then
		self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_keysanity_mapsanity.png")
	elseif self:getState() == 2 then
		self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_keysanity_smallsanity.png")
	else
		self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_keysanity_full.png")
		item.MaxCount = 27
	end

	self:updateChests()
end

function KeysanityMode:updateChests()
	local dungeons = { "hc", "ep", "dp", "at", "sp", "pod", "mm", "sw", "ip", "toh", "tt", "tr", "gt" }
	for i = 1, 13 do
		local item = Tracker:FindObjectForCode(dungeons[i] .. "_item")
		local chest = Tracker:FindObjectForCode(dungeons[i] .. "_chest")
		local key = Tracker:FindObjectForCode(dungeons[i] .. "_smallkey")
		local found = item.Section.ChestCount - item.Section.AvailableChestCount

		item.Section.ChestCount = chest.MaxCount
		if self:getState() <= 2 and dungeons[i] ~= "hc" and dungeons[i] ~= "at" then
			item.Section.ChestCount = item.Section.ChestCount - 1
		end
		if self:getState() <= 1 and key then
			item.Section.ChestCount = item.Section.ChestCount - key.MaxCount
		end
		if self:getState() == 0 then
			if dungeons[i] == "hc" then
				item.Section.ChestCount = item.Section.ChestCount - 1
			elseif dungeons[i] ~= "at" then
				item.Section.ChestCount = item.Section.ChestCount - 2
			end
		end
		item.Section.AvailableChestCount = math.max(item.Section.ChestCount - found, 0)
	end
end

function KeysanityMode:onLeftClick()
	self:setState((self:getState() + 1) % 4)
end

function KeysanityMode:onRightClick()
	self:setState((self:getState() - 1) % 4)
end

function KeysanityMode:canProvideCode(code)
	if code == self.code then
		return true
	else
		return false
	end
end

function KeysanityMode:providesCode(code)
	if code == self.code and self:getState() ~= 0 then
		return 1
	end
	return 0
end

function KeysanityMode:advanceToCode(code)
	if code == nil or code == self.code then
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