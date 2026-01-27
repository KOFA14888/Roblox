-- KofaHVH v4.3 - With WallShoot + Icon Toggle
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
            
            -- Конвертируем цвета для ESP
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

-- ==================== WALLSHOOT ФУНКЦИИ ====================
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
                    simulateShootThroughWalls()
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
                        
                        -- Box ESP
                        if espSettings.ShowBox then
                            box.Size = Vector2.new(width, height)
                            box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                            box.Visible = true
                            box.Color = espSettings.BoxColor
                        else
                            box.Visible = false
                        end
                        
                        -- Name ESP
                        if espSettings.ShowName then
                            espNames[player].Position = Vector2.new(pos.X, pos.Y - height/2 - 15)
                            espNames[player].Visible = true
                            espNames[player].Color = espSettings.NameColor
                        else
                            espNames[player].Visible = false
                        end
                        
                        -- Health ESP
                        if espSettings.ShowHealth then
                            local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                            espHealth[player].Text = healthPercent .. "%"
                            espHealth[player].Position = Vector2.new(pos.X, pos.Y + height/2 + 5)
                            espHealth[player].Visible = true
                            
                            -- Цвет здоровья
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
        -- Создаем ESP для всех игроков
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Plr then
                createESP(player)
            end
        end
        
        -- Подключаем обновление
        espConnection = RunService.RenderStepped:Connect(updateESP)
        
        -- Обработчик новых игроков
        Players.PlayerAdded:Connect(function(player)
            createESP(player)
        end)
        
        Players.PlayerRemoving:Connect(function(player)
            removeESP(player)
        end)
    else
        -- Удаляем весь ESP
        for player, _ in pairs(espBoxes) do
            removeESP(player)
        end
        
        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end
    end
end

-- ИСПРАВЛЕННЫЙ AntiKick (без лагов)
local function toggleAntikick()
    antikickActive = not antikickActive
    
    if antikickActive then
        -- Включаем легкий антикик без лагов
        antikickConnection = RunService.Heartbeat:Connect(function()
            if not antikickActive then return end
            
            -- Только проверяем ReplicatedStorage (основное место для RemoteEvents)
            local replicatedStorage = game:GetService("ReplicatedStorage")
            if not replicatedStorage then return end
            
            -- Ищем ТОЛЬКО RemoteEvents с названиями связанными с киком
            local dangerousEvents = {}
            
            local function checkForKickEvents(parent)
                for _, child in pairs(parent:GetChildren()) do
                    if child:IsA("RemoteEvent") then
                        local name = child.Name:lower()
                        if name:find("kick") or name:find("ban") or name:find("punish") then
                            table.insert(dangerousEvents, child)
                        end
                    end
                    -- Рекурсивно проверяем только 1 уровень вглубь (чтобы не лагать)
                    if #parent:GetChildren() < 50 then -- Ограничение чтобы не лагать
                        checkForKickEvents(child)
                    end
                end
            end
            
            -- Проверяем только ReplicatedStorage и Players
            checkForKickEvents(replicatedStorage)
            checkForKickEvents(game:GetService("Players"))
            
            -- Блокируем найденные события
            for _, event in pairs(dangerousEvents) do
                local oldFire = event.FireServer
                if oldFire then
                    event.FireServer = function(self, ...)
                        -- Просто игнорируем вызов, не создаем лагов
                        warn("[KofaHVH] Blocked kick attempt from:", event.Name)
                        return nil
                    end
                end
            end
        end)
    else
        -- Выключаем
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

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KofaHVH_Menu_v4"
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
title.Text = "🔥 KofaHVH v4.3"
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

wallshootToggleBtn.MouseButton1Click:Connect(function()
    wallshootActive = not wallshootActive
    
    if wallshootActive then
        wallshootToggleBtn.Text = "DISABLE WALLSHOOT (" .. settings.WallshootToggle .. ")"
        wallshootToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        wallshootStatus.Text = "Status: ACTIVE | Bind: " .. settings.WallshootToggle
        wallshootStatus.TextColor3 = Color3.new(0.5, 1, 0.5)
        
        toggleWallshoot()
    else
        wallshootToggleBtn.Text = "ENABLE WALLSHOOT (" .. settings.WallshootToggle .. ")"
        wallshootToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        wallshootStatus.Text = "Status: OFF | Bind: " .. settings.WallshootToggle
        wallshootStatus.TextColor3 = Color3.new(1, 0.5, 0.5)
        
        toggleWallshoot()
    end
end)

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

local teleportTitle = Instance.new("TextLabel")
teleportTitle.Parent = teleportContent
teleportTitle.Size = UDim2.new(0.9, 0, 0, 40 * scale)
teleportTitle.Position = UDim2.new(0.05, 0, 0, 10)
teleportTitle.BackgroundTransparency = 1
teleportTitle.Text = "TELEPORT SYSTEM"
teleportTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
teleportTitle.Font = Enum.Font.GothamBold
teleportTitle.TextSize = 22 * scale

local teleportStatus = Instance.new("TextLabel")
teleportStatus.Parent = teleportContent
teleportStatus.Size = UDim2.new(0.9, 0, 0, 25 * scale)
teleportStatus.Position = UDim2.new(0.05, 0, 0, 60)
teleportStatus.BackgroundTransparency = 1
teleportStatus.Text = "Bind: " .. settings.TeleportNearest .. " - Nearest, " .. settings.TeleportBehind .. " - Behind"
teleportStatus.TextColor3 = Color3.new(0.8, 0.8, 1)
teleportStatus.Font = Enum.Font.Gotham
teleportStatus.TextSize = 14 * scale

-- Список игроков
local teleportScroll = Instance.new("ScrollingFrame")
teleportScroll.Parent = teleportContent
teleportScroll.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
teleportScroll.BorderSizePixel = 0
teleportScroll.Position = UDim2.new(0.05, 0, 0, 100)
teleportScroll.Size = UDim2.new(0.9, 0, 0, 200 * scale)
teleportScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
teleportScroll.ScrollBarThickness = 4

