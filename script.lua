-- MM2 Event Auto-Farm & Clone Godmode (Premium UI)
-- Переписано с нуля: Красивое меню, фиксы клонов и фарма.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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

-- ================= КРАСИВОЕ МЕНЮ =================
if CoreGui:FindFirstChild("MM2_Premium_Farm") then
    CoreGui.MM2_Premium_Farm:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_Premium_Farm"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 360)
Main.Position = UDim2.new(0.5, -140, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 70)
MainStroke.Thickness = 1.5
MainStroke.Parent = Main

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Title.Text = "  MM2 AUTO-FARM  "
Title.TextColor3 = Color3.fromRGB(255, 165, 0)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Обрезка нижних углов заголовка
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = Title

-- Статус
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 45)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Конфет собрано: 0 / 50"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Main

-- Кнопка Фарм
local FarmBtn = Instance.new("TextButton")
FarmBtn.Size = UDim2.new(0.9, 0, 0, 40)
FarmBtn.Position = UDim2.new(0.05, 0, 0, 75)
FarmBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
FarmBtn.Text = "Включить автофарм"
FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmBtn.TextSize = 14
FarmBtn.Font = Enum.Font.GothamBold
FarmBtn.Parent = Main

local FarmBtnCorner = Instance.new("UICorner")
FarmBtnCorner.CornerRadius = UDim.new(0, 6)
FarmBtnCorner.Parent = FarmBtn

-- Кнопка Клоны
local CloneBtn = Instance.new("TextButton")
CloneBtn.Size = UDim2.new(0.9, 0, 0, 40)
CloneBtn.Position = UDim2.new(0.05, 0, 0, 125)
CloneBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
CloneBtn.Text = "Создать клонов (ВЫКЛ)"
CloneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloneBtn.TextSize = 14
CloneBtn.Font = Enum.Font.GothamBold
CloneBtn.Parent = Main

local CloneBtnCorner = Instance.new("UICorner")
CloneBtnCorner.CornerRadius = UDim.new(0, 6)
CloneBtnCorner.Parent = CloneBtn

-- Ползунок скорости
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
SpeedLabel.Position = UDim2.new(0, 10, 0, 180)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Скорость телепорта: 0.1 сек"
SpeedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = Main

-- Визуальный ползунок скорости (упрощенный)
local SpeedBar = Instance.new("Frame")
SpeedBar.Size = UDim2.new(0.9, 0, 0, 6)
SpeedBar.Position = UDim2.new(0.05, 0, 0, 205)
SpeedBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
SpeedBar.Parent = Main

local SpeedFill = Instance.new("Frame")
SpeedFill.Size = UDim2.new(0.5, 0, 1, 0) -- 50% заполнения
SpeedFill.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
SpeedFill.BorderSizePixel = 0
SpeedFill.Parent = SpeedBar

local SpeedBarCorner = Instance.new("UICorner")
SpeedBarCorner.CornerRadius = UDim.new(1, 0)
SpeedBarCorner.Parent = SpeedBar

local SpeedFillCorner = Instance.new("UICorner")
SpeedFillCorner.CornerRadius = UDim.new(1, 0)
SpeedFillCorner.Parent = SpeedFill

-- Выбор количества клонов (кнопки + и -)
local CountLabel = Instance.new("TextLabel")
CountLabel.Size = UDim2.new(1, -20, 0, 20)
CountLabel.Position = UDim2.new(0, 10, 0, 230)
CountLabel.BackgroundTransparency = 1
CountLabel.Text = "Количество клонов: 5"
CountLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
CountLabel.TextSize = 12
CountLabel.Font = Enum.Font.Gotham
CountLabel.TextXAlignment = Enum.TextXAlignment.Left
CountLabel.Parent = Main

local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0, 40, 0, 30)
MinusBtn.Position = UDim2.new(0.05, 0, 0, 260)
MinusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.TextSize = 18
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.Parent = Main

local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 40, 0, 30)
PlusBtn.Position = UDim2.new(0.05, 45, 0, 260)
PlusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.TextSize = 18
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.Parent = Main

-- ================= ЛОГИКА UI =================

-- Изменение скорости
SpeedBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local mouseX = input.Position.X
        local barPos = SpeedBar.AbsolutePosition.X
        local barSize = SpeedBar.AbsoluteSize.X
        local percent = math.clamp((mouseX - barPos) / barSize, 0, 1)
        
        SpeedFill.Size = UDim2.new(percent, 0, 1, 0)
        -- Инвертируем: больше ползунок = меньше задержка (быстрее)
        farmSpeed = 1.0 - (percent * 0.95) 
        SpeedLabel.Text = string.format("Скорость телепорта: %.2f сек", farmSpeed)
    end
