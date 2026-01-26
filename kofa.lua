-- KofaHVH v5.0 - Ultimate HVH Cheat Suite
-- Features: Teleport, AutoTP, Noclip, Speed, AntiKick, ESP, WallShoot, Icon Toggle
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local Plr = Players.LocalPlayer
local menuOpen = true
local currentTab = "Teleport"

-- Основные переменные
local noclipActive = false
local noclipConnection = nil
local antikickActive = false
local antikickConnection = nil
local speedHackActive = false
local speedHackConnection = nil
local autoTeleportActive = false
local autoTeleportConnection = nil
local espActive = false
local espConnection = nil
local wallshootActive = false
local wallshootConnection = nil
local espBoxes = {}
local espNames = {}
local espHealth = {}
local autoTargetPlayer = nil
local speedMultiplier = 2.0
local AUTO_TELEPORT_DISTANCE = 55
local TELEPORT_COOLDOWN = 1
local lastAutoTeleport = 0
local WALLSHOOT_RANGE = 500

-- Настройки
local settings = {
    MenuToggle = "Delete",
    TeleportNearest = "R",
    TeleportBehind = "T",
    NoclipToggle = "N",
    AntikickToggle = "K",
    SpeedHackToggle = "G",
    SpeedIncrease = "PageUp",
    SpeedDecrease = "PageDown",
    AutoTeleportToggle = "F",
    EspToggle = "H",
    WallshootToggle = "J",
    MenuScale = 1.0
}

-- ESP настройки
local espSettings = {
    BoxColor = Color3.new(1, 0, 0),
    NameColor = Color3.new(1, 1, 1),
    HealthColor = Color3.new(0, 1, 0),
    ShowBox = true,
    ShowName = true,
    ShowHealth = true,
    MaxDistance = 500
}

-- Загрузка настроек
local function loadSettings()
    pcall(function()
        if readfile and isfile and isfile("kofahvh_settings.json") then
            local data = readfile("kofahvh_settings.json")
            local loaded = HttpService:JSONDecode(data)
            for k, v in pairs(loaded) do
                if settings[k] ~= nil then
                    settings[k] = v
                end
            end
        end
    end)
    
    pcall(function()
        if readfile and isfile and isfile("kofahvh_esp.json") then
            local data = readfile("kofahvh_esp.json")
            local loaded = HttpService:JSONDecode(data)
            for k, v in pairs(loaded) do
                if espSettings[k] ~= nil then
                    if type(v) == "table" and v[1] then
                        espSettings[k] = Color3.new(v[1], v[2], v[3])
                    else
                        espSettings[k] = v
                    end
                end
            end
        end
    end)
end

-- Сохранение настроек
local function saveSettings()
    pcall(function()
        if writefile then
            writefile("kofahvh_settings.json", HttpService:JSONEncode(settings))
            
            local espToSave = {}
            for k, v in pairs(espSettings) do
                if typeof(v) == "Color3" then
                    espToSave[k] = {v.R, v.G, v.B}
                else
                    espToSave[k] = v
                end
            end
            writefile("kofahvh_esp.json", HttpService:JSONEncode(espToSave))
        end
    end)
end

loadSettings()

-- Конвертация строки в KeyCode
local function stringToKeyCode(keyString)
    local keyMap = {
        ["Delete"] = Enum.KeyCode.Delete,
        ["R"] = Enum.KeyCode.R,
        ["T"] = Enum.KeyCode.T,
        ["N"] = Enum.KeyCode.N,
        ["K"] = Enum.KeyCode.K,
        ["G"] = Enum.KeyCode.G,
        ["F"] = Enum.KeyCode.F,
        ["H"] = Enum.KeyCode.H,
        ["J"] = Enum.KeyCode.J,
        ["PageUp"] = Enum.KeyCode.PageUp,
        ["PageDown"] = Enum.KeyCode.PageDown,
        ["F1"] = Enum.KeyCode.F1,
        ["F2"] = Enum.KeyCode.F2,
        ["F3"] = Enum.KeyCode.F3,
        ["F4"] = Enum.KeyCode.F4,
        ["F5"] = Enum.KeyCode.F5,
        ["F6"] = Enum.KeyCode.F6,
        ["F7"] = Enum.KeyCode.F7,
        ["F8"] = Enum.KeyCode.F8,
        ["F9"] = Enum.KeyCode.F9,
        ["F10"] = Enum.KeyCode.F10,
        ["F11"] = Enum.KeyCode.F11,
        ["F12"] = Enum.KeyCode.F12,
        ["LeftControl"] = Enum.KeyCode.LeftControl,
        ["RightControl"] = Enum.KeyCode.RightControl,
        ["LeftShift"] = Enum.KeyCode.LeftShift,
        ["RightShift"] = Enum.KeyCode.RightShift,
        ["Space"] = Enum.KeyCode.Space,
        ["Q"] = Enum.KeyCode.Q,
        ["E"] = Enum.KeyCode.E,
        ["V"] = Enum.KeyCode.V,
        ["B"] = Enum.KeyCode.B,
        ["C"] = Enum.KeyCode.C,
        ["X"] = Enum.KeyCode.X,
        ["Z"] = Enum.KeyCode.Z,
        ["1"] = Enum.KeyCode.One,
        ["2"] = Enum.KeyCode.Two,
        ["3"] = Enum.KeyCode.Three,
        ["4"] = Enum.KeyCode.Four,
        ["5"] = Enum.KeyCode.Five
    }
    
    return keyMap[keyString] or Enum.KeyCode.Delete
