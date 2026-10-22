--[[
    Felix Scripts | Super pro   (v5)
    Jogos: Brookhaven RP (menu completo) e SCP AIMBOT (ESP + FPS + Aimbot)
    Ao executar, aparece "Usar no:" para escolher o jogo.
    Brookhaven: Jogador, Sistema, Veículos, Casas, Jogadores, Câmera, Locais, Música
    SCP AIMBOT: ESP, FPS, Aimbot, SCP Troll, Jogadores (vida PvP, combate auto-tiro, wallbang)
    - Botão "F" abre/fecha o menu (arrastável)
    - Botão X (no topo do menu) apaga o script por completo
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local SoundService     = game:GetService("SoundService")
local HttpService      = game:GetService("HttpService")
local TeleportService  = game:GetService("TeleportService")
local Stats            = game:GetService("Stats")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

----------------------------------------------------------------
-- Evita execução dupla (fecha a versão anterior)
----------------------------------------------------------------
pcall(function()
    local env = (getgenv and getgenv()) or _G
    if env.FelixCleanup then env.FelixCleanup() end
end)

local parentGui = (gethui and gethui()) or game:GetService("CoreGui")
local gui = Instance.new("ScreenGui")
gui.Name = "FelixScriptsGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = parentGui

----------------------------------------------------------------
-- Utilidades
----------------------------------------------------------------
local Conns = {}
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Conns, c)
    return c
end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function round(o, r)
    new("UICorner", {CornerRadius = UDim.new(0, r or 8)}, o)
end

local function getChar() return LP.Character end
local function getHum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getRoot()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local C = {
    bg      = Color3.fromRGB(12, 12, 22),
    side    = Color3.fromRGB(18, 18, 32),
    row     = Color3.fromRGB(28, 28, 48),
    rowHi   = Color3.fromRGB(40, 40, 68),
    text    = Color3.fromRGB(235, 235, 245),
    sub     = Color3.fromRGB(150, 150, 175),
    accent  = Color3.fromRGB(140, 80, 255),
    accent2 = Color3.fromRGB(0, 200, 255),
    on      = Color3.fromRGB(60, 190, 120),
    off     = Color3.fromRGB(70, 70, 95),
    danger  = Color3.fromRGB(220, 60, 80),
}

local function accentGradient(parent, rot)
    return new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, C.accent),
            ColorSequenceKeypoint.new(1, C.accent2),
        }),
        Rotation = rot or 0,
    }, parent)
end

-- Arrastar (mouse e toque). Retorna tabela com .moved para diferenciar clique de arraste
local function makeDraggable(handle, target)
    local state = {moved = false}
    local dragging, dragStart, startPos = false, nil, nil
    connect(handle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            state.moved = false
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    connect(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            if d.Magnitude > 8 then state.moved = true end
            if state.moved then
                target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                            startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end
    end)
    return state
end

----------------------------------------------------------------
-- INTRO
----------------------------------------------------------------
local function playIntro()
    local bg = new("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(8, 8, 14),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    }, gui)

    local card = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(340, 130), BackgroundColor3 = Color3.fromRGB(18, 18, 30),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    }, bg)
    round(card, 16)

    local stroke = new("UIStroke", {Thickness = 2, Transparency = 1, Color = Color3.new(1, 1, 1)}, card)
    local strokeGrad = accentGradient(stroke)

    local title = new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 22),
        Size = UDim2.new(1, 0, 0, 50), Font = Enum.Font.GothamBlack, Text = "Felix Scripts",
        TextSize = 38, TextColor3 = Color3.new(1, 1, 1), TextTransparency = 1,
    }, card)
    local titleGrad = accentGradient(title)

    local sub = new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 78),
        Size = UDim2.new(1, 0, 0, 28), Font = Enum.Font.GothamMedium, Text = "Super pro",
        TextSize = 20, TextColor3 = Color3.fromRGB(200, 200, 220), TextTransparency = 1,
    }, card)

    local ti = TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(bg, ti, {BackgroundTransparency = 0.35}):Play()
    TweenService:Create(card, ti, {BackgroundTransparency = 0.05}):Play()
    TweenService:Create(stroke, ti, {Transparency = 0}):Play()
    TweenService:Create(title, ti, {TextTransparency = 0}):Play()
    task.delay(0.25, function()
        TweenService:Create(sub, ti, {TextTransparency = 0}):Play()
    end)

    local rot = 0
    local spin = RunService.RenderStepped:Connect(function(dt)
        rot = (rot + dt * 90) % 360
        strokeGrad.Rotation = rot
        titleGrad.Rotation = rot
    end)

    task.wait(2.6)

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
-- ESTADO / RECURSOS DO SCRIPT
----------------------------------------------------------------
local S = {
    speedOn = false, speed = 40,
    jumpOn = false, jump = 100,
    infJump = false,
    noclip = false,
    fly = false, flySpeed = 60,
    esp = false,
    turbo = false, turboBoost = 6, turboMax = 200,
    lunar = false,
    espOnlySel = false,
    fovOn = false, fov = 70,
    cinema = false,
    antiAfk = false,
    fullbright = false,
    fpsBoost = false,
    -- Aimbot (SCP)
    aimbot = false,
    aimbotFov = 80,           -- tamanho do FOV (1 a 100)
    aimbotInvis = true,       -- deixa invisível? (sem círculo visual)
    aimbotSens = 3,           -- sensibilidade 1 a 10 (maior = mais rápido/travado)
    aimbotColor = Color3.fromRGB(140, 80, 255), -- cor do círculo do AIMBOT
    -- SCP Troll
    scpEsp = false,
    scpAimbot = true,         -- aimbot também mira em SCPs
    scpLifeMode = "off",      -- "off" | "melhor" | "super" (só protege de SCPs, não de jogadores)
    antiInfect = false,       -- anti-infecção (409, 008, etc.)
    -- Jogadores / combate
    pLifeMode = "off",        -- vida vs jogadores: "off" | "melhor" | "super"
    combatMode = false,       -- auto-atirar quando vê inimigo
    wallbang = false,         -- tentativa de balas atravessarem parede
}

local hum0 = getHum()
local ORIG = {
    walk = hum0 and hum0.WalkSpeed or 16,
    jump = hum0 and hum0.JumpPower or 50,
    gravity = workspace.Gravity,
    brightness = Lighting.Brightness,
    clock = Lighting.ClockTime,
    fogEnd = Lighting.FogEnd,
    ambient = Lighting.Ambient,
    fov = Camera.FieldOfView,
    maxZoom = LP.CameraMaxZoomDistance,
    quality = nil,
}
pcall(function() ORIG.quality = settings().Rendering.QualityLevel end)

local flyBV
local selPlayer -- jogador selecionado na aba Jogadores

----------------------------------------------------------------
-- ESP (nome + distância)
----------------------------------------------------------------
local espObjects = {}

local function removeESP(p)
    local o = espObjects[p]
    if o then o.gui:Destroy() espObjects[p] = nil end
end

local function createESP(p)
    if p == LP then return end
    removeESP(p)
    local bb = new("BillboardGui", {
        Name = "FelixESP", AlwaysOnTop = true, Size = UDim2.fromOffset(160, 40),
        StudsOffset = Vector3.new(0, 3.2, 0), ResetOnSpawn = false, Enabled = false,
    }, gui)
    local lbl = new("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold,
        TextSize = 14, TextColor3 = Color3.new(1, 1, 1), TextStrokeTransparency = 0.4,
        Text = p.DisplayName,
    }, bb)
    espObjects[p] = {gui = bb, label = lbl}
end

for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
connect(Players.PlayerAdded, createESP)
connect(Players.PlayerRemoving, removeESP)

----------------------------------------------------------------
-- SCP TROLL: detecção + ESP de SCPs
----------------------------------------------------------------
local SCP_KEYWORDS = {
    "scp", "SCP", "096", "173", "049", "106", "682", "457", "966", "023",
    "008", "079", "087", "093", "002", "066", "076", "131", "999", "2950",
    "1299", "409", "299", "938", "939", "016", "316", "1025", "001",
    "shy", "peanut", "plague", "burning", "able", "old man", "tickle",
}

