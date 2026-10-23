-- Delta Android UI v2: Spacious Sidebar Dashboard & Procedural Background Engines

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local parentGui
pcall(function()
	parentGui = (gethui and gethui()) or CoreGui
end)
if not parentGui then
	parentGui = Players.LocalPlayer:WaitForChild("PlayerGui")
end

if parentGui:FindFirstChild("DeltaMasterUI_v2") then
	parentGui.DeltaMasterUI_v2:Destroy()
end

-- ==========================================
-- 1. LOCALIZATION (EN / RU)
-- ==========================================
local currentLang = "RU"

local Lang = {
	RU = {
		OpenBtn = "◈ Открыть",
		CloseBtn = "✕ Скрыть",
		SidebarSub = "СИСТЕМНОЕ МЕНЮ",
		SectionThemes = "ВЫБОР ОФОРМЛЕНИЯ",
		ClockHeader = "ТОЧНОЕ ВРЕМЯ (UTC+3)",
		ClockSub = "Московский часовой пояс • Синхронизировано",
		LangHeader = "ЛОКАЛИЗАЦИЯ ИНТЕРФЕЙСА",
		LangValue = "Русский язык (RU)",
		LangSwitchBtn = "Switch to English ➔",
		AboutHeader = "ИНФОРМАЦИЯ О СКРИПТЕ",
		AboutBody = "Модульная панель управления для Delta Android. Поддерживает процедурные фоновые слои (сетка, сканлайны, орнаменты, неоновые сферы), адаптивную верстку с отступами и мгновенный перевод.",
		Themes = {
			"1. Чертежная Сетка",
			"2. Военный Бункер",
			"3. Ретро ЭЛТ-Монитор",
			"4. Неоновое Стекло",
			"5. Имперский Орден"
		}
	},
	EN = {
		OpenBtn = "◈ Open UI",
		CloseBtn = "✕ Hide UI",
		SidebarSub = "SYSTEM OVERLAY",
		SectionThemes = "VISUAL ARCHITECTURE",
		ClockHeader = "REAL-TIME CLOCK (UTC+3)",
		ClockSub = "Moscow Standard Time • Live Sync",
		LangHeader = "INTERFACE LANGUAGE",
		LangValue = "English (US/UK)",
		LangSwitchBtn = "Переключить на Русский ➔",
		AboutHeader = "SCRIPT SPECIFICATION",
		AboutBody = "Modular dashboard engineered for Delta Android. Features procedural background canvas engines (grid lines, hazard stripes, CRT scanlines, bokeh orbs, ornate frames) and clean typography.",
		Themes = {
			"1. Blueprint Grid",
			"2. War Room Hazard",
			"3. CRT Scanlines",
			"4. Glass Bokeh Orbs",
			"5. Imperial Ornate"
		}
	}
}

