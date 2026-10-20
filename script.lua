-- MM2 HALLOWEEN ULTIMATE FARM & CLONES (MOBILE / DELTA)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local settings = {
    farmActive = false,
    clonesActive = false,
    speed = 0.15,
    cloneCount = 4,
    collected = 0,
    maxLimit = 50,
    undergroundOffset = 3.5 -- глубина под конфету (не проваливает под карту)
}

local currentClones = {}
local isBusy = false

-- Удаление старого UI
if CoreGui:FindFirstChild("MM2_MobileHub") then
    CoreGui.MM2_MobileHub:Destroy()
end

-- ================= ИНТЕРФЕЙС =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_MobileHub"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true

-- Главное горизонтальное окно
local Main = Instance.new("Frame")
Main.Name = "MainWindow"
Main.Size = UDim2.new(0, 380, 0, 210)
Main.Position = UDim2.new(0.5, -190, 0.4, -105)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 80)
MainStroke.Thickness = 1.5
MainStroke.Parent = Main

-- Шапка
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "MM2 HALLOWEEN V4 | DELTA"
Title.TextColor3 = Color3.fromRGB(255, 140, 0)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Кнопка скрыть [-]
local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0, 30, 0, 25)
HideBtn.Position = UDim2.new(1, -38, 0, 5)
HideBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
HideBtn.Text = "-"
HideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HideBtn.TextSize = 16
HideBtn.Font = Enum.Font.GothamBold
HideBtn.Parent = Header

local HideCorner = Instance.new("UICorner")
HideCorner.CornerRadius = UDim.new(0, 6)
HideCorner.Parent = HideBtn

-- Плавающая кнопка для открытия
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 50, 0, 50)
FloatBtn.Position = UDim2.new(0, 15, 0.4, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
FloatBtn.Text = "MM2"
FloatBtn.TextColor3 = Color3.fromRGB(255, 140, 0)
FloatBtn.TextSize = 14
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.Active = true
FloatBtn.Draggable = true
FloatBtn.Visible = false
FloatBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(255, 140, 0)
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatBtn

-- Статус
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -24, 0, 20)
StatusLabel.Position = UDim2.new(0, 12, 0, 42)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Конфет: 0 / 50"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Main

-- Кнопки действий
local FarmBtn = Instance.new("TextButton")
FarmBtn.Size = UDim2.new(0.46, 0, 0, 40)
FarmBtn.Position = UDim2.new(0.03, 0, 0, 68)
FarmBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
FarmBtn.Text = "Автофарм: ВЫКЛ"
FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmBtn.TextSize = 12
FarmBtn.Font = Enum.Font.GothamBold
FarmBtn.Parent = Main

local FarmCorner = Instance.new("UICorner")
FarmCorner.CornerRadius = UDim.new(0, 8)
FarmCorner.Parent = FarmBtn

local CloneBtn = Instance.new("TextButton")
CloneBtn.Size = UDim2.new(0.46, 0, 0, 40)
CloneBtn.Position = UDim2.new(0.51, 0, 0, 68)
CloneBtn.BackgroundColor3 = Color3.fromRGB(45, 55, 120)
CloneBtn.Text = "Клоны: ВЫКЛ"
CloneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloneBtn.TextSize = 12
CloneBtn.Font = Enum.Font.GothamBold
CloneBtn.Parent = Main

local CloneCorner = Instance.new("UICorner")
CloneCorner.CornerRadius = UDim.new(0, 8)
CloneCorner.Parent = CloneBtn

-- Скорость
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -24, 0, 18)
SpeedLabel.Position = UDim2.new(0, 12, 0, 118)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Задержка сбора: 0.15с"
SpeedLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
SpeedLabel.TextSize = 11
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = Main

local SpeedBar = Instance.new("Frame")
SpeedBar.Size = UDim2.new(0.94, 0, 0, 8)
SpeedBar.Position = UDim2.new(0.03, 0, 0, 138)
SpeedBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
SpeedBar.Parent = Main

