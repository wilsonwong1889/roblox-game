local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local stateRemote = remotesFolder:WaitForChild("StateUpdate") :: RemoteEvent
local messageRemote = remotesFolder:WaitForChild("UiMessage") :: RemoteEvent
local requestStateFunction = remotesFolder:WaitForChild("RequestState") :: RemoteFunction
local requestDailySpinFunction = remotesFolder:WaitForChild("RequestDailySpin") :: RemoteFunction
local requestCodeRedeemFunction = remotesFolder:WaitForChild("RequestCodeRedeem") :: RemoteFunction
local sprintRemote = remotesFolder:WaitForChild("SprintStateChanged") :: RemoteEvent

for _, hudName in { "Week6HUD", "Week5HUD", "Week4HUD", "Week3HUD", "Week2HUD" } do
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

local function formatChance(amount: number?): string
	return string.format("%d%% chance", math.floor((amount or 0) + 0.5))
end

local function roundCount(value: number?): number
	return math.floor((value or 0) + 0.5)
end

local function makeButton(parent: Instance, name: string, size: UDim2, position: UDim2, text: string, backgroundColor: Color3, textColor: Color3): TextButton
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = size
	button.Position = position
	button.Text = text
	button.TextSize = 16
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = textColor
	button.BackgroundColor3 = backgroundColor
	button.AutoButtonColor = false
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = backgroundColor:Lerp(Color3.new(1, 1, 1), 0.28)
	stroke.Thickness = 1
	stroke.Transparency = 0.15
	stroke.Parent = button

	return button
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Week6HUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 50
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromOffset(488, 410)
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

local menuButton = makeButton(topBar, "MenuButton", UDim2.fromOffset(84, 30), UDim2.new(1, -96, 0, 12), "Menu", Color3.fromRGB(48, 61, 86), Color3.fromRGB(255, 255, 255))

local titleLabel = makeLabel(topBar, "TitleLabel", UDim2.new(1, -20, 0, 22), UDim2.fromOffset(12, 4), "Break-In Tycoon", 22, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold)
local stageLabel = makeLabel(topBar, "StageLabel", UDim2.new(1, -20, 0, 18), UDim2.fromOffset(12, 28), "Ring Layout Server", 14, Color3.fromRGB(130, 203, 255), Enum.Font.GothamSemibold)
local serverSummaryLabel = makeLabel(topBar, "ServerSummaryLabel", UDim2.fromOffset(232, 18), UDim2.new(1, -244, 0, 18), "Owners 0/0 | Open plots 0", 13, Color3.fromRGB(191, 199, 214), Enum.Font.GothamSemibold)
serverSummaryLabel.TextXAlignment = Enum.TextXAlignment.Right
serverSummaryLabel.Size = UDim2.fromOffset(144, 18)
serverSummaryLabel.Position = UDim2.new(1, -250, 0, 18)

local statsWrap = Instance.new("Frame")
statsWrap.Name = "StatsWrap"
statsWrap.Size = UDim2.new(1, -24, 0, 210)
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
local clickerLabel = makeStatCard(leftColumn, "ClickerLabel", 92, Color3.fromRGB(168, 139, 255), "Starter Drop", "$0")
local unlockLabel = makeStatCard(rightColumn, "UnlockLabel", 92, Color3.fromRGB(130, 203, 255), "Unlock State", "Locked")
local killsLabel = makeStatCard(rightColumn, "KillsLabel", 138, Color3.fromRGB(255, 112, 112), "Kills", "0")

local bottomWrap = Instance.new("Frame")
bottomWrap.Name = "BottomWrap"
bottomWrap.Size = UDim2.new(1, -24, 0, 100)
bottomWrap.Position = UDim2.fromOffset(12, 298)
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
	"Walk to any open claim pad and take the tycoon you want."
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

local codePanel = Instance.new("Frame")
codePanel.Name = "CodePanel"
codePanel.Size = UDim2.fromOffset(286, 116)
codePanel.AnchorPoint = Vector2.new(1, 1)
codePanel.Position = UDim2.new(1, -22, 1, -22)
codePanel.BackgroundColor3 = Color3.fromRGB(18, 23, 31)
codePanel.BackgroundTransparency = 0.05
codePanel.ZIndex = 18
codePanel.Parent = screenGui

