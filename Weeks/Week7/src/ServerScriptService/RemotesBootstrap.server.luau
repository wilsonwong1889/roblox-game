local ReplicatedStorage = game:GetService("ReplicatedStorage")

local REQUIRED_REMOTES = {
	{ name = "StateUpdate", className = "RemoteEvent" },
	{ name = "UiMessage", className = "RemoteEvent" },
	{ name = "RequestState", className = "RemoteFunction" },
	{ name = "RequestDailySpin", className = "RemoteFunction" },
	{ name = "RequestCodeRedeem", className = "RemoteFunction" },
	{ name = "RequestRebirth", className = "RemoteFunction" },
	{ name = "PromptVipStarterPackPurchase", className = "RemoteEvent" },
	{ name = "SprintStateChanged", className = "RemoteEvent" },
	{ name = "WeaponFire", className = "RemoteEvent" },
}

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if remotesFolder and not remotesFolder:IsA("Folder") then
	remotesFolder:Destroy()
	remotesFolder = nil
end

if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = ReplicatedStorage
end

for _, definition in REQUIRED_REMOTES do
	local existing = remotesFolder:FindFirstChild(definition.name)
	if existing and existing.ClassName ~= definition.className then
		existing:Destroy()
		existing = nil
	end

	if not existing then
		existing = Instance.new(definition.className)
		existing.Name = definition.name
		existing.Parent = remotesFolder
	end
end
