TrackerSync = ActionItem:extend()

function TrackerSync:init()
    self.label = "Refresh Autotracker"
    self.code = "tracker_sync"

    self:createItem(self.label)

    self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/icons/misc/refresh.png")
end

function TrackerSync:onLeftClick()
    if STATUS.AutotrackerInGame then
        ScriptHost:PushMarkdownNotification(NotificationType.Message, "Autotracker Refreshed")
        disposeMemoryWatch()
        initMemoryWatch()
    end
end