local codePanelCorner = Instance.new("UICorner")
codePanelCorner.CornerRadius = UDim.new(0, 16)
codePanelCorner.Parent = codePanel

local codePanelStroke = Instance.new("UIStroke")
codePanelStroke.Color = Color3.fromRGB(118, 176, 255)
codePanelStroke.Thickness = 1
codePanelStroke.Transparency = 0.08
codePanelStroke.Parent = codePanel

local codeTitleLabel = makeLabel(codePanel, "CodeTitleLabel", UDim2.new(1, -20, 0, 22), UDim2.fromOffset(10, 8), "Redeem Code", 18, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold)
codeTitleLabel.ZIndex = 19

local codeHintLabel = makeLabel(codePanel, "CodeHintLabel", UDim2.new(1, -20, 0, 16), UDim2.fromOffset(10, 32), "Try: money or amanda", 12, Color3.fromRGB(198, 208, 224), Enum.Font.GothamSemibold)
codeHintLabel.ZIndex = 19

local codeInput = Instance.new("TextBox")
codeInput.Name = "CodeInput"
codeInput.Size = UDim2.new(1, -110, 0, 34)
codeInput.Position = UDim2.fromOffset(10, 56)
codeInput.BackgroundColor3 = Color3.fromRGB(33, 40, 54)
codeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
codeInput.PlaceholderColor3 = Color3.fromRGB(159, 170, 188)
codeInput.PlaceholderText = "Enter code"
codeInput.Text = ""
codeInput.ClearTextOnFocus = false
codeInput.Font = Enum.Font.GothamSemibold
codeInput.TextSize = 15
codeInput.ZIndex = 19
codeInput.Parent = codePanel

local codeInputCorner = Instance.new("UICorner")
codeInputCorner.CornerRadius = UDim.new(0, 12)
codeInputCorner.Parent = codeInput

local codeInputStroke = Instance.new("UIStroke")
codeInputStroke.Color = Color3.fromRGB(80, 93, 118)
codeInputStroke.Thickness = 1
codeInputStroke.Transparency = 0.1
codeInputStroke.Parent = codeInput

local codeRedeemButton = makeButton(codePanel, "CodeRedeemButton", UDim2.fromOffset(84, 34), UDim2.new(1, -94, 0, 56), "Redeem", Color3.fromRGB(98, 245, 182), Color3.fromRGB(19, 36, 30))
codeRedeemButton.ZIndex = 19

local codeStatusLabel = makeLabel(codePanel, "CodeStatusLabel", UDim2.new(1, -20, 0, 18), UDim2.fromOffset(10, 92), "Codes grant wallet cash instantly.", 12, Color3.fromRGB(198, 208, 224), Enum.Font.GothamSemibold)
codeStatusLabel.ZIndex = 19

local startMenuOverlay = Instance.new("Frame")
startMenuOverlay.Name = "StartMenuOverlay"
startMenuOverlay.Size = UDim2.fromScale(1, 1)
startMenuOverlay.BackgroundColor3 = Color3.fromRGB(8, 11, 16)
startMenuOverlay.BackgroundTransparency = 0.22
startMenuOverlay.ZIndex = 20
startMenuOverlay.Parent = screenGui

local startMenuPanel = Instance.new("Frame")
startMenuPanel.Name = "StartMenuPanel"
startMenuPanel.Size = UDim2.fromOffset(640, 480)
startMenuPanel.AnchorPoint = Vector2.new(0.5, 0.5)
startMenuPanel.Position = UDim2.fromScale(0.5, 0.5)
startMenuPanel.BackgroundColor3 = Color3.fromRGB(20, 25, 34)
startMenuPanel.ZIndex = 21
startMenuPanel.Parent = startMenuOverlay

local startMenuCorner = Instance.new("UICorner")
startMenuCorner.CornerRadius = UDim.new(0, 20)
startMenuCorner.Parent = startMenuPanel

