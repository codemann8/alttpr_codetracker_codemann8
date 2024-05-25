# CodeTracker Full Tracker Package for EmoTracker
Join the [Discord](https://discord.gg/Fk4wTn6) to get notified of updates and/or join the discussion of the various features!

#### Special Thanks
- Kaesden - Taking ownership of anything Race Mode related
- Neonnite - Playing a large role into adding entrance badge icons

## New in v3.0:
Version 3.0 has brought MANY changes. This section of the Readme aims to explain what has changed:
- *\*If you had overridden files that modified aspects of this tracker, I highly recommend making a backup of these files and removing them entirely from your overrides folder. Having modifications in there from the old version will more than likely break functionality. Please review each of your changes and move them in one by one for best results.\**
- The 3 Map Variants in the pack have been combined into one, where the `Broadcast View` can now be configured thru the `Settings` feature above. This also means that before you can use this pack, you will need to select a new variant, an error will display until you do.
- There is a new section for `Settings`. IMPORTANT: In order for the settings to save for the next session, you MUST first use the `Export Overrides` feature to export at least one setting file first. See `Settings` section near the end of this guide.
- Another note on Settings, there are some new options available. Please be sure to review the `Settings` section near the end of this guide for more detail on specific settings. However, a couple things worthy of mention:
  - There is a way to get the more traditional-looking Dungeon Layout that you see in other trackers.
  - There is a `Map Direction` option in the `Broadcast Options` which allows you to specify which side you want the map to show on the Broadcast View, or if you don't want it to show at all!
  - If you were one of the people with a custom Broadcast layout that you defined. There is a specific file you are meant to override and modify now. And if you change the `Alternate Layout` option `3`, the custom layout will then be used. See the more detailed explanation below.
- The autotracker script has been revamped. If you save-scum, the tracker will continue to show that you checked those locations. However, if you wanted to those locations to come back, there is a `Refresh` icon that appears in the `Autotracker` portion of the `Settings` pane.
- OW Tile Swap (Mixed) support has been added. This allows screens to be flipped from one world to the other independently. With autotracking enabled, these screens will auto-flip when you visit each screen. See `Mode-Specific Features` section below for a more detailed explanation on how to use this feature.
- `Flute Shuffle` and `Whirlpool Shuffle` support have been added. Currently both of these only just limited the logic rules/access. The icons for these 2 modes are ONLY located in the `Overworld Shuffle` part of the `Modes` popup. Careful, they are a bit hidden. A future version will expand on the Flute Shuffle part and actually let you define the new flute spots.
- GTBK Guessing Game autotracking icon has been replaced by the `Race Mode` icon, which displays the current collection rate but only if NOT in Race Mode

## Overview:
This package is meant to encompass all aspects that are desired or missing from the existing array of LttPR packages. The intention of this package is to be a complete package, to include and cover all the ways you can play the game, such as entrance shuffle, mystery multiworld, door shuffle, overworld shuffle, and custom ROM hacks.

#### Variants:
All map variants (Standard, Keysanity, Inverted, etc) have been combined into one variant where your game mode is set by toggling settings. This allows for Mystery Multiworld support where you don't have to disconnect EmoTracker from the multiworld to change to a different variant (losing all your marked off locations).
- Map Tracker
- Item/Key Tracker
- Vanilla/ROM Hack Item Tracker

## Modes:
All of the modes can be set by clicking the `Gear` in the `Modes` section. Additionally, there are shortcut icons for many of these modes in the `Modes` section of the tracker.
- World State
    - *\*Right-clicking will enable a '2' in the corner, which enables the logic for Inverted 2.0 changes\**
  - Open (Works for Standard also)
  - Inverted
- Dungeon Items (Keysanity Options, can be toggled separately)
    - *\*Right-clicking any of these options will also enable the options before it\**
  - Maps
  - Compasses
  - Small Keys (Also has extra option for Universal Keys, commonly paired with Retro mode)
  - Big Keys
  - Prizes (In Dungeon vs Wild)
- Entrance Shuffle
  - Vanilla
  - Dungeon (Only the dungeon entrances are shuffled)
    - *\*This also works with Lobby shuffle to show logical access via Sanctuary being in a different dungeon\**
  - Lite\Lean (Dungeons+Connectors / Item Locations are shuffled independently)
  - Entrance (Works for most ER modes Simple/Restricted/Full/Crossed)
  - Insanity
- Door Shuffle
  - Vanilla
  - Basic (Supertiles are shuffled within each dungeon)
  - Crossed (Supertiles are shuffled with all dungeons)
- Overworld Shuffle
  - OW Tile Swap "Mixed" (Overworld screens are randomly swapped with the other world)
  - OW Layout (Overworld transitions are shuffled)
  - Flute Shuffle (New flute spots are chosen)
    - *\*This only disables the logic that uses flute to access areas*\*
    - *\*A future version will provide a way to specify the new flute spots*\*
  - Whirlpool Shuffle (Whirlpool connections are shuffled)
    - *\*This only disables the logic that uses whirlpools to access areas*\*
- Retro Mode (Shows Shops and also possible Take Any Caves)
- Pool Mode
  - Shops (Shop inventories are shuffled into the item pool)
  - Bonks (Bonk drops are shuffled into the item pool)
  - District Map (This ONLY enables a map overlay to show the boundary lines for Districts)
  - Enemy Drops (normally drop keys, shuffled into the item pool)
  - Dungeon Pot Drops
    - Key Pots (shuffled into the item pool)
    - Dungeon Pots (tracker assumes a variable amount of pots are shuffled into the pool)
  - Cave Pot Drops (all pots outside of dungeons are shuffled into the item pool)
- Glitch Logic
  - None
  - OWG (Overworld Glitches)
  - HMG (Hybrid Major Glitches)
  - MG (Major Glitches)
- Race Mode (Disables autotracking features that are deemed illegal per racing council rules)
  - *A checkered flag icon will replace the GT BK guessing game icon to indicate its activation*
  - *\*Race Mode is disabled by default. If you wish to enable this by default, see `Customization` section below\**

## Installation:
To install, you will need to perform the following steps:
1) Open EmoTracker, in the default `Package Manager` under the ALTTPR section, you will see `CodeTracker Full Tracker` as an option to install.
2) Click `Install`. From now on, EmoTracker will show a yellow/green cloud icon when there is a new version of this tracker to install.
3) Beat the pig ;) See Usage section for further info, if needed

