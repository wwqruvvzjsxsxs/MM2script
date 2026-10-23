--[[
  Delta Panel — только интерфейс (без читов), для Delta (Android) / Roblox
  • Круглая кнопка меню и окно перетаскиваются пальцем
  • Часы по Москве (UTC+3), RU/EN переключатель
  • 8 тем: меняют форму, рамки, шрифты и рисунок на фоне
]]

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP           = Players.LocalPlayer

------------------------------------------------------------------ ПАРЕНТ
local parents = {}
pcall(function() if gethui then parents[#parents + 1] = gethui() end end)
pcall(function() parents[#parents + 1] = game:GetService("CoreGui") end)
pcall(function() parents[#parents + 1] = LP:WaitForChild("PlayerGui", 5) end)
for _, p in ipairs(parents) do
	pcall(function()
		local old = p:FindFirstChild("DeltaPanelGUI")
		if old then old:Destroy() end
	end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "DeltaPanelGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
for _, p in ipairs(parents) do
	local ok = pcall(function() gui.Parent = p end)
	if ok and gui.Parent == p then break end
end

------------------------------------------------------------------ УТИЛИТЫ
local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end
local function c(r, g, b) return Color3.fromRGB(r, g, b) end
local function F(name, fb)
	local ok, v = pcall(function() return Enum.Font[name] end)
	if ok and v then return v end
	return fb
end

local lang, themeId, decoToken, open, tabSel = "ru", 1, 0, false, 1
local styleFns, langFns = {}, {}
local cur -- текущая тема
local art -- слой рисунка

local STR = {
	ru = {
		tab_home = "Главная", tab_themes = "Темы", tab_about = "О скрипте",
		clock_cap = "Московское время", tz = "МСК · UTC+3",
		lang_cap = "Язык интерфейса", lang_val = "Русский", lang_btn = "Переключить на English",
		theme_cap = "Текущая тема",
		themes_hdr = "Выбор оформления", themes_sub = "Нажмите на карточку, чтобы применить",
		about_hdr = "О скрипте", footer = "Только интерфейс · без читов",
		about_body = "Delta Panel — аккуратная пользовательская панель для Roblox.\n\n"
			.. "• Кнопка меню и окно перетаскиваются пальцем.\n"
			.. "• Точные часы по Москве (UTC+3) независимо от часового пояса устройства.\n"
			.. "• Мгновенное переключение RU / EN для всего интерфейса.\n"
			.. "• 8 тем оформления: меняются форма окна, скругления, рамки, шрифты и рисунок на фоне.\n"
			.. "• Сетка: боковая панель + рабочая зона, карточки и чёткая иерархия шрифтов.\n\n"
			.. "Скрипт содержит только интерфейс — никаких читов и эксплойтов.",
		days = { "Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб" },
	},
	en = {
		tab_home = "Home", tab_themes = "Themes", tab_about = "About",
		clock_cap = "Moscow time", tz = "MSK · UTC+3",
		lang_cap = "Interface language", lang_val = "English", lang_btn = "Switch to Русский",
		theme_cap = "Current theme",
		themes_hdr = "Choose a style", themes_sub = "Tap a card to apply it",
		about_hdr = "About", footer = "UI only · no cheats",
		about_body = "Delta Panel is a clean, tidy user panel for Roblox.\n\n"
			.. "• The menu button and the window can be dragged with a finger.\n"
			.. "• Accurate Moscow time (UTC+3) regardless of the device time zone.\n"
			.. "• Instant RU / EN switch for the whole interface.\n"
			.. "• 8 visual styles: window shape, corner radius, borders, fonts and background artwork all change.\n"
			.. "• Grid layout: sidebar + work area, cards and a clear font hierarchy.\n\n"
			.. "This script contains only a user interface — no cheats or exploits.",
		days = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" },
	},
}
local function tr(k) return STR[lang][k] or k end

local function onStyle(fn) styleFns[#styleFns + 1] = fn; fn(cur) end
local function onLang(fn) langFns[#langFns + 1] = fn; fn() end
local function refreshText()
	for _, fn in ipairs(langFns) do local ok, e = pcall(fn); if not ok then warn(e) end end
end
local function restyle()
	for _, fn in ipairs(styleFns) do local ok, e = pcall(fn, cur); if not ok then warn(e) end end
end

------------------------------------------------------------------ РИСОВАЛКИ ДЛЯ ФОНА
local function rect(p, x, y, w, h, col, tp, rot)
	return new("Frame", { Position = UDim2.new(0, x, 0, y), Size = UDim2.new(0, w, 0, h),
		BackgroundColor3 = col, BackgroundTransparency = tp or 0, BorderSizePixel = 0,
		Rotation = rot or 0, ZIndex = 1 }, p)
end
local function rr(p, x, y, w, h, col, tp, rad)
	local f = rect(p, x, y, w, h, col, tp)
	new("UICorner", { CornerRadius = UDim.new(0, rad or 4) }, f)
	return f
end
local function circle(p, x, y, d, col, tp)
	local f = rect(p, x - d / 2, y - d / 2, d, d, col, tp)
	new("UICorner", { CornerRadius = UDim.new(1, 0) }, f)
	return f
end
local function ring(p, x, y, d, col, th, tp)
	local f = new("Frame", { Position = UDim2.new(0, x - d / 2, 0, y - d / 2), Size = UDim2.new(0, d, 0, d),
		BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1 }, p)
	new("UICorner", { CornerRadius = UDim.new(1, 0) }, f)
	new("UIStroke", { Color = col, Thickness = th, Transparency = tp or 0.5 }, f)
	return f
end
local function glyph(p, txt, x, y, sz, col, tp, rot)
	return new("TextLabel", { BackgroundTransparency = 1, Text = txt, TextSize = sz, TextColor3 = col,
		TextTransparency = tp or 0, Position = UDim2.new(0, x, 0, y), Size = UDim2.new(0, sz * 2, 0, sz * 1.5),
		AnchorPoint = Vector2.new(0.5, 0.5), Rotation = rot or 0, Font = Enum.Font.SourceSansBold, ZIndex = 1 }, p)
end
local function tag(p, txt, x, y, sz, col, tp, ax)
	return new("TextLabel", { BackgroundTransparency = 1, Text = txt, TextSize = sz, TextColor3 = col,
		TextTransparency = tp or 0, Position = UDim2.new(0, x, 0, y), Size = UDim2.new(0, 300, 0, sz + 4),
		AnchorPoint = Vector2.new(ax, 1), Font = F("Code", Enum.Font.Code), ZIndex = 1,
		TextXAlignment = (ax == 1) and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left }, p)
end

local DECO = {}

-- 1. Чертёж CAD: сетка + перекрестия
DECO[1] = function(a, W, H, lg, t)
	local lc = t.accent
	for x = 0, W, 24 do rect(a, x, 0, 1, H, lc, (x % 120 == 0) and 0.55 or 0.9) end
	for y = 0, H, 24 do rect(a, 0, y, W, 1, lc, (y % 120 == 0) and 0.55 or 0.9) end
	for x = 0, W, 120 do
		for y = 0, H, 120 do
			rect(a, x - 7, y, 15, 1, lc, 0.1)
			rect(a, x, y - 7, 1, 15, lc, 0.1)
		end
	end
	local cx, cy = W * 0.84, H * 0.74
	ring(a, cx, cy, 140, lc, 1, 0.5)
	ring(a, cx, cy, 84, lc, 1, 0.6)
	rect(a, cx - 80, cy, 160, 1, lc, 0.5)
	rect(a, cx, cy - 80, 1, 160, lc, 0.5)
	tag(a, lg == "ru" and "ЛИСТ 1/1 · А3 · М 1:1" or "SHEET 1/1 · A3 · 1:1", W - 12, H - 8, 10, lc, 0.2, 1)
end

-- 2. Бункер: полосы опасности, заклёпки, фаски
DECO[2] = function(a, W, H, lg, t)
	local dark = c(18, 18, 14)
	local function stripe(y)
		local s = rect(a, 0, y, W, 10, dark, 0)
		s.ClipsDescendants = true
		for x = -20, W + 20, 20 do rect(s, x, -8, 10, 30, t.accent, 0, 40) end
	end
	stripe(0); stripe(H - 10)
	for _, p in ipairs({ { 16, 24 }, { W - 16, 24 }, { 16, H - 24 }, { W - 16, H - 24 } }) do
		circle(a, p[1], p[2], 8, c(110, 112, 98), 0)
		circle(a, p[1], p[2], 3, dark, 0.3)
	end
	for _, p in ipairs({ { 0, 0 }, { W, 0 }, { 0, H }, { W, H } }) do rect(a, p[1] - 14, p[2] - 14, 28, 28, dark, 0, 45) end
	glyph(a, "★", W * 0.8, H * 0.55, 110, t.accent, 0.9)
	tag(a, lg == "ru" and "СЕКТОР 7 · ДОСТУП ОГРАНИЧЕН" or "SECTOR 7 · RESTRICTED", W - 18, H - 14, 10, t.accent, 0.3, 1)
end

-- 3. ЭЛТ-терминал: scanlines, бегущая полоса, курсор
DECO[3] = function(a, W, H, lg, t, my)
	for y = 0, H, 3 do rect(a, 0, y, W, 1, Color3.new(0, 0, 0), 0.55) end
	local bar = rect(a, 0, -40, W, 40, t.accent, 0.93)
	local line = tag(a, "> SYSTEM READY _", 16, H - 22, 11, t.text, 0.2, 0)
	tag(a, "CRT-80 · 60Hz", W - 14, H - 8, 10, t.sub, 0.3, 1)
	task.spawn(function()
		local n = 0
		while decoToken == my and gui.Parent do
			if n % 6 == 0 then
				bar.Position = UDim2.new(0, 0, 0, -40)
				TweenService:Create(bar, TweenInfo.new(3, Enum.EasingStyle.Linear), { Position = UDim2.new(0, 0, 0, H) }):Play()
			end
			local word = (lang == "ru") and "> СИСТЕМА ГОТОВА" or "> SYSTEM READY"
			line.Text = word .. ((n % 2 == 0) and " █" or " _")
			n = n + 1
			task.wait(0.5)
		end
	end)
end

-- 4. Неоновое стекло: светящиеся полупрозрачные сферы
DECO[4] = function(a, W, H)
	local function orb(x, y, d, col, tp)
		local o = circle(a, x, y, d, col, tp)
		new("UIGradient", { Rotation = 45, Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.7) }) }, o)
		new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1, Transparency = 0.7 }, o)
		circle(a, x - d * 0.22, y - d * 0.25, d * 0.18, Color3.new(1, 1, 1), 0.75)
	end
	orb(W * 0.2, H * 0.35, 150, c(255, 46, 196), 0.6)
	orb(W * 0.82, H * 0.22, 170, c(0, 240, 255), 0.65)
	orb(W * 0.6, H * 0.9, 200, c(140, 80, 255), 0.55)
	orb(W * 0.38, H * 0.14, 50, c(0, 240, 255), 0.5)
	orb(W * 0.93, H * 0.78, 70, c(255, 46, 196), 0.5)
	orb(W * 0.08, H * 0.9, 60, c(140, 80, 255), 0.5)
end

-- 5. Имперский: двойная золотая рамка + угловые орнаменты
DECO[5] = function(a, W, H, lg, t)
	local function fr(i, th, tp)
		local f = new("Frame", { Position = UDim2.new(0, i, 0, i), Size = UDim2.new(1, -i * 2, 1, -i * 2),
			BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1 }, a)
		new("UIStroke", { Color = t.accent, Thickness = th, Transparency = tp, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
	end
	fr(5, 2.5, 0); fr(11, 1, 0.2)
	for _, p in ipairs({ { 20, 20 }, { W - 20, 20 }, { 20, H - 20 }, { W - 20, H - 20 } }) do glyph(a, "❖", p[1], p[2], 16, t.accent, 0) end
	glyph(a, "⚜", W * 0.8, H * 0.58, 120, t.accent, 0.9)
	glyph(a, "♛", W * 0.5, H - 20, 14, t.accent, 0.3)
end

-- 6. Детская: радуга, облака, игрушки
DECO[6] = function(a, W, H)
	local cols = { c(255, 82, 82), c(255, 167, 38), c(255, 235, 59), c(102, 187, 106), c(66, 165, 245) }
	for i = 1, 5 do ring(a, W - 20, H + 40, 330 - (i - 1) * 34, cols[i], 17, 0.1) end
	local white = Color3.new(1, 1, 1)
	local function cloud(x, y, s)
		circle(a, x, y, s, white, 0)
		circle(a, x + s * 0.55, y + s * 0.15, s * 0.8, white, 0)
		circle(a, x - s * 0.55, y + s * 0.15, s * 0.7, white, 0)
	end
	cloud(W * 0.3, H * 0.16, 34); cloud(W * 0.68, H * 0.1, 28)
	local em = { { "🧸", .16, .86, 40 }, { "🍼", .36, .9, 30 }, { "👶", .55, .88, 36 }, { "🦆", .9, .14, 30 },
		{ "🎈", .46, .14, 30 }, { "⭐", .8, .2, 26 }, { "🚂", .08, .5, 30 }, { "🦄", .94, .5, 32 } }
	for _, e in ipairs(em) do glyph(a, e[1], W * e[2], H * e[3], e[4], white, 0.2) end
end

-- 7. Молодёжная: точки, градиент, стикеры о проблемах мира
DECO[7] = function(a, W, H, lg, t)
	local g = rect(a, 0, 0, W, H, c(139, 92, 246), 0.8)
	g.Size = UDim2.fromScale(1, 1)
	new("UIGradient", { Rotation = 35, Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 1) }) }, g)
	for x = 14, W, 28 do for y = 14, H, 28 do rect(a, x, y, 2, 2, t.accent, 0.8) end end
	glyph(a, "🌍", W * 0.82, H * 0.5, 100, Color3.new(1, 1, 1), 0.85)
	local function chip(txt, sx, sy, rot, col)
		local f = new("TextLabel", { Text = txt, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = col,
			BackgroundColor3 = c(10, 10, 14), BackgroundTransparency = 0.4, BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 0, 20), AutomaticSize = Enum.AutomaticSize.X, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(sx, 0, sy, 0), Rotation = rot, ZIndex = 1 }, a)
		new("UICorner", { CornerRadius = UDim.new(1, 0) }, f)
		new("UIStroke", { Color = col, Thickness = 1, Transparency = 0.3 }, f)
		new("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9) }, f)
	end
	local ru = (lg == "ru")
	chip(ru and "#климат" or "#climate", 0.42, 0.9, -4, t.accent)
	chip(ru and "#ментальное здоровье" or "#mentalhealth", 0.72, 0.94, 3, c(139, 92, 246))
	chip(ru and "#инфляция" or "#inflation", 0.9, 0.8, -5, t.accent)
	chip(ru and "#мир" or "#peace", 0.9, 0.22, 5, c(139, 92, 246))
	chip(ru and "#жильё" or "#housing", 0.55, 0.12, -3, t.accent)
	chip(ru and "#ИИ" or "#AI", 0.72, 0.2, 4, c(139, 92, 246))
end

-- 8. Взрослая: вишни, дом, семья, кровать, луна (без сексуализации)
DECO[8] = function(a, W, H, lg, t)
	local red, grn = c(200, 30, 60), c(90, 150, 80)
	local function cherry(x, y, s)
		rect(a, x - s * 0.1, y - s * 0.2, 2, s, grn, 0, 18)
		rect(a, x + s * 0.35, y - s * 0.2, 2, s, grn, 0, -18)
		circle(a, x - s * 0.35, y + s * 0.75, s, red, 0)
		circle(a, x + s * 0.55, y + s * 0.8, s, red, 0)
		circle(a, x - s * 0.5, y + s * 0.6, s * 0.25, Color3.new(1, 1, 1), 0.6)
		circle(a, x + s * 0.4, y + s * 0.65, s * 0.25, Color3.new(1, 1, 1), 0.6)
		rect(a, x + s * 0.2, y - s * 0.35, s * 0.5, s * 0.25, grn, 0, -25)
	end
	cherry(W * 0.86, H * 0.3, 26); cherry(W * 0.34, H * 0.84, 18); cherry(W * 0.95, H * 0.82, 20)
	-- кровать
	local bx, by = W * 0.52, H * 0.78
	local wood, cream, rose = c(120, 70, 60), c(250, 235, 215), c(232, 130, 140)
	rr(a, bx, by, 8, 44, wood, 0.2, 3)
	rr(a, bx + 8, by + 22, 78, 14, cream, 0.2, 4)
	rr(a, bx + 32, by + 16, 54, 16, rose, 0.2, 5)
	rr(a, bx + 12, by + 14, 22, 10, Color3.new(1, 1, 1), 0.2, 5)
	rect(a, bx + 2, by + 44, 4, 8, wood, 0.2)
	rect(a, bx + 82, by + 36, 4, 16, wood, 0.2)
	local em = { { "🌙", .62, .62, 24 }, { "🏠", .44, .12, 28 }, { "👪", .93, .58, 32 }, { "☕", .7, .12, 26 },
		{ "🔑", .8, .92, 22 } }
	for _, e in ipairs(em) do glyph(a, e[1], W * e[2], H * e[3], e[4], Color3.new(1, 1, 1), 0.4) end
end

------------------------------------------------------------------ ТЕМЫ
local THEMES = {
	{ id = 1, icon = "📐", name = { ru = "Чертёж", en = "Blueprint" },
		desc = { ru = "Сетка CAD с перекрестиями", en = "CAD grid with crosshairs" },
		rad = 3, crad = 2, brad = 2, sw = 1, cw = 1, ptr = 0.35, side = 128, fab = 6,
		head = F("RobotoMono", Enum.Font.Code), body = F("RobotoMono", Enum.Font.Code), fs = 0.9,
		bg = c(11, 42, 74), panel = c(18, 59, 102), accent = c(127, 209, 255), text = c(232, 244, 255),
		sub = c(143, 184, 218), line = c(127, 209, 255), onAccent = c(11, 42, 74) },
	{ id = 2, icon = "🛡", name = { ru = "Бункер", en = "Bunker" },
		desc = { ru = "Полосы опасности и заклёпки", en = "Hazard stripes and rivets" },
		rad = 0, crad = 0, brad = 0, sw = 3, cw = 2, ptr = 0.1, side = 120, fab = 0,
		head = F("RobotoCondensed", Enum.Font.GothamBold), body = F("RobotoCondensed", Enum.Font.GothamBold), fs = 1.05,
		bg = c(43, 46, 39), panel = c(58, 62, 51), accent = c(224, 180, 0), text = c(230, 226, 208),
		sub = c(160, 163, 140), line = c(224, 180, 0), onAccent = c(26, 26, 20) },
	{ id = 3, icon = "🖥", name = { ru = "ЭЛТ-терминал", en = "CRT Terminal" },
		desc = { ru = "Линии развёртки, зелёный люминофор", en = "Scanlines, green phosphor" },
		rad = 8, crad = 4, brad = 3, sw = 2, cw = 1, ptr = 0.25, side = 124, fab = 10,
		head = Enum.Font.Code, body = Enum.Font.Code, fs = 0.92,
		bg = c(4, 26, 12), panel = c(6, 40, 18), accent = c(51, 255, 102), text = c(125, 255, 158),
		sub = c(47, 168, 79), line = c(51, 255, 102), onAccent = c(2, 18, 8) },
	{ id = 4, icon = "🔮", name = { ru = "Неоновое стекло", en = "Neon Glass" },
		desc = { ru = "Светящиеся полупрозрачные сферы", en = "Glowing translucent orbs" },
		rad = 24, crad = 16, brad = 12, sw = 1.5, cw = 1, ptr = 0.45, side = 132, fab = 28,
		head = Enum.Font.GothamBold, body = Enum.Font.Gotham, fs = 0.95,
		bg = c(18, 11, 46), panel = c(60, 40, 120), accent = c(0, 240, 255), text = c(255, 255, 255),
		sub = c(185, 168, 255), line = c(255, 46, 196), onAccent = c(18, 11, 46) },
	{ id = 5, icon = "👑", name = { ru = "Имперский", en = "Imperial" },
		desc = { ru = "Двойная золотая рамка, орнаменты", en = "Double gold frame, ornaments" },
		rad = 6, crad = 3, brad = 3, sw = 3, cw = 1.5, ptr = 0.2, side = 134, fab = 28,
		head = F("Merriweather", Enum.Font.GothamMedium), body = F("Merriweather", Enum.Font.GothamMedium), fs = 0.95,
		bg = c(28, 11, 34), panel = c(52, 22, 58), accent = c(212, 175, 55), text = c(245, 230, 184),
		sub = c(184, 160, 106), line = c(212, 175, 55), onAccent = c(28, 11, 34) },
	{ id = 6, icon = "🌈", name = { ru = "Детская", en = "Kids" },
		desc = { ru = "Радуга, облака, игрушки", en = "Rainbow, clouds, toys" },
		rad = 28, crad = 20, brad = 18, sw = 4, cw = 3, ptr = 0.05, side = 126, fab = 28,
		head = F("Nunito", Enum.Font.GothamBold), body = F("Nunito", Enum.Font.GothamMedium), fs = 1,
		bg = c(205, 235, 255), panel = c(255, 255, 255), accent = c(255, 111, 181), text = c(74, 59, 107),
		sub = c(130, 115, 170), line = c(255, 111, 181), onAccent = c(255, 255, 255) },
	{ id = 7, icon = "🌍", name = { ru = "Молодёжная", en = "Gen Z" },
		desc = { ru = "Актуальные темы мира, стикеры", en = "Real-world issues, stickers" },
		rad = 14, crad = 12, brad = 10, sw = 2, cw = 1, ptr = 0.2, side = 128, fab = 18,
		head = F("Ubuntu", Enum.Font.GothamBold), body = F("Ubuntu", Enum.Font.Gotham), fs = 1,
		bg = c(15, 17, 21), panel = c(30, 34, 44), accent = c(182, 255, 59), text = c(242, 244, 248),
		sub = c(138, 146, 163), line = c(139, 92, 246), onAccent = c(15, 17, 21) },
	{ id = 8, icon = "🍒", name = { ru = "Взрослая", en = "Adult" },
		desc = { ru = "Дом, семья, вишни, уют", en = "Home, family, cherries, cosy" },
		rad = 16, crad = 14, brad = 12, sw = 2, cw = 1, ptr = 0.25, side = 130, fab = 24,
		head = Enum.Font.SourceSansSemibold, body = Enum.Font.SourceSans, fs = 1.12,
		bg = c(58, 15, 30), panel = c(84, 28, 47), accent = c(243, 217, 177), text = c(250, 235, 215),
		sub = c(201, 161, 143), line = c(201, 161, 143), onAccent = c(58, 15, 30) },
}
cur = THEMES[1]

------------------------------------------------------------------ РАЗМЕРЫ
local cam = workspace.CurrentCamera
local vp = cam and cam.ViewportSize or Vector2.new(800, 400)
local W = math.floor(math.clamp(vp.X * 0.74, 380, 620))
local H = math.floor(math.clamp(vp.Y * 0.80, 250, 360))
local TB = 36

------------------------------------------------------------------ ПЕРЕТАСКИВАНИЕ
local function makeDraggable(handle, target, sizePx, onTap)
	local dragging, tracked, startIn, startPos, moved = false, nil, nil, nil, false
	handle.InputBegan:Connect(function(inp)
		local ut = inp.UserInputType
		if ut == Enum.UserInputType.Touch or ut == Enum.UserInputType.MouseButton1 then
			dragging, moved, tracked = true, false, inp
			startIn, startPos = inp.Position, target.Position
			local conn
			conn = inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					conn:Disconnect()
					dragging = false
					if not moved and onTap then onTap() end
				end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(inp)
		if not dragging then return end
		local ut = inp.UserInputType
		if ut == Enum.UserInputType.Touch then
			if inp ~= tracked then return end
		elseif ut ~= Enum.UserInputType.MouseMovement then
			return
		end
		local d = inp.Position - startIn
		if not moved and d.Magnitude > 8 then moved = true end
		if moved then
			local v = workspace.CurrentCamera.ViewportSize
			local ap = target.AnchorPoint
			local nx = math.clamp(startPos.X.Offset + d.X, sizePx.X * ap.X, v.X - sizePx.X * (1 - ap.X))
			local ny = math.clamp(startPos.Y.Offset + d.Y, sizePx.Y * ap.Y, v.Y - sizePx.Y * (1 - ap.Y))
			target.Position = UDim2.fromOffset(nx, ny)
		end
	end)
end

------------------------------------------------------------------ ПЛАВАЮЩАЯ КНОПКА
local fab = new("TextButton", { Name = "Fab", AutoButtonColor = false, Text = "☰", BorderSizePixel = 0,
	Size = UDim2.fromOffset(56, 56), Position = UDim2.fromOffset(vp.X - 76, vp.Y * 0.35), ZIndex = 50 }, gui)
local fabC = new("UICorner", {}, fab)
local fabS = new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, fab)
local fabScale = new("UIScale", {}, fab)
onStyle(function(t)
	fab.BackgroundColor3 = t.accent
	fab.TextColor3 = t.onAccent
	fab.Font = t.head
	fab.TextSize = 26
	fabC.CornerRadius = UDim.new(0, t.fab)
	fabS.Color = t.line
	fabS.Thickness = t.sw
end)

------------------------------------------------------------------ ОКНО
local win = new("Frame", { Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Visible = false, BorderSizePixel = 0,
	Position = UDim2.fromOffset(vp.X / 2, vp.Y / 2), Size = UDim2.fromOffset(W, H), ZIndex = 10 }, gui)
local winScale = new("UIScale", { Scale = 0.85 }, win)
local winC = new("UICorner", {}, win)
local winS = new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, win)
local deco = new("CanvasGroup", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 1 }, win)
local decoC = new("UICorner", {}, deco)
art = new("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) }, deco)
onStyle(function(t)
	win.BackgroundColor3 = t.bg
	winC.CornerRadius = UDim.new(0, t.rad)
	decoC.CornerRadius = UDim.new(0, t.rad)
	winS.Color = t.accent
	winS.Thickness = t.sw
end)

local function buildDeco()
	decoToken = decoToken + 1
	art:ClearAllChildren()
	local fn = DECO[themeId]
	if fn then
		local ok, e = pcall(fn, art, W, H, lang, cur, decoToken)
		if not ok then warn(e) end
	end
end

-- Помощники для текста / карточек / кнопок
local function mkText(parent, o)
	local l = new("TextLabel", { BackgroundTransparency = 1, BorderSizePixel = 0, Text = o.text or "",
		Position = o.pos or UDim2.new(), Size = o.size or UDim2.fromScale(1, 1),
		TextXAlignment = o.xa or Enum.TextXAlignment.Left, TextYAlignment = o.ya or Enum.TextYAlignment.Center,
		TextWrapped = o.wrap or false, ZIndex = o.z or 4 }, parent)
	if o.auto then l.AutomaticSize = Enum.AutomaticSize.Y end
	if o.trunc then l.TextTruncate = Enum.TextTruncate.AtEnd end
	local con
	if o.scaled then
		l.TextScaled = true
		con = new("UITextSizeConstraint", { MinTextSize = 8 }, l)
	end
	local f = (o.key and function() l.Text = tr(o.key) end) or (o.fn and function() l.Text = o.fn() end)
	if f then onLang(f) end
	onStyle(function(t)
		l.Font = o.head and t.head or t.body
		local s = math.floor(o.sz * t.fs + 0.5)
		if con then con.MaxTextSize = s else l.TextSize = s end
		l.TextColor3 = t[o.role or "text"]
	end)
	return l
end

local function mkCard(parent, pos, size)
	local f = new("Frame", { Position = pos, Size = size, BorderSizePixel = 0, ZIndex = 3 }, parent)
	local cc = new("UICorner", {}, f)
	local ss = new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
	new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }, f)
	onStyle(function(t)
		f.BackgroundColor3 = t.panel
		f.BackgroundTransparency = t.ptr
		cc.CornerRadius = UDim.new(0, t.crad)
		ss.Color = t.line
		ss.Thickness = t.cw
		ss.Transparency = 0.4
	end)
	return f