local startMenuStroke = Instance.new("UIStroke")
startMenuStroke.Color = Color3.fromRGB(130, 203, 255)
startMenuStroke.Thickness = 2
startMenuStroke.Parent = startMenuPanel

local menuHero = Instance.new("Frame")
menuHero.Name = "Hero"
menuHero.Size = UDim2.new(1, -28, 0, 94)
menuHero.Position = UDim2.fromOffset(14, 14)
menuHero.BackgroundColor3 = Color3.fromRGB(28, 35, 48)
menuHero.ZIndex = 21
menuHero.Parent = startMenuPanel

local menuHeroCorner = Instance.new("UICorner")
menuHeroCorner.CornerRadius = UDim.new(0, 16)
menuHeroCorner.Parent = menuHero

local menuHeroGlow = Instance.new("Frame")
menuHeroGlow.Name = "Glow"
menuHeroGlow.Size = UDim2.new(1, 0, 0, 12)
menuHeroGlow.Position = UDim2.fromOffset(0, 82)
menuHeroGlow.BackgroundColor3 = Color3.fromRGB(142, 210, 190)
menuHeroGlow.BackgroundTransparency = 0.25
menuHeroGlow.ZIndex = 21
menuHeroGlow.Parent = menuHero

local menuTitle = makeLabel(menuHero, "MenuTitle", UDim2.new(1, -24, 0, 34), UDim2.fromOffset(14, 10), "Break-In Tycoon", 28, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold)
menuTitle.ZIndex = 22
local menuSubtitle = makeLabel(menuHero, "MenuSubtitle", UDim2.new(1, -24, 0, 22), UDim2.fromOffset(14, 48), "Build fast, arm your base, and climb three production floors.", 15, Color3.fromRGB(209, 220, 236), Enum.Font.GothamSemibold)
menuSubtitle.ZIndex = 22

local menuTabs = Instance.new("Frame")
menuTabs.Name = "Tabs"
menuTabs.Size = UDim2.new(1, -28, 0, 42)
menuTabs.Position = UDim2.fromOffset(14, 122)
menuTabs.BackgroundTransparency = 1
menuTabs.ZIndex = 21
menuTabs.Parent = startMenuPanel

local startNowButton = makeButton(menuTabs, "StartNowButton", UDim2.fromOffset(152, 40), UDim2.fromOffset(0, 0), "Start Now", Color3.fromRGB(98, 245, 182), Color3.fromRGB(19, 36, 30))
startNowButton.ZIndex = 22
local infoButton = makeButton(menuTabs, "InfoButton", UDim2.fromOffset(152, 40), UDim2.fromOffset(168, 0), "Information", Color3.fromRGB(56, 69, 96), Color3.fromRGB(255, 255, 255))
infoButton.ZIndex = 22
local settingsButton = makeButton(menuTabs, "SettingsButton", UDim2.fromOffset(152, 40), UDim2.fromOffset(336, 0), "Settings", Color3.fromRGB(56, 69, 96), Color3.fromRGB(255, 255, 255))
settingsButton.ZIndex = 22

local menuBody = Instance.new("Frame")
menuBody.Name = "Body"
menuBody.Size = UDim2.new(1, -28, 1, -182)
menuBody.Position = UDim2.fromOffset(14, 174)
menuBody.BackgroundColor3 = Color3.fromRGB(25, 30, 41)
menuBody.ZIndex = 21
menuBody.Parent = startMenuPanel

local menuBodyCorner = Instance.new("UICorner")
menuBodyCorner.CornerRadius = UDim.new(0, 16)
menuBodyCorner.Parent = menuBody

local menuBodyStroke = Instance.new("UIStroke")
menuBodyStroke.Color = Color3.fromRGB(51, 64, 91)
menuBodyStroke.Thickness = 1
menuBodyStroke.Transparency = 0.15
menuBodyStroke.Parent = menuBody

