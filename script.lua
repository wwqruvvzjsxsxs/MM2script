-- MM2 Event Auto-Farm & Clone Godmode (Fixed & Scaled UI)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Настройки
local isFarming = false
local isCloning = false
local farmSpeed = 0.1
local cloneCount = 5
local collected = 0
local maxLimit = 50
local isProcessing = false
local myClones = {}

-- ================= УЛУЧШЕННОЕ МЕНЮ (АДАПТИРОВАННОЕ) =================
if CoreGui:FindFirstChild("MM2_Fixed_Farm_GUI") then
    CoreGui.MM2_Fixed_Farm_GUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_Fixed_Farm_GUI"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 420)
Main.Position = UDim2.new(0.5, -160, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(70, 70, 90)
MainStroke.Thickness = 2
MainStroke.Parent = Main

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
Title.Text = "  MM2 HALLOWEEN AUTO-FARM"
Title.TextColor3 = Color3.fromRGB(255, 140, 0)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- Фикс скругления шапки
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = Title

-- Статус
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -30, 0, 25)
StatusLabel.Position = UDim2.new(0, 15, 0, 55)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Конфет собрано: 0 / 50"
StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Main

-- Кнопка Фарм
local FarmBtn = Instance.new("TextButton")
FarmBtn.Size = UDim2.new(0.9, 0, 0, 45)
FarmBtn.Position = UDim2.new(0.05, 0, 0, 90)
FarmBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
FarmBtn.Text = "Включить автофарм"
FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmBtn.TextSize = 14
FarmBtn.Font = Enum.Font.GothamBold
FarmBtn.Parent = Main

local FarmBtnCorner = Instance.new("UICorner")
FarmBtnCorner.CornerRadius = UDim.new(0, 8)
FarmBtnCorner.Parent = FarmBtn

-- Кнопка Клоны
local CloneBtn = Instance.new("TextButton")
CloneBtn.Size = UDim2.new(0.9, 0, 0, 45)
CloneBtn.Position = UDim2.new(0.05, 0, 0, 145)
CloneBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 110)
CloneBtn.Text = "Создать клонов (ВЫКЛ)"
CloneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloneBtn.TextSize = 14
CloneBtn.Font = Enum.Font.GothamBold
CloneBtn.Parent = Main

local CloneBtnCorner = Instance.new("UICorner")
CloneBtnCorner.CornerRadius = UDim.new(0, 8)
CloneBtnCorner.Parent = CloneBtn

-- Ползунок скорости
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -30, 0, 25)
SpeedLabel.Position = UDim2.new(0, 15, 0, 205)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Задержка телепорта: 0.10 сек"
SpeedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
SpeedLabel.TextSize = 13
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = Main

local SpeedBar = Instance.new("Frame")
SpeedBar.Size = UDim2.new(0.9, 0, 0, 10)
SpeedBar.Position = UDim2.new(0.05, 0, 0, 235)
SpeedBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SpeedBar.Parent = Main

local SpeedFill = Instance.new("Frame")
SpeedFill.Size = UDim2.new(0.5, 0, 1, 0)
SpeedFill.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
SpeedFill.BorderSizePixel = 0
SpeedFill.Parent = SpeedBar

local SpeedBarCorner = Instance.new("UICorner")
SpeedBarCorner.CornerRadius = UDim.new(1, 0)
SpeedBarCorner.Parent = SpeedBar

local SpeedFillCorner = Instance.new("UICorner")
SpeedFillCorner.CornerRadius = UDim.new(1, 0)
SpeedFillCorner.Parent = SpeedFill

-- Клоны настройки (кнопки + и -)
local CountLabel = Instance.new("TextLabel")
CountLabel.Size = UDim2.new(1, -30, 0, 25)
CountLabel.Position = UDim2.new(0, 15, 0, 265)
CountLabel.BackgroundTransparency = 1
CountLabel.Text = "Количество клонов: 5"
CountLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
CountLabel.TextSize = 13
CountLabel.Font = Enum.Font.Gotham
CountLabel.TextXAlignment = Enum.TextXAlignment.Left
CountLabel.Parent = Main

local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0, 50, 0, 35)
MinusBtn.Position = UDim2.new(0.05, 0, 0, 295)
MinusBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.TextSize = 20
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.Parent = Main

local MinusCorner = Instance.new("UICorner")
MinusCorner.CornerRadius = UDim.new(0, 6)
MinusCorner.Parent = MinusBtn

local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 50, 0, 35)
PlusBtn.Position = UDim2.new(0.05, 60, 0, 295)
PlusBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.TextSize = 20
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.Parent = Main

local PlusCorner = Instance.new("UICorner")
PlusCorner.CornerRadius = UDim.new(0, 6)
PlusCorner.Parent = PlusBtn

-- Подсказка внизу
local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 0, 20)
Credits.Position = UDim2.new(0, 0, 1, -25)
Credits.BackgroundTransparency = 1
Credits.Text = "Delta Executor Ready"
Credits.TextColor3 = Color3.fromRGB(100, 100, 120)
Credits.TextSize = 11
Credits.Font = Enum.Font.Gotham
Credits.Parent = Main

-- ================= УПРАВЛЕНИЕ UI =================

SpeedBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local mouseX = input.Position.X
        local barPos = SpeedBar.AbsolutePosition.X
        local barSize = SpeedBar.AbsoluteSize.X
        local percent = math.clamp((mouseX - barPos) / barSize, 0, 1)
        
        SpeedFill.Size = UDim2.new(percent, 0, 1, 0)
        farmSpeed = math.clamp(0.05 + (percent * 0.95), 0.05, 1.0)
        SpeedLabel.Text = string.format("Задержка телепорта: %.2f сек", farmSpeed)
    end
end)

MinusBtn.MouseButton1Click:Connect(function()
    if cloneCount > 1 then
        cloneCount = cloneCount - 1
        CountLabel.Text = "Количество клонов: " .. cloneCount
    end
end)

PlusBtn.MouseButton1Click:Connect(function()
    if cloneCount < 15 then
        cloneCount = cloneCount + 1
        CountLabel.Text = "Количество клонов: " .. cloneCount
    end
end)

FarmBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        FarmBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        FarmBtn.Text = "Автофарм: ВКЛЮЧЕН"
        collected = 0
        StatusLabel.Text = "Конфет собрано: 0 / 50"
    else
        FarmBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        FarmBtn.Text = "Включить автофарм"
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Anchored = false
        end
    end
end)

CloneBtn.MouseButton1Click:Connect(function()
    isCloning = not isCloning
    if isCloning then
        CloneBtn.BackgroundColor3 = Color3.fromRGB(50, 140, 200)
        CloneBtn.Text = "Клоны: ВКЛЮЧЕНЫ"
    else
        CloneBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 110)
        CloneBtn.Text = "Создать клонов (ВЫКЛ)"
    end
end)

-- ================= СКРИПТОВЫЕ ФУНКЦИИ =================

local function getCharParts()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        return char.HumanoidRootPart, char.Humanoid, char
    end
    return nil, nil, nil
end

local function clearClones()
    for _, clone in ipairs(myClones) do
        if clone and clone.Parent then
            clone:Destroy()
        end
    end
    myClones = {}
end

-- Поиск конфет по всем папкам и частям
local function getCandy()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = string.lower(obj.Name)
            -- Проверяем распространенные имена эвентовых предметов в MM2
            if name:find("candy") or name:find("konfeta") or name:find("token") or name:find("coin") or name:find("drop") then
                -- Убедимся, что у объекта есть реальная позиция и он активен
                if obj.Transparency < 1 and obj.Position.Magnitude > 0 then
                    return obj
                end
            end
        end
    end
    return nil
end

-- Сброс при смерти
LocalPlayer.CharacterAdded:Connect(function(newChar)
    clearClones()
    isProcessing = false
end)

-- Защита от падений
RunService.Stepped:Connect(function()
    if isFarming and not isProcessing then
        local hrp = getCharParts()
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- Основной цикл автофарма
task.spawn(function()
    while true do
        task.wait(0.05)
        if isFarming and not isProcessing then
            local hrp, humanoid = getCharParts()
            
            if hrp and humanoid and humanoid.Health > 0 then
                if collected >= maxLimit then
                    StatusLabel.Text = "Лимит 50 достигнут! Респавн..."
                    isProcessing = true
                    collected = 0
                    clearClones()
                    hrp.Anchored = false
                    humanoid.Health = 0 -- Сброс раунда
                    task.wait(4)
                    isProcessing = false
                    continue
                end

                local candy = getCandy()
                if candy then
                    isProcessing = true
                    hrp.Anchored = true
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    
                    -- Телепорт строго под конфету (на 8 блоков ниже, чтобы хитбокс задел)
                    hrp.CFrame = CFrame.new(candy.Position - Vector3.new(0, 8, 0))

                    -- Попытка программного касания
                    if firetouchinterest then
                        pcall(function()
                            firetouchinterest(hrp, candy, 0)
                            task.wait(0.02)
                            firetouchinterest(hrp, candy, 1)
                        end)
                    end

                    task.wait(farmSpeed)

                    -- Если конфета подобрана (исчезла)
                    if not candy.Parent or candy.Transparency >= 1 then
                        collected = collected + 1
                        StatusLabel.Text = "Конфет собрано: " .. collected .. " / 50"
                    end
                    
                    hrp.Anchored = false
                    isProcessing = false
                end
            end
        end
    end
end)

-- Цикл клонов
task.spawn(function()
    while true do
        task.wait(0.4)
        if isCloning and isFarming then
            local hrp, humanoid, char = getCharParts()
            
            if hrp and humanoid and humanoid.Health > 0 and char then
                if #myClones < cloneCount then
                    local clone = char:Clone()
                    clone.Name = "MM2_Dummy_Clone"
                    
                    -- Очистка от скриптов чтобы не крашило клиент
                    for _, d in ipairs(clone:GetDescendants()) do
                        if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("Humanoid") or d:IsA("Sound") then
                            d:Destroy()
                        elseif d:IsA("BasePart") then
                            d.CanCollide = false
                            d.Anchored = true
                        end
                    end
                    
                    clone.Parent = workspace
                    table.insert(myClones, clone)
                end
                
                -- Расстановка клонов вокруг игрока
                for i, clone in ipairs(myClones) do
                    if clone and clone:FindFirstChild("HumanoidRootPart") then
                        local angle = (i / cloneCount) * math.pi * 2
                        local xOffset = math.cos(angle) * 3.5
                        local zOffset = math.sin(angle) * 3.5
                        clone.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(xOffset, 0, zOffset)
                    end
                end
            end
        else
            if #myClones > 0 then
                clearClones()
            end
        end
    end
end)
