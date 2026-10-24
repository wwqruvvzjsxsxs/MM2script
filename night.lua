local env = getgenv and getgenv() or _G
if env.NIGHT_HUB_JOB == game.JobId then
    print("[Night Hub] уже запущен на этом сервере")
    return
end
env.NIGHT_HUB_JOB = game.JobId

-- ===== НАСТРОЙКИ ЗАПУСКА =====
local DELAY = 75       -- через сколько секунд включить экран (0 = не включать сам)
local MODE = "black"   -- "black" = чёрный экран, "dim" = очень тёмный, но картинка остаётся
local SELF_URL = "https://raw.githubusercontent.com/wwqruvvzjsxsxs/MM2script/refs/heads/main/night.lua"

local ok, err = pcall(function()

print("[Night Hub] запуск...")
if not game:IsLoaded() then game.Loaded:Wait() end

-- после перезахода запуститься снова
local q = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
if q then q('loadstring(game:HttpGet("' .. SELF_URL .. '"))()') end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local Stats = game:GetService("Stats")
local lp = Players.LocalPlayer
local FILE = "night_settings.json"
local T0 = os.clock()

-- ===== цвета =====
local C = {
    bg = Color3.fromRGB(12, 14, 24), card = Color3.fromRGB(24, 28, 46),
    card2 = Color3.fromRGB(40, 46, 72), text = Color3.fromRGB(235, 238, 250),
    sub = Color3.fromRGB(140, 148, 175), accent = Color3.fromRGB(100, 125, 255),
    on = Color3.fromRGB(70, 190, 140), off = Color3.fromRGB(62, 68, 96),
    warn = Color3.fromRGB(240, 160, 60), bad = Color3.fromRGB(200, 85, 90),
}

-- ===== настройки =====
local S = {
    afk = true, black = false, clock = true, dim = false, dimv = 60,
    dark = false, light = false, fpsOn = false, fps = 20,
    mute = false, hideplr = false, hidegui = false, gc = false,
    timer = false, mins = 480, w = 235, h = 440,
}
pcall(function()
    if isfile(FILE) then
        for k, v in pairs(HttpService:JSONDecode(readfile(FILE))) do S[k] = v end
    end
end)
local AUTO = DELAY > 0
if AUTO then S.black = false S.dim = false end -- экран включится сам через DELAY
local function save() pcall(writefile, FILE, HttpService:JSONEncode(S)) end

local function viewport()
    local c = workspace.CurrentCamera
    return c and c.ViewportSize or Vector2.new(800, 400)
end

-- ===== основа интерфейса =====
pcall(function()
    local old = ((gethui and gethui()) or game:GetService("CoreGui")):FindFirstChild("NightHub")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "NightHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 2147483647
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

-- ===== уведомления =====
local notifyBox = Instance.new("Frame", gui)
notifyBox.AnchorPoint = Vector2.new(1, 1)
notifyBox.Position = UDim2.new(1, -10, 1, -10)
notifyBox.Size = UDim2.fromOffset(250, 300)
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

-- ===== анти-афк =====
lp.Idled:Connect(function()
    if not S.afk then return end
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ===== FPS =====
local fpsVal = 60
RunService.Heartbeat:Connect(function(dt)
    if dt > 0 then fpsVal = fpsVal * 0.9 + (1 / dt) * 0.1 end
end)

-- ===== помощник «запомнить и вернуть» =====
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

local hooks = {}

-- ===== чёрный экран, часы и затемнение =====
local overlay = Instance.new("Frame", gui)
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.new(0, 0, 0)
overlay.BorderSizePixel = 0
overlay.ZIndex = 1
overlay.Visible = false

local clockLbl = Instance.new("TextLabel", overlay)
clockLbl.AnchorPoint = Vector2.new(0.5, 0.5)
clockLbl.Position = UDim2.fromScale(0.5, 0.5)
clockLbl.Size = UDim2.fromOffset(260, 24)
clockLbl.BackgroundTransparency = 1
clockLbl.TextColor3 = Color3.fromRGB(70, 74, 92)
clockLbl.Font = Enum.Font.Gotham
clockLbl.TextSize = 14
clockLbl.Text = ""
clockLbl.ZIndex = 1

local dimFrame = Instance.new("Frame", gui)
dimFrame.Size = UDim2.new(1, 0, 1, 0)
dimFrame.BackgroundColor3 = Color3.new(0, 0, 0)
dimFrame.BorderSizePixel = 0
dimFrame.ZIndex = 1
dimFrame.Visible = false

local function updateDim()
    dimFrame.BackgroundTransparency = 1 - math.clamp(S.dimv, 0, 90) / 100
    dimFrame.Visible = S.dim
end

local circle -- объявлен ниже
local function updateCircle()
    if not circle then return end
    local st = circle:FindFirstChildOfClass("UIStroke")
    if st then
        TweenService:Create(st, TweenInfo.new(0.2),
            {Color = S.black and C.accent or Color3.new(1, 1, 1)}):Play()
    end
end

hooks.black = function(on)
    overlay.Visible = on
    clockLbl.Visible = on and S.clock
    pcall(function() RunService:Set3dRenderingEnabled(not on) end)
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, not (on or S.hidegui)) end)
    gui.DisplayOrder = 2147483647
    if circle then
        TweenService:Create(circle, TweenInfo.new(0.3), {
            BackgroundTransparency = on and 0.7 or 0,
            TextTransparency = on and 0.5 or 0,
        }):Play()
    end
    updateCircle()
end
hooks.clock = function() clockLbl.Visible = S.black and S.clock end
hooks.dim = function() updateDim() end

-- ===== лимит FPS =====
local function applyFps()
    pcall(function() setfpscap(S.fpsOn and S.fps or 60) end)
end
hooks.fpsOn = function() applyFps() end

-- ===== облегчение =====
local lRemember, lRestore = newSaver()
local lightOn, lightSaved, lightConn = false, nil, nil

local function lighten(o)
    if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam")
        or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then
        lRemember(o, {"Enabled"})
        o.Enabled = false
    end
end

hooks.light = function(on)
    if on == lightOn then return end
    lightOn = on
    if on then
        lightSaved = {shadows = Lighting.GlobalShadows}
        pcall(function()
            lightSaved.q = settings().Rendering.QualityLevel
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        Lighting.GlobalShadows = false
        for _, o in ipairs(Lighting:GetChildren()) do
            if o:IsA("PostEffect") or o:IsA("Atmosphere") then
                pcall(function() lRemember(o, {"Enabled"}) o.Enabled = false end)
            end
        end
        for _, o in ipairs(workspace:GetDescendants()) do pcall(lighten, o) end
        lightConn = workspace.DescendantAdded:Connect(function(o) pcall(lighten, o) end)
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            pcall(function()
                lRemember(terrain, {"WaterWaveSize", "WaterWaveSpeed", "WaterReflectance"})
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
            end)
            pcall(function()
                lightSaved.deco = gethiddenproperty(terrain, "Decoration")
                sethiddenproperty(terrain, "Decoration", false)
            end)
        end
    else
        if lightConn then lightConn:Disconnect() lightConn = nil end
        lRestore()
        if lightSaved then
            Lighting.GlobalShadows = lightSaved.shadows
            if lightSaved.q then
                pcall(function() settings().Rendering.QualityLevel = lightSaved.q end)
            end
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if terrain and lightSaved.deco ~= nil then
                pcall(sethiddenproperty, terrain, "Decoration", lightSaved.deco)
            end
            lightSaved = nil
        end
    end
end

-- ===== тёмная графика =====
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

-- ===== без звука =====
local mRemember, mRestore = newSaver()
local muteOn, muteConn, muteVol = false, nil, nil

local function muteSound(o)
    if o:IsA("Sound") then
        mRemember(o, {"Volume"})
        o.Volume = 0
    end
end

hooks.mute = function(on)
    if on == muteOn then return end
    muteOn = on
    if on then
        pcall(function()
            local u = UserSettings():GetService("UserGameSettings")
            muteVol = u.MasterVolume
            u.MasterVolume = 0
        end)
        for _, o in ipairs(workspace:GetDescendants()) do pcall(muteSound, o) end
        for _, o in ipairs(SoundService:GetDescendants()) do pcall(muteSound, o) end
        muteConn = workspace.DescendantAdded:Connect(function(o) pcall(muteSound, o) end)
    else
        if muteConn then muteConn:Disconnect() muteConn = nil end
        mRestore()
        pcall(function()
            if muteVol then UserSettings():GetService("UserGameSettings").MasterVolume = muteVol end
        end)
    end
end

-- ===== скрыть других игроков =====
local hRemember, hRestore = newSaver()
local hideOn = false

hooks.hideplr = function(on)
    hideOn = on
    if not on then hRestore() end
end

task.spawn(function()
    while task.wait(2) do
        if hideOn then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character then
                    for _, o in ipairs(plr.Character:GetDescendants()) do
                        if o:IsA("BasePart") or o:IsA("Decal") then
                            pcall(function() hRemember(o, {"Transparency"}) o.Transparency = 1 end)
                        elseif o:IsA("Humanoid") then
                            pcall(function() hRemember(o, {"DisplayDistanceType"}) o.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end)
                        end
                    end
                end
            end
        end
    end
end)

-- ===== скрыть интерфейс игры =====
local gRemember, gRestore = newSaver()
local guiOn, guiConn = false, nil

local function hideGameGui(o)
    if o:IsA("ScreenGui") and o ~= gui then
        gRemember(o, {"Enabled"})
        o.Enabled = false
    end
end

hooks.hidegui = function(on)
    if on == guiOn then return end
    guiOn = on
    local pg = lp:WaitForChild("PlayerGui")
    if on then
        for _, o in ipairs(pg:GetChildren()) do pcall(hideGameGui, o) end
        guiConn = pg.ChildAdded:Connect(function(o) task.wait() pcall(hideGameGui, o) end)
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
    else
        if guiConn then guiConn:Disconnect() guiConn = nil end
        gRestore()
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, not S.black) end)
    end
