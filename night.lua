-- Ожидание базовой загрузки
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

-- Безопасный выбор родителя GUI
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
-- 1. ПОЛНЫЙ ЧЕРНЫЙ ЭКРАН (True Black #000000 для AMOLED)
-- =======================================================
local blackOverlay = Instance.new("TextButton")
blackOverlay.Name = "BlackOverlay"
blackOverlay.Size = UDim2.new(1, 0, 1, 0)
blackOverlay.Position = UDim2.new(0, 0, 0, 0)
blackOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackOverlay.BorderSizePixel = 0
blackOverlay.ZIndex = 1000000
blackOverlay.Text = "ДВАЖДЫ НАЖМИ НА ЭКРАН, ЧТОБЫ ВЕРНУТЬСЯ"
blackOverlay.TextColor3 = Color3.fromRGB(40, 40, 40)
blackOverlay.TextSize = 13
blackOverlay.Font = Enum.Font.GothamMedium
blackOverlay.Visible = false
blackOverlay.Parent = screenGui

local lastTap = 0
blackOverlay.MouseButton1Click:Connect(function()
    local now = tick()
    if now - lastTap < 0.45 then
        blackOverlay.Visible = false
    end
    lastTap = now
end)

-- =======================================================
-- 2. ГЛАВНОЕ ОКНО МЕНЮ С КОПИРАЙТОМ
-- =======================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 175, 0, 205) -- Немного увеличили высоту под футер
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

-- Авторский знак (закреплен внизу рамки, аккуратно и статично)
local watermark = Instance.new("TextLabel")
watermark.Name = "Watermark"
watermark.Size = UDim2.new(1, 0, 0, 24)
watermark.Position = UDim2.new(0, 0, 0, 175)
watermark.BackgroundTransparency = 1
watermark.Text = "CHLEN AN SY? 🍌🙅‍♀️"
watermark.TextColor3 = Color3.fromRGB(130, 130, 145)
watermark.Font = Enum.Font.GothamMedium
watermark.TextSize = 10
watermark.Parent = mainFrame

-- Логика черного экрана
blackBtn.MouseButton1Click:Connect(function()
    blackOverlay.Visible = true
end)

-- Логика NoLag
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

    for _, v in ipairs(workspace:GetDescendants()) do
        cleanObject(v)
    end
    workspace.DescendantAdded:Connect(cleanObject)

    if RunService:IsClient() and setrenderstepped then
        pcall(function() settings().Rendering.QualityLevel = 1 end)
    end
end)

-- Логика 15 FPS
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

-- Сворачивание панели
local miniToggle = Instance.new("TextButton")
miniToggle.Size = UDim2.new(0, 32, 0, 32)
miniToggle.Position = UDim2.new(0.04, 0, 0.25, 0)
miniToggle.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
miniToggle.Text = "🌙"
miniToggle.TextSize = 14
miniToggle.Visible = false
miniToggle.Active = true
miniToggle.Draggable = true
miniToggle.Parent = screenGui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(0, 8)
miniCorner.Parent = miniToggle

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    miniToggle.Visible = true
end)

miniToggle.MouseButton1Click:Connect(function()
    miniToggle.Visible = false
    mainFrame.Visible = true
end)
