print("")
print("Active Auto-Tracker Configuration")
print("---------------------------------------------------------------------")
print("Enable Item Tracking:			", AUTOTRACKER_ENABLE_ITEM_TRACKING)
print("Enable Location Tracking:		", AUTOTRACKER_ENABLE_LOCATION_TRACKING)
print("Enable Entrance Tracking:		", AUTOTRACKER_ENABLE_ENTRANCE_TRACKING)
if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
		print("Enable Debug Logging:				", "true")
end
print("---------------------------------------------------------------------")
print("")

function autotracker_started()
	-- Invoked when the auto-tracker is activated/connected
	START_TIME = os.time()
end

AUTOTRACKER_IS_IN_TRIFORCE_ROOM = false
AUTOTRACKER_HAS_DONE_POST_GAME_SUMMARY = false

U8_READ_CACHE = 0
U8_READ_CACHE_ADDRESS = 0

U16_READ_CACHE = 0
U16_READ_CACHE_ADDRESS = 0

function InvalidateReadCaches()
	U8_READ_CACHE_ADDRESS = 0
	U16_READ_CACHE_ADDRESS = 0
end

function ReadU8(segment, address)
	if U8_READ_CACHE_ADDRESS ~= address then
		U8_READ_CACHE = segment:ReadUInt8(address)
		U8_READ_CACHE_ADDRESS = address				
	end

	return U8_READ_CACHE
end

function ReadU16(segment, address)
	if U16_READ_CACHE_ADDRESS ~= address then
		U16_READ_CACHE = segment:ReadUInt16(address)
		U16_READ_CACHE_ADDRESS = address				
	end

	return U16_READ_CACHE
end

function isInGame()
	return AutoTracker:ReadU8(0x7e0010, 0) > 0x05
end

function updateInGameStatusFromMemorySegment(segment)
	
	local mainModuleIdx = segment:ReadUInt8(0x7e0010)
	
	if mainModuleIdx == 0 then
		START_TIME = os.time()
	end

	if mainModuleIdx == 0x09 then
		LASTCOORDX = segment:ReadUInt16(0x7e0022)
		LASTCOORDY = segment:ReadUInt16(0x7e0020)

		--print(string.format("Coord: %xx%x", LASTCOORDX, LASTCOORDY))
	end

	if mainModuleIdx ~= PREV_MODULEID then
		if (mainModuleIdx == 0x07 or mainModuleIdx == 0x09) then
			updateModuleFromMemorySegment(segment)
		end
	end

	local wasInTriforceRoom = AUTOTRACKER_IS_IN_TRIFORCE_ROOM
	AUTOTRACKER_IS_IN_TRIFORCE_ROOM = (mainModuleIdx == 0x19 or mainModuleIdx == 0x1a)

	if AUTOTRACKER_IS_IN_TRIFORCE_ROOM and not wasInTriforceRoom then
		ScriptHost:AddMemoryWatch("LTTP Statistics", 0x7ef420, 0x46, updateStatisticsFromMemorySegment)
	end

	PREV_MODULEID = mainModuleIdx

	if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
		if mainModuleIdx > 0x05 then
			--print("Current Room Index: ", segment:ReadUInt16(0x7e00a0))
			--print("Current OW	 Index: ", segment:ReadUInt16(0x7e008a))
		end
		--return false
	end

	return true
end

function updateProgressiveItemFromByte(segment, code, address, offset)
		local item = Tracker:FindObjectForCode(code)
		if item then
			local value = ReadU8(segment, address)
			if value + (offset or 0) - item.CurrentStage == 1 then
				itemFlippedOn(code)
			end
			item.CurrentStage = value + (offset or 0)
		end
end

function updateAga1(segment)
	local item = Tracker:FindObjectForCode("aga1")
	local value = ReadU8(segment, 0x7ef3c5)
	if value >= 3 then
		item.Active = true
		if (string.find(Tracker.ActiveVariantUID, "inverted")) then
			item = Tracker:FindObjectForCode("castle_top")
		else
			item = Tracker:FindObjectForCode("dw_east")
		end
		item.Active = true
	else
		item.Active = false
	end
end

function updateAga2(segment)
	local item = Tracker:FindObjectForCode("aga2")
	local value = ReadU8(segment, 0x7ef2db)
	if value & 0x20 > 0 then
		item.Active = true
		if (string.find(Tracker.ActiveVariantUID, "inverted")) then
			item = Tracker:FindObjectForCode("castle_top")
		else
			item = Tracker:FindObjectForCode("dw_east")
		end
		item.Active = true
	else
		item.Active = false
	end
end

function updateDam(segment)
	local item = Tracker:FindObjectForCode("dam")
	local value = ReadU8(segment, 0x7ef2bb)
	item.Active = value & 0x20 > 0
end

function testFlag(segment, address, flag)
    local value = ReadU8(segment, address)
    local flagTest = value & flag

    if flagTest ~= 0 then
        return true
    else
        return false
    end    
end

function updateProgressiveBow(segment)
    local item = Tracker:FindObjectForCode("bowandarrows")    
    if testFlag(segment, 0x7ef38e, 0x40) then
        if testFlag(segment, 0x7ef38e, 0x80) then
			item.CurrentStage = 3
		else
			item.CurrentStage = 0
		end
	elseif testFlag(segment, 0x7ef38e, 0x80) then
        item.CurrentStage = 2
    else
        item.CurrentStage = 1
    end
end

function updateBottles(segment)
	local item = Tracker:FindObjectForCode("bottle")		
	local count = 0
	for i = 0, 3, 1 do
		if ReadU8(segment, 0x7ef35c + i) > 0 then
			count = count + 1
		end
	end
	item.CurrentStage = count
end

function updateToggleItemFromByte(segment, code, address)
	local item = Tracker:FindObjectForCode(code)
	if item then
		local value = ReadU8(segment, address)
		if value > 0 then
			if not item.Active then
				itemFlippedOn(code)
			end
			item.Active = true
		else
			item.Active = false
		end
	end
end

function updateToggleItemFromByteAndFlag(segment, code, address, flag)
	local item = Tracker:FindObjectForCode(code)
	if item then
		local value = ReadU8(segment, address)
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
			print(item.Name, code, flag)
		end

		local flagTest = value & flag

		if flagTest ~= 0 then
			if not item.Active then
				itemFlippedOn(code)
			end
			item.Active = true
		else
			item.Active = false
		end
	else
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
			print("Cannot find item", code)
		end
	end
end

function updateToggleFromRoomSlot(segment, code, slot)
	local item = Tracker:FindObjectForCode(code)
	if item then
		local roomData = ReadU16(segment, 0x7ef000 + (slot[1] * 2))
		
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
			print(roomData)
		end

		item.Active = (roomData & (1 << slot[2])) ~= 0
	end
end

function updateFlute(segment)
	local item = Tracker:FindObjectForCode("flute")
	local value = ReadU8(segment, 0x7ef38c)

	local fakeFlute = value & 0x02
	local realFlute = value & 0x01

	if realFlute ~= 0 then
		if item.CurrentStage == 0 then
			itemFlippedOn("flute2")
		end
		item.Active = true
		item.CurrentStage = 1
	elseif fakeFlute ~= 0 then
		if not item.Active then
			itemFlippedOn("flute")
		end
		item.Active = true
		item.CurrentStage = 0
	else
		item.Active = false
	end
end

function updateConsumableItemFromByte(segment, code, address)
	local item = Tracker:FindObjectForCode(code)
	if item then
		local value = ReadU8(segment, address)
		item.AcquiredCount = value
	else
		print("Couldn't find item: ", code)
	end
end

function updatePseudoProgressiveItemFromByteAndFlag(segment, code, address, flag, callback)
	local item = Tracker:FindObjectForCode(code)
	if item then
		if item.Owner.ModifiedByUser then
			return
		end

		local value = ReadU8(segment, address)
		local flagTest = value & flag

		if flagTest ~= 0 then
			if item.CurrentStage == 0 then
				itemFlippedOn(code)
			end
			item.CurrentStage = math.max(1, item.CurrentStage)
		else 
			item.CurrentStage = 0
		end	
		
		if callback then
			callback(true)
		end
	end
end

function updateSectionChestCountFromByteAndFlag(segment, locationRef, address, flag, callback)
	local location = Tracker:FindObjectForCode(locationRef)
	if location then
		-- Do not auto-track this the user has manually modified it
		if location.Owner.ModifiedByUser then
			return
		end

		local value = ReadU8(segment, address)
		
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
			print(locationRef, value)
		end

		if (value & flag) ~= 0 then
			location.AvailableChestCount = 0
			if callback then
				callback(true)
			end
		else
			location.AvailableChestCount = location.ChestCount
			if callback then
				callback(false)
			end
		end
	elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
		print("Couldn't find location", locationRef)
	end
