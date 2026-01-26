-- KofaHVH - Ultimate HVH Cheat Menu
-- Version: 3.0 | Made for MirageHVH
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

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
local autoTargetPlayer = nil
local speedMultiplier = 2.0
local AUTO_TELEPORT_DISTANCE = 55
local TELEPORT_COOLDOWN = 1
local lastAutoTeleport = 0

-- Настройки биндов
local bindSettings = {
    MenuToggle = "Delete",
    TeleportNearest = "R",
    TeleportBehind = "T",
    NoclipToggle = "N",
    AntikickToggle = "K",
    SpeedHackToggle = "G",
    SpeedIncrease = "PageUp",
    SpeedDecrease = "PageDown",
    AutoTeleportToggle = "F"
}

-- Загрузка настроек
local function loadSettings()
    pcall(function()
        if readfile then
            local data = readfile("kofahvh_settings.json")
            bindSettings = HttpService:JSONDecode(data)
        end
    end)
end

-- Сохранение настроек
local function saveSettings()
    pcall(function()
        if writefile then
            local data = HttpService:JSONEncode(bindSettings)
            writefile("kofahvh_settings.json", data)
        end
    end)
end

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

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KofaHVH_Menu"
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0.6, 0, 0.1, 0)
mainFrame.Size = UDim2.new(0, 400, 0, 550)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = menuOpen

-- Заголовок KofaHVH
local titleBar = Instance.new("Frame")
titleBar.Parent = mainFrame
titleBar.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
titleBar.BorderSizePixel = 0
titleBar.Size = UDim2.new(1, 0, 0, 50)

local title = Instance.new("TextLabel")
title.Parent = titleBar
title.BackgroundTransparency = 1
title.Size = UDim2.new(0.8, 0, 1, 0)
title.Position = UDim2.new(0.1, 0, 0, 0)
title.Font = Enum.Font.GothamBold
title.Text = "🔥 KofaHVH v3.0"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 22

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.BackgroundTransparency = 1
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0.5, -20)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 30

-- Вкладки
local tabsFrame = Instance.new("Frame")
tabsFrame.Parent = mainFrame
tabsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
tabsFrame.BorderSizePixel = 0
tabsFrame.Size = UDim2.new(1, 0, 0, 40)
tabsFrame.Position = UDim2.new(0, 0, 0, 55)

local tabs = {}
local tabNames = {"Teleport", "AutoTP", "Noclip", "Speed", "AntiKick", "Settings"}
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
    tab.TextSize = 11
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
contentFrame.Size = UDim2.new(1, 0, 0, 455)
contentFrame.Position = UDim2.new(0, 0, 0, 100)

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
teleportTitle.Size = UDim2.new(0.9, 0, 0, 30)
teleportTitle.Position = UDim2.new(0.05, 0, 0, 10)
teleportTitle.BackgroundTransparency = 1
teleportTitle.Text = "TELEPORT SYSTEM"
teleportTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
teleportTitle.Font = Enum.Font.GothamBold
teleportTitle.TextSize = 18

local teleportStatus = Instance.new("TextLabel")
teleportStatus.Parent = teleportContent
teleportStatus.Size = UDim2.new(0.9, 0, 0, 25)
teleportStatus.Position = UDim2.new(0.05, 0, 0, 45)
teleportStatus.BackgroundTransparency = 1
teleportStatus.Text = "Bind: " .. bindSettings.TeleportNearest .. " - Nearest, " .. bindSettings.TeleportBehind .. " - Behind"
teleportStatus.TextColor3 = Color3.new(0.8, 0.8, 1)
teleportStatus.Font = Enum.Font.Gotham
teleportStatus.TextSize = 14

-- Список игроков
local teleportScroll = Instance.new("ScrollingFrame")
teleportScroll.Parent = teleportContent
teleportScroll.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
teleportScroll.BorderSizePixel = 0
teleportScroll.Position = UDim2.new(0.05, 0, 0, 80)
teleportScroll.Size = UDim2.new(0.9, 0, 0, 200)
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
    local buttonHeight = 35
    
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
            playerBtn.TextSize = 14
            playerBtn.TextXAlignment = Enum.TextXAlignment.Left
            
            local distText = Instance.new("TextLabel")
            distText.Parent = playerBtn
            distText.Size = UDim2.new(0, 80, 1, 0)
            distText.Position = UDim2.new(1, -85, 0, 0)
            distText.BackgroundTransparency = 1
            distText.Text = ""
            distText.TextColor3 = Color3.new(0.8, 0.8, 0.8)
            distText.Font = Enum.Font.Gotham
            distText.TextSize = 12
            distText.TextXAlignment = Enum.TextXAlignment.Right
            
            -- Статус игрока (живой/мертвый)
            local statusIcon = Instance.new("TextLabel")
            statusIcon.Parent = playerBtn
            statusIcon.Size = UDim2.new(0, 25, 1, 0)
            statusIcon.Position = UDim2.new(1, -115, 0, 0)
            statusIcon.BackgroundTransparency = 1
            statusIcon.Font = Enum.Font.GothamBold
            statusIcon.TextSize = 16
            
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
teleportButtons.Size = UDim2.new(0.9, 0, 0, 100)
teleportButtons.Position = UDim2.new(0.05, 0, 0.7, 0)