local menuBodyTitle = makeLabel(menuBody, "MenuBodyTitle", UDim2.new(1, -24, 0, 28), UDim2.fromOffset(14, 14), "Start Now", 22, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold)
menuBodyTitle.ZIndex = 22
local menuBodyText = makeLabel(menuBody, "MenuBodyText", UDim2.new(1, -24, 0, 56), UDim2.fromOffset(14, 50), "Claim a tycoon and begin building.", 15, Color3.fromRGB(214, 223, 238), Enum.Font.Gotham)
menuBodyText.TextYAlignment = Enum.TextYAlignment.Top
menuBodyText.TextWrapped = true
menuBodyText.ZIndex = 22

local settingsActionButton = makeButton(menuBody, "SettingsActionButton", UDim2.fromOffset(160, 38), UDim2.new(0, 14, 1, -52), "Music: On", Color3.fromRGB(66, 84, 112), Color3.fromRGB(255, 255, 255))
settingsActionButton.Visible = false
settingsActionButton.ZIndex = 22

local dailySpinFrame = Instance.new("Frame")
dailySpinFrame.Name = "DailySpinFrame"
dailySpinFrame.Size = UDim2.new(1, -28, 0, 178)
dailySpinFrame.Position = UDim2.fromOffset(14, 108)
dailySpinFrame.BackgroundColor3 = Color3.fromRGB(29, 36, 49)
dailySpinFrame.Visible = false
dailySpinFrame.ZIndex = 22
dailySpinFrame.Parent = menuBody

local dailySpinCorner = Instance.new("UICorner")
dailySpinCorner.CornerRadius = UDim.new(0, 14)
dailySpinCorner.Parent = dailySpinFrame

local dailySpinStroke = Instance.new("UIStroke")
dailySpinStroke.Color = Color3.fromRGB(255, 197, 104)
dailySpinStroke.Thickness = 1
dailySpinStroke.Transparency = 0.1
dailySpinStroke.Parent = dailySpinFrame

local dailySpinTitle = makeLabel(dailySpinFrame, "DailySpinTitle", UDim2.new(1, -20, 0, 22), UDim2.fromOffset(10, 8), "Daily Spin", 18, Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold)
dailySpinTitle.ZIndex = 23
local dailySpinSubtitle = makeLabel(dailySpinFrame, "DailySpinSubtitle", UDim2.new(1, -20, 0, 18), UDim2.fromOffset(10, 32), "Spin once for a cash reward.", 13, Color3.fromRGB(218, 225, 238), Enum.Font.GothamSemibold)
dailySpinSubtitle.ZIndex = 23

local dailySpinGrid = Instance.new("Frame")
dailySpinGrid.Name = "DailySpinGrid"
dailySpinGrid.Size = UDim2.fromOffset(372, 112)
dailySpinGrid.Position = UDim2.fromOffset(10, 56)
dailySpinGrid.BackgroundTransparency = 1
dailySpinGrid.ZIndex = 23
dailySpinGrid.Parent = dailySpinFrame

local dailySpinGridLayout = Instance.new("UIGridLayout")
dailySpinGridLayout.CellSize = UDim2.fromOffset(116, 32)
dailySpinGridLayout.CellPadding = UDim2.fromOffset(10, 8)
dailySpinGridLayout.FillDirectionMaxCells = 3
dailySpinGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
dailySpinGridLayout.Parent = dailySpinGrid

local dailySpinSlots = {}
for index = 1, 9 do
	local slot = Instance.new("TextLabel")
	slot.Name = string.format("DailySpinSlot%d", index)
	slot.BackgroundColor3 = Color3.fromRGB(42, 50, 67)
	slot.TextColor3 = Color3.fromRGB(255, 255, 255)
	slot.TextSize = 15
	slot.Font = Enum.Font.GothamBold
	slot.TextWrapped = true
	slot.ZIndex = 23
	slot.Parent = dailySpinGrid

	local slotCorner = Instance.new("UICorner")
	slotCorner.CornerRadius = UDim.new(0, 10)
	slotCorner.Parent = slot

	local slotStroke = Instance.new("UIStroke")
	slotStroke.Name = "SlotStroke"
	slotStroke.Color = Color3.fromRGB(90, 103, 128)
	slotStroke.Thickness = 1
	slotStroke.Transparency = 0.15
	slotStroke.Parent = slot

	dailySpinSlots[index] = slot
end

