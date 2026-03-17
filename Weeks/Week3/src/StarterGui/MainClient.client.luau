local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local stateRemote = remotesFolder:WaitForChild("StateUpdate") :: RemoteEvent
local messageRemote = remotesFolder:WaitForChild("UiMessage") :: RemoteEvent
local requestStateFunction = remotesFolder:WaitForChild("RequestState") :: RemoteFunction

for _, hudName in { "Week3HUD", "Week2HUD" } do
	local existing = playerGui:FindFirstChild(hudName)
	if existing then
		existing:Destroy()
	end
end

local function makeLabel(parent: Instance, name: string, size: UDim2, position: UDim2, text: string, textSize: number, color: Color3, font: Enum.Font): TextLabel
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
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = parent
	return label
end

local function formatCash(amount: number?): string
	return string.format("$%d", math.floor((amount or 0) + 0.5))
end

local function formatEarnings(amount: number?): string
	return string.format("$%.1f / sec", amount or 0)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Week3HUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 50
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromOffset(440, 324)
root.Position = UDim2.fromOffset(20, 20)
root.BackgroundColor3 = Color3.fromRGB(17, 21, 29)
root.BackgroundTransparency = 0.06
root.Parent = screenGui

local rootCorner = Instance.new("UICorner")
rootCorner.CornerRadius = UDim.new(0, 18)
rootCorner.Parent = root

local rootStroke = Instance.new("UIStroke")
rootStroke.Color = Color3.fromRGB(92, 142, 255)
rootStroke.Thickness = 2
rootStroke.Parent = root

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, -24, 0, 52)
topBar.Position = UDim2.fromOffset(12, 12)
topBar.BackgroundColor3 = Color3.fromRGB(24, 29, 39)
topBar.Parent = root

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 14)
topBarCorner.Parent = topBar

local topBarStroke = Instance.new("UIStroke")
topBarStroke.Color = Color3.fromRGB(45, 58, 84)
topBarStroke.Thickness = 1
topBarStroke.Transparency = 0.15
topBarStroke.Parent = topBar

local titleLabel = makeLabel(topBar, "TitleLabel", UDim2.new(1, -20, 0, 22), UDim2.fromOffset(12, 4), "Break-In Tycoon", 22, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold)
local stageLabel = makeLabel(topBar, "StageLabel", UDim2.new(1, -20, 0, 18), UDim2.fromOffset(12, 26), "Week 3 Structure", 14, Color3.fromRGB(130, 203, 255), Enum.Font.GothamSemibold)

local statsWrap = Instance.new("Frame")
statsWrap.Name = "StatsWrap"
statsWrap.Size = UDim2.new(1, -24, 0, 150)
statsWrap.Position = UDim2.fromOffset(12, 76)
statsWrap.BackgroundTransparency = 1
statsWrap.Parent = root

local leftColumn = Instance.new("Frame")
leftColumn.Name = "LeftColumn"
leftColumn.Size = UDim2.new(0.5, -6, 1, 0)
leftColumn.BackgroundTransparency = 1
leftColumn.Parent = statsWrap

local rightColumn = Instance.new("Frame")
rightColumn.Name = "RightColumn"
rightColumn.Size = UDim2.new(0.5, -6, 1, 0)
rightColumn.Position = UDim2.new(0.5, 6, 0, 0)
rightColumn.BackgroundTransparency = 1
rightColumn.Parent = statsWrap

local function makeStatCard(parent: Instance, name: string, yOffset: number, accent: Color3, title: string, value: string): TextLabel
	local card = Instance.new("Frame")
	card.Name = name .. "Card"
	card.Size = UDim2.new(1, 0, 0, 34)
	card.Position = UDim2.fromOffset(0, yOffset)
	card.BackgroundColor3 = Color3.fromRGB(24, 29, 39)
	card.Parent = parent

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 12)
	cardCorner.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = accent
	cardStroke.Thickness = 1
	cardStroke.Transparency = 0.1
	cardStroke.Parent = card

	return makeLabel(card, name, UDim2.new(1, -18, 1, 0), UDim2.fromOffset(10, 0), string.format("%s: %s", title, value), 16, Color3.fromRGB(235, 239, 248), Enum.Font.GothamSemibold)
end

local walletLabel = makeStatCard(leftColumn, "WalletLabel", 0, Color3.fromRGB(105, 255, 140), "Wallet", "$0")
local collectorLabel = makeStatCard(leftColumn, "CollectorLabel", 42, Color3.fromRGB(255, 217, 117), "Collector", "$0")
local earnedLabel = makeStatCard(rightColumn, "EarnedLabel", 0, Color3.fromRGB(205, 219, 255), "Total Earned", "$0")
local epsLabel = makeStatCard(rightColumn, "EpsLabel", 42, Color3.fromRGB(255, 178, 79), "Earnings / Sec", "$0")

local bottomWrap = Instance.new("Frame")
bottomWrap.Name = "BottomWrap"
bottomWrap.Size = UDim2.new(1, -24, 0, 90)
bottomWrap.Position = UDim2.fromOffset(12, 232)
bottomWrap.BackgroundTransparency = 1
bottomWrap.Parent = root

local leftBottom = Instance.new("Frame")
leftBottom.Name = "LeftBottom"
leftBottom.Size = UDim2.new(0.54, -4, 1, 0)
leftBottom.BackgroundTransparency = 1
leftBottom.Parent = bottomWrap

local rightBottom = Instance.new("Frame")
rightBottom.Name = "RightBottom"
rightBottom.Size = UDim2.new(0.46, -4, 1, 0)
rightBottom.Position = UDim2.new(0.54, 4, 0, 0)
rightBottom.BackgroundTransparency = 1
rightBottom.Parent = bottomWrap

