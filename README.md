# CodeTracker Full Tracker Package for EmoTracker

FORE WORD: If you don't want maps to be displayed on the Broadcast View, please read below.

### Overview:
This package is meant to encompass all aspects that are desired or missing from the existing array of ALTTPR packages. The intention of this package is to be a complete package, to include and cover almost all ways you can play the game, such as entrance rando, multiworld, door rando, and custom ROM hacks.

### Features:
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

### Variants:
- Standard
- Keysanity
- Inverted
- Inverted Keysanity
- Entrance Rando Standard
- Entrance Rando Keysanity
- Entrance Rando Inverted Keysanity
- Items Only
- Items And Keys Only

### Customization:
EmoTracker's base functionality allows users to modify aspects of any package to suit the users' needs. There may be aspects of this package that you may not like. These can be configured by clicking the `Gear icon -> Advanced -> Export Overrides`. This brings up a window with all the files that encompass this package, any of these files can be overridden as per user preference, but it is recommended to only override files when you know what they do. When you export overrides, you can click the `Gear icon -> Advanced -> Open Overrides Folder` and it will bring you to where you can modify the file.

For instance, some may not want to have maps be shown on the Broadcast View. There is a settings file that can be modified to have maps be disabled. This settings file is where all options to configure (current and future) are surfaced. The settings file will be found under `scripts/settings.lua`. Inside the settings file, there is an option called `MAP_ON_BROADCAST_VIEW`. If you change this to false, the Broadcast View will now show the base view instead.

##### Settings:
- MAP_ON_BROADCAST_VIEW - Shows maps on Boradcast View
- AUTOTRACKER_ENABLE_EXTERNAL_ITEM_FILE - For advanced usage only, in Beta, will export a item.txt file in `C:/Users/\<user\>/Documents/EmoTracker` when a new item is collected
- AUTOTRACKER_ENABLE_EXTERNAL_DUNGEON_IMAGE - For advanced usage only, in Beta, will export a dungeon.txt in `C:/Users/\<user\>/Documents/EmoTracker` when the player enters a new area of the game
