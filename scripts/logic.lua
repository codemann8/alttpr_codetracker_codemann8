-- DO NOT OVERRIDE THIS FILE, INSTEAD OVERRIDE scripts/logic_custom.lua and only include the Lua code you want changed there

function canActivateTablets()
    if Tracker:ProviderCountForCode("swordless") > 0 then
        return Tracker:ProviderCountForCode("hammer")
    else
        return Tracker:ProviderCountForCode("sword2")
    end
end

function canUseMedallions()
    if Tracker:ProviderCountForCode("swordless") > 0 then
        return 1
    else
        return Tracker:ProviderCountForCode("sword")
    end
end

function canRemoveCurtains()
    if Tracker:ProviderCountForCode("swordless") > 0 then
        return 1
    else
        return Tracker:ProviderCountForCode("sword")
    end
end

function canClearAgaTowerBarrier()
    -- With cape, we can always get through
    if Tracker:ProviderCountForCode("cape") > 0 then
        return 1
    end
    -- Otherwise we need master sword or a hammer depending on the mode
    if Tracker:ProviderCountForCode("swordless") > 0 then
        return Tracker:ProviderCountForCode("hammer")
    else
        return Tracker:ProviderCountForCode("sword2")
    end    
end

function canDamageBoss(locationRef)
    local boss = Tracker:FindObjectForCode(locationRef)
    if boss and boss.CapturedItem then
        boss = boss.CapturedItem.Name
    else
        boss = locationRef:sub(locationRef:find("/") + 1)
    end
    if boss == "Ice Armos" then
        boss = "Armos"
    end
    if locationRef == "@Thieves Town/Blind" and boss == "Blind" then
        return 1, Tracker:FindObjectForCode("@Bosses/Blind At Home").AccessibilityLevel
    else
        return 1, Tracker:FindObjectForCode("@Bosses/" .. boss).AccessibilityLevel
    end
end

function canEngageTTBoss()
    local boss = Tracker:FindObjectForCode("@Thieves Town/Blind")
    if boss and boss.CapturedItem then
        boss = boss.CapturedItem.Name
    else
        boss = "Blind"
    end
    if boss ~= "Blind" then
        return 1, Tracker:FindObjectForCode("@Thieves Town/Hallway Key").AccessibilityLevel
    else
        return 1, AccessibilityLevel.None
    end
end

function magicExtensions()
    local bars = Tracker:ProviderCountForCode("halfmagic") + 1
    bars = bars * (Tracker:ProviderCountForCode("quartermagic") + 1)
    local bottleCount = Tracker:ProviderCountForCode("bottle") --TODO: This doesnt handle multiple bottles

    return bars * (bottleCount + 1)
end

function hasSeenMireMedallion()
    local medallion = Tracker:FindObjectForCode("bombos")
    if medallion.CurrentStage == 1 or medallion.CurrentStage == 3 then
        return 1
    end
    
    medallion = Tracker:FindObjectForCode("ether")
    if medallion.CurrentStage == 1 or medallion.CurrentStage == 3 then
        return 1
    end

    medallion = Tracker:FindObjectForCode("quake")
    if medallion.CurrentStage == 1 or medallion.CurrentStage == 3 then
        return 1
    end

    return 0
end

function hasSeenTurtleMedallion()
    local medallion = Tracker:FindObjectForCode("bombos")
    if medallion.CurrentStage > 1 then
        return 1
    end
    
    medallion = Tracker:FindObjectForCode("ether")
    if medallion.CurrentStage > 1 then
        return 1
    end

    medallion = Tracker:FindObjectForCode("quake")
    if medallion.CurrentStage > 1 then
        return 1
    end

    return 0
end

function hasNotSeenMireMedallion()
    if hasSeenMireMedallion() == 1 then
        return 0
    else
        local medallion = Tracker:FindObjectForCode("bombos")
        if medallion.Active then
            medallion = Tracker:FindObjectForCode("ether")
            if medallion.Active then
                medallion = Tracker:FindObjectForCode("quake")
                if medallion.Active then
                    return 0
                end
            end
        end
        return 1
    end
end

function hasNotSeenTurtleMedallion()
    if hasSeenTurtleMedallion() == 1 then
        return 0
    else
        local medallion = Tracker:FindObjectForCode("bombos")
        if medallion.Active then
            medallion = Tracker:FindObjectForCode("ether")
            if medallion.Active then
                medallion = Tracker:FindObjectForCode("quake")
                if medallion.Active then
                    return 0
                end
            end
        end
        return 1
    end
end