-- Функция проверки жив ли игрок
local function isPlayerAlive(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- Функция телепорта к живому игроку
local function teleportToLivingPlayer(targetPlayer)
    if not isPlayerAlive(targetPlayer) then
        teleportStatus.Text = targetPlayer.Name .. " is DEAD!"
        teleportStatus.TextColor3 = Color3.new(1, 0, 0)
        return false
    end
    
    local myChar = Plr.Character
    if not myChar then return false end
    
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not myHRP or not targetHRP then return false end
    
    local distance = 8
    local forwardOffset = targetHRP.CFrame.LookVector * distance
    local targetPosition = targetHRP.Position + forwardOffset + Vector3.new(0, 2, 0)
    
    myHRP.CFrame = CFrame.new(targetPosition)
    myHRP.Velocity = Vector3.new(0, 0, 0)
    
    teleportStatus.Text = "Teleported to " .. targetPlayer.Name .. " (ALIVE)"
    teleportStatus.TextColor3 = Color3.new(0, 1, 0)
    
    return true
end

-- Обновление списка игроков
local function updateTeleportList()
    for _, child in pairs(teleportScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local yOffset = 0
    local buttonHeight = 35 * scale
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Plr then
            local playerBtn = Instance.new("TextButton")
            playerBtn.Parent = teleportScroll
            playerBtn.Size = UDim2.new(1, 0, 0, buttonHeight)
            playerBtn.Position = UDim2.new(0, 0, 0, yOffset)
            playerBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            playerBtn.Text = "  " .. player.Name
            playerBtn.TextColor3 = Color3.new(1, 1, 1)
            playerBtn.Font = Enum.Font.Gotham
            playerBtn.TextSize = 14 * scale
            playerBtn.TextXAlignment = Enum.TextXAlignment.Left
            
            local distText = Instance.new("TextLabel")
            distText.Parent = playerBtn
            distText.Size = UDim2.new(0, 80 * scale, 1, 0)
            distText.Position = UDim2.new(1, -85 * scale, 0, 0)
            distText.BackgroundTransparency = 1
            distText.Text = ""
            distText.TextColor3 = Color3.new(0.8, 0.8, 0.8)
            distText.Font = Enum.Font.Gotham
            distText.TextSize = 12 * scale
            distText.TextXAlignment = Enum.TextXAlignment.Right
            
            local statusIcon = Instance.new("TextLabel")
            statusIcon.Parent = playerBtn
            statusIcon.Size = UDim2.new(0, 25 * scale, 1, 0)
            statusIcon.Position = UDim2.new(1, -115 * scale, 0, 0)
            statusIcon.BackgroundTransparency = 1
            statusIcon.Font = Enum.Font.GothamBold
            statusIcon.TextSize = 16 * scale
            
            playerBtn.MouseButton1Click:Connect(function()
                teleportToLivingPlayer(player)
            end)
            
            yOffset = yOffset + buttonHeight + 3
        end
    end
    
    teleportScroll.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Кнопки телепорта
local teleportButtons = Instance.new("Frame")
teleportButtons.Parent = teleportContent
teleportButtons.BackgroundTransparency = 1
teleportButtons.Size = UDim2.new(0.9, 0, 0, 100 * scale)
teleportButtons.Position = UDim2.new(0.05, 0, 0.7, 0)

local teleportNearestBtn = Instance.new("TextButton")
teleportNearestBtn.Parent = teleportButtons
teleportNearestBtn.Size = UDim2.new(1, 0, 0, 40 * scale)
teleportNearestBtn.Position = UDim2.new(0, 0, 0, 0)
teleportNearestBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
teleportNearestBtn.Text = "TELEPORT TO NEAREST (" .. settings.TeleportNearest .. ")"
teleportNearestBtn.TextColor3 = Color3.new(1, 1, 1)
teleportNearestBtn.Font = Enum.Font.GothamBold
teleportNearestBtn.TextSize = 16 * scale

local teleportBehindBtn = Instance.new("TextButton")
teleportBehindBtn.Parent = teleportButtons
teleportBehindBtn.Size = UDim2.new(1, 0, 0, 40 * scale)
teleportBehindBtn.Position = UDim2.new(0, 0, 0, 50 * scale)
teleportBehindBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
teleportBehindBtn.Text = "TELEPORT BEHIND (" .. settings.TeleportBehind .. ")"
teleportBehindBtn.TextColor3 = Color3.new(1, 1, 1)
teleportBehindBtn.Font = Enum.Font.GothamBold
teleportBehindBtn.TextSize = 16 * scale

-- ==================== AUTO TELEPORT ВКЛАДКА ====================
local autoTPContent = Instance.new("Frame")
autoTPContent.Name = "AutoTPContent"
autoTPContent.Parent = contentFrame
autoTPContent.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
autoTPContent.BorderSizePixel = 0
autoTPContent.Size = UDim2.new(1, 0, 1, 0)
autoTPContent.Visible = false

local autoTPTitle = Instance.new("TextLabel")
autoTPTitle.Parent = autoTPContent
autoTPTitle.Size = UDim2.new(0.9, 0, 0, 40 * scale)
autoTPTitle.Position = UDim2.new(0.05, 0, 0.05, 0)
autoTPTitle.BackgroundTransparency = 1
autoTPTitle.Text = "AUTO TELEPORT SYSTEM"
autoTPTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
autoTPTitle.Font = Enum.Font.GothamBold
autoTPTitle.TextSize = 22 * scale

local autoTPStatus = Instance.new("TextLabel")
autoTPStatus.Parent = autoTPContent
autoTPStatus.Size = UDim2.new(0.9, 0, 0, 25 * scale)
autoTPStatus.Position = UDim2.new(0.05, 0, 0.15, 0)
autoTPStatus.BackgroundTransparency = 1
autoTPStatus.Text = "Status: OFF | Bind: " .. settings.AutoTeleportToggle
autoTPStatus.TextColor3 = Color3.new(1, 0.5, 0.5)
autoTPStatus.Font = Enum.Font.Gotham
autoTPStatus.TextSize = 16 * scale

-- Кнопка Auto Teleport
local autoTPToggleBtn = Instance.new("TextButton")
autoTPToggleBtn.Parent = autoTPContent
autoTPToggleBtn.Size = UDim2.new(0.9, 0, 0, 50 * scale)
autoTPToggleBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
autoTPToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
autoTPToggleBtn.Text = "ENABLE AUTO TELEPORT (" .. settings.AutoTeleportToggle .. ")"
autoTPToggleBtn.TextColor3 = Color3.new(1, 1, 1)
autoTPToggleBtn.Font = Enum.Font.GothamBold
autoTPToggleBtn.TextSize = 18 * scale

-- Список для выбора цели AutoTP
local autoTPList = Instance.new("ScrollingFrame")
autoTPList.Parent = autoTPContent
autoTPList.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
autoTPList.BorderSizePixel = 0
autoTPList.Position = UDim2.new(0.05, 0, 0.4, 0)
autoTPList.Size = UDim2.new(0.9, 0, 0, 150 * scale)
autoTPList.CanvasSize = UDim2.new(0, 0, 0, 0)
autoTPList.ScrollBarThickness = 4

local selectedTargetText = Instance.new("TextLabel")
selectedTargetText.Parent = autoTPContent
selectedTargetText.Size = UDim2.new(0.9, 0, 0, 25 * scale)
selectedTargetText.Position = UDim2.new(0.05, 0, 0.8, 0)
selectedTargetText.BackgroundTransparency = 1
selectedTargetText.Text = "Selected: None"
selectedTargetText.TextColor3 = Color3.new(1, 1, 0.5)
selectedTargetText.Font = Enum.Font.Gotham
selectedTargetText.TextSize = 14 * scale

-- Функция Auto Teleport
local function toggleAutoTeleport()
    autoTeleportActive = not autoTeleportActive
    
    if autoTeleportActive then
        if not autoTargetPlayer then
            autoTPStatus.Text = "Select a target first!"
            autoTPStatus.TextColor3 = Color3.new(1, 1, 0)
            autoTeleportActive = false
            return
        end
        
        autoTPToggleBtn.Text = "DISABLE AUTO TELEPORT (" .. settings.AutoTeleportToggle .. ")"
        autoTPToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        autoTPStatus.Text = "Status: ACTIVE | Target: " .. autoTargetPlayer.Name .. " | Distance: " .. AUTO_TELEPORT_DISTANCE .. "m"
        autoTPStatus.TextColor3 = Color3.new(0.5, 1, 0.5)
        
        autoTeleportConnection = RunService.Heartbeat:Connect(function()
            if not autoTeleportActive then return end
            
            local currentTime = tick()
            if currentTime - lastAutoTeleport < TELEPORT_COOLDOWN then return end
            
            if not isPlayerAlive(autoTargetPlayer) then
                autoTPStatus.Text = "Target is DEAD! AutoTP stopped"
                autoTPStatus.TextColor3 = Color3.new(1, 0, 0)
                toggleAutoTeleport()
                return
            end
            
            local myChar = Plr.Character
            local targetChar = autoTargetPlayer.Character
            
            if not myChar or not targetChar then return end
            
            local myHRP = myChar:FindFirstChild("HumanoidRootPart")
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
            
            if not myHRP or not targetHRP then return end
            
            local distance = (targetHRP.Position - myHRP.Position).Magnitude
            
            if distance <= AUTO_TELEPORT_DISTANCE then
                local forwardOffset = targetHRP.CFrame.LookVector * 8
                local targetPosition = targetHRP.Position + forwardOffset + Vector3.new(0, 2, 0)
                
                myHRP.CFrame = CFrame.new(targetPosition)
                myHRP.Velocity = Vector3.new(0, 0, 0)
                
                lastAutoTeleport = currentTime
                autoTPStatus.Text = "Auto Teleported! Distance: " .. math.floor(distance) .. "m"
                autoTPStatus.TextColor3 = Color3.new(0, 1, 1)
            else
                autoTPStatus.Text = "Waiting... Distance: " .. math.floor(distance) .. "m"
                autoTPStatus.TextColor3 = Color3.new(1, 1, 0.5)
            end
        end)
    else
        autoTPToggleBtn.Text = "ENABLE AUTO TELEPORT (" .. settings.AutoTeleportToggle .. ")"
        autoTPToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        autoTPStatus.Text = "Status: OFF | Bind: " .. settings.AutoTeleportToggle
        autoTPStatus.TextColor3 = Color3.new(1, 0.5, 0.5)
        
        if autoTeleportConnection then
            autoTeleportConnection:Disconnect()
            autoTeleportConnection = nil
        end
    end
end

autoTPToggleBtn.MouseButton1Click:Connect(toggleAutoTeleport)

-- Обновление списка для AutoTP
local function updateAutoTPList()
    for _, child in pairs(autoTPList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local yOffset = 0
    local buttonHeight = 30 * scale
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Plr then
            local playerBtn = Instance.new("TextButton")
            playerBtn.Parent = autoTPList
            playerBtn.Size = UDim2.new(1, 0, 0, buttonHeight)
            playerBtn.Position = UDim2.new(0, 0, 0, yOffset)
            playerBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            playerBtn.Text = "  " .. player.Name
            playerBtn.TextColor3 = Color3.new(1, 1, 1)
            playerBtn.Font = Enum.Font.Gotham
            playerBtn.TextSize = 13 * scale
            playerBtn.TextXAlignment = Enum.TextXAlignment.Left
            
            local statusIcon = Instance.new("TextLabel")
            statusIcon.Parent = playerBtn
            statusIcon.Size = UDim2.new(0, 20 * scale, 1, 0)
            statusIcon.Position = UDim2.new(1, -25 * scale, 0, 0)
            statusIcon.BackgroundTransparency = 1
            statusIcon.Font = Enum.Font.GothamBold
            statusIcon.TextSize = 14 * scale
            
            playerBtn.MouseButton1Click:Connect(function()
                autoTargetPlayer = player
                selectedTargetText.Text = "Selected: " .. player.Name .. " (AutoTP when <" .. AUTO_TELEPORT_DISTANCE .. "m)"
                selectedTargetText.TextColor3 = Color3.new(0.5, 1, 0.5)
                
                for _, btn in pairs(autoTPList:GetChildren()) do
                    if btn:IsA("TextButton") then
                        if btn == playerBtn then
                            btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
                        else
                            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
                        end
                    end
                end
            end)
            
            yOffset = yOffset + buttonHeight + 2
        end
    end
    
    autoTPList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- ==================== NOCLIP ВКЛАДКА ====================
local noclipContent = Instance.new("Frame")
noclipContent.Name = "NoclipContent"
noclipContent.Parent = contentFrame
noclipContent.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
noclipContent.BorderSizePixel = 0
noclipContent.Size = UDim2.new(1, 0, 1, 0)
noclipContent.Visible = false

local noclipTitle = Instance.new("TextLabel")
noclipTitle.Parent = noclipContent
noclipTitle.Size = UDim2.new(0.9, 0, 0, 40 * scale)
noclipTitle.Position = UDim2.new(0.05, 0, 0.05, 0)
noclipTitle.BackgroundTransparency = 1
noclipTitle.Text = "NOCLIP SYSTEM"
noclipTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
noclipTitle.Font = Enum.Font.GothamBold
noclipTitle.TextSize = 22 * scale

local noclipStatus = Instance.new("TextLabel")
noclipStatus.Parent = noclipContent
noclipStatus.Size = UDim2.new(0.9, 0, 0, 25 * scale)
noclipStatus.Position = UDim2.new(0.05, 0, 0.15, 0)
noclipStatus.BackgroundTransparency = 1
noclipStatus.Text = "Status: OFF | Bind: " .. settings.NoclipToggle
noclipStatus.TextColor3 = Color3.new(1, 0.5, 0.5)
noclipStatus.Font = Enum.Font.Gotham
noclipStatus.TextSize = 16 * scale

local noclipToggleBtn = Instance.new("TextButton")
noclipToggleBtn.Parent = noclipContent
noclipToggleBtn.Size = UDim2.new(0.9, 0, 0, 50 * scale)
noclipToggleBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
noclipToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
noclipToggleBtn.Text = "ENABLE NOCLIP (" .. settings.NoclipToggle .. ")"
noclipToggleBtn.TextColor3 = Color3.new(1, 1, 1)
noclipToggleBtn.Font = Enum.Font.GothamBold
noclipToggleBtn.TextSize = 18 * scale

-- Функция Noclip
local function toggleNoclip()
    noclipActive = not noclipActive
    
    if noclipActive then
        noclipToggleBtn.Text = "DISABLE NOCLIP (" .. settings.NoclipToggle .. ")"
        noclipToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        noclipStatus.Text = "Status: ACTIVE | Bind: " .. settings.NoclipToggle
        noclipStatus.TextColor3 = Color3.new(0.5, 1, 0.5)
        
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
        noclipToggleBtn.Text = "ENABLE NOCLIP (" .. settings.NoclipToggle .. ")"
        noclipToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        noclipStatus.Text = "Status: OFF | Bind: " .. settings.NoclipToggle
        noclipStatus.TextColor3 = Color3.new(1, 0.5, 0.5)
        
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

noclipToggleBtn.MouseButton1Click:Connect(toggleNoclip)

-- ==================== SPEED ВКЛАДКА ====================
local speedContent = Instance.new("Frame")
speedContent.Name = "SpeedContent"
speedContent.Parent = contentFrame
speedContent.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
speedContent.BorderSizePixel = 0
speedContent.Size = UDim2.new(1, 0, 1, 0)
speedContent.Visible = false

local speedTitle = Instance.new("TextLabel")
speedTitle.Parent = speedContent
speedTitle.Size = UDim2.new(0.9, 0, 0, 40 * scale)
speedTitle.Position = UDim2.new(0.05, 0, 0.05, 0)
speedTitle.BackgroundTransparency = 1
speedTitle.Text = "SPEED HACK"
speedTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
speedTitle.Font = Enum.Font.GothamBold
speedTitle.TextSize = 22 * scale

local speedStatus = Instance.new("TextLabel")
speedStatus.Parent = speedContent
speedStatus.Size = UDim2.new(0.9, 0, 0, 25 * scale)
speedStatus.Position = UDim2.new(0.05, 0, 0.15, 0)
speedStatus.BackgroundTransparency = 1
speedStatus.Text = "Status: OFF | Speed: " .. speedMultiplier .. "x | Bind: " .. settings.SpeedHackToggle
speedStatus.TextColor3 = Color3.new(1, 0.5, 0.5)
speedStatus.Font = Enum.Font.Gotham
speedStatus.TextSize = 16 * scale

local speedToggleBtn = Instance.new("TextButton")
speedToggleBtn.Parent = speedContent
speedToggleBtn.Size = UDim2.new(0.9, 0, 0, 50 * scale)
speedToggleBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
speedToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
speedToggleBtn.Text = "ENABLE SPEED HACK (" .. settings.SpeedHackToggle .. ")"
speedToggleBtn.TextColor3 = Color3.new(1, 1, 1)
speedToggleBtn.Font = Enum.Font.GothamBold
speedToggleBtn.TextSize = 18 * scale

-- Управление скоростью
local speedControl = Instance.new("Frame")
speedControl.Parent = speedContent
speedControl.BackgroundTransparency = 1
speedControl.Size = UDim2.new(0.9, 0, 0, 100 * scale)
speedControl.Position = UDim2.new(0.05, 0, 0.4, 0)

local speedDecreaseBtn = Instance.new("TextButton")
speedDecreaseBtn.Parent = speedControl
speedDecreaseBtn.Size = UDim2.new(0.45, 0, 0, 40 * scale)
speedDecreaseBtn.Position = UDim2.new(0, 0, 0, 0)
speedDecreaseBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
speedDecreaseBtn.Text = "SLOWER (" .. settings.SpeedDecrease .. ")"
speedDecreaseBtn.TextColor3 = Color3.new(1, 1, 1)
speedDecreaseBtn.Font = Enum.Font.Gotham
speedDecreaseBtn.TextSize = 14 * scale

local speedIncreaseBtn = Instance.new("TextButton")
speedIncreaseBtn.Parent = speedControl
speedIncreaseBtn.Size = UDim2.new(0.45, 0, 0, 40 * scale)
speedIncreaseBtn.Position = UDim2.new(0.55, 0, 0, 0)
speedIncreaseBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
speedIncreaseBtn.Text = "FASTER (" .. settings.SpeedIncrease .. ")"
speedIncreaseBtn.TextColor3 = Color3.new(1, 1, 1)
speedIncreaseBtn.Font = Enum.Font.Gotham
speedIncreaseBtn.TextSize = 14 * scale

local speedValueText = Instance.new("TextLabel")
speedValueText.Parent = speedControl
speedValueText.Size = UDim2.new(1, 0, 0, 40 * scale)
speedValueText.Position = UDim2.new(0, 0, 0, 50 * scale)
speedValueText.BackgroundTransparency = 1
speedValueText.Text = "Current Speed: " .. speedMultiplier .. "x"
speedValueText.TextColor3 = Color3.new(1, 1, 1)
speedValueText.Font = Enum.Font.GothamBold
speedValueText.TextSize = 18 * scale

-- Функция Speed Hack
local function toggleSpeedHack()
    speedHackActive = not speedHackActive
    
    if speedHackActive then
        speedToggleBtn.Text = "DISABLE SPEED HACK (" .. settings.SpeedHackToggle .. ")"
        speedToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        speedStatus.Text = "Status: ACTIVE | Speed: " .. speedMultiplier .. "x"
        speedStatus.TextColor3 = Color3.new(0.5, 1, 0.5)
        
        speedHackConnection = RunService.Heartbeat:Connect(function()
            if not speedHackActive then return end
            
            local char = Plr.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16 * speedMultiplier
                    humanoid.JumpPower = 50 * speedMultiplier
                end
            end
        end)
    else
        speedToggleBtn.Text = "ENABLE SPEED HACK (" .. settings.SpeedHackToggle .. ")"
        speedToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        speedStatus.Text = "Status: OFF | Speed: " .. speedMultiplier .. "x"
        speedStatus.TextColor3 = Color3.new(1, 0.5, 0.5)
        
        if speedHackConnection then
            speedHackConnection:Disconnect()
            speedHackConnection = nil
        end
        
        local char = Plr.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
                humanoid.JumpPower = 50
            end
        end
    end
end

local function changeSpeedMultiplier(delta)
    speedMultiplier = math.max(1, math.min(10, speedMultiplier + delta))
    speedValueText.Text = "Current Speed: " .. speedMultiplier .. "x"
    
    if speedHackActive then
        speedStatus.Text = "Status: ACTIVE | Speed: " .. speedMultiplier .. "x"
        local char = Plr.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16 * speedMultiplier
                humanoid.JumpPower = 50 * speedMultiplier
            end
        end
    end
end

speedToggleBtn.MouseButton1Click:Connect(toggleSpeedHack)
speedDecreaseBtn.MouseButton1Click:Connect(function() changeSpeedMultiplier(-0.5) end)
speedIncreaseBtn.MouseButton1Click:Connect(function() changeSpeedMultiplier(0.5) end)

-- ==================== ANTI-KICK ВКЛАДКА ====================
local antikickContent = Instance.new("Frame")
antikickContent.Name = "AntikickContent"
antikickContent.Parent = contentFrame
antikickContent.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
antikickContent.BorderSizePixel = 0
antikickContent.Size = UDim2.new(1, 0, 1, 0)
antikickContent.Visible = false

local antikickTitle = Instance.new("TextLabel")
antikickTitle.Parent = antikickContent
antikickTitle.Size = UDim2.new(0.9, 0, 0, 40 * scale)
antikickTitle.Position = UDim2.new(0.05, 0, 0.05, 0)
antikickTitle.BackgroundTransparency = 1
antikickTitle.Text = "ANTI-KICK PROTECTION"
antikickTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
antikickTitle.Font = Enum.Font.GothamBold
antikickTitle.TextSize = 22 * scale

local antikickStatus = Instance.new("TextLabel")
antikickStatus.Parent = antikickContent
antikickStatus.Size = UDim2.new(0.9, 0, 0, 25 * scale)
antikickStatus.Position = UDim2.new(0.05, 0, 0.15, 0)
antikickStatus.BackgroundTransparency = 1
antikickStatus.Text = "Status: OFF | Bind: " .. settings.AntikickToggle
antikickStatus.TextColor3 = Color3.new(1, 0.5, 0.5)
antikickStatus.Font = Enum.Font.Gotham
antikickStatus.TextSize = 16 * scale

local antikickToggleBtn = Instance.new("TextButton")
antikickToggleBtn.Parent = antikickContent
antikickToggleBtn.Size = UDim2.new(0.9, 0, 0, 50 * scale)
antikickToggleBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
antikickToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
antikickToggleBtn.Text = "ENABLE ANTI-KICK (" .. settings.AntikickToggle .. ")"
antikickToggleBtn.TextColor3 = Color3.new(1, 1, 1)
antikickToggleBtn.Font = Enum.Font.GothamBold
antikickToggleBtn.TextSize = 18 * scale

antikickToggleBtn.MouseButton1Click:Connect(toggleAntikick)

-- ==================== ESP ВКЛАДКА ====================
local espContent = Instance.new("ScrollingFrame")
espContent.Name = "ESPContent"
espContent.Parent = contentFrame
espContent.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
espContent.BorderSizePixel = 0
espContent.Size = UDim2.new(1, 0, 1, 0)
espContent.CanvasSize = UDim2.new(0, 0, 0, 600)
espContent.ScrollBarThickness = 6
espContent.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 0)
espContent.Visible = false

local espTitle = Instance.new("TextLabel")
espTitle.Parent = espContent
espTitle.Size = UDim2.new(0.9, 0, 0, 40 * scale)
espTitle.Position = UDim2.new(0.05, 0, 0, 10)
espTitle.BackgroundTransparency = 1
espTitle.Text = "ESP SETTINGS"
espTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
espTitle.Font = Enum.Font.GothamBold
espTitle.TextSize = 22 * scale

local espStatus = Instance.new("TextLabel")
espStatus.Parent = espContent
espStatus.Size = UDim2.new(0.9, 0, 0, 25 * scale)
espStatus.Position = UDim2.new(0.05, 0, 0, 60)
espStatus.BackgroundTransparency = 1
espStatus.Text = "Status: OFF | Bind: " .. settings.EspToggle
espStatus.TextColor3 = Color3.new(1, 0.5, 0.5)
espStatus.Font = Enum.Font.Gotham
espStatus.TextSize = 16 * scale

local espToggleBtn = Instance.new("TextButton")
espToggleBtn.Parent = espContent
espToggleBtn.Size = UDim2.new(0.9, 0, 0, 50 * scale)
espToggleBtn.Position = UDim2.new(0.05, 0, 0, 100)
espToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
espToggleBtn.Text = "ENABLE ESP (" .. settings.EspToggle .. ")"
espToggleBtn.TextColor3 = Color3.new(1, 1, 1)
espToggleBtn.Font = Enum.Font.GothamBold
espToggleBtn.TextSize = 18 * scale

-- Настройки ESP
local espSettingsFrame = Instance.new("Frame")
espSettingsFrame.Parent = espContent
espSettingsFrame.BackgroundTransparency = 1
espSettingsFrame.Size = UDim2.new(0.9, 0, 0, 300 * scale)
espSettingsFrame.Position = UDim2.new(0.05, 0, 0, 170)

local function createESPSetting(text, yPos, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Parent = espSettingsFrame
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, 0, 0, 30 * scale)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14 * scale
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Instance.new("TextButton")
    toggle.Parent = frame
    toggle.Size = UDim2.new(0.35, 0, 0.7, 0)
    toggle.Position = UDim2.new(0.65, 0, 0.15, 0)
    toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    toggle.Text = defaultValue and "ON" or "OFF"
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 14 * scale
    
    toggle.MouseButton1Click:Connect(function()
        local newValue = not defaultValue
        defaultValue = newValue
        toggle.Text = newValue and "ON" or "OFF"
        toggle.BackgroundColor3 = newValue and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        callback(newValue)
        saveSettings()
    end)
    
    return frame
end

-- Создаем настройки ESP
createESPSetting("Show Box ESP", 0, espSettings.ShowBox, function(value)
    espSettings.ShowBox = value
end)

createESPSetting("Show Name ESP", 40, espSettings.ShowName, function(value)
    espSettings.ShowName = value
end)

createESPSetting("Show Health ESP", 80, espSettings.ShowHealth, function(value)
    espSettings.ShowHealth = value
end)

-- Настройка расстояния
local distanceFrame = Instance.new("Frame")
distanceFrame.Parent = espContent
distanceFrame.BackgroundTransparency = 1
distanceFrame.Size = UDim2.new(0.9, 0, 0, 50 * scale)
distanceFrame.Position = UDim2.new(0.05, 0, 0, 500)

local distanceLabel = Instance.new("TextLabel")
distanceLabel.Parent = distanceFrame
distanceLabel.Size = UDim2.new(0.6, 0, 1, 0)
distanceLabel.Position = UDim2.new(0, 0, 0, 0)
distanceLabel.BackgroundTransparency = 1
distanceLabel.Text = "Max Distance: " .. espSettings.MaxDistance .. "m"
distanceLabel.TextColor3 = Color3.new(1, 1, 1)
distanceLabel.Font = Enum.Font.Gotham
distanceLabel.TextSize = 14 * scale
distanceLabel.TextXAlignment = Enum.TextXAlignment.Left

local distanceSlider = Instance.new("TextButton")
distanceSlider.Parent = distanceFrame
distanceSlider.Size = UDim2.new(0.35, 0, 0.5, 0)
distanceSlider.Position = UDim2.new(0.65, 0, 0.25, 0)
distanceSlider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
distanceSlider.Text = "CHANGE"
distanceSlider.TextColor3 = Color3.new(1, 1, 1)
distanceSlider.Font = Enum.Font.GothamBold
distanceSlider.TextSize = 12 * scale

distanceSlider.MouseButton1Click:Connect(function()
    espSettings.MaxDistance = espSettings.MaxDistance == 500 and 1000 or 500
    distanceLabel.Text = "Max Distance: " .. espSettings.MaxDistance .. "m"
    saveSettings()
end)

espToggleBtn.MouseButton1Click:Connect(toggleESP)

-- ==================== НАСТРОЙКИ ВКЛАДКА ====================
local settingsContent = Instance.new("ScrollingFrame")
settingsContent.Name = "SettingsContent"
settingsContent.Parent = contentFrame
settingsContent.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
settingsContent.BorderSizePixel = 0
settingsContent.Size = UDim2.new(1, 0, 1, 0)
settingsContent.CanvasSize = UDim2.new(0, 0, 0, 600)
settingsContent.Visible = false

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Parent = settingsContent
settingsTitle.Size = UDim2.new(0.9, 0, 0, 40 * scale)
settingsTitle.Position = UDim2.new(0.05, 0, 0, 10)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "KEY BIND SETTINGS"
settingsTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = 22 * scale

local keyBindings = {}
local availableKeys = {"Delete", "R", "T", "N", "K", "G", "F", "H", "J", "PageUp", "PageDown", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "Q", "E", "V", "B", "C", "X", "Z", "Space", "LeftControl", "RightControl", "LeftShift", "RightShift", "1", "2", "3", "4", "5"}

-- Создание настроек биндов
local function createBindSetting(name, displayName, yPosition)
    local frame = Instance.new("Frame")
    frame.Parent = settingsContent
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(0.9, 0, 0, 50 * scale)
    frame.Position = UDim2.new(0.05, 0, 0, yPosition)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = displayName .. ":"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16 * scale
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local currentKey = Instance.new("TextButton")
    currentKey.Parent = frame
    currentKey.Size = UDim2.new(0.35, 0, 0.7, 0)
    currentKey.Position = UDim2.new(0.65, 0, 0.15, 0)
    currentKey.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    currentKey.Text = settings[name]
    currentKey.TextColor3 = Color3.new(1, 1, 1)
    currentKey.Font = Enum.Font.GothamBold
    currentKey.TextSize = 14 * scale
    
    local waitingForInput = false
    
    currentKey.MouseButton1Click:Connect(function()
        waitingForInput = true
        currentKey.Text = "[PRESS KEY]"
        currentKey.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    end)
    
    keyBindings[name] = {
        button = currentKey,
        waiting = false
    }
    
    return frame
end

-- Создаем все настройки биндов
local bindSettingsList = {
    {"MenuToggle", "Toggle Menu", 60},
    {"TeleportNearest", "Teleport Nearest", 120},
    {"TeleportBehind", "Teleport Behind", 180},
    {"NoclipToggle", "Noclip Toggle", 240},
    {"SpeedHackToggle", "Speed Hack Toggle", 300},
    {"AntikickToggle", "Anti-Kick Toggle", 360},
    {"AutoTeleportToggle", "Auto Teleport Toggle", 420},
    {"EspToggle", "ESP Toggle", 480},
    {"WallshootToggle", "Wallshoot Toggle", 540}
}

for i, setting in ipairs(bindSettingsList) do
    createBindSetting(setting[1], setting[2], setting[3])
end

-- Настройка размера меню
local sizeFrame = Instance.new("Frame")
sizeFrame.Parent = settingsContent
sizeFrame.BackgroundTransparency = 1
sizeFrame.Size = UDim2.new(0.9, 0, 0, 80 * scale)
sizeFrame.Position = UDim2.new(0.05, 0, 0, 610)

local sizeLabel = Instance.new("TextLabel")
sizeLabel.Parent = sizeFrame
sizeLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
sizeLabel.Position = UDim2.new(0, 0, 0, 0)
sizeLabel.BackgroundTransparency = 1
sizeLabel.Text = "Menu Size: " .. settings.MenuScale .. "x"
sizeLabel.TextColor3 = Color3.new(1, 1, 1)
sizeLabel.Font = Enum.Font.Gotham
sizeLabel.TextSize = 16 * scale
sizeLabel.TextXAlignment = Enum.TextXAlignment.Left

local sizeDecreaseBtn = Instance.new("TextButton")
sizeDecreaseBtn.Parent = sizeFrame
sizeDecreaseBtn.Size = UDim2.new(0.2, 0, 0.5, 0)
sizeDecreaseBtn.Position = UDim2.new(0.6, 0, 0, 0)
sizeDecreaseBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
sizeDecreaseBtn.Text = "SMALLER"
sizeDecreaseBtn.TextColor3 = Color3.new(1, 1, 1)
sizeDecreaseBtn.Font = Enum.Font.GothamBold
sizeDecreaseBtn.TextSize = 12 * scale

local sizeIncreaseBtn = Instance.new("TextButton")
sizeIncreaseBtn.Parent = sizeFrame
sizeIncreaseBtn.Size = UDim2.new(0.2, 0, 0.5, 0)
sizeIncreaseBtn.Position = UDim2.new(0.8, 0, 0, 0)
sizeIncreaseBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
sizeIncreaseBtn.Text = "BIGGER"
sizeIncreaseBtn.TextColor3 = Color3.new(1, 1, 1)
sizeIncreaseBtn.Font = Enum.Font.GothamBold
sizeIncreaseBtn.TextSize = 12 * scale

sizeDecreaseBtn.MouseButton1Click:Connect(function()
    local newScale = math.max(0.5, settings.MenuScale - 0.1)
    updateMenuSize(newScale)
    sizeLabel.Text = "Menu Size: " .. newScale .. "x"
end)

sizeIncreaseBtn.MouseButton1Click:Connect(function()
    local newScale = math.min(2.0, settings.MenuScale + 0.1)
    updateMenuSize(newScale)
    sizeLabel.Text = "Menu Size: " .. newScale .. "x"
end)

-- Кнопка сохранения
local saveBtn = Instance.new("TextButton")
saveBtn.Parent = settingsContent
saveBtn.Size = UDim2.new(0.9, 0, 0, 50 * scale)
saveBtn.Position = UDim2.new(0.05, 0, 0, 700)
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
saveBtn.Text = "SAVE SETTINGS"
saveBtn.TextColor3 = Color3.new(1, 1, 1)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 18 * scale

saveBtn.MouseButton1Click:Connect(function()
    for name, data in pairs(keyBindings) do
        settings[name] = data.button.Text
    end
    
    saveSettings()
    
    -- Обновляем текст кнопок
    teleportNearestBtn.Text = "TELEPORT TO NEAREST (" .. settings.TeleportNearest .. ")"
    teleportBehindBtn.Text = "TELEPORT BEHIND (" .. settings.TeleportBehind .. ")"
    noclipToggleBtn.Text = "ENABLE NOCLIP (" .. settings.NoclipToggle .. ")"
    noclipStatus.Text = "Status: " .. (noclipActive and "ACTIVE" or "OFF") .. " | Bind: " .. settings.NoclipToggle
    speedToggleBtn.Text = "ENABLE SPEED HACK (" .. settings.SpeedHackToggle .. ")"
    speedStatus.Text = "Status: " .. (speedHackActive and "ACTIVE" or "OFF") .. " | Speed: " .. speedMultiplier .. "x | Bind: " .. settings.SpeedHackToggle
    speedDecreaseBtn.Text = "SLOWER (" .. settings.SpeedDecrease .. ")"
    speedIncreaseBtn.Text = "FASTER (" .. settings.SpeedIncrease .. ")"
    antikickToggleBtn.Text = "ENABLE ANTI-KICK (" .. settings.AntikickToggle .. ")"
    antikickStatus.Text = "Status: " .. (antikickActive and "ACTIVE" or "OFF") .. " | Bind: " .. settings.AntikickToggle
    autoTPToggleBtn.Text = "ENABLE AUTO TELEPORT (" .. settings.AutoTeleportToggle .. ")"
    autoTPStatus.Text = "Status: " .. (autoTeleportActive and "ACTIVE" or "OFF") .. " | Bind: " .. settings.AutoTeleportToggle
    espToggleBtn.Text = "ENABLE ESP (" .. settings.EspToggle .. ")"
    espStatus.Text = "Status: " .. (espActive and "ACTIVE" or "OFF") .. " | Bind: " .. settings.EspToggle
    wallshootToggleBtn.Text = "ENABLE WALLSHOOT (" .. settings.WallshootToggle .. ")"
    wallshootStatus.Text = "Status: " .. (wallshootActive and "ACTIVE" or "OFF") .. " | Bind: " .. settings.WallshootToggle
    teleportStatus.Text = "Bind: " .. settings.TeleportNearest .. " - Nearest, " .. settings.TeleportBehind .. " - Behind"
    
    local confirm = Instance.new("TextLabel")
    confirm.Parent = settingsContent
    confirm.Size = UDim2.new(0.9, 0, 0, 30 * scale)
    confirm.Position = UDim2.new(0.05, 0, 0, 760)
    confirm.BackgroundTransparency = 1
    confirm.Text = "✓ Settings saved!"
    confirm.TextColor3 = Color3.new(0, 1, 0)
    confirm.Font = Enum.Font.GothamBold
    confirm.TextSize = 16 * scale
    
    task.wait(2)
    confirm:Destroy()
end)

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

-- Телепорт к ближайшему живому игроку
teleportNearestBtn.MouseButton1Click:Connect(function()
    local myChar = Plr.Character
    if not myChar then return end
    
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Plr and isPlayerAlive(player) then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local distance = (targetHRP.Position - myHRP.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    if closestPlayer then
        teleportToLivingPlayer(closestPlayer)
    else
        teleportStatus.Text = "No LIVING players found!"
        teleportStatus.TextColor3 = Color3.new(1, 0, 0)
    end
end)

teleportBehindBtn.MouseButton1Click:Connect(function()
    local myChar = Plr.Character
    if not myChar then return end
    
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Plr and isPlayerAlive(player) then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local distance = (targetHRP.Position - myHRP.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    if closestPlayer then
        local targetHRP = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP then
            local behindOffset = -targetHRP.CFrame.LookVector * 5
            local targetPosition = targetHRP.Position + behindOffset + Vector3.new(0, 2, 0)
            
            myHRP.CFrame = CFrame.new(targetPosition)
            myHRP.Velocity = Vector3.new(0, 0, 0)
            
            teleportStatus.Text = "Teleported BEHIND " .. closestPlayer.Name .. " (ALIVE)"
            teleportStatus.TextColor3 = Color3.new(0.5, 1, 1)
        end
    else
        teleportStatus.Text = "No LIVING players found!"
        teleportStatus.TextColor3 = Color3.new(1, 0, 0)
    end
end)

-- Закрытие меню через крестик
closeBtn.MouseButton1Click:Connect(function()
    menuOpen = false
    screenGui.Enabled = false
    iconFrame.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    iconStatus.Text = "CLOSED"
end)

-- Функция открытия/закрытия меню
local function toggleMenu()
    menuOpen = not menuOpen
    screenGui.Enabled = menuOpen
    
    if menuOpen then
        updateTeleportList()
        iconFrame.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        iconStatus.Text = "OPEN"
    else
        iconFrame.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        iconStatus.Text = "CLOSED"
    end
end

-- Обработчик клика по иконке
iconFrame.MouseButton1Click:Connect(toggleMenu)

-- Горячие клавиши
UIS.InputBegan:Connect(function(input)
    local function checkBind(bindName)
        return input.KeyCode == stringToKeyCode(settings[bindName])
    end
    
    if checkBind("MenuToggle") then
        toggleMenu()
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
        elseif checkBind("SpeedIncrease") and speedHackActive then
            changeSpeedMultiplier(0.5)
        elseif checkBind("SpeedDecrease") and speedHackActive then
            changeSpeedMultiplier(-0.5)
        end
    end
end)

-- Обработка ввода для изменения биндов
local waitingForBind = nil
local waitingButton = nil

RunService.Heartbeat:Connect(function()
    for name, data in pairs(keyBindings) do
        if data.waiting then
            waitingForBind = name
            waitingButton = data.button
            data.waiting = false
        end
    end
    
    if waitingForBind and waitingButton then
        UIS.InputBegan:Connect(function(input)
            if input.KeyCode ~= Enum.KeyCode.Escape then
                for keyName, keyCode in pairs(Enum.KeyCode:GetEnumItems()) do
                    if keyCode.Value == input.KeyCode.Value then
                        local keyString = keyName
                        if keyString:sub(1, 3) == "One" then keyString = "1"
                        elseif keyString:sub(1, 3) == "Two" then keyString = "2"
                        elseif keyString:sub(1, 5) == "Three" then keyString = "3"
                        elseif keyString:sub(1, 4) == "Four" then keyString = "4"
                        elseif keyString:sub(1, 4) == "Five" then keyString = "5" end
                        
                        waitingButton.Text = keyString
                        waitingButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                        waitingForBind = nil
                        waitingButton = nil
                        break
                    end
                end
            end
        end)
    end
end)

-- Обновление статусов игроков
spawn(function()
    while true do
        if menuOpen then
            if currentTab == "Teleport" then
                local myChar = Plr.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                
                if myHRP then
                    for _, child in pairs(teleportScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            local playerName = child.Text:sub(3)
                            local player = Players:FindFirstChild(playerName)
                            local distText = child:FindFirstChildOfClass("TextLabel")
                            local statusIcon = child:FindFirstChild("TextLabel")
                            
                            if player and distText and statusIcon then
                                local isAlive = isPlayerAlive(player)
                                local distanceText = "---"
                                
                                if player.Character then
                                    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                                    if targetHRP and myHRP then
                                        local distance = math.floor((targetHRP.Position - myHRP.Position).Magnitude)
                                        distanceText = distance .. "m"
                                        
                                        if isAlive then
                                            if distance <= 10 then
                                                child.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
                                            elseif distance <= 30 then
                                                child.BackgroundColor3 = Color3.fromRGB(80, 80, 40)
                                            else
                                                child.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
                                            end
                                        else
                                            child.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                                        end
                                    end
                                end
                                
                                distText.Text = distanceText
                                
                                if isAlive then
                                    statusIcon.Text = "❤️"
                                    statusIcon.TextColor3 = Color3.new(0, 1, 0)
                                    child.TextColor3 = Color3.new(1, 1, 1)
                                else
                                    statusIcon.Text = "💀"
                                    statusIcon.TextColor3 = Color3.new(1, 0, 0)
                                    child.TextColor3 = Color3.new(0.5, 0.5, 0.5)
                                end
                            end
                        end
                    end
                end
            end
            
            if currentTab == "AutoTP" then
                for _, child in pairs(autoTPList:GetChildren()) do
                    if child:IsA("TextButton") then
                        local playerName = child.Text:sub(3)
                        local player = Players:FindFirstChild(playerName)
                        local statusIcon = child:FindFirstChild("TextLabel")
                        
                        if player and statusIcon then
                            if isPlayerAlive(player) then
                                statusIcon.Text = "❤️"
                                statusIcon.TextColor3 = Color3.new(0, 1, 0)
                                child.TextColor3 = Color3.new(1, 1, 1)
                            else
                                statusIcon.Text = "💀"
                                statusIcon.TextColor3 = Color3.new(1, 0, 0)
                                child.TextColor3 = Color3.new(0.5, 0.5, 0.5)
                                
                                if autoTargetPlayer == player then
                                    autoTargetPlayer = nil
                                    selectedTargetText.Text = "Selected: None (target died)"
                                    selectedTargetText.TextColor3 = Color3.new(1, 0.5, 0.5)
                                    
                                    if autoTeleportActive then
                                        toggleAutoTeleport()
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- Автообновление списков
spawn(function()
    while true do
        if menuOpen then
            if currentTab == "Teleport" then
                updateTeleportList()
            elseif currentTab == "AutoTP" then
                updateAutoTPList()
            end
        end
        task.wait(5)
    end
end)

-- Автообновление при респавне
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    if noclipActive then
        task.wait(1)
        if noclipConnection then
            noclipConnection:Disconnect()
        end
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
    end
    
    if speedHackActive then
        task.wait(1)
        if speedHackConnection then
            speedHackConnection:Disconnect()
        end
        speedHackConnection = RunService.Heartbeat:Connect(function()
            if not speedHackActive then return end
            local char = Plr.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16 * speedMultiplier
                    humanoid.JumpPower = 50 * speedMultiplier
                end
            end
        end)
    end
    
    if wallshootActive then
        task.wait(1)
        if wallshootConnection then
            wallshootConnection:Disconnect()
        end
        wallshootConnection = RunService.Heartbeat:Connect(function()
            if not wallshootActive then return end
            local myChar = Plr.Character
            if not myChar then return end
            local tool = myChar:FindFirstChildOfClass("Tool")
            if tool then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    simulateShootThroughWalls()
                end
            end
        end)
    end
end)

-- Инициализация
switchTab("Teleport")

print("========================================")
print("🔥 KofaHVH v4.3 LOADED 🔥")
print("Added WallShoot + Icon Toggle")
print("========================================")
print("Features:")
print("- WallShoot (стрельба сквозь стены)")
print("- Clickable Icon (🔥 top-left) to open/close")
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
print("J - Wallshoot toggle (NEW!)")
print("N - Noclip toggle")
print("G - Speed hack toggle")
print("K - Anti-kick toggle")
print("PageUp/PageDown - Speed control")
print("========================================")