local teleportNearestBtn = Instance.new("TextButton")
teleportNearestBtn.Parent = teleportButtons
teleportNearestBtn.Size = UDim2.new(1, 0, 0, 40)
teleportNearestBtn.Position = UDim2.new(0, 0, 0, 0)
teleportNearestBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
teleportNearestBtn.Text = "TELEPORT TO NEAREST (" .. bindSettings.TeleportNearest .. ")"
teleportNearestBtn.TextColor3 = Color3.new(1, 1, 1)
teleportNearestBtn.Font = Enum.Font.GothamBold
teleportNearestBtn.TextSize = 16

local teleportBehindBtn = Instance.new("TextButton")
teleportBehindBtn.Parent = teleportButtons
teleportBehindBtn.Size = UDim2.new(1, 0, 0, 40)
teleportBehindBtn.Position = UDim2.new(0, 0, 0, 50)
teleportBehindBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
teleportBehindBtn.Text = "TELEPORT BEHIND (" .. bindSettings.TeleportBehind .. ")"
teleportBehindBtn.TextColor3 = Color3.new(1, 1, 1)
teleportBehindBtn.Font = Enum.Font.GothamBold
teleportBehindBtn.TextSize = 16

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
autoTPTitle.Size = UDim2.new(0.9, 0, 0, 40)
autoTPTitle.Position = UDim2.new(0.05, 0, 0.05, 0)
autoTPTitle.BackgroundTransparency = 1
autoTPTitle.Text = "AUTO TELEPORT SYSTEM"
autoTPTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
autoTPTitle.Font = Enum.Font.GothamBold
autoTPTitle.TextSize = 22

local autoTPStatus = Instance.new("TextLabel")
autoTPStatus.Parent = autoTPContent
autoTPStatus.Size = UDim2.new(0.9, 0, 0, 25)
autoTPStatus.Position = UDim2.new(0.05, 0, 0.15, 0)
autoTPStatus.BackgroundTransparency = 1
autoTPStatus.Text = "Status: OFF | Bind: " .. bindSettings.AutoTeleportToggle
autoTPStatus.TextColor3 = Color3.new(1, 0.5, 0.5)
autoTPStatus.Font = Enum.Font.Gotham
autoTPStatus.TextSize = 16

-- Кнопка Auto Teleport
local autoTPToggleBtn = Instance.new("TextButton")
autoTPToggleBtn.Parent = autoTPContent
autoTPToggleBtn.Size = UDim2.new(0.9, 0, 0, 50)
autoTPToggleBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
autoTPToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
autoTPToggleBtn.Text = "ENABLE AUTO TELEPORT (" .. bindSettings.AutoTeleportToggle .. ")"
autoTPToggleBtn.TextColor3 = Color3.new(1, 1, 1)
autoTPToggleBtn.Font = Enum.Font.GothamBold
autoTPToggleBtn.TextSize = 18

-- Список для выбора цели AutoTP
local autoTPList = Instance.new("ScrollingFrame")
autoTPList.Parent = autoTPContent
autoTPList.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
autoTPList.BorderSizePixel = 0
autoTPList.Position = UDim2.new(0.05, 0, 0.4, 0)
autoTPList.Size = UDim2.new(0.9, 0, 0, 150)
autoTPList.CanvasSize = UDim2.new(0, 0, 0, 0)