local dailySpinButton = makeButton(dailySpinFrame, "DailySpinButton", UDim2.fromOffset(182, 38), UDim2.new(1, -194, 0, 64), "Spin Now", Color3.fromRGB(255, 197, 104), Color3.fromRGB(49, 31, 16))
dailySpinButton.ZIndex = 23
local dailySpinStatus = makeLabel(dailySpinFrame, "DailySpinStatus", UDim2.fromOffset(182, 60), UDim2.new(1, -194, 0, 108), "Available now", 14, Color3.fromRGB(231, 238, 248), Enum.Font.GothamSemibold)
dailySpinStatus.TextWrapped = true
dailySpinStatus.TextYAlignment = Enum.TextYAlignment.Top
dailySpinStatus.ZIndex = 23

local latestState = nil
local startMenuOpen = true
local startMenuTab = "start"
local musicMuted = false
local dailySpinBusy = false
local codeRedeemBusy = false

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

local function trimText(value: string): string
	return string.gsub(value, "^%s*(.-)%s*$", "%1")
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

local function getBackgroundMusic()
	local sound = SoundService:FindFirstChild("BackgroundMusic")
	if sound and sound:IsA("Sound") then
		return sound
	end

	return nil
end

local function applyMusicToggle()
	local music = getBackgroundMusic()
	settingsActionButton.Text = if musicMuted then "Music: Off" else "Music: On"
	settingsActionButton.BackgroundColor3 = if musicMuted then Color3.fromRGB(92, 70, 76) else Color3.fromRGB(66, 84, 112)
	if music then
		music.Volume = if musicMuted then 0 else 0.2
	end
end

local function closeStartMenu()
	if not startMenuOpen then
		return
	end

	startMenuOpen = false
	local fade = TweenService:Create(startMenuOverlay, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		BackgroundTransparency = 1,
	})
	local shrink = TweenService:Create(startMenuPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(530, 340),
	})
	fade:Play()
	shrink:Play()
	shrink.Completed:Wait()
	startMenuOverlay.Visible = false
	startMenuOverlay.BackgroundTransparency = 0.22
	startMenuPanel.BackgroundTransparency = 0
	startMenuPanel.Size = UDim2.fromOffset(640, 480)
end

local function openStartMenu()
	if startMenuOpen then
		return
	end

	startMenuOpen = true
	startMenuOverlay.Visible = true
	startMenuOverlay.BackgroundTransparency = 1
	startMenuPanel.BackgroundTransparency = 0.18
	startMenuPanel.Size = UDim2.fromOffset(610, 450)
	TweenService:Create(startMenuOverlay, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.22,
	}):Play()
	TweenService:Create(startMenuPanel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0,
		Size = UDim2.fromOffset(640, 480),
	}):Play()
end

local function updateDailySpinView(state)
	local slots = state and state.dailySpinSlots or nil
	for index, slot in dailySpinSlots do
		local reward = slots and slots[index] or nil
		if reward then
			slot.Text = string.format("%s\n%s", reward.name, formatChance(reward.chancePercent))
			slot.BackgroundColor3 = reward.color:Lerp(Color3.fromRGB(32, 39, 52), 0.7)
			local stroke = slot:FindFirstChild("SlotStroke")
			if stroke and stroke:IsA("UIStroke") then
				stroke.Color = reward.color
			end
		else
			slot.Text = "Locked"
			slot.BackgroundColor3 = Color3.fromRGB(42, 50, 67)
			local stroke = slot:FindFirstChild("SlotStroke")
			if stroke and stroke:IsA("UIStroke") then
				stroke.Color = Color3.fromRGB(90, 103, 128)
			end
		end
	end

	local enabled = state and state.dailySpinEnabled == true
	local claimed = state and state.dailySpinClaimedToday == true
	local lastReward = state and state.dailySpinLastReward or 0
	dailySpinFrame.Visible = startMenuTab == "start" and enabled
	dailySpinButton.Visible = enabled
	dailySpinStatus.Visible = enabled
	if not enabled then
		return
	end

	if dailySpinBusy then
		dailySpinButton.Active = false
		dailySpinButton.AutoButtonColor = false
		dailySpinButton.Text = "Spinning..."
		dailySpinButton.BackgroundColor3 = Color3.fromRGB(162, 167, 176)
		dailySpinStatus.Text = "Rolling your prize..."
	elseif claimed then
		dailySpinButton.Active = false
		dailySpinButton.AutoButtonColor = false
		dailySpinButton.Text = "Claimed Today"
		dailySpinButton.BackgroundColor3 = Color3.fromRGB(86, 104, 128)
		if lastReward > 0 then
			dailySpinStatus.Text = string.format("Already claimed this session.\nLast reward: %s", formatCash(lastReward))
		else
			dailySpinStatus.Text = "Already claimed this session."
		end
	else
		dailySpinButton.Active = true
		dailySpinButton.AutoButtonColor = true
		dailySpinButton.Text = "Spin Now"
		dailySpinButton.BackgroundColor3 = Color3.fromRGB(255, 197, 104)
		dailySpinStatus.Text = "Available now.\nSpin for a weighted cash reward."
	end