-- Classificação por nome (Safe / Euclid / Keter)
local SCP_CLASS = {
    -- SAFE
    ["131"] = "Safe", ["316"] = "Safe", ["999"] = "Safe", ["1025"] = "Safe", ["2950"] = "Safe",
    ["tickle"] = "Safe", ["chair"] = "Safe", ["eyepod"] = "Safe",
    -- EUCLID
    ["002"] = "Euclid", ["008"] = "Euclid", ["023"] = "Euclid", ["049"] = "Euclid",
    ["066"] = "Euclid", ["079"] = "Euclid", ["087"] = "Euclid", ["093"] = "Euclid",
    ["096"] = "Euclid", ["173"] = "Euclid", ["966"] = "Euclid", ["1299"] = "Euclid",
    ["shy"] = "Euclid", ["peanut"] = "Euclid", ["plague"] = "Euclid", ["sculpture"] = "Euclid",
    -- KETER
    ["016"] = "Keter", ["076"] = "Keter", ["106"] = "Keter", ["299"] = "Keter",
    ["409"] = "Keter", ["457"] = "Keter", ["682"] = "Keter", ["938"] = "Keter", ["939"] = "Keter",
    ["burning"] = "Keter", ["able"] = "Keter", ["old man"] = "Keter", ["lizard"] = "Keter",
}

local function classifySCP(model)
    local n = string.lower(model.Name)
    for key, class in pairs(SCP_CLASS) do
        if string.find(n, key, 1, true) then
            return class
        end
    end
    return "Euclid" -- padrão se não reconhecer
end

local scpEspObjects = {} -- [Instance] = {gui, label, part, class}

local function isLikelySCP(inst)
    if not inst or not inst.Parent then return false end
    if inst:IsA("Model") or inst:IsA("Folder") then
        local n = string.lower(inst.Name)
        for _, kw in ipairs(SCP_KEYWORDS) do
            if string.find(n, string.lower(kw), 1, true) then
                return true
            end
        end
        if inst:GetAttribute("SCP") or inst:GetAttribute("IsSCP") or inst:FindFirstChild("SCP") then
            return true
        end
    end
    return false
end

local function getSCPPart(model)
    if not model then return nil end
    return model:FindFirstChild("Head")
        or model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
        or model:FindFirstChildWhichIsA("BasePart", true)
end

local function removeSCPEsp(model)
    local o = scpEspObjects[model]
    if o then
        pcall(function() o.gui:Destroy() end)
        scpEspObjects[model] = nil
    end
end

local function createSCPEsp(model)
    if scpEspObjects[model] then return end
    local part = getSCPPart(model)
    if not part then return end
    local class = classifySCP(model)
    local color = class == "Safe" and Color3.fromRGB(80, 220, 120)
        or class == "Keter" and Color3.fromRGB(255, 70, 70)
        or Color3.fromRGB(255, 200, 60) -- Euclid
    local bb = new("BillboardGui", {
        Name = "FelixSCPEsp", AlwaysOnTop = true, Size = UDim2.fromOffset(180, 44),
        StudsOffset = Vector3.new(0, 3.5, 0), ResetOnSpawn = false, Enabled = false,
    }, gui)
    local lbl = new("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold,
        TextSize = 14, TextColor3 = color, TextStrokeTransparency = 0.3,
        Text = model.Name,
    }, bb)
    scpEspObjects[model] = {gui = bb, label = lbl, part = part, class = class}
end

local function scanSCPs()
    for model in pairs(scpEspObjects) do
        if not model.Parent then removeSCPEsp(model) end
    end
    local roots = {workspace}
    for _, name in ipairs({"SCPs", "SCP", "Anomalies", "Entities", "Mobs", "NPCs"}) do
        local f = workspace:FindFirstChild(name)
        if f then table.insert(roots, f) end
    end
    for _, root in ipairs(roots) do
        for _, inst in ipairs(root:GetChildren()) do
            if isLikelySCP(inst) then
                createSCPEsp(inst)
            end
            if inst:IsA("Folder") or inst:IsA("Model") then
                for _, child in ipairs(inst:GetChildren()) do
                    if isLikelySCP(child) then
                        createSCPEsp(child)
                    end
                end
            end
        end
    end
end

local function teleportToSCP(model)
    local part = getSCPPart(model)
    local me = getRoot()
    if part and me then
        me.CFrame = part.CFrame * CFrame.new(0, 3, 6)
    end
end

local function getSCPsByClass(className)
    local list = {}
    for model, o in pairs(scpEspObjects) do
        if model.Parent and o.class == className then
            table.insert(list, model)
        end
    end
    table.sort(list, function(a, b) return a.Name < b.Name end)
    return list
end

----------------------------------------------------------------
-- Anti-infecção (409, 008, 016, 299, etc.)
----------------------------------------------------------------
local INFECT_KEYWORDS = {
    "infect", "infection", "infected", "plague", "virus", "contag",
    "409", "008", "016", "299", "crystal", "zombie", "spore",
    "daybreak", "disease", "sickness", "status", "debuff",
}

local function nameLooksInfect(n)
    n = string.lower(tostring(n or ""))
    for _, kw in ipairs(INFECT_KEYWORDS) do
        if string.find(n, kw, 1, true) then return true end
    end
    return false
end

local function clearInfection()
    local char = getChar()
    if not char then return end

    -- remove efeitos/objetos de infecção no personagem
    for _, inst in ipairs(char:GetDescendants()) do
        local n = inst.Name
        if nameLooksInfect(n) then
            -- não destrói partes essenciais do corpo
            if not inst:IsA("BasePart") and not inst:IsA("Humanoid")
                and not inst:IsA("Shirt") and not inst:IsA("Pants")
                and not inst:IsA("BodyColors") and not inst:IsA("CharacterMesh") then
                pcall(function() inst:Destroy() end)
            end
        end
    end

    -- atributos de infecção
    pcall(function()
        for attr, _ in pairs(char:GetAttributes()) do
            if nameLooksInfect(attr) then
                char:SetAttribute(attr, nil)
            end
        end
    end)

    -- valores no humanoid / player
    local hum = getHum()
    if hum then
        pcall(function()
            for attr, _ in pairs(hum:GetAttributes()) do
                if nameLooksInfect(attr) then
                    hum:SetAttribute(attr, nil)
                end
            end
        end)
        -- alguns jogos usam BoolValues / NumberValues
        for _, v in ipairs(hum:GetChildren()) do
            if nameLooksInfect(v.Name) then
                pcall(function() v:Destroy() end)
            end
        end
    end

    -- PlayerGui / efeitos visuais de infecção
    pcall(function()
        for _, g in ipairs(LP.PlayerGui:GetChildren()) do
            if nameLooksInfect(g.Name) then
                g.Enabled = false
                pcall(function() g:Destroy() end)
            end
        end
    end)

    -- pastas comuns de status / infecção no character
    for _, folderName in ipairs({"Status", "Statuses", "Effects", "Buffs", "Debuffs", "Infection"}) do
        local f = char:FindFirstChild(folderName)
        if f then
            for _, child in ipairs(f:GetChildren()) do
                if nameLooksInfect(folderName) or nameLooksInfect(child.Name) then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end

task.spawn(function()
    while gui.Parent do
        if S.scpEsp or S.scpAimbot or S.scpLifeMode ~= "off" then
            pcall(scanSCPs)
        end
        if S.antiInfect then
            pcall(clearInfection)
        end
        task.wait(S.antiInfect and 0.35 or 1.2)
    end
end)

----------------------------------------------------------------
-- Wallbang (balas atravessam parede) — client / executor
----------------------------------------------------------------
local wallbangHooked = false
local function setupWallbang()
    if wallbangHooked then return end
    wallbangHooked = true
    -- tenta hook de Raycast (Synapse / Script-Ware / similares)
    pcall(function()
        if not hookmetamethod or not getnamecallmethod then return end
        local old
        old = hookmetamethod(game, "__namecall", newcclosure and newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if S.wallbang and method == "Raycast" and self == workspace then
                local origin, dir, params = ...
                if typeof(params) == "RaycastParams" then
                    local np = RaycastParams.new()
                    np.FilterType = Enum.RaycastFilterType.Exclude
                    local filter = {getChar()}
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character then table.insert(filter, p.Character) end
                    end
                    -- ignora mapa: só colide com personagens (efeito wallbang)
                    np.FilterDescendantsInstances = filter
                    np.FilterType = Enum.RaycastFilterType.Include
                    return old(self, origin, dir, np)
                end
            end
            return old(self, ...)
        end) or function(self, ...)
            local method = getnamecallmethod()
            if S.wallbang and method == "Raycast" and self == workspace then
                local origin, dir, params = ...
                if typeof(params) == "RaycastParams" then
                    local np = RaycastParams.new()
                    local filter = {}
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character then table.insert(filter, p.Character) end
                    end
                    np.FilterType = Enum.RaycastFilterType.Include
                    np.FilterDescendantsInstances = filter
                    return old(self, origin, dir, np)
                end
            end
            return old(self, ...)
        end)
    end)
end
setupWallbang()

----------------------------------------------------------------
-- FLY
----------------------------------------------------------------
local flyUI -- setter do toggle (definido depois)

