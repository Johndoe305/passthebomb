-- carregar biblioteca
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- serviços
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- controle do toggle
local touchToggleEnabled = false

-- janela
local Window = Fluent:CreateWindow({
    Title = "Pass The Bomb Hub💣" .. Fluent.Version,
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark"
})

local Tabs = {}

Tabs.Main = Window:AddTab({ Title = "Main", Icon = "home" })
Tabs.Player = Window:AddTab({ Title = "Player", Icon = "user" })
Tabs.Visual = Window:AddTab({ Title = "Visual", Icon = "eye" })
Tabs.Others = Window:AddTab({ Title = "Others", Icon = "star" }) -- ⭐ AQUI
Tabs.Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })


-- ===================== MAIN =====================
Tabs.Main:AddParagraph({
    Title = "scripts here",
    Content = "This is a paragraph.\nSecond line!"
})

Tabs.Main:AddButton({
    Title = "Pass The Bomb Mini Gui",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Johndoe305/PasstheBombMinigui/main/script.lua"))()
        end)
        if not success then
            warn("Erro ao executar Mini GUI:", err)
        end
    end
})

Tabs.Main:AddButton({
    Title = "Fe emote Script",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-7yd7-I-Emote-Script-48024"))()
        end)
        if not success then
            warn("Erro ao executar Mini GUI:", err)
        end
    end
})

Tabs.Main:AddButton({
    Title = "Noclip Gui",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-NOCLIP-GUI-43727"))()
        end)
        if not success then
            warn("Erro ao executar Mini GUI:", err)
        end
    end
})

Tabs.Main:AddButton({
    Title = "Dash Bomb To Player",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Johndoe305/MagneticBombScript/refs/heads/main/script.lua"))()
        end)
        if not success then
            warn("Erro ao executar Mini GUI:", err)
        end
    end
})

-- ===================== PLAYER TAB =====================

Tabs.Player:AddButton({
   Title = "Float",
   Callback = function()
       local success, err = pcall(function()
           loadstring(game:HttpGet("https://raw.githubusercontent.com/Johndoe305/Floatscript/main/script.lua"))()
       end)
       if not success then
           warn("Erro ao executar Float:", err)
       end
   end
})

-- ===================== INFINITE JUMP =====================

local UserInputService = game:GetService("UserInputService")

local infiniteJumpEnabled = false
local jumpConnection

Tabs.Player:AddToggle("InfiniteJumpToggle", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(state)
        infiniteJumpEnabled = state

        if state then
            jumpConnection = UserInputService.JumpRequest:Connect(function()
                local char = player.Character
                if not char then return end

                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if jumpConnection then
                jumpConnection:Disconnect()
                jumpConnection = nil
            end
        end
    end
})

-- ===================== HITBOX SYSTEM =====================

local hitboxEnabled = false
local hitboxScale = 0.35

local OriginalSizes = {}

local function saveOriginalSizes(char)
    OriginalSizes = {}
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            OriginalSizes[part] = {
                Size = part.Size,
                CanCollide = part.CanCollide,
                CanTouch = part.CanTouch,
                Massless = part.Massless
            }
        end
    end
end

local function applyHitbox(char)
    for part, data in pairs(OriginalSizes) do
        if part and part.Parent then
            if part.Name ~= "HumanoidRootPart" then
                part.Size = data.Size * hitboxScale
            end
            part.CanCollide = false
            part.CanTouch = false
            part.Massless = true
        end
    end
end

local function restoreHitbox()
    for part, data in pairs(OriginalSizes) do
        if part and part.Parent then
            part.Size = data.Size
            part.CanCollide = data.CanCollide
            part.CanTouch = data.CanTouch
            part.Massless = data.Massless
        end
    end
end

local function onCharacterAdded(char)
    task.wait(0.6)
    saveOriginalSizes(char)
    if hitboxEnabled then
        applyHitbox(char)
    end
end

player.CharacterAdded:Connect(onCharacterAdded)

if player.Character then
    onCharacterAdded(player.Character)
end

Tabs.Player:AddToggle("HitboxToggle", {
    Title = "Small Hitbox",
    Default = false,
    Callback = function(state)
        hitboxEnabled = state

        local char = player.Character
        if not char then return end

        if state then
            saveOriginalSizes(char)
            applyHitbox(char)
        else
            restoreHitbox()
        end
    end
})

-- ===================== VISUAL TAB =====================