-- ==========================================
-- 2. 5 DISTINCT ARCHITECTURAL THEMES
-- ==========================================
local Themes = {
	[1] = { -- Blueprint Grid
		Bg = Color3.fromRGB(12, 22, 38),
		Sidebar = Color3.fromRGB(9, 16, 28),
		Card = Color3.fromRGB(18, 32, 54),
		Accent = Color3.fromRGB(56, 189, 248),
		TextPrimary = Color3.fromRGB(240, 249, 255),
		TextMuted = Color3.fromRGB(125, 165, 205),
		Corner = UDim.new(0, 8),
		Stroke = 1.5,
		TitleFont = Enum.Font.GothamBold,
		BodyFont = Enum.Font.GothamMedium,
		ClockFont = Enum.Font.Code,
		BadgeIcon = "📐",
		HeaderSign = "[ CAD // GRID-01 ]",
		Pattern = "Grid"
	},
	[2] = { -- War Room Hazard (Military / Swastika-style geometric cross option requested)
		Bg = Color3.fromRGB(24, 22, 18),
		Sidebar = Color3.fromRGB(18, 16, 13),
		Card = Color3.fromRGB(34, 31, 26),
		Accent = Color3.fromRGB(235, 168, 35),
		TextPrimary = Color3.fromRGB(245, 240, 225),
		TextMuted = Color3.fromRGB(160, 150, 130),
		Corner = UDim.new(0, 0), -- Hard sharp corners
		Stroke = 2.5,
		TitleFont = Enum.Font.Oswald,
		BodyFont = Enum.Font.Highway,
		ClockFont = Enum.Font.Code,
		BadgeIcon = "卐",
		HeaderSign = "✠ СЕКТОР-09 // ШТАБ 卐",
		Pattern = "Hazard"
	},
	[3] = { -- CRT Scanlines
		Bg = Color3.fromRGB(6, 14, 8),
		Sidebar = Color3.fromRGB(4, 9, 5),
		Card = Color3.fromRGB(10, 24, 14),
		Accent = Color3.fromRGB(34, 255, 102),
		TextPrimary = Color3.fromRGB(180, 255, 200),
		TextMuted = Color3.fromRGB(60, 165, 90),
		Corner = UDim.new(0, 3),
		Stroke = 1,
		TitleFont = Enum.Font.Code,
		BodyFont = Enum.Font.Code,
		ClockFont = Enum.Font.Arcade,
		BadgeIcon = "📟",
		HeaderSign = "root@delta:~# ./sys",
		Pattern = "Scanlines"
	},
	[4] = { -- Glass Bokeh Orbs
		Bg = Color3.fromRGB(19, 15, 34),
		Sidebar = Color3.fromRGB(14, 11, 26),
		Card = Color3.fromRGB(30, 24, 52),
		Accent = Color3.fromRGB(192, 132, 252),
		TextPrimary = Color3.fromRGB(250, 245, 255),
		TextMuted = Color3.fromRGB(165, 145, 195),
		Corner = UDim.new(0, 16), -- Smooth modern curves
		Stroke = 1.5,
		TitleFont = Enum.Font.GothamBold,
		BodyFont = Enum.Font.Gotham,
		ClockFont = Enum.Font.GothamBold,
		BadgeIcon = "🔮",
		HeaderSign = "✦ AETHER GLASS UI",
		Pattern = "Orbs"
	},
	[5] = { -- Imperial Ornate Frame
		Bg = Color3.fromRGB(26, 11, 14),
		Sidebar = Color3.fromRGB(18, 7, 9),
		Card = Color3.fromRGB(40, 16, 21),
		Accent = Color3.fromRGB(245, 195, 95),
		TextPrimary = Color3.fromRGB(255, 242, 225),
		TextMuted = Color3.fromRGB(195, 150, 140),
		Corner = UDim.new(0, 4),
		Stroke = 2,
		TitleFont = Enum.Font.Antique,
		BodyFont = Enum.Font.Garamond,
		ClockFont = Enum.Font.Antique,
		BadgeIcon = "⚜",
		HeaderSign = "◆ ИМПЕРСКИЙ АРХИВ ◆",
		Pattern = "Imperial"
	}
}

local activeTheme = 1
local menuVisible = true

-- ==========================================
-- 3. DRAG FUNCTIONALITY (Mobile + PC)
-- ==========================================
local function enableDrag(target, handle)
	local dragging, dragInput, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- ==========================================
-- 4. MAIN GUI & FLOATING TOGGLE BUTTON
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMasterUI_v2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parentGui

local CornerRegistry = {}
local StrokeRegistry = {}
local CardRegistry = {}

-- Floating Toggle Pill
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 130, 0, 42)
ToggleBtn.Position = UDim2.new(0.04, 0, 0.1, 0)
ToggleBtn.TextSize = 14
ToggleBtn.AutoButtonColor = true
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner", ToggleBtn)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
table.insert(CornerRegistry, ToggleCorner)
table.insert(StrokeRegistry, ToggleStroke)
enableDrag(ToggleBtn, ToggleBtn)