end

-- ===== таймер закрытия =====
local timerStart, timerWarned = os.clock(), false
hooks.timer = function()
    timerStart = os.clock()
    timerWarned = false
end

-- ===== круглая кнопка =====
local cx, cy = viewport().X - 62, viewport().Y * 0.45
circle = Instance.new("TextButton", gui)
circle.Size = UDim2.fromOffset(52, 52)
circle.Position = UDim2.fromOffset(cx, cy)
circle.BackgroundColor3 = Color3.new(1, 1, 1)
circle.TextColor3 = Color3.new(1, 1, 1)
circle.Font = Enum.Font.GothamBold
circle.TextSize = 26
circle.Text = "🌙"
circle.AutoButtonColor = false
circle.ZIndex = 5
Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
local cGrad = Instance.new("UIGradient", circle)
cGrad.Color = ColorSequence.new(Color3.fromRGB(40, 50, 120), Color3.fromRGB(120, 80, 210))
cGrad.Rotation = 45
local cStroke = Instance.new("UIStroke", circle)
cStroke.Thickness = 3
cStroke.Color = Color3.new(1, 1, 1)

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

local title = Instance.new("TextLabel", frame)
title.Position = UDim2.new(0, 12, 0, 0)
title.Size = UDim2.new(1, -50, 0, 34)
title.BackgroundTransparency = 1
title.TextColor3 = C.text
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "🌙 Night Hub"

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Position = UDim2.new(1, -34, 0, 4)
closeBtn.Size = UDim2.fromOffset(26, 26)
closeBtn.BackgroundColor3 = C.card
closeBtn.TextColor3 = C.sub
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Text = "✕"
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

