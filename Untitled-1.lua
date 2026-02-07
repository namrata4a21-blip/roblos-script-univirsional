--====================================================
-- SERVICES
--====================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--====================================================
-- SETTINGS / STATES
--====================================================
local Settings = {
	FollowSpeed = 1,
	Theme = "Dark",
	ESPEnabled = true
}

local FollowEnabled = false
local FollowTarget = nil
local ViewEnabled = false
local ViewTarget = nil
local OrbitEnabled = false
local OrbitAngle = 0

--====================================================
-- GUI ROOT
--====================================================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AdminPanel"
gui.ResetOnSpawn = false

--====================================================
-- BLUR
--====================================================
local Blur = Instance.new("BlurEffect", Lighting)
Blur.Size = 0

--====================================================
-- DRAG
--====================================================
local function MakeDraggable(frame, handle)
	handle = handle or frame
	local dragging, dragInput, startPos, startFramePos

	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startPos = i.Position
			startFramePos = frame.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)

	handle.InputChanged:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			dragInput = i
		end
	end)

	RunService.RenderStepped:Connect(function()
		if dragging and dragInput then
			local delta = dragInput.Position - startPos
			frame.Position = UDim2.new(
				startFramePos.X.Scale,
				startFramePos.X.Offset + delta.X,
				startFramePos.Y.Scale,
				startFramePos.Y.Offset + delta.Y
			)
		end
	end)
end

--====================================================
-- THEMES
--====================================================
local Themes = {
	Dark = {
		Panel = Color3.fromRGB(20,20,20),
		Button = Color3.fromRGB(60,60,60),
		Text = Color3.new(1,1,1)
	},
	Light = {
		Panel = Color3.fromRGB(230,230,230),
		Button = Color3.fromRGB(200,200,200),
		Text = Color3.fromRGB(20,20,20)
	},
	Neon = {
		Panel = Color3.fromRGB(10,10,10),
		Button = Color3.fromRGB(0,255,180),
		Text = Color3.fromRGB(0,255,180)
	}
}

--====================================================
-- MAIN PANEL
--====================================================
local panel = Instance.new("Frame", gui)
panel.Size = UDim2.fromScale(0.34,0.62)
panel.Position = UDim2.fromScale(0.05,0.2)
panel.BackgroundTransparency = 0.1
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,22)

local header = Instance.new("TextLabel", panel)
header.Size = UDim2.fromScale(1,0.1)
header.BackgroundTransparency = 1
header.Text = "ADMIN PANEL"
header.Font = Enum.Font.GothamBlack
header.TextScaled = true

MakeDraggable(panel, header)

--====================================================
-- THEME BUTTONS
--====================================================
local themeBar = Instance.new("Frame", panel)
themeBar.Position = UDim2.fromScale(0,0.1)
themeBar.Size = UDim2.fromScale(1,0.08)
themeBar.BackgroundTransparency = 1

local function ThemeButton(name, pos)
	local b = Instance.new("TextButton", themeBar)
	b.Position = pos
	b.Size = UDim2.fromScale(0.3,1)
	b.Text = name
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)

	b.MouseButton1Click:Connect(function()
		Settings.Theme = name
		local t = Themes[name]
		TweenService:Create(panel, TweenInfo.new(0.25), {BackgroundColor3 = t.Panel}):Play()
		header.TextColor3 = t.Text
	end)
	return b
end

ThemeButton("Dark", UDim2.fromScale(0.02,0))
ThemeButton("Light", UDim2.fromScale(0.35,0))
ThemeButton("Neon", UDim2.fromScale(0.68,0))

--====================================================
-- PLAYER LIST
--====================================================
local list = Instance.new("ScrollingFrame", panel)
list.Position = UDim2.fromScale(0,0.18)
list.Size = UDim2.fromScale(1,0.82)
list.ScrollBarImageTransparency = 1

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,10)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)

--====================================================
-- ESP SYSTEM
--====================================================
local ESPFolder = Instance.new("Folder", gui)

