-- MM2 FLAWLESS AUTO-FARM (DELTA MOBILE EDITION)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local isFarming = false
local clonesActive = false
local clonesList = {}
local maxCoins = 50
local currentCoins = 0

-- Очистка старых интерфейсов
if CoreGui:FindFirstChild("MM2_Flawless_UI") then
    CoreGui.MM2_Flawless_UI:Destroy()
end

-- ================== МОБИЛЬНЫЙ ИНТЕРФЕЙС ==================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_Flawless_UI"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 220)
MainFrame.Position = UDim2.new(0.5, -150, 0.4, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "MM2 HALLOWEEN FARM"
Title.TextColor3 = Color3.fromRGB(255, 120, 0)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Кнопка сворачивания (большая для пальца)
local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0, 40, 0, 40)
HideBtn.Position = UDim2.new(1, -45, 0, 0)
HideBtn.BackgroundTransparency = 1
HideBtn.Text = "➖"
HideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HideBtn.TextSize = 20
HideBtn.Parent = MainFrame

-- Плавающая кнопка (чтобы открыть обратно)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0.5, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.Text = "🎃"
OpenBtn.TextSize = 25
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenBtn

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 0, 30)
StatusText.Position = UDim2.new(0, 0, 0, 45)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Собрано: 0 / 50"
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusText.TextSize = 16
StatusText.Font = Enum.Font.GothamMedium
StatusText.Parent = MainFrame

-- Огромная кнопка ФАРМ
local FarmBtn = Instance.new("TextButton")
FarmBtn.Size = UDim2.new(0.9, 0, 0, 50)
FarmBtn.Position = UDim2.new(0.05, 0, 0, 85)
FarmBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
FarmBtn.Text = "ВКЛЮЧИТЬ ФАРМ"
FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmBtn.TextSize = 16
FarmBtn.Font = Enum.Font.GothamBold
FarmBtn.Parent = MainFrame

local FarmCorner = Instance.new("UICorner")
FarmCorner.CornerRadius = UDim.new(0, 8)
FarmCorner.Parent = FarmBtn

-- Огромная кнопка КЛОНЫ
local CloneBtn = Instance.new("TextButton")
CloneBtn.Size = UDim2.new(0.9, 0, 0, 50)
CloneBtn.Position = UDim2.new(0.05, 0, 0, 145)
CloneBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 150)
CloneBtn.Text = "КЛОНЫ: ВЫКЛ"
CloneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloneBtn.TextSize = 16
CloneBtn.Font = Enum.Font.GothamBold
CloneBtn.Parent = MainFrame

local CloneCorner = Instance.new("UICorner")
CloneCorner.CornerRadius = UDim.new(0, 8)
CloneCorner.Parent = CloneBtn

-- ================== ЛОГИКА UI ==================
HideBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

-- ================== ФИЗИКА И АНТИ-ПАДЕНИЕ ==================
local function getHRP()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        return char.HumanoidRootPart, char.Humanoid
    end
    return nil, nil
end

local function applyAntiFall(hrp)
    -- Идеальный якорь без блокировки движения скриптом
    local bv = hrp:FindFirstChild("AntiFallVelocity")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "AntiFallVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
    end
end

local function removeAntiFall(hrp)
    local bv = hrp:FindFirstChild("AntiFallVelocity")
    if bv then bv:Destroy() end
end

-- ================== ПОИСК КОНФЕТ MM2 ==================
local function getValidCandy()
    local normal = workspace:FindFirstChild("Normal")
    if normal then
        local coinContainer = normal:FindFirstChild("CoinContainer")
        if coinContainer then
            for _, coin in ipairs(coinContainer:GetChildren()) do
                if coin:IsA("BasePart") and coin.Transparency < 1 then
                    return coin
                end
            end
        end
    end
    return nil
end

-- ================== ЛОГИКА КЛОНОВ ==================
local function clearClones()
    for _, c in ipairs(clonesList) do
        if c and c.Parent then c:Destroy() end
    end
    clonesList = {}
end

CloneBtn.MouseButton1Click:Connect(function()
    clonesActive = not clonesActive
    if clonesActive then
        CloneBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 60)
        CloneBtn.Text = "КЛОНЫ: ВКЛ"
    else
        CloneBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 150)
        CloneBtn.Text = "КЛОНЫ: ВЫКЛ"
        clearClones()
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if clonesActive and isFarming then
            local hrp = getHRP()
            local char = LocalPlayer.Character
            if hrp and char then
                if #clonesList < 4 then
                    -- Безопасное клонирование через Archivable
                    char.Archivable = true
                    local success, clone = pcall(function() return char:Clone() end)
                    
                    if success and clone then
                        clone.Name = "GhostClone"
                        -- Жестко удаляем всё, что может крашнуть игру
                        for _, v in ipairs(clone:GetDescendants()) do
                            if v:IsA("Script") or v:IsA("LocalScript") then
                                v:Destroy()
                            elseif v:IsA("BasePart") then
                                v.CanCollide = false
                                v.Anchored = true
                                v.Massless = true
                            end
                        end
                        clone.Parent = workspace
                        table.insert(clonesList, clone)
                    end
                end
                
                -- Крутим клонов вокруг тебя
                for i, c in ipairs(clonesList) do
                    local cloneRoot = c:FindFirstChild("HumanoidRootPart")
                    if cloneRoot then
                        local angle = (i / #clonesList) * math.pi * 2
                        cloneRoot.CFrame = hrp.CFrame * CFrame.new(math.cos(angle) * 4, 0, math.sin(angle) * 4)
                    end
                end
            end
        elseif #clonesList > 0 then
            clearClones()
        end
    end
end)

-- ================== ЛОГИКА ФАРМА ==================
FarmBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        FarmBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        FarmBtn.Text = "ФАРМ ИДЕТ..."
        currentCoins = 0
        StatusText.Text = "Собрано: 0 / 50"
    else
        FarmBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        FarmBtn.Text = "ВКЛЮЧИТЬ ФАРМ"
        local hrp = getHRP()
        if hrp then removeAntiFall(hrp) end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if isFarming then
            local hrp, hum = getHRP()
            if hrp and hum and hum.Health > 0 then
                
                if currentCoins >= maxCoins then
                    StatusText.Text = "ЛИМИТ! РЕСПАВН..."
                    removeAntiFall(hrp)
                    clearClones()
                    hum.Health = 0 -- Убиваем персонажа для сброса раунда
                    currentCoins = 0
                    task.wait(4)
                    continue
                end

                local candy = getValidCandy()
                if candy then
                    -- Включаем анти-падение
                    applyAntiFall(hrp)
                    
                    -- Телепорт прямо в центр конфеты
                    hrp.CFrame = candy.CFrame
                    
                    -- Ждем пока сервер засчитает сбор (конфета исчезнет)
                    local timeout = 0
                    while candy.Parent and candy.Transparency < 1 and isFarming and timeout < 10 do
                        hrp.CFrame = candy.CFrame
                        task.wait(0.1)
                        timeout = timeout + 1
                    end
                    
                    if timeout < 10 then
                        currentCoins = currentCoins + 1
                        StatusText.Text = "Собрано: " .. currentCoins .. " / 50"
                    end
                end
            end
        end
    end
end)

-- Очистка при респавне
LocalPlayer.CharacterAdded:Connect(function()
    clearClones()
end)