-- CONTROLE
local espBombActive = false
local espObjects = {}

-- FUNÇÕES ESP
local function clearESP(tag)
    for _, v in pairs(espObjects) do
        if v and v.Parent then
            v:Destroy()
        end
    end
    table.clear(espObjects)
end

local function createESP(hrp, color, tag)
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_" .. tag
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Size = Vector3.new(4, 6, 4)
    box.Transparency = 0.4
    box.Color3 = color
    box.Parent = hrp

    table.insert(espObjects, box)
end

-- TOGGLE ESP BOMB
Tabs.Visual:AddToggle("ESPBombToggle", {
    Title = "ESP Bomb",
    Default = false,
    Callback = function(state)
        espBombActive = state
        if not state then
            clearESP("bomb")
        end
    end
})

-- LOOP ESP BOMB
task.spawn(function()
    while task.wait(1) do
        if espBombActive then
            clearESP("bomb")

            for _, p in ipairs(Players:GetPlayers()) do
                local char = Workspace:FindFirstChild(p.Name)
                if char and char:FindFirstChild("Bomb") then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        createESP(hrp, Color3.new(1, 0, 0), "bomb")
                        break -- só 1 player com bomb
                    end
                end
            end
        end
    end
end)

-- ===================== ESP PLAYER =====================

local espPlayerActive = false

Tabs.Visual:AddToggle("ESPPlayerToggle", {
    Title = "ESP Player",
    Default = false,
    Callback = function(state)
        espPlayerActive = state
        if not state then
            clearESP("player")
        end
    end
})

-- *** ESP PLAYER FUNCIONAL PARA TODOS OS PLAYERS ***
task.spawn(function()
    while task.wait(0.5) do
        if espPlayerActive then
            clearESP("player")
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then
                    local c = Workspace:FindFirstChild(p.Name)
                    if c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChild("Humanoid") then
                        if c.Humanoid.Health > 0 then
                            createESP(c.HumanoidRootPart, Color3.new(0,1,0), "player")
                        end
                    end
                end
            end
        end
    end
end)


Tabs.Others:AddButton({
    Title = "Disable Anti Cheat (Op)",
    Description = "This allows you to fly and use the speed without being restarted or kicked from the server",
    Callback = function()
        local success, err = pcall(function()
            -- Desativa / inutiliza o "Sound Handler" e scripts parecidos
 -- Coloque como LocalScript (dentro de StarterPlayerScripts ou injetado)

local player = game.Players.LocalPlayer
local rep = game:GetService("ReplicatedStorage")

-- 1. Bloqueia a remote que ele usa para denunciar
local function blockReportingRemote()
    local eventsFolder = rep:FindFirstChild("Events")
    if not eventsFolder then return end
    
    local re = eventsFolder:FindFirstChild("RE")
    if re and re:IsA("RemoteEvent") then
        -- Sobrescreve o :FireServer para não fazer nada
        re.FireServer = function() end
        re.fireServer = function() end  -- algumas pessoas escrevem errado
        print("Remote de report (RE) neutralizada")
    end
end

-- 2. Impede que o script aumente o contador de detecção
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    
    if self == player and method == "Kick" then
        print("Tentativa de kick bloqueada pelo anti-kick")
        return
    end
    
    if method == "FireServer" and tostring(self) == "RE" then
        print("Tentativa de report via RE bloqueada")
        return
    end
    
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- 3. Remove as conexões que monitoram WalkSpeed, JumpPower, BodyMovers e Swimming
local function disconnectDetectors(char)
    if not char then return end
    
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end
    
    -- Desconecta sinais que o cheat usa
    for _, conn in pairs(getconnections(hum:GetPropertyChangedSignal("WalkSpeed"))) do
        conn:Disable()
        conn:Disconnect()
    end
    
    for _, conn in pairs(getconnections(hum:GetPropertyChangedSignal("JumpPower"))) do
        conn:Disable()
        conn:Disconnect()
    end
    
    for _, conn in pairs(getconnections(hum.Swimming)) do
        conn:Disable()
        conn:Disconnect()
    end
    
    -- Remove conexões de DescendantAdded que procuram BodyMovers
    for _, conn in pairs(getconnections(char.DescendantAdded)) do
        local func = debug.getupvalue(conn.Function, 1)
        if type(func) == "function" then
            local source = debug.getinfo(func).source or ""
            if source:find("SoundHandler") or source:find("tbl_upvr") then
                conn:Disable()
                conn:Disconnect()
                print("Conexão de detecção de BodyMover removida")
            end
        end
    end
end

-- 4. Remove o script se ele já estiver rodando
for _, obj in ipairs(game:GetDescendants()) do
    if obj:IsA("LocalScript") and (obj.Name == "SoundHandler" or obj.Name:lower():find("sound")) then
        obj.Disabled = true
        obj:Destroy()
        print("Script SoundHandler encontrado e destruído")
    end
end

-- 5. Executa as proteções principais
player.CharacterAdded:Connect(disconnectDetectors)
if player.Character then
    disconnectDetectors(player.Character)
end

-- Roda logo no início
blockReportingRemote()

-- Opcional: força gravidade normal (caso o cheat tente travar)
workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
    if workspace.Gravity ~= 196.2 then
        workspace.Gravity = 196.2
    end
end)

print("Medidas anti-Sound Handler aplicadas")
            print("Botão God Mode clicado (script executaria aqui)")
        end)

        if not success then
            warn("Erro ao executar script:", err)
        end
    end
})

