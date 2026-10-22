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

-- ===== слова для поиска (допиши свои, маленькими буквами) =====
local BOLT_WORDS = {"lightning", "bolt", "speed", "молни"}
local COIN_WORDS = {"coin", "coins", "монет"}
local EVENT_WORDS = {"candy", "candies", "pumpkin", "halloween", "sweet", "treat", "lollipop",
    "jack", "ghost", "spooky", "orb", "конфет", "тыкв"}
local BLACK_WORDS = {"kill", "lava", "damage", "trap", "spike", "portal", "teleport", "spawn",
    "door", "shop", "sell", "buy", "death", "hurt", "void"}
-- кириллицу пишем без первой буквы: ловит и "Переполнен", и "переполнен"
local FULL_WORDS = {"ереполн", "ЕРЕПОЛН", "полон", "Полон", "ПОЛОН", "is full",
    "inventory full", "bag full", "backpack full"}

-- ===== цвета =====
local C = {
    bg = Color3.fromRGB(17, 17, 27), card = Color3.fromRGB(30, 30, 46),
    card2 = Color3.fromRGB(44, 44, 68), text = Color3.fromRGB(235, 235, 245),
    sub = Color3.fromRGB(150, 150, 175), accent = Color3.fromRGB(124, 92, 255),
    on = Color3.fromRGB(60, 190, 110), off = Color3.fromRGB(70, 70, 95),
    warn = Color3.fromRGB(240, 150, 50), bad = Color3.fromRGB(200, 80, 80),
}

-- ===== настройки =====
local S = {
    farm = true, bolts = true, coins = false, event = true, any = false,
    speed = 40, height = 0, rejoin = true,
    autoreset = false, limit = 50,
    black = false, dark = false, light = false,
    custom = {}, w = 235, h = 420,
}
pcall(function()
    if isfile(FILE) then
        for k, v in pairs(HttpService:JSONDecode(readfile(FILE))) do S[k] = v end
    end
end)
if type(S.custom) ~= "table" then S.custom = {} end
local function save() pcall(writefile, FILE, HttpService:JSONEncode(S)) end

local function hasWord(s, words)
    for _, w in ipairs(words) do
        if s:find(w, 1, true) then return true end
    end
    return false
end

local function viewport()
    local c = workspace.CurrentCamera
    return c and c.ViewportSize or Vector2.new(800, 400)
end

-- ===== основа интерфейса =====
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

-- ===== уведомления =====
local notifyBox = Instance.new("Frame", gui)
notifyBox.AnchorPoint = Vector2.new(1, 1)
notifyBox.Position = UDim2.new(1, -10, 1, -10)
notifyBox.Size = UDim2.fromOffset(240, 300)
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
    card.BackgroundColor3 = C.bg
    card.BorderSizePixel = 0
    card.GroupTransparency = 1
    card.ZIndex = 7
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local bar = Instance.new("Frame", card)
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = color or C.accent
    bar.BorderSizePixel = 0
    bar.ZIndex = 7

    local lbl = Instance.new("TextLabel", card)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Size = UDim2.new(1, -16, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Text = text
    lbl.ZIndex = 7

    TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0}):Play()

    task.delay(2.8, function()
        if not card.Parent then return end
        local t = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(1.2, 0, 0, 0), GroupTransparency = 1})
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
            notify("🔄 Перезаход...", C.warn)
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
local targets, last, targetCount = {}, 0, 0
local visited = setmetatable({}, {__mode = "k"})
local fti = firetouchinterest

local function nameOf(o)
    local s, p = o.Name, o.Parent
    for _ = 1, 3 do
        if p and p ~= workspace and p ~= game then
            s = s .. "/" .. p.Name
            p = p.Parent
        else
            break
        end
    end
    return s:lower()
end