local function stopFly()
    S.fly = false
    if flyBV then flyBV:Destroy() flyBV = nil end
    local h = getHum()
    if h then h.PlatformStand = false end
end

local function startFly()
    local root, h = getRoot(), getHum()
    if not root or not h then return false end
    if flyBV then flyBV:Destroy() end
    flyBV = new("BodyVelocity", {MaxForce = Vector3.new(1e9, 1e9, 1e9), Velocity = Vector3.zero}, root)
    h.PlatformStand = true
    S.fly = true
    return true
end

----------------------------------------------------------------
-- LOOP PRINCIPAL
----------------------------------------------------------------
local fpsSmooth = 60

connect(RunService.Heartbeat, function(dt)
    fpsSmooth = fpsSmooth * 0.9 + (1 / math.max(dt, 1e-4)) * 0.1

    local h, root = getHum(), getRoot()

    -- ESP jogadores
    local myPos = root and root.Position
    for p, o in pairs(espObjects) do
        local ch = p.Character
        local r = ch and ch:FindFirstChild("HumanoidRootPart")
        if S.esp and r and myPos and (not S.espOnlySel or p == selPlayer) then
            o.gui.Adornee = r
            o.gui.Enabled = true
            o.label.Text = string.format("%s\n[%d m]", p.DisplayName, math.floor((r.Position - myPos).Magnitude))
        else
            o.gui.Enabled = false
        end
    end

    -- ESP SCPs
    for model, o in pairs(scpEspObjects) do
        local part = o.part and o.part.Parent and o.part or getSCPPart(model)
        o.part = part
        if S.scpEsp and part and myPos then
            o.gui.Adornee = part
            o.gui.Enabled = true
            local dist = math.floor((part.Position - myPos).Magnitude)
            local cls = o.class or "Euclid"
            o.label.Text = string.format("[%s] %s\n[%d m]", cls, model.Name, dist)
            o.label.TextColor3 = cls == "Safe" and Color3.fromRGB(80, 220, 120)
                or cls == "Keter" and Color3.fromRGB(255, 70, 70)
                or Color3.fromRGB(255, 200, 60)
        else
            o.gui.Enabled = false
        end
    end

    -- Proteção de vida SÓ contra SCPs (jogadores matam normal)
    if S.scpLifeMode ~= "off" and h and root then
        local nearSCP = false
        for model, o in pairs(scpEspObjects) do
            local part = o.part and o.part.Parent and o.part or getSCPPart(model)
            if part then
                local d = (part.Position - root.Position).Magnitude
                if d < 45 then -- perto de um SCP = considera dano de SCP
                    nearSCP = true
                    break
                end
            end
        end
        if nearSCP then
            if S.scpLifeMode == "super" then
                -- Super vida: cura total instantânea (mais óbvio)
                if h.Health < h.MaxHealth then
                    h.Health = h.MaxHealth
                end
                pcall(function()
                    if h:GetState() == Enum.HumanoidStateType.Dead then
                        h:ChangeState(Enum.HumanoidStateType.Running)
                        h.Health = h.MaxHealth
                    end
                end)
            elseif S.scpLifeMode == "melhor" then
                -- Melhor vida: regenera devagar (parece natural, menos suspeito)
                if h.Health < h.MaxHealth and h.Health > 0 then
                    h.Health = math.min(h.MaxHealth, h.Health + (18 * dt)) -- ~18 HP/s
                end
            end
        end
        -- longe de SCP: não mexe na vida → jogadores matam normal (salvo pLifeMode)
    end

    -- Vida vs JOGADORES (quando alguém te atira)
    if S.pLifeMode ~= "off" and h then
        if S.pLifeMode == "super" then
            if h.Health < h.MaxHealth then
                h.Health = h.MaxHealth
            end
            pcall(function()
                if h:GetState() == Enum.HumanoidStateType.Dead then
                    h:ChangeState(Enum.HumanoidStateType.Running)
                    h.Health = h.MaxHealth
                end
            end)
        elseif S.pLifeMode == "melhor" then
            -- quase não sente dano: regenera bem rápido
            if h.Health < h.MaxHealth and h.Health > 0 then
                h.Health = math.min(h.MaxHealth, h.Health + (55 * dt)) -- ~55 HP/s
            end
        end
    end

    -- Modo combate: auto-atirar quando inimigo no FOV / mira
    if not _G._felixCombatCd then _G._felixCombatCd = 0 end
    if S.combatMode and cam and root and tick() > _G._felixCombatCd then
        local vp = cam.ViewportSize
        local center = Vector2.new(vp.X / 2, vp.Y / 2)
        local shouldShoot = false
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local ch = p.Character
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                local head = ch and (ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart"))
                if hum and hum.Health > 0 and head then
                    local sp, onScreen = cam:WorldToViewportPoint(head.Position)
                    if onScreen and sp.Z > 0 then
                        local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if dist <= (S.aimbotFov * 2.8) then
                            shouldShoot = true
                            break
                        end
                    end
                end
            end
        end
        if shouldShoot then
            _G._felixCombatCd = tick() + 0.08 -- ~12 tiros/s máx
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                vim:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
                task.delay(0.03, function()
                    pcall(function()
                        vim:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
                    end)
                end)
            end)
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton1(Vector2.new())
            end)
        end
    end

    -- wallbang é aplicado via hook (ver setupWallbang)

    if h then
        if S.speedOn then h.WalkSpeed = S.speed end
        if S.jumpOn then
            h.UseJumpPower = true
            h.JumpPower = S.jump
        end
    end

    -- Fly
    if S.fly and flyBV and root and h then
        local look = Camera.CFrame.LookVector
        local move = h.MoveDirection
        local vel = Vector3.zero
        if move.Magnitude > 0.05 then
            local flatLook = Vector3.new(look.X, 0, look.Z)
            local fwd = flatLook.Magnitude > 0 and move:Dot(flatLook.Unit) or 0
            vel = move * S.flySpeed + Vector3.new(0, look.Y * fwd * S.flySpeed, 0)
        end
        flyBV.Velocity = vel
    end

    -- Turbo de veículo (acelera na direção em que o carro já está indo)
    if S.turbo and h and h.SeatPart then
        local seat = h.SeatPart
        local body = seat.AssemblyRootPart or seat
        local v = body.AssemblyLinearVelocity
        local flat = Vector3.new(v.X, 0, v.Z)
        if flat.Magnitude > 3 and flat.Magnitude < S.turboMax then
            body.AssemblyLinearVelocity = v + flat.Unit * (S.turboBoost * 60 * dt)
        end
    end

    -- Câmera (FOV personalizado)
    local cam = workspace.CurrentCamera
    if S.fovOn and cam then cam.FieldOfView = S.fov end

    -- AIMBOT — centrado na tela (jogadores + SCPs se ativado)
    if S.aimbot and cam then
        local vp = cam.ViewportSize
        local center = Vector2.new(vp.X / 2, vp.Y / 2)
        local fovRadius = S.aimbotFov * 2.8
        local bestScore, bestPart

        -- jogadores
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local ch = p.Character
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                local head = ch and ch:FindFirstChild("Head")
                local pRoot = ch and ch:FindFirstChild("HumanoidRootPart")
                local part = head or pRoot
                if hum and hum.Health > 0 and part then
                    local predPos = part.Position
                    if pRoot then
                        local vel = pRoot.AssemblyLinearVelocity
                        predPos = predPos + Vector3.new(vel.X, 0, vel.Z) * 0.12
                    end
                    local screenPos, onScreen = cam:WorldToViewportPoint(predPos)
                    if onScreen and screenPos.Z > 0 then
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if screenDist <= fovRadius then
                            local worldDist = (part.Position - cam.CFrame.Position).Magnitude
                            local score = screenDist + worldDist * 0.08
                            if not bestScore or score < bestScore then
                                bestScore = score
                                bestPart = part
                            end
                        end
                    end
                end
            end
        end

        -- SCPs (se opção ligada)
        if S.scpAimbot then
            for model, o in pairs(scpEspObjects) do
                local part = o.part and o.part.Parent and o.part or getSCPPart(model)
                if part then
                    local predPos = part.Position
                    pcall(function()
                        local vel = part.AssemblyLinearVelocity
                        predPos = predPos + Vector3.new(vel.X, 0, vel.Z) * 0.1
                    end)
                    local screenPos, onScreen = cam:WorldToViewportPoint(predPos)
                    if onScreen and screenPos.Z > 0 then
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if screenDist <= fovRadius then
                            local worldDist = (part.Position - cam.CFrame.Position).Magnitude
                            local score = screenDist + worldDist * 0.06 -- prioriza um pouco mais SCP
                            if not bestScore or score < bestScore then
                                bestScore = score
                                bestPart = part
                            end
                        end
                    end
                end
            end
        end

        if bestPart then
            local targetPos = bestPart.Position
            pcall(function()
                local r = bestPart.Parent and bestPart.Parent:FindFirstChild("HumanoidRootPart")
                if r then
                    local vel = r.AssemblyLinearVelocity
                    targetPos = targetPos + Vector3.new(vel.X, 0, vel.Z) * 0.12
                end
            end)
            local targetCF = CFrame.new(cam.CFrame.Position, targetPos)
            local alpha = math.clamp((S.aimbotSens / 10) * 0.95, 0.06, 1)
            cam.CFrame = cam.CFrame:Lerp(targetCF, alpha)
        end
    end
