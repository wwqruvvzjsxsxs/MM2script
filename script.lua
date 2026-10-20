-- =================================================================
-- PROJECT ARGON: MM2 PREMIUM AUTOFARM (DELTA OPTIMIZED)
-- =================================================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local isFarming = false
local farmSpeed = 15 -- Скорость полета (выше = быстрее)
local collected = 0
local maxCoins = 50

-- Очистка старого UI
if CoreGui:FindFirstChild("ArgonPremiumUI") then
    CoreGui.ArgonPremiumUI:Destroy()
end

-- ================= УМНАЯ НЕВИДИМАЯ ПЛАТФОРМА =================
-- Это спасет от падений под карту и античита
local platform = Instance.new("Part")
platform.Size = Vector3.new(15, 1, 15)
platform.Transparency = 1 -- Полностью невидимая
platform.Anchored = true
platform.CanCollide = true
platform.Color = Color3.fromRGB(255, 0, 0)
platform.Material = Enum.Material.ForceField
platform.Parent = workspace

RunService.Heartbeat:Connect(function()
    if isFarming then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            -- Платформа всегда висит ровно на 3.5 стада ниже тебя
            platform.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, -3.5, 0)
        end
    else
        platform.CFrame = CFrame.new(0, -9999, 0) -- Прячем, когда выключено
    end
end)

-- ================= ПРЕМИУМ ИНТЕРФЕЙС =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArgonPremiumUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Плавающая кнопка-логотип (для скрытия/открытия)
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ToggleBtn.Image = "rbxassetid://6026568227" -- Иконка шестеренки/лого
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(255, 85, 0)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleBtn

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 240)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainShadow = Instance.new("UIStroke")
MainShadow.Color = Color3.fromRGB(40, 40, 50)
MainShadow.Thickness = 2
MainShadow.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "ARGON | HALLOWEEN MM2"
Title.TextColor3 = Color3.fromRGB(255, 85, 0)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 0, 30)
StatusText.Position = UDim2.new(0, 0, 0, 45)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Конфет: 0 / 50"
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusText.TextSize = 18
StatusText.Font = Enum.Font.Gotham
StatusText.Parent = MainFrame

-- Качественный слайдер скорости
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -40, 0, 20)
SpeedLabel.Position = UDim2.new(0, 20, 0, 85)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Скорость полета: 15"
SpeedLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
SpeedLabel.TextSize = 13
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = MainFrame

local SliderBG = Instance.new("Frame")
SliderBG.Size = UDim2.new(1, -40, 0, 8)
SliderBG.Position = UDim2.new(0, 20, 0, 110)
SliderBG.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
SliderBG.Parent = MainFrame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(1, 0)
SliderCorner.Parent = SliderBG

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.3, 0, 1, 0) -- Дефолтная позиция
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
SliderFill.Parent = SliderBG

local SliderFillCorner = Instance.new("UICorner")
SliderFillCorner.CornerRadius = UDim.new(1, 0)
SliderFillCorner.Parent = SliderFill

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(1, 0, 1, 10)
SliderBtn.Position = UDim2.new(0, 0, 0, -5)
SliderBtn.BackgroundTransparency = 1
SliderBtn.Text = ""
SliderBtn.Parent = SliderBG

-- Кнопка старта
local FarmBtn = Instance.new("TextButton")
FarmBtn.Size = UDim2.new(1, -40, 0, 50)
FarmBtn.Position = UDim2.new(0, 20, 0, 150)
FarmBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
FarmBtn.Text = "ЗАПУСТИТЬ ФАРМ"
FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmBtn.TextSize = 14
FarmBtn.Font = Enum.Font.GothamBold
FarmBtn.Parent = MainFrame

local FarmBtnCorner = Instance.new("UICorner")
FarmBtnCorner.CornerRadius = UDim.new(0, 8)
FarmBtnCorner.Parent = FarmBtn