-- Main Window (530 x 340 - Spacious 2-Column Layout)
local MainWindow = Instance.new("Frame")
MainWindow.Size = UDim2.new(0, 530, 0, 340)
MainWindow.Position = UDim2.new(0.5, -265, 0.5, -170)
MainWindow.ClipsDescendants = true
MainWindow.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainWindow)
local MainStroke = Instance.new("UIStroke", MainWindow)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
table.insert(CornerRegistry, MainCorner)
table.insert(StrokeRegistry, MainStroke)

-- Dedicated Background Pattern Canvas (Sits behind everything)
local PatternCanvas = Instance.new("Folder")
PatternCanvas.Name = "PatternCanvas"
PatternCanvas.Parent = MainWindow

-- ==========================================
-- 5. PROCEDURAL BACKGROUND ENGINE
-- ==========================================
local function rebuildBackgroundPattern(patternType, accentColor)
	PatternCanvas:ClearAllChildren()

	if patternType == "Grid" then
		-- Vertical Blueprint Lines
		for x = 1, 13 do
			local vLine = Instance.new("Frame")
			vLine.Size = UDim2.new(0, 1, 1, 0)
			vLine.Position = UDim2.new(0, x * 40, 0, 0)
			vLine.BackgroundColor3 = accentColor
			vLine.BackgroundTransparency = 0.88
			vLine.BorderSizePixel = 0
			vLine.ZIndex = 1
			vLine.Parent = PatternCanvas
		end
		-- Horizontal Blueprint Lines
		for y = 1, 8 do
			local hLine = Instance.new("Frame")
			hLine.Size = UDim2.new(1, 0, 0, 1)
			hLine.Position = UDim2.new(0, 0, 0, y * 40)
			hLine.BackgroundColor3 = accentColor
			hLine.BackgroundTransparency = 0.88
			hLine.BorderSizePixel = 0
			hLine.ZIndex = 1
			hLine.Parent = PatternCanvas
		end
		-- Technical Crosshairs
		local coords = {UDim2.new(0, 195, 0, 12), UDim2.new(1, -28, 0, 12), UDim2.new(0, 195, 1, -24), UDim2.new(1, -28, 1, -24)}
		for _, pos in ipairs(coords) do
			local mark = Instance.new("TextLabel")
			mark.Size = UDim2.new(0, 16, 0, 16)
			mark.Position = pos
			mark.BackgroundTransparency = 1
			mark.Text = "+"
			mark.TextColor3 = accentColor
			mark.TextTransparency = 0.4
			mark.TextSize = 16
			mark.Font = Enum.Font.Code
			mark.ZIndex = 1
			mark.Parent = PatternCanvas
		end

	elseif patternType == "Hazard" then
		-- Top & Bottom Caution Tape Bars
		for _, yPos in ipairs({0, 330}) do
			local bar = Instance.new("Frame")
			bar.Size = UDim2.new(1, 0, 0, 10)
			bar.Position = UDim2.new(0, 0, 0, yPos)
			bar.BackgroundColor3 = Color3.fromRGB(15, 14, 12)
			bar.BorderSizePixel = 0
			bar.ZIndex = 2
			bar.Parent = PatternCanvas

			for i = 0, 26 do
				local stripe = Instance.new("Frame")
				stripe.Size = UDim2.new(0, 10, 1, 0)
				stripe.Position = UDim2.new(0, i * 22, 0, 0)
				stripe.BackgroundColor3 = accentColor
				stripe.BackgroundTransparency = 0.25
				stripe.BorderSizePixel = 0
				stripe.ZIndex = 2
				stripe.Parent = bar
			end
		end
		-- Large Watermark Insignia in Background Corner
		local watermark = Instance.new("TextLabel")
		watermark.Size = UDim2.new(0, 180, 0, 180)
		watermark.Position = UDim2.new(1, -160, 1, -160)
		watermark.BackgroundTransparency = 1
		watermark.Text = "卐"
		watermark.TextColor3 = accentColor
		watermark.TextTransparency = 0.91
		watermark.TextSize = 150
		watermark.Font = Enum.Font.Oswald
		watermark.ZIndex = 1
		watermark.Parent = PatternCanvas

	elseif patternType == "Scanlines" then
		-- Retro CRT Horizontal Scanlines
		for y = 1, 56 do
			local scan = Instance.new("Frame")
			scan.Size = UDim2.new(1, 0, 0, 2)
			scan.Position = UDim2.new(0, 0, 0, y * 6)
			scan.BackgroundColor3 = accentColor
			scan.BackgroundTransparency = 0.93
			scan.BorderSizePixel = 0
			scan.ZIndex = 1
			scan.Parent = PatternCanvas
		end

	elseif patternType == "Orbs" then
		-- Floating Neon Bokeh Circles
		local orbSpecs = {
			{Size = 180, Pos = UDim2.new(0, 160, 0, -40), Trans = 0.88},
			{Size = 220, Pos = UDim2.new(1, -120, 1, -110), Trans = 0.86},
			{Size = 110, Pos = UDim2.new(0, 240, 1, -70), Trans = 0.90}
		}
		for _, spec in ipairs(orbSpecs) do
			local orb = Instance.new("Frame")
			orb.Size = UDim2.new(0, spec.Size, 0, spec.Size)
			orb.Position = spec.Pos
			orb.BackgroundColor3 = accentColor
			orb.BackgroundTransparency = spec.Trans
			orb.BorderSizePixel = 0
			orb.ZIndex = 1
			orb.Parent = PatternCanvas
			local c = Instance.new("UICorner", orb)
			c.CornerRadius = UDim.new(1, 0)
		end

	elseif patternType == "Imperial" then
		-- Inner Ceremonial Gold Frame
		local innerFrame = Instance.new("Frame")
		innerFrame.Size = UDim2.new(1, -16, 1, -16)
		innerFrame.Position = UDim2.new(0, 8, 0, 8)
		innerFrame.BackgroundTransparency = 1
		innerFrame.ZIndex = 1
		innerFrame.Parent = PatternCanvas

		local iStroke = Instance.new("UIStroke", innerFrame)
		iStroke.Color = accentColor
		iStroke.Transparency = 0.55
		iStroke.Thickness = 1

		-- Corner Diamonds
		local corners = {
			UDim2.new(0, 12, 0, 12),
			UDim2.new(1, -28, 0, 12),
			UDim2.new(0, 12, 1, -28),
			UDim2.new(1, -28, 1, -28)
		}
		for _, pos in ipairs(corners) do
			local diamond = Instance.new("TextLabel")
			diamond.Size = UDim2.new(0, 16, 0, 16)
			diamond.Position = pos
			diamond.BackgroundTransparency = 1
			diamond.Text = "❖"
			diamond.TextColor3 = accentColor
			diamond.TextTransparency = 0.25
			diamond.TextSize = 15
			diamond.ZIndex = 2
			diamond.Parent = PatternCanvas
		end
	end