end)

connect(RunService.Stepped, function()
    if S.noclip then
        local c = getChar()
        if c then
            for _, part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

connect(UserInputService.JumpRequest, function()
    if S.infJump then
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

connect(LP.CharacterAdded, function(char)
    stopFly()
    if flyUI then flyUI(false) end
    -- proteção de vida é aplicada no Heartbeat (só perto de SCPs)
end)

connect(LP.Idled, function()
    if S.antiAfk then
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end
end)

----------------------------------------------------------------
-- MÚSICA: persistência e canais
----------------------------------------------------------------
local FILE = "FelixScripts_musicas.json"
local store = {geral = {}, casa = {}, veiculo = {}, locais = {}}
pcall(function()
    if isfile and isfile(FILE) then
        local d = HttpService:JSONDecode(readfile(FILE))
        for k, v in pairs(d) do store[k] = v end
    end
end)
for _, k in ipairs({"geral", "casa", "veiculo", "locais"}) do store[k] = store[k] or {} end

local function saveStore()
    pcall(function()
        if writefile then writefile(FILE, HttpService:JSONEncode(store)) end
    end)
end

local channels = {}
local function getChannel(key)
    if channels[key] then return channels[key] end
    local ch = {
        sound = new("Sound", {Name = "Felix_" .. key, Volume = 0.5, Looped = false}, SoundService),
        statuses = {}, lists = {}, token = 0,
    }
    channels[key] = ch

    function ch.setStatus(t)
        for _, l in ipairs(ch.statuses) do l.Text = t end
    end
    function ch.refresh()
        for _, fn in ipairs(ch.lists) do fn() end
    end
    function ch.play(id, name)
        local clean = tostring(id or ""):match("%d+")
        if not clean then ch.setStatus("ID inválido") return end
        ch.token = ch.token + 1
        local my = ch.token
        ch.sound:Stop()
        ch.sound.SoundId = "rbxassetid://" .. clean
        ch.sound:Play()
        ch.setStatus("Carregando...")
        task.spawn(function()
            local t = 0
            while t < 6 and not ch.sound.IsLoaded and ch.token == my do
                task.wait(0.2)
                t = t + 0.2
            end
            if ch.token ~= my then return end
            if ch.sound.IsLoaded then
                ch.setStatus("Tocando: " .. (name or clean))
            else
                ch.setStatus("Não carregou (ID inválido ou áudio privado)")
            end
        end)
    end
    function ch.stop()
        ch.token = ch.token + 1
        ch.sound:Stop()
        ch.setStatus("Parado")
    end
    return ch
end

----------------------------------------------------------------
-- UI: janela principal
----------------------------------------------------------------
local vp = Camera.ViewportSize
local baseScale = math.clamp((vp.Y - 40) / 300, 0.6, 1)

local main = new("Frame", {
    Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(500, 300), BackgroundColor3 = C.bg, BorderSizePixel = 0,
    ClipsDescendants = true, Visible = false,
}, gui)
round(main, 14)
local mainScale = new("UIScale", {Scale = baseScale * 0.85}, main)
local mainStroke = new("UIStroke", {Thickness = 1.5, Color = Color3.new(1, 1, 1)}, main)
accentGradient(mainStroke, 45)

-- Barra do topo
local top = new("Frame", {
    Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = C.side, BorderSizePixel = 0,
}, main)

local topTitle = new("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -110, 1, 0),
    Font = Enum.Font.GothamBlack, Text = "Felix Scripts  •  Super pro", TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.new(1, 1, 1),
}, top)
accentGradient(topTitle)

local btnClose = new("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(28, 26),
    BackgroundColor3 = C.danger, Font = Enum.Font.GothamBold, Text = "X", TextSize = 14,
    TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = true,
}, top)
round(btnClose, 6)

local btnMin = new("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -42, 0.5, 0), Size = UDim2.fromOffset(28, 26),
    BackgroundColor3 = C.row, Font = Enum.Font.GothamBold, Text = "-", TextSize = 18,
    TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = true,
}, top)
round(btnMin, 6)

makeDraggable(top, main)

-- Sidebar
local sidebar = new("ScrollingFrame", {
    Position = UDim2.fromOffset(0, 38), Size = UDim2.new(0, 112, 1, -38), BackgroundColor3 = C.side,
    BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, main)
new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, sidebar)
new("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, sidebar)

local content = new("Frame", {
    Position = UDim2.fromOffset(112, 38), Size = UDim2.new(1, -112, 1, -38),
    BackgroundTransparency = 1,
}, main)

----------------------------------------------------------------
-- UI: componentes
----------------------------------------------------------------
local orderCounter = 0
local function nextOrder() orderCounter = orderCounter + 1 return orderCounter end

local pages, tabButtons = {}, {}
local currentTab

local function selectTab(name)
    currentTab = name
    for n, page in pairs(pages) do page.Visible = (n == name) end
    for n, b in pairs(tabButtons) do
        local active = (n == name)
        TweenService:Create(b, TweenInfo.new(0.2), {
            BackgroundColor3 = active and C.rowHi or C.side,
            TextColor3 = active and Color3.new(1, 1, 1) or C.sub,
        }):Play()
    end
end

local function addTab(name)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = C.side, BorderSizePixel = 0,
        Font = Enum.Font.GothamBold, Text = name, TextSize = 14, TextColor3 = C.sub,
        AutoButtonColor = false, LayoutOrder = nextOrder(),
    }, sidebar)
    round(b, 8)

    local page = new("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = C.accent, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
    }, content)
    new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    new("UIPadding", {
        PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10),
    }, page)

    pages[name] = page
    tabButtons[name] = b
    connect(b.Activated, function() selectTab(name) end)
    return page
end

local function section(page, text)
    return new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
        Text = string.upper(text), TextSize = 12, TextColor3 = C.accent2,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(),
    }, page)
end

local function infoLabel(page, text)
    return new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        Font = Enum.Font.Gotham, Text = text, TextSize = 12, TextColor3 = C.sub, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(),
    }, page)
end

local function rowFrame(page, height)
    local f = new("Frame", {
        Size = UDim2.new(1, 0, 0, height or 34), BackgroundColor3 = C.row, BorderSizePixel = 0,
        LayoutOrder = nextOrder(),
    }, page)
    round(f, 8)
    return f
end

local function toggleRow(page, text, default, callback)
    local row = rowFrame(page)
    new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -70, 1, 0),
        Font = Enum.Font.GothamMedium, Text = text, TextSize = 13, TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    }, row)
    local sw = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(44, 22),
        BackgroundColor3 = C.off, Text = "", AutoButtonColor = false,
    }, row)
    round(sw, 11)
    local knob = new("Frame", {
        Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(3, 3),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
    }, sw)
    round(knob, 8)

    local state = default and true or false
    local function apply(animated)
        local info = TweenInfo.new(animated and 0.18 or 0)
        TweenService:Create(sw, info, {BackgroundColor3 = state and C.on or C.off}):Play()
        TweenService:Create(knob, info, {Position = state and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3)}):Play()
    end
    apply(false)

    connect(sw.Activated, function()
        state = not state
        apply(true)
        callback(state)
    end)
    -- setter externo (não dispara callback)
    return function(v) state = v and true or false apply(true) end
end

local function stepperRow(page, text, min, max, step, default, callback, fmt)
    local row = rowFrame(page)
    local value = default
    local lbl = new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -110, 1, 0),
        Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = C.text,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    }, row)
    local function refresh()
        lbl.Text = text .. ": " .. (fmt and fmt(value) or tostring(value))
    end
    refresh()

    local function mk(txt, xOff, delta)
        local b = new("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, xOff, 0.5, 0), Size = UDim2.fromOffset(30, 24),
            BackgroundColor3 = C.rowHi, Font = Enum.Font.GothamBold, Text = txt, TextSize = 16,
            TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = true,
        }, row)
        round(b, 6)
        connect(b.Activated, function()
            value = math.clamp(value + delta * step, min, max)
            refresh()
            callback(value)
        end)
    end
    mk("+", -8, 1)
    mk("-", -44, -1)
