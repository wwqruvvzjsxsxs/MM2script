-- Delta Android UI Script: Custom Menu with Real-Time MSK, Localization & 5 Distinct Themes

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Safely parent the GUI for Delta / Android executors
local parentGui
local success, err = pcall(function()
	parentGui = (gethui and gethui()) or CoreGui
end)
if not success or not parentGui then
	parentGui = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Remove previous instance if re-executed
if parentGui:FindFirstChild("DeltaCustomMenuUI") then
	parentGui.DeltaCustomMenuUI:Destroy()
end

-- ==========================================
-- 1. LOCALIZATION DATA (EN / RU)
-- ==========================================
local currentLang = "RU"

local TextData = {
	EN = {
		ToggleOpen = "☰ Menu",
		ToggleClose = "✕ Close",
		Title = "DELTA UTILITY HUB",
		TimePrefix = "Moscow Time (MSK): ",
		LangLabel = "Language: English",
		LangBtn = "Switch to Русский",
		DescTitle = "About Script",
		DescBody = "Lightweight utility overlay built for Delta Android. Features real-time UTC+3 synchronization, multi-language support, and 5 dynamic structural & visual styles.",
		ThemeTitle = "Select Menu Style (5 Presets):"
	},
	RU = {
		ToggleOpen = "☰ Меню",
		ToggleClose = "✕ Закрыть",
		Title = "ПАНЕЛЬ DELTA UI",
		TimePrefix = "Время (МСК): ",
		LangLabel = "Язык: Русский",
		LangBtn = "Переключить на English",
		DescTitle = "О скрипте",
		DescBody = "Легковесное пользовательское меню для Delta Android. Включает точное московское время в реальном времени, смену языка и 5 уникальных дизайнов с разной геометрией и шрифтами.",
		ThemeTitle = "Выберите стиль оформления (5 тем):"
	}
}

-- ==========================================
-- 2. 5 DISTINCT DESIGN THEMES (Colors, Shapes, Fonts, Symbols)
-- ==========================================
local Themes = {
	[1] = {
		NameEN = "1. Cyber Neon",
		NameRU = "1. Кибер-Неон",
		BgColor = Color3.fromRGB(15, 15, 28),
		CardColor = Color3.fromRGB(24, 24, 44),
		AccentColor = Color3.fromRGB(0, 240, 255),
		TextColor = Color3.fromRGB(235, 250, 255),
		CornerRadius = UDim.new(0, 12),
		StrokeThickness = 2,
		Font = Enum.Font.SciFi,
		Symbol = "⚡",
		UseGradient = true,
		GradColor1 = Color3.fromRGB(20, 20, 45),
		GradColor2 = Color3.fromRGB(5, 5, 12)
	},
	[2] = {
		NameEN = "2. Military Tactical",
		NameRU = "2. Военный Тактический",
		BgColor = Color3.fromRGB(28, 33, 24),
		CardColor = Color3.fromRGB(40, 48, 34),
		AccentColor = Color3.fromRGB(215, 165, 40),
		TextColor = Color3.fromRGB(225, 230, 210),
		CornerRadius = UDim.new(0, 0), -- Sharp rectangular tactical edges
		StrokeThickness = 3,
		Font = Enum.Font.Code,
		Symbol = "✪ [TAC-OPS]",
		UseGradient = false,
		GradColor1 = Color3.fromRGB(28, 33, 24),
		GradColor2 = Color3.fromRGB(28, 33, 24)
	},
	[3] = {
		NameEN = "3. Imperial Gothic",
		NameRU = "3. Имперская Готика",
		BgColor = Color3.fromRGB(22, 10, 12),
		CardColor = Color3.fromRGB(38, 16, 20),
		AccentColor = Color3.fromRGB(220, 35, 55),
		TextColor = Color3.fromRGB(255, 230, 230),
		CornerRadius = UDim.new(0, 4),
		StrokeThickness = 2.5,
		Font = Enum.Font.Antique,
		Symbol = "✠ [IMPERIAL]",
		UseGradient = true,
		GradColor1 = Color3.fromRGB(45, 10, 15),
		GradColor2 = Color3.fromRGB(12, 5, 5)
	},
	[4] = {
		NameEN = "4. Soft Minimal Pill",
		NameRU = "4. Мягкий Минимализм",
		BgColor = Color3.fromRGB(238, 242, 248),
		CardColor = Color3.fromRGB(255, 255, 255),
		AccentColor = Color3.fromRGB(70, 120, 255),
		TextColor = Color3.fromRGB(30, 35, 45),
		CornerRadius = UDim.new(0, 22), -- Extra round corners
		StrokeThickness = 1,
		Font = Enum.Font.GothamMedium,
		Symbol = "✦",
		UseGradient = false,
		GradColor1 = Color3.fromRGB(238, 242, 248),
		GradColor2 = Color3.fromRGB(238, 242, 248)
	},
	[5] = {
		NameEN = "5. Retro Terminal",
		NameRU = "5. Ретро Терминал",
		BgColor = Color3.fromRGB(8, 12, 8),
		CardColor = Color3.fromRGB(14, 24, 14),
		AccentColor = Color3.fromRGB(30, 255, 70),
		TextColor = Color3.fromRGB(30, 255, 70),
		CornerRadius = UDim.new(0, 2),
		StrokeThickness = 1.5,
		Font = Enum.Font.Arcade,
		Symbol = "☢ [SYS://]",
		UseGradient = false,
		GradColor1 = Color3.fromRGB(8, 12, 8),
		GradColor2 = Color3.fromRGB(8, 12, 8)
	}
}

