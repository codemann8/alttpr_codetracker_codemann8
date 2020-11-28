--Config
ScriptHost:LoadScript("scripts/settings/experimental.lua")
ScriptHost:LoadScript("scripts/settings/tracking.lua")
ScriptHost:LoadScript("scripts/settings/fileio.lua")
ScriptHost:LoadScript("scripts/settings/settings.lua")
ScriptHost:LoadScript("scripts/settings/defaults.lua")

--Essentials
ScriptHost:LoadScript("scripts/global.lua")
ScriptHost:LoadScript("scripts/events.lua")

--SDK
ScriptHost:LoadScript("scripts/sdk/class.lua")
ScriptHost:LoadScript("scripts/sdk/custom_item.lua")
ScriptHost:LoadScript("scripts/sdk/consumableitem.lua")

--Items
Tracker:AddItems("items/common.json")
Tracker:AddItems("items/regions.json")
Tracker:AddItems("items/keysanity_dungeon_items.json")
Tracker:AddItems("items/keys.json")
Tracker:AddItems("items/labels.json")
Tracker:AddItems("items/capturebadges.json")

--Custom Items
ScriptHost:LoadScript("scripts/custom/mapcompassbk.lua")
ScriptHost:LoadScript("scripts/custom/extconsumableitem.lua")

ScriptHost:LoadScript("scripts/custom/surrogateitem.lua")
ScriptHost:LoadScript("scripts/custom/worldstatemode.lua")
ScriptHost:LoadScript("scripts/custom/keysanitymode.lua")
ScriptHost:LoadScript("scripts/custom/entranceshufflemode.lua")
ScriptHost:LoadScript("scripts/custom/doorshufflemode.lua")
ScriptHost:LoadScript("scripts/custom/retromode.lua")
ScriptHost:LoadScript("scripts/custom/poolmode.lua")
ScriptHost:LoadScript("scripts/custom/glitchmode.lua")
ScriptHost:LoadScript("scripts/custom/racemode.lua")

ScriptHost:LoadScript("scripts/custom/gtcrystalreq.lua")
ScriptHost:LoadScript("scripts/custom/goalsetting.lua")
ScriptHost:LoadScript("scripts/custom/doordungeonselect.lua")
ScriptHost:LoadScript("scripts/custom/doortotalchest.lua")
ScriptHost:LoadScript("scripts/custom/dynamicrequirement.lua")

loadMCBK()
loadDungeonChests()
loadDynamicRequirement()

if Tracker.ActiveVariantUID == "items_only" then
    Tracker:AddLayouts("layouts/layouts_base_custom.json")
    Tracker:AddLayouts("layouts/layouts_base_shared.json")
    Tracker:AddLayouts("layouts/layouts_custom.json")
    if LAYOUT_ENABLE_ALTERNATE_DUNGEON_VIEW then
        Tracker:AddLayouts("layouts/layouts_dungeonalt_shared.json")
    end
    Tracker:AddLayouts("layouts/layouts_shared.json")
    Tracker:AddLayouts("layouts/dungeon_grid.json")
    Tracker:AddLayouts("layouts/tracker.json")
    Tracker:AddLayouts("layouts/broadcast_standard.json")
else
    --Maps
    Tracker:AddMaps("maps/maps.json")

    --Layouts
    Tracker:AddLayouts("layouts/layouts_capture.json")

    --Map Locations
    ScriptHost:LoadScript("scripts/logic_common.lua")
    ScriptHost:LoadScript("scripts/logic_custom.lua")

    Tracker:AddLocations("locations/regions.json")
    Tracker:AddLocations("locations/dungeons.json")
    Tracker:AddLocations("locations/dungeonmap.json")
    Tracker:AddLocations("locations/underworld.json")
    Tracker:AddLocations("locations/overworld.json")
    Tracker:AddLocations("locations/ghosts.json")

    --Custom Items
    DoorDungeonSelect()
    DoorTotalChest("Chests", "chest", "item", "images/0058.png")
    DoorTotalChest("Keys", "key", "smallkey", "images/SmallKey2.png")

    WorldStateMode(true):linkSurrogate(WorldStateMode(false))
    KeysanityMode(false, "Map"):linkSurrogate(KeysanityMode(true, "Map"))
    KeysanityMode(false, "Compass"):linkSurrogate(KeysanityMode(true, "Compass"))
    KeysanityMode(false, "Small Key"):linkSurrogate(KeysanityMode(true, "Small Key"))
    KeysanityMode(false, "Big Key"):linkSurrogate(KeysanityMode(true, "Big Key"))
    EntranceShuffleMode(false):linkSurrogate(EntranceShuffleMode(true))
    DoorShuffleMode(false):linkSurrogate(DoorShuffleMode(true))
    RetroMode(false):linkSurrogate(RetroMode(true))
    PoolMode(false):linkSurrogate(PoolMode(true))
    GlitchMode(false):linkSurrogate(GlitchMode(true))
    RaceMode(false):linkSurrogate(RaceMode(true))

    GTCrystalReq()
    GoalSetting()

    --Tracker Layout
    Tracker:AddLayouts("layouts/layouts_base_custom.json") --anything defined here overrides layouts defined in 'layouts_base_shared'
    Tracker:AddLayouts("layouts/layouts_base_shared.json")

    Tracker:AddLayouts("layouts/layouts_custom.json") --anything defined here overrides layouts defined in 'layouts_shared'
    if LAYOUT_ENABLE_ALTERNATE_DUNGEON_VIEW then
        Tracker:AddLayouts("layouts/layouts_dungeonalt_shared.json")
    end
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
Tracker.DisplayAllLocations = PREFERENCE_DISPLAY_ALL_LOCATIONS
Tracker.AlwaysAllowClearing = PREFERENCE_ALWAYS_ALLOW_CLEARING_LOCATIONS
Tracker.PinLocationsOnItemCapture = PREFERENCE_PIN_LOCATIONS_ON_ITEM_CAPTURE
Tracker.AutoUnpinLocationsOnClear = PREFERENCE_AUTO_UNPIN_LOCATIONS_ON_CLEAR

if _VERSION == "Lua 5.3" then
    ScriptHost:LoadScript("scripts/fileio.lua")
    ScriptHost:LoadScript("scripts/autotracking.lua")
else
    print("Auto-tracker is unsupported by your tracker version")
end