end

local function mkBtn(parent, o)
	local b = new("TextButton", { AutoButtonColor = false, BorderSizePixel = 0, Text = "",
		Position = o.pos, Size = o.size, ZIndex = o.z or 5 }, parent)
	local cr = new("UICorner", {}, b)
	if o.key or o.fn then onLang(function() b.Text = o.key and tr(o.key) or o.fn() end) end
	onStyle(function(t)
		b.Font = t.head
		b.TextSize = math.floor(o.sz * t.fs + 0.5)
		cr.CornerRadius = UDim.new(0, t.brad)
		if o.plain then
			b.BackgroundColor3 = t.panel; b.BackgroundTransparency = t.ptr; b.TextColor3 = t.text
		else
			b.BackgroundColor3 = t.accent; b.BackgroundTransparency = 0; b.TextColor3 = t.onAccent
		end
	end)
	b.Activated:Connect(o.tap)
	return b
end

------------------------------------------------------------------ ЗАГОЛОВОК
local tb = new("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, TB), ZIndex = 3 }, win)
local tbLine = new("Frame", { BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, TB), Size = UDim2.new(1, 0, 0, 1), ZIndex = 3 }, win)
onStyle(function(t) tbLine.BackgroundColor3 = t.line; tbLine.BackgroundTransparency = 0.6 end)
mkText(tb, { fn = function() return cur.icon .. "  Delta Panel" end, sz = 15, head = true,
	pos = UDim2.new(0, 14, 0, 0), size = UDim2.new(1, -110, 1, 0) })
