DATA = {}
DATA.SettingsHeader = {
    { "defaults.lua", {
        "CONFIG.PREFERENCE_DISPLAY_ALL_LOCATIONS",
        "CONFIG.PREFERENCE_ALWAYS_ALLOW_CLEARING_LOCATIONS",
        "CONFIG.PREFERENCE_PIN_LOCATIONS_ON_ITEM_CAPTURE",
        "CONFIG.PREFERENCE_AUTO_UNPIN_LOCATIONS_ON_CLEAR",
        "CONFIG.PREFERENCE_DEFAULT_RACE_MODE_ON",
        "CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING"
    }},
    { "layout.lua", {
        "CONFIG.LAYOUT_ENABLE_ALTERNATE_DUNGEON_VIEW",
        "CONFIG.LAYOUT_USE_THIN_HORIZONTAL_PANE",
        "CONFIG.LAYOUT_SHOW_MAP_GRIDLINES",
        "CONFIG.LAYOUT_ROOM_SLOT_METHOD"
    }},
    { "broadcast.lua", {
        "CONFIG.BROADCAST_MAP_DIRECTION",
        "CONFIG.BROADCAST_ALTERNATE_LAYOUT"
    }},
    { "tracking.lua", {
        "CONFIG.AUTOTRACKER_ENABLE_AUTOPIN_CURRENT_DUNGEON",
        "CONFIG.AUTOTRACKER_DISABLE_DUNGEON_ITEM_TRACKING",
        "CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING",
        "CONFIG.AUTOTRACKER_DISABLE_OWMIXED_TRACKING",
        "CONFIG.AUTOTRACKER_DISABLE_REGION_TRACKING",
        "CONFIG.AUTOTRACKER_DISABLE_ROM_HEADER"
    }},
    { "fileio.lua", {
        "CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_ITEM_FILE",
        "CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_DUNGEON_IMAGE",
        "CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_HEALTH_FILE"
    }}
}