end

local function setMenuTab(tabName: string)
	startMenuTab = tabName

	local function styleTab(button: TextButton, isActive: boolean)
		button.BackgroundColor3 = if isActive then Color3.fromRGB(130, 203, 255) else Color3.fromRGB(56, 69, 96)
		button.TextColor3 = if isActive then Color3.fromRGB(16, 24, 33) else Color3.fromRGB(255, 255, 255)
	end

	styleTab(infoButton, tabName == "info")
	styleTab(settingsButton, tabName == "settings")
	styleTab(startNowButton, tabName == "start")
	settingsActionButton.Visible = false
	dailySpinFrame.Visible = false

	local tycoonCapacity = latestState and latestState.competition and latestState.competition.tycoonCapacity or 8
	if tabName == "start" then
		menuBodyTitle.Text = "Start Now"
		menuBodyText.Size = UDim2.new(1, -24, 0, 56)
		menuBodyText.Text = "Spawn in the center, pick any open tycoon, use the starter dropper, and start climbing the factory floors."
		updateDailySpinView(latestState)
	elseif tabName == "info" then
		menuBodyTitle.Text = "Information"
		menuBodyText.Size = UDim2.new(1, -24, 1, -68)
		menuBodyText.Text = string.format(
			"This server supports %d tycoons around the center hub.\n\nControls:\n- Walk to a claim pad to own a tycoon\n- Tap the starter dropper before automation\n- Hold Shift to sprint\n- Use owner door buttons to open your gate\n\nGoal:\nBuild your income, unlock the next floors, arm your base, and keep expanding.",
			tycoonCapacity
		)
	else
		menuBodyTitle.Text = "Settings"
		menuBodyText.Size = UDim2.new(1, -24, 1, -68)
		menuBodyText.Text = "Local settings only.\n\nYou can mute the background music here. More toggles can be added later without affecting server gameplay."
		settingsActionButton.Visible = true
		applyMusicToggle()
	end
end

startNowButton.MouseButton1Click:Connect(function()
	setMenuTab("start")
	closeStartMenu()
end)

infoButton.MouseButton1Click:Connect(function()
	setMenuTab("info")
end)

settingsButton.MouseButton1Click:Connect(function()
	setMenuTab("settings")
end)

menuButton.MouseButton1Click:Connect(function()
	openStartMenu()
end)

settingsActionButton.MouseButton1Click:Connect(function()
	musicMuted = not musicMuted
	applyMusicToggle()
end)

local function updateCodeRedeemUi()
	if codeRedeemBusy then
		codeRedeemButton.Active = false
		codeRedeemButton.AutoButtonColor = false
		codeRedeemButton.Text = "..."
		codeRedeemButton.BackgroundColor3 = Color3.fromRGB(148, 156, 168)
	else
		codeRedeemButton.Active = true
		codeRedeemButton.AutoButtonColor = true
		codeRedeemButton.Text = "Redeem"
		codeRedeemButton.BackgroundColor3 = Color3.fromRGB(98, 245, 182)
	end
end