local function kind(o)
    if not o:IsA("BasePart") or not o:FindFirstChildOfClass("TouchInterest") then return nil end
    local m = o:FindFirstAncestorOfClass("Model")
    if m and Players:GetPlayerFromCharacter(m) then return nil end
    local n = nameOf(o)
    for _, w in ipairs(S.custom) do
        if n:find(w, 1, true) then return "custom" end
    end
    if hasWord(n, COIN_WORDS) then return "coin" end
    if hasWord(n, BOLT_WORDS) then return "bolt" end
    if hasWord(n, EVENT_WORDS) then return "event" end
    if not hasWord(n, BLACK_WORDS) then return "any" end
    return nil
end

local function rescan()
    targets = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        local k = kind(o)
        if k == "custom" or (k == "bolt" and S.bolts) or (k == "coin" and S.coins)
            or (k == "event" and S.event) or (k == "any" and S.any) then
            table.insert(targets, o)
        end
    end
    targetCount = #targets
end

local function touch(root, part)
    if fti then
        pcall(fti, root, part, 0)
        pcall(fti, root, part, 1)
    else
        root.CFrame = part.CFrame
    end
end

RunService.Heartbeat:Connect(function(dt)
    if not S.farm then return end
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return end

    if os.clock() - last > 1.5 then rescan() last = os.clock() end

    local nearest, best = nil, math.huge
    local now = os.clock()
    for _, t in ipairs(targets) do
        if t.Parent and not (visited[t] and now - visited[t] < 3) then
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
        touch(root, nearest)
        visited[nearest] = os.clock()
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
    notify("🎒 Рюкзак полон, ресет", C.warn)
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

-- ===== функции экрана (все обратимые) =====
local hooks = {}

local function newSaver()
    local store = setmetatable({}, {__mode = "k"})
    local function remember(o, props)
        if store[o] then return end
        local t = {}
        for _, p in ipairs(props) do t[p] = o[p] end
        store[o] = t
    end
    local function restore()
        for o, t in pairs(store) do
            for p, v in pairs(t) do pcall(function() o[p] = v end) end
        end
        store = setmetatable({}, {__mode = "k"})
    end
    return remember, restore
end

-- чёрный экран
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

-- тёмная графика
local dRemember, dRestore = newSaver()
local darkOn, darkConn, darkLight, darkSkies = false, nil, nil, {}

local function darken(o)
    if o:IsA("BasePart") then
        dRemember(o, {"Material", "Color", "CastShadow"})
        o.Material = Enum.Material.SmoothPlastic
        o.Color = Color3.fromRGB(35, 35, 35)
        o.CastShadow = false
    elseif o:IsA("Decal") or o:IsA("Texture") then
        dRemember(o, {"Transparency"})
        o.Transparency = 1
    elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam")
        or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then
        dRemember(o, {"Enabled"})
        o.Enabled = false
    end
end

hooks.dark = function(on)
    if on == darkOn then return end
    darkOn = on
    if on then
        darkLight = {
            Brightness = Lighting.Brightness,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
        }
        Lighting.Brightness = 0
        Lighting.Ambient = Color3.fromRGB(20, 20, 20)
        Lighting.OutdoorAmbient = Color3.fromRGB(20, 20, 20)
        for _, o in ipairs(Lighting:GetChildren()) do
            if o:IsA("Sky") then
                table.insert(darkSkies, o)
                o.Parent = nil
            end
        end
        for _, o in ipairs(workspace:GetDescendants()) do pcall(darken, o) end
        darkConn = workspace.DescendantAdded:Connect(function(o) pcall(darken, o) end)
    else
        if darkConn then darkConn:Disconnect() darkConn = nil end
        dRestore()
        if darkLight then
            for k, v in pairs(darkLight) do Lighting[k] = v end
            darkLight = nil
        end
        for _, s in ipairs(darkSkies) do s.Parent = Lighting end
        darkSkies = {}
    end
end

-- облегчение
local lRemember, lRestore = newSaver()
local lightOn, lightSaved = false, nil

hooks.light = function(on)
    if on == lightOn then return end
    lightOn = on
    pcall(function() setfpscap(on and 20 or 60) end)
    if on then
        lightSaved = {shadows = Lighting.GlobalShadows}
        pcall(function()
            lightSaved.q = settings().Rendering.QualityLevel
            settings().Rendering.QualityLevel = 1
        end)
        Lighting.GlobalShadows = false
        for _, o in ipairs(Lighting:GetChildren()) do
            if o:IsA("PostEffect") then
                lRemember(o, {"Enabled"})
                o.Enabled = false
            end
        end
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") then
                lRemember(o, {"Enabled"})
                o.Enabled = false
            end
        end
    else
        lRestore()
        if lightSaved then
            Lighting.GlobalShadows = lightSaved.shadows
            if lightSaved.q then
                pcall(function() settings().Rendering.QualityLevel = lightSaved.q end)
            end
            lightSaved = nil
        end
    end
end

-- ===== круглая кнопка =====
local cx, cy = 10, viewport().Y * 0.3
local circle = Instance.new("TextButton", gui)
circle.Size = UDim2.fromOffset(52, 52)
circle.Position = UDim2.fromOffset(cx, cy)
circle.BackgroundColor3 = Color3.new(1, 1, 1)
circle.TextColor3 = Color3.new(1, 1, 1)
circle.Font = Enum.Font.GothamBold
circle.TextSize = 26
circle.Text = "⚡"
circle.AutoButtonColor = false
circle.ZIndex = 5
Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
local cGrad = Instance.new("UIGradient", circle)
cGrad.Color = ColorSequence.new(Color3.fromRGB(150, 90, 255), Color3.fromRGB(255, 120, 60))
cGrad.Rotation = 45
local cStroke = Instance.new("UIStroke", circle)
cStroke.Thickness = 3
cStroke.Color = Color3.new(1, 1, 1)

local function updateCircle()
    TweenService:Create(cStroke, TweenInfo.new(0.2),
        {Color = S.farm and C.on or Color3.new(1, 1, 1)}):Play()
end
hooks.farm = function() updateCircle() end

-- ===== меню =====
local frame = Instance.new("CanvasGroup", gui)
frame.BackgroundColor3 = C.bg
frame.BorderSizePixel = 0
frame.ZIndex = 6
frame.Visible = false
frame.GroupTransparency = 1
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
local fStroke = Instance.new("UIStroke", frame)
fStroke.Color = C.accent
fStroke.Transparency = 0.5
fStroke.Thickness = 1.5
local scale = Instance.new("UIScale", frame)
scale.Scale = 0.85

local function clampSize()
    local vp = viewport()
    S.w = math.clamp(S.w, 190, math.max(190, vp.X - 20))
    S.h = math.clamp(S.h, 260, math.max(260, vp.Y - 20))
    frame.Size = UDim2.fromOffset(S.w, S.h)
end

local function placeMenu()
    local vp = viewport()
    local x, y = cx, cy + 58
    if x + S.w > vp.X - 5 then x = vp.X - S.w - 5 end
    if y + S.h > vp.Y - 5 then y = cy - S.h - 6 end
    frame.Position = UDim2.fromOffset(math.max(5, x), math.max(5, y))
end

clampSize()
placeMenu()

-- шапка
local title = Instance.new("TextLabel", frame)
title.Position = UDim2.new(0, 12, 0, 0)
title.Size = UDim2.new(1, -50, 0, 34)
title.BackgroundTransparency = 1
title.TextColor3 = C.text
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "🎃 Farm Hub"

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Position = UDim2.new(1, -34, 0, 4)
closeBtn.Size = UDim2.fromOffset(26, 26)
closeBtn.BackgroundColor3 = C.card
closeBtn.TextColor3 = C.sub
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Text = "✕"
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

-- вкладки
local tabBar = Instance.new("Frame", frame)
tabBar.Position = UDim2.new(0, 6, 0, 36)
tabBar.Size = UDim2.new(1, -12, 0, 28)
tabBar.BackgroundTransparency = 1

local pages, tabs = {}, {}
local tabNames = {"⚡ Фарм", "🌙 Экран", "🔧 Сервис"}

for i = 1, 3 do
    local sf = Instance.new("ScrollingFrame", frame)
    sf.Position = UDim2.new(0, 6, 0, 70)
    sf.Size = UDim2.new(1, -12, 1, -98)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 3
    sf.CanvasSize = UDim2.new()
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Visible = (i == 1)
    local lay = Instance.new("UIListLayout", sf)
    lay.Padding = UDim.new(0, 6)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    pages[i] = sf

    local tb = Instance.new("TextButton", tabBar)
    tb.Size = UDim2.new(1 / 3, -4, 1, 0)
    tb.Position = UDim2.new((i - 1) / 3, 2, 0, 0)
    tb.BackgroundColor3 = (i == 1) and C.accent or C.card
    tb.TextColor3 = C.text
    tb.Font = Enum.Font.GothamBold
    tb.TextSize = 12
    tb.Text = tabNames[i]
    tb.AutoButtonColor = false
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
    tabs[i] = tb
end

local function showTab(n)
    for i = 1, 3 do
        pages[i].Visible = (i == n)
        TweenService:Create(tabs[i], TweenInfo.new(0.15),
            {BackgroundColor3 = (i == n) and C.accent or C.card}):Play()
    end
end
for i = 1, 3 do
    tabs[i].MouseButton1Click:Connect(function() showTab(i) end)
end

-- ===== элементы меню =====
local ord = {}
local function nextOrder(p)
    ord[p] = (ord[p] or 0) + 1
    return ord[p]
end

local function card(page, h)
    local f = Instance.new("Frame", page)
    f.LayoutOrder = nextOrder(page)
    f.Size = UDim2.new(1, -6, 0, h or 38)
    f.BackgroundColor3 = C.card
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    return f
end

local function rowLabels(row, icon, label)
    local ic = Instance.new("TextLabel", row)
    ic.Position = UDim2.new(0, 8, 0, 0)
    ic.Size = UDim2.new(0, 26, 1, 0)
    ic.BackgroundTransparency = 1
    ic.TextSize = 18
    ic.Font = Enum.Font.Gotham
    ic.TextColor3 = C.text
    ic.Text = icon
    local nm = Instance.new("TextLabel", row)
    nm.Position = UDim2.new(0, 38, 0, 0)
    nm.Size = UDim2.new(1, -110, 1, 0)
    nm.BackgroundTransparency = 1
    nm.TextColor3 = C.text
    nm.Font = Enum.Font.Gotham
    nm.TextSize = 14
    nm.TextXAlignment = Enum.TextXAlignment.Left
    nm.TextTruncate = Enum.TextTruncate.AtEnd
    nm.Text = label
end

local function section(page, text)
    local l = Instance.new("TextLabel", page)
    l.LayoutOrder = nextOrder(page)
    l.Size = UDim2.new(1, -6, 0, 18)
    l.BackgroundTransparency = 1
    l.TextColor3 = C.accent
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = "  " .. text
end

local function switchRow(page, icon, label, key)
    local row = card(page, 38)
    rowLabels(row, icon, label)
    local pill = Instance.new("Frame", row)
    pill.AnchorPoint = Vector2.new(1, 0.5)
    pill.Position = UDim2.new(1, -10, 0.5, 0)
    pill.Size = UDim2.fromOffset(42, 22)
    pill.BackgroundColor3 = C.off
    pill.BorderSizePixel = 0
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", pill)
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = UDim2.new(0, 2, 0.5, 0)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function render(anim)
        local info = TweenInfo.new(anim and 0.15 or 0)
        local on = S[key]
        TweenService:Create(pill, info, {BackgroundColor3 = on and C.on or C.off}):Play()
        TweenService:Create(knob, info, {Position = UDim2.new(0, on and 22 or 2, 0.5, 0)}):Play()
    end
    render(false)

    local hit = Instance.new("TextButton", row)
    hit.Size = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        render(true)
        save()
        last = 0
        if hooks[key] then pcall(hooks[key], S[key]) end
        notify(icon .. " " .. label .. ": " .. (S[key] and "ВКЛ" or "ВЫКЛ"), S[key] and C.on or C.bad)
    end)
