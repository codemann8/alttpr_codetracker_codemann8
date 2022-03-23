DykCloseItem = ActionItem:extend()

function DykCloseItem:init(number)
    self.label = "Close"
    self.number = number
    self.code = "dyk_exit_" .. self.number

    self:createItem(self.label)

    if self.number == 1 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/overlays/overlay-x.png")
    end
end

function DykCloseItem:onLeftClick()
    if self.ItemInstance.Icon ~= nil and Tracker.ActiveVariantUID == "full_tracker" or Tracker.ActiveVariantUID == "items_only" or Tracker.ActiveVariantUID == "vanilla" then
        if self.number ~= 3 and STATUS.START_DATE["month"] == 4 and STATUS.START_DATE["day"] == 1 then
            self.ItemInstance.Icon = nil
            Tracker:FindObjectForCode("dyk_exit_" .. self.number + 1).Icon = ImageReference:FromPackRelativePath("images/overlays/overlay-x.png")
        else
            Layout:FindLayout("ref_dyk_grid").Root.Layout = nil
        end
    end
end
