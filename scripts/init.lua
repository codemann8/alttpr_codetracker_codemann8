--Config
ScriptHost:LoadScript("scripts/settings.lua")

--Items
ScriptHost:LoadScript("scripts/global.lua")
ScriptHost:LoadScript("scripts/class.lua")
ScriptHost:LoadScript("scripts/custom_item.lua")

Tracker:AddItems("items/common.json")
Tracker:AddItems("items/regions.json")
Tracker:AddItems("items/keysanity_dungeon_items.json")
Tracker:AddItems("items/keys.json")
Tracker:AddItems("items/labels.json")

--Custom Items
ScriptHost:LoadScript("scripts/custom/mapcompassbk.lua")

ScriptHost:LoadScript("scripts/custom/surrogateitem.lua")
ScriptHost:LoadScript("scripts/custom/worldstatemode.lua")
ScriptHost:LoadScript("scripts/custom/keysanitymode.lua")
ScriptHost:LoadScript("scripts/custom/entranceshufflemode.lua")
ScriptHost:LoadScript("scripts/custom/doorshufflemode.lua")
ScriptHost:LoadScript("scripts/custom/retromode.lua")
ScriptHost:LoadScript("scripts/custom/racemode.lua")

ScriptHost:LoadScript("scripts/custom/gtcrystalreq.lua")
ScriptHost:LoadScript("scripts/custom/goalsetting.lua")
ScriptHost:LoadScript("scripts/custom/doordungeonselect.lua")
ScriptHost:LoadScript("scripts/custom/doortotalchest.lua")
ScriptHost:LoadScript("scripts/custom/dynamicrequirement.lua")

loadMCBK()
loadDynamicRequirement()

if Tracker.ActiveVariantUID == "items_only" then
    Tracker:AddLayouts("layouts/layouts_base_custom.json")
    Tracker:AddLayouts("layouts/layouts_base_shared.json")
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

    --Custom Items
    DoorDungeonSelect()
    DoorTotalChest()

    WorldStateMode(true):linkSurrogate(WorldStateMode(false))
    KeysanityMode(false, "Map"):linkSurrogate(KeysanityMode(true, "Map"))
    KeysanityMode(false, "Compass"):linkSurrogate(KeysanityMode(true, "Compass"))
    KeysanityMode(false, "Small Key"):linkSurrogate(KeysanityMode(true, "Small Key"))
    KeysanityMode(false, "Big Key"):linkSurrogate(KeysanityMode(true, "Big Key"))
    EntranceShuffleMode(false):linkSurrogate(EntranceShuffleMode(true))
    DoorShuffleMode(false):linkSurrogate(DoorShuffleMode(true))
    RetroMode(false):linkSurrogate(RetroMode(true))
    RaceMode(false):linkSurrogate(RaceMode(true))

    GTCrystalReq()
    GoalSetting()

    --Tracker Layout
    Tracker:AddLayouts("layouts/layouts_base_custom.json") --anything defined here overrides layouts defined in 'layouts_base_shared'
    Tracker:AddLayouts("layouts/layouts_base_shared.json")

    Tracker:AddLayouts("layouts/layouts_custom.json") --anything defined here overrides layouts defined in 'layouts_shared'
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

--Load Global Variables
initGlobalVars()

--Default Settings
Tracker.DisplayAllLocations = true
Tracker.AlwaysAllowClearing = true

if _VERSION == "Lua 5.3" then
    ScriptHost:LoadScript("scripts/fileio.lua")
    ScriptHost:LoadScript("scripts/autotracking.lua")
else
    print("Auto-tracker is unsupported by your tracker version")
end
