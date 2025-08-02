local RunService = game:GetService("RunService")
local import = {}

local Server = {
    Modules = {},
    Services = {}
}
local Client = {
    Controllers = {},
    Modules = {}
}
local Shared = {}

-- made by @lunarprogramas (janslan)

local function setAliases(modules, type, isShared: boolean?)
    if RunService:IsServer() and not isShared then
        Server[type] = modules
    elseif RunService:IsClient() and not isShared then
        Client[type] = modules
    else
        Shared = modules
    end
end

return function (directory, modules: Object?, isShared: boolean?)
    if string.find(directory, "set") then
        local split = string.split(directory, ":")
        return setAliases(modules, split[2], isShared)
    end

    local split = string.split(directory, "/")
    local context = split[1] == "Shared" and "Shared" or RunService:IsClient() and "Client" or RunService:IsServer() and "Server"

    if context == "Server" then
        for _, module in Server[split[1]] do
            if module.Name == split[2] then
                return require(module)
            end
        end
    elseif context == "Client" then
        for _, module in Client[split[1]] do
            if module.Name == split[2] then
                return require(module)
            end
        end
    elseif context == "Shared" then
        for _, module in Shared do
            if module.Name == split[2] then
                return require(module)
            end
        end
    end
end