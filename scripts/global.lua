START_CLOCK = os.clock()

function initGlobalVars()
    OBJ_MODULE = Tracker:FindObjectForCode("module")
    OBJ_OWAREA = Tracker:FindObjectForCode("owarea")
    OBJ_DUNGEON = Tracker:FindObjectForCode("dungeon")
    OBJ_ROOM = Tracker:FindObjectForCode("room")

    if Tracker.ActiveVariantUID ~= "items_only" then
        OBJ_WORLDSTATE = Tracker:FindObjectForCode("world_state_mode")
        OBJ_KEYSANITY = Tracker:FindObjectForCode("keysanity_mode")
        OBJ_ENTRANCE = Tracker:FindObjectForCode("entrance_shuffle")
        OBJ_DOORSHUFFLE = Tracker:FindObjectForCode("door_shuffle")
        OBJ_RACEMODE = Tracker:FindObjectForCode("race_mode")

        OBJ_DOORDUNGEON = Tracker:FindObjectForCode("door_dungeonselect")
        OBJ_DOORCHEST = Tracker:FindObjectForCode("door_totalchest")

        updateIcons()

        local message = "To get started: Select a Game Mode by clicking the Gear icon in the Items pane"
        ScriptHost:PushMarkdownNotification(NotificationType.Message, message)
    end
end

function loadMCBK()
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
end

function loadDynamicRequirement()
    DynamicRequirement("hc", "hc", 1, 923, 983)
    DynamicRequirement("hc", "hc", 2, 1008, 983)
    DynamicRequirement("ep", "eppod", 1, 1840, 862)
    DynamicRequirement("ep", "eppod", 2, 1925, 862)
    DynamicRequirement("dp", "dpmm", 1, 89, 1742)
    DynamicRequirement("dp", "dpmm", 2, 174, 1742)
    DynamicRequirement("toh", "tohgt", 1, 1056, 115)
    DynamicRequirement("toh", "tohgt", 2, 1141, 115)
    DynamicRequirement("at", "at", 1, 923, 627)
    DynamicRequirement("at", "at", 2, 1008, 862)
    DynamicRequirement("pod", "eppod", 1, 1840, 862)
    DynamicRequirement("pod", "eppod", 2, 1925, 862)
    DynamicRequirement("sp", "sp", 1, 860, 1910)
    DynamicRequirement("sp", "sp", 2, 945, 1910)
    DynamicRequirement("sw", "sw", 1, 2, 158)
    DynamicRequirement("sw", "sw", 2, 87, 158)
    DynamicRequirement("tt", "tt", 1, 174, 1018)
    DynamicRequirement("tt", "tt", 2, 259, 1018)
    DynamicRequirement("ip", "ip", 1, 1519, 1785)
    DynamicRequirement("ip", "ip", 2, 1604, 1785)
    DynamicRequirement("mm", "dpmm", 1, 89, 1742)
    DynamicRequirement("mm", "dpmm", 2, 174, 1742)
    DynamicRequirement("tr", "tr", 1, 1809, 196)
    DynamicRequirement("tr", "tr", 2, 1889, 196)
    DynamicRequirement("gt", "tohgt", 1, 1056, 115)
    DynamicRequirement("gt", "tohgt", 2, 1141, 115)
end

function updateIcons()
    local dungeons =  {"hc", "ep", "dp", "at", "sp", "pod", "mm", "sw", "ip", "toh", "tt", "tr", "gt"}
    local chestkeys = { 1,    0,    1,    2,    1,    6,     3,    3,    2,    1,     1,    4,    4  }
    for i = 1, 13 do
        local item = Tracker:FindObjectForCode(dungeons[i] .. "_item")
        local key = Tracker:FindObjectForCode(dungeons[i] .. "_smallkey")
        if OBJ_DOORSHUFFLE.CurrentStage == 2 then
            if item.MaxCount ~= 99 then
                item.MaxCount = 99
                item.AcquiredCount = 0
                item.SwapActions = true
                item.Icon = ImageReference:FromPackRelativePath("images/0058.png")
            end
            key.MaxCount = 99
            key.Icon = ImageReference:FromPackRelativePath("images/SmallKey2.png", "@disabled")

            if dungeons[i] == "hc" or dungeons[i] == "at" then
                Tracker:FindObjectForCode(dungeons[i] .. "_bigkey").Icon = ImageReference:FromPackRelativePath("images/BigKey.png", "@disabled")
            end
        else
            key.MaxCount = chestkeys[i]
            if key.MaxCount == 0 then
                key.Icon = ""
            end
            
            if dungeons[i] == "hc" or dungeons[i] == "at" then
                local bk = Tracker:FindObjectForCode(dungeons[i] .. "_bigkey")
                if bk.Icon ~= "" then
                    bk.Icon = ""
                end
            end

            local found = 0
            if item.MaxCount ~= 99 then
                found = item.MaxCount - item.AcquiredCount
            end

            local chest = Tracker:FindObjectForCode(dungeons[i] .. "_chest")
            item.MaxCount = chest.MaxCount
            if OBJ_KEYSANITY.CurrentStage <= 2 and dungeons[i] ~= "hc" and dungeons[i] ~= "at" then
                item.MaxCount = item.MaxCount - 1
            end
            if OBJ_KEYSANITY.CurrentStage <= 1 and key then
                item.MaxCount = item.MaxCount - key.MaxCount
            end
            if OBJ_KEYSANITY.CurrentStage == 0 then
                if dungeons[i] == "hc" then
                    item.MaxCount = item.MaxCount - 1
                elseif dungeons[i] ~= "at" then
                    item.MaxCount = item.MaxCount - 2
                end
            end

            item.SwapActions = false
            item.AcquiredCount = math.max(item.MaxCount - found, 0)
        end

        if EXPERIMENTAL_ENABLE_DYNAMIC_REQUIREMENTS then
            local dyn = Tracker:FindObjectForCode("dynreq_" .. dungeons[i] .. "1_sur")
            if dyn then
                dyn.ItemState:setState(OBJ_DOORSHUFFLE.CurrentStage == 2 and 1 or 0)
            end
            dyn = Tracker:FindObjectForCode("dynreq_" .. dungeons[i] .. "2_sur")
            if dyn then
                dyn.ItemState:setState(OBJ_DOORSHUFFLE.CurrentStage == 2 and 1 or 0)
            end
        end
    end

    OBJ_DOORDUNGEON.ItemState:updateIcon()
    OBJ_DOORCHEST.ItemState:updateIcon()
end