## Usage:
#### Tracker Layout
The first thing you may notice is that a few things are rearranged differently than the other LttPR packages.
- Items
  - Item layout more accurately maintains the ordering and grouping of how it is laid out in the game menu, making for better pre-meditated menuing
- Dungeons
  - The `Dungeons` items are arranged in the way that you see the dungeons on the world map, to support the players who prefer a more visual approach to marking dungeons. A traditional-looking layout is available as well, see `Settings` section below for more info.
  - The Big Key icon has been replaced with an icon that supports tracking Map, Compass, and Big Key, for those who wish to incorporate that into figuring out logic or determining whether a map check is worth it. (Left-click toggles BK, right-click cycles thru the combinations of Map and Compass)
  - The dungeon chest icons indicate the remaining items (not necessarily the number of chests) to be found. The chest counts will change on the fly when you change thru the various modes (like Keysanity, etc). The color of the chest counts will indicate the level of access you have to that dungeon, the colors used are identical to the colors used on the map. In `Crossed Door Shuffle` mode, the colors have a different meaning, see the `Door Shuffle` section for more details
- Settings
  - This is an area where you can enable/disable feature per your own personal preferences. There is also a `Gear` in the `Items` sections that is a shortcut to these Settings. See `Settings` section below for more information
- Dropdowns
  - For Entrance Shuffle, this area is meant to mark off dropdown entrances as you find them
- Miscellaneous
  - Most of these icons are niche for mode-specific uses (see `Mode-Specific Features` section below)
- Map Area
  - Dungeon locations having a larger blip on the map compared to other locations
  - Bosses can be rearranged and the appropriate logic rules flow thru to the location, see `Boss Shuffle` section below
  - MM and TR Medallion Checks are added to inform the user when it is available to check. Weathervane also gets a blip when you find flute but haven't activated it
  - The Map area features a `Dungeon` tab, which shows all the dungeon rooms in the game and the locations of all the items, this can also be used as a reference
  - The Map area features a `Doors` tab, which can be used to track doors in Door Shuffle, see `Door Shuffle` section below