end

-- ==================== ИКОНКА ДЛЯ ОТКРЫТИЯ/ЗАКРЫТИЯ ====================
local iconGui = Instance.new("ScreenGui")
iconGui.Name = "KofaHVH_Icon"
iconGui.Parent = CoreGui
iconGui.ResetOnSpawn = false

local iconFrame = Instance.new("Frame")
iconFrame.Parent = iconGui
iconFrame.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
iconFrame.BackgroundTransparency = 0.3
iconFrame.BorderSizePixel = 2
iconFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
iconFrame.Size = UDim2.new(0, 50, 0, 50)
iconFrame.Position = UDim2.new(0, 20, 0.5, -25)
iconFrame.Active = true
iconFrame.Draggable = true

local iconText = Instance.new("TextLabel")
iconText.Parent = iconFrame
iconText.BackgroundTransparency = 1
iconText.Size = UDim2.new(1, 0, 1, 0)
iconText.Text = "🔥"
iconText.TextColor3 = Color3.new(1, 1, 1)
iconText.Font = Enum.Font.GothamBold
iconText.TextSize = 24

local iconStatus = Instance.new("TextLabel")
iconStatus.Parent = iconFrame
iconStatus.BackgroundTransparency = 1
iconStatus.Size = UDim2.new(1, 0, 0, 12)
iconStatus.Position = UDim2.new(0, 0, 1, 2)
iconStatus.Text = "KofaHVH"
iconStatus.TextColor3 = Color3.new(1, 1, 1)
iconStatus.Font = Enum.Font.Gotham
iconStatus.TextSize = 10

iconFrame.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    if screenGui then
        screenGui.Enabled = menuOpen
    end
    iconFrame.BackgroundColor3 = menuOpen and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    iconStatus.Text = menuOpen and "OPEN" or "CLOSED"
end)

-- Функции ESP
local function createESP(player)
    if not player or player == Plr then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = espSettings.BoxColor
    box.Thickness = 2
    box.Filled = false
    espBoxes[player] = box
    
    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = espSettings.NameColor
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.Text = player.Name
    espNames[player] = name
    
    local health = Drawing.new("Text")
    health.Visible = false
    health.Color = espSettings.HealthColor
    health.Size = 12
    health.Center = true
    health.Outline = true
    espHealth[player] = health
end

local function removeESP(player)
    if espBoxes[player] then
        espBoxes[player]:Remove()
        espBoxes[player] = nil
    end
    if espNames[player] then
        espNames[player]:Remove()
        espNames[player] = nil
    end
    if espHealth[player] then
        espHealth[player]:Remove()
        espHealth[player] = nil
    end
end