end

-- ==========================================
-- 6. LEFT SIDEBAR (Navigation & 5 Themes)
-- ==========================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 175, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3
Sidebar.Parent = MainWindow

local SidebarDivider = Instance.new("Frame")
SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
SidebarDivider.Position = UDim2.new(1, 0, 0, 0)
SidebarDivider.BorderSizePixel = 0
SidebarDivider.ZIndex = 4
SidebarDivider.Parent = Sidebar

-- Brand Header Inside Sidebar
local BrandBadge = Instance.new("TextLabel")
BrandBadge.Size = UDim2.new(0, 36, 0, 36)
BrandBadge.Position = UDim2.new(0, 16, 0, 18)
BrandBadge.BackgroundTransparency = 0.15
BrandBadge.TextSize = 20
BrandBadge.ZIndex = 4
BrandBadge.Parent = Sidebar
local BadgeCorner = Instance.new("UICorner", BrandBadge)
table.insert(CornerRegistry, BadgeCorner)

local BrandTitle = Instance.new("TextLabel")
BrandTitle.Size = UDim2.new(1, -68, 0, 20)
BrandTitle.Position = UDim2.new(0, 60, 0, 17)
BrandTitle.BackgroundTransparency = 1
BrandTitle.Text = "DELTA UI"
BrandTitle.TextSize = 17
BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
BrandTitle.ZIndex = 4
BrandTitle.Parent = Sidebar

