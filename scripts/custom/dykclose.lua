DykCloseItem = ActionItem:extend()

function DykCloseItem:init()
    self.label = "Close"
    self.code = "dyk_exit"

    self:createItem(self.label)

    self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/overlays/overlay-x.png")
end

function DykCloseItem:onLeftClick()
    Layout:FindLayout("ref_dyk_grid").Root.Layout = nil
end
