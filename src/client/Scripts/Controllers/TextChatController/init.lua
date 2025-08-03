local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local TextChatController = {
    ChatConfigurations = {}
}

local ChatConfigs = script.ChatConfig

local import = require(ReplicatedStorage.Shared.import)
local HasPermission = import("Shared/Permissions")

function TextChatService.OnBubbleAdded(message: TextChatMessage, adornee: Instance)
    if message.TextSource then
        if HasPermission(message.TextSource, "Owner") then
            local bubbleChatConfig = Instance.new("BubbleChatMessageProperties")

            for name, config in TextChatController.ChatConfigurations["Owner"] do
                bubbleChatConfig[name] = config
            end

            return bubbleChatConfig
        end
    elseif adornee then
        if CollectionService:HasTag(adornee.Parent, "Vendor") then
            local bubbleChatConfig = Instance.new("BubbleChatMessageProperties")

            for name, config in TextChatController.ChatConfigurations["Vendors"] do
                bubbleChatConfig[name] = config
            end

            return bubbleChatConfig
        end
    end
end

function TextChatController:Init()
    for _, module in ChatConfigs:GetChildren() do
        local moduleName = module.Name
        local success, result = pcall(require, module)
        if not success then
            warn("[ TextChatController ] Failed to load chat config due to :", result)
            continue
        end

        self.ChatConfigurations[moduleName] = result
    end
end

function TextChatController:Start()
end

return TextChatController