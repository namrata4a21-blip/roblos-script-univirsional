--==================================================
-- SERVICES
--==================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

--==================================================
-- PLAYER
--==================================================
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--==================================================
-- SETTINGS
--==================================================
local Settings = {
	DeveloperName = "by shravan4343",
	CircleSize = 48,
	CircleShape = "Circle", -- Circle / Square
	ESPEnabled = false,
	ESPColor = Color3.fromRGB(255, 80, 80)
}

--==================================================
-- BLUR
--==================================================
local blur = Instance.new("BlurEffect")
blur.Parent = Lighting
blur.Size = 0
blur.Enabled = false

local function blurOn()
	blur.Enabled = true
	TweenService:Create(blur, TweenInfo.new(0.3), {Size = 18}):Play()
end

local function blurOff()
	local t = TweenService:Create(blur, TweenInfo.new(0.3), {Size = 0})
	t:Play()
	t.Completed:Connect(function()
		blur.Enabled = false
	end)
end

--==================================================
-- GUI ROOT
--==================================================
local gui = Instance.new("ScreenGui")
gui.Name = "AdminPanel"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--==================================================
-- LOADING SCREEN
--==================================================
local loading = Instance.new("Frame", gui)
loading.Size = UDim2.fromScale(0.25,0.18)
loading.Position = UDim2.fromScale(0.5,0.5)
loading.AnchorPoint = Vector2.new(0.5,0.5)
loading.BackgroundColor3 = Color3.fromRGB(25,25,25)
loading.BackgroundTransparency = 0.15
loading.BorderSizePixel = 0
Instance.new("UICorner", loading).CornerRadius = UDim.new(0,16)
Instance.new("UIStroke", loading).Transparency = 0.6

local l1 = Instance.new("TextLabel", loading)
l1.Size = UDim2.fromScale(1,0.55)
l1.BackgroundTransparency = 1
l1.Text = "Loading Admin..."
l1.TextScaled = true
l1.TextColor3 = Color3.new(1,1,1)

local l2 = Instance.new("TextLabel", loading)
l2.Position = UDim2.fromScale(0,0.55)
l2.Size = UDim2.fromScale(1,0.35)
l2.BackgroundTransparency = 1
l2.Text = Settings.DeveloperName
l2.TextScaled = true
l2.TextColor3 = Color3.fromRGB(180,180,180)

blurOn()
task.wait(1.5)
loading:Destroy()
blurOff()

--==================================================
-- FLOATING BUTTON
--==================================================
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.fromOffset(Settings.CircleSize, Settings.CircleSize)
openBtn.Position = UDim2.fromScale(0.5,0.88)
openBtn.AnchorPoint = Vector2.new(0.5,0.5)
openBtn.Text = ""
openBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
openBtn.BorderSizePixel = 0

local oc = Instance.new("UICorner", openBtn)
oc.CornerRadius = Settings.CircleShape=="Circle" and UDim.new(1,0) or UDim.new(0,12)

--==================================================
-- MAIN MENU
--==================================================
local menu = Instance.new("Frame", gui)
menu.Size = UDim2.fromScale(0.32,0.5)
menu.Position = UDim2.fromScale(0.5,0.5)
menu.AnchorPoint = Vector2.new(0.5,0.5)
menu.Visible = false
menu.BackgroundColor3 = Color3.fromRGB(30,30,30)
menu.BackgroundTransparency = 0.2
menu.BorderSizePixel = 0
Instance.new("UICorner", menu).CornerRadius = UDim.new(0,18)
Instance.new("UIStroke", menu).Transparency = 0.6

local layout = Instance.new("UIListLayout", menu)
layout.Padding = UDim.new(0.02,0)

local function mkBtn(text)
	local b = Instance.new("TextButton", menu)
	b.Size = UDim2.fromScale(1,0.12)
	b.Text = text
	b.TextScaled = true
	b.BackgroundColor3 = Color3.fromRGB(45,45,45)
	b.TextColor3 = Color3.new(1,1,1)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,14)
	return b
end