local function submitRedeemCode()
	local rawCode = trimText(codeInput.Text)
	if rawCode == "" or codeRedeemBusy then
		if rawCode == "" then
			showToast("Redeem Code", "Enter a code first.", "warning")
		end
		return
	end

	codeRedeemBusy = true
	updateCodeRedeemUi()
	local success, result = pcall(function()
		return requestCodeRedeemFunction:InvokeServer(rawCode)
	end)
	codeRedeemBusy = false
	updateCodeRedeemUi()

	if not success then
		codeStatusLabel.Text = "Code redeem failed. Try again."
		showToast("Redeem Code", "Code redeem failed right now.", "warning")
		return
	end

	if result and result.ok == true then
		codeInput.Text = ""
		codeStatusLabel.Text = string.format("Redeemed %s for %s.", result.code or rawCode, formatCash(result.reward))
		return
	end

	if result and result.reason == "already_redeemed" then
		codeStatusLabel.Text = string.format("Code %s already used.", result.code or rawCode)
	elseif result and result.reason == "invalid_code" then
		codeStatusLabel.Text = "That code is invalid."
	else
		codeStatusLabel.Text = "Code redeem unavailable right now."
	end
end

codeRedeemButton.MouseButton1Click:Connect(submitRedeemCode)
codeInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		submitRedeemCode()
	end
end)

dailySpinButton.MouseButton1Click:Connect(function()
	if dailySpinBusy then
		return
	end

	dailySpinBusy = true
	updateDailySpinView(latestState)

	local success, result = pcall(function()
		return requestDailySpinFunction:InvokeServer()
	end)

	dailySpinBusy = false
	if not success then
		showToast("Daily Spin", "The daily spin could not be completed right now.", "warning")
		updateDailySpinView(latestState)
		return
	end

	if not result or result.ok ~= true then
		if result and result.reason == "already_claimed" then
			showToast("Daily Spin", "You already used the daily spin for this session.", "info")
		elseif result and result.reason == "disabled" then
			showToast("Daily Spin", "The daily spin is disabled right now.", "warning")
		else
			showToast("Daily Spin", "The daily spin could not be completed.", "warning")
		end
	end

	updateDailySpinView(latestState)
end)

local function getProgressText(state)
	local purchased = state.purchasedUpgrades or {}
	local collectorStored = state.collectorStored or state.collectorStoredCash or 0

	if not state.tycoonId then
		return "Claim your tycoon", "Spawn in the lobby, then claim any open tycoon."
	end

	if purchased.clicker then
		return "Use the starter dropper", "Tap the starter dropper to send cash blocks onto the conveyor before buying automation."
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

	if not purchased.front_door then
		return "Add the front door", "Buy the front door to unlock the owner door buttons on both sides."
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

	if not purchased.second_floor then
		return "Unlock the second floor", "Buy the upper floor starter to begin the landing and stair chain."
	end

	if not purchased.upper_walls then
		return "Raise upper walls", "Upper Walls lock the second-floor shell onto the back-right wing."
	end

	if not purchased.upper_conveyor then
		return "Run the upper conveyor", "The top lane comes online before the new droppers."
	end

	if not purchased.upper_dropper_1 then
		return "Place upper dropper 1", "Start the upper lane with the first high-floor dropper."
	end

	if not purchased.upper_dropper_2 then
		return "Place upper dropper 2", "Keep the upper conveyor fed with the next tier."
	end

	if not purchased.upper_dropper_3 then
		return "Place upper dropper 3", "The upper lane is still growing toward full output."
	end

	if not purchased.upper_dropper_4 then
		return "Place upper dropper 4", "Finish the upper dropper row before the collector."
	end

	if not purchased.upper_collector then
		return "Install the upper collector", "Cash from the second floor needs its own payout point."
	end

	if not purchased.third_floor then
		return "Unlock the third floor", "Start the next deck by buying the third-floor expansion above the upper floor."
	end

	if not purchased.third_floor_walls then
		return "Wrap the top deck", "Third Floor Walls tighten the shell around the new top-level platform."
	end

	if not purchased.third_conveyor then
		return "Run the third conveyor", "Bring the top-floor production lane online before placing the new droppers."
	end

	if not purchased.third_dropper_1 then
		return "Place third dropper 1", "Start the new top-floor lane with the first third-floor dropper."
	end

	if not purchased.third_dropper_2 then
		return "Place third dropper 2", "Keep the third-floor conveyor fed with more output."
	end

	if not purchased.third_dropper_3 then
		return "Place third dropper 3", "The top deck is still growing toward full output."
	end

	if not purchased.third_dropper_4 then
		return "Place third dropper 4", "Finish the third-floor dropper row before the collector."
	end

	if not purchased.third_collector then
		return "Install the third collector", "The top floor needs its own collector to finish the lane."
	end

	return "Three floors online", "The factory is now running active production across all three floors."