local BrandSub = Instance.new("TextLabel")
BrandSub.Size = UDim2.new(1, -68, 0, 14)
BrandSub.Position = UDim2.new(0, 60, 0, 37)
BrandSub.BackgroundTransparency = 1
BrandSub.TextSize = 10
BrandSub.TextXAlignment = Enum.TextXAlignment.Left
BrandSub.ZIndex = 4
BrandSub.Parent = Sidebar

enableDrag(MainWindow, Sidebar)

-- Theme Section Label
local ThemeSectionTitle = Instance.new("TextLabel")
ThemeSectionTitle.Size = UDim2.new(1, -32, 0, 16)
ThemeSectionTitle.Position = UDim2.new(0, 16, 0, 72)
ThemeSectionTitle.BackgroundTransparency = 1
ThemeSectionTitle.TextSize = 10
ThemeSectionTitle.TextXAlignment = Enum.TextXAlignment.Left
ThemeSectionTitle.ZIndex = 4
ThemeSectionTitle.Parent = Sidebar

-- Theme Buttons Container
local ThemeListFrame = Instance.new("Frame")
ThemeListFrame.Size = UDim2.new(1, -28, 0, 230)
ThemeListFrame.Position = UDim2.new(0, 14, 0, 94)
ThemeListFrame.BackgroundTransparency = 1
ThemeListFrame.ZIndex = 4
ThemeListFrame.Parent = Sidebar

local ThemeListLayout = Instance.new("UIListLayout", ThemeListFrame)
ThemeListLayout.Padding = UDim.new(0, 8)
ThemeListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ThemeBtnObjects = {}

-- ==========================================
-- 7. RIGHT CONTENT AREA (Spacious Cards)
-- ==========================================
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -175, 1, 0)
ContentArea.Position = UDim2.new(0, 175, 0, 0)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 3
ContentArea.Parent = MainWindow

enableDrag(MainWindow, ContentArea)

-- Top Technical Status Banner
local TopStatusSign = Instance.new("TextLabel")
TopStatusSign.Size = UDim2.new(1, -40, 0, 20)
TopStatusSign.Position = UDim2.new(0, 20, 0, 14)
TopStatusSign.BackgroundTransparency = 1
TopStatusSign.TextSize = 12
TopStatusSign.TextXAlignment = Enum.TextXAlignment.Right
TopStatusSign.ZIndex = 4
TopStatusSign.Parent = ContentArea

-- Card 1: Real-Time Moscow Clock
local ClockCard = Instance.new("Frame")
ClockCard.Size = UDim2.new(1, -40, 0, 84)
ClockCard.Position = UDim2.new(0, 20, 0, 40)
ClockCard.BackgroundTransparency = 0.08
ClockCard.ZIndex = 4
ClockCard.Parent = ContentArea
table.insert(CardRegistry, ClockCard)
table.insert(CornerRegistry, Instance.new("UICorner", ClockCard))
local cStroke1 = Instance.new("UIStroke", ClockCard)
table.insert(StrokeRegistry, cStroke1)

local ClockIconBox = Instance.new("TextLabel")
ClockIconBox.Size = UDim2.new(0, 48, 0, 48)
ClockIconBox.Position = UDim2.new(0, 16, 0.5, -24)
ClockIconBox.BackgroundTransparency = 0.85
ClockIconBox.Text = "🕒"
ClockIconBox.TextSize = 22
ClockIconBox.ZIndex = 5
ClockIconBox.Parent = ClockCard
table.insert(CornerRegistry, Instance.new("UICorner", ClockIconBox))