local function updateESP()
    if not espActive then return end
    
    for player, box in pairs(espBoxes) do
        local char = player.Character
        local myChar = Plr.Character
        local myHead = myChar and myChar:FindFirstChild("Head")
        
        if char and myHead then
            local head = char:FindFirstChild("Head")
            local humanoid = char:FindFirstChild("Humanoid")
            
            if head and humanoid then
                local distance = (head.Position - myHead.Position).Magnitude
                
                if distance <= espSettings.MaxDistance then
                    local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                    
                    if onScreen then
                        local height = math.clamp(1000 / distance, 10, 50)
                        local width = height * 0.6
                        
                        if espSettings.ShowBox then
                            box.Size = Vector2.new(width, height)
                            box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                            box.Visible = true
                            box.Color = espSettings.BoxColor
                        else
                            box.Visible = false
                        end
                        
                        if espSettings.ShowName then
                            espNames[player].Position = Vector2.new(pos.X, pos.Y - height/2 - 15)
                            espNames[player].Visible = true
                            espNames[player].Color = espSettings.NameColor
                        else
                            espNames[player].Visible = false
                        end
                        
                        if espSettings.ShowHealth then
                            local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                            espHealth[player].Text = healthPercent .. "%"
                            espHealth[player].Position = Vector2.new(pos.X, pos.Y + height/2 + 5)
                            espHealth[player].Visible = true
                            
                            if healthPercent > 70 then
                                espHealth[player].Color = Color3.new(0, 1, 0)
                            elseif healthPercent > 30 then
                                espHealth[player].Color = Color3.new(1, 1, 0)
                            else
                                espHealth[player].Color = Color3.new(1, 0, 0)
                            end
                        else
                            espHealth[player].Visible = false
                        end
                    else
                        box.Visible = false
                        espNames[player].Visible = false
                        espHealth[player].Visible = false
                    end
                else
                    box.Visible = false
                    espNames[player].Visible = false
                    espHealth[player].Visible = false
                end
            else
                box.Visible = false
                espNames[player].Visible = false
                espHealth[player].Visible = false
            end
        else
            box.Visible = false
            espNames[player].Visible = false
            espHealth[player].Visible = false
        end
    end
end

local function toggleESP()
    espActive = not espActive
    
    if espActive then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Plr then
                createESP(player)
            end
        end
        
        espConnection = RunService.RenderStepped:Connect(updateESP)
        
        Players.PlayerAdded:Connect(function(player)
            createESP(player)
        end)
        
        Players.PlayerRemoving:Connect(function(player)
            removeESP(player)
        end)
    else
        for player, _ in pairs(espBoxes) do
            removeESP(player)
        end
        
        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end
    end
end

-- ==================== WALLSHOOT (СТРЕЛЬБА СКВОЗЬ СТЕНЫ) ====================
local function getClosestPlayer()
    local myChar = Plr.Character
    if not myChar then return nil end
    
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Plr and player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local distance = (targetHRP.Position - myHRP.Position).Magnitude
                if distance < closestDistance and distance <= WALLSHOOT_RANGE then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer, closestDistance
end

local function simulateShootThroughWalls()
    local closestPlayer, distance = getClosestPlayer()
    if not closestPlayer or not closestPlayer.Character then return end
    
    local targetChar = closestPlayer.Character
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local humanoid = targetChar:FindFirstChild("Humanoid")
    
    if not targetHRP or not humanoid then return end
    
    -- Создаем визуальный эффект выстрела
    local bulletTracer = Instance.new("Part")
    bulletTracer.Size = Vector3.new(0.1, 0.1, distance)
    bulletTracer.Color = Color3.new(1, 0, 0)
    bulletTracer.Material = Enum.Material.Neon
    bulletTracer.Transparency = 0.3
    bulletTracer.Anchored = true
    bulletTracer.CanCollide = false
    bulletTracer.CFrame = CFrame.new(Plr.Character.Head.Position, targetHRP.Position) * 
                         CFrame.new(0, 0, -distance/2)
    bulletTracer.Parent = Workspace
    
    -- Наносим урон
    humanoid:TakeDamage(25)
    
    -- Удаляем трассер через секунду
    game:GetService("Debris"):AddItem(bulletTracer, 1)
end

