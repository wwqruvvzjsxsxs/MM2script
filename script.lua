local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer
local FILE = "farm_settings.json"

-- слова в названиях объектов (допиши свои)
local BOLT_WORDS = {"lightning", "bolt", "speed", "молни"}
local COIN_WORDS = {"coin", "coins", "монет"}

-- слова в надписи о полном рюкзаке (допиши свои)
-- кириллицу пишем без первой буквы, чтобы ловило и "Переполнен", и "переполнен"
local FULL_WORDS = {"ереполн", "ЕРЕПОЛН", "is full", "inventory full", "bag full", "backpack full", "олон"}

-- ===== настройки =====
local S = {
    farm = true, bolts = true, coins = false,
    speed = 40, height = 0, rejoin = true,
    autoreset = false, limit = 50,
    black = false, dark = false, light = false,
    w = 200, h = 380,
}
pcall(function()
    if isfile(FILE) then
        for k, v in pairs(HttpService:JSONDecode(readfile(FILE))) do S[k] = v end
    end
end)
local function save() pcall(writefile, FILE, HttpService:JSONEncode(S)) end

-- ===== определение целей =====
local function hasWord(s, words)
    for _, w in ipairs(words) do
        if s:find(w, 1, true) then return true end
    end
end

local function kind(o)
    if not o:IsA("BasePart") or not o:FindFirstChildOfClass("TouchInterest") then return end
    local n = (o.Name .. (o.Parent and o.Parent.Name or "")):lower()
    if hasWord(n, COIN_WORDS) then return "coin" end
    if hasWord(n, BOLT_WORDS) then return "bolt" end
end