end

local function updateUi(state)
	state = state or {}
	latestState = state

	local purchased = state.purchasedUpgrades or {}
	local walletCash = state.walletCash or 0
	local collectorStored = state.collectorStored or state.collectorStoredCash or 0
	local totalEarned = state.totalEarned or 0
	local kills = state.kills or 0
	local earningsPerSecond = state.earningsPerSecond or 0
	local earningsPerSecondText = state.earningsPerSecondText or formatRate(earningsPerSecond)

	titleLabel.Text = state.gameName or "Break-In Tycoon"
	if state.gameStage then
		stageLabel.Text = state.gameStage
	elseif purchased.third_floor or purchased.third_floor_walls or purchased.third_conveyor or purchased.third_dropper_1 or purchased.third_collector then
		stageLabel.Text = "Third Floor Expansion"
	elseif purchased.second_floor or purchased.upper_walls or purchased.upper_conveyor or purchased.upper_dropper_1 or purchased.upper_collector then
		stageLabel.Text = "Second Floor Wing"
	else
		stageLabel.Text = "Ring Layout Server"
	end
	walletLabel.Text = string.format("Wallet: %s", formatCash(walletCash))
	collectorLabel.Text = string.format("Collector: %s", formatCash(collectorStored))
	earnedLabel.Text = string.format("Total Earned: %s", formatCash(totalEarned))
	epsLabel.Text = string.format("Earnings / Sec: %s", earningsPerSecondText)
	killsLabel.Text = string.format("Kills: %d", roundCount(kills))

	local clickerCash = state.clickerCashPerTap or state.clickerCashPerClick or state.clickerIncome or state.clickerValue or state.startingClickerValue or 0
	clickerLabel.Text = string.format("Starter Drop: %s", formatCash(clickerCash))

	local unlockedText = "Locked"
	if purchased.third_collector then
		unlockedText = "Three floors online"
	elseif purchased.third_dropper_4 then
		unlockedText = "Top-floor droppers online"
	elseif purchased.third_dropper_3 then
		unlockedText = "Top-floor lane online"
	elseif purchased.third_conveyor then
		unlockedText = "Third conveyor online"
	elseif purchased.third_floor_walls then
		unlockedText = "Third-floor shell online"
	elseif purchased.third_floor then
		unlockedText = "Third floor online"
	elseif purchased.upper_collector then
		unlockedText = "Upper collector online"
	elseif purchased.upper_dropper_4 then
		unlockedText = "Upper droppers online"
	elseif purchased.upper_dropper_3 then
		unlockedText = "Upper lane online"
	elseif purchased.second_floor then
		unlockedText = "Second floor online"
	elseif purchased.roof_frame then
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

	local competition = state.competition or {}
	local claimedPlots = roundCount(competition.claimedPlots)
	local availablePlots = roundCount(competition.availablePlots)
	local tycoonCapacity = roundCount(competition.tycoonCapacity)
	local playerCount = roundCount(competition.playerCount)
	if tycoonCapacity > 0 then
		serverSummaryLabel.Text = string.format("Owners %d/%d | Open plots %d | Players %d", claimedPlots, tycoonCapacity, availablePlots, playerCount)
	else
		serverSummaryLabel.Text = string.format("Owners %d | Players %d", claimedPlots, playerCount)
	end

	updateDailySpinView(state)
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

setMenuTab("start")
applyMusicToggle()
updateCodeRedeemUi()