Tabs.Others:AddButton({
    Title = "Reactivate Anti-cheat (Rejoin)",
    Description = "If you want to reactivate the anti-cheat system, click here The script will rejoin you and reactivate the anti-cheat",
    Callback = function()
        local player = game.Players.LocalPlayer
        local TeleportService = game:GetService("TeleportService")

        TeleportService:TeleportToPlaceInstance(
            game.PlaceId,
            game.JobId,
            player
        )
    end
})

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local TELEPORT_DISTANCE = 5

local teleportJumpEnabled = false
local teleportJumpConnection

Tabs.Others:AddToggle("TeleportJumpToggle", {
    Title = "Teleport Jump",
    Description = "Every time you jump, you teleport 5 studs forward",
    Default = false,
    Callback = function(state)
        teleportJumpEnabled = state

        if state then
            teleportJumpConnection = UserInputService.JumpRequest:Connect(function()
                local char = lp.Character
                if not char then return end

                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then return end

                -- evita ativar no ar
                if hum:GetState() == Enum.HumanoidStateType.Freefall then return end

                local lookVector = hrp.CFrame.LookVector
                hrp.CFrame = hrp.CFrame + (lookVector * TELEPORT_DISTANCE)
            end)
        else
            if teleportJumpConnection then
                teleportJumpConnection:Disconnect()
                teleportJumpConnection = nil
            end
        end
    end
})

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local lp = Players.LocalPlayer

local bombPathEnabled = false
local line = Drawing.new("Line")
line.Visible = false
line.Thickness = 3
line.Color = Color3.fromRGB(255, 70, 70)
line.Transparency = 1

local lastPos = nil
local predictDistance = 30
local smoothing = 0.2

local function getBombPlayer()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            local char = plr.Character
            if char and char:FindFirstChild("Bomb") then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    return plr
                end
            end
        end
    end
    return nil
end

RunService.RenderStepped:Connect(function()
    if not bombPathEnabled then line.Visible = false lastPos = nil return end

    local bombPlayer = getBombPlayer()
    if not bombPlayer or not bombPlayer.Character then line.Visible = false lastPos = nil return end

    local hrp = bombPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then line.Visible = false lastPos = nil return end

    if not lastPos then lastPos = hrp.Position return end
    local dir = (hrp.Position - lastPos) * (1 / smoothing)
    lastPos = hrp.Position

    if dir.Magnitude < 0.1 then
        line.Visible = false
        return
    end

    local predictedPos = hrp.Position + dir.Unit * predictDistance
    local screenStart, onScreen1 = camera:WorldToViewportPoint(hrp.Position)
    local screenEnd, onScreen2 = camera:WorldToViewportPoint(predictedPos)

    if onScreen1 and onScreen2 then
        line.From = Vector2.new(screenStart.X, screenStart.Y)
        line.To = Vector2.new(screenEnd.X, screenEnd.Y)
        line.Visible = true
    else
        line.Visible = false
    end
end)

