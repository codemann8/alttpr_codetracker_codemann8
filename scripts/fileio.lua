function itemFlippedOn(item)
    if os.time() - STATUS.LastMajorItem > 2 and STATUS.AutotrackerInGame then
        if item == "sword" then
            local object = Tracker:FindObjectForCode(item)
            if object.CurrentStage == 2 then
                sendExternalMessage("item", "sword")
            elseif object.CurrentStage == 3 then
                sendExternalMessage("item", "master")
            elseif object.CurrentStage == 4 then
                sendExternalMessage("item", "bacon")
            elseif object.CurrentStage == 5 then
                sendExternalMessage("item", "butter")
            end
        elseif item == "gloves" then
            local object = Tracker:FindObjectForCode(item)
            if object.CurrentStage == 1 then
                sendExternalMessage("item", "gloves")
            elseif object.CurrentStage == 2 then
                sendExternalMessage("item", "mitts")
            end
        elseif item == "bow" or item == "hammer" or item == "flute" or item == "boots"
                or item == "lamp" or item == "halfmagic" or item == "firerod" or item == "icerod"
                or item == "bombos" or item == "ether" or item == "quake" or item == "mushroom"
                or item == "powder" or item == "shovel" or item == "mirror" or item == "hookshot"
                or item == "book" or item == "cape" or item == "byrna" or item == "somaria"
                or item == "net" or item == "flippers" or item == "pearl" then
            sendExternalMessage("item", item)
        end
        
        STATUS.LastMajorItem = os.time()
    end
end

function sendExternalMessage(filename, value)
    if value then
        if (filename == "item" and CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_ITEM_FILE)
                or (filename == "dungeon" and CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_DUNGEON_IMAGE)
                or (filename == "health" and CONFIG.AUTOTRACKER_ENABLE_EXTERNAL_HEALTH_FILE) then
            local file = io.open(os.getenv("USERPROFILE") .. "\\Documents\\EmoTracker\\" .. filename .. ".txt", "w+")
            if file then
                io.output(file)
                io.write(value)
                io.close(file)
            end
        end
    end
end

function saveSettings(setting)
    local emoDir = "Documents\\EmoTracker\\"
    local packRoot = "user_overrides\\alttpr_codetracker_codemann8\\"
    
    local function writeOverride(path, filename, text)
        local fullDir = ""

        if os.getenv("OneDrive") and dirExists(os.getenv("OneDrive") .. "\\" .. emoDir) then
            fullDir = os.getenv("OneDrive") .. "\\"
        elseif dirExists(CONFIG.DOCUMENTS_FOLDER .. emoDir) then
            fullDir = CONFIG.DOCUMENTS_FOLDER
        else
            print("ERROR: User has changed the location of their 'Documents' folder. Press F1 to read the documentation for steps to resolve.")
            print("OneDrive:", os.getenv("OneDrive"))
            print("UserProfile:", os.getenv("UserProfile"))
        end

        local written = false
        if fullDir ~= "" then
            written = writeFile(fullDir .. emoDir .. packRoot, path, filename, text)
        
            if dirExists(fullDir .. emoDir .. "dev\\") then
                written = writeFile(fullDir .. emoDir .. "dev\\" .. packRoot, path, filename, text) or written
            end

            if not written then
                print("ERROR: User hasn't overridden any settings files yet. Press F1 to read the documentation for steps to resolve.")
            end
        end

        Layout:FindLayout("ref_settings_message").Root.Layout = not written and Layout:FindLayout("settings_message") or nil
        Layout:FindLayout("ref_settings_v_message").Root.Layout = not written and Layout:FindLayout("settings_v_message") or nil
    end
    
    local function deleteOverride(path, filename)
        local fullDir = ""
        
        if os.getenv("OneDrive") and dirExists(os.getenv("OneDrive") .. "\\" .. emoDir) then
            fullDir = os.getenv("OneDrive") .. "\\"
        elseif dirExists(CONFIG.DOCUMENTS_FOLDER .. emoDir) then
            fullDir = CONFIG.DOCUMENTS_FOLDER
        else
            print("ERROR: User has changed the location of their 'Documents' folder. Press F1 to read the documentation for steps to resolve.")
            print("OneDrive:", os.getenv("OneDrive"))
            print("UserProfile:", os.getenv("UserProfile"))
            return false
        end

        if dirExists(fullDir .. emoDir .. packRoot .. path .. filename) then
            os.remove(fullDir .. emoDir .. packRoot .. path .. filename)
        end
        
        if dirExists(fullDir .. emoDir .. "dev\\" .. packRoot .. path .. filename) then
            os.remove(fullDir .. emoDir .. "dev\\" .. packRoot .. path .. filename)
        end
    end
    
    local textOutput = ""
    local isDefault = true
    for textcode, data in pairs(DATA.SettingsData[setting.file]) do
        local name = data[1]
        local code = data[2]
        local default = data[4]
        local otherSetting = Tracker:FindObjectForCode(code).ItemState
        if otherSetting.default ~= otherSetting:getState() then
            isDefault = false
        end
        textOutput = textOutput .. textcode .. " = " .. tostring(otherSetting:getState()) .. "\n"
    end
    if isDefault then
        deleteOverride("settings\\", setting.file)
    else
        writeOverride("settings\\", setting.file, textOutput)
    end
end

function writeFile(rootpath, localpath, filename, text)
    if not dirExists(rootpath .. localpath) then
        --Tracker.ActiveGamePackage:ExportUserOverride(localpath .. filename)
        --TODO: Revisit when Emo adds ability to export overrides from code
        return false
    end

    local file = io.open(rootpath .. localpath .. filename, "w+")
    if file then
        io.output(file)
        io.write(text)
        io.close(file)
        return true
    end

    return false
end

function dirExists(path)
    local ok, err, code = os.rename(path, path)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    return ok, err
end