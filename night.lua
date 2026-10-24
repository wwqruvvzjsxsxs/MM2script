-- =======================================================
-- НАСТРОЙКИ
-- =======================================================
local ICON_URL = "https://raw.githubusercontent.com/wwqruvvzjsxsxs/MM2script/main/file_00000000149081f4a364411ebc997e59.png"

-- Ожидание базовой загрузки игры
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

-- Безопасный контейнер под UI
local targetParent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui", 30)

-- Удаляем старое меню при повторном запуске
local oldGui = targetParent:FindFirstChild("NightFarmToolGui")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NightFarmToolGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999
screenGui.Parent = targetParent

-- =======================================================
-- 1. ЧЕРНЫЙ ЭКРАН (ПРОПУСКАЕТ ВСЕ КЛИКИ В ИГРУ)
-- =======================================================
local blackOverlay = Instance.new("Frame")
blackOverlay.Name = "BlackOverlay"
blackOverlay.Size = UDim2.new(1, 0, 1, 0)
blackOverlay.Position = UDim2.new(0, 0, 0, 0)
blackOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackOverlay.BorderSizePixel = 0
blackOverlay.ZIndex = 1000000
blackOverlay.Active = false -- Не блокирует нажатия автокликера
blackOverlay.Visible = false
blackOverlay.Parent = screenGui

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, 0, 0, 40)
infoText.Position = UDim2.new(0, 0, 0.45, 0)
infoText.BackgroundTransparency = 1
infoText.Text = "3 БЫСТРЫХ ТАПА ДЛЯ ВЫХОДА\n(КЛИКИ ИДУТ В ИГРУ)"
infoText.TextColor3 = Color3.fromRGB(35, 35, 35) -- Тусклый цвет, диоды выключены
infoText.TextSize = 13
infoText.Font = Enum.Font.GothamMedium
infoText.Parent = blackOverlay

-- Логика разблокировки по 3 быстрым тапам
local tapCount = 0
local lastTapTime = 0

local function checkTripleTap()
    if not blackOverlay.Visible then return end
    local now = tick()
    if now - lastTapTime < 0.5 then
        tapCount = tapCount + 1
    else
        tapCount = 1
    end
    lastTapTime = now

    if tapCount >= 3 then
        blackOverlay.Visible = false
        tapCount = 0
    end
end

UserInputService.TouchTapInWorld:Connect(checkTripleTap)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        checkTripleTap()
    end
end)

-- =======================================================
-- 2. ГЛАВНОЕ ОКНО МЕНЮ
-- =======================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 175, 0, 210)
mainFrame.Position = UDim2.new(0.04, 0, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🌙 Night Optimizer"
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = mainFrame

local function makeButton(text, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.88, 0, 0, 30)
    btn.Position = UDim2.new(0.06, 0, 0, yPos)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.Parent = mainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

local blackBtn = makeButton("🌑 Черный экран", 34, Color3.fromRGB(30, 30, 42))
local lagBtn   = makeButton("⚡ NoLag + Темнота", 69, Color3.fromRGB(48, 35, 64))
local fpsBtn   = makeButton("❄️ Ограничить 15 FPS", 104, Color3.fromRGB(25, 48, 42))
local closeBtn = makeButton("❌ Свернуть меню", 139, Color3.fromRGB(55, 25, 25))

-- Авторский знак / Водяной знак
local watermarkContainer = Instance.new("Frame")
watermarkContainer.Name = "WatermarkContainer"
watermarkContainer.Size = UDim2.new(0.88, 0, 0, 24)
watermarkContainer.Position = UDim2.new(0.06, 0, 0, 176)
watermarkContainer.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
watermarkContainer.BorderSizePixel = 0
watermarkContainer.Parent = mainFrame

local wmCorner = Instance.new("UICorner")
wmCorner.CornerRadius = UDim.new(0, 6)
wmCorner.Parent = watermarkContainer

local watermark = Instance.new("TextLabel")
watermark.Name = "WatermarkText"
watermark.Size = UDim2.new(1, 0, 1, 0)
watermark.BackgroundTransparency = 1
watermark.Text = "8====D • CHLEN AN SY"
watermark.TextColor3 = Color3.fromRGB(120, 120, 135)
watermark.Font = Enum.Font.Code
watermark.TextSize = 11
watermark.Parent = watermarkContainer

-- Включение черного экрана
blackBtn.MouseButton1Click:Connect(function()
    blackOverlay.Visible = true
    tapCount = 0
end)

-- Снижение нагрузки и темный режим
local lagReduced = false
lagBtn.MouseButton1Click:Connect(function()
    if lagReduced then return end
    lagReduced = true
    lagBtn.Text = "✓ Графика выключена"
    lagBtn.BackgroundColor3 = Color3.fromRGB(35, 80, 35)

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 0.1
    Lighting.ClockTime = 0

    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostProcessEffect") or v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("Clouds") then
            v:Destroy()
        end
    end

    local function cleanObject(v)
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("BasePart") and not v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        end
    end

    for _, v in ipairs(workspace:GetDescendants()) do cleanObject(v) end
    workspace.DescendantAdded:Connect(cleanObject)

    if RunService:IsClient() and setrenderstepped then
        pcall(function() settings().Rendering.QualityLevel = 1 end)
    end
end)

-- Ограничение кадров
local isCapped = false
fpsBtn.MouseButton1Click:Connect(function()
    if not isCapped then
        if setfpscap then
            setfpscap(15)
            fpsBtn.Text = "✓ 15 FPS активен"
            fpsBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 60)
            isCapped = true
        else
            fpsBtn.Text = "setfpscap не найден"
        end
    else
        if setfpscap then
            setfpscap(60)
            fpsBtn.Text = "❄️ Ограничить 15 FPS"
            fpsBtn.BackgroundColor3 = Color3.fromRGB(25, 48, 42)
            isCapped = false
        end
    end
end)

-- =======================================================
-- 3. ПЛАВАЮЩАЯ КРУГЛАЯ ИКОНКА (С ТВОИМ PNG)
-- =======================================================
local miniToggle = Instance.new("ImageButton")
miniToggle.Name = "MiniToggle"
miniToggle.Size = UDim2.new(0, 42, 0, 42)
miniToggle.Position = UDim2.new(0.04, 0, 0.25, 0)
miniToggle.BackgroundTransparency = 1
miniToggle.Visible = false
miniToggle.Active = true
miniToggle.Draggable = true
miniToggle.Parent = screenGui

-- Автоматическая обрезка в ровный круг
local roundCorner = Instance.new("UICorner")
roundCorner.CornerRadius = UDim.new(1, 0)
roundCorner.Parent = miniToggle

-- Загрузка PNG по ссылке в Дельту
task.spawn(function()
    local filename = "custom_night_icon.png"
    pcall(function()
        if not isfile or not isfile(filename) then
            if writefile then
                writefile(filename, game:HttpGet(ICON_URL))
            end
        end
        if getcustomasset then
            miniToggle.Image = getcustomasset(filename)
        elseif getsynasset then
            miniToggle.Image = getsynasset(filename)
        end
    end)
end)

-- Сворачивание и разворачивание
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    miniToggle.Visible = true
end)

miniToggle.MouseButton1Click:Connect(function()
    miniToggle.Visible = false
    mainFrame.Visible = true
end)
