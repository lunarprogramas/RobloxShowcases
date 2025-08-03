local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreditStore = DataStoreService:GetDataStore("Credits")

local import = require(ReplicatedStorage.Shared.import)

local Network = import("Shared/Network")
local VendorFunction: RemoteFunction = Network.GetRemoteFunction("RF_Vendor")

local CreditService = {
    Players = {}
}

local starterCredits = 50

-- made by @lunarprogramas (janslan)

function CreditService:GetAndSetPlayerCredits(player: Player)
    local checkData = CreditStore:GetAsync(player.UserId)
    local credits = 0

    if not checkData then
        self.Players[player] = starterCredits
        CreditStore:SetAsync(player.UserId, starterCredits)
        credits = starterCredits
    else
        self.Players[player] = checkData
        credits = checkData
    end

    return credits
end

function CreditService:RemoveAndSetPlayerCredits(plr: Player)
    local credits = self.Players[plr]
    CreditStore:SetAsync(plr.UserId, credits)
    self.Players[plr] = nil
end

function CreditService:AddCredits(plr: Player, amount: number)
    self.Players[plr] += amount
    VendorFunction:InvokeClient(plr, "RefreshCredits", self.Players[plr])
end

function CreditService:RemoveCredits(plr: Player, amount: number)
    if self.Players[plr] <= 0 then
        return "This player is already in debt."
    else
        self.Players[plr] -= amount
        VendorFunction:InvokeClient(plr, "RefreshCredits", self.Players[plr])
    end
end

function CreditService:GetCredits(plr: Player)
    return self.Players[plr] or 0
end

function CreditService:Init()
    for _, plr: Player in Players:GetPlayers() do
        self:GetAndSetPlayerCredits(plr)
    end

    Players.PlayerAdded:Connect(function(player)
        self:GetAndSetPlayerCredits(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:RemoveAndSetPlayerCredits(player)
    end)

    game:BindToClose(function()
        for _, plr in Players:GetPlayers() do
            self:RemoveAndSetPlayerCredits(plr)
        end
    end)
end


function CreditService:Start()
    
end


return CreditService