DATA.SettingsData = {
    ["defaults.lua"] = {
        ["CONFIG.PREFERENCE_DISPLAY_ALL_LOCATIONS"] =           {"Show All Locations",                   "settings_base_showlocations",     2, true,  CONFIG.PREFERENCE_DISPLAY_ALL_LOCATIONS},
        ["CONFIG.PREFERENCE_ALWAYS_ALLOW_CLEARING_LOCATIONS"] = {"Always Allow Clearing Locations",      "settings_base_allowclearing",     2, true,  CONFIG.PREFERENCE_ALWAYS_ALLOW_CLEARING_LOCATIONS},
        ["CONFIG.PREFERENCE_PIN_LOCATIONS_ON_ITEM_CAPTURE"] =   {"Auto Pin On Item Capture",             "settings_base_autopincapture",    2, false, CONFIG.PREFERENCE_PIN_LOCATIONS_ON_ITEM_CAPTURE},
        ["CONFIG.PREFERENCE_AUTO_UNPIN_LOCATIONS_ON_CLEAR"] =   {"Auto Un-pin On Location Clear",        "settings_base_autounpinclear",    2, false, CONFIG.PREFERENCE_AUTO_UNPIN_LOCATIONS_ON_CLEAR},
        ["CONFIG.PREFERENCE_DEFAULT_RACE_MODE_ON"] =            {"Race Mode Default",                    "settings_base_racemode",          2, false, CONFIG.PREFERENCE_DEFAULT_RACE_MODE_ON},
        ["CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING"] =            {"Enable Debug Logging",                 "settings_base_debug",             2, false, CONFIG.PREFERENCE_ENABLE_DEBUG_LOGGING}
    },
    ["layout.lua"] = {
        ["CONFIG.LAYOUT_ENABLE_ALTERNATE_DUNGEON_VIEW"] =       {"Enable Traditional Dungeon Layout",    "settings_layout_altdungeon",      2, false, CONFIG.LAYOUT_ENABLE_ALTERNATE_DUNGEON_VIEW},
        ["CONFIG.LAYOUT_USE_THIN_HORIZONTAL_PANE"] =            {"Enable Thin Horizontal Pane",          "settings_layout_thinhoriz",       2, false, CONFIG.LAYOUT_USE_THIN_HORIZONTAL_PANE},
        ["CONFIG.LAYOUT_SHOW_MAP_GRIDLINES"] =                  {"Show Map Gridlines",                   "settings_layout_showgridlines",   2, false, CONFIG.LAYOUT_SHOW_MAP_GRIDLINES},
        ["CONFIG.LAYOUT_ROOM_SLOT_METHOD"] =                    {"Door Rando Slot Method",               "settings_layout_doorslot",        3, 1,     CONFIG.LAYOUT_ROOM_SLOT_METHOD}
    },
    ["broadcast.lua"] = {
        ["CONFIG.BROADCAST_MAP_DIRECTION"] =                    {"Map Direction",                        "settings_broadcast_mapdirection", 5, 1,     CONFIG.BROADCAST_MAP_DIRECTION},
        ["CONFIG.BROADCAST_ALTERNATE_LAYOUT"] =                 {"Alternate Layout",                     "settings_broadcast_altlayout",    3, 1,     CONFIG.BROADCAST_ALTERNATE_LAYOUT}
    },
    ["tracking.lua"] = {
        ["CONFIG.AUTOTRACKER_ENABLE_AUTOPIN_CURRENT_DUNGEON"] = {"Auto Pin Current Dungeon",             "settings_auto_pindungeon",        2, false, CONFIG.AUTOTRACKER_ENABLE_AUTOPIN_CURRENT_DUNGEON},
        ["CONFIG.AUTOTRACKER_DISABLE_DUNGEON_ITEM_TRACKING"] =  {"Disable Auto Dungeon Item Tracking",   "settings_auto_dungeon_item",      2, false, CONFIG.AUTOTRACKER_DISABLE_DUNGEON_ITEM_TRACKING},
        ["CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING"] =      {"Disable Auto Location Tracking",       "settings_auto_location",          2, false, CONFIG.AUTOTRACKER_DISABLE_LOCATION_TRACKING},
        ["CONFIG.AUTOTRACKER_DISABLE_OWMIXED_TRACKING"] =       {"Disable Auto OW Tile Swap Tracking",   "settings_auto_owmixed",           2, false, CONFIG.AUTOTRACKER_DISABLE_OWMIXED_TRACKING},
        ["CONFIG.AUTOTRACKER_DISABLE_REGION_TRACKING"] =        {"Disable Auto Region Tracking",         "settings_auto_region",            2, false, CONFIG.AUTOTRACKER_DISABLE_REGION_TRACKING},
        ["CONFIG.AUTOTRACKER_DISABLE_ROM_HEADER"] =             {"Disable ROM Header Check",             "settings_auto_header",            2, false, CONFIG.AUTOTRACKER_DISABLE_ROM_HEADER}
    },
    ["fileio.lua"] = {
        ["CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_ITEM_FILE"] =      {"Enable External Item File",            "settings_fileio_item",            2, false, CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_ITEM_FILE},
        ["CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_DUNGEON_IMAGE"] =  {"Enable External Dungeon File",         "settings_fileio_dungeon",         2, false, CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_DUNGEON_IMAGE},
        ["CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_HEALTH_FILE"] =    {"Enable External Health File",          "settings_fileio_health",          2, false, CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_HEALTH_FILE}
    }
}

