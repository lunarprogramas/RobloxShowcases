local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TextChatService = game:GetService("TextChatService")

local Vendor = {}
Vendor.__index = Vendor

local import = require(ReplicatedStorage.Shared.import)
local HasPermission = import("Shared/Permissions")

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
		},
	},
	Permissions: string | table,
	Messages: {
		[number]: string,
	},
}

function Vendor:ShowUI()
	local ui = Players.LocalPlayer.PlayerGui:FindFirstChild("Vendor")
	if not ui then
		return
	end

	local Items: ScrollingFrame = ui.Frame.Items

	for name, item in self.Products do
		local template = ui.Frame.TEMPLATE:Clone()
		template.Name = name
		template.Price.Text = `PRICE: <font color="rgb(49, 176, 58)"><b>${item.Price}</b></font>`
		template.ItemName.Text = item.StoreName
		template.Description.Text = item.StoreDescription
		template.Parent = Items
		template.Visible = true

		table.insert(
			self.Connections,
			template.Purchase.MouseButton1Click:Connect(function()
				local success, result = VendorFunction:InvokeServer("ProcessReciept", item.Price, item.ItemToRecieve)
				if not success then
					warn("[ VENDOR ]", result)
				end
			end)
		)
	end

	table.insert(
		self.Connections,
		ui.Frame.Close.MouseButton1Click:Connect(function()
			return self:HideUI()
		end)
	)

	ui.Frame.VendorTitle.Text = string.upper(`{self.VendorName}'s vendor`)

	local credits = VendorFunction:InvokeServer("GetCredits")
	ui.Frame.Credits.Text = `YOUR CREDITS: <font color="rgb(49, 176, 58)"><b>${credits}</b></font>`

	ui.Enabled = true

    if self.Music then
        self.Music:Play()
    end

    if self.CameraPart then
        workspace.CurrentCamera.CameraSubject = self.CameraPart
        workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed
        workspace.CurrentCamera.Focus = self.CameraPart.CFrame
    end

	self:SendMessage("How can I help?")
	self.Active = true
	return
end

function Vendor:HideUI()
	local ui = Players.LocalPlayer.PlayerGui:FindFirstChild("Vendor")
	if not ui then
		return
	end

    if self.Music then
        self.Music:Stop()
    end

    if self.CameraPart then
        workspace.CurrentCamera.CameraSubject = self.Player.Character.Humanoid
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end

	ui.Enabled = false

	local Items: ScrollingFrame = ui.Frame.Items

	for _, item in Items:GetChildren() do
		if item:IsA("Frame") then
			item:Destroy()
		end
	end

	self:SendMessage("Cya!")
	self.Active = false

	for _, conn in self.Connections do
		conn:Disconnect()
		conn = nil
	end

	return
end

function Vendor:SendMessage(message: string)
	return TextChatService:DisplayBubble(self.VendorObject:FindFirstChild("Head"), message)
end

function Vendor:PlayRandomMessage()
	if not self.LastPlayedMessage then
		self.LastPlayedMessage = 1
		self:SendMessage(self.Messages[self.LastPlayedMessage])
	else
		if self.LastPlayedMessage >= #self.Messages then
			self.LastPlayedMessage = 1
		else
			self.LastPlayedMessage += 1
		end

		self:SendMessage(self.Messages[self.LastPlayedMessage])
	end
end

function Vendor:Interact()
	if not HasPermission(self.Player, self.Permissions) then
		return self:PlayRandomMessage()
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

    self.CameraPart = self.VendorObject:WaitForChild("Camera", 5) or nil

	self.Connections = {}

	self.Messages = Data.Messages
	self.LastPlayedMessage = false

    if Data.VendorMusic then
        self.Music = Instance.new("Sound")
        self.Music.Parent = SoundService
        
        for property, soundData in Data.VendorMusic do
            self.Music[property] = soundData
        end
    end

	self.Prompt = Instance.new("ProximityPrompt", Root)
	self.Prompt.ActionText = "Open Vendor"
	self.Prompt.ObjectText = self.VendorName
	self.Prompt.KeyboardKeyCode = Enum.KeyCode.E
	self.Prompt.HoldDuration = 0.5
	self.Prompt.Triggered:Connect(function()
		return self:Interact()
	end)

	VendorFunction.OnClientInvoke = function(request, ...)
		local args = { ... }
		if request == "RefreshCredits" then
			local ui = Players.LocalPlayer.PlayerGui:FindFirstChild("Vendor")
			if not ui then
				return
			end

			ui.Frame.Credits.Text = `YOUR CREDITS: <font color="rgb(49, 176, 58)"><b>${args[1]}</b></font>`
		end
	end

	return self
end

return Vendor