end

local function numberRow(page, icon, label, key)
    local row = card(page, 38)
    rowLabels(row, icon, label)
    local tb = Instance.new("TextBox", row)
    tb.AnchorPoint = Vector2.new(1, 0.5)
    tb.Position = UDim2.new(1, -8, 0.5, 0)
    tb.Size = UDim2.fromOffset(62, 26)
    tb.BackgroundColor3 = C.card2
    tb.TextColor3 = C.text
    tb.Font = Enum.Font.GothamBold
    tb.TextSize = 14
    tb.ClearTextOnFocus = false
    tb.Text = tostring(S[key])
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
    tb.FocusLost:Connect(function()
        local n = tonumber(tb.Text)
        if n then
            S[key] = n
            save()
            notify(icon .. " " .. label .. ": " .. n)
        else
            tb.Text = tostring(S[key])
        end
    end)
end

local function actionRow(page, icon, label, cb)
    local row = card(page, 38)
    rowLabels(row, icon, label)
    local arrow = Instance.new("TextLabel", row)
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -10, 0.5, 0)
    arrow.Size = UDim2.fromOffset(20, 20)
    arrow.BackgroundTransparency = 1
    arrow.TextColor3 = C.sub
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 16
    arrow.Text = "›"
    local hit = Instance.new("TextButton", row)
    hit.Size = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.MouseButton1Click:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.08), {BackgroundColor3 = C.card2}):Play()
        task.delay(0.12, function()
            TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = C.card}):Play()
        end)
        cb()
    end)