mkBtn(tb, { fn = function() return lang:upper() end, sz = 12, pos = UDim2.new(1, -90, 0.5, -12), size = UDim2.new(0, 46, 0, 24),
	tap = function() lang = (lang == "ru") and "en" or "ru"; refreshText(); buildDeco() end })
mkBtn(tb, { text = "✕", fn = function() return "✕" end, sz = 13, plain = true, pos = UDim2.new(1, -38, 0.5, -12),
	size = UDim2.new(0, 28, 0, 24), tap = function() end })

------------------------------------------------------------------ БОКОВАЯ ПАНЕЛЬ
local side = new("Frame", { BorderSizePixel = 0, ZIndex = 3 }, win)
local sideC = new("UICorner", {}, side)
onStyle(function(t)
	side.BackgroundColor3 = t.panel
	side.BackgroundTransparency = math.min(t.ptr + 0.15, 0.7)
	sideC.CornerRadius = UDim.new(0, t.crad)
	side.Position = UDim2.new(0, 8, 0, TB + 8)
	side.Size = UDim2.new(0, t.side - 8, 1, -(TB + 16))
end)

local pages = {}
local main = new("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2 }, win)
onStyle(function(t)
	main.Position = UDim2.new(0, t.side + 2, 0, TB + 1)
	main.Size = UDim2.new(1, -(t.side + 2), 1, -(TB + 1))
end)
for i = 1, 3 do
	pages[i] = new("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 2 }, main)
	new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10) }, pages[i])
