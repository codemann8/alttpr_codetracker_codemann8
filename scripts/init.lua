--User Config
CONFIG = {}
BACKUP = {}
ScriptHost:LoadScript("settings/documents.lua")
ScriptHost:LoadScript("settings/defaults.lua")
ScriptHost:LoadScript("settings/layout.lua")
ScriptHost:LoadScript("settings/broadcast.lua")
ScriptHost:LoadScript("settings/tracking.lua")
ScriptHost:LoadScript("settings/fileio.lua")
ScriptHost:LoadScript("settings/experimental.lua")
ScriptHost:LoadScript("settings/backup.lua")


--Classes & SDK
ScriptHost:LoadScript("scripts/sdk/base/class.lua")
ScriptHost:LoadScript("scripts/sdk/base/custom_item.lua")
if Tracker.ActiveVariantUID ~= "vanilla" then
    ScriptHost:LoadScript("scripts/sdk/chestcounter.lua")
    ScriptHost:LoadScript("scripts/sdk/surrogateitem.lua")
    ScriptHost:LoadScript("scripts/sdk/actionitem.lua")
end

--Custom Classes
ScriptHost:LoadScript("scripts/custom/setting.lua")
if Tracker.ActiveVariantUID ~= "vanilla" then
    ScriptHost:LoadScript("scripts/custom/savestorage.lua")
    ScriptHost:LoadScript("scripts/custom/extchestcounter.lua")
    ScriptHost:LoadScript("scripts/custom/mapcompassbk.lua")
    ScriptHost:LoadScript("scripts/custom/dykclose.lua")
    ScriptHost:LoadScript("scripts/custom/trackersync.lua")
    ScriptHost:LoadScript("scripts/custom/trackerrestore.lua")
    if Tracker.ActiveVariantUID == "full_tracker" then
        ScriptHost:LoadScript("scripts/custom/owswap.lua")

        ScriptHost:LoadScript("scripts/custom/doors/roomgroupselect.lua")
        ScriptHost:LoadScript("scripts/custom/doors/roomselectslot.lua")
        ScriptHost:LoadScript("scripts/custom/doors/doorslotselect.lua")
        ScriptHost:LoadScript("scripts/custom/doors/doorslot.lua")
    end
    ScriptHost:LoadScript("scripts/custom/doors/doordungeonselect.lua")
    ScriptHost:LoadScript("scripts/custom/doors/doortotalchest.lua")
    
    ScriptHost:LoadScript("scripts/custom/modes/worldstatemode.lua")
    ScriptHost:LoadScript("scripts/custom/modes/keysanitymode.lua")
    ScriptHost:LoadScript("scripts/custom/modes/entranceshufflemode.lua")
    ScriptHost:LoadScript("scripts/custom/modes/doorshufflemode.lua")
    ScriptHost:LoadScript("scripts/custom/modes/owlayoutmode.lua")
    ScriptHost:LoadScript("scripts/custom/modes/owmixedmode.lua")
    ScriptHost:LoadScript("scripts/custom/modes/retromode.lua")
    ScriptHost:LoadScript("scripts/custom/modes/poolmode.lua")
    ScriptHost:LoadScript("scripts/custom/modes/poolpotmode.lua")
    ScriptHost:LoadScript("scripts/custom/modes/glitchmode.lua")
    ScriptHost:LoadScript("scripts/custom/modes/racemode.lua")
    ScriptHost:LoadScript("scripts/custom/modes/gtcrystalreq.lua")
end


--Essentials
ScriptHost:LoadScript("scripts/static.lua")
ScriptHost:LoadScript("scripts/global.lua")
ScriptHost:LoadScript("scripts/events.lua")
if _VERSION == "Lua 5.3" then
    ScriptHost:LoadScript("scripts/fileio.lua")
    ScriptHost:LoadScript("scripts/autotracking.lua")
else
    print("Auto-tracker is unsupported by your tracker version")
end

--Items
Tracker:AddItems("items/items.json")
if Tracker.ActiveVariantUID == "full_tracker" then
    Tracker:AddItems("items/misc.json")
end
if Tracker.ActiveVariantUID ~= "vanilla" then
    Tracker:AddItems("items/modes.json")
    Tracker:AddItems("items/labels.json")
    Tracker:AddItems("items/dungeon_items.json")
end
Tracker:AddItems("items/prizes.json")

if Tracker.ActiveVariantUID == "full_tracker" then
    Tracker:AddItems("items/regions.json")
    Tracker:AddItems("items/capture.json")
end

--Load Custom Item Instances
loadSettings()
if Tracker.ActiveVariantUID ~= "vanilla" then
    loadMCBK()
    loadModes()
    loadSwaps()
    loadDungeonChests()
    loadDoorObjects()
    loadMisc()
end

--Item Logic
ScriptHost:LoadScript("scripts/logic_custom.lua")
ScriptHost:LoadScript("scripts/logic.lua")


--Maps
if Tracker.ActiveVariantUID == "full_tracker" then
    Tracker:AddMaps("maps/overworld.json")
    Tracker:AddMaps("maps/dungeons.json")
end

--Map Locations
if Tracker.ActiveVariantUID == "full_tracker" then
    Tracker:AddLocations("locations/regions.json")
    Tracker:AddLocations("locations/tileregions.json")
    Tracker:AddLocations("locations/edges.json")
    Tracker:AddLocations("locations/bosses.json")
    Tracker:AddLocations("locations/dungeons.json")
    Tracker:AddLocations("locations/dungeonmaps.json")
    Tracker:AddLocations("locations/entrances.json")
    Tracker:AddLocations("locations/overworld.json")
    Tracker:AddLocations("locations/underworld.json")
    Tracker:AddLocations("locations/ghosts.json")
elseif Tracker.ActiveVariantUID == "items_only" then
    Tracker:AddLocations("locations/dungeons.json")
    Tracker:AddLocations("locations/dungeonmaps.json")
end

--Layouts
if Tracker.ActiveVariantUID == "full_tracker" then
    Tracker:AddLayouts("layouts/capture.json")
    Tracker:AddLayouts("layouts/maps.json")
end

Tracker:AddLayouts("layouts/settings.json")
if Tracker.ActiveVariantUID == "full_tracker" then
    Tracker:AddLayouts("layouts/doors.json")
end
Tracker:AddLayouts("layouts/layouts_custom.json")
Tracker:AddLayouts("layouts/shared_base.json")

if Tracker.ActiveVariantUID ~= "vanilla" then
    Tracker:AddLayouts("layouts/dungeons_alt.json")
    Tracker:AddLayouts("layouts/dungeons.json")
end

Tracker:AddLayouts("layouts/dock_thin.json")
Tracker:AddLayouts("layouts/dock.json")

Tracker:AddLayouts("layouts/tracker.json")


--Broadcast
Tracker:AddLayouts("layouts/broadcast_custom.json")
Tracker:AddLayouts("layouts/broadcast.json")


--Initialize variables and object states
initialize()