--==================================================
-- INVISIBILITY
--==================================================
local invis = false
mkBtn("Toggle Invisibility").MouseButton1Click:Connect(function()
	local char = player.Character
	if not char then return end
	invis = not invis
	for _,v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = invis and 1 or 0
			v.CanCollide = not invis
		end
	end
end)

--==================================================
-- PLAYERS MENU
--==================================================
local playersMenu = Instance.new("Frame", gui)
playersMenu.Size = UDim2.fromScale(0.28,0.5)
playersMenu.Position = UDim2.fromScale(0.18,0.5)
playersMenu.AnchorPoint = Vector2.new(0.5,0.5)
playersMenu.Visible = false
playersMenu.BackgroundColor3 = Color3.fromRGB(25,25,25)
playersMenu.BackgroundTransparency = 0.2
playersMenu.BorderSizePixel = 0
Instance.new("UICorner", playersMenu).CornerRadius = UDim.new(0,18)
Instance.new("UIStroke", playersMenu).Transparency = 0.6

local plLayout = Instance.new("UIListLayout", playersMenu)
plLayout.Padding = UDim.new(0.02,0)

local search = Instance.new("TextBox", playersMenu)
search.Size = UDim2.fromScale(1,0.1)
search.PlaceholderText = "Search player..."
search.TextScaled = true
search.BackgroundColor3 = Color3.fromRGB(35,35,35)
search.TextColor3 = Color3.new(1,1,1)
search.BorderSizePixel = 0
Instance.new("UICorner", search).CornerRadius = UDim.new(0,12)

local function teamColor(p)
	return p.Team and p.Team.TeamColor.Color or Color3.fromRGB(70,70,70)
end

local function confirmTP(target, callback)
	local c = Instance.new("Frame", gui)
	c.Size = UDim2.fromScale(0.25,0.18)
	c.Position = UDim2.fromScale(0.5,0.5)
	c.AnchorPoint = Vector2.new(0.5,0.5)
	c.BackgroundColor3 = Color3.fromRGB(25,25,25)
	c.BorderSizePixel = 0
	Instance.new("UICorner", c).CornerRadius = UDim.new(0,16)
	Instance.new("UIStroke", c).Transparency = 0.6

	local t = Instance.new("TextLabel", c)
	t.Size = UDim2.fromScale(1,0.55)
	t.BackgroundTransparency = 1
	t.Text = "Teleport to "..target.Name.."?"
	t.TextScaled = true
	t.TextColor3 = Color3.new(1,1,1)

	local y = Instance.new("TextButton", c)
	y.Size = UDim2.fromScale(0.45,0.25)
	y.Position = UDim2.fromScale(0.05,0.65)
	y.Text = "YES"
	y.TextScaled = true
	y.BackgroundColor3 = Color3.fromRGB(0,170,0)
	Instance.new("UICorner", y).CornerRadius = UDim.new(0,12)

	local n = Instance.new("TextButton", c)
	n.Size = UDim2.fromScale(0.45,0.25)
	n.Position = UDim2.fromScale(0.5,0.65)
	n.Text = "NO"
	n.TextScaled = true
	n.BackgroundColor3 = Color3.fromRGB(170,0,0)
	Instance.new("UICorner", n).CornerRadius = UDim.new(0,12)

	y.MouseButton1Click:Connect(function()
		c:Destroy()
		callback()
	end)
	n.MouseButton1Click:Connect(function()
		c:Destroy()
	end)
end

local function loadPlayers()
	for _,v in pairs(playersMenu:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end

	for _,p in pairs(Players:GetPlayers()) do
		if p ~= player and string.find(string.lower(p.Name), string.lower(search.Text)) then
			local b = Instance.new("TextButton", playersMenu)
			b.Size = UDim2.fromScale(1,0.1)
			b.Text = p.Name
			b.TextScaled = true
			b.BackgroundColor3 = teamColor(p)
			b.TextColor3 = Color3.new(1,1,1)
			b.BorderSizePixel = 0
			Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)

			b.MouseButton1Click:Connect(function()
				confirmTP(p,function()
					if player.Character and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
						player.Character:MoveTo(
							p.Character.HumanoidRootPart.Position
							- p.Character.HumanoidRootPart.CFrame.LookVector * 3
						)
					end
				end)
			end)
		end
	end