local function CreateESP(plr)
	if plr == LP then return end

	local bb = Instance.new("BillboardGui", ESPFolder)
	bb.Size = UDim2.fromOffset(200,250)
	bb.AlwaysOnTop = true

	local box = Instance.new("Frame", bb)
	box.Size = UDim2.fromScale(1,1)
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 2

	local name = Instance.new("TextLabel", box)
	name.Size = UDim2.fromScale(1,0.18)
	name.BackgroundTransparency = 1
	name.Font = Enum.Font.GothamBold
	name.TextScaled = true
	name.TextStrokeTransparency = 0.3

	RunService.RenderStepped:Connect(function()
		if Settings.ESPEnabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			bb.Adornee = plr.Character.HumanoidRootPart
			name.Text = plr.Name
			name.TextColor3 = plr.TeamColor.Color
			box.BorderColor3 = plr.TeamColor.Color
		else
			bb.Adornee = nil
		end
	end)
end

--====================================================
-- MINIMAP ESP
--====================================================
local minimap = Instance.new("Frame", gui)
minimap.Size = UDim2.fromScale(0.18,0.25)
minimap.Position = UDim2.fromScale(0.78,0.05)
minimap.BackgroundTransparency = 0.2
Instance.new("UICorner", minimap).CornerRadius = UDim.new(0,18)
MakeDraggable(minimap)

--====================================================
-- PLAYER BUTTON
--====================================================
local function AddPlayer(plr)
	if plr == LP then return end
	CreateESP(plr)

	local frame = Instance.new("Frame", list)
	frame.Size = UDim2.fromScale(1,0.14)
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)

	local name = Instance.new("TextLabel", frame)
	name.Size = UDim2.fromScale(0.45,1)
	name.BackgroundTransparency = 1
	name.Text = plr.Name
	name.TextScaled = true
	name.Font = Enum.Font.GothamBold
	name.TextColor3 = plr.TeamColor.Color

	local function Btn(txt, pos)
		local b = Instance.new("TextButton", frame)
		b.Position = pos
		b.Size = UDim2.fromScale(0.16,0.4)
		b.Text = txt
		b.TextScaled = true
		b.Font = Enum.Font.GothamBold
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
		return b
	end

	local tp = Btn("TP", UDim2.fromScale(0.48,0.1))
	local follow = Btn("Follow", UDim2.fromScale(0.66,0.1))
	local view = Btn("View", UDim2.fromScale(0.84,0.1))

	tp.MouseButton1Click:Connect(function()
		if LP.Character and plr.Character then
			LP.Character:MoveTo(plr.Character.HumanoidRootPart.Position - Vector3.new(0,0,3))
		end
	end)

	follow.MouseButton1Click:Connect(function()
		if FollowTarget == plr then
			FollowEnabled = false
			FollowTarget = nil
			follow.Text = "Follow"
		else
			FollowEnabled = true
			FollowTarget = plr
			follow.Text = "Stop"
		end
	end)

	view.MouseButton1Click:Connect(function()
		if ViewTarget == plr then
			ViewEnabled = false
			ViewTarget = nil
			view.Text = "View"
			if LP.Character then
				Camera.CameraSubject = LP.Character.Humanoid
			end
		else
			ViewEnabled = true
			ViewTarget = plr
			view.Text = "Back"
			if plr.Character then
				Camera.CameraSubject = plr.Character.Humanoid
			end
		end
	end)
end

--====================================================
-- LOAD PLAYERS
--====================================================
for _,p in ipairs(Players:GetPlayers()) do AddPlayer(p) end
Players.PlayerAdded:Connect(AddPlayer)

--====================================================
-- FOLLOW LOOP
--====================================================
RunService.RenderStepped:Connect(function(dt)
	if FollowEnabled and FollowTarget and LP.Character and FollowTarget.Character then
		local hrp = LP.Character.HumanoidRootPart
		local thrp = FollowTarget.Character.HumanoidRootPart
		if hrp and thrp then
			hrp.CFrame = hrp.CFrame:Lerp(thrp.CFrame * CFrame.new(0,0,3), dt*Settings.FollowSpeed*5)
		end
	end
end)

--====================================================
-- HOTKEY
--====================================================
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.RightShift then
		panel.Visible = not panel.Visible
		Blur.Size = panel.Visible and 18 or 0
	end
end)
