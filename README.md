# CodeTracker Full Tracker Package for EmoTracker
Join the [Discord](https://discord.gg/Fk4wTn6) to get notified of updates and/or join the discussion of the various features!

#### Special Thanks:
- Kaesden - Taking ownership of anything Race Mode related
- Neonnite - Playing a large role into adding entrance badge icons

## Overview:
This package is meant to encompass all aspects that are desired or missing from the existing array of LttPR packages. The intention of this package is to be a complete package, to include and cover all the ways you can play the game, such as entrance shuffle, mystery multiworld, door shuffle, and custom ROM hacks.

#### Variants:
All variants (Standard, Keysanity, Inverted, etc) have been combined into one variant where your game mode is set by toggling settings. This allows for Mystery Multiworld support where you don't have to disconnect EmoTracker from the multiworld to change to a different variant (losing all your marked off locations).
- Map Tracker
- Map Tracker (Map Broadcast)
- Map Tracker (ER Broadcast)
- Item/Key Tracker
- Vanilla/ROM Hack Item Tracker

## Modes:
All of the modes can be set by clicking the `Gear` in the `Items` section. Additionally, there are shortcut icons for many of these modes in the `Modes` section of the tracker.
- World State
  - Open (Works for Standard also)
  - Inverted
- Dungeon Items (Keysanity Options, can be toggled separately)
    - *\*Right-clicking any of these options will also enable the options before it\**
  - Maps
  - Compasses
  - Small Keys (Also has extra option for Universal Keys, commonly paired with Retro mode)
  - Big Keys
- Entrance Shuffle
  - Vanilla
  - Dungeon (Only the dungeon entrances are shuffled)
    - *\*This also works with Lobby shuffle to show logical access via Sanctuary being in a different dungeon\**
  - Crossed (Works for most ER modes Simple/Restricted/Full/Crossed)
  - Insanity
- Door Shuffle
  - Vanilla
  - Basic (Supertiles are shuffled within each dungeon)
  - Crossed (Supertiles are shuffled with all dungeons)
- Retro Mode (Shows Shops and also possible Take Any Caves)
- Pool Mode
  - Shopsanity (Shop inventories are shuffled into the item pool)
  - Key Drops (Enemies and Pots, that normally drop keys, are shuffled into the item pool)
- Glitch Logic
  - None
  - OWG (Overworld Glitches)
  - HMG (Hybrid Major Glitches)
  - MG (Major Glitches)
- Race Mode (Disables autotracking features that are deemed illegal per racing council rules)
  - *A checkered flag icon will replace the GT BK guessing game icon to indicate its activation*
  - *\*This mode can be defaulted to be enabled, see `Customization` section below\**

## Installation:
To install, you will need to perform the following steps:
1) Open EmoTracker, in the default `Package Manager` under the ALTTPR section, you will see `CodeTracker Full Tracker` as an option to install.
2) Click `Install`. From now on, EmoTracker will show a yellow/green cloud icon when there is a new version of this tracker to install.
3) Beat the pig ;) See Usage section for further info, if needed

## Usage:
#### Tracker Layout
The first thing you may notice is that a few things are rearranged differently than the other LttPR packages.
- There are 3 Map Tracker variants, all of which are identical logically, but have different Broadcast Views (a future version of this tracker will combine these 3 when EmoTracker supports making modifications to layouts on the fly)
- Items
  - Item layout more accurately maintains the ordering and grouping of how it is laid out in the game menu, making for better pre-meditated menuing.
- Dungeons
  - The `Dungeons` items are arranged in the way that you see the dungeons on the world map, to support the players who prefer a more visual approach to marking dungeons. A traditional-looking layout is available as well, see `Customization` section below for more info.
  - The Big Key icon has been replaced with an icon that supports tracking Map, Compass, and Big Key, for those who wish to incorporate that into figuring out logic or determining whether a map check is worth it. (Left-click toggles BK, right-click cycles thru the combinations of Map and Compass)
  - The dungeon chest icons indicate the remaining items (not necessarily the number of chests) to be found. The chest counts will change on the fly when you change thru the various modes (like Keysanity, etc). The color of the chest counts will indicate the level of access you have to that dungeon, the colors used are identical to the colors used on the map. In `Crossed Door Shuffle` mode, the colors have a different meaning, see the `Door Shuffle` section for more details.