local tabBar = Instance.new("Frame", frame)
tabBar.Position = UDim2.new(0, 6, 0, 36)
tabBar.Size = UDim2.new(1, -12, 0, 28)
tabBar.BackgroundTransparency = 1

local pages, tabs = {}, {}
local tabNames = {"🌙 Ночь", "⚙ Нагрузка", "📊 Инфо"}

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

local switches = {}

local function setFlag(key, val)
    if S[key] == val then return end
    S[key] = val
    if switches[key] then switches[key](true) end
    if hooks[key] then pcall(hooks[key], val) end
    save()
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
    switches[key] = render

    local hit = Instance.new("TextButton", row)
    hit.Size = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.MouseButton1Click:Connect(function()
        setFlag(key, not S[key])
        notify(icon .. " " .. label .. ": " .. (S[key] and "ВКЛ" or "ВЫКЛ"), S[key] and C.on or C.bad)
    end)
end

local function numberRow(page, icon, label, key, mn, mx, onChange)
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
            n = math.clamp(math.floor(n), mn, mx)
            S[key] = n
            tb.Text = tostring(n)
            save()
            if onChange then pcall(onChange, n) end
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
end

local function statRow(page, icon, label)
    local row = card(page, 38)
    rowLabels(row, icon, label)
    local v = Instance.new("TextLabel", row)
    v.AnchorPoint = Vector2.new(1, 0.5)
    v.Position = UDim2.new(1, -10, 0.5, 0)
    v.Size = UDim2.fromOffset(100, 26)
    v.BackgroundTransparency = 1
    v.TextColor3 = C.text
    v.Font = Enum.Font.GothamBold
    v.TextSize = 14
    v.TextXAlignment = Enum.TextXAlignment.Right
    v.Text = "—"
    return v
