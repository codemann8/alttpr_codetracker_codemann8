SaveStorage = CustomItem:extend()

function SaveStorage:init()
    self:createItem("Save Storage")
end

function SaveStorage:save()
    local saveData = {}
    saveData["roomSlots"] = ROOMSLOTS
    saveData["doorSlots"] = DOORSLOTS
    return saveData
end

function SaveStorage:load(data)
    ROOMSLOTS = JObjectToLuaTable(data["roomSlots"])
    DOORSLOTS = JObjectToLuaTable(data["doorSlots"])

    updateDoorSlots(0, true)
end
