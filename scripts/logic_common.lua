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

function gtCrystalCount()
    local reqCount = Tracker:ProviderCountForCode("gt_crystals")
    local count = Tracker:ProviderCountForCode("crystal")
    local prizes = Tracker:ProviderCountForCode("prize")

    if count >= reqCount or prizes == 10 then
        return 1
    else
        return 0
    end
end

function ganonCrystalCount()
    local reqCount = Tracker:ProviderCountForCode("ganon_crystals")
    local count = Tracker:ProviderCountForCode("crystal")
    local prizes = Tracker:ProviderCountForCode("prize")

    if count >= reqCount or prizes == 10 then
        return 1
    else
        return 0
    end
end