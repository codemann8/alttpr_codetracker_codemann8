--Config
ScriptHost:LoadScript("scripts/settings.lua")

--Items
ScriptHost:LoadScript("scripts/class.lua")
ScriptHost:LoadScript("scripts/custom_item.lua")
ScriptHost:LoadScript("scripts/mapcompassbk.lua")

Tracker:AddItems("items/common.json")
Tracker:AddItems("items/regions.json")
Tracker:AddItems("items/keysanity_dungeon_items.json")
Tracker:AddItems("items/keys.json")
Tracker:AddItems("items/labels.json")

MapCompassBK("Hyrule Castle Map/Compass/Big Key", "hc")
MapCompassBK("Eastern Palace Map/Compass/Big Key", "ep")
MapCompassBK("Desert Palace Map/Compass/Big Key", "dp")
MapCompassBK("Tower of Hera Map/Compass/Big Key", "toh")
MapCompassBK("Aganihm's Tower Map/Compass/Big Key", "at")
MapCompassBK("Palace of Darkness Map/Compass/Big Key", "pod")
MapCompassBK("Swamp Palace Map/Compass/Big Key", "sp")
MapCompassBK("Skull Woods Map/Compass/Big Key", "sw")
MapCompassBK("Thieves Town Map/Compass/Big Key", "tt")
MapCompassBK("Ice Palace Map/Compass/Big Key", "ip")
MapCompassBK("Misery Mire Map/Compass/Big Key", "mm")
MapCompassBK("Turtle Rock Map/Compass/Big Key", "tr")
MapCompassBK("Ganon's Tower Map/Compass/Big Key", "gt")

if Tracker.ActiveVariantUID == "items_only" then
	Tracker:AddLayouts("layouts/layouts_custom.json")
	Tracker:AddLayouts("layouts/layouts_shared.json")
	Tracker:AddLayouts("layouts/dungeon_grid.json")
	Tracker:AddLayouts("layouts/tracker.json")
	Tracker:AddLayouts("layouts/broadcast_standard.json")
else
	--Maps
	Tracker:AddMaps("maps/maps.json")
	Tracker:AddItems("items/rooms.json")

	--Layouts
	Tracker:AddLayouts("layouts/layouts_capture.json")

	--Map Locations
	ScriptHost:LoadScript("scripts/logic_common.lua")
	ScriptHost:LoadScript("scripts/logic_custom.lua")
	
	Tracker:AddLocations("locations/regions.json")
	Tracker:AddLocations("locations/dungeons.json")
	Tracker:AddLocations("locations/underworld.json")
	Tracker:AddLocations("locations/overworld.json")
	
	Tracker:AddItems("items/chest_proxies.json")
	ScriptHost:LoadScript("scripts/keysanitymode.lua")
	KeysanityMode(Tracker.ActiveVariantUID)

	--Tracker Layout
	Tracker:AddLayouts("layouts/layouts_custom.json")
	Tracker:AddLayouts("layouts/layouts_shared.json")

	Tracker:AddLayouts("layouts/dungeon_keys_grid.json")
	Tracker:AddLayouts("layouts/entrance_grid.json")

	Tracker:AddLayouts("layouts/tracker.json")

	--Broadcast Layout
	Tracker:AddLayouts("layouts/keys.json")
	if Tracker.ActiveVariantUID == "mystery" or Tracker.ActiveVariantUID == "items_only_keys" then
		Tracker:AddLayouts("layouts/broadcast_keysanity.json")
	else
		Tracker:AddLayouts("layouts/maps.json")
		if string.find(Tracker.ActiveVariantUID, "er_") then
			Tracker:AddLayouts("layouts/broadcast_erkeysanity.json")
		else
			Tracker:AddLayouts("layouts/broadcast_keysanity.json")
		end
	end
end

if _VERSION == "Lua 5.3" then
	ScriptHost:LoadScript("scripts/fileio.lua")
	ScriptHost:LoadScript("scripts/autotracking.lua")
else		
	print("Auto-tracker is unsupported by your tracker version")
end
