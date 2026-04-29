CustomItem = class()

function CustomItem:init()
end

function CustomItem:createItem(name)
	local function invokeLeftClick(item)
		item.ItemState:onLeftClick()
	end
	local function invokeRightClick(item)
		item.ItemState:onRightClick()
	end
	local function invokeCanProvideCode(item, code)
		return item.ItemState:canProvideCode(code)
	end
	local function invokeProvidesCode(item, code)
		return item.ItemState:providesCode(code)
	end
	local function invokeAdvanceToCode(item, code)
		return item.ItemState:advanceToCode(code)
	end
	local function invokeGetAllProvidedCodes(item)
		return item.ItemState:getAllProvidedCodes()
	end
	local function invokeSave(item)
		return item.ItemState:save()
	end
	local function invokeLoad(item, data)
		return item.ItemState:load(data)
	end
	local function invokePropertyChanged(item, key, value)
		return item.ItemState:propertyChanged(key, value)
	end

	self.ItemInstance = ScriptHost:CreateLuaItem()
	self.ItemInstance.Name = name
	self.ItemInstance.ItemState = self
	self.ItemInstance.OnLeftClickFunc = invokeLeftClick
	self.ItemInstance.OnRightClickFunc = invokeRightClick
	self.ItemInstance.CanProvideCodeFunc = invokeCanProvideCode
	self.ItemInstance.ProvidesCodeFunc = invokeProvidesCode
	self.ItemInstance.AdvanceToCodeFunc = invokeAdvanceToCode
	self.ItemInstance.GetAllProvidedCodesFunc = invokeGetAllProvidedCodes
	self.ItemInstance.SaveFunc = invokeSave
	self.ItemInstance.LoadFunc = invokeLoad
	self.ItemInstance.PropertyChangedFunc = invokePropertyChanged
end

--	Called when your item is left-clicked
function CustomItem:onLeftClick()
end

--	Called when your item is right-clicked
function CustomItem:onRightClick()
end

--	Called to determine if your item can ever provide a given code
--	This is used (for example) when placing items on item grids.
--
--	Returns true or false
function CustomItem:canProvideCode(code)
	return false
end

--	Called to determine if your item currently provides a given code,
--	and if so, the count provided.
--
--	Returns an integer count >= 0
function CustomItem:providesCode(code)
	return 0
end

--	Called to request that your item advance to the given code.
function CustomItem:advanceToCode(code)
end

--	Called once after the item is created, to advertise the complete static
--	set of codes this item could ever provide via providesCode() across any
--	state. EmoTracker uses the result to build a code → providers index;
--	codes NOT in this list will skip this item entirely on accessibility-rule
--	lookups (no per-rule providesCode invocation).
--
--	Return:
--	  - A table of code strings — array-style { "lamp", "fire" }
--	    or set-style { lamp = true, fire = true } both work. Return {}
--	    if your item never returns >0 from providesCode for any code.
--	  - nil to signal "indeterminate" — EmoTracker will fall back to
--	    brute-force providesCode dispatch on every lookup (legacy behavior).
--
--	The base default is nil; override in subclasses whose code set is
--	statically determinable to enable the indexing optimization.
function CustomItem:getAllProvidedCodes()
	return nil
end

--	Called when the user is saving progress.
--
--	Return a table of key-value pairs, for simple value types (bool, integer, string, etc.)
function CustomItem:save()
	return { }
end

--	Called when the user is loading progress. Data is a table containing your saved data.
--
--	Return true for success, false for failure (will fail the load)
function CustomItem:load(data)
	return true
end

--	Call to set a transaction-backed property. Properties set this way will support undo.
--
--	Returns true if the value was actually modified. DO NOT OVERRIDE
function CustomItem:setProperty(key, value)
	return self.ItemInstance:Set(key, value)
end

--	Call to read a transaction-backed property. DO NOT OVERRIDE
function CustomItem:getProperty(key)
	return self.ItemInstance:Get(key)
end

--  Call to read a transaction-backed property that will use an open transaction. DO NOT OVERRIDE
function CustomItem:getUpdatedProperty(key)
    return self.ItemInstance:Get(key, true)
end

--	Called when a transaction-backed property's value has changed. This will also happen
--	as part of setting a transaction-backed property.
function CustomItem:propertyChanged(key, value)
end