local ClockHeaderLbl = Instance.new("TextLabel")
ClockHeaderLbl.Size = UDim2.new(1, -88, 0, 14)
ClockHeaderLbl.Position = UDim2.new(0, 76, 0, 12)
ClockHeaderLbl.BackgroundTransparency = 1
ClockHeaderLbl.TextSize = 10
ClockHeaderLbl.TextXAlignment = Enum.TextXAlignment.Left
ClockHeaderLbl.ZIndex = 5
ClockHeaderLbl.Parent = ClockCard

local ClockDigitsLbl = Instance.new("TextLabel")
ClockDigitsLbl.Size = UDim2.new(1, -88, 0, 32)
ClockDigitsLbl.Position = UDim2.new(0, 76, 0, 26)
ClockDigitsLbl.BackgroundTransparency = 1
ClockDigitsLbl.Text = "00:00:00"
ClockDigitsLbl.TextSize = 26
ClockDigitsLbl.TextXAlignment = Enum.TextXAlignment.Left
ClockDigitsLbl.ZIndex = 5
ClockDigitsLbl.Parent = ClockCard

local ClockSubLbl = Instance.new("TextLabel")
ClockSubLbl.Size = UDim2.new(1, -88, 0, 14)
ClockSubLbl.Position = UDim2.new(0, 76, 0, 58)
ClockSubLbl.BackgroundTransparency = 1
ClockSubLbl.TextSize = 11
ClockSubLbl.TextXAlignment = Enum.TextXAlignment.Left
ClockSubLbl.ZIndex = 5
ClockSubLbl.Parent = ClockCard

-- Card 2: Language Selector
local LangCard = Instance.new("Frame")
LangCard.Size = UDim2.new(1, -40, 0, 68)
LangCard.Position = UDim2.new(0, 20, 0, 136)
LangCard.BackgroundTransparency = 0.08
LangCard.ZIndex = 4
LangCard.Parent = ContentArea
table.insert(CardRegistry, LangCard)
table.insert(CornerRegistry, Instance.new("UICorner", LangCard))
local cStroke2 = Instance.new("UIStroke", LangCard)
table.insert(StrokeRegistry, cStroke2)

local LangIconBox = Instance.new("TextLabel")
LangIconBox.Size = UDim2.new(0, 42, 0, 42)
LangIconBox.Position = UDim2.new(0, 16, 0.5, -21)
LangIconBox.BackgroundTransparency = 0.85
LangIconBox.Text = "🌐"
LangIconBox.TextSize = 20
LangIconBox.ZIndex = 5
LangIconBox.Parent = LangCard
table.insert(CornerRegistry, Instance.new("UICorner", LangIconBox))

local LangHeaderLbl = Instance.new("TextLabel")
LangHeaderLbl.Size = UDim2.new(0.5, -60, 0, 14)
LangHeaderLbl.Position = UDim2.new(0, 70, 0, 14)
LangHeaderLbl.BackgroundTransparency = 1
LangHeaderLbl.TextSize = 10
LangHeaderLbl.TextXAlignment = Enum.TextXAlignment.Left
LangHeaderLbl.ZIndex = 5
LangHeaderLbl.Parent = LangCard

local LangValueLbl = Instance.new("TextLabel")
LangValueLbl.Size = UDim2.new(0.5, -60, 0, 22)
LangValueLbl.Position = UDim2.new(0, 70, 0, 30)
LangValueLbl.BackgroundTransparency = 1
LangValueLbl.TextSize = 14
LangValueLbl.TextXAlignment = Enum.TextXAlignment.Left
LangValueLbl.ZIndex = 5
LangValueLbl.Parent = LangCard

local LangSwitchBtn = Instance.new("TextButton")
LangSwitchBtn.Size = UDim2.new(0, 148, 0, 34)
LangSwitchBtn.Position = UDim2.new(1, -162, 0.5, -17)
LangSwitchBtn.TextSize = 12
LangSwitchBtn.AutoButtonColor = true
LangSwitchBtn.ZIndex = 5
LangSwitchBtn.Parent = LangCard
table.insert(CornerRegistry, Instance.new("UICorner", LangSwitchBtn))
local lBtnStroke = Instance.new("UIStroke", LangSwitchBtn)
lBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
table.insert(StrokeRegistry, lBtnStroke)

