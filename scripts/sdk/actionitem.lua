ActionItem = CustomItem:extend()

function ActionItem:init(name, code, image)
    self.label = name
    self.code = code

    self:createItem(self.label)

    self.ItemInstance.Icon = ImageReference:FromPackRelativePath(image)
end

function ActionItem:onLeftClick()
    --do something here
end

function ActionItem:onRightClick()
    self:onLeftClick()
end

function ActionItem:canProvideCode(code)
    return code == self.code
end