end

local function infoRow(page, text, h)
    local row = card(page, h or 44)
    local l = Instance.new("TextLabel", row)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.Size = UDim2.new(1, -20, 1, 0)
    l.BackgroundTransparency = 1
    l.TextColor3 = C.sub
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextWrapped = true
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = text
    return l
end

-- ===== вкладка 1: фарм =====
local p1, p2, p3 = pages[1], pages[2], pages[3]

section(p1, "ГЛАВНОЕ")
switchRow(p1, "▶", "Автофарм", "farm")
local statusLbl = infoRow(p1, "🎯 Целей найдено: 0", 32)
section(p1, "ЦЕЛИ")
switchRow(p1, "⚡", "Молнии", "bolts")
switchRow(p1, "🪙", "Монеты", "coins")
switchRow(p1, "🎃", "Конфеты и тыквы", "event")
switchRow(p1, "🧲", "Все касаемые", "any")
section(p1, "ПАРАМЕТРЫ")
numberRow(p1, "🚀", "Скорость", "speed")
numberRow(p1, "↕", "Высота", "height")
section(p1, "РЮКЗАК")
switchRow(p1, "🎒", "Авторесет", "autoreset")
numberRow(p1, "🔢", "Лимит", "limit")

task.spawn(function()
    while task.wait(1) do
        statusLbl.Text = "🎯 Целей найдено: " .. targetCount
    end
end)