end

function updateSectionChestCountFromOverworldIndexAndFlag(segment, locationRef, index, callback)
	updateSectionChestCountFromByteAndFlag(segment, locationRef, 0x7ef280 + index, 0x40, callback)
end

function updateSectionChestCountFromRoomSlotList(segment, locationRef, roomSlots, callback)
	local location = Tracker:FindObjectForCode(locationRef)
	if location then
		-- Do not auto-track this the user has manually modified it
		if location.Owner.ModifiedByUser then
			return
		end

		local clearedCount = 0
		for i,slot in ipairs(roomSlots) do
			local roomData = ReadU16(segment, 0x7ef000 + (slot[1] * 2))

			if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
				print(locationRef, roomData, 1 << slot[2])
			end
					
			if (roomData & (1 << slot[2])) ~= 0 then
				clearedCount = clearedCount + 1
			elseif not (string.find(Tracker.ActiveVariantUID, "er_")) and slot[3] and roomData & slot[3] ~= 0 then
				clearedCount = clearedCount + 1
			end
		end

		location.AvailableChestCount = location.ChestCount - clearedCount

		if callback then
			callback(clearedCount > 0)
		end
	elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
			print("Couldn't find location", locationRef)
	end
end

function updateDungeonChestCountFromRoomSlotList(segment, chestRef, roomSlots, callback)
	local chest = Tracker:FindObjectForCode(chestRef)
	if chest then
		-- Do not auto-track this the user has manually modified it
		if chest.Owner.ModifiedByUser then
			return
		end

		local clearedCount = 0
		for i,slot in ipairs(roomSlots) do
			local roomData = ReadU16(segment, 0x7ef000 + (slot[1] * 2))

			if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
				print(chestRef, roomData, 1 << slot[2])
			end
					
			if (roomData & (1 << slot[2])) ~= 0 then
				clearedCount = clearedCount + 1
			end
		end
		
		chest.AcquiredCount = chest.MaxCount - clearedCount

		if callback then
			callback(clearedCount > 0)
		end
	elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
		print("Couldn't find chest", chestRef)
	end
end

function updateDoorKeyCountFromRoomSlotList(segment, doorKeyRef, roomSlots, callback)
	local doorKey = Tracker:FindObjectForCode(doorKeyRef)
	if doorKey then
		local clearedCount = 0
		for i,slot in ipairs(roomSlots) do
			local roomData = ReadU16(segment, 0x7ef000 + (slot[1] * 2))

			if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
					print(doorKeyRef, roomData, 1 << slot[2])
			end
	
			if (roomData & (1 << slot[2])) ~= 0 then
				clearedCount = clearedCount + 1
			elseif #slot > 2 then
				roomData = ReadU16(segment, 0x7ef000 + (slot[3] * 2))
				
				if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
					print(doorKeyRef, roomData, 1 << slot[2])
				end
				
				if (roomData & (1 << slot[4])) ~= 0 then
					clearedCount = clearedCount + 1
				end
			end
		end

		doorKey.AcquiredCount = clearedCount
		
		if callback then
				callback(clearedCount > 0)
		end
	elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
		print("Couldn't find door/key", doorKeyRef)
	end
end

function updateDungeonKeysFromPrefix(segment, dungeonPrefix, address)
	local dungeons =
	{
		[0] = "hc",--sewer
		[2] = "hc",
		[4] = "ep",
		[6] = "dp",
		[8] = "at",
		[10] = "sp",
		[12] = "pod",
		[14] = "mm",
		[16] = "sw",
		[18] = "ip",
		[20] = "toh",
		[22] = "tt",
		[24] = "tr",
		[26] = "gt",
		[255] = "OW"
	}

	local chestKeys = Tracker:FindObjectForCode(dungeonPrefix .. "_smallkey")
	if chestKeys then
		local doorsOpened = Tracker:FindObjectForCode(dungeonPrefix .. "_door")
		if doorsOpened then
			local currentDungeon = Tracker:FindObjectForCode("dungeon")
			local currentKeys = 0
			
			if currentDungeon and dungeons[currentDungeon.AcquiredCount] == dungeonPrefix and ReadU8(segment, 0x7ef36f) ~= 0xff then
				currentKeys = ReadU8(segment, 0x7ef36f)
			else
				currentKeys = ReadU8(segment, address)
			end
			local potKeys = Tracker:FindObjectForCode(dungeonPrefix .. "_potkey")
			if potKeys then
				chestKeys.AcquiredCount = currentKeys + doorsOpened.AcquiredCount - potKeys.AcquiredCount
			else
				chestKeys.AcquiredCount = currentKeys + doorsOpened.AcquiredCount
			end
		end
	end
	
	--update map/compass/big key
	local state = 0
	local item = Tracker:FindObjectForCode(dungeonPrefix .. "_bigkey")
	if item and item.Active then
		state = state + 0x4
	end
	
	item = Tracker:FindObjectForCode(dungeonPrefix .. "_map")
	if item and item.Active then
		state = state + 0x2
	end
	
	item = Tracker:FindObjectForCode(dungeonPrefix .. "_compass")
	if item and item.Active then
		state = state + 0x1
	end
	
	item = Tracker:FindObjectForCode(dungeonPrefix .. "_mcbk")
	if item then
		item:Set("state", state)
	end
end

function updateBossChestCountFromRoom(segment, locationRef, roomSlot)
	local location = Tracker:FindObjectForCode(locationRef)
	if location then
		-- Do not auto-track this the user has manually modified it
		if location.Owner.ModifiedByUser then
			return
		end

		local roomData = ReadU16(segment, 0x7ef000 + (roomSlot[1] * 2))
			
		if (roomData & (1 << roomSlot[2])) ~= 0 then
			location.AvailableChestCount = 0
		end
	elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
		print("Couldn't find location", locationRef)
	end
end

function updateSectionChestCountFromDungeon(locationRef, dungeonPrefix)
	local location = Tracker:FindObjectForCode(locationRef)
	if location then
		-- Do not auto-track this the user has manually modified it
		if location.Owner.ModifiedByUser then
			return
		end
		
		local chest = Tracker:FindObjectForCode(dungeonPrefix.."_chest")
		if chest then
			local bigkey = Tracker:FindObjectForCode(dungeonPrefix.."_bigkey")
			local map = Tracker:FindObjectForCode(dungeonPrefix.."_map")
			local compass = Tracker:FindObjectForCode(dungeonPrefix.."_compass")
			local smallkey = Tracker:FindObjectForCode(dungeonPrefix.."_smallkey")
			local dungeonItems = 0
			
			if bigkey and bigkey.Active then
				dungeonItems = dungeonItems + 1
			end
			
			if map and map.Active then
				dungeonItems = dungeonItems + 1
			end
			
			if compass and compass.Active then
				dungeonItems = dungeonItems + 1
			end
			
			if smallkey and smallkey.AcquiredCount then
				dungeonItems = dungeonItems + smallkey.AcquiredCount
			end
			
			if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
				print(dungeonPrefix.." Items", dungeonItems)
				print(dungeonPrefix.." Chests", chest.MaxCount - chest.AcquiredCount)
			end
			
			location.AvailableChestCount = location.ChestCount - ((chest.MaxCount - chest.AcquiredCount) - dungeonItems)
			
			local item = Tracker:FindObjectForCode(dungeonPrefix.."_item")
			if item then
				item.AcquiredCount = location.AvailableChestCount
			end
		end
	end
end

function updateBombIndicatorStatus(status)
	local item = Tracker:FindObjectForCode("bombs")
	if item then
		if status then
			item.CurrentStage = 1
		else
			item.CurrentStage = 0
		end
	end
end

function updateBatIndicatorStatus(status)
	local item = Tracker:FindObjectForCode("powder")
	if item then
		if status then
			item.CurrentStage = 1
		else
			item.CurrentStage = 0
		end
	end
end

function updateMushroomStatus(status)
	local item = Tracker:FindObjectForCode("mushroom")
	if item then
		local location = Tracker:FindObjectForCode("@Witch's Hut/Assistant")
		if location and location.AvailableChestCount == 0 then
			item.CurrentStage = 2
		end
	end
end

function updateShovelStatus(status)
	local item = Tracker:FindObjectForCode("shovel")
	if item then
		if status then
			item.CurrentStage = 2
		end
	end
end