Tabs.Others:AddToggle("BombFuturePathToggle", {
    Title = "Bomb Future",
    Description = "Predicting the movement of the pump with the line",
    Default = false,
    Callback = function(state)
        bombPathEnabled = state
        if not state then
            line.Visible = false
            lastPos = nil
        end
    end
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local bombESPToggleEnabled = false
local espGui = nil
local espText = nil
local StatusValue = ReplicatedStorage:WaitForChild("Values"):WaitForChild("Status")

local function getBombPlayer()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            local char = plr.Character
            if char and char:FindFirstChild("Bomb") then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    return plr
                end
            end
        end
    end
    return nil
end

local function createESP(hrp)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BombDistanceESP"
    billboard.Adornee = hrp
    billboard.Size = UDim2.new(0, 160, 0, 45)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255,80,80)
    text.TextStrokeTransparency = 0
    text.Font = Enum.Font.GothamBold
    text.TextScaled = true
    text.Text = "💣 -- studs | --s"
    text.Parent = billboard

    billboard.Parent = hrp
    return billboard, text
end

local function removeESP()
    if espGui then
        espGui:Destroy()
        espGui = nil
        espText = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not bombESPToggleEnabled then removeESP() return end

    local myHRP = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local bombPlayer = getBombPlayer()
    if bombPlayer and bombPlayer.Character then
        local hrp = bombPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not espGui or espGui.Adornee ~= hrp then
                removeESP()
                espGui, espText = createESP(hrp)
            end

            local dist = (hrp.Position - myHRP.Position).Magnitude
            local seconds = StatusValue.Value or "--"

            espText.Text = string.format("💣 %.1f studs | %ss", dist, seconds)
        end
    else
        removeESP()
    end
end)

Tabs.Others:AddToggle("BombDistanceESP", {
    Title = "Bomb Distance Timer",
    Description = "This shows the distance to the bomb and the seconds",
    Default = false,
    Callback = function(state)
        bombESPToggleEnabled = state
        if not state then removeESP() end
    end
})

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer

--// CONFIG
local antiVoidEnabled = false
local MIN_Y = -10 -- altura mínima antes de considerar void
local BOOST = Vector3.new(0, 400, 0) -- empurrão pra cima
local cooldown = false

--// LOOP
RunService.Heartbeat:Connect(function()
    if not antiVoidEnabled or cooldown then return end

    local char = lp.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    if hrp.Position.Y <= MIN_Y then
        cooldown = true

        local bv = Instance.new("BodyVelocity")
        bv.Velocity = BOOST
        bv.MaxForce = Vector3.new(0, math.huge, 0)
        bv.P = 1250
        bv.Parent = hrp

        task.delay(0.2, function()
            if bv then bv:Destroy() end
        end)

        task.delay(0.6, function()
            cooldown = false
        end)
    end
end)

--// TOGGLE (OTHERS TAB)
Tabs.Others:AddToggle("AntiVoidPush", {
    Title = "Anti Void",
    Description = "First, activate the anti-cheat system; otherwise, the server will disconnect you or reset you",
    Default = false,
    Callback = function(state)
        antiVoidEnabled = state
    end
})

--// Botão flutuante para mobile (corrigido)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HubToggleGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local ToggleButton = Instance.new("ImageButton")
ToggleButton.Size = UDim2.fromOffset(50, 50)
ToggleButton.Position = UDim2.fromOffset(20, 20)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Image = "rbxassetid://7118978055"  -- Seu ícone
ToggleButton.Parent = ScreenGui

-- Função de toggle usando o método nativo do Fluent
local function toggleHub()
    if Window then
        Window:Minimize()  -- Isso abre e fecha o hub perfeitamente
    end
end

-- Conecta o clique
ToggleButton.MouseButton1Click:Connect(toggleHub)

-- Sistema de arrastar o botão (funciona no mobile e PC)
local dragging = false
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    ToggleButton.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
end

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateInput(input)
    end
end)

-- Opcional: Começar com o hub minimizado (só o botão visível ao injetar)
-- Window:Minimize()

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

InterfaceManager:SetFolder("SpongeHub")
SaveManager:SetFolder("SpongeHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

--remove this⬇️

-- NOTIFICAÇÃO
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Made by Old Scripts";
    Text = "Script loaded";
    Icon = "rbxassetid://288817482"; -- icone de virus so pra dar um pouco de susto kkkk
    Duration = 6;
    Button1 = "OK";
    Callback = callback;
})

-- Somzinho de carregado
task.spawn(function()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://3023237993"
    s.Volume = 0.4
    s.Parent = game:GetService("SoundService")
    s:Play()
    task.delay(3, function() s:Destroy() end)
end)

print("[loaded]")