-- Card 3: Script Description
local AboutCard = Instance.new("Frame")
AboutCard.Size = UDim2.new(1, -40, 0, 108)
AboutCard.Position = UDim2.new(0, 20, 0, 216)
AboutCard.BackgroundTransparency = 0.08
AboutCard.ZIndex = 4
AboutCard.Parent = ContentArea
table.insert(CardRegistry, AboutCard)
table.insert(CornerRegistry, Instance.new("UICorner", AboutCard))
local cStroke3 = Instance.new("UIStroke", AboutCard)
table.insert(StrokeRegistry, cStroke3)

local AboutHeaderLbl = Instance.new("TextLabel")
AboutHeaderLbl.Size = UDim2.new(1, -32, 0, 18)
AboutHeaderLbl.Position = UDim2.new(0, 16, 0, 12)
AboutHeaderLbl.BackgroundTransparency = 1
AboutHeaderLbl.TextSize = 11
AboutHeaderLbl.TextXAlignment = Enum.TextXAlignment.Left
AboutHeaderLbl.ZIndex = 5
AboutHeaderLbl.Parent = AboutCard

local AboutBodyLbl = Instance.new("TextLabel")
AboutBodyLbl.Size = UDim2.new(1, -32, 0, 66)
AboutBodyLbl.Position = UDim2.new(0, 16, 0, 32)
AboutBodyLbl.BackgroundTransparency = 1
AboutBodyLbl.TextSize = 12
AboutBodyLbl.TextWrapped = true
AboutBodyLbl.TextXAlignment = Enum.TextXAlignment.Left
AboutBodyLbl.TextYAlignment = Enum.TextYAlignment.Top
AboutBodyLbl.ZIndex = 5
AboutBodyLbl.Parent = AboutCard

-- ==========================================
-- 8. LOGIC: TIME, TEXTS & THEME ENGINE
-- ==========================================
local function getMoscowTime()
	local msk = os.date("!*t", os.time() + 10800)
	return string.format("%02d:%02d:%02d", msk.hour, msk.min, msk.sec)
end

local function refreshLanguage()
	local t = Lang[currentLang]
	ToggleBtn.Text = menuVisible and t.CloseBtn or t.OpenBtn
	BrandSub.Text = t.SidebarSub
	ThemeSectionTitle.Text = t.SectionThemes
	ClockHeaderLbl.Text = t.ClockHeader
	ClockSubLbl.Text = t.ClockSub
	LangHeaderLbl.Text = t.LangHeader
	LangValueLbl.Text = t.LangValue
	LangSwitchBtn.Text = t.LangSwitchBtn
	AboutHeaderLbl.Text = "ⓘ  " .. t.AboutHeader
	AboutBodyLbl.Text = t.AboutBody

	for i, btn in ipairs(ThemeBtnObjects) do
		btn.Text = "  " .. t.Themes[i]
	end
end