local selectedTargetText = Instance.new("TextLabel")
selectedTargetText.Parent = autoTPContent
selectedTargetText.Size = UDim2.new(0.9, 0, 0, 25)
selectedTargetText.Position = UDim2.new(0.05, 0, 0.8, 0)
selectedTargetText.BackgroundTransparency = 1
selectedTargetText.Text = "Selected: None"
selectedTargetText.TextColor3 = Color3.new(1, 1, 0.5)
selectedTargetText.Font = Enum.Font.Gotham
selectedTargetText.TextSize = 14

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
        
        autoTPToggleBtn.Text = "DISABLE AUTO TELEPORT (" .. bindSettings.AutoTeleportToggle .. ")"
        autoTPToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        autoTPStatus.Text = "Status: ACTIVE | Target: " .. autoTargetPlayer.Name .. " | Distance: " .. AUTO_TELEPORT_DISTANCE .. "m"
        autoTPStatus.TextColor3 = Color3.new(0.5, 1, 0.5)
        
        autoTeleportConnection = RunService.Heartbeat:Connect(function()
            if not autoTeleportActive then return end
            
            local currentTime = tick()
            if currentTime - lastAutoTeleport < TELEPORT_COOLDOWN then return end
            
            -- Проверяем что цель жива
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
            
            -- Если цель ближе 55 метров - телепортируемся
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
        autoTPToggleBtn.Text = "ENABLE AUTO TELEPORT (" .. bindSettings.AutoTeleportToggle .. ")"
        autoTPToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        autoTPStatus.Text = "Status: OFF | Bind: " .. bindSettings.AutoTeleportToggle
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
    local buttonHeight = 30
    
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
            playerBtn.TextSize = 13
            playerBtn.TextXAlignment = Enum.TextXAlignment.Left
            
            local statusIcon = Instance.new("TextLabel")
            statusIcon.Parent = playerBtn
            statusIcon.Size = UDim2.new(0, 20, 1, 0)
            statusIcon.Position = UDim2.new(1, -25, 0, 0)
            statusIcon.BackgroundTransparency = 1
            statusIcon.Font = Enum.Font.GothamBold
            statusIcon.TextSize = 14
            
            playerBtn.MouseButton1Click:Connect(function()
                autoTargetPlayer = player
                selectedTargetText.Text = "Selected: " .. player.Name .. " (AutoTP when <" .. AUTO_TELEPORT_DISTANCE .. "m)"
                selectedTargetText.TextColor3 = Color3.new(0.5, 1, 0.5)
                
                -- Выделяем выбранного
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

-- ==================== SPEED ВКЛАДКА ====================
local speedContent = Instance.new("Frame")
speedContent.Name = "SpeedContent"
speedContent.Parent = contentFrame
speedContent.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
speedContent.BorderSizePixel = 0
speedContent.Size = UDim2.new(1, 0, 1, 0)
speedContent.Visible = false

-- ==================== ANTI-KICK ВКЛАДКА ====================
local antikickContent = Instance.new("Frame")
antikickContent.Name = "AntikickContent"
antikickContent.Parent = contentFrame
antikickContent.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
antikickContent.BorderSizePixel = 0
antikickContent.Size = UDim2.new(1, 0, 1, 0)
antikickContent.Visible = false

-- ==================== НАСТРОЙКИ ВКЛАДКА ====================
local settingsContent = Instance.new("ScrollingFrame")
settingsContent.Name = "SettingsContent"
settingsContent.Parent = contentFrame
settingsContent.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
settingsContent.BorderSizePixel = 0
settingsContent.Size = UDim2.new(1, 0, 1, 0)
settingsContent.CanvasSize = UDim2.new(0, 0, 0, 600)
settingsContent.Visible = false

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

-- Закрытие меню
closeBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    mainFrame.Visible = menuOpen
end)

-- Горячие клавиши
UIS.InputBegan:Connect(function(input)
    local function checkBind(bindName)
        return input.KeyCode == stringToKeyCode(bindSettings[bindName])
    end
    
    if checkBind("MenuToggle") then
        menuOpen = not menuOpen
        mainFrame.Visible = menuOpen
        if menuOpen then
            updateTeleportList()
        end
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
        end
    end
end)

-- Обновление статусов игроков
spawn(function()
    while true do
        if menuOpen then
            -- Обновление списка телепорта
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
            
            -- Обновление списка AutoTP
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
                                
                                -- Если выбранный игрок умер - сбрасываем выбор
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

-- Инициализация
loadSettings()
switchTab("Teleport")

print("========================================")
print("🔥 KofaHVH v3.0 LOADED 🔥")
print("Made for MirageHVH")
print("Features:")
print("- Teleport to LIVING players only")
print("- Auto Teleport when target < 55m")
print("- Noclip, Speed Hack, Anti-Kick")
print("- Customizable key binds")
print("========================================")
print("Delete - Toggle Menu")
print("R - Teleport to nearest LIVING player")
print("T - Teleport behind LIVING player")
print("F - Auto Teleport toggle")
print("========================================")