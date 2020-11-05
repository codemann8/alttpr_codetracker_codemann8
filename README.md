# CodeTracker Full Tracker Package for EmoTracker
Join the [Discord](https://discord.gg/Fk4wTn6) to get notified of updates!

## Overview:
This package is meant to encompass all aspects that are desired or missing from the existing array of LttP packages. The intention of this package is to be a complete package, to include and cover almost all ways you can play the game, such as entrance rando, mystery multiworld, door rando, and custom ROM hacks.

## Features:
- All variants (Standard, Keysanity, Inverted, etc) have been combined into one variant where your game mode is set by toggling settings. This allows for Mystery Multiworld support where you don't have to disconnect EmoTracker from the multiworld to change to a different variant (losing all your marked off locations). All of the Modes can be set by clicking the icons in the `Modes` section. A more detailed explantion of these Modes are shown by clicking the `Gear` in the `Items` section.
- Small keys and dungeon chests are auto-tracked in both Standard and Keysanity
- Dungeon chests and keys are laid out in a more visual manner, as the dungeons exist on the world map
- Dungeon chests show on the item tracker; the chest icons indicate the remaining items (not necessarily the number of chests) to be found. The chest count will change on the fly when you change thru the various Keysanity (Dungeon Item) modes
- Dungeon Item Shuffles (Keysanity options) are separated as individual toggles (Map, Compass, Small Keys, Big Key). Left click toggles each type, right click enables everything up to that point. (ie. right click on Big Key effectively sets it to Full Keysanity)
- Key Drop Shuffle (Pool Mode) is a mode where pot keys and enemy drop keys are shuffled into the standard item pool, this affects the dungeon item counts along with dungeon key counts
- A `Race Mode` has been added to disable autotracking features that have been disallowed per racing council rules. A checkered flag icon will replace the GT Big Key guessing game icon to indicate its activation.
- Dungeon locations on the map tracker shows every chest location and has it's own logical access defined, except where they can be grouped
- Dungeon locations having a larger blip on the map compared to other locations
- MM and TR Medallion Checks are added to inform the user when it is available to check. Weathervane also gets a blip when you find flute but haven't activated it.
- In `Door Rando Mode`, under the `Dungeon` tab, maps are available and are able to be manually checked off when a room is found
- In `Retro Mode`, when not in Entrance Shuffle, Shops and Take Any Caves show up as smaller blips on the map. Take Any Caves show up as yellow instead of green as they aren't as essential as the Shops. Universal keys can be set without Retro Mode active, simply disabling Small Key Shuffle is the correct way to handle this scenario. An icon in the `Misc` section allows the user to track the Take Any Caves as they are found.
- In Keysanity, Map/Compass/BK is trackable under one icon; left click toggles BK, right click cycles thru the combinations of Map and Compass.
- GT Big Key Guessing Game, auto-tracks the GT Big Key Location, including when you look at the torch but don't get it
- Item layout more accurately maintains the ordering and grouping of how it is laid out in the game menu
- Backwards compatibility to v30 logic with non-progressive bow, so modes like legacy versions of multiworld properly shows silvers without bow
- Blips on the map have been made bigger to show up better on Broadcast View
- Entrance rando, has icons for the 8 dropdown entrances, to be marked as they are found, to show which dropdowns are left to be found. The exits to dropdowns are shown when in `Insanity` mode
- Entrance rando, a Dam icon has been added for when you drain the dam, this gives the player access to Swamp Palace and also the Dam item on the overworld, this is auto-tracked
- Entrance rando, various bugs in the logic have been fixed and the logic has been updated to fit v31 scenarios
- Door rando, an Attic icon has been added for when you bomb the Attic floor in cross dungeon door rando, this is auto-tracked
- An Aga2 icon has been added for when Aga2 is defeated, this is toggled by right-clicking the Aga icon, autotracking this is disabled as it can spoil Fast Ganon in Mystery seeds
- The current dungeon is auto-pinned when player enters a dungeon, feature is disabled by default
- Advanced development feature, in Beta and disabled by default, output file when certain items are obtained
- Advanced development feature, in Beta and disabled by default, output file when you enter dungeons or overworld

#### Variants:
- Map Tracker
- Map Tracker (Map Broadcast)
- Map Tracker (ER Broadcast)
- Item Tracker
- Item/Key Tracker

## Installation:
To install, you will need to perform the following steps:
1) Open EmoTracker, in the default `Package Manager` under the ALTTPR section, you will see `CodeTracker Full Tracker` as an option to install.
2) Click `Install`. From now on, EmoTracker will show a yellow/green cloud icon when there is a new version of this tracker to install.
3) Beat the pig ;) See Usage section for further info, if needed