#### Broadcast View
The Broadcast View is a great way to give viewers a glimse of your progress. It is recommended to install [NDI Tools](https://ndi.tv/tools/) and the [NDI Plugin for OBS](https://github.com/Palakis/obs-ndi/releases) and use an NDI Source, this allows for a clean transparent background.

Maps help with putting as much info on your stream so viewers ask less questions about what you have or haven't done yet. The colored dots have been made bigger compared to other LttPR packages so they are better visible to viewers.
- Dungeon chests/items have been added to the Broadcast View for better visibility into what dungeons you have already visited.
- Blips on the map have been made bigger to show up better on Broadcast View
- Press F2 to quickly open Broadcast View

#### Autotracking
- Remaining Dungeon Items and Small Keys DO autotrack, unlike the other LttPR trackers.
- There is a GT Big Key guessing game icon that auto increments a GT BK chest count as chests are collected in GT, this correctly counts the torch if it was viewed but not collected.
- Some Locations autotrack if an item was viewed but not collected (Cave 45 does not, as there is a bug in the vanilla game), but only in scenarios when you have the ability to get the item, but decide to not collect it.
- Aga2 is autotracked when you beat Aga2. *(This does NOT spoil Fast Ganon in Mystery modes)*
- In Entrance Shuffle, the Dam autotracks when the dam is drained.
- In Door Shuffle, the Attic autotracks when the TT Attic floor is bombed.
- In OW Tile Swap (Mixed), the OW screens are automatically flipped.
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
- In the map area of the tracker, there is a tab labeled `Dungeons` which shows all the supertiles in the game, which can be used as a reference. The first tab, `All` shows the EG Map for those already familiar with how the vanilla game arranges the supertiles. If not, there are separate tabs for each of the dungeons. Boss locations appear as larger blips on the maps.

#### Overworld Shuffle
- In `OW Tile Swap` (Mixed) mode, overworld screens are swapped with their other-world counterpart. Enabling this will gray out the entire map until each of the individual screens are determined. Enabling Autotracker will flip these screens automatically. However, there is a manual way to flip them. Enabling `OW Tile Swap` turns the mode icon Blue. If you click again, it turns Yellow; and click again, it turns Red. Yellow means it is 'Single-Edit Mode' which allows you to click on one screen to flip it and automatically exits 'Edit Mode' afterwards. Red means you can flip screens indefinitely until you click on the `OW Tile Swap` icon again. While in 'Edit Mode' you will be unable to interact with the Map Locations. When a screen is shown as unknown (grayed out), left-clicking it will mark is as normal (non-flipped), right-clicking it will mark it as flipped. When a screen is known, left-clicking will flip the screen and right-clicking will reset the screen back to unknown.
- In `OW Layout` mode, overworld transitions are shuffled. Your logical access to things are limited to the screens you have visited and the items/entrances/terrain that allow for cross-screen travel.
  - *\*Although this is an option in the tracker, I recommend using [Dunka/Community Tracker](https://alttprtracker.dunka.net) to track OW Layout. You can use both trackers in unison for best effect.\**

#### Retro Mode
- In `Retro Mode`, when not in Entrance Shuffle, Shops and Take Any Caves show up as smaller blips on the map.
  - Take Any Caves show up as yellow instead of green as they aren't as essential as Shops.
- Universal Keys are typically paired with Retro Mode, but due to their ability to be enabled separately, this has to be manually set. This is set by cycling through the `Small Key Shuffle` options.
- In the `Miscellaneous` section of the tracker, there is a Take Any Cave icon. Left-clicking this will mark that you found the Take Any Sword, right-clicking will mark all the Take Any Heart Containers that you find.

## Customization:
EmoTracker's base functionality allows users to modify aspects of any package to suit the users' needs. There may be aspects of this package that you may not like. These can be configured by clicking the `Gear icon -> Advanced -> Export Overrides`. This brings up a window with all the files that encompass this package, any of these files can be overridden and modified per user preference, but it is recommended to only override files when you know what they do. USER BEWARE: When files are overridden, you risk not getting access to new features as they come out in new releases. When you export overrides, you can click the `Gear icon -> Advanced -> Open Override Folder` and it will bring you to where you can modify the file.

As far as information regarding the structure or syntax of the layout definition, or specific questions as to 'how do I mod it to do this specific thing', these are better suited for inquiry in the [EmoTracker Discord](https://emotracker.net/community/).

## Settings:
There is a new tab called `Settings` where users can specify personal preferences in tracker behavior. Additionally, there is a `Gear` icon in the `Items` section that also brings up the same display.

In order for the settings to save properly, you must first export at least one of the settings files (explained in the previous `Customization` section). These settings files will be found in the `settings` directory.

If you continue to get an error when attempting to change settings, it is likely due to the tracker being unable to determine your computer's 'Documents' folder. You can specify a custom location by overriding the `settings/documents.lua` file and modify that file in a text editor (don't include the 'Documents' folder itself). If you don't know where your Documents folder is located, you can find out by clicking on `Gear icon -> Advanced -> Open Override Folder`

The settings are broken out into several categories, an explanation for each of them are listed below.

#### User Preferences
  - Show All Locations - Option to `Show All Locations` by default
  - Always Allow Clearing Locations - Option to `Always Allow Chest Manipulation` by default
  - Auto Pin on Item Capture - Option to `Pin Locations on Item Capture` by default
  - Auto Un-pin On Location Cleared - Option to `Unpin Locations when Cleared` by default
  - Race Mode Default - Option to enable `Race Mode` by default
  - Enable Debug Logging - This outputs various verbose logging messages to the Developer Console
#### Layout Options
  - Use Traditional Dungeon Layout - This enables a more traditional-looking layout if the visual-oriented layout isn't favorable
  - Use Thin Horizontal Pane - This enables an alternate thinner layout of the item/dungeon portion of the tracker 
  - Door Slot Method - In door rando mode, this determines the order in which rooms will occupy slots
    - 1: This prioritizes replacing the oldest room with the current room, unless the room already exists (this ensures the 4 most recent rooms are displayed)
    - 2: This ensures the most recent room stays in the first slot, bumping every room down a slot
    - 3: This puts the most recent room in the next slot in the rotation, keeping all slots in their place
#### Broadcast Options
  - Map Direction - This determines which side the map shows on the Broadcast View, the `X` option hides the map
  - Alternate Layout
    - 1: Simple Item/Key Grid (default)
    - 2: Advanced View - Has the largest map and most information displayed
    - 3: Custom Broadcast - Custom user-defined view - Override `layouts/broadcast_custom.json` to define the layout - See `Customization` section above
#### Autotracker
  - Auto Pin Current Dungeon - This will auto-pin the current dungeon you are in when you enter a new dungeon
  - Disable Auto Dungeon Item Tracking - Changes whether dungeon items (keys/maps/compasses) are auto-tracked or not
  - Disable Auto Location Tracking - Changes whether map locations are auto-tracked or not
  - Disable Auto Entrance Tracking - Changes whether entrances are auto-tracked or not
    - *\*This is already disabled in Race Mode\**
    - If Insanity ER is enabled, entrances will only be autotracked when going from the Overworld to the Underworld
  - Disable Auto OW Tile Swap Tracking - Changes whether OW screens are flipped automatically upon visiting them. This only matters when `OW Tile Swap` mode is enabled.
#### File Output
*\*(Features relating to files that are output when certain events are triggered)\**
  - Enable External Item File - For advanced usage only, in Beta, will export a item.txt file in `C:/Users/<user>/Documents/EmoTracker` when a new item is collected
  - Enable External Dungeon File - For advanced usage only, in Beta, will export a dungeon.txt in `C:/Users/<user>/Documents/EmoTracker` when the player enters a new area of the game
  - Enable External Health File - For advanced usage only, in Beta, will export a health.txt in `C:/Users/<user>/Documents/EmoTracker` when the player has a change in health/status