DATA.DykTexts = {
    {
        "You don't need to chroma-key filter to remove the background color.",
        "When you install NDI and the NDI plugin for OBS, you can add NDI",
        "sources, which EmoTracker supports! This allows you to capture the",
        "Broadcast View without the window background included.",
        "For more info and support, visit the EmoTracker Discord."
    },
    {
        "You don't have to window capture the main EmoTracker window.",
        "By pressing F2, you can open the Broadcast View, which is a better,",
        "more optimized display for your audience.",
        "For more info and support, press F1 to view the Readme."
    },
    {
        "You can make personal customizations to your favorite trackers!",
        "EmoTracker is built to be customizable. Each tracker will vary, but any",
        "tracker can be customized by Exporting Overrides, and editting those",
        "files with a text editor.",
        "For more specific info on customizations, press F1 to view the Readme."
    },
    {
        "Made a mistake?",
        "Using Ctrl+Z will Undo your last action.",
        "For more info and support, press F1 to view the Readme."
    },
    {
        "Not sure how much of a Dungeon you can clear?",
        "When you hold left-click on a Map Location, it will expand out and",
        "show all the specific chests in the Dungeon. Each grouping of chests",
        "will show you the logical accessibility by the color of the text.",
        "For more info and support, press F1 to view the Readme."
    },
    {
        "Don't quite like something with the tracker?",
        "Good news! Many options are available to choose from in the Settings",
        "tab. You can change the way some things display in the layout,",
        "change the way some things function, and more!",
        "For more info and support, press F1 to view the Readme."
    },
    {
        "Have ideas/concerns for the tracker?",
        "Join the Discord for this tracker package! We accept feedback and also",
        "offer support to answer any questions you might have.",
        "To find a link to the Discord, press F1 to view the Readme."
    },
    {
        "Don't like how the Dungeons are displayed?",
        "Good news! There is an option to switch it to a more traditional,",
        "alternate layout. This, like many other options, can be changed in",
        "the Settings tab.",
        "For more info and support, press F1 to view the Readme."
    },
    {
        "Playing Swordless?", "",
        "Right click the Sword item! Doing so will update the logic to show",
        "you the unique places you can access when swords don't exist.", "",
        "For more info and support, press F1 to view the Readme."
    },
    {
        "You can track which medallions lock access to dungeons?",
        "Right click the medallions! Doing so will allow the tracker to show you",
        "your eventual access to those dungeons once you find them.",
        "For more info and support, press F1 to view the Readme."
    },
    {
        "You can track Entrances on the map!",
        "When you hold left-click on a Map Location, you can click the dotted",
        "box, and select the Location you found there. An icon will appear on",
        "the map! Right clicking that icon later will remove it from the map.",
        "For more info and support, press F1 to view the Readme."
    },
    {
        "There are more Mode options than what displays by default.",
        "In the Modes section of the tracker, clicking the Gear icon will open",
        "a popup with ALL of the Modes that can be toggled.",
        "For more info and support, press F1 to view the Readme."
    },
    {
        "You can track Bosses when shuffled!",
        "If you hold left-click on a Dungeon Location on the Map, the bottom",
        "area has a dotted box, where you can select which Boss you found",
        "there. Doing this will also update the logic rules for that Dungeon.",
        "For more info and support, press F1 to view the Readme."
    },
    {
        "You can set Total Chests/Keys for Dungeons in Crossed Door Rando.",
        "By default, the chest counter starts at 0 and increments as you collect",
        "chests. But using the Dungeon Totals tool on the right portion of the",
        "Dungeons section, you can set a Total amount, and the corresponding",
        "Dungeon chest will switch to showing the remaining chests left and",
        "will start decrementing as you collect chests.",
        "For more info on how to use this, press F1 to view the Readme."
    }
}

DATA.DungeonList = { "hc", "ep", "dp", "toh", "at", "pod", "sp", "sw", "tt", "ip", "mm", "tr", "gt" }