local function applyTheme(index)
	activeTheme = index
	local th = Themes[index]

	-- Window & Sidebar Colors
	MainWindow.BackgroundColor3 = th.Bg
	Sidebar.BackgroundColor3 = th.Sidebar
	SidebarDivider.BackgroundColor3 = th.Accent
	SidebarDivider.BackgroundTransparency = 0.65

	ToggleBtn.BackgroundColor3 = th.Card
	ToggleBtn.TextColor3 = th.TextPrimary
	ToggleBtn.Font = th.TitleFont

	-- Brand Header
	BrandBadge.BackgroundColor3 = th.Accent
	BrandBadge.TextColor3 = th.Bg
	BrandBadge.Text = th.BadgeIcon
	BrandTitle.TextColor3 = th.TextPrimary
	BrandTitle.Font = th.TitleFont
	BrandSub.TextColor3 = th.Accent
	BrandSub.Font = th.BodyFont

	ThemeSectionTitle.TextColor3 = th.TextMuted
	ThemeSectionTitle.Font = th.TitleFont

	TopStatusSign.Text = th.HeaderSign
	TopStatusSign.TextColor3 = th.Accent
	TopStatusSign.Font = th.ClockFont

	-- Cards & Borders
	for _, card in ipairs(CardRegistry) do
		card.BackgroundColor3 = th.Card
	end
	for _, corner in ipairs(CornerRegistry) do
		corner.CornerRadius = th.Corner
	end
	for _, stroke in ipairs(StrokeRegistry) do
		stroke.Color = th.Accent
		stroke.Thickness = th.Stroke
		stroke.Transparency = 0.35
	end

	-- Icon Boxes & Buttons
	ClockIconBox.BackgroundColor3 = th.Accent
	ClockIconBox.TextColor3 = th.TextPrimary
	LangIconBox.BackgroundColor3 = th.Accent
	LangIconBox.TextColor3 = th.TextPrimary

	LangSwitchBtn.BackgroundColor3 = th.Bg
	LangSwitchBtn.TextColor3 = th.Accent
	LangSwitchBtn.Font = th.TitleFont

	-- Typography Hierarchy
	ClockHeaderLbl.TextColor3 = th.Accent
	ClockHeaderLbl.Font = th.TitleFont
	ClockDigitsLbl.TextColor3 = th.TextPrimary
	ClockDigitsLbl.Font = th.ClockFont
	ClockSubLbl.TextColor3 = th.TextMuted
	ClockSubLbl.Font = th.BodyFont

	LangHeaderLbl.TextColor3 = th.Accent
	LangHeaderLbl.Font = th.TitleFont
	LangValueLbl.TextColor3 = th.TextPrimary
	LangValueLbl.Font = th.TitleFont

	AboutHeaderLbl.TextColor3 = th.Accent
	AboutHeaderLbl.Font = th.TitleFont
	AboutBodyLbl.TextColor3 = th.TextMuted
	AboutBodyLbl.Font = th.BodyFont

	-- Sidebar Theme Buttons
	for i, btn in ipairs(ThemeBtnObjects) do
		btn.Font = th.BodyFont
		if i == index then
			btn.BackgroundColor3 = th.Accent
			btn.TextColor3 = th.Bg
			btn.BackgroundTransparency = 0
		else
			btn.BackgroundColor3 = th.Card
			btn.TextColor3 = th.TextPrimary
			btn.BackgroundTransparency = 0.2
		end
	end

	-- Rebuild Physical Background Layer
	rebuildBackgroundPattern(th.Pattern, th.Accent)
	refreshLanguage()
end

-- Create the 5 Sidebar Theme Buttons
for i = 1, #Themes do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.LayoutOrder = i
	btn.TextSize = 13
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.AutoButtonColor = true
	btn.ZIndex = 5
	btn.Parent = ThemeListFrame

	table.insert(CornerRegistry, Instance.new("UICorner", btn))
	local st = Instance.new("UIStroke", btn)
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	table.insert(StrokeRegistry, st)
	table.insert(ThemeBtnObjects, btn)

	btn.MouseButton1Click:Connect(function()
		applyTheme(i)
	end)
end

-- ==========================================
-- 9. EVENTS & LIVE CLOCK LOOP
-- ==========================================
ToggleBtn.MouseButton1Click:Connect(function()
	menuVisible = not menuVisible
	MainWindow.Visible = menuVisible
	refreshLanguage()
end)

LangSwitchBtn.MouseButton1Click:Connect(function()
	currentLang = (currentLang == "RU") and "EN" or "RU"
	refreshLanguage()
end)

-- Start with Theme 1
applyTheme(1)

task.spawn(function()
	while ScreenGui.Parent do
		ClockDigitsLbl.Text = getMoscowTime()
		task.wait(1)
	end
end)
