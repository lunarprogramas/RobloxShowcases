local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vendor = {}
Vendor.__index = Vendor

local import = require(ReplicatedStorage.Shared.import)
local HasPermission = import("Shared/Permissions")

export type VendorInstance = {
    VendorModel: Model,
    Name: string,
    Products: {
        [string]: {
            Price: number,
            Permissions: string | table,
            ItemToRecieve: string
        }
    },
    Permissions: string | table,
}

function Vendor:ShowUI()
    warn("show ui")
    self.Active = true
    return
end

function Vendor:HideUI()
    warn("hide ui")
    self.Active = false
    return
end

function Vendor:Interact()
    if not HasPermission(self.Player, self.Permissions) then
        return
    end
    
    if self.Active then
        self:HideUI()
    else
        self:ShowUI()
    end
end

function Vendor.new(Root: Model, Data: VendorInstance)
    local self = setmetatable({}, Vendor)

    self.VendorObject = Root
    self.Products = Data.Products
    self.Permissions = Data.Permissions
    self.VendorName = Data.Name
    self.Player = Players.LocalPlayer
    self.Active = false

    self.Prompt = Instance.new("ProximityPrompt", Root)
    self.Prompt.ActionText = "Open Vendor"
    self.Prompt.ObjectText = self.VendorName
    self.Prompt.KeyboardKeyCode = Enum.KeyCode.E
    self.Prompt.HoldDuration = 0.5
    self.Prompt.Triggered:Connect(function()
        return self:Interact()
    end)

    return self
end


return Vendor