function updateNPCItemFlagsFromMemorySegment(segment)
	if not isInGame() then
		return false
	end

	if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
		return true
	end

	InvalidateReadCaches()

	updateSectionChestCountFromByteAndFlag(segment, "@Old Man/Bring Him Home", 0x7ef410, 0x01)
	updateSectionChestCountFromByteAndFlag(segment, "@Zora's Domain/King Zora", 0x7ef410, 0x02)
	updateSectionChestCountFromByteAndFlag(segment, "@Sick Kid/By The Bed", 0x7ef410, 0x04)
	updateSectionChestCountFromByteAndFlag(segment, "@Haunted Grove/Stumpy", 0x7ef410, 0x08)
	updateSectionChestCountFromByteAndFlag(segment, "@Sahasrala's Hut/Shabbadoo", 0x7ef410, 0x10)
	updateSectionChestCountFromByteAndFlag(segment, "@Catfish/Ring of Stones", 0x7ef410, 0x20)
	-- 0x40 is unused
	updateSectionChestCountFromByteAndFlag(segment, "@Library/On The Shelf", 0x7ef410, 0x80)

	updateSectionChestCountFromByteAndFlag(segment, "@Ether Tablet/Tablet", 0x7ef411, 0x01)
	updateSectionChestCountFromByteAndFlag(segment, "@Bombos Tablet/Tablet", 0x7ef411, 0x02)
	updateSectionChestCountFromByteAndFlag(segment, "@Dwarven Smiths/Bring Him Home", 0x7ef411, 0x04)
	-- 0x08 is no longer relevant
	updateSectionChestCountFromByteAndFlag(segment, "@Lost Woods/Mushroom Spot", 0x7ef411, 0x10)
	updateSectionChestCountFromByteAndFlag(segment, "@Witch's Hut/Assistant", 0x7ef411, 0x20)
	-- 0x40 is unused
	updateSectionChestCountFromByteAndFlag(segment, "@Magic Bat/Magic Bowl", 0x7ef411, 0x80, updateBatIndicatorStatus)
end

function updateOverworldEventsFromMemorySegment(segment)
	if not isInGame() then
		return false
	end

	if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
		return true
	end		

	InvalidateReadCaches()

	updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Spectacle Rock/Up On Top",           3)
	updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Floating Island/Island",             5)
	updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Race Game/Take This Trash",          40)
	updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Grove Digging Spot/Hidden Treasure", 42, updateShovelStatus)
	updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Desert Ledge/Ledge",                 48)
	updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Lake Hylia Island/Island",           53)
	updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Dam/Outside",                        59)
	updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Bumper Cave/Ledge",                  74)
	updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Pyramid Ledge/Ledge",                91)
	updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Digging Game/Dig For Treasure",      104)
	updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Master Sword Pedestal/Pedestal",     128)
	updateSectionChestCountFromOverworldIndexAndFlag(segment, "@Zora's Domain/Ledge",                129)

	updateAga2(segment)
	updateDam(segment)
end

