function updateProgressiveBow(segment)
    local item = Tracker:FindObjectForCode("bow")
    local prevActive = item.Active
    local data = { nil, nil, nil }
    if segment:ContainsAddress(0x7ef340) then
        data[1] = segment:ReadUInt8(0x7ef340)
        data[2] = AutoTracker:ReadU8(0x7ef38e, 0)
        data[3] = AutoTracker:ReadU8(0x7ef377, 0)
    elseif segment:ContainsAddress(0x7ef38e) then
        data[1] = AutoTracker:ReadU8(0x7ef340, 0)
        data[2] = segment:ReadUInt8(0x7ef38e)
        data[3] = AutoTracker:ReadU8(0x7ef377, 0)
    elseif segment:ContainsAddress(0x7ef377) then
        data[1] = AutoTracker:ReadU8(0x7ef340, 0)
        data[2] = AutoTracker:ReadU8(0x7ef38e, 0)
        data[3] = segment:ReadUInt8(0x7ef377)
    end
    if Tracker.ActiveVariantUID == "vanilla" then
        if data[1] > 2 then
            item.Active = true
            item.CurrentStage = 2
        elseif data[1] > 0 then
            item.Active = true
            item.CurrentStage = 1
        else
            item.Active = false
            item.CurrentStage = 0
        end
    else

        if data[2] & 0x80 > 0 and data[1] > 0 then
            item.Active = true
        elseif not item.Active or not STATUS.AutotrackerInGame then
            item.Active = false
        end

        if data[2] & 0x40 > 0 then
            if OBJ_RETRO:getState() > 0 and data[3] == 0 then
                item.CurrentStage = 0
            else
                item.CurrentStage = 2
            end
        elseif OBJ_RETRO:getState() == 0 or (OBJ_RETRO:getState() > 0 and data[3] == 0) then
            item.CurrentStage = 0
        else
            item.CurrentStage = 1
        end
    end

    if not prevActive and item.Active then
        itemFlippedOn("bow")
    end
end

function updateProgressiveMirror(segment)
    local item = Tracker:FindObjectForCode("mirror")
    if segment:ReadUInt8(0x7ef353) & 0x02 > 0 then
        if item.CurrentStage ~= 1 then
            itemFlippedOn("mirror")
        end
        item.CurrentStage = 1
    else
        item.CurrentStage = 0
        if segment:ReadUInt8(0x7ef353) & 0x01 > 0 then
            item.Stages[item.CurrentStage].Icon = ImageReference:FromPackRelativePath("images/items/mirror-scroll.png")
            item.Icon = ImageReference:FromPackRelativePath("images/items/mirror-scroll.png")
            if OBJ_DOORSHUFFLE:getState() == 0 then
                OBJ_DOORSHUFFLE:onLeftClick()
            end
        else
            item.Stages[item.CurrentStage].Icon = ImageReference:FromPackRelativePath("images/items/mirror.png", "@disabled")
            item.Icon = ImageReference:FromPackRelativePath("images/items/mirror.png", "@disabled")
        end
    end
end

function updateFlute(segment)
    local item = Tracker:FindObjectForCode("flute")
    if Tracker.ActiveVariantUID == "vanilla" then
        print("NO FLUTE HERE")
        item.Active = segment:ReadUInt8(0x7ef34c) > 1
    else
        local value = 0
        if segment:ContainsAddress(0x7ef38c) then
            value = segment:ReadUInt8(0x7ef38c)
        else
            value = AutoTracker:ReadU8(0x7ef38c, 0)
        end

        local fakeFlute = value & 0x02
        local realFlute = value & 0x01

        if realFlute ~= 0 then
            if item.CurrentStage == 0 then
                itemFlippedOn("flute2")
            end
            item.Active = true
            item.CurrentStage = 1
        elseif fakeFlute ~= 0 then
            if not item.Active then
                itemFlippedOn("flute")
            end
            item.Active = true
            item.CurrentStage = 0
        elseif not item.Active or not STATUS.AutotrackerInGame then
            item.Active = false
        end
    end
end

function updateBottles(segment)
    for i = 0, 3, 1 do
        local item = Tracker:FindObjectForCode("bottle"..i)
        local contents = segment:ReadUInt8(0x7ef35c + i)
        print(string.format("bottle %d contents: %d", i, contents))
        if contents == 0 then
            item.CurrentStage = 0
        else
            item.CurrentStage = contents - 1
        end
    end
end

function updateBatIndicatorStatus(status)
    local item = Tracker:FindObjectForCode("powder_used")
    if item and (not item.Active or not STATUS.AutotrackerInGame) then
        item.Active = status
    end
end

function updateShovelIndicatorStatus(status)
    local item = Tracker:FindObjectForCode("shovel_used")
    if item and (not item.Active or not STATUS.AutotrackerInGame) then
        item.Active = status
    end
end

function doStatsMessage()
    function read32BitTimer(baseAddress)
        local timer = 0
        timer = timer | (AutoTracker:ReadU8(baseAddress + 3, 0) << 24)
        timer = timer | (AutoTracker:ReadU8(baseAddress + 2, 0) << 16)
        timer = timer | (AutoTracker:ReadU8(baseAddress + 1, 0) << 8)
        timer = timer | (AutoTracker:ReadU8(baseAddress + 0, 0) << 0)
    
        local hours = timer // (60 * 60 * 60)
        local minutes = (timer % (60 * 60 * 60)) // (60 * 60)
        local seconds = (timer % (60 * 60)) // (60)
        local frames = timer % 60
    
        return hours, minutes, seconds, frames
    end

    -- Read completion timer
    local hours, minutes, seconds, frames = read32BitTimer(0x7ef43e)

    local deaths = AutoTracker:ReadU8(0x7ef449, 0)
    local bonks = AutoTracker:ReadU8(0x7ef420, 0)

    local markdown = string.format(DATA.StatsMarkdownFormat, CACHE.CollectionRate, math.max(CACHE.CollectionMax, 216), deaths, bonks, hours, minutes, seconds, frames)
    ScriptHost:PushMarkdownNotification(NotificationType.Celebration, markdown)
end