local currentThemeIndex = 1
local isMenuOpen = true

-- ==========================================
-- 3. DRAGGABLE HELPER (Supports Mobile Touch & Mouse)
-- ==========================================
local function makeDraggable(frame, dragHandle)
	local dragging = false
	local dragInput, dragStart, startPos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- ==========================================
-- 4. UI CONSTRUCTION
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaCustomMenuUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parentGui

-- Lists to store elements for dynamic theme updates
local CornerElements = {}
local StrokeElements = {}
local CardElements = {}
local TextElements = {}
local ThemeButtons = {}

-- 4A. Floating Open/Close Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 115, 0, 40)
ToggleButton.Position = UDim2.new(0.05, 0, 0.12, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 15
ToggleButton.AutoButtonColor = true
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner", ToggleButton)
local ToggleStroke = Instance.new("UIStroke", ToggleButton)
ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
table.insert(CornerElements, ToggleCorner)
table.insert(StrokeElements, ToggleStroke)
table.insert(TextElements, ToggleButton)

makeDraggable(ToggleButton, ToggleButton)

-- 4B. Main Menu Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 310)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 28)
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local MainGradient = Instance.new("UIGradient", MainFrame)
MainGradient.Rotation = 45

table.insert(CornerElements, MainCorner)
table.insert(StrokeElements, MainStroke)

-- Top Header Bar (Draggable area)
local HeaderBar = Instance.new("Frame")
HeaderBar.Size = UDim2.new(1, -24, 0, 38)
HeaderBar.Position = UDim2.new(0, 12, 0, 10)
HeaderBar.BackgroundColor3 = Color3.fromRGB(24, 24, 44)
HeaderBar.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner", HeaderBar)
local HeaderStroke = Instance.new("UIStroke", HeaderBar)
table.insert(CornerElements, HeaderCorner)
table.insert(StrokeElements, HeaderStroke)
table.insert(CardElements, HeaderBar)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = HeaderBar
table.insert(TextElements, TitleLabel)

makeDraggable(MainFrame, HeaderBar)

-- Real-Time Moscow Clock + Language Row
local TopRow = Instance.new("Frame")
TopRow.Size = UDim2.new(1, -24, 0, 42)
TopRow.Position = UDim2.new(0, 12, 0, 56)
TopRow.BackgroundColor3 = Color3.fromRGB(24, 24, 44)
TopRow.Parent = MainFrame

