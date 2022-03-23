TrackerSync = ActionItem:extend()

function TrackerSync:init()
    self.label = "Refresh Autotracker"
    self.code = "tracker_sync"

    self:createItem(self.label)

    self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/icons/refresh.png")
end

function TrackerSync:onLeftClick()
    if STATUS.AutotrackerInGame then
        disposeMemoryWatch()
        initMemoryWatch()
    end
end