end

mkBtn("Players Menu").MouseButton1Click:Connect(function()
	playersMenu.Visible = not playersMenu.Visible
	if playersMenu.Visible then loadPlayers() end
end)

Players.PlayerAdded:Connect(loadPlayers)
Players.PlayerRemoving:Connect(loadPlayers)
search:GetPropertyChangedSignal("Text"):Connect(loadPlayers)

--==================================================
-- ESP MENU
--==================================================
local espMenu = Instance.new("Frame", gui)
espMenu.Size = UDim2.fromScale(0.26,0.45)
espMenu.Position = UDim2.fromScale(0.82,0.5)
espMenu.AnchorPoint = Vector2.new(0.5,0.5)
espMenu.Visible = false
espMenu.BackgroundColor3 = Color3.fromRGB(25,25,25)
espMenu.BackgroundTransparency = 0.2
espMenu.BorderSizePixel = 0
Instance.new("UICorner", espMenu).CornerRadius = UDim.new(0,18)
Instance.new("UIStroke", espMenu).Transparency = 0.6
Instance.new("UIListLayout", espMenu).Padding = UDim.new(0.02,0)

local espBtn = Instance.new("TextButton", espMenu)
espBtn.Size = UDim2.fromScale(1,0.15)
espBtn.Text = "ESP : OFF"
espBtn.TextScaled = true
espBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
espBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0,14)

espBtn.MouseButton1Click:Connect(function()
	Settings.ESPEnabled = not Settings.ESPEnabled
	espBtn.Text = Settings.ESPEnabled and "ESP : ON" or "ESP : OFF"
end)

mkBtn("ESP Menu").MouseButton1Click:Connect(function()
	espMenu.Visible = not espMenu.Visible
end)

--==================================================
-- ESP RENDER (FIXED BOX AROUND CHARACTER)
--==================================================
local espBoxes = {}

local function createESP(p)
	if espBoxes[p] then return end
	local box = Instance.new("Frame", gui)
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 2
	box.BorderColor3 = Settings.ESPColor
	box.Visible = false

	local name = Instance.new("TextLabel", box)
	name.Size = UDim2.new(1,0,0.15,0)
	name.BackgroundTransparency = 1
	name.TextScaled = true
	name.TextColor3 = Settings.ESPColor
	name.Text = p.Name

	local hpbg = Instance.new("Frame", box)
	hpbg.Size = UDim2.new(0.06,0,1,0)
	hpbg.Position = UDim2.new(-0.1,0,0,0)
	hpbg.BackgroundColor3 = Color3.fromRGB(40,40,40)

	local hp = Instance.new("Frame", hpbg)
	hp.BackgroundColor3 = Color3.fromRGB(0,255,0)
	hp.Size = UDim2.new(1,0,1,0)

	espBoxes[p] = {Box=box,HP=hp}
end

local function getBox(char)
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	if not hrp or not hum then return end

	local h = hum.HipHeight + 3
	local top = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,h,0))
	local bot = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,h,0))

	local height = math.abs(top.Y - bot.Y)
	local width = height * 0.5

	return UDim2.fromOffset(top.X - width/2, top.Y),
	       UDim2.fromOffset(width, height)
end

RunService.RenderStepped:Connect(function()
	if not Settings.ESPEnabled then return end
	for _,p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			createESP(p)
			local box = espBoxes[p]
			local pos,size = getBox(p.Character)
			if pos and size then
				box.Box.Position = pos
				box.Box.Size = size
				box.Box.Visible = true
			else
				box.Box.Visible = false
			end
		end
	end
end)

--==================================================
-- TOGGLE MAIN MENU
--==================================================
openBtn.MouseButton1Click:Connect(function()
	menu.Visible = not menu.Visible
	if menu.Visible then blurOn() else blurOff() end
end)
