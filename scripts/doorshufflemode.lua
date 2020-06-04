DoorShuffleMode = class(CustomItem)

function DoorShuffleMode:init()
	self:createItem("Door Shuffle")
	self.code = "door_shuffle_surrogate"
	self.activeImage = ImageReference:FromPackRelativePath("images/mode_door_shuffle_off.png")
	self.ItemInstance.PotentialIcon = self.activeImage
    self:setState(0)
end

function DoorShuffleMode:setState(state)
	self:setProperty("state", state)
end

function DoorShuffleMode:getState()
	return self:getProperty("state")
end

function DoorShuffleMode:updateIcon()
	local item = Tracker:FindObjectForCode("door_shuffle")
	item.CurrentStage = self:getState()

	item = Tracker:FindObjectForCode("gt_bkgame")
	item.MaxCount = 22

	if self:getState() == 0 then
		self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_door_shuffle_off.png")
	elseif self:getState() == 1 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_door_shuffle_basic.png")
        item.MaxCount = 27
	else
		self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_door_shuffle_crossed.png")
		item.MaxCount = 99
    end
    
    local keysanity = Tracker:FindObjectForCode("keysanity_mode")
	updateIcons(keysanity.CurrentStage, self:getState())
end

function DoorShuffleMode:onLeftClick()
	self:setState((self:getState() + 1) % 3)
end

function DoorShuffleMode:onRightClick()
	self:setState((self:getState() - 1) % 3)
end

function DoorShuffleMode:canProvideCode(code)
	if code == self.code then
		return true
	else
		return false
	end
end

function DoorShuffleMode:providesCode(code)
	if code == self.code and self:getState() ~= 0 then
		return 1
	end
	return 0
end

function DoorShuffleMode:advanceToCode(code)
	if code == nil or code == self.code then
		self:setState((self:getState() + 1) % 3)
	end
end

function DoorShuffleMode:save()
	return { }
end

function DoorShuffleMode:load(data)
	local item = Tracker:FindObjectForCode("door_shuffle")
	self:setState(item.CurrentStage)
end

function DoorShuffleMode:propertyChanged(key, value)
	if key == "state" then
		self:updateIcon()
	end
end