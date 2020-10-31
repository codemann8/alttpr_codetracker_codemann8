CaptureBadgeCache = {}

function tracker_on_accessibility_updated()
    if OBJ_ENTRANCE.CurrentStage == 0 then
        for i,section in pairs(CaptureBadgeEntrances) do
            local tempSection = section:gsub("/", " Ghost/")
            local target = Tracker:FindObjectForCode(section)
            local hiddenTarget = Tracker:FindObjectForCode(tempSection)
            -- Has the captured item for this section changed since last update
            if target == nil or hiddenTarget == nil then
                print("Failed to resolve " .. section .. " please check for typos.")
            elseif CaptureBadgeCache[target] then
                -- Does the location that owns this section already have a badge, if so remove it
                hiddenTarget.Owner:RemoveBadge(CaptureBadgeCache[target.Owner])
                CaptureBadgeCache[target] = nil
            end
        end
    else
        for i,section in pairs(CaptureBadgeEntrances) do
            local tempSection = section:gsub("/", " Ghost/")
            local target = Tracker:FindObjectForCode(section)
            local hiddenTarget = Tracker:FindObjectForCode(tempSection)
            -- Has the captured item for this section changed since last update
            if target == nil or hiddenTarget == nil then
                print("Failed to resolve " .. section .. " please check for typos.")
            elseif target.CapturedItem ~= CaptureBadgeCache[target] then
                -- Does the location that owns this section already have a badge, if so remove it
                if CaptureBadgeCache[target.Owner] then
                    hiddenTarget.Owner:RemoveBadge(CaptureBadgeCache[target.Owner])
                    CaptureBadgeCache[target.Owner] = nil
                    CaptureBadgeCache[target] = nil
                end
                -- Check if a captured item exists, add as badge to the sections owner if it does
                if target.CapturedItem then
                    CaptureBadgeCache[target.Owner] = hiddenTarget.Owner:AddBadge(target.CapturedItem.PotentialIcon)
                    CaptureBadgeCache[target] = target.CapturedItem
                    target.AvailableChestCount = 0
                    target.HostedItem.Active = true
                    target.CapturedItem = CaptureBadgeCache[target]
                end
            end
        end
    end

    for i,section in pairs(CaptureBadgeSections) do
        local tempSection = section:gsub("/", " Ghost/")
        local target = Tracker:FindObjectForCode(section)
        local hiddenTarget = Tracker:FindObjectForCode(tempSection)
        -- Has the captured item for this section changed since last update
        if target == nil or hiddenTarget == nil then
            print("Failed to resolve " .. section .. " please check for typos.")
        elseif target.CapturedItem ~= CaptureBadgeCache[target] then
            -- Does the location that owns this section already have a badge, if so remove it
            if CaptureBadgeCache[target.Owner] then
                hiddenTarget.Owner:RemoveBadge(CaptureBadgeCache[target.Owner])
                CaptureBadgeCache[target.Owner] = nil
                CaptureBadgeCache[target] = nil
            end
            -- Check if a captured item exists, add as badge to the sections owner if it does
            if target.CapturedItem then
                CaptureBadgeCache[target.Owner] = hiddenTarget.Owner:AddBadge(target.CapturedItem.PotentialIcon)
                CaptureBadgeCache[target] = target.CapturedItem
            end
        end
    end
end

--If you want to use this code for your tracker, copy-paste all of the code above into it's own lua file (like you see here)

