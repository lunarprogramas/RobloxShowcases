local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VendorService = {
    Vendors = {}
}

local import = require(ReplicatedStorage.Shared.import)

local Network = import("Shared/Network")
local VendorFunction: RemoteFunction = Network.GetRemoteFunction("RF_Vendor")

export type VendorSettings = {
    Items: {
        [string]: {
            Price: number,
            Permissions: string | table,
            ItemToRecieve: string
        }
    },
    VendorName: string,
    Permissions: string | table,
    Rank: string
}

function VendorService:Init()
    local instances = CollectionService:GetTagged("Vendor")
    local nametag: BillboardGui = ReplicatedStorage:WaitForChild("Nametag", 5)
    assert(nametag, "[VendorService] Failed to find nametag for vendor.")

    for _, vendor: Model in instances do
        local configScript: ModuleScript | VendorSettings = vendor:FindFirstChild("Settings")
        if configScript then
            configScript = require(configScript)
        else
            warn(("[ VendorService ] Failed to find configuration file for %s vendor."):format(vendor.Name))
            continue -- go to the next vendor if possible
        end

        local clonedNametag = nametag:Clone()
        clonedNametag.Parent = vendor:FindFirstChild("Head")
        clonedNametag.Adornee = vendor:FindFirstChild("Head")
        clonedNametag.Rank.Text = configScript.Rank
        clonedNametag.Username.Text = configScript.VendorName

        table.insert(self.Vendors, { VendorModel = vendor, Name = configScript.VendorName, Products = configScript.Items, Permissions = configScript.Permissions })
        warn(("[ VendorService ] Successfully loaded %s vendor!"):format(configScript.VendorName))
    end

    VendorFunction.OnServerInvoke = function(player, request, ...)
        local args = { ... }

        if request == "GetVendors" then
            return self.Vendors
        end
    end
end

function VendorService:Start()
    
end

return VendorService