end

local function showPage(i)
	tabSel = i
	for k, p in ipairs(pages) do p.Visible = (k == i) end
	restyle()
end

local TABS = { { "🏠", "tab_home" }, { "🎨", "tab_themes" }, { "📜", "tab_about" } }
for i, tdef in ipairs(TABS) do
	local b = new("TextButton", { AutoButtonColor = false, BorderSizePixel = 0, Text = "", TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 8, 0, 10 + (i - 1) * 46), Size = UDim2.new(1, -16, 0, 40), ZIndex = 5 }, side)
	local cr = new("UICorner", {}, b)
	new("UIPadding", { PaddingLeft = UDim.new(0, 10) }, b)
	onLang(function() b.Text = tdef[1] .. "  " .. tr(tdef[2]) end)
	onStyle(function(t)
		local sel = (tabSel == i)
		b.BackgroundColor3 = t.accent
		b.BackgroundTransparency = sel and 0 or 1
		b.TextColor3 = sel and t.onAccent or t.sub
		b.Font = t.head
		b.TextSize = math.floor(13 * t.fs + 0.5)
		cr.CornerRadius = UDim.new(0, t.brad)
	end)
	b.Activated:Connect(function() showPage(i) end)
end
mkText(side, { key = "footer", sz = 10, role = "sub", wrap = true, xa = Enum.TextXAlignment.Center,
	pos = UDim2.new(0, 6, 1, -36), size = UDim2.new(1, -12, 0, 30) })