end

local function buttonRow(page, text, callback, color)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = color or C.rowHi, BorderSizePixel = 0,
        Font = Enum.Font.GothamBold, Text = text, TextSize = 13, TextColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = true, LayoutOrder = nextOrder(),
    }, page)
    round(b, 8)
    connect(b.Activated, callback)
    return b
end

local function multiButtonRow(page, defs)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = nextOrder(),
    }, page)
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, row)
    local n = #defs
    for i, d in ipairs(defs) do
        local b = new("TextButton", {
            Size = UDim2.new(1 / n, -math.ceil(6 * (n - 1) / n), 1, 0),
            BackgroundColor3 = d.color or C.rowHi, BorderSizePixel = 0, Font = Enum.Font.GothamBold,
            Text = d.text, TextSize = 13, TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = true, LayoutOrder = i,
        }, row)
        round(b, 8)
        connect(b.Activated, d.fn)
    end
end

local function inputRow(page, placeholder)
    local tb = new("TextBox", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = C.row, BorderSizePixel = 0,
        Font = Enum.Font.Gotham, Text = "", PlaceholderText = placeholder, PlaceholderColor3 = C.sub,
        TextColor3 = C.text, TextSize = 13, ClearTextOnFocus = false, LayoutOrder = nextOrder(),
    }, page)
    round(tb, 8)
    new("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, tb)
    return tb
end

----------------------------------------------------------------
-- UI: seção de música (reutilizável)
----------------------------------------------------------------
local function musicSection(page, key, title)
    local ch = getChannel(key)
    section(page, title)

    local statusRow = rowFrame(page, 26)
    local status = new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.Gotham, Text = "Parado", TextSize = 12, TextColor3 = C.sub,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    }, statusRow)
    table.insert(ch.statuses, status)

    local idBox = inputRow(page, "ID da música (somente números)")
    local nameBox = inputRow(page, "Nome (para salvar na lista)")

    multiButtonRow(page, {
        {text = "Play", color = C.on, fn = function() ch.play(idBox.Text, nil) end},
        {text = "Parar", color = C.danger, fn = function() ch.stop() end},
        {text = "+ Lista", fn = function()
            local id = idBox.Text:match("%d+")
            if not id then ch.setStatus("Digite um ID válido para adicionar") return end
            local list = store[key]
            local name = nameBox.Text ~= "" and nameBox.Text or ("Música " .. (#list + 1))
            table.insert(list, {name = name, id = id})
            saveStore()
            nameBox.Text = ""
            ch.refresh()
            ch.setStatus("Adicionada: " .. name)
        end},
    })

    stepperRow(page, "Volume", 0, 10, 1, 5, function(v) ch.sound.Volume = v / 10 end, function(v) return (v * 10) .. "%" end)
    toggleRow(page, "Repetir (loop)", false, function(v) ch.sound.Looped = v end)

    -- lista salva
    local listFrame = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        LayoutOrder = nextOrder(),
    }, page)
    new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, listFrame)

    local function refresh()
        for _, c in ipairs(listFrame:GetChildren()) do
            if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
        end
        local list = store[key]
        if #list == 0 then
            new("TextLabel", {
                Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Font = Enum.Font.Gotham,
                Text = "Lista vazia. Digite um ID e toque em + Lista.", TextSize = 12, TextColor3 = C.sub,
                TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1,
            }, listFrame)
            return
        end
        for i, item in ipairs(list) do
            local r = new("Frame", {
                Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.row, BorderSizePixel = 0, LayoutOrder = i,
            }, listFrame)
            round(r, 6)
            new("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -78, 1, 0),
                Font = Enum.Font.GothamMedium, Text = item.name, TextSize = 12, TextColor3 = C.text,
                TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
            }, r)
            local play = new("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -38, 0.5, 0), Size = UDim2.fromOffset(28, 22),
                BackgroundColor3 = C.on, Font = Enum.Font.GothamBold, Text = ">", TextSize = 14,
                TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = true,
            }, r)
            round(play, 5)
            local del = new("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.fromOffset(28, 22),
                BackgroundColor3 = C.danger, Font = Enum.Font.GothamBold, Text = "X", TextSize = 12,
                TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = true,
            }, r)
            round(del, 5)
            play.Activated:Connect(function() ch.play(item.id, item.name) end)
            del.Activated:Connect(function()
                table.remove(store[key], i)
                saveStore()
                ch.refresh()
            end)
        end
    end
    table.insert(ch.lists, refresh)
    refresh()
end

----------------------------------------------------------------
-- ABAS
----------------------------------------------------------------
----------------------------------------------------------------
-- ESCOLHA DO JOGO ("Usar no:")
----------------------------------------------------------------
local function chooseGame()
    local choice
    local bg = new("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(8, 8, 14),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    }, gui)
    local card = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(340, 210), BackgroundColor3 = C.bg, BorderSizePixel = 0,
    }, bg)
    round(card, 16)
    local cardStroke = new("UIStroke", {Thickness = 2, Color = Color3.new(1, 1, 1)}, card)
    accentGradient(cardStroke, 45)

    local title = new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 14), Size = UDim2.new(1, 0, 0, 40),
        Font = Enum.Font.GothamBlack, Text = "Usar no:", TextSize = 30, TextColor3 = Color3.new(1, 1, 1),
    }, card)
    accentGradient(title)

    local function option(text, y, value)
        local b = new("TextButton", {
            Position = UDim2.fromOffset(20, y), Size = UDim2.new(1, -40, 0, 48), BackgroundColor3 = C.rowHi,
            BorderSizePixel = 0, Font = Enum.Font.GothamBold, Text = text, TextSize = 20,
            TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = true,
        }, card)
        round(b, 10)
        b.Activated:Connect(function() choice = value end)
    end
    option("Brookhaven", 70, "brookhaven")
    option("SCP AIMBOT", 130, "scp")

    TweenService:Create(bg, TweenInfo.new(0.4), {BackgroundTransparency = 0.35}):Play()
    while not choice and gui.Parent do task.wait(0.1) end
    bg:Destroy()
    return choice
end

playIntro()
local chosenGame = chooseGame()

-- funções usadas na limpeza (definidas dentro da aba do Brookhaven)
local setCinema, stopSpectate

