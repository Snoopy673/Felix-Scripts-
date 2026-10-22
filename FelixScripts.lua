--[[
    Felix Scripts | Super pro
    Jogo: Brookhaven RP
    Recursos: Intro animada + ESP (nome e distância) com liga/desliga
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Evita executar duas vezes
local parentGui = (gethui and gethui()) or game:GetService("CoreGui")
if parentGui:FindFirstChild("FelixScriptsGui") then
    parentGui.FelixScriptsGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "FelixScriptsGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = parentGui

----------------------------------------------------------------
-- INTRO
----------------------------------------------------------------
local function playIntro()
    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
    bg.BackgroundTransparency = 1
    bg.BorderSizePixel = 0
    bg.Parent = gui

    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.Size = UDim2.fromOffset(340, 130)
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.Parent = bg
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Transparency = 1
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Parent = card
    local strokeGrad = Instance.new("UIGradient")
    strokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 80, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255)),
    })
    strokeGrad.Parent = stroke

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(0, 22)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Font = Enum.Font.GothamBlack
    title.Text = "Felix Scripts"
    title.TextSize = 38
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextTransparency = 1
    title.Parent = card
    local titleGrad = Instance.new("UIGradient")
    titleGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 110, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 210, 255)),
    })
    titleGrad.Parent = title

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(0, 78)
    sub.Size = UDim2.new(1, 0, 0, 28)
    sub.Font = Enum.Font.GothamMedium
    sub.Text = "Super pro"
    sub.TextSize = 20
    sub.TextColor3 = Color3.fromRGB(200, 200, 220)
    sub.TextTransparency = 1
    sub.Parent = card

    -- animação de entrada
    local ti = TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(bg, ti, {BackgroundTransparency = 0.35}):Play()
    TweenService:Create(card, ti, {BackgroundTransparency = 0.05}):Play()
    TweenService:Create(stroke, ti, {Transparency = 0}):Play()
    TweenService:Create(title, ti, {TextTransparency = 0}):Play()
    task.delay(0.25, function()
        TweenService:Create(sub, ti, {TextTransparency = 0}):Play()
    end)

    -- gradiente girando
    local rot = 0
    local spin = RunService.RenderStepped:Connect(function(dt)
        rot = (rot + dt * 90) % 360
        strokeGrad.Rotation = rot
        titleGrad.Rotation = rot
    end)

    task.wait(2.6)

    -- saída
    local to = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    TweenService:Create(bg, to, {BackgroundTransparency = 1}):Play()
    TweenService:Create(card, to, {BackgroundTransparency = 1}):Play()
    TweenService:Create(stroke, to, {Transparency = 1}):Play()
    TweenService:Create(title, to, {TextTransparency = 1}):Play()
    TweenService:Create(sub, to, {TextTransparency = 1}):Play()
    task.wait(0.7)
    spin:Disconnect()
    bg:Destroy()
end

----------------------------------------------------------------
-- ESP (nome + distância)
----------------------------------------------------------------
local espEnabled = false
local espObjects = {}

local function removeESP(player)
    local obj = espObjects[player]
    if obj then
        if obj.gui then obj.gui:Destroy() end
        espObjects[player] = nil
    end
end

local function createESP(player)
    if player == LocalPlayer then return end
    removeESP(player)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FelixESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.fromOffset(160, 40)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.ResetOnSpawn = false

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.4
    label.Text = player.DisplayName
    label.Parent = billboard

    billboard.Parent = gui
    espObjects[player] = {gui = billboard, label = label}
end

local function updateESP()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for player, obj in pairs(espObjects) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if espEnabled and root and myRoot then
            obj.gui.Adornee = root
            obj.gui.Enabled = true
            local dist = math.floor((root.Position - myRoot.Position).Magnitude)
            obj.label.Text = string.format("%s\n[%d m]", player.DisplayName, dist)
        else
            obj.gui.Enabled = false
        end
    end
end

for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)
RunService.RenderStepped:Connect(updateESP)

----------------------------------------------------------------
-- MENU (um único botão: ESP)
----------------------------------------------------------------
local function buildMenu()
    local frame = Instance.new("Frame")
    frame.Name = "Menu"
    frame.Position = UDim2.fromOffset(20, 120)
    frame.Size = UDim2.fromOffset(200, 96)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true -- arrastável
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Parent = frame
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 80, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255)),
    })
    g.Parent = stroke

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(0, 8)
    title.Size = UDim2.new(1, 0, 0, 22)
    title.Font = Enum.Font.GothamBlack
    title.Text = "Felix Scripts"
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Position = UDim2.fromOffset(16, 44)
    btn.Size = UDim2.new(1, -32, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "ESP: OFF"
    btn.AutoButtonColor = true
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        btn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
        TweenService:Create(btn, TweenInfo.new(0.25), {
            BackgroundColor3 = espEnabled and Color3.fromRGB(60, 190, 120) or Color3.fromRGB(60, 60, 80)
        }):Play()
    end)

    -- animação de entrada do menu
    frame.BackgroundTransparency = 1
    TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
end

playIntro()
buildMenu()
