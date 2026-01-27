-- Pure WallShoot Cheat v1.0
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Plr = Players.LocalPlayer
local WALLSHOOT_RANGE = 500
local WALLSHOOT_DAMAGE = 25

-- Режимы стрельбы
local shootModes = {
    "WallShoot",       -- Прямая стрельба сквозь стены
    "ThinWalls",       -- Стены становятся тоньше/деревянными
    "GhostWalls"       -- Стены становятся полупрозрачными
}

local currentMode = shootModes[1]
local wallshootActive = false
local wallshootConnection = nil
local thinWallsActive = false
local thinWallsConnection = nil
local modifiedWalls = {}

-- ==================== ИКОНКА ====================
local iconGui = Instance.new("ScreenGui")
iconGui.Name = "WallShoot_Icon"
iconGui.Parent = CoreGui
iconGui.ResetOnSpawn = false

local iconFrame = Instance.new("Frame")
iconFrame.Parent = iconGui
iconFrame.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
iconFrame.BackgroundTransparency = 0.2
iconFrame.BorderSizePixel = 2
iconFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
iconFrame.Size = UDim2.new(0, 60, 0, 60)
iconFrame.Position = UDim2.new(0, 20, 0.5, -30)
iconFrame.Active = true
iconFrame.Draggable = true

local iconText = Instance.new("TextLabel")
iconText.Parent = iconFrame
iconText.BackgroundTransparency = 1
iconText.Size = UDim2.new(1, 0, 1, 0)
iconText.Text = "🔫"
iconText.TextColor3 = Color3.new(1, 1, 1)
iconText.Font = Enum.Font.GothamBold
iconText.TextSize = 28

local iconStatus = Instance.new("TextLabel")
iconStatus.Parent = iconFrame
iconStatus.BackgroundTransparency = 1
iconStatus.Size = UDim2.new(1, 0, 0, 15)
iconStatus.Position = UDim2.new(0, 0, 1, 2)
iconStatus.Text = "OFF | WallShoot"
iconStatus.TextColor3 = Color3.new(1, 1, 1)
iconStatus.Font = Enum.Font.Gotham
iconStatus.TextSize = 10

-- ==================== ОСНОВНОЙ GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WallShoot_GUI"
screenGui.Parent = CoreGui
screenGui.Enabled = false

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
mainFrame.Position = UDim2.new(0.6, 0, 0.1, 0)
mainFrame.Size = UDim2.new(0, 300, 0, 350)
mainFrame.Active = true
mainFrame.Draggable = true

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Parent = mainFrame
titleBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
titleBar.BorderSizePixel = 0
titleBar.Size = UDim2.new(1, 0, 0, 40)

local title = Instance.new("TextLabel")
title.Parent = titleBar
title.BackgroundTransparency = 1
title.Size = UDim2.new(0.8, 0, 1, 0)
title.Position = UDim2.new(0.1, 0, 0, 0)
title.Font = Enum.Font.GothamBold
title.Text = "🔥 WALLSHOOT CHEAT"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.BackgroundTransparency = 1
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0.5, -20)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 30

-- Основной контент
local contentFrame = Instance.new("Frame")
contentFrame.Parent = mainFrame
contentFrame.BackgroundColor3 = Color3.fromRGB(15, 0, 0)
contentFrame.BorderSizePixel = 0
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)

-- ==================== СТАТУС ====================
local statusFrame = Instance.new("Frame")
statusFrame.Parent = contentFrame
statusFrame.BackgroundTransparency = 1
statusFrame.Size = UDim2.new(0.9, 0, 0, 80)
statusFrame.Position = UDim2.new(0.05, 0, 0, 10)

local statusTitle = Instance.new("TextLabel")
statusTitle.Parent = statusFrame
statusTitle.Size = UDim2.new(1, 0, 0, 30)
statusTitle.BackgroundTransparency = 1
statusTitle.Text = "STATUS"
statusTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
statusTitle.Font = Enum.Font.GothamBold
statusTitle.TextSize = 16