local FarmBtnStroke = Instance.new("UIStroke")
FarmBtnStroke.Color = Color3.fromRGB(255, 85, 0)
FarmBtnStroke.Thickness = 1
FarmBtnStroke.Parent = FarmBtn

-- ================= ЛОГИКА ИНТЕРФЕЙСА =================
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ToggleBtn.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleBtn.Visible = true
end)

local isDraggingSlider = false
SliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSlider = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSlider = false
    end
end)

RunService.RenderStepped:Connect(function()
    if isDraggingSlider then
        local mousePos = UserInputService:GetMouseLocation().X
        local bgPos = SliderBG.AbsolutePosition.X
        local bgSize = SliderBG.AbsoluteSize.X
        local percent = math.clamp((mousePos - bgPos) / bgSize, 0, 1)
        
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        -- Скорость от 5 (медленно, сейвово) до 50 (супер быстро)
        farmSpeed = math.floor(5 + (percent * 45))
        SpeedLabel.Text = "Скорость полета: " .. farmSpeed
    end
end)

-- ================= ЛОГИКА ФАРМА =================
local function getCandy()
    local normal = workspace:FindFirstChild("Normal")
    if normal then
        local coinContainer = normal:FindFirstChild("CoinContainer")
        if coinContainer then
            for _, coin in ipairs(coinContainer:GetChildren()) do
                if coin:IsA("BasePart") and coin.Transparency < 1 and coin.Position.Y > -100 then
                    return coin
                end
            end
        end
    end
    return nil
end

local currentTween = nil

local function stopFarm()
    isFarming = false
    FarmBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    FarmBtn.Text = "ЗАПУСТИТЬ ФАРМ"
    FarmBtnStroke.Color = Color3.fromRGB(255, 85, 0)
    if currentTween then currentTween:Cancel() end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.Anchored = false
    end
end

FarmBtn.MouseButton1Click:Connect(function()
    if isFarming then
        stopFarm()
    else
        isFarming = true
        collected = 0
        StatusText.Text = "Конфет: 0 / 50"
        FarmBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
        FarmBtn.Text = "ОСТАНОВИТЬ ФАРМ"
        FarmBtnStroke.Color = Color3.fromRGB(255, 255, 255)
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if isFarming then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local hrp = char.HumanoidRootPart
                local hum = char.Humanoid
                
                if hum.Health <= 0 then
                    stopFarm()
                    continue
                end

                if collected >= maxCoins then
                    StatusText.Text = "ЛИМИТ! Ожидание..."
                    stopFarm()
                    hum.Health = 0 -- Автоматический рип
                    continue
                end

                local candy = getCandy()
                if candy then
                    -- Отключаем коллизию, чтобы лететь сквозь стены
                    for _, v in ipairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end

                    -- Точка ровно НАД конфетой, чтобы не задеть текстуры пола
                    local targetPos = candy.Position + Vector3.new(0, 1.5, 0)
                    local distance = (hrp.Position - targetPos).Magnitude
                    
                    -- Рассчитываем время полета на основе выбранной скорости
                    local tweenTime = distance / farmSpeed
                    if tweenTime < 0.1 then tweenTime = 0.1 end

                    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
                    currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
                    
                    hrp.Anchored = true
                    currentTween:Play()
                    currentTween.Completed:Wait()
                    
                    if isFarming and candy and candy.Parent then
                        -- Эмуляция касания
                        if firetouchinterest then
                            firetouchinterest(hrp, candy, 0)
                            task.wait(0.05)
                            firetouchinterest(hrp, candy, 1)
                        end
                        
                        task.wait(0.1) -- Даем серверу долю секунды на регистрацию
                        
                        -- Проверяем, исчезла ли конфета
                        if not candy.Parent or candy.Transparency >= 1 then
                            collected = collected + 1
                            StatusText.Text = "Конфет: " .. collected .. " / 50"
                        end
                    end
                else
                    hrp.Anchored = false
                end
            end
        end
    end
end)
