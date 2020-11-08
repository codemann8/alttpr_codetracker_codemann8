START_CLOCK = os.clock()
TRACKER_READY = false




function loadDungeonChests()
    ExtendedConsumableItem("Hyrule Castle Items", "hc", "@Hyrule Castle & Escape")
    ExtendedConsumableItem("Eastern Palace Items", "ep", "@Eastern Palace")
    ExtendedConsumableItem("Desert Palace Items", "dp", "@Desert Palace")
    ExtendedConsumableItem("Tower of Hera Items", "toh", "@Tower of Hera")
    ExtendedConsumableItem("Aganihm's Tower Items", "at", "@Agahnim's Tower")
    ExtendedConsumableItem("Palace of Darkness Items", "pod", "@Palace of Darkness")
    ExtendedConsumableItem("Swamp Palace Items", "sp", "@Swamp Palace")
    ExtendedConsumableItem("Skull Woods Items", "sw", "@Skull Woods")
    ExtendedConsumableItem("Thieves Town Items", "tt", "@Thieves Town")
    ExtendedConsumableItem("Ice Palace Items", "ip", "@Ice Palace")
    ExtendedConsumableItem("Misery Mire Items", "mm", "@Misery Mire")
    ExtendedConsumableItem("Turtle Rock Items", "tr", "@Turtle Rock")
    ExtendedConsumableItem("Ganon's Tower Items", "gt", "@Ganon's Tower")
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

function initGlobalVars()
    AUTOTRACKER_ON = false

    OBJ_MODULE = Tracker:FindObjectForCode("module")
    OBJ_OWAREA = Tracker:FindObjectForCode("owarea")
    OBJ_DUNGEON = Tracker:FindObjectForCode("dungeon")
    OBJ_ROOM = Tracker:FindObjectForCode("room")

    if Tracker.ActiveVariantUID ~= "items_only" then
        OBJ_WORLDSTATE = Tracker:FindObjectForCode("world_state_mode")
        OBJ_KEYSANITY_SMALL = Tracker:FindObjectForCode("keysanity_smallkey")
        OBJ_KEYSANITY_BIG = Tracker:FindObjectForCode("keysanity_bigkey")
        OBJ_ENTRANCE = Tracker:FindObjectForCode("entrance_shuffle")
        OBJ_DOORSHUFFLE = Tracker:FindObjectForCode("door_shuffle")
        OBJ_RETRO = Tracker:FindObjectForCode("retro_mode")
        OBJ_POOL = Tracker:FindObjectForCode("pool_mode")
        OBJ_RACEMODE = Tracker:FindObjectForCode("race_mode")

        OBJ_DOORDUNGEON = Tracker:FindObjectForCode("door_dungeonselect")
        OBJ_DOORCHEST = Tracker:FindObjectForCode("door_totalchest")

        if Tracker.ActiveVariantUID == "items_only_keys" then
            Tracker:FindObjectForCode("keysanity_map_surrogate").ItemState:setState(1)
            Tracker:FindObjectForCode("keysanity_compass_surrogate").ItemState:setState(1)
            Tracker:FindObjectForCode("keysanity_smallkey_surrogate").ItemState:setState(1)
            Tracker:FindObjectForCode("keysanity_bigkey_surrogate").ItemState:setState(1)
        end

        --Auto-Toggle Race Mode
        if AUTOTRACKER_ENABLE_RACE_MODE_BY_DEFAULT then
            Tracker:FindObjectForCode("race_mode_surrogate").ItemState:setState(1)
        end

        TRACKER_READY = true

        updateIcons()

        local message = "To get started: Select a Game Mode by clicking the Gear icon in the Items pane"
        ScriptHost:PushMarkdownNotification(NotificationType.Message, message)
    end

    TRACKER_READY = true
end