function updateRoomsFromMemorySegment(segment)

	if not isInGame() then
		return false
	end

	InvalidateReadCaches()

	if AUTOTRACKER_ENABLE_ITEM_TRACKING then
		updateToggleFromRoomSlot(segment, "ep", { 200, 11 })
		updateToggleFromRoomSlot(segment, "dp", { 51, 11 })
		updateToggleFromRoomSlot(segment, "toh", { 7, 11 })
		updateToggleFromRoomSlot(segment, "pod", { 90, 11 })
		updateToggleFromRoomSlot(segment, "sp", { 6, 11 })
		updateToggleFromRoomSlot(segment, "sw", { 41, 11 })
		updateToggleFromRoomSlot(segment, "tt", { 172, 11 })
		updateToggleFromRoomSlot(segment, "ip", { 222, 11 })
		updateToggleFromRoomSlot(segment, "mm", { 144, 11 })
		updateToggleFromRoomSlot(segment, "tr", { 164, 11 })
	end

	if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
		return true
	end		

	updateSectionChestCountFromRoomSlotList(segment, "@Link's House/By The Door", { { 0, 10 } })
	updateSectionChestCountFromRoomSlotList(segment, "@The Well/Cave", { { 47, 5 }, { 47, 6 }, { 47, 7 }, { 47, 8 } })
	updateSectionChestCountFromRoomSlotList(segment, "@The Well/Bombable Wall", { { 47, 4 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Hookshot Cave/Bonkable Chest", { { 60, 7 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Hookshot Cave/Back", { { 60, 4 }, { 60, 5 }, { 60, 6 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Castle Secret Entrance/Hallway", { { 85, 4 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Lost Woods/Forest Hideout", { { 225, 9, 4 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Lumberjack Cave/Cave", { { 226, 9 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Spectacle Rock/Cave", { { 234, 10, 2 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Paradox Cave/Top", { { 239, 4 }, { 239, 5 }, { 239, 6 }, { 239, 7 }, { 239, 8 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Super-Bunny Cave/Cave", { { 248, 4 }, { 248, 5 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Spiral Cave/Cave", { { 254, 4 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Paradox Cave/Bottom", { { 255, 4 }, { 255, 5 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Tavern/Back Room", { { 259, 4 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Link's House/By The Door", { { 260, 4 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Sahasrala's Hut/Back Room", { { 261, 4 }, { 261, 5 }, { 261, 6 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Bombable Shack/Downstairs", { { 262, 4 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Treasure Game/Prize", { { 262, 10 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Chicken House/Bombable Wall", { { 264, 4 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Aginah's Cave/Cave", { { 266, 4 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Dam/Inside", { { 267, 4 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Mimic Cave/Cave", { { 268, 4 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Mire Shack/Shack", { { 269, 4 }, { 269, 5 } })
	updateSectionChestCountFromRoomSlotList(segment, "@King's Tomb/The Crypt", { { 275, 4 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Waterfall Fairy/Waterfall Cave", { { 276, 4 }, { 276, 5 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Fat Fairy/Big Bomb Spot", { { 278, 4 }, { 278, 5 } }, updateBombIndicatorStatus)
	updateSectionChestCountFromRoomSlotList(segment, "@Spike Cave/Cave", { { 279, 4 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Graveyard Ledge/Cave", { { 283, 9, 0x8000 } })
	updateSectionChestCountFromRoomSlotList(segment, "@South of Grove/Circle of Bushes", { { 283, 10, 2 } })
	updateSectionChestCountFromRoomSlotList(segment, "@C-Shaped House/House", { { 284, 4 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Blind's House/Basement", { { 285, 5 }, { 285, 6 }, { 285, 7 }, { 285, 8 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Blind's House/Bombable Wall", { { 285, 4 } })	 
	updateSectionChestCountFromRoomSlotList(segment, "@Hype Cave/Cave", { { 286, 4 }, { 286, 5 }, { 286, 6 }, { 286, 7 }, { 286, 10 } }) 
	updateSectionChestCountFromRoomSlotList(segment, "@Ice Rod Cave/Cave", { { 288, 4 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Mini Moldorm Cave/Cave", { { 291, 4 }, { 291, 5 }, { 291, 6 }, { 291, 7 }, { 291, 10 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Bonk Rocks/Cave", { { 292, 4 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Checkerboard Cave/Cave", { { 294, 9, 1 } })
	updateSectionChestCountFromRoomSlotList(segment, "@Hammer Pegs/Cave", { { 295, 10, 2 } })
end

function updateItemsFromMemorySegment(segment)
	if not isInGame() then
		return false
	end

	InvalidateReadCaches()

	if AUTOTRACKER_ENABLE_ITEM_TRACKING then
		updateProgressiveItemFromByte(segment, "sword",	0x7ef359, 1)
		updateProgressiveItemFromByte(segment, "shield", 0x7ef35a, 0)
		updateProgressiveItemFromByte(segment, "armor",	0x7ef35b, 0)
		updateProgressiveItemFromByte(segment, "gloves", 0x7ef354, 0)
		
		updateToggleItemFromByte(segment, "hookshot",	0x7ef342)
		updateToggleItemFromByte(segment, "bombs",		 0x7ef343)
		updateToggleItemFromByte(segment, "firerod",	 0x7ef345)
		updateToggleItemFromByte(segment, "icerod",		0x7ef346)
		updateToggleItemFromByte(segment, "bombos",		0x7ef347)
		updateToggleItemFromByte(segment, "ether",		 0x7ef348)
		updateToggleItemFromByte(segment, "quake",		 0x7ef349)
		updateToggleItemFromByte(segment, "lamp",			0x7ef34a)
		updateToggleItemFromByte(segment, "hammer",		0x7ef34b)
		updateToggleItemFromByte(segment, "net",			 0x7ef34d)
		updateToggleItemFromByte(segment, "book",			0x7ef34e)
		updateToggleItemFromByte(segment, "somaria",	 0x7ef350)
		updateToggleItemFromByte(segment, "byrna",		 0x7ef351)
		updateToggleItemFromByte(segment, "cape",			0x7ef352)
		updateToggleItemFromByte(segment, "mirror",		0x7ef353)
		updateToggleItemFromByte(segment, "boots",		 0x7ef355)
		updateToggleItemFromByte(segment, "flippers",	0x7ef356)
		updateToggleItemFromByte(segment, "pearl",		 0x7ef357)
		updateProgressiveItemFromByte(segment, "halfmagic",	0x7ef37b)

		updateToggleItemFromByteAndFlag(segment, "blue_boomerang", 0x7ef38c, 0x80)
		updateToggleItemFromByteAndFlag(segment, "red_boomerang",	0x7ef38c, 0x40)
		updateToggleItemFromByteAndFlag(segment, "powder", 0x7ef38c, 0x10)
		
		if (string.find(Tracker.ActiveVariantUID, "items_only")) then
			updateToggleItemFromByte(segment, "bow", 0x7ef340)
			updateToggleItemFromByte(segment, "blue_boomerang", 0x7ef341)
		else
			updateToggleItemFromByteAndFlag(segment, "np_bow", 0x7ef38e, 0x80)
			updateToggleItemFromByteAndFlag(segment, "np_silvers", 0x7ef38e, 0x40)
			updateProgressiveBow(segment)
		end

		updatePseudoProgressiveItemFromByteAndFlag(segment, "mushroom", 0x7ef38c, 0x20, updateMushroomStatus)
		updatePseudoProgressiveItemFromByteAndFlag(segment, "shovel", 0x7ef38c, 0x04)

		updateBottles(segment)
		updateFlute(segment)
		updateAga1(segment)
	end

	if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
		return true
	end		

	--	It may seem unintuitive, but these locations are controlled by flags stored adjacent to the item data,
	--	which makes it more efficient to update them here.
	updateSectionChestCountFromByteAndFlag(segment, "@Castle Secret Entrance/Uncle", 0x7ef3c6, 0x01)		
	updateSectionChestCountFromByteAndFlag(segment, "@Hobo/Under The Bridge", 0x7ef3c9, 0x01)
	updateSectionChestCountFromByteAndFlag(segment, "@Bottle Vendor/This Jerk", 0x7ef3c9, 0x02)
	updateSectionChestCountFromByteAndFlag(segment, "@Purple Chest/Show To Gary", 0x7ef3c9, 0x10)
end

function updateDungeonItemsFromMemorySegment(segment)
	if not isInGame() then
		return false
	end

	InvalidateReadCaches()

	if AUTOTRACKER_ENABLE_ITEM_TRACKING then
		if SEGMENT_ROOMDATA then
			--Doors Opened
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "hc_door", { { 114, 15 }, { 113, 15 }, { 50, 15, 34, 15 }, { 17, 13, 33, 15 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "at_door", { { 224, 13 }, { 208, 15 }, { 192, 13 }, { 176, 13 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "dp_door", { { 133, 14 }, { 99, 15 }, { 83, 13, 67, 13 }, { 67, 14 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "toh_door", { { 119, 15 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "pod_door", { { 74, 13, 58, 15 }, { 10, 15 }, { 42, 14, 26, 12 }, { 26, 14, 25, 14 }, { 26, 15 }, { 11, 13 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "sp_door", { { 40, 15 }, { 56, 14, 55, 12 }, { 55, 13 }, { 54, 13, 53, 15 }, { 54, 14, 38, 15 }, { 22, 14 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "sw_door", { { 87, 13, 88, 14 }, { 104, 14, 88, 13 }, { 86, 15 }, { 89, 15, 73, 13 }, { 57, 14 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "tt_door", { { 188, 15 }, { 171, 15 }, { 68, 14 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "ip_door", { { 14, 15 }, { 62, 14, 78, 14 }, { 94, 15, 95, 15 }, { 126, 15, 142, 15 }, { 158, 15 }, { 190, 14, 191, 15 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "mm_door", { { 179, 15 }, { 194, 14, 193, 14 }, { 193, 15 }, { 194, 15, 195, 15 }, { 161, 15, 177, 14 }, { 147, 14 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "tr_door", { { 198, 15, 182, 13 }, { 182, 12 }, { 182, 15 }, { 19, 15, 20, 14 }, { 4, 15 }, { 197, 15, 196, 15 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "gt_door", { { 140, 13 }, { 139, 14 }, { 155, 15 }, { 125, 13 }, { 141, 14 }, { 123, 14, 124, 13 }, { 61, 14 }, { 61, 13, 77, 15 } })
			
			--Pot and Enemy Keys
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "hc_potkey", { { 114, 10 }, { 113, 10 }, { 33, 10 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "at_potkey", { { 192, 10 }, { 176, 10 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "dp_potkey", { { 99, 10 }, { 83, 10 }, { 67, 10 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "sp_potkey", { { 56, 10 }, { 55, 10 }, { 54, 10 }, { 53, 10 }, { 22, 10 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "sw_potkey", { { 86, 10 }, { 57, 10 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "tt_potkey", { { 188, 10 }, { 171, 10 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "ip_potkey", { { 14, 10 }, { 62, 10 }, { 63, 10 }, { 159, 10 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "mm_potkey", { { 179, 10 }, { 193, 10 }, { 161, 10 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "tr_potkey", { { 182, 10 }, { 19, 10 } })
			updateDoorKeyCountFromRoomSlotList(SEGMENT_ROOMDATA, "gt_potkey", { { 139, 10 }, { 155, 10 }, { 123, 10 }, { 61, 10 } })
		end
		
		if SEGMENT_DUNGEONITEMS then
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "gt_bigkey",	0x7ef366, 0x04)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "tr_bigkey",	0x7ef366, 0x08)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "tt_bigkey",	0x7ef366, 0x10)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "toh_bigkey", 0x7ef366, 0x20)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "ip_bigkey",	0x7ef366, 0x40)		
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "sw_bigkey",	0x7ef366, 0x80)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "mm_bigkey",	0x7ef367, 0x01)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "pod_bigkey", 0x7ef367, 0x02)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "sp_bigkey",	0x7ef367, 0x04)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "dp_bigkey",	0x7ef367, 0x10)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "ep_bigkey",	0x7ef367, 0x20)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "hc_bigkey",	0x7ef367, 0x40)
			
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "gt_map",	0x7ef368, 0x04)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "tr_map",	0x7ef368, 0x08)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "tt_map",	0x7ef368, 0x10)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "toh_map", 0x7ef368, 0x20)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "ip_map",	0x7ef368, 0x40)		
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "sw_map",	0x7ef368, 0x80)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "mm_map",	0x7ef369, 0x01)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "pod_map", 0x7ef369, 0x02)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "sp_map",	0x7ef369, 0x04)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "dp_map",	0x7ef369, 0x10)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "ep_map",	0x7ef369, 0x20)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "hc_map",	0x7ef369, 0x40)
			
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "gt_compass",	0x7ef364, 0x04)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "tr_compass",	0x7ef364, 0x08)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "tt_compass",	0x7ef364, 0x10)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "toh_compass", 0x7ef364, 0x20)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "ip_compass",	0x7ef364, 0x40)		
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "sw_compass",	0x7ef364, 0x80)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "mm_compass",	0x7ef365, 0x01)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "pod_compass", 0x7ef365, 0x02)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "sp_compass",	0x7ef365, 0x04)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "dp_compass",	0x7ef365, 0x10)
			updateToggleItemFromByteAndFlag(SEGMENT_DUNGEONITEMS, "ep_compass",	0x7ef365, 0x20)
			
			--Small Keys
			updateDungeonKeysFromPrefix(SEGMENT_DUNGEONITEMS, "hc",	0x7ef37c)
			updateDungeonKeysFromPrefix(SEGMENT_DUNGEONITEMS, "at",	0x7ef380)
			updateDungeonKeysFromPrefix(SEGMENT_DUNGEONITEMS, "ep",	0x7ef37e)
			updateDungeonKeysFromPrefix(SEGMENT_DUNGEONITEMS, "dp",	0x7ef37f)
			updateDungeonKeysFromPrefix(SEGMENT_DUNGEONITEMS, "toh", 0x7ef386)
			updateDungeonKeysFromPrefix(SEGMENT_DUNGEONITEMS, "pod", 0x7ef382)
			updateDungeonKeysFromPrefix(SEGMENT_DUNGEONITEMS, "sp",	0x7ef381)
			updateDungeonKeysFromPrefix(SEGMENT_DUNGEONITEMS, "sw",	0x7ef384)
			updateDungeonKeysFromPrefix(SEGMENT_DUNGEONITEMS, "tt",	0x7ef387)
			updateDungeonKeysFromPrefix(SEGMENT_DUNGEONITEMS, "ip",	0x7ef385)
			updateDungeonKeysFromPrefix(SEGMENT_DUNGEONITEMS, "mm",	0x7ef383)
			updateDungeonKeysFromPrefix(SEGMENT_DUNGEONITEMS, "tr",	0x7ef388)
			updateDungeonKeysFromPrefix(SEGMENT_DUNGEONITEMS, "gt",	0x7ef389)
		end
	end
	
	if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
		return true
	end
	
	if SEGMENT_ROOMDATA then
		--Dungeon Chests
		updateDungeonChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "hc_chest", { { 114, 4 }, { 113, 4 }, { 128, 4 }, { 50, 4 }, { 17, 4 }, { 17, 5 }, { 17, 6 }, { 18, 4 } })
		updateDungeonChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "at_chest", { { 224, 4 }, { 208, 4 } })
		updateDungeonChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "ep_chest", { { 185, 4 }, { 170, 4 }, { 168, 4 }, { 169, 4 }, { 184, 4 }, { 200, 11 } })
		updateDungeonChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "dp_chest", { { 115, 4 }, { 115, 10 }, { 116, 4 }, { 133, 4 }, { 117, 4 }, { 51, 11 } })
		updateDungeonChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "toh_chest", { { 135, 10 }, { 119, 4 }, { 135, 4 }, { 39, 4 }, { 39, 5 }, { 7, 11 } })
		updateDungeonChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "pod_chest", { { 9, 4 }, { 43, 4 }, { 42, 4 }, { 42, 5 }, { 58, 4 }, { 10, 4 }, { 26, 4 }, { 26, 5 }, { 26, 6 }, { 25, 4 }, { 25, 5 }, { 106, 4 }, { 106, 5 }, { 90, 11 } })
		updateDungeonChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "sp_chest", { { 40, 4 }, { 55, 4 }, { 54, 4 }, { 53, 4 }, { 52, 4 }, { 70, 4 }, { 118, 4 }, { 118, 5 }, { 102, 4 }, { 6, 11 } })
		updateDungeonChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "sw_chest", { { 103, 4 }, { 104, 4 }, { 87, 4 }, { 87, 5 }, { 88, 4 }, { 88, 5 }, { 89, 4 }, { 41, 11 } })
		updateDungeonChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "tt_chest", { { 219, 4 }, { 219, 5 }, { 203, 4 }, { 220, 4 }, { 101, 4 }, { 69, 4 }, { 68, 4 }, { 172, 11 } })
		updateDungeonChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "ip_chest", { { 46, 4 }, { 63, 4 }, { 31, 4 }, { 95, 4 }, { 126, 4 }, { 174, 4 }, { 158, 4 }, { 222, 11 } })
		updateDungeonChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "mm_chest", { { 162, 4 }, { 179, 4 }, { 194, 4 }, { 193, 4 }, { 209, 4 }, { 195, 4 }, { 195, 5 }, { 144, 11 } })
		updateDungeonChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "tr_chest", { { 214, 4 }, { 183, 4 }, { 183, 5 }, { 182, 4 }, { 20, 4 }, { 36, 4 }, { 4, 4 }, { 213, 4 }, { 213, 5 }, { 213, 6 }, { 213, 7 }, { 164, 11 } })
		updateDungeonChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "gt_chest", { { 140, 10 }, { 123, 4 }, { 123, 5 }, { 123, 6 }, { 123, 7 }, { 139, 4 }, { 125, 4 }, { 124, 4 }, { 124, 5 }, { 124, 6 }, { 124, 7 }, { 140, 4 }, { 140, 5 }, { 140, 6 }, { 140, 7 }, { 28, 4 }, { 28, 5 }, { 28, 6 }, { 141, 4 }, { 157, 4 }, { 157, 5 }, { 157, 6 }, { 157, 7 }, { 61, 4 }, { 61, 5 }, { 61, 6 }, { 77, 4 } })

		--Keysanity Dungeon Map Locations
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Hyrule Castle & Sanctuary/Escape", { { 114, 4 }, { 113, 4 }, { 128, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Hyrule Castle & Sanctuary/Dark Cross", { { 50, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Hyrule Castle & Sanctuary/Back", { { 17, 4 }, { 17, 5 }, { 17, 6 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Hyrule Castle & Sanctuary/Sanctuary", { { 18, 4 } })
		
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Agahnim's Tower/Front", { { 224, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Agahnim's Tower/Back", { { 208, 4 } })
		
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Eastern Palace/Front", { { 185, 4 }, { 170, 4 }, { 168, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Eastern Palace/Big Chest", { { 169, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Eastern Palace/Big Key Chest", { { 184, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Eastern Palace/Armos", { { 200, 11 } })
		
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Desert Palace/Eyegore Chest", { { 116, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Desert Palace/Right Side", { { 133, 4 }, { 117, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Desert Palace/Torch", { { 115, 10 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Desert Palace/Big Chest", { { 115, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Desert Palace/Lanmolas", { { 51, 11 } })
		
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Tower of Hera/Lobby\\Cage", { { 135, 10 }, { 119, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Tower of Hera/Basement", { { 135, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Tower of Hera/Compass Chest", { { 39, 5 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Tower of Hera/Big Chest", { { 39, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Tower of Hera/Moldorm", { { 7, 11 } })
		
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Palace of Darkness/Shooter Chest", { { 9, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Palace of Darkness/Bow Side", { { 43, 4 }, { 42, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Palace of Darkness/Arena\\Stalfos", { { 42, 5 }, { 10, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Palace of Darkness/Big Key Chest", { { 58, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Palace of Darkness/Dark Maze", { { 25, 4 }, { 25, 5 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Palace of Darkness/Big Chest", { { 26, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Palace of Darkness/Turtle Room", { { 26, 5 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Palace of Darkness/Rupee Basement", { { 106, 4 }, { 106, 5 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Palace of Darkness/Harmless Hellway", {  { 26, 6 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Palace of Darkness/Helmasaur", { { 90, 11 } })
		
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Swamp Palace/Entrance Chest", { { 40, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Swamp Palace/Bomb Wall", { { 55, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Swamp Palace/Left\\South Side", { { 53, 4 }, { 52, 4 }, { 70, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Swamp Palace/Big Chest", { { 54, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Swamp Palace/Back", { { 118, 4 }, { 118, 5 }, { 102, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Swamp Palace/Arrgus", { { 6, 11 } })
		
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Skull Woods/Front", { { 103, 4 }, { 104, 4 }, { 87, 4 }, { 87, 5 }, { 88, 5 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Skull Woods/Big Chest", { { 88, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Skull Woods/Bridge", { { 89, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Skull Woods/Mothula", { { 41, 11 } })
		
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Thieves Town/Front", { { 219, 4 }, { 219, 5 }, { 203, 4 }, { 220, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Thieves Town/Attic Chest", { { 101, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Thieves Town/Prison Cell", { { 69, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Thieves Town/Big Chest", { { 68, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Thieves Town/Blind", { { 172, 11 } })
		
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ice Palace/Pengator Room", { { 46, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ice Palace/Spike Room", { { 95, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ice Palace/Right Side", { { 63, 4 }, { 31, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ice Palace/Freezor Chest", { { 126, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ice Palace/Ice T", { { 174, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ice Palace/Big Chest", { { 158, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ice Palace/Khold", { { 222, 11 } })
		
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Misery Mire/Front", { { 162, 4 }, { 179, 4 }, { 194, 4 }, { 195, 5 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Misery Mire/Left Side", { { 193, 4 }, { 209, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Misery Mire/Big Chest", { { 195, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Misery Mire/Vitreous", { { 144, 11 } })
		
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Turtle Rock/Compass Chest", { { 214, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Turtle Rock/Roller Room", { { 183, 4 }, { 183, 5 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Turtle Rock/Chain Chomp", { { 182, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Turtle Rock/Lava Chest", { { 20, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Turtle Rock/Big Chest", { { 36, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Turtle Rock/Crystaroller Chest", { { 4, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Turtle Rock/Laser Bridge", { { 213, 4 }, { 213, 5 }, { 213, 6 }, { 213, 7 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Turtle Rock/Trinexx", { { 164, 11 } })
		
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ganon's Tower/Hope Room", { { 140, 5 }, { 140, 6 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ganon's Tower/Torch", { { 140, 3 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ganon's Tower/Stalfos Room", { { 123, 4 }, { 123, 5 }, { 123, 6 }, { 123, 7 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ganon's Tower/Map Chest", { { 139, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ganon's Tower/Firesnake\\Rando", { { 125, 4 }, { 124, 4 }, { 124, 5 }, { 124, 6 }, { 124, 7 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ganon's Tower/Compass Room", { { 157, 4 }, { 157, 5 }, { 157, 6 }, { 157, 7 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ganon's Tower/Bob\\Ice Armos", { { 140, 7 }, { 28, 4 }, { 28, 5 }, { 28, 6 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ganon's Tower/Tile Room", { { 141, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ganon's Tower/Big Chest", { { 140, 4 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ganon's Tower/Mini Helmasaur", { { 61, 4 }, { 61, 5 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ganon's Tower/Pre-Moldorm", { { 61, 6 } })
		updateSectionChestCountFromRoomSlotList(SEGMENT_ROOMDATA, "@Ganon's Tower/Validation", { { 77, 4 } })
		
		--Marking Bosses as Complete
		updateBossChestCountFromRoom(SEGMENT_ROOMDATA, "@Eastern Palace/Armos", { 200, 11 })
		updateBossChestCountFromRoom(SEGMENT_ROOMDATA, "@Desert Palace/Lanmolas", { 51, 11 })
		updateBossChestCountFromRoom(SEGMENT_ROOMDATA, "@Tower of Hera/Moldorm", { 7, 11 })
		updateBossChestCountFromRoom(SEGMENT_ROOMDATA, "@Palace of Darkness/Helmasaur", { 90, 11 })
		updateBossChestCountFromRoom(SEGMENT_ROOMDATA, "@Swamp Palace/Arrgus", { 6, 11 })
		updateBossChestCountFromRoom(SEGMENT_ROOMDATA, "@Skull Woods/Mothula", { 41, 11 })
		updateBossChestCountFromRoom(SEGMENT_ROOMDATA, "@Thieves Town/Blind", { 172, 11 })
		updateBossChestCountFromRoom(SEGMENT_ROOMDATA, "@Ice Palace/Khold", { 222, 11 })
		updateBossChestCountFromRoom(SEGMENT_ROOMDATA, "@Misery Mire/Vitreous", { 144, 11 })
		updateBossChestCountFromRoom(SEGMENT_ROOMDATA, "@Turtle Rock/Trinexx", { 164, 11 })
	end
	
	--Regular Dungeon Items
	updateSectionChestCountFromDungeon("@Hyrule Castle & Sanctuary/Items", "hc")
	updateSectionChestCountFromDungeon("@Eastern Palace/Items", "ep")
	updateSectionChestCountFromDungeon("@Desert Palace/Items", "dp")
	updateSectionChestCountFromDungeon("@Tower of Hera/Items", "toh")
	updateSectionChestCountFromDungeon("@Palace of Darkness/Items", "pod")
	updateSectionChestCountFromDungeon("@Swamp Palace/Items", "sp")
	updateSectionChestCountFromDungeon("@Skull Woods/Items", "sw")
	updateSectionChestCountFromDungeon("@Thieves Town/Items", "tt")
	updateSectionChestCountFromDungeon("@Ice Palace/Items", "ip")
	updateSectionChestCountFromDungeon("@Misery Mire/Items", "mm")
	updateSectionChestCountFromDungeon("@Turtle Rock/Items", "tr")
	updateSectionChestCountFromDungeon("@Ganon's Tower/Items", "gt")
end

function updateDungeonFromMemorySegment(segment)
	if not isInGame() then
		return false
	end
	
	if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
		return false
	end
	
	if (string.find(Tracker.ActiveVariantUID, "items_only")) then
		return false
	end

	if not (SEGMENT_LASTROOMID) then
		print ("no lastroom")
	end
	if not SEGMENT_OWID then
		print ("no owid")
	end
	
	if not (SEGMENT_LASTROOMID and SEGMENT_OWID) then
		return false
	end

	local dungeonMap =
	{
		             [0x01] = 2,  [0x02] = 0,               [0x04] = 24,              [0x06] = 10, [0x07] = 20,              [0x09] = 12, [0x0a] = 12, [0x0b] = 12, [0x0c] = 26, [0x0d] = 26, [0x0e] = 18,
		             [0x11] = 0,  [0x12] = 0,  [0x13] = 24, [0x14] = 24, [0x15] = 24, [0x16] = 10, [0x17] = 20,              [0x19] = 12, [0x1a] = 12, [0x1b] = 12, [0x1c] = 26, [0x1d] = 26, [0x1e] = 18, [0x1f] = 18,
		[0x20] = 8,  [0x21] = 0,  [0x22] = 0,  [0x23] = 24, [0x24] = 24,              [0x26] = 10, [0x27] = 20, [0x28] = 10, [0x29] = 16, [0x2a] = 12, [0x2b] = 12,                           [0x2e] = 18,
		[0x30] = 8,  [0x31] = 20, [0x32] = 0,  [0x33] = 6,  [0x34] = 10, [0x35] = 10, [0x36] = 10, [0x37] = 10, [0x38] = 10, [0x39] = 16, [0x3a] = 12, [0x3b] = 12,              [0x3d] = 26, [0x3e] = 18, [0x3f] = 18,
		[0x40] = 8,  [0x41] = 0,  [0x42] = 0,  [0x43] = 6,  [0x44] = 22, [0x45] = 22, [0x46] = 10,                           [0x49] = 16, [0x4a] = 12, [0x4b] = 12, [0x4c] = 26, [0x4d] = 26, [0x4e] = 18, [0x4f] = 18,
		[0x50] = 2,  [0x51] = 2,  [0x52] = 2,  [0x53] = 6,  [0x54] = 10,              [0x56] = 16, [0x57] = 16, [0x58] = 16, [0x59] = 16, [0x5a] = 12, [0x5b] = 26, [0x5c] = 26, [0x5d] = 26, [0x5e] = 18, [0x5f] = 18,
		[0x60] = 2,  [0x61] = 2,  [0x62] = 2,  [0x63] = 6,  [0x64] = 22, [0x65] = 22, [0x66] = 10, [0x67] = 16, [0x68] = 16,              [0x6a] = 12, [0x6b] = 26, [0x6c] = 26, [0x6d] = 26, [0x6e] = 18,
		[0x70] = 2,  [0x71] = 2,  [0x72] = 2,  [0x73] = 6,  [0x74] = 6,  [0x75] = 6,  [0x76] = 10, [0x77] = 20,                                        [0x7b] = 26, [0x7c] = 26, [0x7d] = 26, [0x7e] = 18, [0x7f] = 18,
		[0x80] = 2,  [0x81] = 2,  [0x82] = 2,  [0x83] = 6,  [0x84] = 6,  [0x85] = 6,               [0x87] = 20,              [0x89] = 4,               [0x8b] = 26, [0x8c] = 26, [0x8d] = 26, [0x8e] = 18,
		[0x90] = 14, [0x91] = 14, [0x92] = 14, [0x93] = 14,              [0x95] = 26, [0x96] = 26, [0x97] = 14, [0x98] = 14, [0x99] = 4,               [0x9b] = 26, [0x9c] = 26, [0x9d] = 26, [0x9e] = 18, [0x9f] = 18,
		[0xa0] = 14, [0xa1] = 14, [0xa2] = 14, [0xa3] = 14, [0xa4] = 24, [0xa5] = 26, [0xa6] = 26, [0xa7] = 20, [0xa8] = 4,  [0xa9] = 4,  [0xaa] = 4,  [0xab] = 22, [0xac] = 22,              [0xae] = 18, [0xaf] = 18,
		[0xb0] = 8,  [0xb1] = 14, [0xb2] = 14, [0xb3] = 14, [0xb4] = 24, [0xb5] = 24, [0xb6] = 24, [0xb7] = 24, [0xb8] = 4,  [0xb9] = 4,  [0xba] = 4,  [0xbb] = 22, [0xbc] = 22,              [0xbe] = 18, [0xbf] = 18,
		[0xc0] = 8,  [0xc1] = 14, [0xc2] = 14, [0xc3] = 14, [0xc4] = 24, [0xc5] = 24, [0xc6] = 24, [0xc7] = 24, [0xc8] = 4,  [0xc9] = 4,               [0xcb] = 22, [0xcc] = 22,              [0xce] = 18,
		[0xd0] = 8,  [0xd1] = 14, [0xd2] = 14,                           [0xd5] = 24, [0xd6] = 24,              [0xd8] = 4,  [0xd9] = 4,  [0xda] = 4,  [0xdb] = 22, [0xdc] = 22,              [0xde] = 18,
		[0xe0] = 8
	}
	
	local dungeon = Tracker:FindObjectForCode("dungeon")
	local dungeonLocal = 0xff

	if dungeon then
		--dungeon.AcquiredCount = ReadU8(segment, 0x7e040c) --to be used if 0x7e040c becomes unblocked
		
		local owarea = ReadU16(SEGMENT_OWID, 0x7e008a)
		if owarea == 0 and dungeonMap[ReadU16(SEGMENT_LASTROOMID, 0x7e00a0)] then
			dungeonLocal = dungeonMap[ReadU16(SEGMENT_LASTROOMID, 0x7e00a0)]
		end
		
		if dungeon.AcquiredCount ~= dungeonLocal then
			dungeon.AcquiredCount = dungeonLocal
		end

		if AUTOTRACKER_ENABLE_ENTRANCE_TRACKING then
			print(LASTOWID, LASTCOORDX, LASTCOORDY, LASTROOMID)
			--if LASTOWID ~= owarea then
				if owarea > 0 then
					LASTOWID = owarea
				else
					LASTROOMID = ReadU16(SEGMENT_LASTROOMID, 0x7e00a0)
				end
				if LASTOWID and LASTCOORDX and LASTCOORDY and LASTROOMID and segment == SEGMENT_OWID then --entrance tracking
					print(string.format("%x %xx%x leads to %s %x", LASTOWID, LASTCOORDX, LASTCOORDY, dungeonId, LASTROOMID));
				end
			--end
		end
		
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
			print("CURRENT DUNGEON:", dungeon.AcquiredCount, owarea)
		end
	end
end

function updateModuleFromMemorySegment(segment)
	if not isInGame() then
		return false
	end
	
	if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
		return false
	end
	
	if (string.find(Tracker.ActiveVariantUID, "items_only")) then
		return false
	end

	if not (SEGMENT_LASTROOMID and SEGMENT_OWID) then
		return false
	end

	local dungeonMap =
	{
		[0x00] = "gt",  [0x01] = "hc",  [0x02] = "hc",                  [0x04] = "tr",                  [0x06] = "sp",  [0x07] = "toh",                 [0x09] = "pod", [0x0a] = "pod", [0x0b] = "pod", [0x0c] = "gt",  [0x0d] = "gt",  [0x0e] = "ip",
		                [0x11] = "hc",  [0x12] = "hc",  [0x13] = "tr",  [0x14] = "tr",  [0x15] = "tr",  [0x16] = "sp",  [0x17] = "toh",                 [0x19] = "pod", [0x1a] = "pod", [0x1b] = "pod", [0x1c] = "gt",  [0x1d] = "gt",  [0x1e] = "ip",  [0x1f] = "ip",
		[0x20] = "at",  [0x21] = "hc",  [0x22] = "hc",  [0x23] = "tr",  [0x24] = "tr",                  [0x26] = "sp",  [0x27] = "toh", [0x28] = "sp",  [0x29] = "sw",  [0x2a] = "pod", [0x2b] = "pod",                                 [0x2e] = "ip",
		[0x30] = "at",  [0x31] = "toh", [0x32] = "hc",  [0x33] = "dp",  [0x34] = "sp",  [0x35] = "sp",  [0x36] = "sp",  [0x37] = "sp",  [0x38] = "sp",  [0x39] = "sw",  [0x3a] = "pod", [0x3b] = "pod",                 [0x3d] = "gt",  [0x3e] = "ip",  [0x3f] = "ip",
		[0x40] = "at",  [0x41] = "hc",  [0x42] = "hc",  [0x43] = "dp",  [0x44] = "tt",  [0x45] = "tt",  [0x46] = "sp",                                  [0x49] = "sw",  [0x4a] = "pod", [0x4b] = "pod", [0x4c] = "gt",  [0x4d] = "gt",  [0x4e] = "ip",  [0x4f] = "ip",
		[0x50] = "hc",  [0x51] = "hc",  [0x52] = "hc",  [0x53] = "dp",  [0x54] = "sp",                  [0x56] = "sw",  [0x57] = "sw",  [0x58] = "sw",  [0x59] = "sw",  [0x5a] = "pod", [0x5b] = "gt",  [0x5c] = "gt",  [0x5d] = "gt",  [0x5e] = "ip",  [0x5f] = "ip",
		[0x60] = "hc",  [0x61] = "hc",  [0x62] = "hc",  [0x63] = "dp",  [0x64] = "tt",  [0x65] = "tt",  [0x66] = "sp",  [0x67] = "sw",  [0x68] = "sw",                  [0x6a] = "pod", [0x6b] = "gt",  [0x6c] = "gt",  [0x6d] = "gt",  [0x6e] = "ip",
		[0x70] = "hc",  [0x71] = "hc",  [0x72] = "hc",  [0x73] = "dp",  [0x74] = "dp",  [0x75] = "dp",  [0x76] = "sp",  [0x77] = "toh",                                                 [0x7b] = "gt",  [0x7c] = "gt",  [0x7d] = "gt",  [0x7e] = "ip",  [0x7f] = "ip",
		[0x80] = "hc",  [0x81] = "hc",  [0x82] = "hc",  [0x83] = "dp",  [0x84] = "dp",  [0x85] = "dp",                  [0x87] = "toh",                 [0x89] = "ep",                  [0x8b] = "gt",  [0x8c] = "gt",  [0x8d] = "gt",  [0x8e] = "ip",
		[0x90] = "mm",  [0x91] = "mm",  [0x92] = "mm",  [0x93] = "mm",                  [0x95] = "gt",  [0x96] = "gt",  [0x97] = "mm",  [0x98] = "mm",  [0x99] = "ep",                  [0x9b] = "gt",  [0x9c] = "gt",  [0x9d] = "gt",  [0x9e] = "ip",  [0x9f] = "ip",
		[0xa0] = "mm",  [0xa1] = "mm",  [0xa2] = "mm",  [0xa3] = "mm",  [0xa4] = "tr",  [0xa5] = "gt",  [0xa6] = "gt",  [0xa7] = "toh", [0xa8] = "ep",  [0xa9] = "ep",  [0xaa] = "ep",  [0xab] = "tt",  [0xac] = "tt",                  [0xae] = "ip",  [0xaf] = "ip",
		[0xb0] = "at",  [0xb1] = "mm",  [0xb2] = "mm",  [0xb3] = "mm",  [0xb4] = "tr",  [0xb5] = "tr",  [0xb6] = "tr",  [0xb7] = "tr",  [0xb8] = "ep",  [0xb9] = "ep",  [0xba] = "ep",  [0xbb] = "tt",  [0xbc] = "tt",                  [0xbe] = "ip",  [0xbf] = "ip",
		[0xc0] = "at",  [0xc1] = "mm",  [0xc2] = "mm",  [0xc3] = "mm",  [0xc4] = "tr",  [0xc5] = "tr",  [0xc6] = "tr",  [0xc7] = "tr",  [0xc8] = "ep",  [0xc9] = "ep",                  [0xcb] = "tt",  [0xcc] = "tt",                  [0xce] = "ip",
		[0xd0] = "at",  [0xd1] = "mm",  [0xd2] = "mm",                                  [0xd5] = "tr",  [0xd6] = "tr",                  [0xd8] = "ep",  [0xd9] = "ep",  [0xda] = "ep",  [0xdb] = "tt",  [0xdc] = "tt",                  [0xde] = "ip",
		[0xe0] = "at"
	}

	if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
		print("MODULE: ", ReadU8(segment, 0x7e0010))
	end

	--update dungeon image
	if ReadU8(segment, 0x7e0010) == 0x07 then --underworld
		LASTROOMID = ReadU16(SEGMENT_LASTROOMID, 0x7e00a0)
		local dungeonId = dungeonMap[LASTROOMID]

		if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
			print("DUNGEON: ", dungeonId)
		end

		if dungeonId then
			if (string.find(Tracker.ActiveVariantUID, "er_")) then
				sendExternalMessage("dungeon", "er-"..dungeonId)
			else
				sendExternalMessage("dungeon", dungeonId)
			end
		end

		if AUTOTRACKER_ENABLE_ENTRANCE_TRACKING then
			if LASTOWID then --entrance tracking
				--print(string.format("%x %xx%x leads to %s %x", LASTOWID, LASTCOORDX, LASTCOORDY, dungeonId, LASTROOMID));
			end
		end
	elseif ReadU8(segment, 0x7e0010) == 0x09 then --overworld
		--LASTOWID = ReadU8(SEGMENT_OWID, 0x7e008a)
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
			print("OW: ", ReadU8(SEGMENT_OWID, 0x7e008a))
		end

		if ReadU8(SEGMENT_OWID, 0x7e008a) >= 0x40 and ReadU8(SEGMENT_OWID, 0x7e008a) < 0x80 then
			if (string.find(Tracker.ActiveVariantUID, "er_")) then
				sendExternalMessage("dungeon", "er-dw")
			else
				sendExternalMessage("dungeon", "dw")
			end
		else
			if (string.find(Tracker.ActiveVariantUID, "er_")) then
				sendExternalMessage("dungeon", "er-lw")
			else
				sendExternalMessage("dungeon", "lw")
			end
		end

		if AUTOTRACKER_ENABLE_ENTRANCE_TRACKING then
			if (LASTROOMID) then
				--print(string.format("%x %xx%x came from %s %x", LASTOWID, LASTCOORDX, LASTCOORDY, dungeonMap[LASTROOMID], LASTROOMID));
			end
		end
	end
end

function updateGTBKFromMemorySegment(segment)
	if not isInGame() or string.find(Tracker.ActiveVariantUID, "keys") then
		return false
	end
	
	if not (SEGMENT_GTTORCHROOM and SEGMENT_GTBIGKEYCOUNT) then
		return false
	end
	
	local gtBK = Tracker:FindObjectForCode("gt_bkgame")
	local dungeon = Tracker:FindObjectForCode("dungeon")

	if gtBK and dungeon and dungeon.AcquiredCount == 26 then --if in GT
		local gtTorchRoom = ReadU16(SEGMENT_GTTORCHROOM, 0x7ef118)
		local gtCount = ReadU8(SEGMENT_GTBIGKEYCOUNT, 0x7ef42a) & 0x1f
		
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
			print("GT Torch Visited:", (gtTorchRoom & 0x8) > 0)
			print("GT Torch Collected:", (gtTorchRoom & 0x400) > 0)
			print("GT Raw Count:", gtCount)
		end
		
		if gtCount and (gtTorchRoom & 0x400) == 0 and (gtTorchRoom & 0x8) > 0 then
			gtBK.AcquiredCount = gtCount + 1
		else
			gtBK.AcquiredCount = gtCount
		end
	end
end

function itemFlippedOn(item)
	if os.time() - START_TIME > 5 then
		print(item)
		if item == "sword" then
			local object = Tracker:FindObjectForCode(item)
			if object.CurrentStage == 3 then
				sendExternalMessage("item", "bacon")
				START_TIME = os.time()
			elseif object.CurrentStage == 4 then
				sendExternalMessage("item", "butter")
				START_TIME = os.time()
			end
		elseif item == "np_bow" then
			sendExternalMessage("item", "bow")
			START_TIME = os.time()
		elseif item == "hammer" or item == "flute" or item == "boots"
			or item == "lamp" or item == "halfmagic" or item == "firerod" or item == "icerod"
			or item == "bombos" or item == "ether" or item == "quake"
			or item == "mushroom" or item == "powder" or item == "shovel"
			or item == 'mirror' or item == "hookshot" or item == "book" or item == "cape" then
			sendExternalMessage("item", item)
			START_TIME = os.time()
		end
	end
end

function sendExternalMessage(filename, value)
	if value then
		if (filename == "item" and AUTOTRACKER_ENABLE_EXTERNAL_ITEM_FILE) or (filename == "dungeon" and AUTOTRACKER_ENABLE_EXTERNAL_DUNGEON_IMAGE) then
			local file = io.open("C:/Users/"..os.getenv("USERNAME").."/Documents/EmoTracker/"..filename..".txt", "w+")
			if file then
				io.output(file)
				io.write(value)
				io.close(file)
			end
		end
	end
end

function updateHeartPiecesFromMemorySegment(segment)
	if not isInGame() then
		return false
	end

	InvalidateReadCaches()

	if AUTOTRACKER_ENABLE_ITEM_TRACKING then
		updateConsumableItemFromByte(segment, "heartpiece", 0x7ef448)
	end
end

function updateHeartContainersFromMemorySegment(segment)
	if not isInGame() then
		return false
	end

	InvalidateReadCaches()

	if AUTOTRACKER_ENABLE_ITEM_TRACKING then
		local pieces = Tracker:FindObjectForCode("heartpiece")
		local containers = Tracker:FindObjectForCode("heartcontainer")

		if pieces and containers then
			local maxHealth = (ReadU8(segment, 0x7ef36c) // 8) - 3
			
			if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
				print("Pieces: ", pieces.AcquiredCount)
				print("Max Health: ", maxHealth)
			end

			containers.AcquiredCount = maxHealth - (pieces.AcquiredCount // 4)
		end
	end
end

AUTOTRACKER_STATS_MARKDOWN_FORMAT = [===[
### Post-Game Summary

Stat | Value
--|-
**Collection Rate** | %d/216
**Deaths** | %d
**Bonks** | %d
**Total Time** | %02d:%02d:%02d.%02d
]===]

function read32BitTimer(segment, baseAddress)
	local timer = 0;
	timer = timer | (ReadU8(segment, baseAddress + 3) << 24)
	timer = timer | (ReadU8(segment, baseAddress + 2) << 16)
	timer = timer | (ReadU8(segment, baseAddress + 1) << 8)
	timer = timer | (ReadU8(segment, baseAddress + 0) << 0)

	local hours = timer // (60 * 60 * 60)
	local minutes = (timer % (60 * 60 * 60)) // (60 * 60)
	local seconds = (timer % (60 * 60)) // (60)
	local frames = timer % 60

	return hours, minutes, seconds, frames
end

function updateStatisticsFromMemorySegment(segment)

	if not isInGame() then
		return false
	end

	InvalidateReadCaches()

	if not AUTOTRACKER_HAS_DONE_POST_GAME_SUMMARY then
		-- Read completion timer
		local hours, minutes, seconds, frames = read32BitTimer(segment, 0x7ef43e)

		local collection_rate = ReadU8(segment, 0x7ef423)
		local deaths = ReadU8(segment, 0x7ef449)
		local bonks = ReadU8(segment, 0x7ef420)

		local markdown = string.format(AUTOTRACKER_STATS_MARKDOWN_FORMAT, collection_rate, deaths, bonks, hours, minutes, seconds, frames)
		ScriptHost:PushMarkdownNotification(NotificationType.Celebration, markdown)
	end

	AUTOTRACKER_HAS_DONE_POST_GAME_SUMMARY = true

	return true
end

-- Run the in-game status check more frequently (every 250ms) to catch save/quit scenarios more effectively
ScriptHost:AddMemoryWatch("LTTP In-Game status", 0x7e0010, 0x90, updateInGameStatusFromMemorySegment, 250)
ScriptHost:AddMemoryWatch("LTTP Item Data", 0x7ef340, 0x90, updateItemsFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Room Data", 0x7ef000, 0x250, updateRoomsFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Overworld Event Data", 0x7ef280, 0x82, updateOverworldEventsFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP NPC Item Data", 0x7ef410, 2, updateNPCItemFlagsFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Heart Piece Data", 0x7ef448, 1, updateHeartPiecesFromMemorySegment)
ScriptHost:AddMemoryWatch("LTTP Heart Container Data", 0x7ef36c, 1, updateHeartContainersFromMemorySegment)

SEGMENT_ROOMDATA = ScriptHost:AddMemoryWatch("LTTP Dungeon Data", 0x7ef000, 0x250, updateDungeonItemsFromMemorySegment)
SEGMENT_DUNGEONITEMS = ScriptHost:AddMemoryWatch("LTTP Dungeon Data", 0x7ef364, 0x26, updateDungeonItemsFromMemorySegment)
--ScriptHost:AddMemoryWatch("LTTP Dungeon", 0x7e040c, 1, updateDungeonFromMemorySegment) --switch to this if memory address becomes available
SEGMENT_OWID = ScriptHost:AddMemoryWatch("LTTP Dungeon", 0x7e008a, 2, updateDungeonFromMemorySegment)
SEGMENT_LASTROOMID = ScriptHost:AddMemoryWatch("LTTP Dungeon", 0x7e00a0, 2, updateDungeonFromMemorySegment)
SEGMENT_GTBIGKEYCOUNT = ScriptHost:AddMemoryWatch("LTTP GT BK Game", 0x7ef42a, 1, updateGTBKFromMemorySegment)
SEGMENT_GTTORCHROOM = ScriptHost:AddMemoryWatch("LTTP GT BK Game", 0x7ef118, 2, updateGTBKFromMemorySegment) --GT Torch Visit
ScriptHost:AddMemoryWatch("LTTP GT BK Game", 0x7ef0d6, 2, updateGTBKFromMemorySegment) --GT Gauntlet Climb Update
