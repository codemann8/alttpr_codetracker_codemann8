function itemFlippedOn(item)
    if os.time() - START_TIME > 5 then
        if item == "sword" then
            local object = Tracker:FindObjectForCode(item)
            if object.CurrentStage == 1 then
                sendExternalMessage("item", "sword")
                START_TIME = os.time()
            elseif object.CurrentStage == 2 then
                sendExternalMessage("item", "master")
                START_TIME = os.time()
            elseif object.CurrentStage == 3 then
                sendExternalMessage("item", "bacon")
                START_TIME = os.time()
            elseif object.CurrentStage == 4 then
                sendExternalMessage("item", "butter")
                START_TIME = os.time()
            end
        elseif item == "glove" then
            local object = Tracker:FindObjectForCode(item)
            if object.CurrentStage == 1 then
                sendExternalMessage("item", "gloves")
                START_TIME = os.time()
            elseif object.CurrentStage == 2 then
                sendExternalMessage("item", "mitts")
                START_TIME = os.time()
            end
        elseif
            item == "bow" or item == "hammer" or item == "flute" or item == "boots" or item == "lamp" or
                item == "halfmagic" or
                item == "firerod" or
                item == "icerod" or
                item == "bombos" or
                item == "ether" or
                item == "quake" or
                item == "mushroom" or
                item == "powder" or
                item == "shovel" or
                item == "mirror" or
                item == "hookshot" or
                item == "book" or
                item == "cape" or
                item == "byrna" or
                item == "somaria" or
                item == "net" or
                item == "flippers" or
                item == "pearl"
         then
            sendExternalMessage("item", item)
            START_TIME = os.time()
        end
    end
end

function sendExternalMessage(filename, value)
    if value then
        if
            (filename == "item" and AUTOTRACKER_ENABLE_EXTERNAL_ITEM_FILE) or
                (filename == "dungeon" and AUTOTRACKER_ENABLE_EXTERNAL_DUNGEON_IMAGE)
         then
            local file =
                io.open("C:/Users/" .. os.getenv("USERNAME") .. "/Documents/EmoTracker/" .. filename .. ".txt", "w+")
            if file then
                io.output(file)
                io.write(value)
                io.close(file)
            end
        end
    end
end