end

-- ===== пресеты =====
local NIGHT = {black = true, clock = true, light = true, fpsOn = true, mute = true, afk = true, gc = true}
local RESET = {black = false, dim = false, dark = false, light = false, fpsOn = false,
    mute = false, hideplr = false, hidegui = false}

local function applyPreset(map)
    for k, v in pairs(map) do setFlag(k, v) end
end

-- ===== вкладка 1: ночь =====
local p1, p2, p3 = pages[1], pages[2], pages[3]

section(p1, "БЫСТРО")
actionRow(p1, "🌙", "Ночной режим", function()
    applyPreset(NIGHT)
    notify("🌙 Ночной режим включён", C.accent)
end)
actionRow(p1, "☀", "Вернуть всё", function()
    applyPreset(RESET)
    notify("☀ Всё возвращено", C.warn)
end)
section(p1, "ЭКРАН")
switchRow(p1, "⬛", "Чёрный экран", "black")
switchRow(p1, "🕒", "Часы на чёрном", "clock")
switchRow(p1, "🌗", "Затемнение", "dim")
numberRow(p1, "🔆", "Затемнить на %", "dimv", 0, 90, updateDim)
section(p1, "СЕССИЯ")
switchRow(p1, "🛡", "Анти-АФК", "afk")
switchRow(p1, "⏳", "Таймер закрытия", "timer")
numberRow(p1, "⏱", "Минут до закрытия", "mins", 1, 1440, function() hooks.timer() end)