local function makeInfoPanel(parent: Instance, name: string, accent: Color3, heading: string, value: string, detail: string)
	local panel = Instance.new("Frame")
	panel.Name = name
	panel.Size = UDim2.new(1, 0, 1, 0)
	panel.BackgroundColor3 = Color3.fromRGB(24, 29, 39)
	panel.Parent = parent

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 12)
	panelCorner.Parent = panel

	local panelStroke = Instance.new("UIStroke")
	panelStroke.Color = accent
	panelStroke.Thickness = 1
	panelStroke.Transparency = 0.1
	panelStroke.Parent = panel

	local headingLabel = makeLabel(panel, name .. "Heading", UDim2.new(1, -18, 0, 16), UDim2.fromOffset(10, 8), heading, 13, Color3.fromRGB(165, 173, 190), Enum.Font.GothamSemibold)
	local valueLabel = makeLabel(panel, name .. "Value", UDim2.new(1, -18, 0, 24), UDim2.fromOffset(10, 26), value, 20, Color3.fromRGB(244, 247, 252), Enum.Font.GothamBold)
	local detailLabel = makeLabel(panel, name .. "Detail", UDim2.new(1, -18, 0, 18), UDim2.fromOffset(10, 52), detail, 13, Color3.fromRGB(191, 199, 214), Enum.Font.Gotham)
	detailLabel.TextWrapped = true
	return valueLabel, detailLabel
end

local progressValueLabel, progressDetailLabel = makeInfoPanel(
	leftBottom,
	"ProgressPanel",
	Color3.fromRGB(130, 203, 255),
	"Current Goal",
	"Claim your tycoon",
	"Walk to Tycoon A or Tycoon B and claim the base you want."
)

local tycoonValueLabel, tycoonDetailLabel = makeInfoPanel(
	rightBottom,
	"TycoonPanel",
	Color3.fromRGB(92, 142, 255),
	"Tycoon",
	"Unclaimed",
	"Your owner status and base label appear here."
)

local toastHolder = Instance.new("Frame")
toastHolder.Name = "ToastHolder"
toastHolder.Size = UDim2.fromOffset(360, 180)
toastHolder.Position = UDim2.new(0.5, -180, 0, 18)
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
	elseif tone == "danger" then
		return Color3.fromRGB(255, 112, 112)
	end

	return Color3.fromRGB(92, 142, 255)
end

local function showToast(title: string, body: string, tone: string?)
	local color = getToastColor(tone)

	local toast = Instance.new("Frame")
	toast.Size = UDim2.fromOffset(360, 58)
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

	local toastTitle = makeLabel(toast, "ToastTitle", UDim2.new(1, -18, 0, 22), UDim2.fromOffset(10, 8), title, 17, Color3.new(1, 1, 1), Enum.Font.GothamBold)
	local toastBody = makeLabel(toast, "ToastBody", UDim2.new(1, -18, 0, 18), UDim2.fromOffset(10, 30), body, 14, Color3.fromRGB(212, 220, 235), Enum.Font.Gotham)
	toastTitle.TextXAlignment = Enum.TextXAlignment.Left
	toastBody.TextXAlignment = Enum.TextXAlignment.Left

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

local function getProgressText(state)
	local purchased = state.purchasedUpgrades or {}
	local collectorStored = state.collectorStored or 0

	if not state.tycoonId then
		return "Claim your tycoon", "Walk to Tycoon A or Tycoon B, then claim the base you want."
	end

	if not purchased.basic_dropper then
		return "Buy the first dropper", "Start the economy loop by buying the Basic Dropper button."
	end

	if collectorStored > 0 then
		return "Collect the pad", "Money is waiting on your collector pad. Claim it to move cash into your wallet."
	end

	if not purchased.collector then
		return "Upgrade the collector", "Buy the Collector upgrade to boost the payout when you cash out."
	end

	if not purchased.conveyor_speed then
		return "Speed up the belt", "Buy the Conveyor Upgrade to move money faster through the lane."
	end

	if not purchased.second_dropper then
		return "Scale the lane", "Buy the second dropper to make the conveyor busier and income faster."
	end

	if not purchased.wall_set_1 then
		return "Secure the base", "Buy Wall Set 1 to start giving your tycoon a proper perimeter."
	end

	if not purchased.front_door then
		return "Add owner entry", "Buy the Front Door so only the owner can use the main entrance."
	end

	if not purchased.reinforced_door then
		return "Reinforce the door", "Upgrade to Reinforced Door for a stronger front gate."
	end

	if not purchased.high_walls then
		return "Raise the perimeter", "Buy High Walls to complete the Week 3 structure pass."
	end

	return "Base upgraded", "Your Week 3 factory and perimeter are active. Keep collecting and building."
end

local function updateUi(state)
	state = state or {}

	titleLabel.Text = state.gameName or "Break-In Tycoon"
	stageLabel.Text = state.gameStage or "Week 3 Structure"
	walletLabel.Text = string.format("Wallet: %s", formatCash(state.walletCash))
	collectorLabel.Text = string.format("Collector: %s", formatCash(state.collectorStored or state.collectorStoredCash))
	earnedLabel.Text = string.format("Total Earned: %s", formatCash(state.totalEarned))
	epsLabel.Text = string.format("Earnings / Sec: %s", state.earningsPerSecondText or formatEarnings(state.earningsPerSecond))
	tycoonValueLabel.Text = state.tycoonId or "Unclaimed"

	local progress, hint = getProgressText(state)
	progressValueLabel.Text = progress
	progressDetailLabel.Text = state.tycoonId and (state.statusText or hint) or hint
	tycoonDetailLabel.Text = state.tycoonId and "Owner: You" or "Walk to a claim pad to take ownership."
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