local SpeedFill = Instance.new("Frame")
SpeedFill.Size = UDim2.new(0.3, 0, 1, 0)
SpeedFill.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
SpeedFill.BorderSizePixel = 0
SpeedFill.Parent = SpeedBar

local SpeedBarCorner = Instance.new("UICorner")
SpeedBarCorner.CornerRadius = UDim.new(1, 0)
SpeedBarCorner.Parent = SpeedBar

local SpeedFillCorner = Instance.new("UICorner")
SpeedFillCorner.CornerRadius = UDim.new(1, 0)
SpeedFillCorner.Parent = SpeedFill

-- Кнопки изменения клонов
local CloneCountText = Instance.new("TextLabel")
CloneCountText.Size = UDim2.new(0.6, 0, 0, 24)
CloneCountText.Position = UDim2.new(0.03, 0, 0, 160)
CloneCountText.BackgroundTransparency = 1
CloneCountText.Text = "Количество клонов: 4"
CloneCountText.TextColor3 = Color3.fromRGB(160, 160, 170)
CloneCountText.TextSize = 11
CloneCountText.Font = Enum.Font.Gotham
CloneCountText.TextXAlignment = Enum.TextXAlignment.Left
CloneCountText.Parent = Main

local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0, 32, 0, 24)
MinusBtn.Position = UDim2.new(0.72, 0, 0, 160)
MinusBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.Parent = Main

local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 32, 0, 24)
PlusBtn.Position = UDim2.new(0.86, 0, 0, 160)
PlusBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.Parent = Main

-- ================= ОБРАБОТКА ИНТЕРФЕЙСА =================

HideBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    FloatBtn.Visible = true
end)

FloatBtn.MouseButton1Click:Connect(function()
    Main.Visible = true
    FloatBtn.Visible = false
end)

SpeedBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local ratio = math.clamp((input.Position.X - SpeedBar.AbsolutePosition.X) / SpeedBar.AbsoluteSize.X, 0, 1)
        SpeedFill.Size = UDim2.new(ratio, 0, 1, 0)
        settings.speed = math.clamp(0.05 + (ratio * 0.5), 0.05, 0.55)
        SpeedLabel.Text = string.format("Задержка сбора: %.2fс", settings.speed)
    end
end)

MinusBtn.MouseButton1Click:Connect(function()
    if settings.cloneCount > 1 then
        settings.cloneCount -= 1
        CloneCountText.Text = "Количество клонов: " .. settings.cloneCount
    end
end)

PlusBtn.MouseButton1Click:Connect(function()
    if settings.cloneCount < 10 then
        settings.cloneCount += 1
        CloneCountText.Text = "Количество клонов: " .. settings.cloneCount
    end
end)

FarmBtn.MouseButton1Click:Connect(function()
    settings.farmActive = not settings.farmActive
    if settings.farmActive then
        FarmBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
        FarmBtn.Text = "Автофарм: ВКЛ"
        settings.collected = 0
        StatusLabel.Text = "Конфет: 0 / 50"
    else
        FarmBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
        FarmBtn.Text = "Автофарм: ВЫКЛ"
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Anchored = false
        end
    end
end)

local function removeClones()
    for _, clone in ipairs(currentClones) do
        if clone and clone.Parent then
            clone:Destroy()
        end
    end
    currentClones = {}
end

CloneBtn.MouseButton1Click:Connect(function()
    settings.clonesActive = not settings.clonesActive
    if settings.clonesActive then
        CloneBtn.BackgroundColor3 = Color3.fromRGB(40, 110, 200)
        CloneBtn.Text = "Клоны: ВКЛ"
    else
        CloneBtn.BackgroundColor3 = Color3.fromRGB(45, 55, 120)
        CloneBtn.Text = "Клоны: ВЫКЛ"
        removeClones()
    end
end)

-- ================= ПОИСК КОНФЕТ В MM2 =================