------------------------------------------------------------------ СТРАНИЦА 1: ГЛАВНАЯ
local p1 = pages[1]
local clockCard = mkCard(p1, UDim2.new(0, 0, 0, 0), UDim2.new(0.58, -5, 0.6, -5))
local langCard = mkCard(p1, UDim2.new(0.58, 5, 0, 0), UDim2.new(0.42, -5, 0.6, -5))
local themeCard = mkCard(p1, UDim2.new(0, 0, 0.6, 5), UDim2.new(1, 0, 0.4, -5))

mkText(clockCard, { fn = function() return "🕒  " .. tr("clock_cap") end, sz = 12, role = "sub", size = UDim2.new(1, 0, 0, 16) })
local timeLbl = mkText(clockCard, { text = "00:00:00", sz = 32, head = true, role = "accent", scaled = true,
	pos = UDim2.new(0, 0, 0, 22), size = UDim2.new(1, 0, 0, 44) })
local dateLbl = mkText(clockCard, { text = "", sz = 12, role = "text", pos = UDim2.new(0, 0, 1, -34), size = UDim2.new(1, 0, 0, 16) })
mkText(clockCard, { key = "tz", sz = 11, role = "sub", pos = UDim2.new(0, 0, 1, -18), size = UDim2.new(1, 0, 0, 16) })