CaptureBadgeEntrances = {
    "@Master Sword Pedestal/Pedestal",
    "@Lumberjack House/Entrance",
    "@Lumberjack Tree Dropdown/Dropdown",
    "@Lumberjack Tree Entrance/Entrance",
    "@Death Mountain Entry Cave/Entrance",
    "@Death Mountain Exit Back/Entrance",
    "@Kakariko Fortune Teller/Entrance",
    "@Elder Left Door/Entrance",
    "@Elder Right Door/Entrance",
    "@Left Snitch House/Entrance",
    "@Right Snitch House/Entrance",
    "@Blind's House Entrance/Entrance",
    "@Kakariko Well/Dropdown",
    "@Kakariko Well Entrance/Entrance",
    "@Chicken House Entrance/Entrance",
    "@Grass House/Entrance",
    "@Front Tavern/Entrance",
    "@Kakariko Shop/Entrance",
    "@Bomb Hut/Entrance",
    "@Sick Kid Entrance/Entrance",
    "@Smith's House/Entrance",
    "@Magic Bat Dropdown/Dropdown",
    "@Magic Bat Entrance/Entrance",
    "@Kakariko Chest Game/Entrance",
    "@Quarreling Brothers Right/Entrance",
    "@Race Game/Take This Trash",
    "@Library Entrance/Entrance",
    "@Library/On The Shelf",
    "@Forest Hideout Entrance/Entrance",
    "@Forest Hideout Dropdown/Dropdown",
    "@Forest Chest Game/Tree",
    "@Castle Secret Dropdown/Dropdown",
    "@Castle Secret Entrance/Entrance",
    "@Castle Left Entrance/Entrance",
    "@Castle Right Entrance/Entrance",
    "@Link's House Entrance/Entrance",
    "@Central Bonk Rocks/Entrance",
    "@Dark Trees Fairy/Entrance",
    "@Dark Witch's Hut/Entrance",
    "@East Storyteller Cave/Entrance",
    "@Dark Sahasrahla/Entrance",
    "@Pyramid Fairy Entrance/Entrance",
    "@Pyramid Hole/Dropdown",
    "@Hype Cave Entrance/Entrance",
    "@Bombos Tablet/Tablet",
    "@South of Grove/Entrance",
    "@Witch's Hut/Entrance",
    "@Waterfall Fairy Entrance/Entrance",
    "@Zora's Domain/Ledge",
    "@Sahasrala's Hut Entrance/Entrance",
    "@Trees Fairy Cave/Entrance",
    "@Long Fairy Cave/Entrance",
    "@North Bonk Rocks/Entrance",
    "@Houlihan Hole/Dropdown",
    "@Houlihan Entrance/Entrance",
    "@King's Tomb Entrance/Entrance",
    "@Graveyard Ledge Entrance/Entrance",
    "@Desert Left Entrance/Entrance",
    "@Desert Back Entrance/Entrance",
    "@Desert Right Entrance/Entrance",
    "@Desert Fairy Cave/Entrance",
    "@Fifty Rupee Cave/Entrance",
    "@Aginah's Cave Entrance/Entrance",
    "@Hammer House/Entrance",
    "@Dark Village Fortune Teller/Entrance",
    "@Dark Chapel/Entrance",
    "@Shield Shop/Entrance",
    "@Dark Lumberjack/Entrance",
    "@C-Shaped House Entrance/Entrance",
    "@Chest Game Entrance/Entrance",
    "@Brewery Entrance/Entrance",
    "@Hammer Pegs Entrance/Entrance",
    "@Bumper Cave Top/Entrance",
    "@Bumper Cave Bottom/Entrance",
    "@Bumper Ledge/Ledge",
    "@Dark Bonk Rocks/Entrance",
    "@Dam Entrance/Entrance",
    "@Hype Fairy Cave/Entrance",
    "@Lake Fortune Teller/Entrance",
    "@Lake Shop/Entrance",
    "@Upgrade Fairy/Entrance",
    "@Bomb Shop/Entrance",
    "@Archery Game/Entrance",
    "@Quarreling Brothers Left/Entrance",
    "@Dark Lake Shop/Entrance",
    "@Mini Moldorm Cave Entrance/Entrance",
    "@Ice Rod Cave Entrance/Entrance",
    "@Cold Bee Cave/Entrance",
    "@Twenty Rupee Cave/Entrance",
    "@Dark Lake Hylia Fairy/Entrance",
    "@Hamburger Helper Cave/Entrance",
    "@Spike Hint Cave/Entrance",
    "@Lake Hylia Island/Island",
    "@Mire Shed Entrance/Entrance",
    "@Mire Fairy/Entrance",
    "@Mire Hint Cave/Entrance",
    "@Checkerboard Cave Entrance/Entrance",
    "@Death Mountain Entry Back/Entrance",
    "@Old Man Home/Entrance",
    "@Old Man Back Door/Entrance",
    "@Death Mountain Exit Front/Entrance",
    "@Spectacle Rock/Up On Top",
    "@Spectacle Rock Top/Entrance",
    "@Spectacle Rock Left/Entrance",
    "@Spectacle Rock Right/Entrance",
    "@Dark Mountain Fairy/Entrance",
    "@Ether Tablet/Tablet",
    "@Spike Cave Entrance/Entrance",
    "@Spiral Cave Top/Entrance",
    "@Paradox Cave Middle/Entrance",
    "@Paradox Cave Bottom/Entrance",
    "@EDM Connector Bottom/Entrance",
    "@EDM Connector Top/Entrance",
    "@Paradox Cave Top/Entrance",
    "@Spiral Cave Bottom/Entrance",
    "@Hookshot Fairy Cave/Entrance",
    "@Super-Bunny Cave Bottom/Entrance",
    "@Dark Death Mountain Shop/Entrance",
    "@Super-Bunny Cave Top/Entrance",
    "@Hookshot Cave Entrance/Entrance",
    "@Hookshot Cave Top/Entrance",
    "@TR Bridge Left/Entrance",
    "@TR Safety Door/Entrance",
    "@Floating Island/Island",
    "@Castle Main Entrance/Entrance",
    "@Sanctuary Entrance/Entrance",
    "@Sanctuary Grave/Dropdown",
    "@Agahnim's Tower Entrance/Entrance",
    "@Eastern Palace Entrance/Entrance",
    "@Desert Front Entrance/Entrance",
    "@Palace of Darkness Entrance/Entrance",
    "@Swamp Palace Entrance/Entrance",
    "@Skull Woods Back/Entrance",
    "@Thieves Town Entrance/Entrance",
    "@Ice Palace Entrance/Entrance",
    "@Misery Mire Entrance/Entrance",
    "@Tower of Hera Entrance/Entrance",
    "@Turtle Rock Entrance/Entrance",
    "@Mimic Cave Entrance/Entrance",
    "@Ganon's Tower Entrance/Entrance"
}

CaptureBadgeSections = {
    "@Desert Ledge/Ledge"
}
-- CaptureBadgeSections = {

--     --List out all of the locations that can be capturable

--     --Format: 
--     --"@Title of Location/Name of Section with Capture Item"
    


   
    
    
-- }