- Dropdowns
  - For Entrance Shuffle, this area is meant to mark off dropdown entrances as you find them
- Miscellaneous
  - Most of these icons are niche for mode-specific uses (see `Mode-Specific Features` section below)
  - The Big Key icon is for the GT BK Guessing Game (see `Autotracking` section below)
- Map Area
  - Dungeon locations having a larger blip on the map compared to other locations
  - Bosses can be rearranged and the appropriate logic rules flow thru to the location, see `Boss Shuffle` section below
  - MM and TR Medallion Checks are added to inform the user when it is available to check. Weathervane also gets a blip when you find flute but haven't activated it
  - The Map area features a `Dungeon` tab, which shows all the dungeon rooms in the game and the locations of all the items, this can also be used as a reference
  - The Map area features a `Doors` tab, which can be used to track doors in Door Shuffle, see `Door Shuffle` section below

#### Broadcast View
The Broadcast View is a great way to give viewers a glimse of your progress. It is recommended to install the NDI plugin for OBS and use an NDI Source, this allows for a clean transparent background. In this tracker, there are 3 Map Tracker variants, each with a different Broadcast View.
- The default variant is the most universal, as it doesn't show a map, thus giving better Mystery support.
- The Map Broadcast variant shows the regular map in addition to the items
- The ER Broadcast variant shows the entrance map, which is a bit larger due to the smaller size of the colored dots.

Maps help with putting as much info on your stream so viewers ask less questions about what you have or haven't done yet. The colored dots have been made bigger compared to other LttPR packages so they are better visible to viewers.
- Dungeon chests/items have been added to the Broadcast View for better visibility into what dungeons you have already visited.
- Blips on the map have been made bigger to show up better on Broadcast View

#### Autotracking
- Remaining Dungeon Items and Small Keys DO autotrack, unlike the other LttPR trackers.
- There is a GT Big Key guessing game icon that auto increments a GT BK chest count as chests are collected in GT, this correctly counts the torch if it was viewed but not collected.
- Some Locations autotrack if an item was viewed but not collected (Cave 45 does not, as there is a bug in the vanilla game), but only in scenarios when you have the ability to get the item, but decide to not collect it.
- Aga2 is autotracked when you beat Aga2. *(This does NOT spoil Fast Ganon in Mystery modes)*
- In Entrance Shuffle, the Dam autotracks when the dam is drained.
- In Door Shuffle, the Attic autotracks when the TT Attic floor is bombed.
- In Legacy modes (playing old seeds or playing ROM hacks), the non-progressive bow and silvers track correctly.
- The current dungeon is auto-pinned when player enters a dungeon, feature is disabled by default (see `Customization` section below)
- Advanced development feature, in Beta and disabled by default, output file when certain items are obtained (see `Customization` section below)
- Advanced development feature, in Beta and disabled by default, output file when you enter dungeons or overworld (see `Customization` section below)

## Mode-Specific Features:
#### Boss Shuffle
- When using Boss Shuffle, you can choose a different boss to replace the original boss and the new logic rules will be applied. To perform this, you left-hold-click a Dungeon blip on the map and click on the dotted line at the Boss Location, a grid will appear where you can select the boss that resides there.

