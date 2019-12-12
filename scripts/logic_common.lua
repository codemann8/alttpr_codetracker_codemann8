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

function gtCrystalCount()
    local reqCount = Tracker:ProviderCountForCode("gt_crystals")
    local count = Tracker:ProviderCountForCode("crystal")

    if count >= reqCount then
        return 1
    else
        return 0
    end
end

function ganonCrystalCount()
    local reqCount = Tracker:ProviderCountForCode("ganon_crystals")
    local count = Tracker:ProviderCountForCode("crystal")

    if count >= reqCount then
        return 1
    else
        return 0
    end
end