mkText(langCard, { fn = function() return "🌐  " .. tr("lang_cap") end, sz = 12, role = "sub", size = UDim2.new(1, 0, 0, 16), trunc = true })
mkText(langCard, { key = "lang_val", sz = 22, head = true, role = "accent", scaled = true,
	pos = UDim2.new(0, 0, 0, 24), size = UDim2.new(1, 0, 0, 32) })
mkBtn(langCard, { key = "lang_btn", sz = 11, pos = UDim2.new(0, 0, 1, -32), size = UDim2.new(1, 0, 0, 32),
	tap = function() lang = (lang == "ru") and "en" or "ru"; refreshText(); buildDeco() end })

mkText(themeCard, { fn = function() return cur.icon end, sz = 30, xa = Enum.TextXAlignment.Center, size = UDim2.new(0, 44, 1, 0) })
mkText(themeCard, { key = "theme_cap", sz = 11, role = "sub", pos = UDim2.new(0, 52, 0, 0), size = UDim2.new(1, -52, 0, 14) })
mkText(themeCard, { fn = function() return cur.name[lang] end, sz = 16, head = true, trunc = true,
	pos = UDim2.new(0, 52, 0, 15), size = UDim2.new(1, -52, 0, 22) })
mkText(themeCard, { fn = function() return cur.desc[lang] end, sz = 11, role = "sub", wrap = true, ya = Enum.TextYAlignment.Top,
	pos = UDim2.new(0, 52, 0, 38), size = UDim2.new(1, -52, 0, 28) })

