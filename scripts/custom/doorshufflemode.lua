DoorShuffleMode = class(CustomItem)

function DoorShuffleMode:init(suffix)
	self:createItem("Door Shuffle")
	self.code = "door_shuffle_surrogate"
    self.suffix = suffix
    
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
	
	if self:getState() == 0 then
		self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_door_shuffle_off" .. self.suffix .. ".png")
        self.ItemInstance.Name = "Off"
        item.MaxCount = 22
    elseif self:getState() == 1 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_door_shuffle_basic" .. self.suffix .. ".png")
        self.ItemInstance.Name = "Basic"
        item.MaxCount = 27
	else
		self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/mode_door_shuffle_crossed" .. self.suffix .. ".png")
        self.ItemInstance.Name = "Crossed"
        item.MaxCount = 99
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
		if (self:getState() - state) % 3 == 1 then
			item:OnLeftClick()
		else
			item:OnRightClick()
		end
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
	if code == self.code .. self.suffix then
		return true
	else
		return false
	end
end

function DoorShuffleMode:providesCode(code)
	if code == self.code .. self.suffix and self:getState() ~= 0 then
		return self:getState()
	end
	return 0
end

function DoorShuffleMode:advanceToCode(code)
	if code == nil or code == self.code .. self.suffix then
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