end)

-- Изменение клонов
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

-- Включение фарма
FarmBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        FarmBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
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

-- Включение клонов
CloneBtn.MouseButton1Click:Connect(function()
    isCloning = not isCloning
    if isCloning then
        CloneBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        CloneBtn.Text = "Клоны: ВКЛЮЧЕНЫ"
    else
        CloneBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
        CloneBtn.Text = "Создать клонов (ВЫКЛ)"
    end
end)

-- ================= ИГРОВАЯ ЛОГИКА =================

local function getChar()
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

-- Поиск конфет (ищет Part и MeshPart)
local function getBestCandy(hrp)
    local candies = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = string.lower(obj.Name)
            if name:find("candy") or name:find("konfeta") or name:find("token") or name:find("sweet") then
                table.insert(candies, obj)
            end
        end
    end
    
    if #candies == 0 then return nil end
    
    table.sort(candies, function(a, b)
        return (a.Position - hrp.Position).Magnitude > (b.Position - hrp.Position).Magnitude
    end)
    return candies[1]
end

-- Авто-восстановление после смерти
LocalPlayer.CharacterAdded:Connect(function(char)
    clearClones()
    if isFarming then
        char:WaitForChild("HumanoidRootPart")
        task.wait(1.5)
    end
end)

-- Защита от падения в пустоту
RunService.Stepped:Connect(function()
    if isFarming and not isProcessing then
        local hrp = getChar()
        if hrp then hrp.Anchored = false end
    end
end)

-- ================= ЦИКЛ ФАРМА =================
task.spawn(function()
    while task.wait(0.05) do
        if isFarming and not isProcessing then
            local hrp, humanoid = getChar()
            
            if hrp and humanoid and humanoid.Health > 0 then
                if collected >= maxLimit then
                    StatusLabel.Text = "Лимит 50! Ждем респавна..."
                    isProcessing = true
                    collected = 0
                    clearClones()
                    hrp.Anchored = false
                    humanoid.Health = 0
                    task.wait(4)
                    isProcessing = false
                    continue
                end

                local candy = getBestCandy(hrp)
                if candy then
                    isProcessing = true
                    hrp.Anchored = true
                    hrp.Velocity = Vector3.new(0,0,0)
                    
                    -- Телепорт ровно под конфету (-3 стада)
                    hrp.CFrame = CFrame.new(candy.Position + Vector3.new(0, -3, 0))

                    if firetouchinterest then
                        pcall(function()
                            firetouchinterest(hrp, candy, 0)
                            task.wait(farmSpeed)
                            firetouchinterest(hrp, candy, 1)
                        end)
                    else
                        task.wait(farmSpeed)
                    end

                    if not candy.Parent then
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

-- ================= ЦИКЛ КЛОНОВ (ФИКС) =================
task.spawn(function()
    while task.wait(0.5) do
        if isCloning and isFarming then
            local hrp, humanoid, char = getChar()
            
            if hrp and humanoid and humanoid.Health > 0 and char then
                -- Если не хватает клонов - создаем
                if #myClones < cloneCount then
                    local fake = char:Clone()
                    fake.Archivable = true
                    fake.Name = "Clone"
                    
                    -- ЖЕСТКАЯ ОЧИСТКА: Удаляем ВСЁ, что может сломать игру
                    for _, child in ipairs(fake:GetDescendants()) do
                        if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("Camera") or child:IsA("Humanoid") or child:IsA("Sound") or child:IsA("ParticleEmitter") then
                            child:Destroy()
                        end
                        if child:IsA("BasePart") then
                            child.CanCollide = false
                            child.Anchored = true
                        end
                    end
                    
                    fake.Parent = workspace
                    table.insert(myClones, fake)
                end
                
                -- Ставим клонов вокруг тебя
                for i, clone in ipairs(myClones) do
                    if clone and clone:FindFirstChild("HumanoidRootPart") then
                        local angle = (i / cloneCount) * math.pi * 2
                        local offsetX = math.cos(angle) * 3
                        local offsetZ = math.sin(angle) * 3
                        
                        -- Привязываем клонов к тебе
                        clone.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(offsetX, 0, offsetZ)
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
