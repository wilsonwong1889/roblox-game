local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local stateRemote = remotesFolder:WaitForChild("StateUpdate") :: RemoteEvent
local messageRemote = remotesFolder:WaitForChild("UiMessage") :: RemoteEvent
local requestStateFunction = remotesFolder:WaitForChild("RequestState") :: RemoteFunction

local existingGui = playerGui:FindFirstChild("Week1HUD")
if existingGui then
	existingGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Week1HUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 50
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.fromOffset(360, 228)
panel.Position = UDim2.fromOffset(20, 20)
panel.BackgroundColor3 = Color3.fromRGB(19, 23, 31)
panel.BackgroundTransparency = 0.08
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 16)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(86, 130, 255)
panelStroke.Thickness = 2
panelStroke.Parent = panel

local function makeLabel(name: string, size: UDim2, position: UDim2, text: string, textSize: number, color: Color3, font: Enum.Font): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextSize = textSize
	label.Font = font
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Parent = panel
	return label
end

local titleLabel = makeLabel("TitleLabel", UDim2.fromOffset(310, 28), UDim2.fromOffset(18, 14), "Break-In Tycoon", 24, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold)
local stageLabel = makeLabel("StageLabel", UDim2.fromOffset(310, 22), UDim2.fromOffset(18, 42), "Week 1 Foundation", 15, Color3.fromRGB(130, 203, 255), Enum.Font.GothamSemibold)
local walletLabel = makeLabel("WalletLabel", UDim2.fromOffset(310, 24), UDim2.fromOffset(18, 76), "Wallet: $0", 18, Color3.fromRGB(105, 255, 140), Enum.Font.Gotham)
local stashLabel = makeLabel("StashLabel", UDim2.fromOffset(310, 24), UDim2.fromOffset(18, 102), "Stash: $0", 18, Color3.fromRGB(255, 217, 117), Enum.Font.Gotham)
local vaultLabel = makeLabel("VaultLabel", UDim2.fromOffset(310, 24), UDim2.fromOffset(18, 128), "Vault: $0", 18, Color3.fromRGB(205, 219, 255), Enum.Font.Gotham)
local tycoonLabel = makeLabel("TycoonLabel", UDim2.fromOffset(310, 24), UDim2.fromOffset(18, 154), "Tycoon: Unclaimed", 18, Color3.fromRGB(220, 226, 240), Enum.Font.Gotham)

local statusLabel = makeLabel("StatusLabel", UDim2.fromOffset(310, 48), UDim2.fromOffset(18, 182), "Walk to a green claim pad to claim a tycoon.", 15, Color3.fromRGB(180, 191, 214), Enum.Font.Gotham)
statusLabel.TextWrapped = true

local toastHolder = Instance.new("Frame")
toastHolder.Name = "ToastHolder"
toastHolder.Size = UDim2.fromOffset(320, 180)
toastHolder.Position = UDim2.new(0.5, -160, 0, 20)
toastHolder.BackgroundTransparency = 1
toastHolder.Parent = screenGui

local toastLayout = Instance.new("UIListLayout")
toastLayout.Padding = UDim.new(0, 8)
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.Parent = toastHolder

local function getToastColor(tone: string?): Color3
	if tone == "warning" then
		return Color3.fromRGB(255, 178, 79)
	elseif tone == "success" then
		return Color3.fromRGB(100, 255, 140)
	end

	return Color3.fromRGB(86, 130, 255)
end

local function showToast(title: string, body: string, tone: string?)
	local color = getToastColor(tone)

	local toast = Instance.new("Frame")
	toast.Size = UDim2.fromOffset(320, 58)
	toast.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
	toast.BackgroundTransparency = 1
	toast.Parent = toastHolder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = toast

	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 2
	stroke.Parent = toast

	local toastTitle = Instance.new("TextLabel")
	toastTitle.Size = UDim2.new(1, -20, 0, 22)
	toastTitle.Position = UDim2.fromOffset(10, 8)
	toastTitle.BackgroundTransparency = 1
	toastTitle.Text = title
	toastTitle.TextColor3 = Color3.new(1, 1, 1)
	toastTitle.TextSize = 17
	toastTitle.Font = Enum.Font.GothamBold
	toastTitle.TextXAlignment = Enum.TextXAlignment.Left
	toastTitle.Parent = toast

	local toastBody = Instance.new("TextLabel")
	toastBody.Size = UDim2.new(1, -20, 0, 18)
	toastBody.Position = UDim2.fromOffset(10, 30)
	toastBody.BackgroundTransparency = 1
	toastBody.Text = body
	toastBody.TextColor3 = Color3.fromRGB(212, 220, 235)
	toastBody.TextSize = 14
	toastBody.Font = Enum.Font.Gotham
	toastBody.TextXAlignment = Enum.TextXAlignment.Left
	toastBody.Parent = toast

	TweenService:Create(toast, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.04,
	}):Play()

	task.delay(3, function()
		if not toast.Parent then
			return
		end

		local fadeOut = TweenService:Create(toast, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
		})
		fadeOut:Play()
		fadeOut.Completed:Wait()
		toast:Destroy()
	end)
end

local function updateUi(state)
	state = state or {}
	titleLabel.Text = state.gameName or "Break-In Tycoon"
	stageLabel.Text = state.gameStage or "Week 1 Foundation"
	walletLabel.Text = string.format("Wallet: $%d", state.walletCash or 0)
	stashLabel.Text = string.format("Stash: $%d", state.stashCash or 0)
	vaultLabel.Text = string.format("Vault: $%d", state.vaultCash or 0)
	tycoonLabel.Text = string.format("Tycoon: %s", state.tycoonId or "Unclaimed")
	statusLabel.Text = state.statusText or "Walk to a green claim pad to claim a tycoon."
end

stateRemote.OnClientEvent:Connect(updateUi)
messageRemote.OnClientEvent:Connect(function(payload)
	payload = payload or {}
	showToast(payload.title or "Update", payload.body or "", payload.tone)
end)

task.defer(function()
	local success, initialState = pcall(function()
		return requestStateFunction:InvokeServer()
	end)

	if success and initialState then
		updateUi(initialState)
	end
end)
