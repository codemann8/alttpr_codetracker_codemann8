GTCrystalReq = CustomItem:extend()

function GTCrystalReq:init()
    self:createItem("GT Crystal Requirement")
    self.code = "gt_crystals"
    self.ItemInstance.Name = "GT Crystal Requirement"

    self:setState(8)
end

function GTCrystalReq:setState(state)
    self:setProperty("state", state)
end

function GTCrystalReq:getState()
    return self:getProperty("state")
end

function GTCrystalReq:updateIcon()
    if self:getState() == 0 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/icons/crystals-gtsign.png", "overlay|images/overlays/overlay-0.png")
    elseif self:getState() == 1 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/icons/crystals-gtsign.png", "overlay|images/overlays/overlay-1.png")
    elseif self:getState() == 2 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/icons/crystals-gtsign.png", "overlay|images/overlays/overlay-2.png")
    elseif self:getState() == 3 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/icons/crystals-gtsign.png", "overlay|images/overlays/overlay-3.png")
    elseif self:getState() == 4 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/icons/crystals-gtsign.png", "overlay|images/overlays/overlay-4.png")
    elseif self:getState() == 5 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/icons/crystals-gtsign.png", "overlay|images/overlays/overlay-5.png")
    elseif self:getState() == 6 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/icons/crystals-gtsign.png", "overlay|images/overlays/overlay-6.png")
    elseif self:getState() == 7 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/icons/crystals-gtsign.png", "overlay|images/overlays/overlay-7.png")
    elseif self:getState() == 8 then
        self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/icons/crystals-gtsign.png", "overlay|images/overlays/overlay-NA.png")
    end
end

function GTCrystalReq:onLeftClick()
    self:setState((self:getState() - 1) % 9)
end

function GTCrystalReq:onRightClick()
    self:setState((self:getState() + 1) % 9)
end

function GTCrystalReq:canProvideCode(code)
    return code == self.code
end

function GTCrystalReq:providesCode(code)
    if code == self.code then
        if Tracker:ProviderCountForCode("prize") > 10 or Tracker:ProviderCountForCode("crystal") >= math.min(self:getState(), 7) then
            return 1
        end
    elseif code == "gt_crystals_unknown" and self:getState() == 8 then
        return 1
    end
    return 0
end

function GTCrystalReq:save()
    local saveData = {}
    saveData["state"] = self:getState()
    return saveData
end

function GTCrystalReq:load(data)
    if data["state"] ~= nil then
        self:setState(data["state"])
    end
    return true
end

function GTCrystalReq:propertyChanged(key, value)
    if key == "state" then
        self:updateIcon()
    end
end