if chosenGame == "scp" then
    ----------------------------------------------------------------
    -- SCP AIMBOT: ESP + FPS boost + Aimbot
    ----------------------------------------------------------------
    local pScp = addTab("SCP")
    section(pScp, "Visual")
    toggleRow(pScp, "ESP (nome + distância)", false, function(v) S.esp = v end)

    section(pScp, "Desempenho")
    toggleRow(pScp, "FPS boost (gráficos baixos)", false, function(v)
        S.fpsBoost = v
        pcall(function()
            settings().Rendering.QualityLevel = v and 1 or (ORIG.quality or Enum.QualityLevel.Automatic)
        end)
    end)

    section(pScp, "AIMBOT")
    infoLabel(pScp, "Círculo fixo no centro da tela (não segue o dedo). Mira na cabeça com predição. Use “Deixa invisível?” para esconder tudo.")
    toggleRow(pScp, "AIMBOT (ligar/desligar)", false, function(v) S.aimbot = v end)
    toggleRow(pScp, "Deixa invisível?", true, function(v) S.aimbotInvis = v end)
    stepperRow(pScp, "Tamanho (FOV)", 1, 100, 1, S.aimbotFov, function(v) S.aimbotFov = v end)
    stepperRow(pScp, "Sensibilidade", 1, 10, 0.5, S.aimbotSens, function(v) S.aimbotSens = v end, function(v)
        return string.format("%.1f", v)
    end)

    -- Círculo de FOV + centro (sempre no meio da tela — NÃO segue toque)
    local fovCircle = new("Frame", {
        Name = "AimbotFovCircle",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(S.aimbotFov * 5.6, S.aimbotFov * 5.6),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 10,
    }, gui)
    local fovStroke = new("UIStroke", {
        Thickness = 1.6,
        Color = S.aimbotColor,
        Transparency = 0.25,
    }, fovCircle)
    new("UICorner", {CornerRadius = UDim.new(1, 0)}, fovCircle)

    -- Ponto central (meio do círculo)
    local centerDot = new("Frame", {
        Name = "AimbotCenter",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = S.aimbotColor,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 11,
    }, fovCircle)
    new("UICorner", {CornerRadius = UDim.new(1, 0)}, centerDot)
    local centerStroke = new("UIStroke", {
        Thickness = 1,
        Color = Color3.new(1, 1, 1),
        Transparency = 0.4,
    }, centerDot)

    -- Cruz fina no centro (mais profissional)
    local function makeCrossLine(w, h)
        local f = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(w, h),
            BackgroundColor3 = S.aimbotColor,
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0,
            ZIndex = 11,
        }, fovCircle)
        return f
    end
    local crossH = makeCrossLine(14, 1)
    local crossV = makeCrossLine(1, 14)

    -- Cores do AIMBOT (botões)
    section(pScp, "Cor do AIMBOT")
    local colorDefs = {
        {text = "Roxo",   color = Color3.fromRGB(140, 80, 255)},
        {text = "Ciano",  color = Color3.fromRGB(0, 200, 255)},
        {text = "Verde",  color = Color3.fromRGB(60, 220, 120)},
        {text = "Verm.",  color = Color3.fromRGB(255, 70, 90)},
        {text = "Branco", color = Color3.fromRGB(255, 255, 255)},
        {text = "Rosa",   color = Color3.fromRGB(255, 100, 180)},
    }
    do
        local t = {}
        for _, d in ipairs(colorDefs) do
            table.insert(t, {
                text = d.text,
                color = d.color,
                fn = function()
                    S.aimbotColor = d.color
                    fovStroke.Color = d.color
                    centerDot.BackgroundColor3 = d.color
                    crossH.BackgroundColor3 = d.color
                    crossV.BackgroundColor3 = d.color
                end,
            })
        end
        multiButtonRow(pScp, t)
    end

    connect(RunService.RenderStepped, function()
        local show = S.aimbot and not S.aimbotInvis
        fovCircle.Visible = show
        if show then
            local size = math.max(12, S.aimbotFov * 5.6)
            fovCircle.Size = UDim2.fromOffset(size, size)
            -- SEMPRE no centro da tela (não segue mouse/toque)
            fovCircle.Position = UDim2.fromScale(0.5, 0.5)
            fovStroke.Color = S.aimbotColor
            centerDot.BackgroundColor3 = S.aimbotColor
            crossH.BackgroundColor3 = S.aimbotColor
            crossV.BackgroundColor3 = S.aimbotColor
        end
    end)

    ----------------------------------------------------------------
    -- ABA: SCP TROLL
    ----------------------------------------------------------------
    local pTroll = addTab("SCP Troll")
    section(pTroll, "ESP de SCPs")
    infoLabel(pTroll, "Mostra nome + distância de SCPs detectados no mapa (096, 173, 049, 106, 682, etc.).")
    toggleRow(pTroll, "ESP SCP (todos)", false, function(v) S.scpEsp = v end)

    section(pTroll, "Aimbot em SCPs")
    infoLabel(pTroll, "Quando o AIMBOT estiver ligado, também mira em SCPs (além de jogadores).")
    toggleRow(pTroll, "Aimbot mira em SCPs", true, function(v) S.scpAimbot = v end)

    section(pTroll, "Config vida (só SCPs)")
    infoLabel(pTroll, "Só protege de SCPs (quando um SCP está perto). Jogadores matam normal. Kills 100% server-side ainda podem passar.")

    local lifeStatus = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium, Text = "Modo atual: Desligado",
        TextSize = 12, TextColor3 = C.sub, TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = nextOrder(),
    }, pTroll)

    local function setLifeMode(mode)
        S.scpLifeMode = mode
        if mode == "super" then
            lifeStatus.Text = "Modo atual: Super vida"
            lifeStatus.TextColor3 = C.danger
        elseif mode == "melhor" then
            lifeStatus.Text = "Modo atual: Melhor vida"
            lifeStatus.TextColor3 = C.on
        else
            lifeStatus.Text = "Modo atual: Desligado"
            lifeStatus.TextColor3 = C.sub
        end
    end

    buttonRow(pTroll, "Super vida", function()
        setLifeMode(S.scpLifeMode == "super" and "off" or "super")
    end, C.danger)
    infoLabel(pTroll, "Super vida: cura total na hora perto de SCP. Meio ruim — podem identificar você como hacker porque você não morre por nada do SCP.")

    buttonRow(pTroll, "Melhor vida", function()
        setLifeMode(S.scpLifeMode == "melhor" and "off" or "melhor")
    end, C.on)
    infoLabel(pTroll, "Melhor vida: regenera devagar perto de SCP. A melhor opção — parece mais natural e dificilmente vão achar que você usa hack.")

    buttonRow(pTroll, "Desligar vida", function()
        setLifeMode("off")
    end)
    buttonRow(pTroll, "Curar agora (100% vida)", function()
        local hum = getHum()
        if hum then
            hum.MaxHealth = math.max(hum.MaxHealth, 100)
            hum.Health = hum.MaxHealth
        end
    end, C.accent)
    buttonRow(pTroll, "Rescanear SCPs agora", function()
        pcall(scanSCPs)
        if refreshSCPLists then refreshSCPLists() end
    end)

    section(pTroll, "Anti-infecção")
    infoLabel(pTroll, "Tenta limpar infecções de SCP-409, 008, 016, 299 e efeitos parecidos no personagem. Não é 100% se o servidor forçar a infecção.")
    toggleRow(pTroll, "Anti-infecção (409 / 008 / etc.)", false, function(v)
        S.antiInfect = v
        if v then pcall(clearInfection) end
    end)
    buttonRow(pTroll, "Limpar infecção agora", function()
        pcall(clearInfection)
    end, C.on)

    ----------------------------------------------------------------
    -- Teleporte por categoria (Safe / Euclid / Keter)
    ----------------------------------------------------------------
    section(pTroll, "Teleporte por categoria")
    infoLabel(pTroll, "Lista os SCPs detectados separados por classe. Toque em Ir para teleportar até eles. (Apollyon não incluso)")

    local listFrames = {}
    local refreshSCPLists

    local function makeClassSection(className, accentColor)
        section(pTroll, className)
        -- botão teleportar pro mais próximo da classe
        buttonRow(pTroll, "Ir ao " .. className .. " mais próximo", function()
            pcall(scanSCPs)
            local list = getSCPsByClass(className)
            local me = getRoot()
            if not me or #list == 0 then return end
            local best, bestD
            for _, model in ipairs(list) do
                local part = getSCPPart(model)
                if part then
                    local d = (part.Position - me.Position).Magnitude
                    if not bestD or d < bestD then
                        best, bestD = model, d
                    end
                end
            end
            if best then teleportToSCP(best) end
        end, accentColor)

        local frame = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, LayoutOrder = nextOrder(),
        }, pTroll)
        new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, frame)
        listFrames[className] = frame
    end

    makeClassSection("Safe", Color3.fromRGB(60, 180, 100))
    makeClassSection("Euclid", Color3.fromRGB(220, 170, 40))
    makeClassSection("Keter", Color3.fromRGB(200, 50, 60))

    refreshSCPLists = function()
        pcall(scanSCPs)
        for className, frame in pairs(listFrames) do
            for _, c in ipairs(frame:GetChildren()) do
                if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
            end
            local list = getSCPsByClass(className)
            if #list == 0 then
                new("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham, Text = "Nenhum " .. className .. " detectado.",
                    TextSize = 12, TextColor3 = C.sub, TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = 1,
                }, frame)
            else
                for i, model in ipairs(list) do
                    local r = new("Frame", {
                        Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.row,
                        BorderSizePixel = 0, LayoutOrder = i,
                    }, frame)
                    round(r, 6)
                    local dist = "--"
                    local part = getSCPPart(model)
                    local me = getRoot()
                    if part and me then
                        dist = math.floor((part.Position - me.Position).Magnitude) .. " m"
                    end
                    new("TextLabel", {
                        BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 0),
                        Size = UDim2.new(1, -78, 1, 0), Font = Enum.Font.GothamMedium,
                        Text = model.Name .. "  (" .. dist .. ")", TextSize = 12,
                        TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                    }, r)
                    local go = new("TextButton", {
                        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0),
                        Size = UDim2.fromOffset(48, 22), BackgroundColor3 = C.on,
                        Font = Enum.Font.GothamBold, Text = "Ir", TextSize = 12,
                        TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = true,
                    }, r)
                    round(go, 5)
                    go.Activated:Connect(function()
                        teleportToSCP(model)
                    end)
                end
            end
        end
    end

    buttonRow(pTroll, "Atualizar listas de teleporte", function()
        refreshSCPLists()
    end, C.accent)

    -- atualiza listas periodicamente enquanto o menu existir
    task.spawn(function()
        while gui.Parent do
            if currentTab == "SCP Troll" then
                pcall(refreshSCPLists)
            end
            task.wait(2.5)
        end
    end)

    -- primeira carga
    task.delay(0.5, function()
        pcall(scanSCPs)
        pcall(refreshSCPLists)
    end)

    ----------------------------------------------------------------
    -- ABA: JOGADORES (combate PvP)
    ----------------------------------------------------------------
    local pPvP = addTab("Jogadores")
    section(pPvP, "Vida vs jogadores")
    infoLabel(pPvP, "Quando alguém atira em você. Funciona contra jogadores (diferente da vida só-SCP).")

    local pLifeStatus = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium, Text = "Modo atual: Desligado",
        TextSize = 12, TextColor3 = C.sub, TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = nextOrder(),
    }, pPvP)

    local function setPLifeMode(mode)
        S.pLifeMode = mode
        if mode == "super" then
            pLifeStatus.Text = "Modo atual: Super vida (PvP)"
            pLifeStatus.TextColor3 = C.danger
        elseif mode == "melhor" then
            pLifeStatus.Text = "Modo atual: Melhor vida (PvP)"
            pLifeStatus.TextColor3 = C.on
        else
            pLifeStatus.Text = "Modo atual: Desligado"
            pLifeStatus.TextColor3 = C.sub
        end
    end

    buttonRow(pPvP, "Super vida", function()
        setPLifeMode(S.pLifeMode == "super" and "off" or "super")
    end, C.danger)
    infoLabel(pPvP, "Super vida: cura total na hora. Quase imortal — podem achar que é hack.")

    buttonRow(pPvP, "Melhor vida", function()
        setPLifeMode(S.pLifeMode == "melhor" and "off" or "melhor")
    end, C.on)
    infoLabel(pPvP, "Melhor vida: regenera bem rápido quando toma tiro. Quase não sente dano — opção mais equilibrada.")

    buttonRow(pPvP, "Desligar vida PvP", function()
        setPLifeMode("off")
    end)

    section(pPvP, "Modo combate")
    infoLabel(pPvP, "Se aparecer inimigo no FOV do aimbot, atira sozinho automaticamente.")
    toggleRow(pPvP, "Modo combate (auto-tiro)", false, function(v) S.combatMode = v end)
    infoLabel(pPvP, "Usa o mesmo tamanho de FOV do AIMBOT. Ligue o AIMBOT + combate pra ficar forte.")

    section(pPvP, "Wallbang")
    infoLabel(pPvP, "Tenta fazer as balas atravessarem paredes (hook de Raycast). Depende do executor e do jogo — pode não funcionar em todos os servidores.")
    toggleRow(pPvP, "Balas atravessam parede", false, function(v)
        S.wallbang = v
        if v then setupWallbang() end
    end)

    section(pPvP, "ESP jogadores")
    toggleRow(pPvP, "ESP (nome + distância)", false, function(v) S.esp = v end)

    selectTab("SCP")