DATA.DungeonData = { --prefix = location header, dungeon order index, bitmask, offset, chests, chest keys, key drops
    ["hc"] = { "@Hyrule Castle & Escape", 1, 0xc000, 0x00,  8, 1, 3 },
    ["ep"] = { "@Eastern Palace",         2, 0x2000, 0x02,  6, 0, 2 },
    ["dp"] = { "@Desert Palace",          3, 0x1000, 0x03,  6, 1, 3 },
    ["at"] = { "@Agahnim's Tower",        5, 0x0800, 0x04,  2, 2, 2 },
    ["sp"] = { "@Swamp Palace",           7, 0x0400, 0x05, 10, 1, 5 },
    ["pod"] = { "@Palace of Darkness",    6, 0x0200, 0x06, 14, 6, 0 },
    ["mm"] = { "@Misery Mire",           11, 0x0100, 0x07,  8, 3, 3 },
    ["sw"] = { "@Skull Woods",            8, 0x0080, 0x08,  8, 3, 2 },
    ["ip"] = { "@Ice Palace",            10, 0x0040, 0x09,  8, 2, 4 },
    ["toh"] = { "@Tower of Hera",         4, 0x0020, 0x0a,  6, 1, 0 },
    ["tt"] = { "@Thieves Town",           9, 0x0010, 0x0b,  8, 1, 2 },
    ["tr"] = { "@Turtle Rock",           12, 0x0008, 0x0c, 12, 4, 2 },
    ["gt"] = { "@Ganon's Tower",         13, 0x0004, 0x0d, 27, 4, 4 }
}

