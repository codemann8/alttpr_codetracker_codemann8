# CodeTracker Full Tracker Package for EmoTracker

FORE WORD: If you don't want maps to be displayed on the Broadcast View, please read below.

## Overview:
This package is meant to encompass all aspects that are desired or missing from the existing array of ALTTPR packages. The intention of this package is to be a complete package, to include and cover almost all ways you can play the game, such as entrance rando, multiworld, door rando, and custom ROM hacks.

## Features:
- Small keys and dungeon chests are auto-tracked in both Standard and Keysanity
- Dungeon chests and keys are laid out in a more visual manner, as the dungeons exist on the world map
- Dungeon chests show on the item tracker; in Standard, the chest icons indicate the remaining items (not chests), in Keysanity, the chest icons indicate the remaining chests.
- Door Rando Mode, when playing door rando, small key and dungeon chest calculation cannot work, so a new mode was created to disable autotracking the parts that are unable to be autotracked, these will have to be manually tracked: this is enabled by clicking the Gear in the Dungeons section
- Door Rando maps are available and are able to be manually checked off when a room is found
- In Keysanity, Map/Compass/BK is trackable under one icon; left click toggles BK, right click cycles thru the combinations of Map and Compass.
- In Keysanity, each chest has it's own logical access defined, except where they can be grouped
- GT Big Key Guessing Game shows on Standard Broadcast Views, auto-tracks the GT Big Key Location, including when you look at the torch but don't get it
- Item layout more accurately maintains the ordering and grouping of how it is laid out in the game menu
- Backwards compatibility to v30 logic with non-progressive bow, so modes like multiworld properly shows silvers without bow
- Optional sphere progression grid for those who wish to track progression on each sphere, this is manually tracked (only available in the horizontal orientation) (This feature is projected to vastly improve when the base EmoTracker software allows for additional tracking features)
- Blips on the map have been made bigger to show up better on Broadcast View (maps can be disabled also, see below)
- Entrance rando, has icons for the 8 dropdown entrances, to be marked as they are found, to show which dropdowns are left to be found
- Entrance rando, an Aga2 icon has been added for when Aga2 is defeated, this is auto-tracked
- Entrance rando, a Dam icon has been added for when you drain the dam, this gives the player access to Swamp Palace and also the Dam item on the overworld, this is auto-tracked
- Entrance rando, various bugs in the logic have been fixed and the logic has been updated to fit v31 scenarios
- Advanced development feature, in Beta and disabled by default, output file when certain items are obtained
- Advanced development feature, in Beta and disabled by default, output file when you enter dungeons or overworld

#### Variants:
- Standard
- Keysanity
- Inverted
- Inverted Keysanity
- Entrance Rando Standard
- Entrance Rando Keysanity
- Entrance Rando Inverted Keysanity
- Items Only
- Items And Keys Only

## Installation:
Normally, an EmoTracker package is installed through the EmoTracker program itself. However, the submission has been denied by EmoTracker staff for unknown/unclarified reasons. Thus, the only way to enjoy this package is to manually install it, which means you will need to periodically check this page (or Star this GitHub project to receive notifications) for when new releases are available. To install, you will need to perform the following steps:
1) Download/update EmoTracker to the latest version
- This package sometimes utilizes features of EmoTracker that were implemented in recent versions
2) Download the latest .zip file from the Releases page
3) Put the .zip file in `Documents/EmoTracker/packs` (`C:/Users/\<user\>/Documents/EmoTracker/packs`)
- If you are upgrading the package to a newer version, simply overwrite the .zip file with the new one
4) If EmoTracker is already opened, you will need to close and reopen the program for it to detect the new package
5) Click the `Gear icon -> Installed packages -> A Link to the Past Randomizer`, you will see `CodeTracker Full Tracker` as a new option
6) Beat the pig ;) See Usage section for further info, if needed

