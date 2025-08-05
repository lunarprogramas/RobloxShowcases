local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = script.Scripts.Services
local Modules = script.Scripts.Modules

local import = require(ReplicatedStorage.Shared.import)
local con

-- made by @lunarprogramas (janslan)

local function start()
    import("set:Services", Services:GetChildren())
    import("set:Modules", Modules:GetChildren())
    import("set:Shared", ReplicatedStorage.Shared.Scripts:GetChildren())
    import("set:Packages", ReplicatedStorage.Packages:GetChildren())

    warn("initializing services")

    for _, ser in Services:GetChildren() do
        local mod = require(ser)

        local success, result = pcall(function()
            return mod:Init()
        end)

        if not success then
            warn(ser.Name, " - ",  result)
        end
    end

    warn("starting services")

    for _, ser in Services:GetChildren() do
        local mod = require(ser)

        local success, result = pcall(function()
            return mod:Start()
        end)

        if not success then
            warn(ser.Name, " - ",  result)
        end
    end


    workspace:SetAttribute("ServerDoneLoading", true)
end

start()