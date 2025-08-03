local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VendorController = {
    Vendors = {}
}

local import = require(ReplicatedStorage.Shared.import)
local Vendor = import("Modules/Vendor")

local Network = import("Shared/Network")
local VendorFunction: RemoteFunction = Network.GetRemoteFunction("RF_Vendor")

-- made by @lunarprogramas (janslan)

export type VendorInstance = {
    VendorModel: Model,
    Name: string,
    Products: {
        [string]: {
            Price: number,
            Permissions: string | table,
            ItemToRecieve: string,
            StoreName: string,
			StoreDescription: string,
        }
    },
    Permissions: string | table,
    Messages: {
        [number]: string
    }
}

function VendorController:GetVendorByName(name: string)
    for _, vendor in self.Vendors do
        if vendor.VendorModule and vendor.VendorModule.VendorName == name then
            return vendor.VendorModule, vendor.ServerData
        end
    end
end

function VendorController:Init()
    local vendorInstances = VendorFunction:InvokeServer("GetVendors")
    if #vendorInstances > 0 then
        for _, vendor: VendorInstance in vendorInstances do
            local success, vendorModule = pcall(Vendor.new, vendor.VendorModel, vendor)
            if not success then
                warn(("[ VendorController ] Failed to load vendor: %s due to: %s"):format(vendor.Name, vendorModule))
            else
                table.insert(self.Vendors, { ServerData = vendor, VendorModule = vendorModule })
                warn(("[ VendorController ] Loaded vendor: %s"):format(vendor.Name))
            end
        end
    end
end

function VendorController:Start()
    
end

return VendorController