## Usage:
#### Tracker Layout
The first thing you may notice is that a few things are rearranged differently than the other LttP packages.
- The items are laid out in a fashion that makes it easier to visually plan out menuing to different items before you open your menu. The dungeons are arranged in the way that you see the dungeons on the world map, to support the players who prefer a more visual approach to marking dungeons.
- In Keysanity layouts, the Big Key has been replaced with an icon that supports tracking Map, Compass, and Big Key, for those who wish to incorporate that into figuring out logic or determining whether a map check is worth it. (Left-click toggles BK, right-click cycles thru the combinations of Map and Compass)
- In Entrance Rando, there are 8 Dropdown icons, indicating the 8 possible locations you can find thru a dropdown entrance. These can be used to mark the dropdowns you have found so you are aware of what is left to find. There is also a Dam icon, to indicate if the dam has been drained, this is used to indicate access to Swamp Palace and the item on the Overworld.
- The Map area features a `Dungeon` tab, which shows all the dungeon rooms in the game. This is intended to be used for Door Rando to mark rooms of as you find them.
- In Entrance Rando modes, it is recommended to enable the `Gear -> Tracking -> Always Allow Chest Manipulation` option, which allows you to mark off entrances you find in areas you don't have logical access to but find thru a connecting tunnel.

#### Broadcast View
- Maps are included on Broadcast View by default as it helps with putting as much info on your stream so viewers ask less questions about what you have or haven't done yet. The colored dots have been made bigger compared to other LttP packages so they are better visible to viewers. If you wish to not have maps shown on your Broadcast View, please see the Customization section below.
- Dungeon chests/items have been added to the Broadcast View for better visibility into what dungeons you have already visited.

#### Autotracking
- Dungeon items (in Standard modes) and Small Keys (in Keysanity modes) DO autotrack, unlike the other LttP trackers. This feaure is disabled when using `Door Rando Mode`, as it is impossible to calculate this info in that mode (See the Door Rando sub-section below).
- In Standard modes, there is a GT Big Key guessing game icon that auto increments a GTBK chest count as chests are collected in GT, this correctly counts the torch if it was viewed but not collected.
- Some Locations autotrack if an item was viewed but not collected (Cave 45 does not, as there is a bug in the vanilla game).
- In Entrance Rando, Aganihm 2 autotracks as he is defeated or if Fast Ganon is the goal, the Dam autotracks when the dam is drained.
- In Door Rando modes, `Door Rando Mode` should be enabled (See the Door Rando sub-section below).
- In Legacy modes (playing old seeds or playing ROM hacks), the non-progressive bow and silvers track correctly unlike the other Lttp packages.

#### Door Rando
- In the map area of the tracker, there is a new tab called `Dungeon` which shows all the rooms in the game. These can be marked off as they are found. The first tab, `All` shows the EG Map for those already familiar with how the vanilla game arranges the rooms. If not, there are separate tabs for each of the dungeons.
- If using autotracking, `Door Rando Mode` MUST be enabled. This disables autotracking for dungeon items (in Standard modes) and small keys (in Keysanity modes) as it is impossible to calculate this information when the doors are shuffled. Weird behavior WILL happen if `Door Rando Mode` isn't enabled when playing Door Rando and autotracker is active. This can be enabled by clicking the Gear in the header of the `Dungeons` section.

## Customization:
EmoTracker's base functionality allows users to modify aspects of any package to suit the users' needs. There may be aspects of this package that you may not like. These can be configured by clicking the `Gear icon -> Advanced -> Export Overrides`. This brings up a window with all the files that encompass this package, any of these files can be overridden as per user preference, but it is recommended to only override files when you know what they do. When you export overrides, you can click the `Gear icon -> Advanced -> Open Overrides Folder` and it will bring you to where you can modify the file.

For instance, some may not want to have maps be shown on the Broadcast View. There is a settings file that can be modified to have maps be disabled. This settings file is where all options to configure (current and future) are surfaced. The settings file will be found under `scripts/settings.lua`. Inside the settings file, there is an option called `MAP_ON_BROADCAST_VIEW`. If you change this to false, the Broadcast View will now show the base view instead.

#### Settings:
- MAP_ON_BROADCAST_VIEW - Shows maps on Broadcast View
- AUTOTRACKER_ENABLE_EXTERNAL_ITEM_FILE - For advanced usage only, in Beta, will export a item.txt file in `C:/Users/\<user\>/Documents/EmoTracker` when a new item is collected
- AUTOTRACKER_ENABLE_EXTERNAL_DUNGEON_IMAGE - For advanced usage only, in Beta, will export a dungeon.txt in `C:/Users/\<user\>/Documents/EmoTracker` when the player enters a new area of the game