## Usage:
#### Tracker Layout
The first thing you may notice is that a few things are rearranged differently than the other LttP packages.
- There are 3 Map Tracker variants, all of which are identical logically, but have different Broadcast Views (a future version of this tracker will combine these 3 when EmoTracker supports making modifications to layouts on the fly)
- The items are laid out in a fashion that makes it easier to visually plan out menuing to different items before you open your menu. The dungeons are arranged in the way that you see the dungeons on the world map, to support the players who prefer a more visual approach to marking dungeons.
- To set your game mode (Keysanity, Inverted, Entrance, Door Rando, etc) click the `Gear` icon in the `Items` section of the tracker; there you will see the various options that can be toggled.  Additionally, there are shortcut icons for these modes in the `Modes` section of the tracker.
- The Big Key has been replaced with an icon that supports tracking Map, Compass, and Big Key, for those who wish to incorporate that into figuring out logic or determining whether a map check is worth it. (Left-click toggles BK, right-click cycles thru the combinations of Map and Compass)
- For Entrance Rando, the Map area features an `Entrance` tab, which shows a map for showing entrances. There are also 8 Dropdown icons, indicating the 8 possible locations you can find thru a dropdown entrance. These can be used to mark the dropdowns you have found so you are aware of what is left to find. There is also a Dam icon, to indicate if the dam has been drained, this is used to indicate access to Swamp Palace and the item on the Overworld.
- For Door Rando, the Map area features a `Dungeon` tab, which shows all the dungeon rooms in the game. This is intended to be used to mark rooms off as you find them, or for reference
- In Entrance Rando modes, it is recommended to use another tracker in conjunction with this one to note which entrances are useful. An example of a tracker is [CodeTracker](https://zelda.codemann8.com/ertracker/tracker.php), a browser-based tracker which features a broadcast view and a link that can be shared with viewers.

#### Broadcast View
There are 3 Map Tracker variants, each with a different Braodcast View.
- The default variant is the most universal, as it doesn't show a map, thus giving better Mystery support.
- The Map Broadcast variant shows the regular map in addition to the items
- The ER Broadcast variant shows the entrance map, which is a bit larger due to the smaller size of the colored dots.

Maps help with putting as much info on your stream so viewers ask less questions about what you have or haven't done yet. The colored dots have been made bigger compared to other LttP packages so they are better visible to viewers.
- Dungeon chests/items have been added to the Broadcast View for better visibility into what dungeons you have already visited.

#### Autotracking
- Dungeon items and Small Keys DO autotrack, unlike the other LttP trackers.
- There is a GT Big Key guessing game icon that auto increments a GTBK chest count as chests are collected in GT, this correctly counts the torch if it was viewed but not collected.
- Some Locations autotrack if an item was viewed but not collected (Cave 45 does not, as there is a bug in the vanilla game).
- In Entrance Rando, the Dam autotracks when the dam is drained.
- In Door Rando, the Attic autotracks when the TT attic floor is bombed.
- In Legacy modes (playing old seeds or playing ROM hacks), the non-progressive bow and silvers track correctly unlike the other LttP packages.

#### Door Rando
- In the map area of the tracker, there is a new tab called `Dungeon` which shows all the rooms in the game. These can be marked off as they are found. The first tab, `All` shows the EG Map for those already familiar with how the vanilla game arranges the rooms. If not, there are separate tabs for each of the dungeons. Rooms with chests are marked with a GREEN square, rooms with a boss are marked with an ORANGE square.
- In Crossed Dungeon Door Rando, dungeon chests default to a count of 0 and increment when you collect chests, as the total number of chests in dungeons is unknown. It is possible in a future version of door rando code, where we might be able to read the total number of chests in a dungeon (like when you get the compass for a dungeon) but it is currently impossible to do in door rando's current version. The total number of chests can be manually changed per the `Dungeon Selector` and `Total Chests` icons in the lower right corner of the `Dungeons` section. The `Dungeon Selector` will cycle thru the dungeons and will display each dungeons' total chests. Left clicking the `Total Chests` will increment the max count, right clicking will reset it to unknown. When autotracking, the number of opened chests for each dungeon will be an orange color, to signify that you know that dungeon's total chest count, but have not opened all of them yet; this is not available whe manually tracking yet due to a limitation in the base framework.

## Customization:
EmoTracker's base functionality allows users to modify aspects of any package to suit the users' needs. There may be aspects of this package that you may not like. These can be configured by clicking the `Gear icon -> Advanced -> Export Overrides`. This brings up a window with all the files that encompass this package, any of these files can be overridden as per user preference, but it is recommended to only override files when you know what they do. USER BEWARE: When files are overridden, you risk not getting access to new features as they come out in new releases. When you export overrides, you can click the `Gear icon -> Advanced -> Open Overrides Folder` and it will bring you to where you can modify the file.

For instance, there is a settings file that can be modified to enable or disable various features. This settings file is where all options to configure (current and future) are surfaced. The settings file will be found under `scripts/settings.lua`.

#### Settings:
- AUTOTRACKER_DISABLE_LOCATION_TRACKING - Changes whether map locations are auto-tracked or not
- AUTOTRACKER_DISABLE_REGION_TRACKING - Changes whether regions are auto-tracked or not (regions are used for access to areas of the overworld in entrance rando)

- AUTOTRACKER_ENABLE_AUTOPIN_CURRENT_DUNGEON - This will auto-pin the current dungeon you are in when you enter a new dungeon
- AUTOTRACKER_ENABLE_EXTERNAL_ITEM_FILE - For advanced usage only, in Beta, will export a item.txt file in `C:/Users/<user>/Documents/EmoTracker` when a new item is collected
- AUTOTRACKER_ENABLE_EXTERNAL_DUNGEON_IMAGE - For advanced usage only, in Beta, will export a dungeon.txt in `C:/Users/<user>/Documents/EmoTracker` when the player enters a new area of the game
- AUTOTRACKER_ENABLE_EXTERNAL_HEALTH_FILE - For advanced usage only, in Beta, will export a health.txt in `C:/Users/<user>/Documents/EmoTracker` when the player has a change in health/status
- EXPERIMENTAL_ENABLE_DYNAMIC_REQUIREMENTS - For experimental use only, in crossed door rando, there are two capture grids added to each dungeon, to which the user can cycle thru the various items that can lock a dungeon. This is useful for marking items that you need to complete a dungeon later.