else
-- JOGADOR
local pJogador = addTab("Jogador")
section(pJogador, "Visual")
toggleRow(pJogador, "ESP (nome + distância)", false, function(v) S.esp = v end)

section(pJogador, "Movimento")
local setSpeedUI = toggleRow(pJogador, "Velocidade", false, function(v)
    S.speedOn = v
    if not v then local h = getHum() if h then h.WalkSpeed = ORIG.walk end end
end)
stepperRow(pJogador, "Valor da velocidade", 16, 150, 8, S.speed, function(v) S.speed = v end)
toggleRow(pJogador, "Super pulo", false, function(v)
    S.jumpOn = v
    if not v then local h = getHum() if h then h.JumpPower = ORIG.jump end end
end)
stepperRow(pJogador, "Valor do pulo", 50, 250, 10, S.jump, function(v) S.jump = v end)
toggleRow(pJogador, "Pulo infinito", false, function(v) S.infJump = v end)
toggleRow(pJogador, "Atravessar paredes (noclip)", false, function(v) S.noclip = v end)
flyUI = toggleRow(pJogador, "Voar", false, function(v)
    if v then
        if not startFly() then flyUI(false) end
    else
        stopFly()
    end
end)
stepperRow(pJogador, "Velocidade de voo", 20, 200, 10, S.flySpeed, function(v) S.flySpeed = v end)
toggleRow(pJogador, "Gravidade lunar", false, function(v)
    S.lunar = v
    workspace.Gravity = v and 60 or ORIG.gravity
end)

-- SISTEMA
local pSistema = addTab("Sistema")
section(pSistema, "Informações")
local statRow = rowFrame(pSistema, 30)
local statLbl = new("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0),
    Font = Enum.Font.GothamMedium, Text = "FPS: --   Ping: --", TextSize = 13, TextColor3 = C.text,
    TextXAlignment = Enum.TextXAlignment.Left,
}, statRow)

section(pSistema, "Ferramentas")
toggleRow(pSistema, "Anti-AFK", false, function(v) S.antiAfk = v end)
toggleRow(pSistema, "Iluminação total (fullbright)", false, function(v)
    S.fullbright = v
    if v then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e6
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
    else
        Lighting.Brightness = ORIG.brightness
        Lighting.ClockTime = ORIG.clock
        Lighting.FogEnd = ORIG.fogEnd
        Lighting.Ambient = ORIG.ambient
    end
end)
toggleRow(pSistema, "Modo FPS (gráficos baixos)", false, function(v)
    S.fpsBoost = v
    pcall(function()
        settings().Rendering.QualityLevel = v and 1 or (ORIG.quality or Enum.QualityLevel.Automatic)
    end)
end)
buttonRow(pSistema, "Ir para o spawn", function()
    local root = getRoot()
    local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    if root and spawn then root.CFrame = spawn.CFrame + Vector3.new(0, 5, 0) end
end)
buttonRow(pSistema, "Reentrar no servidor", function()
    pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
end)
buttonRow(pSistema, "Copiar ID do servidor", function()
    pcall(function() if setclipboard then setclipboard(game.JobId) end end)
end)

-- VEÍCULOS
local pVeic = addTab("Veículos")
section(pVeic, "Desempenho")
infoLabel(pVeic, "Entre em um veículo e ligue o turbo. Ele acelera o carro na direção em que ele já está indo.")
toggleRow(pVeic, "Turbo", false, function(v) S.turbo = v end)
stepperRow(pVeic, "Força do turbo", 1, 20, 1, S.turboBoost, function(v) S.turboBoost = v end)
stepperRow(pVeic, "Velocidade máxima", 80, 400, 20, S.turboMax, function(v) S.turboMax = v end)
buttonRow(pVeic, "Sair do veículo", function()
    local h = getHum()
    if h then h.Sit = false h:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
musicSection(pVeic, "veiculo", "Música do veículo")

-- CASAS
local pCasas = addTab("Casas")
infoLabel(pCasas, "Música separada para a casa. Ela toca em um canal próprio, independente da música geral e da do veículo.")
musicSection(pCasas, "casa", "Música da casa")

-- JOGADORES
local pPlayers = addTab("Jogadores")
section(pPlayers, "Jogador selecionado")

local selRow = rowFrame(pPlayers, 30)
local selLbl = new("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0),
    Font = Enum.Font.GothamBold, Text = "Nenhum selecionado", TextSize = 13, TextColor3 = C.text,
    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
}, selRow)
local infoLbl = infoLabel(pPlayers, "Escolha um jogador na lista abaixo.")

local function updateInfo()
    if not selPlayer or not selPlayer.Parent then
        selPlayer = nil
        selLbl.Text = "Nenhum selecionado"
        infoLbl.Text = "Escolha um jogador na lista abaixo."
        return
    end
    selLbl.Text = selPlayer.DisplayName .. " (@" .. selPlayer.Name .. ")"
    local dist = "--"
    local r = selPlayer.Character and selPlayer.Character:FindFirstChild("HumanoidRootPart")
    local me = getRoot()
    if r and me then dist = math.floor((r.Position - me.Position).Magnitude) .. " m" end
    infoLbl.Text = string.format("ID: %d\nConta: %d dias\nDistância: %s", selPlayer.UserId, selPlayer.AccountAge, dist)
end

stopSpectate = function()
    local h = getHum()
    local cam = workspace.CurrentCamera
    if h and cam then cam.CameraSubject = h end
end

local function targetRoot()
    local c = selPlayer and selPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

multiButtonRow(pPlayers, {
    {text = "Ir até ele", fn = function()
        local r, me = targetRoot(), getRoot()
        if r and me then me.CFrame = r.CFrame * CFrame.new(0, 0, 4) end
    end},
    {text = "Assistir", color = C.on, fn = function()
        local c = selPlayer and selPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local cam = workspace.CurrentCamera
        if h and cam then cam.CameraSubject = h end
    end},
    {text = "Parar", color = C.danger, fn = stopSpectate},
})
toggleRow(pPlayers, "ESP só no selecionado", false, function(v) S.espOnlySel = v end)
buttonRow(pPlayers, "Copiar nome de usuário", function()
    pcall(function()
        if selPlayer and setclipboard then setclipboard(selPlayer.Name) end
    end)
end)