local function toggleWallshoot()
    wallshootActive = not wallshootActive
    
    if wallshootActive then
        wallshootConnection = RunService.Heartbeat:Connect(function()
            if not wallshootActive then return end
            
            local myChar = Plr.Character
            if not myChar then return end
            
            local tool = myChar:FindFirstChildOfClass("Tool")
            if tool then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    -- Перехватываем выстрелы
                    for _, remote in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                        if remote:IsA("RemoteEvent") then
                            local name = remote.Name:lower()
                            if name:find("fire") or name:find("shoot") or name:find("bullet") then
                                local oldFire = remote.FireServer
                                remote.FireServer = function(self, ...)
                                    -- Имитируем выстрел сквозь стены
                                    simulateShootThroughWalls()
                                    return oldFire(self, ...)
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        if wallshootConnection then
            wallshootConnection:Disconnect()
            wallshootConnection = nil
        end
    end
end

-- ИСПРАВЛЕННЫЙ AntiKick
local function toggleAntikick()
    antikickActive = not antikickActive
    
    if antikickActive then
        antikickConnection = RunService.Heartbeat:Connect(function()
            if not antikickActive then return end
            
            local replicatedStorage = game:GetService("ReplicatedStorage")
            if not replicatedStorage then return end
            
            local dangerousEvents = {}
            
            local function checkForKickEvents(parent)
                for _, child in pairs(parent:GetChildren()) do
                    if child:IsA("RemoteEvent") then
                        local name = child.Name:lower()
                        if name:find("kick") or name:find("ban") or name:find("punish") then
                            table.insert(dangerousEvents, child)
                        end
                    end
                    if #parent:GetChildren() < 50 then
                        checkForKickEvents(child)
                    end
                end
            end
            
            checkForKickEvents(replicatedStorage)
            checkForKickEvents(game:GetService("Players"))
            
            for _, event in pairs(dangerousEvents) do
                local oldFire = event.FireServer
                if oldFire then
                    event.FireServer = function(self, ...)
                        warn("[KofaHVH] Blocked kick attempt from:", event.Name)
                        return nil
                    end
                end
            end
        end)
    else
        if antikickConnection then
            antikickConnection:Disconnect()
            antikickConnection = nil
        end
    end
end

-- GUI с масштабированием
local baseWidth = 400
local baseHeight = 550
local scale = settings.MenuScale

screenGui = Instance.new("ScreenGui")
screenGui.Name = "KofaHVH_Menu_v5"
screenGui.Parent = CoreGui
screenGui.Enabled = menuOpen

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0.6, 0, 0.1, 0)
mainFrame.Size = UDim2.new(0, baseWidth * scale, 0, baseHeight * scale)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = menuOpen

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Parent = mainFrame
titleBar.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
titleBar.BorderSizePixel = 0
titleBar.Size = UDim2.new(1, 0, 0, 50 * scale)

local title = Instance.new("TextLabel")
title.Parent = titleBar
title.BackgroundTransparency = 1
title.Size = UDim2.new(0.8, 0, 1, 0)
title.Position = UDim2.new(0.1, 0, 0, 0)
title.Font = Enum.Font.GothamBold
title.Text = "🔥 KofaHVH v5.0"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 22 * scale

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.BackgroundTransparency = 1
closeBtn.Size = UDim2.new(0, 40 * scale, 0, 40 * scale)
closeBtn.Position = UDim2.new(1, -45 * scale, 0.5, -20 * scale)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 30 * scale

-- Вкладки (добавили Wallshoot)
local tabsFrame = Instance.new("Frame")
tabsFrame.Parent = mainFrame
tabsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
tabsFrame.BorderSizePixel = 0
tabsFrame.Size = UDim2.new(1, 0, 0, 40 * scale)
tabsFrame.Position = UDim2.new(0, 0, 0, 55 * scale)

local tabs = {}
local tabNames = {"Teleport", "AutoTP", "Noclip", "Speed", "AntiKick", "ESP", "Wallshoot", "Settings"}
local tabWidth = 1 / #tabNames

for i, tabName in ipairs(tabNames) do
    local tab = Instance.new("TextButton")
    tab.Parent = tabsFrame
    tab.Size = UDim2.new(tabWidth, 0, 1, 0)
    tab.Position = UDim2.new((i-1) * tabWidth, 0, 0, 0)
    tab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tab.Text = tabName:upper()
    tab.TextColor3 = Color3.new(1, 1, 1)
    tab.Font = Enum.Font.GothamBold
    tab.TextSize = 10 * scale
    tab.Name = tabName
    
    if tabName == "Teleport" then
        tab.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    end
    
    tabs[tabName] = tab
end

-- Контент фрейм
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Parent = mainFrame
contentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
contentFrame.BorderSizePixel = 0
contentFrame.Size = UDim2.new(1, 0, 0, 455 * scale)
contentFrame.Position = UDim2.new(0, 0, 0, 100 * scale)