function updateIcons()
    if TRACKER_READY then
        local dungeons =  {"hc", "ep", "dp", "at", "sp", "pod", "mm", "sw", "ip", "toh", "tt", "tr", "gt"}
        local chestkeys = { 1,    0,    1,    2,    1,    6,     3,    3,    2,    1,     1,    4,    4  }
        local keydrops =  { 3,    2,    3,    2,    5,    0,     3,    2,    4,    0,     2,    2,    4  }
        for i = 1, #dungeons do
            local item = Tracker:FindObjectForCode(dungeons[i] .. "_item").ItemState
            local key = Tracker:FindObjectForCode(dungeons[i] .. "_smallkey")
            if OBJ_DOORSHUFFLE.CurrentStage == 2 then
                if item.MaxCount ~= 99 then
                    item.MaxCount = 99
                    item.AcquiredCount = 99
                end
                item.SwapActions = true
                key.MaxCount = 99
                key.Icon = ImageReference:FromPackRelativePath("images/SmallKey2.png", "@disabled")

                if (OBJ_POOL.CurrentStage == 0 and dungeons[i] == "hc") or dungeons[i] == "at" then
                    Tracker:FindObjectForCode(dungeons[i] .. "_bigkey").Icon = ImageReference:FromPackRelativePath("images/BigKey.png", "@disabled")
                end
            else
                key.MaxCount = chestkeys[i]
                if OBJ_POOL.CurrentStage > 0 then
                    key.MaxCount = key.MaxCount + keydrops[i]
                end

                if key.MaxCount == 0 then
                    key.Icon = ""
                end

                if OBJ_POOL.CurrentStage > 0 and dungeons[i] == "hc" then
                    Tracker:FindObjectForCode(dungeons[i] .. "_bigkey").Icon = ImageReference:FromPackRelativePath("images/BigKey.png", (not Tracker:FindObjectForCode(dungeons[i] .. "_bigkey").Active and "@disabled" or ""))
                end
                
                if (OBJ_POOL.CurrentStage == 0 and dungeons[i] == "hc") or dungeons[i] == "at" then
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
                if OBJ_POOL.CurrentStage > 0 then
                    item.MaxCount = item.MaxCount + keydrops[i] + (dungeons[i] == "hc" and 1 or 0)
                end

                if Tracker:FindObjectForCode("keysanity_map").CurrentStage == 0 and dungeons[i] ~= "at" then
                    item.MaxCount = item.MaxCount - 1
                end
                if Tracker:FindObjectForCode("keysanity_compass").CurrentStage == 0 and dungeons[i] ~= "hc" and dungeons[i] ~= "at" then
                    item.MaxCount = item.MaxCount - 1
                end
                if OBJ_KEYSANITY_SMALL.CurrentStage == 0 and key then
                    item.MaxCount = item.MaxCount - key.MaxCount
                end
                if OBJ_KEYSANITY_BIG.CurrentStage == 0 and dungeons[i] ~= "at" and not (dungeons[i] == "hc" and OBJ_POOL.CurrentStage == 0) then
                    item.MaxCount = item.MaxCount - 1
                end

                item.AcquiredCount = math.max(item.MaxCount - found, 0)

                --Link Dungeon Locations to Chest Items
                item:setProperty("section", Tracker:FindObjectForCode(item:getProperty("sectionName")))
                item:UpdateBadgeAndIcon()

                item.SwapActions = false
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

            if OBJ_KEYSANITY_SMALL.CurrentStage == 2 then
                key.Icon = ""
                key.BadgeText = nil
                key.IgnoreUserInput = true
            else
                if key.MaxCount > 0 then
                    key.DisplayAsFractionOfMax = true
                    key.DisplayAsFractionOfMax = false
                end
                key.IgnoreUserInput = false
            end
        end

        local gtbk = Tracker:FindObjectForCode("gt_bkgame")
        if OBJ_DOORSHUFFLE.CurrentStage == 0 then
            if OBJ_POOL.CurrentStage == 0 then
                gtbk.MaxCount = 22
            else
                gtbk.MaxCount = 25
            end
        elseif OBJ_DOORSHUFFLE.CurrentStage == 1 then
            if OBJ_POOL.CurrentStage == 0 then
                gtbk.MaxCount = 27
            else
                gtbk.MaxCount = 31
            end
        else
            gtbk.MaxCount = 99
        end

        OBJ_DOORDUNGEON.ItemState:updateIcon()
        OBJ_DOORCHEST.ItemState:updateIcon()
    end
end