local TopRowCorner = Instance.new("UICorner", TopRow)
local TopRowStroke = Instance.new("UIStroke", TopRow)
table.insert(CornerElements, TopRowCorner)
table.insert(StrokeElements, TopRowStroke)
table.insert(CardElements, TopRow)

local TimeLabel = Instance.new("TextLabel")
TimeLabel.Size = UDim2.new(0.58, -10, 1, 0)
TimeLabel.Position = UDim2.new(0, 10, 0, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.TextSize = 13
TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
TimeLabel.Parent = TopRow
table.insert(TextElements, TimeLabel)

local LangButton = Instance.new("TextButton")
LangButton.Size = UDim2.new(0.42, -10, 0, 28)
LangButton.Position = UDim2.new(0.58, 0, 0.5, -14)
LangButton.TextSize = 12
LangButton.Parent = TopRow

local LangBtnCorner = Instance.new("UICorner", LangButton)
local LangBtnStroke = Instance.new("UIStroke", LangButton)
LangBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
table.insert(CornerElements, LangBtnCorner)
table.insert(StrokeElements, LangBtnStroke)
table.insert(TextElements, LangButton)

-- Description Box
local DescFrame = Instance.new("Frame")
DescFrame.Size = UDim2.new(1, -24, 0, 82)
DescFrame.Position = UDim2.new(0, 12, 0, 106)
DescFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 44)
DescFrame.Parent = MainFrame

local DescCorner = Instance.new("UICorner", DescFrame)
local DescStroke = Instance.new("UIStroke", DescFrame)
table.insert(CornerElements, DescCorner)
table.insert(StrokeElements, DescStroke)
table.insert(CardElements, DescFrame)

local DescTitleLabel = Instance.new("TextLabel")
DescTitleLabel.Size = UDim2.new(1, -20, 0, 22)
DescTitleLabel.Position = UDim2.new(0, 10, 0, 4)
DescTitleLabel.BackgroundTransparency = 1
DescTitleLabel.TextSize = 14
DescTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
DescTitleLabel.Parent = DescFrame
table.insert(TextElements, DescTitleLabel)

local DescBodyLabel = Instance.new("TextLabel")
DescBodyLabel.Size = UDim2.new(1, -20, 0, 52)
DescBodyLabel.Position = UDim2.new(0, 10, 0, 26)
DescBodyLabel.BackgroundTransparency = 1
DescBodyLabel.TextSize = 12
DescBodyLabel.TextWrapped = true
DescBodyLabel.TextXAlignment = Enum.TextXAlignment.Left
DescBodyLabel.TextYAlignment = Enum.TextYAlignment.Top
DescBodyLabel.Parent = DescFrame
table.insert(TextElements, DescBodyLabel)

-- Theme Selector Section
local ThemeHeaderLabel = Instance.new("TextLabel")
ThemeHeaderLabel.Size = UDim2.new(1, -24, 0, 20)
ThemeHeaderLabel.Position = UDim2.new(0, 14, 0, 194)
ThemeHeaderLabel.BackgroundTransparency = 1
ThemeHeaderLabel.TextSize = 13
ThemeHeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
ThemeHeaderLabel.Parent = MainFrame
table.insert(TextElements, ThemeHeaderLabel)

local ThemeContainer = Instance.new("Frame")
ThemeContainer.Size = UDim2.new(1, -24, 0, 80)
ThemeContainer.Position = UDim2.new(0, 12, 0, 218)
ThemeContainer.BackgroundTransparency = 1
ThemeContainer.Parent = MainFrame

local GridLayout = Instance.new("UIGridLayout", ThemeContainer)
GridLayout.CellSize = UDim2.new(0.32, -4, 0, 34)
GridLayout.CellPadding = UDim2.new(0, 6, 0, 8)
GridLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ==========================================
-- 5. FUNCTIONS: THEME & LANGUAGE APPLICATION
-- ==========================================
local function getMoscowTimeString()
	-- UTC timestamp + 3 hours (10800 seconds) for Moscow Time (MSK)
	local mskTimestamp = os.time() + 10800
	local timeTable = os.date("!*t", mskTimestamp)
	return string.format("%02d:%02d:%02d", timeTable.hour, timeTable.min, timeTable.sec)