local statusText = Instance.new("TextLabel")
statusText.Parent = statusFrame
statusText.Size = UDim2.new(1, 0, 0, 50)
statusText.Position = UDim2.new(0, 0, 0, 30)
statusText.BackgroundTransparency = 1
statusText.Text = "WALLSHOOT: OFF\nMode: " .. currentMode .. "\nRange: " .. WALLSHOOT_RANGE .. " studs"
statusText.TextColor3 = Color3.new(1, 1, 1)
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 14
statusText.TextWrapped = true

-- ==================== КНОПКА ВКЛ/ВЫКЛ ====================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Parent = contentFrame
toggleBtn.Size = UDim2.new(0.9, 0, 0, 50)
toggleBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
toggleBtn.Text = "🔥 ENABLE WALLSHOOT (F)"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18

-- ==================== ВЫБОР РЕЖИМА ====================
local modeFrame = Instance.new("Frame")
modeFrame.Parent = contentFrame
modeFrame.BackgroundTransparency = 1
modeFrame.Size = UDim2.new(0.9, 0, 0, 120)
modeFrame.Position = UDim2.new(0.05, 0, 0.4, 0)

local modeTitle = Instance.new("TextLabel")
modeTitle.Parent = modeFrame
modeTitle.Size = UDim2.new(1, 0, 0, 25)
modeTitle.BackgroundTransparency = 1
modeTitle.Text = "SHOOT MODE (V)"
modeTitle.TextColor3 = Color3.fromRGB(255, 150, 50)
modeTitle.Font = Enum.Font.GothamBold
modeTitle.TextSize = 16

-- Кнопки выбора режима
local modeButtons = {}

for i, mode in ipairs(shootModes) do
    local btn = Instance.new("TextButton")
    btn.Parent = modeFrame
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, 25 + (i-1)*35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
    btn.Text = "  " .. mode
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    if mode == currentMode then
        btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
    
    local modeDesc = Instance.new("TextLabel")
    modeDesc.Parent = btn
    modeDesc.Size = UDim2.new(0, 100, 1, 0)
    modeDesc.Position = UDim2.new(1, -105, 0, 0)
    modeDesc.BackgroundTransparency = 1
    modeDesc.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    modeDesc.Font = Enum.Font.Gotham
    modeDesc.TextSize = 10
    
    if mode == "WallShoot" then
        modeDesc.Text = "Direct shoot"
    elseif mode == "ThinWalls" then
        modeDesc.Text = "Thin wooden walls"
    elseif mode == "GhostWalls" then
        modeDesc.Text = "Ghost walls"
    end
    
    btn.MouseButton1Click:Connect(function()
        currentMode = mode
        statusText.Text = "WALLSHOOT: " .. (wallshootActive and "ON" or "OFF") .. "\nMode: " .. currentMode .. "\nRange: " .. WALLSHOOT_RANGE .. " studs"
        
        for _, b in pairs(modeButtons) do
            b.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
        end
        btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        
        -- Если активен режим тонких стен - обновляем
        if thinWallsActive then
            applyThinWalls()
        end
    end)
    
    modeButtons[mode] = btn
end

-- ==================== ФУНКЦИИ ====================
-- Поиск ближайшего игрока
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

-- Стрельба сквозь стены (Прямой режим)
local function directWallShoot()
    local closestPlayer, distance = getClosestPlayer()
    if not closestPlayer or not closestPlayer.Character then return end
    
    local targetChar = closestPlayer.Character
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local humanoid = targetChar:FindFirstChild("Humanoid")
    
    if not targetHRP or not humanoid or humanoid.Health <= 0 then return end
    
    -- Создаем красный трассер выстрела
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
    
    -- Наносим урон сквозь стены
    humanoid:TakeDamage(WALLSHOOT_DAMAGE)
    
    -- Удаляем трассер
    game:GetService("Debris"):AddItem(bulletTracer, 0.5)
    
    -- Показываем попадание
    local hitIndicator = Instance.new("Part")
    hitIndicator.Size = Vector3.new(1, 1, 1)
    hitIndicator.Color = Color3.new(1, 0, 0)
    hitIndicator.Material = Enum.Material.Neon
    hitIndicator.Transparency = 0.5
    hitIndicator.Anchored = true
    hitIndicator.CanCollide = false
    hitIndicator.Position = targetHRP.Position
    hitIndicator.Parent = Workspace
    
    game:GetService("Debris"):AddItem(hitIndicator, 0.3)
    
    return true