#### Entrance Shuffle
- For tracking entrances, not only can you mark an entrance as Checked, but you can also add an icon on the map, indicating where the entrance leads. This is done by left-hold-clicking a blip and clicking the dashed box. Selecting an icon will place an icon on the map for later reference.
- In the `Dropdowns` section of the tracker, there are 8 dropdown icons, to be marked as they are found, to show which dropdowns are left to be found. In `Insanity Shuffle`, 4 additional dropdown icons appear.
- In the `Miscellaneous` section of the tracker, there is a Dam icon, to indicate when you've found and drained the Dam, giving logical access to both the Sunken Treasure item and Swamp Palace. This is autotracked.
- In `Dungeon Shuffle` mode, only the dungeon entrances are shuffle. This is a relatively new mode, popularized by the Multiworld community.
- In `Insanity Shuffle`, all of the Skull Woods entrances/dropdowns and exits to the other 8 dropdowns appear as blips on the map.
- An alternative choice for tracking entrances is [CodeTracker: Web Edition](https://zelda.codemann8.com/ertracker/tracker.php), a browser-based tracker which also features a broadcast view and a link that can be shared with viewers

#### Door Shuffle
- In `Crossed Shuffle`, dungeon chests default to a count of 0 (yellow color) and increment when you collect chests, as the total number of chests in dungeons is unknown. The total number of chests can be manually changed per the `Dungeon Selector` and `Total Chests` icons in the lower right of the `Dungeons` section. The `Dungeon Selector` will cycle thru the dungeons and will display each dungeons' total chests. Left clicking the `Total Chests` will increment the max count, right clicking will decrement it. When the max count is set, the corresponding dungeon chest text number will now indicate the remaining number of chests to open and will change to an orange color. When all of the chests in that dungeon have been collected, the color will change to red and will display the total number of chests that were opened, and the chest icon will change to an opened chest. The same can be done with small keys, although the text color of the keys will remain default EmoTracker behavior, a green color when you've found all of them. It is important to mention that if manually tracking chests, left-clicking on the chest is ALWAYS the appropriate action when marking a collected chest, regardless if it is displaying a yellow collected amount or an orange remaining amount; right-clicking the chest reverses the count if you accidentally mis-click.
- In the map area of the tracker, there is a tab labeled `Doors` which can be used to track doors, reducing the need to re-navigate rooms of a dungeon. Using the `Room Group Selector`, you can click on a group to view all the non-linear rooms in that group. You can then click on a room to add it to the list of recently visited rooms. If autotracking is enabled, this part is unnecessary as the rooms will automatically be added to the recently visited rooms. When a room is added to the recently visited rooms, question marks will also appear, by default, where there are doors in that room. Using the `Door Type Selector`, you can select the icon you want to place on a door. Clicking on a door will mark a door with the selected icon. If an icon in the `Door Type Selector` section has a `+` sign in the upper right corner, it means it is an icon group and will cycle thru different icons when you click multiple times on a particular door. Right-clicking a door will reset it to a question mark. When a room comes up in the recently visited rooms, if it was a room that was already previously brought up before and edited, those door icon changes will be remembered and displayed. For convenience, a `Dashboard` tab was also added which displays both the Overworld map and the Doors editor in one simple-to-use screen. Since the base EmoTracker application doesn't have good support for resizeable layouts (outside of Map objects), most of the Door Tracking functionality has been optimized to work for 1920x1080 a window size, or half a window size if using the vertical view.
- In the `Miscellaneous` section of the tracker, there is a Attic icon, to indicate when you've found and bombed the Thieves' Town attic, logically required to beat Blind (even with Boss Shuffle). This is autotracked.
- If playing with `Lobby Shuffle` but not `Entrance Shuffle`, it is recommended to also enable `Dungeon Shuffle` under the Entrance Shuffle modes. With this enabled, you can mark the dungeon entrance where Sanctuary is located; this also shows the appropriate logical access from this non-standard starting location.
- In the map area of the tracker, there is a tab labeled `Dungeon` which shows all the supertiles in the game, which can be used as a reference. The first tab, `All` shows the EG Map for those already familiar with how the vanilla game arranges the supertiles. If not, there are separate tabs for each of the dungeons. Boss locations appear as larger blips on the maps.

#### Retro Mode
- In `Retro Mode`, when not in Entrance Shuffle, Shops and Take Any Caves show up as smaller blips on the map.
  - Take Any Caves show up as yellow instead of green as they aren't as essential as Shops.
- Universal Keys can be set without Retro Mode active, altho by default, enabling Retro Mode also triggers Universal Keys to enable as well.
- In the `Miscellaneous` section of the tracker, there is a Take Any Cave icon. Left-clicking this will mark that you found the Take Any Sword, right-clicking will mark all the Take Any Heart Containers that you find.

## Customization:
EmoTracker's base functionality allows users to modify aspects of any package to suit the users' needs. There may be aspects of this package that you may not like. These can be configured by clicking the `Gear icon -> Advanced -> Export Overrides`. This brings up a window with all the files that encompass this package, any of these files can be overridden as per user preference, but it is recommended to only override files when you know what they do. USER BEWARE: When files are overridden, you risk not getting access to new features as they come out in new releases. When you export overrides, you can click the `Gear icon -> Advanced -> Open Overrides Folder` and it will bring you to where you can modify the file.

For instance, there are settings files that can be modified to enable or disable various features. The settings files will be found under the `scripts/settings` directory. More information on the various .lua settings files are in the below section.

#### Settings:
The settings are broken out into several files, grouped by relation or its usage.

- tracking.lua (Settings relating to content that is tracked)
  - AUTOTRACKER_DISABLE_ITEM_TRACKING - Changes whether items are auto-tracked or not
  - AUTOTRACKER_DISABLE_LOCATION_TRACKING - Changes whether map locations are auto-tracked or not
  - AUTOTRACKER_DISABLE_REGION_TRACKING - Changes whether regions are auto-tracked or not (regions are used for access to areas of the overworld in entrance shuffle)
    - *\*This is already disabled in Race Mode\**
- defaults.lua (Settings that are defaults, can be changed by user in app)
  - PREFERENCE_DISPLAY_ALL_LOCATIONS - Option to `Show All Locations` by default
  - PREFERENCE_ALWAYS_ALLOW_CLEARING_LOCATIONS - Option to `Always Allow Chest Manipulation` by default
  - PREFERENCE_PIN_LOCATIONS_ON_ITEM_CAPTURE - Option to `Pin Locations on Item Capture` by default
  - PREFERENCE_AUTO_UNPIN_LOCATIONS_ON_CLEAR - Option to `Unpin Locations when Cleared` by default
  - PREFERENCE_DEFAULT_RACE_MODE_ON - Option to enable `Race Mode` by default
- settings.lua (Features available specific to functionality in this package)
  - AUTOTRACKER_ENABLE_AUTOPIN_CURRENT_DUNGEON - This will auto-pin the current dungeon you are in when you enter a new dungeon
  - LAYOUT_ENABLE_ALTERNATE_DUNGEON_VIEW - This enables a more traditional-looking layout if the visual-oriented layout isn't favorable
- fileio.lua (Features relating to files that are output when certain events are triggered)
  - AUTOTRACKER_ENABLE_EXTERNAL_ITEM_FILE - For advanced usage only, in Beta, will export a item.txt file in `C:/Users/<user>/Documents/EmoTracker` when a new item is collected
  - AUTOTRACKER_ENABLE_EXTERNAL_DUNGEON_IMAGE - For advanced usage only, in Beta, will export a dungeon.txt in `C:/Users/<user>/Documents/EmoTracker` when the player enters a new area of the game
  - AUTOTRACKER_ENABLE_EXTERNAL_HEALTH_FILE - For advanced usage only, in Beta, will export a health.txt in `C:/Users/<user>/Documents/EmoTracker` when the player has a change in health/status
- experimental.lua (Settings to enable experimental features)
  - EXPERIMENTAL_ENABLE_DYNAMIC_REQUIREMENTS - For experimental use only, in crossed door shuffle, there are two capture grids added to each dungeon, to which the user can cycle thru the various items that can lock a dungeon. This is useful for marking items that you need to complete a dungeon later.
