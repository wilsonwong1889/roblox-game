local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local stateRemote = remotesFolder:WaitForChild("StateUpdate") :: RemoteEvent
local messageRemote = remotesFolder:WaitForChild("UiMessage") :: RemoteEvent
local requestStateFunction = remotesFolder:WaitForChild("RequestState") :: RemoteFunction
local sprintRemote = remotesFolder:WaitForChild("SprintStateChanged") :: RemoteEvent

for _, hudName in { "Week4HUD", "Week3HUD", "Week2HUD" } do
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

local function formatRate(amount: number?): string
	return string.format("$%.1f / sec", amount or 0)
end

local function roundCount(value: number?): number
	return math.floor((value or 0) + 0.5)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Week4HUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 50
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromOffset(488, 360)
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
topBar.Size = UDim2.new(1, -24, 0, 54)
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
local stageLabel = makeLabel(topBar, "StageLabel", UDim2.new(1, -20, 0, 18), UDim2.fromOffset(12, 28), "First Floor Expansion", 14, Color3.fromRGB(130, 203, 255), Enum.Font.GothamSemibold)

local statsWrap = Instance.new("Frame")
statsWrap.Name = "StatsWrap"
statsWrap.Size = UDim2.new(1, -24, 0, 164)
statsWrap.Position = UDim2.fromOffset(12, 78)
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
	card.Size = UDim2.new(1, 0, 0, 36)
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
local collectorLabel = makeStatCard(leftColumn, "CollectorLabel", 46, Color3.fromRGB(255, 217, 117), "Collector", "$0")
local earnedLabel = makeStatCard(rightColumn, "EarnedLabel", 0, Color3.fromRGB(205, 219, 255), "Total Earned", "$0")
local epsLabel = makeStatCard(rightColumn, "EpsLabel", 46, Color3.fromRGB(255, 178, 79), "Earnings / Sec", "$0.0")
local clickerLabel = makeStatCard(leftColumn, "ClickerLabel", 92, Color3.fromRGB(168, 139, 255), "Clicker / Tap", "$0")
local unlockLabel = makeStatCard(rightColumn, "UnlockLabel", 92, Color3.fromRGB(130, 203, 255), "Unlock State", "Locked")

local bottomWrap = Instance.new("Frame")
bottomWrap.Name = "BottomWrap"
bottomWrap.Size = UDim2.new(1, -24, 0, 100)
bottomWrap.Position = UDim2.fromOffset(12, 252)
bottomWrap.BackgroundTransparency = 1
bottomWrap.Parent = root

local leftBottom = Instance.new("Frame")
leftBottom.Name = "LeftBottom"
leftBottom.Size = UDim2.new(0.52, -4, 1, 0)
leftBottom.BackgroundTransparency = 1
leftBottom.Parent = bottomWrap

local rightBottom = Instance.new("Frame")
rightBottom.Name = "RightBottom"
rightBottom.Size = UDim2.new(0.48, -4, 1, 0)
rightBottom.Position = UDim2.new(0.52, 4, 0, 0)
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
	local detailLabel = makeLabel(panel, name .. "Detail", UDim2.new(1, -18, 0, 22), UDim2.fromOffset(10, 52), detail, 13, Color3.fromRGB(191, 199, 214), Enum.Font.Gotham)
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
	"Your owner status and unlock path appear here."
)

local toastHolder = Instance.new("Frame")
toastHolder.Name = "ToastHolder"
toastHolder.Size = UDim2.fromOffset(372, 180)
toastHolder.Position = UDim2.new(0.5, -186, 0, 18)
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
	toast.Size = UDim2.fromOffset(372, 58)
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

local isSprinting = false
local function setSprintState(shouldSprint: boolean)
	if isSprinting == shouldSprint then
		return
	end

	isSprinting = shouldSprint
	sprintRemote:FireServer(shouldSprint)
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then
		return
	end

	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		setSprintState(true)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		setSprintState(false)
	end
end)

player.CharacterAdded:Connect(function()
	task.defer(function()
		sprintRemote:FireServer(isSprinting)
	end)
end)