-- ===== интерфейс: основа =====
pcall(function()
    local old = ((gethui and gethui()) or game:GetService("CoreGui")):FindFirstChild("FarmGui")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "FarmGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

local cam = workspace.CurrentCamera
local function viewport() return cam and cam.ViewportSize or Vector2.new(800, 400) end

-- ===== уведомления =====
local notifyBox = Instance.new("Frame", gui)
notifyBox.AnchorPoint = Vector2.new(1, 1)
notifyBox.Position = UDim2.new(1, -10, 1, -10)
notifyBox.Size = UDim2.fromOffset(230, 300)
notifyBox.BackgroundTransparency = 1
notifyBox.ZIndex = 7
local nl = Instance.new("UIListLayout", notifyBox)
nl.Padding = UDim.new(0, 6)
nl.SortOrder = Enum.SortOrder.LayoutOrder
nl.HorizontalAlignment = Enum.HorizontalAlignment.Right
nl.VerticalAlignment = Enum.VerticalAlignment.Bottom

local nCount = 0
local function notify(text, color)
    nCount += 1
    local holder = Instance.new("Frame", notifyBox)
    holder.LayoutOrder = nCount
    holder.Size = UDim2.new(1, 0, 0, 36)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 7

    local card = Instance.new("CanvasGroup", holder)
    card.Size = UDim2.new(1, 0, 1, 0)
    card.Position = UDim2.new(1.2, 0, 0, 0)
    card.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    card.BorderSizePixel = 0
    card.GroupTransparency = 1
    card.ZIndex = 7
    Instance.new("UICorner", card)

    local bar = Instance.new("Frame", card)
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = color or Color3.fromRGB(110, 90, 240)
    bar.BorderSizePixel = 0
    bar.ZIndex = 7

    local lbl = Instance.new("TextLabel", card)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Size = UDim2.new(1, -16, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Text = text
    lbl.ZIndex = 7

    local inInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(card, inInfo, {Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0}):Play()

    task.delay(2.8, function()
        if not card.Parent then return end
        local outInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local t = TweenService:Create(card, outInfo, {Position = UDim2.new(1.2, 0, 0, 0), GroupTransparency = 1})
        t.Completed:Connect(function() holder:Destroy() end)
        t:Play()
    end)
end

-- ===== антиафк =====
lp.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ===== перезаход, если один 30 секунд =====
task.spawn(function()
    local alone = 0
    while task.wait(1) do
        alone = (#Players:GetPlayers() <= 1) and alone + 1 or 0
        if S.rejoin and alone >= 30 then
            notify("Перезаход...", Color3.fromRGB(220, 150, 50))
            task.wait(1)
            pcall(function() TeleportService:Teleport(game.PlaceId, lp) end)
            alone = 0
        end
    end
end)

-- ===== ноуклип =====
RunService.Stepped:Connect(function()
    if not S.farm or not lp.Character then return end
    for _, p in ipairs(lp.Character:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- ===== автофарм =====
local targets, last = {}, 0
local function rescan()
    targets = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        local k = kind(o)
        if (k == "bolt" and S.bolts) or (k == "coin" and S.coins) then
            table.insert(targets, o)
        end
    end
end

RunService.Heartbeat:Connect(function(dt)
    if not S.farm then return end
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if os.clock() - last > 2 then rescan() last = os.clock() end

    local nearest, best = nil, math.huge
    for _, t in ipairs(targets) do
        if t.Parent then
            local d = (t.Position - root.Position).Magnitude
            if d < best then nearest, best = t, d end
        end
    end
    if not nearest then return end

    local target = nearest.Position + Vector3.new(0, S.height, 0)
    local dir = target - root.Position
    local step = S.speed * dt

    root.AssemblyLinearVelocity = Vector3.zero
    if dir.Magnitude <= step then
        root.CFrame = CFrame.new(target)
        firetouchinterest(root, nearest, 0)
        firetouchinterest(root, nearest, 1)
    else
        root.CFrame = root.CFrame + dir.Unit * step
    end
end)

-- ===== авторесет при полном рюкзаке =====
local lastReset = 0

local function doReset()
    pcall(function()
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end)
end

local function fullText(t)
    if t == "" then return false end
    local l = t:lower()
    for _, w in ipairs(FULL_WORDS) do
        if l:find(w, 1, true) or t:find(w, 1, true) then return true end
    end
    local a, b = t:match("(%d+)%s*/%s*(%d+)")
    if a and b and tonumber(b) == S.limit and tonumber(a) >= tonumber(b) then
        return true
    end
    return false
end

local function isShown(o)
    if o.TextTransparency and o.TextTransparency > 0.9 then return false end
    local cur = o
    while cur and cur ~= game do
        if cur:IsA("GuiObject") and not cur.Visible then return false end
        if cur:IsA("ScreenGui") and not cur.Enabled then return false end
        cur = cur.Parent
    end
    return true
end

local function checkLabel(o)
    if not S.autoreset then return end
    if os.clock() - lastReset < 12 then return end
    if not (o:IsA("TextLabel") or o:IsA("TextButton")) then return end
    if o:IsDescendantOf(gui) then return end
    if not fullText(o.Text) then return end
    if not isShown(o) then return end
    lastReset = os.clock()
    notify("Рюкзак полон, ресет", Color3.fromRGB(220, 150, 50))
    doReset()
end

task.spawn(function()
    local pg = lp:WaitForChild("PlayerGui")
    local function watch(o)
        if o:IsA("TextLabel") or o:IsA("TextButton") then
            checkLabel(o)
            o:GetPropertyChangedSignal("Text"):Connect(function() checkLabel(o) end)
        end
    end
    for _, o in ipairs(pg:GetDescendants()) do watch(o) end
    pg.DescendantAdded:Connect(watch)
    while task.wait(1) do
        if S.autoreset then
            for _, o in ipairs(pg:GetDescendants()) do checkLabel(o) end
        end
    end
end)

-- ===== функции экрана =====
local hooks = {}

local overlay = Instance.new("Frame", gui)
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.new(0, 0, 0)
overlay.BorderSizePixel = 0
overlay.ZIndex = 1
overlay.Visible = false

hooks.black = function(on)
    overlay.Visible = on
    pcall(function() RunService:Set3dRenderingEnabled(not on) end)
end

local function darken(o)
    if o:IsA("BasePart") then
        o.Material = Enum.Material.SmoothPlastic
        o.Color = Color3.fromRGB(35, 35, 35)
        o.CastShadow = false
    elseif o:IsA("Decal") or o:IsA("Texture") then
        o.Transparency = 1
    elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam")
        or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then
        o.Enabled = false
    end
end

local darkConn
hooks.dark = function(on)
    if not on then return end -- обратно только перезаходом
    Lighting.Brightness = 0
    Lighting.Ambient = Color3.fromRGB(20, 20, 20)
    Lighting.OutdoorAmbient = Color3.fromRGB(20, 20, 20)
    for _, o in ipairs(Lighting:GetChildren()) do
        if o:IsA("Sky") then o:Destroy() end
    end
    for _, o in ipairs(workspace:GetDescendants()) do pcall(darken, o) end
    if not darkConn then
        darkConn = workspace.DescendantAdded:Connect(function(o) pcall(darken, o) end)
    end
end

hooks.light = function(on)
    pcall(function() setfpscap(on and 20 or 60) end)
    if not on then return end
    pcall(function() settings().Rendering.QualityLevel = 1 end)
    Lighting.GlobalShadows = false
    for _, o in ipairs(Lighting:GetChildren()) do
        if o:IsA("PostEffect") then o.Enabled = false end
    end
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") then
            pcall(function() o.Enabled = false end)
        end
    end
end

-- ===== круглая кнопка =====
local cx, cy = 10, viewport().Y * 0.3
local circle = Instance.new("TextButton", gui)
circle.Size = UDim2.fromOffset(48, 48)
circle.Position = UDim2.fromOffset(cx, cy)
circle.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
circle.TextColor3 = Color3.new(1, 1, 1)
circle.Font = Enum.Font.GothamBold
circle.TextSize = 22
circle.Text = "F"
circle.AutoButtonColor = false
circle.ZIndex = 5
Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

-- ===== меню =====
local frame = Instance.new("CanvasGroup", gui)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.ZIndex = 6
frame.Visible = false
frame.GroupTransparency = 1
Instance.new("UICorner", frame)
local scale = Instance.new("UIScale", frame)
scale.Scale = 0.85

local function clampSize()
    local vp = viewport()
    S.w = math.clamp(S.w, 170, math.max(170, vp.X - 20))
    S.h = math.clamp(S.h, 200, math.max(200, vp.Y - 20))
    frame.Size = UDim2.fromOffset(S.w, S.h)
end

local function placeMenu()
    local vp = viewport()
    local x, y = cx, cy + 54
    if x + S.w > vp.X - 5 then x = vp.X - S.w - 5 end
    if y + S.h > vp.Y - 5 then y = cy - S.h - 6 end
    frame.Position = UDim2.fromOffset(math.max(5, x), math.max(5, y))
end

clampSize()
placeMenu()

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 26)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(200, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Text = "Автофарм"

local list = Instance.new("ScrollingFrame", frame)
list.Position = UDim2.new(0, 4, 0, 28)
list.Size = UDim2.new(1, -8, 1, -56)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local order = 0
local ON, OFF = Color3.fromRGB(50, 130, 80), Color3.fromRGB(55, 55, 80)

local function styleBtn(b)
    order += 1
    b.LayoutOrder = order
    b.Size = UDim2.new(1, -6, 0, 32)
    b.BackgroundColor3 = OFF
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.AutoButtonColor = true
    Instance.new("UICorner", b)
end

local function toggle(label, key)
    local b = Instance.new("TextButton", list)
    styleBtn(b)
    local function refresh()
        b.Text = label .. ": " .. (S[key] and "ВКЛ" or "ВЫКЛ")
        b.BackgroundColor3 = S[key] and ON or OFF
    end
    refresh()
    b.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        refresh()
        save()
        last = 0
        if hooks[key] then pcall(hooks[key], S[key]) end
        notify(label .. ": " .. (S[key] and "ВКЛ" or "ВЫКЛ"),
            S[key] and Color3.fromRGB(50, 170, 100) or Color3.fromRGB(170, 80, 80))
    end)
end

local function input(label, key)
    local row = Instance.new("Frame", list)
    order += 1
    row.LayoutOrder = order
    row.Size = UDim2.new(1, -6, 0, 32)
    row.BackgroundColor3 = OFF
    Instance.new("UICorner", row)

    local l = Instance.new("TextLabel", row)
    l.Size = UDim2.new(0.5, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.new(1, 1, 1)
    l.Font = Enum.Font.Gotham
    l.TextSize = 14
    l.Text = label

    local tb = Instance.new("TextBox", row)
    tb.Position = UDim2.new(0.5, 0, 0, 3)
    tb.Size = UDim2.new(0.5, -4, 1, -6)
    tb.BackgroundColor3 = Color3.fromRGB(75, 75, 105)
    tb.TextColor3 = Color3.new(1, 1, 1)
    tb.Font = Enum.Font.Gotham
    tb.TextSize = 14
    tb.Text = tostring(S[key])
    Instance.new("UICorner", tb)
    tb.FocusLost:Connect(function()
        local n = tonumber(tb.Text)
        if n then
            S[key] = n
            save()
            notify(label .. ": " .. n)
        else
            tb.Text = tostring(S[key])
        end
    end)
end

local function action(label, cb)
    local b = Instance.new("TextButton", list)
    styleBtn(b)
    b.Text = label
    b.MouseButton1Click:Connect(cb)
end

toggle("Автофарм", "farm")
toggle("Молнии", "bolts")
toggle("Монеты", "coins")
toggle("Перезаход", "rejoin")
toggle("Авторесет", "autoreset")
input("Лимит", "limit")
input("Скорость", "speed")
input("Высота", "height")
toggle("Чёрный экран", "black")
toggle("Тёмная графика", "dark")
toggle("Облегчение", "light")

action("Ресет сейчас", function()
    notify("Ресет персонажа", Color3.fromRGB(220, 150, 50))
    doReset()
end)

action("Список объектов", function()
    local seen = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") and o:FindFirstChildOfClass("TouchInterest") and not seen[o.Name] then
            seen[o.Name] = true
            print(o:GetFullName())
        end
    end
    notify("Список выведен в консоль")
end)

action("Список текстов", function()
    local pg = lp:WaitForChild("PlayerGui")
    for _, o in ipairs(pg:GetDescendants()) do
        if (o:IsA("TextLabel") or o:IsA("TextButton")) and not o:IsDescendantOf(gui)
            and o.Text ~= "" and #o.Text < 60 and isShown(o) then
            print(o:GetFullName() .. " = " .. o.Text)
        end
    end
    notify("Список выведен в консоль")
end)

-- ===== уголок для изменения размера =====
local handle = Instance.new("TextButton", frame)
handle.Size = UDim2.fromOffset(28, 28)
handle.Position = UDim2.new(1, -28, 1, -28)
handle.BackgroundTransparency = 1
handle.TextColor3 = Color3.fromRGB(180, 180, 255)
handle.Font = Enum.Font.GothamBold
handle.TextSize = 20
handle.Text = "◢"
handle.ZIndex = 8

local resizing, rStart, rSize
handle.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        rStart = Vector2.new(i.Position.X, i.Position.Y)
        rSize = Vector2.new(S.w, S.h)
    end
end)

-- ===== перетаскивание кружка и открытие меню =====
local menuOpen = false
local function setMenu(open)
    menuOpen = open
    local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    if open then
        clampSize()
        placeMenu()
        frame.Visible = true
        TweenService:Create(frame, info, {GroupTransparency = 0}):Play()
        TweenService:Create(scale, info, {Scale = 1}):Play()
    else
        local t = TweenService:Create(frame, info, {GroupTransparency = 1})
        TweenService:Create(scale, info, {Scale = 0.85}):Play()
        t.Completed:Connect(function()
            if not menuOpen then frame.Visible = false end
        end)
        t:Play()
    end
end

local dragging, moved, dStart, dCirc
circle.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging, moved = true, false
        dStart = Vector2.new(i.Position.X, i.Position.Y)
        dCirc = Vector2.new(cx, cy)
    end
end)

UIS.InputChanged:Connect(function(i)
    local t = i.UserInputType
    if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseMovement then return end
    local p = Vector2.new(i.Position.X, i.Position.Y)
    if dragging then
        local d = p - dStart
        if d.Magnitude > 8 then moved = true end
        if moved then
            local vp = viewport()
            cx = math.clamp(dCirc.X + d.X, 0, vp.X - 48)
            cy = math.clamp(dCirc.Y + d.Y, 0, vp.Y - 48)
            circle.Position = UDim2.fromOffset(cx, cy)
            if menuOpen then placeMenu() end
        end
    elseif resizing then
        local d = p - rStart
        S.w, S.h = rSize.X + d.X, rSize.Y + d.Y
        clampSize()
    end
end)

UIS.InputEnded:Connect(function(i)
    local t = i.UserInputType
    if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then return end
    if dragging then
        dragging = false
        if not moved then setMenu(not menuOpen) end
    end
    if resizing then
        resizing = false
        placeMenu()
        save()
    end
end)

-- ===== применить сохранённое после перезахода =====
for k, f in pairs(hooks) do
    if S[k] then pcall(f, true) end
end

notify("Скрипт запущен", Color3.fromRGB(50, 170, 100))