-- ===== вкладка 2: нагрузка =====
section(p2, "ПРОЦЕССОР И ГРАФИКА")
switchRow(p2, "🎞", "Лимит FPS", "fpsOn")
numberRow(p2, "🔢", "FPS", "fps", 5, 120, applyFps)
switchRow(p2, "🍃", "Облегчение", "light")
switchRow(p2, "🌑", "Тёмная графика", "dark")
section(p2, "ЛИШНЕЕ")
switchRow(p2, "🔇", "Без звука", "mute")
switchRow(p2, "👻", "Скрыть игроков", "hideplr")
switchRow(p2, "🖼", "Скрыть интерфейс игры", "hidegui")
infoRow(p2, "Если у фарм-скрипта есть авторесет по надписи рюкзака, «Скрыть интерфейс игры» держи выключенным: он читает эти надписи.", 56)
section(p2, "ПАМЯТЬ")
switchRow(p2, "🧹", "Автоочистка (5 мин)", "gc")
actionRow(p2, "🗑", "Очистить сейчас", function()
    local before = Stats:GetTotalMemoryUsageMb()
    pcall(collectgarbage, "collect")
    notify("🧹 Память очищена (было " .. math.floor(before) .. " МБ)", C.on)
end)

-- ===== вкладка 3: инфо =====
section(p3, "СЕЙЧАС")
local stFps = statRow(p3, "🎞", "FPS")
local stPing = statRow(p3, "📡", "Пинг")
local stMem = statRow(p3, "💾", "Память")
local stUp = statRow(p3, "🕒", "В игре")
local stLeft = statRow(p3, "⏳", "До закрытия")
infoRow(p3, "Night Hub работает отдельно от других скриптов и их не трогает. Все функции обратимы кнопкой «Вернуть всё».", 56)

-- ===== уголок изменения размера =====
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

-- ===== фоновый цикл: инфо, часы, память, таймер =====
local function fmt(sec)
    sec = math.max(0, math.floor(sec))
    return string.format("%02d:%02d:%02d", sec // 3600, (sec % 3600) // 60, sec % 60)
end

task.spawn(function()
    local lastGc, tick = os.clock(), 0
    while task.wait(1) do
        tick += 1
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        local mem = math.floor(Stats:GetTotalMemoryUsageMb())
        local fpsText = math.floor(fpsVal + 0.5)

        stFps.Text = tostring(fpsText)
        stPing.Text = ping .. " мс"
        stMem.Text = mem .. " МБ"
        stUp.Text = fmt(os.clock() - T0)

        if clockLbl.Visible then
            clockLbl.Text = fmt(os.clock() - T0) .. "  •  " .. fpsText .. " FPS  •  " .. ping .. " мс"
            if tick % 40 == 0 then
                clockLbl.Position = UDim2.fromScale(math.random(18, 82) / 100, math.random(15, 85) / 100)
            end
        end

        if S.gc and os.clock() - lastGc > 300 then
            lastGc = os.clock()
            pcall(collectgarbage, "collect")
            notify("🧹 Память очищена", C.on)
        end

        if S.timer then
            local left = S.mins * 60 - (os.clock() - timerStart)
            stLeft.Text = fmt(left)
            if left <= 60 and not timerWarned then
                timerWarned = true
                notify("⏳ Игра закроется через минуту", C.warn)
            end
            if left <= 0 then
                pcall(function() game:Shutdown() end)
            end
        else
            stLeft.Text = "выкл"
        end
    end
end)

-- ===== применить сохранённое =====
updateDim()
for _, k in ipairs({"black", "dark", "light", "fpsOn", "mute", "hideplr", "hidegui"}) do
    if S[k] then pcall(hooks[k], true) end
end
updateCircle()
notify("🌙 Night Hub запущен", C.accent)
print("[Night Hub] запущен, кружок 🌙 на экране")

-- ===== автовключение экрана через DELAY секунд =====
if AUTO then
    notify("⏱ Экран затемнится через " .. DELAY .. " с", C.sub)
    task.spawn(function()
        task.wait(DELAY)
        if MODE == "black" then
            setFlag("black", true)
        else
            S.dimv = 90
            setFlag("dim", true)
            updateDim()
        end
        notify("🌙 Экран затемнён автоматически", C.accent)
        print("[Night Hub] экран затемнён автоматически")
    end)
end

end)

if not ok then warn("[Night Hub] ошибка: " .. tostring(err)) end