-- Ищет контейнер монет конкретно для карты MM2
local function getCandyList()
    local list = {}
    
    -- 1. Стандартное расположение монет в MM2
    for _, map in ipairs(workspace:GetChildren()) do
        local container = map:FindFirstChild("CoinContainer")
        if container then
            for _, coin in ipairs(container:GetChildren()) do
                if coin:IsA("BasePart") and coin.Transparency < 1 then
                    table.insert(list, coin)
                end
            end
        end
    end
    
    -- 2. Если на карте нестандартная структура ивента
    if #list == 0 then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Transparency < 1 then
                local name = string.lower(obj.Name)
                if name:find("coin") or name:find("candy") or name:find("token") or name:find("sweet") then
                    table.insert(list, obj)
                end
            end
        end
    end
    
    return list
end

-- ================= ФИКС ПАДЕНИЯ И NOCLIP =================
RunService.Stepped:Connect(function()
    if settings.farmActive then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Полная остановка гравитационного ускорения
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- ================= ЦИКЛ ФАРМА =================
task.spawn(function()
    while true do
        task.wait(0.04)
        if settings.farmActive and not isBusy then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local hrp = char.HumanoidRootPart
                local hum = char.Humanoid
                
                if hum.Health > 0 then
                    -- Проверка достижения лимита
                    if settings.collected >= settings.maxLimit then
                        StatusLabel.Text = "Собрано 50! Респавн..."
                        isBusy = true
                        settings.collected = 0
                        removeClones()
                        hrp.Anchored = false
                        hum.Health = 0
                        task.wait(4.5)
                        isBusy = false
                        continue
                    end
                    
                    local candies = getCandyList()
                    if #candies > 0 then
                        -- Берем ближайшую или первую попавшуюся
                        local target = candies[1]
                        if target and target.Parent then
                            isBusy = true
                            
                            -- Ставим позицию ровно под конфету, но БЕЗ падения в пустоту
                            local targetPos = target.Position - Vector3.new(0, settings.undergroundOffset, 0)
                            hrp.CFrame = CFrame.new(targetPos)
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            
                            -- Физическое касание хитбоксом
                            if firetouchinterest then
                                pcall(function()
                                    firetouchinterest(hrp, target, 0)
                                    task.wait(0.02)
                                    firetouchinterest(hrp, target, 1)
                                end)
                            end
                            
                            task.wait(settings.speed)
                            
                            if not target.Parent or target.Transparency >= 1 then
                                settings.collected += 1
                                StatusLabel.Text = "Конфет: " .. settings.collected .. " / " .. settings.maxLimit
                            end
                            
                            isBusy = false
                        end
                    end
                end
            end
        end
    end
end)

-- ================= ЦИКЛ КЛОНОВ =================
task.spawn(function()
    while true do
        task.wait(0.3)
        if settings.clonesActive and settings.farmActive then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local hrp = char.HumanoidRootPart
                if char.Humanoid.Health > 0 then
                    if #currentClones < settings.cloneCount then
                        local fakeChar = Instance.new("Model")
                        fakeChar.Name = "DeceptionClone"
                        
                        -- Копируем только части тела без контроллеров и анимаций
                        for _, part in ipairs(char:GetChildren()) do
                            if part:IsA("BasePart") or part:IsA("Accessory") then
                                local clonedPart = part:Clone()
                                if clonedPart:IsA("BasePart") then
                                    clonedPart.CanCollide = false
                                    clonedPart.Anchored = true
                                end
                                clonedPart.Parent = fakeChar
                            end
                        end
                        
                        fakeChar.Parent = workspace
                        table.insert(currentClones, fakeChar)
                    end
                    
                    -- Размещение по кругу вокруг настоящей позиции
                    for i, clone in ipairs(currentClones) do
                        local root = clone:FindFirstChild("HumanoidRootPart") or clone:FindFirstChild("Torso")
                        if root then
                            local angle = (i / #currentClones) * (math.pi * 2)
                            local offset = Vector3.new(math.cos(angle) * 4, 0, math.sin(angle) * 4)
                            root.CFrame = hrp.CFrame + offset
                        end
                    end
                end
            end
        else
            if #currentClones > 0 then
                removeClones()
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    isBusy = false
    removeClones()
end)
