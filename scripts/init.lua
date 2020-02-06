--Config
ScriptHost:LoadScript("scripts/settings.lua")

--Items
ScriptHost:LoadScript("scripts/class.lua")
ScriptHost:LoadScript("scripts/custom_item.lua")
ScriptHost:LoadScript("scripts/mapcompassbk.lua")

Tracker:AddItems("items/common.json")
Tracker:AddItems("items/regions.json")
if string.find(Tracker.ActiveVariantUID, "keys") then
	Tracker:AddItems("items/keysanity_dungeon_items.json")
else
	Tracker:AddItems("items/dungeon_items.json")
end
Tracker:AddItems("items/keys.json")
Tracker:AddItems("items/labels.json")

MapCompassBK("Hyrule Castle Map/Compass/Big Key", "hc")
MapCompassBK("Eastern Palace Map/Compass/Big Key", "ep")
MapCompassBK("Desert Palace Map/Compass/Big Key", "dp")
MapCompassBK("Tower of Hera Map/Compass/Big Key", "toh")
MapCompassBK("Palace of Darkness Map/Compass/Big Key", "pod")
MapCompassBK("Swamp Palace Map/Compass/Big Key", "sp")
MapCompassBK("Skull Woods Map/Compass/Big Key", "sw")
MapCompassBK("Thieves Town Map/Compass/Big Key", "tt")
MapCompassBK("Ice Palace Map/Compass/Big Key", "ip")
MapCompassBK("Misery Mire Map/Compass/Big Key", "mm")
MapCompassBK("Turtle Rock Map/Compass/Big Key", "tr")
MapCompassBK("Ganon's Tower Map/Compass/Big Key", "gt")

--Map Locations
if not (string.find(Tracker.ActiveVariantUID, "items_only")) then
	ScriptHost:LoadScript("scripts/logic_common.lua")
	ScriptHost:LoadScript("scripts/logic_custom.lua")
	Tracker:AddItems("items/rooms.json")
	Tracker:AddMaps("maps/maps.json")

	if string.find(Tracker.ActiveVariantUID, "er_") and not string.find(Tracker.ActiveVariantUID, "inverted") then
		Tracker:AddLocations("er_locations/overworld.json")
	elseif string.find(Tracker.ActiveVariantUID, "inverted") and not string.find(Tracker.ActiveVariantUID, "er_") then
		Tracker:AddLocations("inverted_locations/overworld.json")
	else
		Tracker:AddLocations("locations/overworld.json")
	end
	Tracker:AddLocations("locations/dungeons.json")		
end
Tracker:AddItems("items/chest_proxies.json")

--Tracker Layout
Tracker:AddLayouts("layouts/layouts_custom.json")
Tracker:AddLayouts("layouts/layouts_shared.json")
if not (string.find(Tracker.ActiveVariantUID, "keys")) then
	Tracker:AddLayouts("layouts/dungeon_grid.json")
else
	Tracker:AddLayouts("layouts/dungeon_keys_grid.json")
end
if string.find(Tracker.ActiveVariantUID, "er_") then
	Tracker:AddLayouts("layouts/entrance_grid.json")
end

Tracker:AddLayouts("layouts/tracker.json")

--Broadcast Layout
if MAP_ON_BROADCAST_VIEW and not (string.find(Tracker.ActiveVariantUID, "items_only")) then
	Tracker:AddLayouts("layouts/maps.json")
end	
if not (string.find(Tracker.ActiveVariantUID, "keys")) then
	if MAP_ON_BROADCAST_VIEW and string.find(Tracker.ActiveVariantUID, "er_")  then
		Tracker:AddLayouts("layouts/broadcast_standard_custom.json")
	else
		Tracker:AddLayouts("layouts/broadcast_standard.json")
	end
else
	Tracker:AddLayouts("layouts/keys.json")
	if not MAP_ON_BROADCAST_VIEW or not string.find(Tracker.ActiveVariantUID, "er_") then
		Tracker:AddLayouts("layouts/broadcast_keysanity.json")
	else
		Tracker:AddLayouts("layouts/broadcast_erkeysanity.json")
	end
end

if _VERSION == "Lua 5.3" then
	ScriptHost:LoadScript("scripts/fileio.lua")
	ScriptHost:LoadScript("scripts/autotracking.lua")
else		
	print("Auto-tracker is unsupported by your tracker version")
end