-- ===== вкладка 2: экран =====
section(p2, "ЭКРАН")
switchRow(p2, "⬛", "Чёрный экран", "black")
switchRow(p2, "🌑", "Тёмная графика", "dark")
switchRow(p2, "🍃", "Облегчение", "light")
infoRow(p2, "Для ночи: включи «Чёрный экран» и поставь яркость телефона на минимум. Всё обратимо: выключил, и картинка вернулась.", 64)

-- ===== вкладка 3: сервис =====
section(p3, "ЗАЩИТА")
switchRow(p3, "🔄", "Перезаход (один 30с)", "rejoin")
section(p3, "ИНСТРУМЕНТЫ")

local function findNearby()
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then notify("Нет персонажа", C.bad) return end

    local groups = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") and o:FindFirstChildOfClass("TouchInterest") then
            local m = o:FindFirstAncestorOfClass("Model")
            if not (m and Players:GetPlayerFromCharacter(m)) then
                local d = (o.Position - root.Position).Magnitude
                if d <= 120 then
                    local g = groups[o.Name] or {name = o.Name, n = 0, d = math.huge}
                    g.n += 1
                    if d < g.d then g.d = d end
                    groups[o.Name] = g
                end
            end
        end
    end

    for _, ch in ipairs(p3:GetChildren()) do
        if ch.Name == "res" then ch:Destroy() end
    end

    local arr = {}
    for _, g in pairs(groups) do table.insert(arr, g) end
    table.sort(arr, function(a, b) return a.d < b.d end)

    if #arr == 0 then
        notify("Рядом ничего не найдено", C.warn)
        return
    end
    notify("Найдено видов: " .. #arr .. ". Смотри внизу вкладки", C.on)

    for i = 1, math.min(#arr, 10) do
        local g = arr[i]
        local row = card(p3, 38)
        row.Name = "res"
        row.LayoutOrder = 100 + i
        rowLabels(row, "➕", g.name .. "  ×" .. g.n .. "  (" .. math.floor(g.d) .. "м)")
        local hit = Instance.new("TextButton", row)
        hit.Size = UDim2.new(1, 0, 1, 0)
        hit.BackgroundTransparency = 1
        hit.Text = ""
        hit.MouseButton1Click:Connect(function()
            local key = g.name:lower()
            for _, w in ipairs(S.custom) do
                if w == key then notify("Уже добавлено", C.warn) return end
            end
            table.insert(S.custom, key)
            save()
            last = 0
            row.BackgroundColor3 = C.on
            notify("➕ Добавлено: " .. g.name, C.on)
        end)
    end
end

actionRow(p3, "🔍", "Найти рядом", findNearby)
actionRow(p3, "💀", "Ресет сейчас", function()
    notify("💀 Ресет персонажа", C.warn)
    doReset()
end)
actionRow(p3, "🗑", "Сбросить свои цели", function()
    S.custom = {}
    save()
    last = 0
    notify("🗑 Свои цели сброшены", C.warn)
end)
actionRow(p3, "📋", "Список объектов", function()
    local seen = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") and o:FindFirstChildOfClass("TouchInterest") and not seen[o.Name] then
            seen[o.Name] = true
            print(o:GetFullName())
        end
    end
    notify("📋 Список в консоли")
end)
actionRow(p3, "🔤", "Список текстов", function()
    local pg = lp:WaitForChild("PlayerGui")
    for _, o in ipairs(pg:GetDescendants()) do
        if (o:IsA("TextLabel") or o:IsA("TextButton")) and not o:IsDescendantOf(gui)
            and o.Text ~= "" and #o.Text < 60 and isShown(o) then
            print(o:GetFullName() .. " = " .. o.Text)
        end
    end
    notify("🔤 Список в консоли")
end)

-- ===== уголок для изменения размера =====
local handle = Instance.new("TextButton", frame)
handle.Size = UDim2.fromOffset(28, 28)
handle.Position = UDim2.new(1, -28, 1, -28)
handle.BackgroundTransparency = 1
handle.TextColor3 = C.accent
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

-- ===== открытие меню и перетаскивание кружка =====
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
closeBtn.MouseButton1Click:Connect(function() setMenu(false) end)

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
            cx = math.clamp(dCirc.X + d.X, 0, vp.X - 52)
            cy = math.clamp(dCirc.Y + d.Y, 0, vp.Y - 52)
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
for _, k in ipairs({"black", "dark", "light"}) do
    if S[k] then pcall(hooks[k], true) end
end
updateCircle()
notify("🎃 Скрипт запущен", C.on)