end

local function updateTexts()
	local lang = TextData[currentLang]
	local theme = Themes[currentThemeIndex]

	ToggleButton.Text = isMenuOpen and lang.ToggleClose or lang.ToggleOpen
	TitleLabel.Text = string.format("%s  %s  %s", theme.Symbol, lang.Title, theme.Symbol)
	TimeLabel.Text = lang.TimePrefix .. getMoscowTimeString()
	LangButton.Text = lang.LangBtn
	DescTitleLabel.Text = theme.Symbol .. " " .. lang.DescTitle .. " (" .. lang.LangLabel .. ")"
	DescBodyLabel.Text = lang.DescBody
	ThemeHeaderLabel.Text = lang.ThemeTitle

	for idx, btn in ipairs(ThemeButtons) do
		btn.Text = (currentLang == "RU") and Themes[idx].NameRU or Themes[idx].NameEN
	end
end

local function applyTheme(index)
	currentThemeIndex = index
	local theme = Themes[index]

	MainFrame.BackgroundColor3 = theme.BgColor
	ToggleButton.BackgroundColor3 = theme.CardColor
	LangButton.BackgroundColor3 = theme.BgColor

	MainGradient.Enabled = theme.UseGradient
	if theme.UseGradient then
		MainGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, theme.GradColor1),
			ColorSequenceKeypoint.new(1, theme.GradColor2)
		})
	end

	for _, card in ipairs(CardElements) do
		card.BackgroundColor3 = theme.CardColor
	end

	for _, corner in ipairs(CornerElements) do
		corner.CornerRadius = theme.CornerRadius
	end

	for _, stroke in ipairs(StrokeElements) do
		stroke.Color = theme.AccentColor
		stroke.Thickness = theme.StrokeThickness
	end

	for _, txt in ipairs(TextElements) do
		txt.TextColor3 = theme.TextColor
		txt.Font = theme.Font
	end

	-- Highlight active theme button
	for idx, btn in ipairs(ThemeButtons) do
		if idx == index then
			btn.BackgroundColor3 = theme.AccentColor
			btn.TextColor3 = theme.BgColor
		else
			btn.BackgroundColor3 = theme.CardColor
			btn.TextColor3 = theme.TextColor
		end
	end

	updateTexts()
end

-- Create the 5 Theme Buttons
for i = 1, #Themes do
	local tBtn = Instance.new("TextButton")
	tBtn.LayoutOrder = i
	tBtn.TextSize = 11
	tBtn.TextWrapped = true
	tBtn.Parent = ThemeContainer

	local c = Instance.new("UICorner", tBtn)
	local s = Instance.new("UIStroke", tBtn)
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	table.insert(CornerElements, c)
	table.insert(StrokeElements, s)
	table.insert(TextElements, tBtn)
	table.insert(ThemeButtons, tBtn)

	tBtn.MouseButton1Click:Connect(function()
		applyTheme(i)
	end)
end

-- ==========================================
-- 6. INTERACTIVITY & REAL-TIME LOOP
-- ==========================================
ToggleButton.MouseButton1Click:Connect(function()
	isMenuOpen = not isMenuOpen
	MainFrame.Visible = isMenuOpen
	updateTexts()
end)

LangButton.MouseButton1Click:Connect(function()
	currentLang = (currentLang == "RU") and "EN" or "RU"
	updateTexts()
end)

-- Initialize default theme & language
applyTheme(1)

-- Update Moscow Time every second cleanly in the background
task.spawn(function()
	while ScreenGui.Parent do
		local lang = TextData[currentLang]
		TimeLabel.Text = lang.TimePrefix .. getMoscowTimeString()
		task.wait(1)
	end
end)
