local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local VendorService = {
    Vendors = {}
}

local import = require(ReplicatedStorage.Shared.import)

local CreditService = import("Services/CreditService")

local Network = import("Shared/Network")
local VendorFunction: RemoteFunction = Network.GetRemoteFunction("RF_Vendor")

-- made by @lunarprogramas (janslan)

export type VendorSettings = {
    Items: {
        [string]: {
            Price: number,
            Permissions: string | table,
            ItemToRecieve: string,
            StoreName: string,
			StoreDescription: string,
        }
    },
    VendorName: string,
    Permissions: string | table,
    Rank: string,
    Messages: {
        [number]: string
    }
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

        table.insert(self.Vendors, { VendorModel = vendor, Name = configScript.VendorName, Products = configScript.Items, Permissions = configScript.Permissions, Messages = configScript.Messages, VendorMusic = configScript.VendorMusic })
        warn(("[ VendorService ] Successfully loaded %s vendor!"):format(configScript.VendorName))
    end

    VendorFunction.OnServerInvoke = function(player, request, ...)
        local args = { ... }

        if request == "GetVendors" then
            return self.Vendors
        elseif request == "ProcessReciept" then
            local requireAmount = args[1]
            local item = args[2]

            local creditCheck = CreditService:GetCredits(player)

            if creditCheck < requireAmount then
                return false, "Not enough credits."
            else
                local toolCheck = ServerStorage.Tools:FindFirstChild(item)
                if not toolCheck then
                    return false, "Tool not found."
                end

                local cloned = toolCheck:Clone()
                CreditService:RemoveCredits(player, requireAmount)
                cloned.Parent = player.Backpack

                VendorFunction:InvokeClient(player, "RefreshCredits", CreditService:GetCredits(player))

                return true, nil
            end
        elseif request == "GetCredits" then
            return CreditService:GetCredits(player)
        end
    end
end

function VendorService:Start()
    
end

return VendorService