end

-- Режим "Тонкие стены" - делаем стены тонкими и деревянными
local function applyThinWalls()
    if not thinWallsActive then return end
    
    -- Ищем все стены в радиусе
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Name:lower():find("wall") then
            if not modifiedWalls[part] then
                -- Сохраняем оригинальные свойства
                modifiedWalls[part] = {
                    Size = part.Size,
                    Material = part.Material,
                    Transparency = part.Transparency,
                    CanCollide = part.CanCollide
                }
                
                if currentMode == "ThinWalls" then
                    -- Делаем стену тонкой и деревянной
                    part.Size = Vector3.new(part.Size.X, part.Size.Y, 0.1)
                    part.Material = Enum.Material.Wood
                    part.Transparency = 0.2
                    part.CanCollide = false
                elseif currentMode == "GhostWalls" then
                    -- Делаем стену полупрозрачной
                    part.Transparency = 0.7
                    part.CanCollide = false
                end
            end
        end
    end
end

-- Восстановление стен
local function restoreWalls()
    for part, originalProps in pairs(modifiedWalls) do
        if part and part.Parent then
            part.Size = originalProps.Size
            part.Material = originalProps.Material
            part.Transparency = originalProps.Transparency
            part.CanCollide = originalProps.CanCollide
        end
    end
    modifiedWalls = {}
end

-- Переключение режима тонких стен
local function toggleThinWalls()
    thinWallsActive = not thinWallsActive
    
    if thinWallsActive then
        applyThinWalls()
        -- Автообновление стен
        thinWallsConnection = RunService.Heartbeat:Connect(function()
            if not thinWallsActive then return end
            applyThinWalls()
        end)
    else
        if thinWallsConnection then
            thinWallsConnection:Disconnect()
            thinWallsConnection = nil
        end
        restoreWalls()
    end
end

-- Основная функция стрельбы
local function shootThroughWalls()
    if currentMode == "WallShoot" then
        return directWallShoot()
    elseif currentMode == "ThinWalls" or currentMode == "GhostWalls" then
        -- При этих режимах просто стреляем обычным способом (стены уже тонкие)
        local closestPlayer, distance = getClosestPlayer()
        if not closestPlayer or not closestPlayer.Character then return end
        
        local targetChar = closestPlayer.Character
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        local humanoid = targetChar:FindFirstChild("Humanoid")
        
        if not targetHRP or not humanoid or humanoid.Health <= 0 then return end
        
        humanoid:TakeDamage(WALLSHOOT_DAMAGE)
        
        -- Трассер для визуализации
        local tracer = Instance.new("Part")
        tracer.Size = Vector3.new(0.05, 0.05, distance)
        tracer.Color = Color3.new(0, 1, 1)
        tracer.Material = Enum.Material.Neon
        tracer.Transparency = 0.4
        tracer.Anchored = true
        tracer.CanCollide = false
        tracer.CFrame = CFrame.new(Plr.Character.Head.Position, targetHRP.Position) * 
                       CFrame.new(0, 0, -distance/2)
        tracer.Parent = Workspace
        
        game:GetService("Debris"):AddItem(tracer, 0.5)
        return true
    end
end