-- Функция обновления размеров
local function updateMenuSize(newScale)
    scale = newScale
    settings.MenuScale = newScale
    
    mainFrame.Size = UDim2.new(0, baseWidth * scale, 0, baseHeight * scale)
    titleBar.Size = UDim2.new(1, 0, 0, 50 * scale)
    title.TextSize = 22 * scale
    closeBtn.Size = UDim2.new(0, 40 * scale, 0, 40 * scale)
    closeBtn.Position = UDim2.new(1, -45 * scale, 0.5, -20 * scale)
    closeBtn.TextSize = 30 * scale
    tabsFrame.Size = UDim2.new(1, 0, 0, 40 * scale)
    tabsFrame.Position = UDim2.new(0, 0, 0, 55 * scale)
    contentFrame.Size = UDim2.new(1, 0, 0, 455 * scale)
    contentFrame.Position = UDim2.new(0, 0, 0, 100 * scale)
    
    for _, tab in pairs(tabs) do
        tab.TextSize = 10 * scale
    end
    
    saveSettings()
end

-- ==================== WALLSHOOT ВКЛАДКА ====================
local wallshootContent = Instance.new("Frame")
wallshootContent.Name = "WallshootContent"
wallshootContent.Parent = contentFrame
wallshootContent.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
wallshootContent.BorderSizePixel = 0
wallshootContent.Size = UDim2.new(1, 0, 1, 0)
wallshootContent.Visible = false

local wallshootTitle = Instance.new("TextLabel")
wallshootTitle.Parent = wallshootContent
wallshootTitle.Size = UDim2.new(0.9, 0, 0, 40 * scale)
wallshootTitle.Position = UDim2.new(0.05, 0, 0.05, 0)
wallshootTitle.BackgroundTransparency = 1
wallshootTitle.Text = "WALLSHOOT SYSTEM"
wallshootTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
wallshootTitle.Font = Enum.Font.GothamBold
wallshootTitle.TextSize = 22 * scale

local wallshootStatus = Instance.new("TextLabel")
wallshootStatus.Parent = wallshootContent
wallshootStatus.Size = UDim2.new(0.9, 0, 0, 25 * scale)
wallshootStatus.Position = UDim2.new(0.05, 0, 0.15, 0)
wallshootStatus.BackgroundTransparency = 1
wallshootStatus.Text = "Status: OFF | Bind: " .. settings.WallshootToggle
wallshootStatus.TextColor3 = Color3.new(1, 0.5, 0.5)
wallshootStatus.Font = Enum.Font.Gotham
wallshootStatus.TextSize = 16 * scale

local wallshootToggleBtn = Instance.new("TextButton")
wallshootToggleBtn.Parent = wallshootContent
wallshootToggleBtn.Size = UDim2.new(0.9, 0, 0, 50 * scale)
wallshootToggleBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
wallshootToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
wallshootToggleBtn.Text = "ENABLE WALLSHOOT (" .. settings.WallshootToggle .. ")"
wallshootToggleBtn.TextColor3 = Color3.new(1, 1, 1)
wallshootToggleBtn.Font = Enum.Font.GothamBold
wallshootToggleBtn.TextSize = 18 * scale

local wallshootInfo = Instance.new("TextLabel")
wallshootInfo.Parent = wallshootContent
wallshootInfo.Size = UDim2.new(0.9, 0, 0, 150 * scale)
wallshootInfo.Position = UDim2.new(0.05, 0, 0.4, 0)
wallshootInfo.BackgroundTransparency = 1
wallshootInfo.Text = "Wallshoot позволяет стрелять сквозь стены.\n\n• Стреляет по ближайшему игроку\n• Дистанция: " .. WALLSHOOT_RANGE .. " studs\n• Урон: 25 HP за выстрел\n• Красные трассеры показывают выстрелы\n\nВключайте когда нужно стрелять сквозь укрытия."
wallshootInfo.TextColor3 = Color3.new(0.8, 0.8, 1)
wallshootInfo.Font = Enum.Font.Gotham
wallshootInfo.TextSize = 14 * scale
wallshootInfo.TextWrapped = true

wallshootToggleBtn.MouseButton1Click:Connect(toggleWallshoot)

-- ==================== ТЕЛЕПОРТ ВКЛАДКА ====================
local teleportContent = Instance.new("ScrollingFrame")
teleportContent.Name = "TeleportContent"
teleportContent.Parent = contentFrame
teleportContent.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
teleportContent.BorderSizePixel = 0
teleportContent.Size = UDim2.new(1, 0, 1, 0)
teleportContent.CanvasSize = UDim2.new(0, 0, 0, 500)
teleportContent.ScrollBarThickness = 6
teleportContent.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 0)
teleportContent.Visible = true