------------------------------------------------------------------ СТРАНИЦА 2: ТЕМЫ
local p2 = pages[2]
mkText(p2, { key = "themes_hdr", sz = 14, head = true, size = UDim2.new(1, 0, 0, 20) })
mkText(p2, { key = "themes_sub", sz = 11, role = "sub", pos = UDim2.new(0, 0, 0, 20), size = UDim2.new(1, 0, 0, 14) })
local scroll2 = new("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 40),
	Size = UDim2.new(1, 0, 1, -40), ScrollBarThickness = 4, ScrollingDirection = Enum.ScrollingDirection.Y,
	AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ZIndex = 3 }, p2)
new("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 6) }, scroll2)
new("UIGridLayout", { CellSize = UDim2.new(0.5, -5, 0, 58), CellPadding = UDim2.new(0, 8, 0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, scroll2)
onStyle(function(t) scroll2.ScrollBarImageColor3 = t.accent end)

for i, th in ipairs(THEMES) do
	local card = new("TextButton", { AutoButtonColor = false, Text = "", BorderSizePixel = 0, LayoutOrder = i,
		BackgroundColor3 = th.bg, ZIndex = 4 }, scroll2)
	new("UICorner", { CornerRadius = UDim.new(0, math.min(th.crad, 22)) }, card)
	local st = new("UIStroke", { Color = th.accent, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, card)
	new("TextLabel", { BackgroundTransparency = 1, Text = th.icon, TextSize = 22, Font = Enum.Font.SourceSansBold,
		Position = UDim2.new(0, 6, 0, 0), Size = UDim2.new(0, 34, 1, 0), ZIndex = 5 }, card)
	local nm = new("TextLabel", { BackgroundTransparency = 1, Font = th.head, TextSize = math.floor(12 * th.fs + 0.5),
		TextColor3 = th.text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.new(0, 44, 0, 7), Size = UDim2.new(1, -70, 0, 18), ZIndex = 5 }, card)
	local ds = new("TextLabel", { BackgroundTransparency = 1, Font = th.body, TextSize = math.floor(10 * th.fs + 0.5),
		TextColor3 = th.sub, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true, Position = UDim2.new(0, 44, 0, 26), Size = UDim2.new(1, -50, 0, 28), ZIndex = 5 }, card)
	local mark = new("TextLabel", { BackgroundTransparency = 1, Text = "✓", Font = Enum.Font.GothamBold, TextSize = 14,
		TextColor3 = th.accent, Position = UDim2.new(1, -24, 0, 4), Size = UDim2.new(0, 20, 0, 18), ZIndex = 5 }, card)
	onLang(function() nm.Text = th.name[lang]; ds.Text = th.desc[lang] end)
	onStyle(function()
		local sel = (themeId == i)
		st.Thickness = sel and (th.cw + 2) or th.cw
		st.Transparency = sel and 0 or 0.45
		mark.Visible = sel
	end)
	card.Activated:Connect(function()
		themeId = i
		cur = THEMES[i]
		restyle()
		buildDeco()
		refreshText()
	end)
end

------------------------------------------------------------------ СТРАНИЦА 3: О СКРИПТЕ
local p3 = pages[3]
mkText(p3, { key = "about_hdr", sz = 14, head = true, size = UDim2.new(1, 0, 0, 22) })
local scroll3 = new("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 26),
	Size = UDim2.new(1, 0, 1, -26), ScrollBarThickness = 4, ScrollingDirection = Enum.ScrollingDirection.Y,
	AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ZIndex = 3 }, p3)
new("UIPadding", { PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 6) }, scroll3)
onStyle(function(t) scroll3.ScrollBarImageColor3 = t.accent end)
local aboutCard = mkCard(scroll3, UDim2.new(), UDim2.new(1, 0, 0, 0))
aboutCard.AutomaticSize = Enum.AutomaticSize.Y
new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, aboutCard)
mkText(aboutCard, { text = "📜  Delta Panel", sz = 15, head = true, role = "accent", size = UDim2.new(1, 0, 0, 20) })
mkText(aboutCard, { key = "about_body", sz = 12, wrap = true, auto = true, ya = Enum.TextYAlignment.Top, size = UDim2.new(1, 0, 0, 0) })

------------------------------------------------------------------ ОТКРЫТИЕ / ЗАКРЫТИЕ
local function setOpen(v)
	open = v
	fab.Text = v and "✕" or "☰"
	if v then
		win.Visible = true
		winScale.Scale = 0.85
		TweenService:Create(winScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	else
		TweenService:Create(winScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.85 }):Play()
		task.delay(0.16, function() if not open then win.Visible = false end end)
	end
	fabScale.Scale = 0.9
	TweenService:Create(fabScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end

-- крестик в заголовке закрывает окно
for _, d in ipairs(tb:GetChildren()) do
	if d:IsA("TextButton") and d.Text == "✕" then d.Activated:Connect(function() setOpen(false) end) end
end

makeDraggable(tb, win, Vector2.new(W, H))
makeDraggable(fab, fab, Vector2.new(56, 56), function() setOpen(not open) end)

------------------------------------------------------------------ ЧАСЫ (МСК, UTC+3)
local function nowUtc()
	local ok, t = pcall(function() return math.floor(workspace:GetServerTimeNow()) end)
	if ok and t then return t end
	return os.time()
end
task.spawn(function()
	while gui.Parent do
		local t = os.date("!*t", nowUtc() + 3 * 3600)
		timeLbl.Text = string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
		dateLbl.Text = string.format("%s, %02d.%02d.%04d", STR[lang].days[t.wday], t.day, t.month, t.year)
		task.wait(0.2)
	end
end)

------------------------------------------------------------------ СТАРТ
showPage(1)
buildDeco()
refreshText()
print("[Delta Panel] loaded")