local function getProgressText(state)
	local purchased = state.purchasedUpgrades or {}
	local collectorStored = state.collectorStored or state.collectorStoredCash or 0

	if not state.tycoonId then
		return "Claim your tycoon", "Spawn in the lobby, then claim the tycoon you want."
	end

	if purchased.clicker then
		return "Use the starter clicker", "Tap or click to create the first cash flow before buying droppers."
	end

	if not purchased.basic_dropper then
		return "Buy the first dropper", "The first automated lane costs $100 and starts the baseline factory loop."
	end

	if not purchased.second_dropper then
		return "Unlock the second lane", "Use the next dropper to automate the second stream and raise EPS."
	end

	if not purchased.dropper_3 then
		return "Push toward 8 droppers", "Keep buying the first-floor droppers to unlock the auto collector."
	end

	if not purchased.auto_collector then
		if collectorStored > 0 then
			return "Collect the pad", "Cash is sitting on the collector until you cash it out."
		end

		return "Unlock auto collector", "Buy all 8 droppers to enable direct wallet cash flow."
	end

	if not purchased.premium_conveyor then
		return "Upgrade the conveyor", "Premium Conveyor pushes money through the lane even faster."
	end

	if not purchased.cash_compressor then
		return "Install the compressor", "Cash Compressor increases each money block before payout."
	end

	if not purchased.collector_array then
		return "Build the collector array", "Add the side collector boosters for a stronger utility lane."
	end

	if not purchased.wall_set_1 then
		return "Secure the perimeter", "Buy Wall Set 1 to start wrapping the larger first floor."
	end

	if not purchased.front_door_button then
		return "Add the door button", "Buy the owner door control so you can open and close the entry."
	end

	if not purchased.reinforced_door then
		return "Reinforce the door", "Upgrade the owner door after the wall set is in place."
	end

	if not purchased.high_walls then
		return "Raise the walls", "High Walls give the larger floor a full shell."
	end

	if not purchased.security_lights then
		return "Wire security lights", "Add perimeter lights to make the shell read more clearly."
	end

	if not purchased.corner_posts then
		return "Finish the corners", "Corner Posts lock in the first-floor outline."
	end

	if not purchased.rear_extension then
		return "Push the rear outward", "Rear Extension expands the collector side deeper into the back end."
	end

	if not purchased.utility_bay then
		return "Build the utility bay", "Utility Bay adds a larger service wing on the right side."
	end

	if not purchased.roof_frame then
		return "Raise the roof frame", "Roof Frame spans the upgraded first floor with steel supports."
	end

	return "Expanded first floor online", "The upgraded first-floor loop and shell package are running."
end

local function updateUi(state)
	state = state or {}

	local purchased = state.purchasedUpgrades or {}
	local walletCash = state.walletCash or 0
	local collectorStored = state.collectorStored or state.collectorStoredCash or 0
	local totalEarned = state.totalEarned or 0
	local earningsPerSecond = state.earningsPerSecond or 0
	local earningsPerSecondText = state.earningsPerSecondText or formatRate(earningsPerSecond)

	titleLabel.Text = state.gameName or "Break-In Tycoon"
	stageLabel.Text = state.gameStage or "First Floor Expansion"
	walletLabel.Text = string.format("Wallet: %s", formatCash(walletCash))
	collectorLabel.Text = string.format("Collector: %s", formatCash(collectorStored))
	earnedLabel.Text = string.format("Total Earned: %s", formatCash(totalEarned))
	epsLabel.Text = string.format("Earnings / Sec: %s", earningsPerSecondText)

	local clickerCash = state.clickerCashPerTap or state.clickerCashPerClick or state.clickerIncome or state.clickerValue or state.startingClickerValue or 0
	clickerLabel.Text = string.format("Clicker / Tap: %s", formatCash(clickerCash))

	local unlockedText = "Locked"
	if purchased.roof_frame then
		unlockedText = "Roof frame online"
	elseif purchased.utility_bay then
		unlockedText = "Utility bay online"
	elseif purchased.rear_extension then
		unlockedText = "Rear extension online"
	elseif purchased.collector_array then
		unlockedText = "Collector array online"
	elseif purchased.corner_posts then
		unlockedText = "First-floor shell complete"
	elseif purchased.security_lights then
		unlockedText = "Security lights online"
	elseif purchased.cash_compressor then
		unlockedText = "Compressor online"
	elseif purchased.premium_conveyor then
		unlockedText = "Premium conveyor online"
	elseif purchased.auto_collector then
		unlockedText = "Auto collector online"
	elseif purchased.dropper_8 or purchased.autoCollectorUnlocked then
		unlockedText = "Auto collector unlock ready"
	elseif purchased.basic_dropper then
		unlockedText = "Droppers online"
	end
	unlockLabel.Text = string.format("Unlock State: %s", unlockedText)

	tycoonValueLabel.Text = state.tycoonId or "Unclaimed"
	local progress, hint = getProgressText(state)
	progressValueLabel.Text = progress
	progressDetailLabel.Text = state.statusText or hint
	tycoonDetailLabel.Text = state.tycoonId and string.format("Owner: %s", state.ownerName or "You") or "Walk to a claim pad to take ownership."
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