section(pPlayers, "Jogadores no servidor")
local plist = new("Frame", {
    Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
    LayoutOrder = nextOrder(),
}, pPlayers)
new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, plist)

local function refreshPlayers()
    for _, c in ipairs(plist:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    local i = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            i = i + 1
            local r = new("Frame", {
                Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.row, BorderSizePixel = 0, LayoutOrder = i,
            }, plist)
            round(r, 6)
            new("TextLabel", {
                BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -90, 1, 0),
                Font = Enum.Font.GothamMedium, Text = p.DisplayName .. " (@" .. p.Name .. ")", TextSize = 12,
                TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, r)
            local pick = new("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.fromOffset(74, 22),
                BackgroundColor3 = C.accent, Font = Enum.Font.GothamBold, Text = "Selecionar", TextSize = 11,
                TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = true,
            }, r)
            round(pick, 5)
            pick.Activated:Connect(function()
                selPlayer = p
                updateInfo()
            end)
        end
    end
    if i == 0 then
        new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Font = Enum.Font.Gotham,
            Text = "Ninguém além de você no servidor.", TextSize = 12, TextColor3 = C.sub,
            TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1,
        }, plist)
    end
end
refreshPlayers()
connect(Players.PlayerAdded, function() task.delay(0.2, refreshPlayers) end)
connect(Players.PlayerRemoving, function() task.delay(0.2, refreshPlayers) end)

task.spawn(function()
    while gui.Parent do
        updateInfo()
        task.wait(0.5)
    end
end)

-- CÂMERA
local pCam = addTab("Câmera")
section(pCam, "Visão")
toggleRow(pCam, "Campo de visão personalizado", false, function(v)
    S.fovOn = v
    local cam = workspace.CurrentCamera
    if not v and cam then cam.FieldOfView = ORIG.fov end
end)
stepperRow(pCam, "Campo de visão (FOV)", 30, 120, 5, S.fov, function(v) S.fov = v end)
toggleRow(pCam, "Zoom livre (afastar bastante)", false, function(v)
    LP.CameraMaxZoomDistance = v and 10000 or ORIG.maxZoom
end)

section(pCam, "Ambiente")
stepperRow(pCam, "Hora do dia", 0, 24, 1, math.floor(ORIG.clock), function(v)
    Lighting.ClockTime = v
end)

section(pCam, "Gravação")
infoLabel(pCam, "O modo cinema esconde a interface do jogo. O menu do Felix continua visível.")
local cinemaHidden = {}
setCinema = function(v)
    S.cinema = v
    pcall(function()
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, not v)
    end)
    if v then
        for _, g in ipairs(LP.PlayerGui:GetChildren()) do
            if g:IsA("ScreenGui") and g.Enabled then
                g.Enabled = false
                table.insert(cinemaHidden, g)
            end
        end
    else
        for _, g in ipairs(cinemaHidden) do
            if g.Parent then g.Enabled = true end
        end
        cinemaHidden = {}
    end
end
toggleRow(pCam, "Modo cinema", false, setCinema)

-- LOCAIS
local pLocais = addTab("Locais")
infoLabel(pLocais, "Salve posições do mapa e volte nelas quando quiser.")
local locName = inputRow(pLocais, "Nome do local")
local refreshLocais
buttonRow(pLocais, "Salvar posição atual", function()
    local root = getRoot()
    if not root then return end
    local p = root.Position
    local name = locName.Text ~= "" and locName.Text or ("Local " .. (#store.locais + 1))
    table.insert(store.locais, {name = name, x = p.X, y = p.Y, z = p.Z})
    saveStore()
    locName.Text = ""
    refreshLocais()
end, C.on)

section(pLocais, "Locais salvos")
local locFrame = new("Frame", {
    Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
    LayoutOrder = nextOrder(),
}, pLocais)
new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, locFrame)

refreshLocais = function()
    for _, c in ipairs(locFrame:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
    end
    if #store.locais == 0 then
        new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Font = Enum.Font.Gotham,
            Text = "Nenhum local salvo.", TextSize = 12, TextColor3 = C.sub,
            TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1,
        }, locFrame)
        return
    end
    for i, loc in ipairs(store.locais) do
        local r = new("Frame", {
            Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.row, BorderSizePixel = 0, LayoutOrder = i,
        }, locFrame)
        round(r, 6)
        new("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -78, 1, 0),
            Font = Enum.Font.GothamMedium, Text = loc.name, TextSize = 12, TextColor3 = C.text,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        }, r)
        local go = new("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -38, 0.5, 0), Size = UDim2.fromOffset(28, 22),
            BackgroundColor3 = C.on, Font = Enum.Font.GothamBold, Text = "Ir", TextSize = 12,
            TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = true,
        }, r)
        round(go, 5)
        local del = new("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.fromOffset(28, 22),
            BackgroundColor3 = C.danger, Font = Enum.Font.GothamBold, Text = "X", TextSize = 12,
            TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = true,
        }, r)
        round(del, 5)
        go.Activated:Connect(function()
            local root = getRoot()
            if root then root.CFrame = CFrame.new(loc.x, loc.y + 3, loc.z) end
        end)
        del.Activated:Connect(function()
            table.remove(store.locais, i)
            saveStore()
            refreshLocais()
        end)
    end
end
refreshLocais()

-- MÚSICA
local pMusica = addTab("Música")
infoLabel(pMusica, "Cole o ID do áudio, toque em Play e use + Lista para salvar com nome. A lista fica salva entre execuções (se o executor permitir).")
musicSection(pMusica, "geral", "Música geral")
musicSection(pMusica, "casa", "Música da casa")
musicSection(pMusica, "veiculo", "Música do veículo")

selectTab("Jogador")

-- Atualiza FPS e ping
task.spawn(function()
    while gui.Parent do
        local ping = "--"
        pcall(function()
            ping = tostring(math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) .. " ms"
        end)
        statLbl.Text = string.format("FPS: %d   Ping: %s", math.floor(fpsSmooth), ping)
        task.wait(0.5)
    end
end)

end -- fim da escolha do jogo (Brookhaven)

----------------------------------------------------------------
-- BOTÃO FLUTUANTE "F" (abre/fecha) E LIMPEZA
----------------------------------------------------------------
local menuOpen = false
local function setMenu(open)
    menuOpen = open
    if open then
        main.Visible = true
        TweenService:Create(mainScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Scale = baseScale}):Play()
    else
        local t = TweenService:Create(mainScale, TweenInfo.new(0.18), {Scale = baseScale * 0.85})
        t:Play()
        t.Completed:Connect(function()
            if not menuOpen then main.Visible = false end
        end)
    end
end

local fab = new("TextButton", {
    Name = "Fab", Position = UDim2.fromOffset(14, 90), Size = UDim2.fromOffset(46, 46),
    BackgroundColor3 = Color3.fromRGB(22, 22, 40), Font = Enum.Font.GothamBlack, Text = "F",
    TextSize = 24, TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false,
}, gui)
round(fab, 23)
local fabStroke = new("UIStroke", {Thickness = 2, Color = Color3.new(1, 1, 1)}, fab)
accentGradient(fabStroke, 45)
local fabState = makeDraggable(fab, fab)
connect(fab.Activated, function()
    if fabState.moved then return end
    setMenu(not menuOpen)
end)
connect(btnMin.Activated, function() setMenu(false) end)

local function destroyAll()
    for _, c in ipairs(Conns) do pcall(function() c:Disconnect() end) end
    stopFly()
    pcall(function()
        local h = getHum()
        if h then h.WalkSpeed = ORIG.walk h.JumpPower = ORIG.jump end
        workspace.Gravity = ORIG.gravity
        Lighting.Brightness = ORIG.brightness
        Lighting.ClockTime = ORIG.clock
        Lighting.FogEnd = ORIG.fogEnd
        Lighting.Ambient = ORIG.ambient
        if ORIG.quality then settings().Rendering.QualityLevel = ORIG.quality end
        if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = ORIG.fov end
        LP.CameraMaxZoomDistance = ORIG.maxZoom
    end)
    pcall(stopSpectate)
    pcall(function() if S.cinema then setCinema(false) end end)
    for _, ch in pairs(channels) do
        pcall(function() ch.sound:Stop() ch.sound:Destroy() end)
    end
    pcall(function() gui:Destroy() end)
    pcall(function()
        local env = (getgenv and getgenv()) or _G
        env.FelixCleanup = nil
    end)
end

connect(btnClose.Activated, destroyAll)
pcall(function()
    local env = (getgenv and getgenv()) or _G
    env.FelixCleanup = destroyAll
end)

----------------------------------------------------------------
-- INÍCIO
----------------------------------------------------------------
setMenu(true)