-- ... [остальной код телепорта как в предыдущей версии] ...

-- ==================== ОБЩИЕ ФУНКЦИИ ====================
-- Переключение вкладок
local function switchTab(tabName)
    currentTab = tabName
    
    for _, tab in pairs(tabs) do
        tab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    end
    
    teleportContent.Visible = false
    autoTPContent.Visible = false
    noclipContent.Visible = false
    speedContent.Visible = false
    antikickContent.Visible = false
    espContent.Visible = false
    wallshootContent.Visible = false
    settingsContent.Visible = false
    
    if tabName == "Teleport" then
        tabs.Teleport.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        teleportContent.Visible = true
        updateTeleportList()
    elseif tabName == "AutoTP" then
        tabs.AutoTP.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        autoTPContent.Visible = true
        updateAutoTPList()
    elseif tabName == "Noclip" then
        tabs.Noclip.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        noclipContent.Visible = true
    elseif tabName == "Speed" then
        tabs.Speed.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        speedContent.Visible = true
    elseif tabName == "AntiKick" then
        tabs.AntiKick.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        antikickContent.Visible = true
    elseif tabName == "ESP" then
        tabs.ESP.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        espContent.Visible = true
    elseif tabName == "Wallshoot" then
        tabs.Wallshoot.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        wallshootContent.Visible = true
    elseif tabName == "Settings" then
        tabs.Settings.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        settingsContent.Visible = true
    end
end

-- Обработчики вкладок
for name, tab in pairs(tabs) do
    tab.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end

-- Функция Noclip
local function toggleNoclip()
    noclipActive = not noclipActive
    
    if noclipActive then
        noclipConnection = RunService.Stepped:Connect(function()
            if not noclipActive then return end
            
            local char = Plr.Character
            if char then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

-- Закрытие меню
closeBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    screenGui.Enabled = menuOpen
    iconFrame.BackgroundColor3 = menuOpen and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    iconStatus.Text = menuOpen and "OPEN" or "CLOSED"
end)

-- Горячие клавиши
UIS.InputBegan:Connect(function(input)
    local function checkBind(bindName)
        return input.KeyCode == stringToKeyCode(settings[bindName])
    end
    
    if checkBind("MenuToggle") then
        menuOpen = not menuOpen
        screenGui.Enabled = menuOpen
        iconFrame.BackgroundColor3 = menuOpen and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        iconStatus.Text = menuOpen and "OPEN" or "CLOSED"
    end
    
    if menuOpen then
        if checkBind("TeleportNearest") and currentTab == "Teleport" then
            teleportNearestBtn:Click()
        elseif checkBind("TeleportBehind") and currentTab == "Teleport" then
            teleportBehindBtn:Click()
        elseif checkBind("NoclipToggle") then
            toggleNoclip()
        elseif checkBind("AutoTeleportToggle") then
            toggleAutoTeleport()
        elseif checkBind("SpeedHackToggle") then
            toggleSpeedHack()
        elseif checkBind("AntikickToggle") then
            toggleAntikick()
        elseif checkBind("EspToggle") then
            toggleESP()
        elseif checkBind("WallshootToggle") then
            toggleWallshoot()
        end
    end
end)

-- Инициализация
switchTab("Teleport")

print("========================================")
print("🔥 KofaHVH v5.0 LOADED 🔥")
print("Added: WallShoot + Icon Toggle")
print("========================================")
print("Features:")
print("- WallShoot (стрельба сквозь стены)")
print("- Icon для открытия/закрытия (красный/зеленый)")
print("- Teleport to LIVING players only")
print("- Auto Teleport when target < 55m")
print("- ESP Box/Name/Health")
print("- Noclip, Speed Hack, AntiKick")
print("- Menu size settings")
print("- Customizable key binds")
print("========================================")
print("🔥 Icon - Click to open/close menu")
print("Delete - Toggle Menu")
print("R - Teleport to nearest LIVING player")
print("T - Teleport behind LIVING player")
print("F - Auto Teleport toggle")
print("H - ESP toggle")
print("J - Wallshoot toggle")
print("N - Noclip toggle")
print("G - Speed hack toggle")
print("K - Anti-kick toggle")
print("========================================")