TrackerRestore = ActionItem:extend()

function TrackerRestore:init()
    self.label = "Restore From Backup"
    self.code = "tracker_restore"

    self:createItem(self.label)

    self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/icons/misc/restore.png")
end

function TrackerRestore:onLeftClick()
    if CONFIG.ENABLE_BACKUP_FILE then
        ScriptHost:PushMarkdownNotification(NotificationType.Message, "Restored From Backup")
        restoreBackup()
    end
end
