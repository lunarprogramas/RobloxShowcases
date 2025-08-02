local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local public = {}

-- made by @lunarprogramas (janslan)

function public:Init()
                local testerTeam = Teams:FindFirstChild("Tester")
            if not testerTeam then
                testerTeam = Instance.new("Team")
                testerTeam.Name = "Tester"
                testerTeam.TeamColor = BrickColor.new("Alder")
                testerTeam.Parent = Teams
            end

                        local developerTeam = Teams:FindFirstChild("Developer")
            if not developerTeam then
                developerTeam = Instance.new("Team")
                developerTeam.Name = "Developer"
                developerTeam.TeamColor = BrickColor.new("Dark Royal blue")
                developerTeam.Parent = Teams
            end
    Players.PlayerAdded:Connect(function(player)
        if player.Name == "janslan" or player.UserId == -1 then
            player.Team = developerTeam
        else
            player.Team = testerTeam
        end
    end)
end

function public:Start()
    
end

return public