-- Zerath Teleportation Library - For Autofarm Developers
-- Developed with ❤️ for performance, stability, and modularity.

local ZerathTPGen = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

local currentTween, currentBodyMover, cancelFlag = nil, nil, false

-- Utility
local function safe(func)
	local ok, err = pcall(func)
	if not ok then warn("[ZerathTPGen]", err) end
end

local function applyCinematicMode(state)
	safe(function()
		for _, v in pairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.LocalTransparencyModifier = state and 1 or 0
			end
		end
	end)
end

local function anchorRoot(state)
	safe(function()
		Root.Anchored = state
	end)
end

local function moveTo(method, destination, delayTime, tweenStyle)
	cancelFlag = false
	if method == "CFrame" then
		anchorRoot(true)
		Root.CFrame = CFrame.new(destination)
		wait(delayTime or 0)
		anchorRoot(false)

	elseif method == "PivotTo" then
		anchorRoot(true)
		Character:PivotTo(CFrame.new(destination))
		wait(delayTime or 0)
		anchorRoot(false)

	elseif method == "Tween" then
		anchorRoot(true)
		local tween = TweenService:Create(Root, TweenInfo.new(delayTime or 1, Enum.EasingStyle[tweenStyle or "Linear"]), {CFrame = CFrame.new(destination)})
		currentTween = tween
		tween:Play()
		tween.Completed:Wait()
		anchorRoot(false)

	elseif method == "BodyPosition" then
		local mover = Instance.new("BodyPosition")
		mover.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		mover.Position = destination
		mover.Parent = Root
		currentBodyMover = mover
		wait(delayTime or 1)
		mover:Destroy()

	elseif method == "AlignPosition" then
		local align = Instance.new("AlignPosition")
		local attachment1 = Instance.new("Attachment", Root)
		local fakePart = Instance.new("Part")
		fakePart.Size = Vector3.new(1,1,1)
		fakePart.Anchored = true
		fakePart.CanCollide = false
		fakePart.Transparency = 1
		fakePart.Position = destination
		fakePart.Parent = workspace
		local attachment2 = Instance.new("Attachment", fakePart)
		align.Attachment0 = attachment1
		align.Attachment1 = attachment2
		align.RigidityEnabled = true
		align.MaxForce = 9999999
		align.Responsiveness = 200
		align.Parent = Root
		currentBodyMover = align
		wait(delayTime or 1.5)
		align:Destroy()
		fakePart:Destroy()
		attachment1:Destroy()
	end
end

local function getOffsetPosition(position, offsetY)
	return Vector3.new(position.X, position.Y + offsetY, position.Z)
end

-- Public API
function ZerathTPGen:Teleport(config)
	safe(function()
		local method = config.Teleport_Method
		local teleportType = config.Teleport_Type or "Normal"
		local coordinates = config.Coordinates
		local delayTime = config.Teleport_Delay or 1
		local yOffset = config.Teleport_Type_Y or -50
		local cinematic = config.CinematicMode or false

		if not (method and coordinates) then
			warn("[ZerathTPGen] Missing method or coordinates!")
			return
		end

		if cinematic then applyCinematicMode(true) end

		if teleportType == "Underground" then
			anchorRoot(true)
			moveTo("CFrame", getOffsetPosition(Root.Position, yOffset), 0.1)
			moveTo(method, getOffsetPosition(coordinates, yOffset), delayTime, config.Tween_Style)
			moveTo("CFrame", coordinates, 0.1)
			anchorRoot(false)

		elseif teleportType == "Air" then
			anchorRoot(true)
			moveTo("CFrame", getOffsetPosition(Root.Position, math.abs(yOffset)), 0.1)
			moveTo(method, getOffsetPosition(coordinates, math.abs(yOffset)), delayTime, config.Tween_Style)
			moveTo("CFrame", coordinates, 0.1)
			anchorRoot(false)

		else
			moveTo(method, coordinates, delayTime, config.Tween_Style)
		end

		if cinematic then applyCinematicMode(false) end
	end)
end

function ZerathTPGen:CancelCurrentTP()
	cancelFlag = true
	if currentTween then currentTween:Cancel() end
	if currentBodyMover then currentBodyMover:Destroy() end
	anchorRoot(false)
	applyCinematicMode(false)
	warn("[ZerathTPGen] Teleport cancelled.")
end

return ZerathTPGen