DATA.DungeonIdMap = {
    [0] = "hc", --sewer
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

DATA.OverworldIds = {
    0x00, 0x02, 0x03, 0x05, 0x07, 0x0a, 0x0f,
    0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
    0x18, 0x1a, 0x1b, 0x1d, 0x1e, 0x22, 0x25,
    0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f,
    0x30, 0x32, 0x33, 0x34, 0x35, 0x37, 0x3a, 0x3b, 0x3c, 0x3f
}

DATA.MegatileOverworlds = {
    [0x00] = true,
    [0x03] = true,
    [0x05] = true,
    [0x18] = true,
    [0x1b] = true,
    [0x1e] = true,
    [0x30] = true,
    [0x35] = true
}

DATA.OverworldIdRegionMap = {
    [0x02] = "ow_lumberjack", [0x03] = "ow_dm_west_bottom", [0x07] = "ow_trpegs", [0x0a] = "ow_mountainentry",
    [0x11] = "ow_kak_fortune", [0x12] = "ow_kak_pond", [0x13] = "ow_sanc",
    [0x1a] = "ow_forest", [0x1e] = "ow_eastern_palace", [0x22] = "ow_blacksmith", [0x25] = "ow_sand_dunes",
    [0x28] = "ow_race_game", [0x29] = "ow_kak_suburb", [0x2b] = "ow_central_bonk", [0x2c] = "ow_links", [0x2f] = "ow_eastern_nook",
    [0x34] = "ow_statues", [0x37] = "ow_ice_cave", [0x3b] = "ow_dam", [0x3c] = "ow_south_pass",
    [0x42] = "ow_dark_lumberjack", [0x43] = "ow_ddm_west_bottom", [0x47] = "ow_turtlerock", [0x4a] = "ow_bumper", [0x4f] = "ow_catfish",
    [0x51] = "ow_outcast_fortune", [0x52] = "ow_outcast_pond", [0x53] = "ow_chapel", [0x54] = "ow_dark_graveyard",
    [0x5a] = "ow_shield_shop", [0x5e] = "ow_dark_palace", [0x65] = "ow_dark_dunes",
    [0x68] = "ow_dig_game", [0x69] = "ow_archery", [0x6b] = "ow_dark_bonk", [0x6c] = "ow_bomb_shop", [0x6f] = "ow_dark_nook",
    [0x70] = "ow_mire", [0x74] = "ow_hype", [0x77] = "ow_shopping_mall",
    [0x7a] = "ow_swamp_nook", [0x7b] = "ow_swamp", [0x7c] = "ow_dark_south_pass"
}

DATA.OverworldIdItemRegionMap = {
    [0x00] = { "ow_lost_woods_east", {}},
    [0x05] = { "ow_dm_east_bottom", { "hammer", "hookshot" }},
    [0x0f] = { "ow_zora_waterfall", { "flippers" }},
    [0x14] = { "ow_graveyard", { "lift2" }},
    [0x15] = { "ow_river_water", { "flippers" }},
    [0x16] = { "ow_witch_water", { "flippers" }},
    [0x18] = { "ow_kakariko", {}},
    [0x32] = { "ow_cave45", {}},
    [0x33] = { "ow_cwhirlpool_east", { "lift1" }},
    [0x35] = { "ow_hylia_water", { "flippers" }},
    [0x3a] = { "ow_desert_pass", { "lift1" }},
    [0x3f] = { "ow_octoballoon", { "flippers" }},
    [0x50] = { "ow_sw_pass_west", { "lift2" }},
    [0x55] = { "ow_qirn_water", { "flippers" }},
    [0x56] = { "ow_dark_witch_water", { "flippers" }},
    [0x58] = { "ow_outcasts", { "hammer" }},
    [0x62] = { "ow_hammerpegs", { "lift2" }},
    [0x6d] = { "ow_hammer_bridge_top", { "hammer" }},
    [0x72] = { "ow_bush_circle", {}},
    [0x73] = { "ow_dark_cwhirlpool_east", { "lift1" }},
    [0x7f] = { "ow_bomber_corner", { "flippers" }}
}

--TODO: Replace this with a smarter exclusion system
DATA.RoomNonLinearExclusions = {
    [0x09] = {{ 0x1228, 0x12c8, 0x0, 0xc0 }},
    [0x14] = {
        { 0x7e8, 0xa00, 0x370, 0x380 },
        { 0x870, 0x880, 0x1e8, 0x248 },
        { 0x970, 0x980, 0x3a8, 0x418 }
    },
    [0x1a] = {{ 0x13f0, 0x1448, 0x2f0, 0x318 }},
    [0x2a] = {{ 0x15b8, 0x1600, 0x570, 0x580 }},
    [0x35] = {{ 0x9e8, 0xac0, 0x660, 0x690 }},
    [0x36] = {{ 0xdb0, 0xe00, 0x630, 0x688 }},
    [0x37] = {{ 0xf30, 0x1008, 0x660, 0x690 }},
    [0x74] = {{ 0x8a8, 0x948, 0xfa0, 0x1018 }},
    [0x7d] = {{ 0x1b28, 0x1bc8, 0xf30, 0x1018 }},
    [0x8c] = {{ 0x1928, 0x19c8, 0x1130, 0x1218 }},
    [0xa2] = {{ 0x3f0, 0x600, 0x14f0, 0x1500 }},
    [0xbc] = {{ 0x1868, 0x1888, 0x17a8, 0x1820 }},
    [0xd1] = {{ 0x328, 0x3c8, 0x19f0, 0x1bc0 }},
    [0xdb] = {{ 0x1770, 0x1800, 0x1b30, 0x1b80 }}
}

DATA.LinkedRoomSurrogates = {
    [0x0a] = 0x3a,
    [0x54] = 0x34,
    [0x9b] = 0x7d,
    [0xa6] = 0x4d
}

DATA.LinkedOverworldScreens = {
    [0x1a] = "1b",
    [0x1b] = "1a",
    [0x28] = "29",
    [0x29] = "28",
    [0x30] = "3a",
    [0x3a] = "30"
}

DATA.CaptureBadgeEntrances = {
    "@Forest Chest Game/Entrance",
    "@Lumberjack House/Entrance",
    "@Kakariko Fortune Teller/Entrance",
    "@Left Snitch House/Entrance",
    "@Blind's House Entrance/Entrance",
    "@Right Snitch House/Entrance",
    "@Chicken House Entrance/Entrance",
    "@Sick Kid Entrance/Entrance",
    "@Grass House/Entrance",
    "@Bomb Hut/Entrance",
    "@Kakariko Shop Entrance/Entrance",
    "@Tavern Entrance/Entrance",
    "@Smith's House/Entrance",
    "@Library Entrance/Entrance",
    "@Kakariko Chest Game/Entrance",
    "@North Bonk Rocks/Entrance",
    "@Graveyard Ledge Cave/Entrance",
    "@King's Tomb Grave/Entrance",
    "@Witch's Hut/Entrance",
    "@Sahasrahla's Hut Entrance/Entrance",
    "@Trees Fairy Cave/Entrance",
    "@Long Fairy Cave/Entrance",
    "@Checkerboard Cave Entrance/Entrance",
    "@Aginah's Cave Entrance/Entrance",
    "@Cave 45 Entrance/Entrance",
    "@Desert Fairy Cave/Entrance",
    "@Fifty Rupee Cave/Entrance",
    "@Dam Entrance/Entrance",
    "@Central Bonk Rocks/Entrance",
    "@Link's House Entrance/Entrance",
    "@Hype Fairy Cave/Entrance",
    "@Lake Fortune Teller/Entrance",
    "@Mini Moldorm Cave Entrance/Entrance",
    "@Lake Shop Entrance/Entrance",
    "@Upgrade Fairy/Entrance",
    "@Ice Rod Cave Entrance/Entrance",
    "@Cold Bee Cave/Entrance",
    "@Twenty Rupee Cave/Entrance",
    "@Mimic Cave Entrance/Entrance",
    "@Hookshot Fairy Cave/Entrance",
    "@Waterfall Fairy Cave/Entrance",
    "@Dark Lumberjack/Entrance",
    "@Dark Chapel/Entrance",
    "@Shield Shop Entrance/Entrance",
    "@Village of Outcasts Fortune Teller/Entrance",
    "@Chest Game Entrance/Entrance",
    "@C-Shaped House Entrance/Entrance",
    "@Hammer House/Entrance",
    "@Brewery Entrance/Entrance",
    "@Hammer Pegs Cave/Entrance",
    "@Archery Game/Entrance",
    "@Pyramid Fairy Cave/Entrance",
    "@Dark Witch's Hut Entrance/Entrance",
    "@Dark Sahasrahla/Entrance",
    "@Dark Trees Fairy/Entrance",
    "@East Storyteller Cave/Entrance",
    "@Mire Shed Cave/Entrance",
    "@Mire Fairy/Entrance",
    "@Mire Hint Cave/Entrance",
    "@Dark Bonk Rocks/Entrance",
    "@Bomb Shop/Entrance",
    "@Hype Cave Entrance/Entrance",
    "@Dark Lake Shop Entrance/Entrance",
    "@Dark Lake Hylia Fairy/Entrance",
    "@Hamburger Helper Cave/Entrance",
    "@Spike Hint Cave/Entrance",
    "@Dark Mountain Fairy/Entrance",
    "@Spike Cave Entrance/Entrance",
    "@Dark Death Mountain Shop Entrance/Entrance"
}

DATA.CaptureBadgeDungeons = {
    "@Castle Left Entrance/Entrance",
    "@Agahnim's Tower Entrance/Entrance",
    "@Castle Right Entrance/Entrance",
    "@Castle Main Entrance/Entrance",
    "@Eastern Palace Entrance/Entrance",
    "@Desert Back Entrance/Entrance",
    "@Desert Left Entrance/Entrance",
    "@Desert Front Entrance/Entrance",
    "@Desert Right Entrance/Entrance",
    "@Tower of Hera Entrance/Entrance",
    "@Skull Woods Back/Entrance",
    "@Thieves Town Entrance/Entrance",
    "@Palace of Darkness Entrance/Entrance",
    "@Misery Mire Entrance/Entrance",
    "@Swamp Palace Entrance/Entrance",
    "@Ice Palace Entrance/Entrance",
    "@Ganon's Tower Entrance/Entrance",
    "@Turtle Ledge Left Entrance/Entrance",
    "@Turtle Ledge Right Entrance/Entrance",
    "@Turtle Laser Bridge Entrance/Entrance",
    "@Turtle Rock Entrance/Entrance"
}

DATA.CaptureBadgeConnectors = {
    "@Elder Left Door/Entrance",
    "@Elder Right Door/Entrance",
    "@Quarreling Brothers Left/Entrance",
    "@Quarreling Brothers Right/Entrance",
    "@Old Man Home/Entrance",
    "@Death Mountain Descent Front/Entrance",
    "@Death Mountain Descent Back/Entrance",
    "@Death Mountain Entry Cave/Entrance",
    "@Death Mountain Entry Back/Entrance",
    "@Spectacle Rock Top/Entrance",
    "@Spectacle Rock Left/Entrance",
    "@Spectacle Rock Bottom/Entrance",
    "@Old Man Back Door/Entrance",
    "@Paradox Cave Top/Entrance",
    "@Spiral Cave Top/Entrance",
    "@Fairy Ascension Top/Entrance",
    "@Spiral Cave Bottom/Entrance",
    "@Fairy Ascension Bottom/Entrance",
    "@Paradox Cave Bottom/Entrance",
    "@Paradox Cave Middle/Entrance",
    "@Bumper Cave Top/Entrance",
    "@Bumper Cave Bottom/Entrance",
    "@Hookshot Cave Island/Entrance",
    "@Hookshot Cave Entrance/Entrance",
    "@Superbunny Cave Top/Entrance",
    "@Superbunny Cave Bottom/Entrance"
}

DATA.CaptureBadgeDropdowns = {
    "@Forest Hideout Drop/Dropdown",
    "@Lumberjack Tree/Dropdown",
    "@Kakariko Well Drop/Dropdown",
    "@Magic Bat Drop/Dropdown",
    "@Secret Passage Drop/Dropdown",
    "@Useless Fairy Drop/Dropdown",
    "@Sanctuary Grave/Dropdown",
    "@Ganon Hole/Dropdown"
}

DATA.CaptureBadgeInsanity = {
    "@Forest Hideout Exit/Entrance",
    "@Lumberjack Tree Exit/Entrance",
    "@Kakariko Well Exit/Entrance",
    "@Magic Bat Exit/Entrance",
    "@Sanctuary Exit/Entrance",
    "@Useless Fairy Exit/Entrance",
    "@Secret Passage Exit/Entrance",
    "@Ganon Hole Exit/Entrance",
    "@Skull Woods Back South/Entrance",
    "@Skull Woods Front Right/Entrance",
    "@Skull Woods Front Left/Entrance",
    "@Skull Woods Back Drop/Dropdown",
    "@Skull Woods Big Chest Drop/Dropdown",
    "@Skull Woods Front Right Drop/Dropdown",
    "@Skull Woods Front Left Drop/Dropdown"
}

DATA.CaptureBadgeOverworld = {
    "@Master Sword Pedestal/Pedestal",
    "@Mushroom Spot/Shroom",
    "@Race Game/Take This Trash",
    "@Desert Ledge/Ledge",
    "@Bombos Tablet/Tablet",
    "@Lake Hylia Island/Island",
    "@Ether Tablet/Tablet",
    "@Spectacle Rock/Up On Top",
    "@Floating Island/Island",
    "@Zora's Domain/Ledge",
    "@Bumper Ledge/Ledge"
}

DATA.CaptureBadgeUnderworld = {
    "@Forest Hideout/Stash",
    "@Lumberjack Cave/Cave",
    "@Kakariko Shop/Items",
    "@Library/On The Shelf",
    "@Cave 45/Circle of Bushes",
    "@Potion Shop/Items",
    "@Lake Shop/Items",
    "@Pond of Happiness/Items",
    "@Paradox Cave Shop/Items",
    "@Dark Lumberjack Shop/Items",
    "@Shield Shop/Items",
    "@Village of Outcasts Shop/Items",
    "@Dark Witch's Hut/Items",
    "@Dark Lake Shop/Items",
    "@Dark Death Mountain Shop/Items"
}

DATA.StatsMarkdownFormat =
    [===[
### Post-Game Summary

Stat | Value
--|-
**Collection Rate** | %d/%d
**Deaths** | %d
**Bonks** | %d
**Total Time** | %02d:%02d:%02d.%02d
]===]
