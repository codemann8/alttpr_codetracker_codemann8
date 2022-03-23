SaveStorage = CustomItem:extend()

function SaveStorage:init()
    self:createItem("Save Storage")
end

function SaveStorage:save()
    local saveData = {}
    saveData["roomSlots"] = INSTANCE.ROOMSLOTS
    saveData["doorSlots"] = INSTANCE.DOORSLOTS
    saveData["roomCursor"] = INSTANCE.ROOMCURSORPOSITION
    return saveData
end

function SaveStorage:load(data)
    INSTANCE.ROOMSLOTS = JObjectToLuaTable(data["roomSlots"])
    INSTANCE.DOORSLOTS = JObjectToLuaTable(data["doorSlots"])
    updateRoomSlots(0, true)
    INSTANCE.ROOMCURSORPOSITION = data["roomCursor"]
end