-- Переключение WallShoot
local function toggleWallShoot()
    wallshootActive = not wallshootActive
    
    if wallshootActive then
        -- Включаем авто-стрельбу
        wallshootConnection = RunService.Heartbeat:Connect(function()
            if not wallshootActive then return end
            
            local myChar = Plr.Character
            if not myChar then return end
            
            local tool = myChar:FindFirstChildOfClass("Tool")
            if tool then
                shootThroughWalls()
            end
        end)
        
        -- Если выбран режим тонких стен - включаем его
        if currentMode == "ThinWalls" or currentMode == "GhostWalls" then
            toggleThinWalls()
        end
        
        toggleBtn.Text = "💥 DISABLE WALLSHOOT (F)"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        statusText.Text = "WALLSHOOT: ON\nMode: " .. currentMode .. "\nRange: " .. WALLSHOOT_RANGE .. " studs"
        iconFrame.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        iconStatus.Text = "ON | " .. currentMode
    else
        -- Выключаем всё
        if wallshootConnection then
            wallshootConnection:Disconnect()
            wallshootConnection = nil
        end
        
        if thinWallsActive then
            toggleThinWalls()
        end
        
        toggleBtn.Text = "🔥 ENABLE WALLSHOOT (F)"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        statusText.Text = "WALLSHOOT: OFF\nMode: " .. currentMode .. "\nRange: " .. WALLSHOOT_RANGE .. " studs"
        iconFrame.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        iconStatus.Text = "OFF | " .. currentMode
    end
end

-- ==================== ГОРЯЧИЕ КЛАВИШИ ====================
local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        toggleWallShoot()
    elseif input.KeyCode == Enum.KeyCode.V then
        -- Переключение режима стрельбы
        local currentIndex = table.find(shootModes, currentMode) or 1
        local nextIndex = currentIndex % #shootModes + 1
        currentMode = shootModes[nextIndex]
        
        statusText.Text = "WALLSHOOT: " .. (wallshootActive and "ON" or "OFF") .. "\nMode: " .. currentMode .. "\nRange: " .. WALLSHOOT_RANGE .. " studs"
        iconStatus.Text = (wallshootActive and "ON" or "OFF") .. " | " .. currentMode
        
        for mode, btn in pairs(modeButtons) do
            btn.BackgroundColor3 = mode == currentMode and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(40, 10, 10)
        end
        
        -- Если включен - переключаем режим тонких стен
        if wallshootActive then
            if thinWallsActive then
                toggleThinWalls()
                toggleThinWalls()
            end
        end
    elseif input.KeyCode == Enum.KeyCode.Delete then
        -- Показать/скрыть меню
        screenGui.Enabled = not screenGui.Enabled
        iconFrame.BackgroundColor3 = screenGui.Enabled and Color3.fromRGB(0, 100, 200) or 
                                    (wallshootActive and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0))
    end
end)

-- ==================== ОБРАБОТЧИКИ КНОПОК ====================
toggleBtn.MouseButton1Click:Connect(toggleWallShoot)

iconFrame.MouseButton1Click:Connect(function()
    screenGui.Enabled = not screenGui.Enabled
    iconFrame.BackgroundColor3 = screenGui.Enabled and Color3.fromRGB(0, 100, 200) or 
                                (wallshootActive and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0))
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
    iconFrame.BackgroundColor3 = wallshootActive and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
end)

-- ==================== ИНФО ТЕКСТ ====================
local infoText = Instance.new("TextLabel")
infoText.Parent = contentFrame
infoText.Size = UDim2.new(0.9, 0, 0, 80)
infoText.Position = UDim2.new(0.05, 0, 0.8, 0)
infoText.BackgroundTransparency = 1
infoText.Text = "Hotkeys:\nF - Toggle WallShoot\nV - Change Mode\nDelete - Show/Hide Menu\n\nModes:\n• WallShoot: Shoot through walls\n• ThinWalls: Walls become thin wood\n• GhostWalls: Walls become transparent"
infoText.TextColor3 = Color3.new(0.8, 0.8, 1)
infoText.Font = Enum.Font.Gotham
infoText.TextSize = 12
infoText.TextWrapped = true

print("========================================")
print("🔥 PURE WALLSHOOT CHEAT v1.0 LOADED 🔥")
print("========================================")
print("Features:")
print("- Direct WallShoot (shoot through any wall)")
print("- ThinWalls mode (walls become thin wood)")
print("- GhostWalls mode (walls become transparent)")
print("- Simple GUI with icon")
print("- Hotkeys: F, V, Delete")
print("========================================")
print("Controls:")
print("F - Toggle WallShoot")
print("V - Change shoot mode")
print("Delete - Show/Hide menu")
print("Icon (🔫) - Click to open menu")
print("========================================")