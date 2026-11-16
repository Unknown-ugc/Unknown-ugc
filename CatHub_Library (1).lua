-- CAT HUB LIBRARY  |  loadstring-able UI library (blue intro included)
-- Upload this file to GitHub, then loadstring its raw link.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local COL_BG       = Color3.fromRGB(31, 20, 16)
local COL_PANEL    = Color3.fromRGB(42, 27, 20)
local COL_CARD     = Color3.fromRGB(53, 35, 26)
local COL_DIVIDER  = Color3.fromRGB(90, 58, 40)
local COL_ACCENT   = Color3.fromRGB(255, 140, 42)
local COL_GLOW     = Color3.fromRGB(255, 176, 102)
local COL_TEXT     = Color3.fromRGB(255, 242, 230)
local COL_SUBTEXT  = Color3.fromRGB(201, 165, 138)
local COL_MUTED    = Color3.fromRGB(130, 100, 82)
local COL_STAR     = Color3.fromRGB(255, 200, 60)
local COL_GREEN    = Color3.fromRGB(80, 220, 130)
local COL_RED      = Color3.fromRGB(230, 80, 100)

local UI = {}

-- cat face drawn with GUI shapes (recolors with the theme)
UI.catFaceHolders = {}
UI.logoCircles = {}
function UI.makeCatFace(parent, size)
    local holder = Instance.new("Frame")
    holder.Name = "CatFace"
    holder.AnchorPoint = Vector2.new(0.5, 0.5)
    holder.Position = UDim2.fromScale(0.5, 0.48)
    holder.Size = UDim2.fromScale(size, size)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local FUR    = Color3.fromRGB(255, 157, 61)
    local STRIPE = Color3.fromRGB(217, 106, 16)
    local LINE   = Color3.fromRGB(168, 72, 10)
    local EARIN  = Color3.fromRGB(255, 191, 163)
    local EYE    = Color3.fromRGB(90, 209, 138)
    local DARK   = Color3.fromRGB(21, 21, 21)
    local WHITE  = Color3.fromRGB(255, 255, 255)

    local function part(name, color, cx, cy, w, h, z, round, rot)
        local f = Instance.new("Frame")
        f.Name = name
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.Position = UDim2.fromScale(cx, cy)
        f.Size = UDim2.fromScale(w, h)
        f.BackgroundColor3 = color
        f.BorderSizePixel = 0
        f.ZIndex = z
        if rot then f.Rotation = rot end
        if round then Instance.new("UICorner", f).CornerRadius = UDim.new(round, 0) end
        f.Parent = holder
        return f
    end

    -- filled triangle made of thin horizontal strips
    local function tri(name, color, pts, z)
        local ymin, ymax = math.huge, -math.huge
        for _, p in ipairs(pts) do
            if p[2] < ymin then ymin = p[2] end
            if p[2] > ymax then ymax = p[2] end
        end
        local N = 12
        local dy = (ymax - ymin) / N
        for k = 0, N - 1 do
            local y = ymin + (k + 0.5) * dy
            local xl, xr = math.huge, -math.huge
            for i = 1, 3 do
                local a, b = pts[i], pts[i % 3 + 1]
                if a[2] ~= b[2] and y >= math.min(a[2], b[2]) and y <= math.max(a[2], b[2]) then
                    local t = (y - a[2]) / (b[2] - a[2])
                    local x = a[1] + (b[1] - a[1]) * t
                    if x < xl then xl = x end
                    if x > xr then xr = x end
                end
            end
            if xr > xl then
                part(name, color, (xl + xr) / 2, y, xr - xl, dy * 1.25, z)
            end
        end
    end

    local function grow(pts, f)
        local cx = (pts[1][1] + pts[2][1] + pts[3][1]) / 3
        local cy = (pts[1][2] + pts[2][2] + pts[3][2]) / 3
        local out = {}
        for i, p in ipairs(pts) do
            out[i] = { cx + (p[1] - cx) * f, cy + (p[2] - cy) * f }
        end
        return out
    end

    -- ears (even, mirrored) with outline
    local earL = { {0.15, 0.46}, {0.20, 0.13}, {0.45, 0.27} }
    local earR = { {0.85, 0.46}, {0.80, 0.13}, {0.55, 0.27} }
    tri("Line", LINE, grow(earL, 1.13), 1)
    tri("Line", LINE, grow(earR, 1.13), 1)
    tri("Fur", FUR, earL, 2)
    tri("Fur", FUR, earR, 2)

    -- head with outline
    local head = part("Fur", FUR, 0.5, 0.58, 0.8, 0.68, 3, 0.5)
    local hs = Instance.new("UIStroke", head)
    hs.Name = "LineStroke"
    hs.Color = LINE
    hs.Thickness = 1.2

    -- inner ears
    tri("EarIn", EARIN, { {0.22, 0.36}, {0.235, 0.20}, {0.36, 0.28} }, 4)
    tri("EarIn", EARIN, { {0.78, 0.36}, {0.765, 0.20}, {0.64, 0.28} }, 4)

    -- forehead stripes
    part("Stripe", STRIPE, 0.5, 0.315, 0.034, 0.11, 4, 1)
    part("Stripe", STRIPE, 0.41, 0.325, 0.034, 0.095, 4, 1, -16)
    part("Stripe", STRIPE, 0.59, 0.325, 0.034, 0.095, 4, 1, 16)

    -- cheeks
    local b1 = part("Blush", EARIN, 0.21, 0.69, 0.11, 0.11, 4, 1)
    local b2 = part("Blush", EARIN, 0.79, 0.69, 0.11, 0.11, 4, 1)
    b1.BackgroundTransparency = 0.45
    b2.BackgroundTransparency = 0.45

    -- eyes
    part("Eye", EYE, 0.33, 0.57, 0.17, 0.17, 5, 1)
    part("Eye", EYE, 0.67, 0.57, 0.17, 0.17, 5, 1)
    part("Pupil", DARK, 0.33, 0.57, 0.064, 0.14, 6, 1)
    part("Pupil", DARK, 0.67, 0.57, 0.064, 0.14, 6, 1)
    part("Shine", WHITE, 0.356, 0.53, 0.048, 0.048, 7, 1)
    part("Shine", WHITE, 0.696, 0.53, 0.048, 0.048, 7, 1)
    part("Shine", WHITE, 0.312, 0.606, 0.022, 0.022, 7, 1)
    part("Shine", WHITE, 0.652, 0.606, 0.022, 0.022, 7, 1)

    -- nose + 3-shaped (w) mouth
    part("EarIn", EARIN, 0.5, 0.672, 0.056, 0.056, 6, 0.15, 45)
    part("Mouth", DARK, 0.5, 0.715, 0.019, 0.026, 6, 1)
    for _, cx in ipairs({0.4575, 0.5425}) do
        local clip = Instance.new("Frame")
        clip.Name = "MouthClip"
        clip.AnchorPoint = Vector2.new(0.5, 0)
        clip.Position = UDim2.fromScale(cx, 0.72)
        clip.Size = UDim2.fromScale(0.13, 0.06)
        clip.BackgroundTransparency = 1
        clip.ClipsDescendants = true
        clip.ZIndex = 6
        clip.Parent = holder

        local arc = Instance.new("Frame")
        arc.Name = "MouthArc"
        arc.AnchorPoint = Vector2.new(0.5, 0.5)
        arc.Position = UDim2.fromScale(0.5, 0)
        arc.Size = UDim2.fromScale(0.654, 1.417)
        arc.BackgroundTransparency = 1
        arc.BorderSizePixel = 0
        arc.ZIndex = 6
        arc.Parent = clip
        Instance.new("UICorner", arc).CornerRadius = UDim.new(1, 0)
        local st = Instance.new("UIStroke", arc)
        st.Name = "MouthStroke"
        st.Color = DARK
        st.Thickness = 1.2
    end

    -- whiskers
    local WH = Color3.fromRGB(244, 244, 244)
    part("Whisker", WH, 0.11, 0.635, 0.14, 0.022, 7, 1, 14)
    part("Whisker", WH, 0.105, 0.705, 0.14, 0.022, 7, 1, -4)
    part("Whisker", WH, 0.89, 0.635, 0.14, 0.022, 7, 1, -14)
    part("Whisker", WH, 0.895, 0.705, 0.14, 0.022, 7, 1, 4)

    table.insert(UI.catFaceHolders, holder)
    table.insert(UI.logoCircles, parent)
    return holder
end

function UI.edge(o, t)
    local st = Instance.new("UIStroke")
    st.Color = COL_DIVIDER
    st.Thickness = 1
    st.Transparency = t or 0.35
    st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    st.Parent = o
    return st
end

function UI.paintNav(b, on)
    b:SetAttribute("on", on)
    b.BackgroundColor3 = on and COL_ACCENT or COL_CARD
    b.BackgroundTransparency = on and 0 or 1
    b.TextColor3 = on and Color3.fromRGB(255, 255, 255) or COL_SUBTEXT
    local g = b:FindFirstChild("Shade")
    if g then g.Enabled = on end
end

local Library = {}

function Library:CreateWindow(opts)
opts = opts or {}
local old = playerGui:FindFirstChild("CatHubGUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "CatHubGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(640, 440)
main.Position = UDim2.new(0.5, -320, 0.5, -220)
main.BackgroundColor3 = COL_BG
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local uiScale = Instance.new("UIScale", main)
local vp = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1280, 720)
local scaleVal = math.min(1, (vp.X - 20) / 640, (vp.Y - 20) / 440)
if (not scaleVal) or (scaleVal ~= scaleVal) or scaleVal < 0.4 then
    scaleVal = 1
end
uiScale.Scale = scaleVal

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = COL_DIVIDER
mainStroke.Thickness = 1
mainStroke.Transparency = 0

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 55)
header.BackgroundColor3 = COL_PANEL
header.BorderSizePixel = 0
header.Parent = main
header.ZIndex = 3

Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local catCircle = Instance.new("Frame")
catCircle.Size = UDim2.fromOffset(38, 38)
catCircle.Position = UDim2.fromOffset(10, 8)
catCircle.BackgroundColor3 = COL_CARD
catCircle.BorderSizePixel = 0
catCircle.Parent = header

Instance.new("UICorner", catCircle).CornerRadius = UDim.new(1, 0)

local catStroke = Instance.new("UIStroke", catCircle)
catStroke.Color = COL_GLOW
catStroke.Thickness = 1.5

UI.makeCatFace(catCircle, 0.8)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(62, 6)
title.Size = UDim2.new(0.5, 0, 0, 20)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = COL_TEXT
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = opts.Title or "CAT HUB"
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(62, 28)
subtitle.Size = UDim2.new(0.5, 0, 0, 14)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 9
subtitle.TextColor3 = COL_SUBTEXT
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Text = opts.Subtitle or "universal  |  v3"
subtitle.Parent = header

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.fromOffset(26, 26)
minimizeBtn.Position = UDim2.new(1, -68, 0, 15)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.TextColor3 = COL_TEXT
minimizeBtn.AutoButtonColor = false
minimizeBtn.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(26, 26)
closeBtn.Position = UDim2.new(1, -34, 0, 15)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = COL_TEXT
closeBtn.AutoButtonColor = false
closeBtn.Parent = header

do
    local headLine = Instance.new("Frame")
    headLine.Size = UDim2.new(1, 0, 0, 1)
    headLine.Position = UDim2.fromOffset(0, 55)
    headLine.BackgroundColor3 = COL_DIVIDER
    headLine.BorderSizePixel = 0
    headLine.ZIndex = 4
    headLine.Parent = main

    local headAccent = Instance.new("Frame")
    headAccent.Size = UDim2.fromOffset(48, 2)
    headAccent.Position = UDim2.fromOffset(0, 54)
    headAccent.BackgroundColor3 = COL_ACCENT
    headAccent.BorderSizePixel = 0
    headAccent.ZIndex = 5
    headAccent.Parent = main
end

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 130, 1, -71)
sidebar.Position = UDim2.fromOffset(8, 63)
sidebar.BackgroundColor3 = COL_PANEL
sidebar.BorderSizePixel = 0
sidebar.Parent = main
sidebar.ZIndex = 5

Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)
UI.edge(sidebar, 0.4)

local sidebarList = Instance.new("Frame")
sidebarList.Size = UDim2.new(1, 0, 1, 0)
sidebarList.BackgroundTransparency = 1
sidebarList.Parent = sidebar

local sidebarLayout = Instance.new("UIListLayout", sidebarList)
sidebarLayout.Padding = UDim.new(0, 5)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

Instance.new("UIPadding", sidebarList).PaddingTop = UDim.new(0, 8)

local function makeNavButton(text, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 34)
    btn.BackgroundColor3 = COL_CARD
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextColor3 = COL_SUBTEXT
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.Parent = sidebarList

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIPadding", btn).PaddingLeft = UDim.new(0, 16)

    local g = Instance.new("UIGradient")
    g.Name = "Shade"
    g.Rotation = 90
    g.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(205, 205, 205))
    g.Enabled = false
    g.Parent = btn

    btn:SetAttribute("on", false)
    return btn
end

local settingsBtn = makeNavButton("settings", 1000)

UI.paintNav(settingsBtn, true)

local miniCircle = Instance.new("ImageButton")
miniCircle.Name = "MinimizeCircle"
miniCircle.Size = UDim2.fromOffset(60, 60)
miniCircle.Position = UDim2.new(0.5, -30, 0, 100)
miniCircle.BackgroundColor3 = COL_CARD
miniCircle.Visible = false
miniCircle.Active = true
miniCircle.Parent = gui

Instance.new("UICorner", miniCircle).CornerRadius = UDim.new(1, 0)

local miniStroke = Instance.new("UIStroke", miniCircle)
miniStroke.Color = COL_GLOW
miniStroke.Thickness = 2

UI.makeCatFace(miniCircle, 0.8)

local isMinimized = false

local function minimizeGUI()
    isMinimized = true
    main.Visible = false
    miniCircle.Visible = true
end

local function restoreGUI()
    isMinimized = false
    main.Visible = true
    miniCircle.Visible = false
end

minimizeBtn.MouseButton1Click:Connect(function()
    if not isMinimized then minimizeGUI() end
end)

miniCircle.MouseButton1Click:Connect(function()
    if isMinimized then restoreGUI() end
end)

local miniDragging = false
local miniDragStart, miniStartPos

miniCircle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = true
        miniDragStart = input.Position
        miniStartPos = miniCircle.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if miniDragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - miniDragStart
        miniCircle.Position = UDim2.new(
            miniStartPos.X.Scale, miniStartPos.X.Offset + delta.X,
            miniStartPos.Y.Scale, miniStartPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = false
    end
end)

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -162, 1, -79)
content.Position = UDim2.fromOffset(154, 67)
content.BackgroundTransparency = 1
content.Parent = main
content.ZIndex = 1

local contentPad = Instance.new("UIPadding", content)
contentPad.PaddingTop = UDim.new(0, 4)
contentPad.PaddingBottom = UDim.new(0, 4)
contentPad.PaddingLeft = UDim.new(0, 8)
contentPad.PaddingRight = UDim.new(0, 8)

-- ===== pages (GUI only) =====
local function newPage(name, titleText)
    local p = Instance.new("Frame")
    p.Name = name
    p.Size = UDim2.fromScale(1, 1)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.ZIndex = 2
    p.Parent = content
    return p
end

local settingsPage = newPage("SettingsPage")

local stTitle = Instance.new("TextLabel")
stTitle.BackgroundTransparency = 1
stTitle.Position = UDim2.fromOffset(0, 0)
stTitle.Size = UDim2.new(1, 0, 0, 22)
stTitle.Font = Enum.Font.GothamBold
stTitle.TextSize = 14
stTitle.TextColor3 = COL_TEXT
stTitle.TextXAlignment = Enum.TextXAlignment.Left
stTitle.Text = "Settings"
stTitle.Parent = settingsPage

local colorTitle = Instance.new("TextLabel")
colorTitle.BackgroundTransparency = 1
colorTitle.Position = UDim2.fromOffset(0, 36)
colorTitle.Size = UDim2.new(1, 0, 0, 14)
colorTitle.Font = Enum.Font.GothamBold
colorTitle.TextSize = 9
colorTitle.TextColor3 = COL_MUTED
colorTitle.TextXAlignment = Enum.TextXAlignment.Left
colorTitle.Text = "COLOR CHANGE"
colorTitle.Parent = settingsPage

local colorBtn = Instance.new("TextButton")
colorBtn.Size = UDim2.new(1, -6, 0, 30)
colorBtn.Position = UDim2.fromOffset(0, 46)
colorBtn.BackgroundColor3 = COL_PANEL
colorBtn.Text = "Color Change"
colorBtn.Font = Enum.Font.GothamBold
colorBtn.TextSize = 10
colorBtn.TextColor3 = COL_TEXT
colorBtn.TextXAlignment = Enum.TextXAlignment.Left
colorBtn.AutoButtonColor = false
colorBtn.BorderSizePixel = 0
colorBtn.Parent = settingsPage

Instance.new("UICorner", colorBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIPadding", colorBtn).PaddingLeft = UDim.new(0, 14)

local colorPanel = Instance.new("Frame")
colorPanel.Size = UDim2.new(1, -6, 0, 130)
colorPanel.Position = UDim2.fromOffset(0, 94)
colorPanel.BackgroundColor3 = COL_PANEL
colorPanel.BorderSizePixel = 0
colorPanel.Visible = false
colorPanel.Parent = settingsPage

Instance.new("UICorner", colorPanel).CornerRadius = UDim.new(0, 8)

local colorPad = Instance.new("UIPadding", colorPanel)
colorPad.PaddingTop = UDim.new(0, 8)
colorPad.PaddingBottom = UDim.new(0, 8)
colorPad.PaddingLeft = UDim.new(0, 8)
colorPad.PaddingRight = UDim.new(0, 8)

local colorGrid = Instance.new("UIGridLayout", colorPanel)
colorGrid.CellSize = UDim2.fromOffset(80, 30)
colorGrid.CellPadding = UDim2.fromOffset(6, 6)

local COLOR_COMBOS = {
    { name = "Orange", bg = Color3.fromRGB(31, 20, 16), panel = Color3.fromRGB(42, 27, 20), card = Color3.fromRGB(53, 35, 26), divider = Color3.fromRGB(90, 58, 40),
      accent = Color3.fromRGB(255, 140, 42), glow = Color3.fromRGB(255, 176, 102), text = Color3.fromRGB(255, 242, 230), subtext = Color3.fromRGB(201, 165, 138), muted = Color3.fromRGB(130, 100, 82),
      stripe = Color3.fromRGB(217, 106, 16), eye = Color3.fromRGB(90, 209, 138),
      logo = Color3.fromRGB(53, 35, 26),
      fur = Color3.fromRGB(255, 157, 61), earin = Color3.fromRGB(255, 191, 163), line = Color3.fromRGB(168, 72, 10), lbl = Color3.fromRGB(40, 22, 8) },
    { name = "White", bg = Color3.fromRGB(20, 22, 28), panel = Color3.fromRGB(28, 31, 39), card = Color3.fromRGB(38, 42, 53), divider = Color3.fromRGB(68, 75, 92),
      accent = Color3.fromRGB(140, 150, 180), glow = Color3.fromRGB(235, 238, 248), text = Color3.fromRGB(255, 255, 255), subtext = Color3.fromRGB(169, 174, 187), muted = Color3.fromRGB(105, 110, 125),
      stripe = Color3.fromRGB(195, 199, 211), eye = Color3.fromRGB(90, 168, 255),
      logo = Color3.fromRGB(38, 42, 53),
      fur = Color3.fromRGB(243, 243, 246), earin = Color3.fromRGB(255, 194, 207), line = Color3.fromRGB(154, 160, 178), lbl = Color3.fromRGB(40, 44, 60) },
    { name = "Black", bg = Color3.fromRGB(10, 10, 10), panel = Color3.fromRGB(20, 20, 20), card = Color3.fromRGB(30, 30, 30), divider = Color3.fromRGB(58, 58, 58),
      accent = Color3.fromRGB(205, 140, 25), glow = Color3.fromRGB(255, 226, 120), text = Color3.fromRGB(242, 242, 242), subtext = Color3.fromRGB(154, 154, 154), muted = Color3.fromRGB(100, 100, 100),
      stripe = Color3.fromRGB(90, 90, 90), eye = Color3.fromRGB(255, 210, 63),
      logo = Color3.fromRGB(205, 140, 25),
      fur = Color3.fromRGB(58, 58, 58), earin = Color3.fromRGB(138, 92, 104), line = Color3.fromRGB(17, 17, 17), lbl = Color3.fromRGB(255, 255, 255) },
    { name = "Gray", bg = Color3.fromRGB(20, 24, 28), panel = Color3.fromRGB(27, 33, 39), card = Color3.fromRGB(37, 44, 52), divider = Color3.fromRGB(63, 74, 86),
      accent = Color3.fromRGB(110, 124, 139), glow = Color3.fromRGB(184, 194, 204), text = Color3.fromRGB(238, 242, 246), subtext = Color3.fromRGB(154, 166, 179), muted = Color3.fromRGB(100, 110, 122),
      stripe = Color3.fromRGB(118, 130, 143), eye = Color3.fromRGB(125, 220, 143),
      logo = Color3.fromRGB(37, 44, 52),
      fur = Color3.fromRGB(163, 173, 185), earin = Color3.fromRGB(232, 188, 203), line = Color3.fromRGB(91, 102, 114), lbl = Color3.fromRGB(20, 26, 32) },
}

function UI.paintEars(combo)
    for _, c in ipairs(UI.logoCircles) do
        c.BackgroundColor3 = combo.logo
    end
    for _, h in ipairs(UI.catFaceHolders) do
        for _, d in ipairs(h:GetDescendants()) do
            if d:IsA("UIStroke") then
                if d.Name == "LineStroke" then d.Color = combo.line end
            elseif d:IsA("Frame") then
                if d.Name == "Fur" then d.BackgroundColor3 = combo.fur
                elseif d.Name == "Line" then d.BackgroundColor3 = combo.line
                elseif d.Name == "Stripe" then d.BackgroundColor3 = combo.stripe
                elseif d.Name == "Eye" then d.BackgroundColor3 = combo.eye
                elseif d.Name == "EarIn" or d.Name == "Blush" then d.BackgroundColor3 = combo.earin end
            end
        end
    end
    for _, e in ipairs(main:GetChildren()) do
        if e.Name == "CatEar" then
            e.BackgroundColor3 = combo.fur
            local i = e:FindFirstChild("Inner")
            if i then i.BackgroundColor3 = combo.earin end
        end
    end
end

local function swapCol(c, list)
    for _, p in ipairs(list) do
        if c == p[1] then return p[2] end
    end
    return nil
end

local function applyTheme(combo)
    local bgList = {
        {COL_BG, combo.bg}, {COL_PANEL, combo.panel}, {COL_CARD, combo.card},
        {COL_DIVIDER, combo.divider}, {COL_ACCENT, combo.accent}, {COL_GLOW, combo.glow},
    }
    local txList = {
        {COL_TEXT, combo.text}, {COL_SUBTEXT, combo.subtext}, {COL_MUTED, combo.muted},
        {COL_GLOW, combo.glow}, {COL_ACCENT, combo.accent}, {COL_DIVIDER, combo.divider},
    }

    for _, v in ipairs(gui:GetDescendants()) do
        if v:IsA("GuiObject") then
            local n = swapCol(v.BackgroundColor3, bgList)
            if n then v.BackgroundColor3 = n end

            if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                n = swapCol(v.TextColor3, txList)
                if n then v.TextColor3 = n end
            end
            if v:IsA("TextBox") then
                n = swapCol(v.PlaceholderColor3, txList)
                if n then v.PlaceholderColor3 = n end
            end
            if v:IsA("ScrollingFrame") then
                n = swapCol(v.ScrollBarImageColor3, bgList)
                if n then v.ScrollBarImageColor3 = n end
            end
        elseif v:IsA("UIStroke") then
            local n = swapCol(v.Color, bgList)
            if n then v.Color = n end
        end
    end

    COL_BG      = combo.bg
    COL_PANEL   = combo.panel
    COL_CARD    = combo.card
    COL_DIVIDER = combo.divider
    COL_ACCENT  = combo.accent
    COL_GLOW    = combo.glow
    COL_TEXT    = combo.text
    COL_SUBTEXT = combo.subtext
    COL_MUTED   = combo.muted
end

for _, combo in ipairs(COLOR_COMBOS) do
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = combo.fur
    btn.Text = combo.name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.TextColor3 = combo.lbl
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Parent = colorPanel

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        applyTheme(combo)
        UI.paintEars(combo)
        if writefile then
            pcall(writefile, "cathub_theme_" .. localPlayer.UserId .. ".txt", combo.name)
        end
        pcall(function()
            local env = getgenv()
            env.CatHubTheme = env.CatHubTheme or {}
            env.CatHubTheme[localPlayer.UserId] = combo.name
        end)
        colorPanel.Visible = false
    end)
end

colorBtn.MouseButton1Click:Connect(function()
    colorPanel.Visible = not colorPanel.Visible
end)

function UI.polish()
    local WHITE = Color3.fromRGB(255, 255, 255)
    for _, v in ipairs(gui:GetDescendants()) do
        if v:IsA("TextButton") and v.BackgroundTransparency < 1
            and v.BackgroundColor3 == COL_ACCENT and not v:FindFirstChildOfClass("UIGradient") then
            local g = Instance.new("UIGradient")
            g.Rotation = 90
            g.Color = ColorSequence.new(WHITE, Color3.fromRGB(205, 205, 205))
            g.Parent = v
        end
    end
    for _, f in ipairs({ main, sidebar }) do
        if not f:FindFirstChildOfClass("UIGradient") then
            local g = Instance.new("UIGradient")
            g.Rotation = 90
            g.Color = ColorSequence.new(WHITE, Color3.fromRGB(225, 225, 225))
            g.Parent = f
        end
    end
end



-- ===== BLUE INTRO =====
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

UI.introPlaying = false
UI.Intro = {
    Enabled = true,
    Duration = 2.6,
    BallColorA = Color3.fromRGB(40, 130, 255), -- blue
    ShardCount = 55,
    ShakeStrength = 9,
    Title = opts.Title or "CAT HUB",
    Subtitle = opts.IntroSubtitle or "LIBRARY",
}

local function create(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "NoTheme" then inst[k] = v end
    end
    if parent then inst.Parent = parent end
    return inst
end

local function safeGuiTween(instance, info, props)
    if not instance or not instance.Parent then return nil end
    local ok, result = pcall(function()
        local tw = TweenService:Create(instance, info, props)
        tw:Play()
        return tw
    end)
    return ok and result or nil
end

function UI.playIntro(cfg)
	local config = {}
	for key, value in pairs(UI.Intro) do
		config[key] = value
	end
	for key, value in pairs(cfg or {}) do
		config[key] = value
	end
	if config.Enabled == false then
		return
	end

	if UI.introPlaying then
		return
	end
	UI.introPlaying = true

	local old = gui:FindFirstChild("__CatHubIntro")
	if old then
		old:Destroy()
	end

	local D = math.max(1.5, tonumber(config.Duration) or 2.0)
	local rng = Random.new()
	local PUR = config.BallColorA
	local YEL = Color3.fromRGB(120, 205, 255)
	local BG = Color3.new(0, 0, 0)
	local BLACK = Color3.new(0, 0, 0)
	local DPUR = PUR:Lerp(BLACK, 0.62)
	local LPUR = PUR:Lerp(Color3.new(1, 1, 1), 0.45)
	local DYEL = YEL:Lerp(BLACK, 0.5)
	local INK = Color3.fromRGB(240, 230, 255)

	local scr = gui.AbsoluteSize
	if scr.X < 100 or scr.Y < 100 then
		scr = Vector2.new(1280, 720)
	end
	local diag = math.sqrt(scr.X * scr.X + scr.Y * scr.Y)

	local function ti(t, style, dir)
		return TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	end
	local function box(parent, color, z, pos, size, transp)
		return create("Frame", {
			BackgroundColor3 = color,
			BackgroundTransparency = transp or 0,
			BorderSizePixel = 0,
			Position = pos,
			Size = size,
			ZIndex = z,
			NoTheme = true,
		}, parent)
	end
	local function eo3(x) x = math.clamp(x, 0, 1) return 1 - (1 - x) ^ 3 end
	local function sm(x) x = math.clamp(x, 0, 1) return x * x * (3 - 2 * x) end
	local function lerp(a, b, t) return a + (b - a) * t end

	main.Visible = false
	miniCircle.Visible = false
	local function showLibrary()
		if main.Parent then
			main.Visible = not isMinimized
			miniCircle.Visible = isMinimized
		end
	end
	task.delay(D + 1.5, showLibrary)

	local overlay = create("Frame", {
		Name = "__CatHubIntro",
		Active = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 250,
	}, gui)
	local stage = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(0, 0),
		ZIndex = 253,
	}, overlay)
	local function disc(size, color, z, parent)
		local f = box(parent or stage, color, z, UDim2.fromOffset(0, 0), UDim2.fromOffset(size, size))
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		create("UICorner", { CornerRadius = UDim.new(0.5, 0) }, f)
		return f
	end
	local fx = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(0, 0),
		ZIndex = 254,
	}, stage)
	local FLOOR_Y = 0

	local particles, rings, rays = {}, {}, {}
	local fire
	local alive, impacted, contact = true, false, false
	local elapsed, simT, hitStopUntil = 0, 0, 0
	local shakeStart, shakeEnd = 0, 0
	local timeScale = 1
	local impactAt, impactSim = 0, 0
	local pxScale = diag / 1500 + 0.4
	local SPARK_COLORS = { INK, YEL, YEL, LPUR, LPUR, PUR }

	local function spawnSpark(parent, ox, oy, speed, ang, col, life, th, z)
		local f = box(parent, col, z or 262, UDim2.fromOffset(ox, oy), UDim2.fromOffset(6, th))
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		particles[#particles + 1] = {
			kind = "spark", gui = f, x = ox, y = oy,
			vx = math.cos(ang) * speed, vy = math.sin(ang) * speed,
			age = 0, life = life, drag = rng:NextNumber(1.4, 2.6), grav = 900, lenK = 0.045, th = th,
		}
	end
	local function spawnStar(parent, ox, oy, vx, vy, size, col, life, lift, z, delay)
		local f = box(parent, col, z or 262, UDim2.fromOffset(ox, oy), UDim2.fromOffset(size, size * 0.3))
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		local kid = box(f, col, z or 262, UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(size * 0.3, size))
		kid.AnchorPoint = Vector2.new(0.5, 0.5)
		if delay then f.Visible = false end
		particles[#particles + 1] = {
			kind = "star", gui = f, kid = kid, x = ox, y = oy, vx = vx, vy = vy,
			size = size, age = -(delay or 0), life = life, drag = 1.3, grav = lift,
			rot = rng:NextNumber(0, 90), spin = rng:NextNumber(-260, 260),
			sway = rng:NextNumber(4, 9), seed = rng:NextNumber(0, 6),
		}
	end
	local function spawnPuff(parent, ox, oy, vx, vy, size, grow, col, t0, life, sx, sy, z, delay)
		local f = disc(size, col, z or 256, parent)
		f.Position = UDim2.fromOffset(ox, oy)
		f.BackgroundTransparency = t0
		if delay then f.Visible = false end
		particles[#particles + 1] = {
			kind = "puff", gui = f, x = ox, y = oy, vx = vx, vy = vy, size = size, grow = grow,
			t0 = t0, age = -(delay or 0), life = life, drag = 2.2, grav = 0, sx = sx or 1, sy = sy or 1,
		}
	end

	local function stepParticles(sdt)
		for i = #particles, 1, -1 do
			local p = particles[i]
			p.age += sdt
			local g = p.gui
			if p.age >= p.life or not g.Parent then
				if g.Parent then g:Destroy() end
				table.remove(particles, i)
			elseif p.age >= 0 then
				if not g.Visible then g.Visible = true end
				local k = p.age / p.life
				local damp = math.exp(-(p.drag or 0) * sdt)
				p.vx *= damp
				p.vy = p.vy * damp + (p.grav or 0) * sdt
				p.x += p.vx * sdt
				p.y += p.vy * sdt
				if p.kind == "spark" then
					local spd = math.sqrt(p.vx * p.vx + p.vy * p.vy)
					g.Size = UDim2.fromOffset(math.clamp(spd * p.lenK, 3, 72) * (1 - k * 0.7), p.th * (1 - k * 0.5))
					g.Rotation = math.deg(math.atan2(p.vy, p.vx))
					g.BackgroundTransparency = k > 0.65 and (k - 0.65) / 0.35 or 0
				elseif p.kind == "star" then
					p.rot += p.spin * sdt
					p.vx += math.sin(p.age * p.sway + p.seed) * 90 * sdt
					g.Rotation = p.rot
					local flicker = (math.sin(p.age * 22 + p.seed * 5) > 0.1) and 0 or 0.55
					local tr = math.max(flicker, k > 0.7 and (k - 0.7) / 0.3 or 0)
					g.BackgroundTransparency = tr
					if p.kid then p.kid.BackgroundTransparency = tr end
					local s = p.size * (1 - k * 0.4)
					g.Size = UDim2.fromOffset(s, s * 0.3)
					if p.kid then p.kid.Size = UDim2.fromOffset(s * 0.3, s) end
				else
					local s = p.size + p.grow * p.age
					g.Size = UDim2.fromOffset(math.max(1, s * p.sx), math.max(1, s * p.sy))
					g.BackgroundTransparency = p.t0 + (1 - p.t0) * k * k
				end
				g.Position = UDim2.fromOffset(p.x, p.y)
			end
		end
	end

	local function addRing(delay, endD, life, thick, color, flat)
		local parent = flat and stage or fx
		local r = disc(20, INK, 257, parent)
		r.BackgroundTransparency = 1
		if flat then r.Position = UDim2.fromOffset(0, FLOOR_Y) end
		r.Visible = false
		local st = create("UIStroke", { Color = color, Thickness = thick, Transparency = 0 }, r)
		rings[#rings + 1] = { gui = r, stroke = st, age = -delay, life = life, d1 = endD, th = thick, flat = flat }
	end
	local function stepRings(sdt)
		for i = #rings, 1, -1 do
			local r = rings[i]
			r.age += sdt
			if r.age >= r.life or not r.gui.Parent then
				if r.gui.Parent then r.gui:Destroy() end
				table.remove(rings, i)
			elseif r.age >= 0 then
				r.gui.Visible = true
				local k = r.age / r.life
				local d = lerp(20, r.d1, eo3(k))
				r.gui.Size = UDim2.fromOffset(d, r.flat and d * 0.24 or d)
				r.stroke.Thickness = math.max(0.5, r.th * (1 - k))
				r.stroke.Transparency = k * k
			end
		end
	end

	local rayGrad = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.55, 0.35),
		NumberSequenceKeypoint.new(1, 0),
	})
	local function addRay(ang, R, col, width, life, delay)
		local f = box(fx, col, 259, UDim2.fromOffset(0, 0), UDim2.fromOffset(0, width))
		f.AnchorPoint = Vector2.new(0, 0.5)
		f.Rotation = math.deg(ang)
		f.Visible = false
		create("UIGradient", { Transparency = rayGrad }, f)
		rays[#rays + 1] = {
			gui = f, ang = ang, R = R, w = width, life = life, age = -delay,
			len = R * rng:NextNumber(0.9, 1.7), r0 = R * rng:NextNumber(0.2, 0.4),
		}
	end
	local function stepRays(sdt)
		for i = #rays, 1, -1 do
			local r = rays[i]
			r.age += sdt
			if r.age >= r.life or not r.gui.Parent then
				if r.gui.Parent then r.gui:Destroy() end
				table.remove(rays, i)
			elseif r.age >= 0 then
				r.gui.Visible = true
				local k = r.age / r.life
				local pos = r.r0 + r.R * 1.5 * eo3(k)
				local len = r.len * math.sin(math.pi * math.min(1, k * 1.15)) ^ 0.6
				r.gui.Position = UDim2.fromOffset(math.cos(r.ang) * pos, math.sin(r.ang) * pos)
				r.gui.Size = UDim2.fromOffset(len, r.w * (1 - k * 0.6))
				r.gui.BackgroundTransparency = k ^ 3
			end
		end
	end

	local function makeFire(R)
		local specs = {
			{ DPUR, 1.00, 0.78, 0.50 },
			{ PUR, 0.84, 0.56, 0.42 },
			{ YEL, 0.60, 0.36, 0.34 },
			{ INK, 0.32, 0.20, 0.26 },
		}
		local lobeN = 11
		local geom = {}
		for i = 1, lobeN do
			geom[i] = {
				a = (i / lobeN) * math.pi * 2 + rng:NextNumber(-0.25, 0.25),
				d = rng:NextNumber(0.40, 0.66), s = rng:NextNumber(0.42, 0.66), seed = rng:NextNumber(0, 6),
			}
		end
		local f = { R = R, t = 0, step = -1, layers = {} }
		for li, sp in ipairs(specs) do
			local layer = { rf = sp[2], shrinkAt = sp[3], dur = sp[4], lobes = {}, li = li }
			layer.center = disc(0, sp[1], 255 + li, fx)
			for i, g in ipairs(geom) do
				layer.lobes[i] = { f = disc(0, sp[1], 255 + li, fx), g = g }
			end
			f.layers[li] = layer
		end
		return f
	end
	local function stepFire(sdt)
		if not fire then return end
		fire.t += sdt
		local step = math.floor(fire.t * 22)
		if step == fire.step then return end
		fire.step = step
		local t, R = fire.t, fire.R
		local grow = eo3(t / 0.40)
		local anyVisible = false
		for _, L in ipairs(fire.layers) do
			local shrink = 1 - sm((t - L.shrinkAt) / L.dur)
			local s = grow * shrink
			local rise = -t * 70 * (1 + L.li * 0.12)
			local vis = s > 0.02
			L.center.Visible = vis
			if vis then
				anyVisible = true
				local R2 = R * L.rf * s
				L.center.Size = UDim2.fromOffset(R2 * 1.32, R2 * 1.32)
				L.center.Position = UDim2.fromOffset(0, rise)
				for _, lobe in ipairs(L.lobes) do
					local g = lobe.g
					local wob = 1 + 0.09 * math.sin(step * 1.9 + g.seed * 3)
					local r = R2 * g.s * wob
					lobe.f.Visible = true
					lobe.f.Size = UDim2.fromOffset(r * 2, r * 2)
					lobe.f.Position = UDim2.fromOffset(math.cos(g.a) * g.d * R2, math.sin(g.a) * g.d * R2 + rise)
				end
			else
				for _, lobe in ipairs(L.lobes) do lobe.f.Visible = false end
			end
		end
		if not anyVisible and t > 0.6 then
			for _, L in ipairs(fire.layers) do
				L.center:Destroy()
				for _, lobe in ipairs(L.lobes) do lobe.f:Destroy() end
			end
			fire = nil
		end
	end

	local function burstAt(parent, ox, oy, n, spd)
		for _ = 1, n do
			spawnSpark(parent, ox, oy, rng:NextNumber(0.4, 1) * spd * pxScale, rng:NextNumber(0, math.pi * 2),
				SPARK_COLORS[rng:NextInteger(1, #SPARK_COLORS)], rng:NextNumber(0.3, 0.8), rng:NextNumber(2, 4))
		end
	end

	local function spawnExplosion()
		local R = diag * 0.075
		for _ = 1, 9 do
			local a = rng:NextNumber(0, math.pi * 2)
			local dist = R * rng:NextNumber(0.2, 0.9)
			spawnPuff(fx, math.cos(a) * dist, math.sin(a) * dist - R * 0.2, math.cos(a) * 40, math.sin(a) * 30 - 40,
				R * rng:NextNumber(0.5, 1.0), R * rng:NextNumber(0.3, 0.6), DPUR, 0.2, rng:NextNumber(0.9, 1.4), 1, 1, 254)
		end
		fire = makeFire(R)
		local n = 18
		for i = 1, n do
			local a = (i / n) * math.pi * 2 + rng:NextNumber(-0.1, 0.1)
			local col = (i % 3 == 0) and INK or ((i % 3 == 1) and YEL or LPUR)
			addRay(a, R, col, rng:NextNumber(2, 6), rng:NextNumber(0.3, 0.5), rng:NextNumber(0, 0.05))
		end
		local count = math.clamp(math.floor(tonumber(config.ShardCount) or 55), 0, 120)
		for _ = 1, count do
			spawnSpark(fx, 0, 0, rng:NextNumber(220, 800) * pxScale, rng:NextNumber(0, math.pi * 2),
				SPARK_COLORS[rng:NextInteger(1, #SPARK_COLORS)], rng:NextNumber(0.4, 1.1), rng:NextNumber(1.5, 3.5))
		end
		for _ = 1, math.floor(count * 0.5) do
			local a = rng:NextNumber(0, math.pi * 2)
			local sp = rng:NextNumber(50, 280) * pxScale
			spawnStar(fx, 0, 0, math.cos(a) * sp, math.sin(a) * sp - 40, rng:NextNumber(5, 12),
				(rng:NextNumber() < 0.5) and YEL or LPUR, rng:NextNumber(1.0, 2.0), -rng:NextNumber(40, 140), 263)
		end
		addRing(0.00, diag * 0.42, 0.5, 8, INK, false)
		addRing(0.06, diag * 0.32, 0.5, 5, YEL, false)
		addRing(0.12, diag * 0.22, 0.5, 3, PUR, false)
	end

	local B = math.clamp(scr.Y * 0.045, 22, 44)
	local function makeBall(col, glow)
		local root = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(0, 0),
			ZIndex = 260,
		}, stage)
		local layers = {}
		for i, sp in ipairs({ { glow, 2.2, 0.65 }, { col, 1.0, 0 }, { INK, 0.5, 0 } }) do
			local f = disc(B * sp[2], sp[1], 260 + i, root)
			f.BackgroundTransparency = sp[3]
			layers[i] = { f = f, k = sp[2] }
		end
		return { root = root, layers = layers }
	end
	local function setBall(b, x, y, stretch)
		b.root.Position = UDim2.fromOffset(x, y)
		for _, l in ipairs(b.layers) do
			l.f.Size = UDim2.fromOffset(B * l.k * stretch, B * l.k)
		end
	end
	local ballL, ballR = makeBall(PUR, LPUR), makeBall(LPUR, PUR)
	local balls = { { b = ballL, dir = 1, col = PUR }, { b = ballR, dir = -1, col = LPUR } }

	local coneGrad = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
	for _, e in ipairs(balls) do
		e.cone = {}
		for i = 1, 2 do
			local l = box(stage, INK, 259, UDim2.fromOffset(0, 0), UDim2.fromOffset(0, 3))
			l.AnchorPoint = Vector2.new(0, 0.5)
			l.Visible = false
			create("UIGradient", { Transparency = coneGrad }, l)
			e.cone[i] = l
		end
	end

	local flash = box(overlay, INK, 271, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 1)

	local T_RUN, HITSTOP = D * 0.3, 0.08
	local startX = scr.X * 0.46
	local machDone, exploded = false, false
	local hitAt = 0
	local trailClock = 0

	local function sonicBoom(x, y, col)
		local ring = disc(16, col, 262)
		ring.Position = UDim2.fromOffset(x, y)
		ring.BackgroundTransparency = 1
		local st = create("UIStroke", { Color = INK, Thickness = 4, Transparency = 0 }, ring)
		safeGuiTween(ring, ti(0.35, Enum.EasingStyle.Quart), { Size = UDim2.fromOffset(46, scr.Y * 0.55) })
		safeGuiTween(st, ti(0.35), { Thickness = 0.5, Transparency = 1 })
		local pop = disc(B * 1.5, INK, 262)
		pop.Position = UDim2.fromOffset(x, y)
		pop.BackgroundTransparency = 0.2
		safeGuiTween(pop, ti(0.25, Enum.EasingStyle.Quart), { Size = UDim2.fromOffset(B * 5, B * 5), BackgroundTransparency = 1 })
		task.delay(0.4, function()
			if ring.Parent then ring:Destroy() end
			if pop.Parent then pop:Destroy() end
		end)
	end

	local TITLE_FONT = Enum.Font.GothamBold
	for _, name in ipairs({ "SciFi", "Michroma" }) do
		pcall(function() TITLE_FONT = Enum.Font[name] end)
	end
	local function slamLine(text, size, cy, tracking, delay, bright)
		local widths, total = {}, 0
		for i = 1, #text do
			local ch = string.sub(text, i, i)
			widths[i] = (ch == " ") and size * 0.5 or TextService:GetTextSize(ch, size, TITLE_FONT, Vector2.new(1000, 1000)).X
			total += widths[i] + tracking
		end
		total -= tracking
		local x = -total / 2
		for i = 1, #text do
			local ch, w = string.sub(text, i, i), widths[i]
			local cx = x + w / 2
			x += w + tracking
			if ch ~= " " then
				local holder = create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1,
					Position = UDim2.fromOffset(cx, cy), Size = UDim2.fromOffset(w + 4, size * 1.2),
					Visible = false, ZIndex = 264,
				}, stage)
				local sc = create("UIScale", { Scale = 1.35 }, holder)
				local function label(color, ox, oy, z, strokeCol, strokeT)
					local l = create("TextLabel", {
						BackgroundTransparency = 1, Font = TITLE_FONT, Text = ch, TextColor3 = color,
						TextSize = size, Size = UDim2.fromScale(1, 1), Position = UDim2.fromOffset(ox, oy),
						ZIndex = z, NoTheme = true,
					}, holder)
					create("UIStroke", { Color = strokeCol, Thickness = strokeT, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual }, l)
					return l
				end
				label(PUR, 0, 0, 264, PUR, math.max(3, size * 0.12)).TextTransparency = 0.55
				local face = label(Color3.new(1, 1, 1), 0, 0, 265, DPUR, 1.5)
				create("UIGradient", {
					Rotation = 90,
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, bright and INK or LPUR),
						ColorSequenceKeypoint.new(0.55, bright and LPUR or PUR),
						ColorSequenceKeypoint.new(1, PUR),
					}),
				}, face)
				task.delay(delay + (i - 1) * 0.04, function()
					if not alive or not holder.Parent then return end
					holder.Visible = true
					holder.Position = UDim2.fromOffset(cx + rng:NextNumber(-8, 8), cy)
					safeGuiTween(sc, ti(0.16, Enum.EasingStyle.Quint), { Scale = 1 })
					safeGuiTween(holder, ti(0.16, Enum.EasingStyle.Quint), { Position = UDim2.fromOffset(cx, cy) })
					task.delay(0.05, function() if holder.Parent then holder.Visible = false end end)
					task.delay(0.08, function() if holder.Parent then holder.Visible = true end end)
				end)
			end
		end
		return total
	end

	local function scanLine(cy, width, delay)
		task.delay(delay, function()
			if not alive or not overlay.Parent then return end
			local bar = box(stage, LPUR, 264, UDim2.fromOffset(0, cy), UDim2.fromOffset(0, 2))
			bar.AnchorPoint = Vector2.new(0.5, 0.5)
			create("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0),
					NumberSequenceKeypoint.new(0.8, 0), NumberSequenceKeypoint.new(1, 1),
				}),
			}, bar)
			safeGuiTween(bar, ti(0.3, Enum.EasingStyle.Quart), { Size = UDim2.fromOffset(width, 2) })
			for _, s in ipairs({ -1, 1 }) do
				local notch = box(stage, INK, 264, UDim2.fromOffset(s * width * 0.5, cy), UDim2.fromOffset(2, 10))
				notch.AnchorPoint = Vector2.new(0.5, 0.5)
				notch.BackgroundTransparency = 1
				safeGuiTween(notch, ti(0.25), { BackgroundTransparency = 0 })
			end
		end)
	end

	local function buildTitle()
		if not alive then return end
		local line1 = tostring(config.Title or "")
		local line2 = tostring(config.Subtitle or "")
		local size1 = math.clamp(math.floor(math.min(scr.X * 0.5 / (math.max(#line1, 1) * 0.95), scr.Y * 0.075)), 24, 64)
		local cy1 = -scr.Y * 0.02
		local w1 = size1 * 6
		if line1 ~= "" then
			w1 = slamLine(line1, size1, cy1, size1 * 0.22, 0, true)
		end
		if line2 ~= "" then
			local size2 = size1 * 0.4
			slamLine(line2, size2, cy1 + size1 * 0.95, size2 * 0.9, 0.2, false)
		end
		scanLine(cy1 - size1 * 0.78, w1 * 1.1, 0.1)
		scanLine(cy1 + size1 * 1.4, w1 * 1.1, 0.25)
	end

	local conn
	local function cleanup()
		alive = false
		UI.introPlaying = false
		if conn then conn:Disconnect() conn = nil end
		showLibrary()
		if overlay.Parent then overlay:Destroy() end
	end

	local function explode()
		exploded = true
		hitAt = elapsed
		for _, e in ipairs(balls) do
			e.b.root:Destroy()
			for _, l in ipairs(e.cone) do l:Destroy() end
		end
		flash.BackgroundColor3 = LPUR
		flash.BackgroundTransparency = 0.3
		safeGuiTween(flash, ti(0.45), { BackgroundTransparency = 1 })
		spawnExplosion()
		shakeStart, shakeEnd = elapsed, elapsed + 0.45
		task.delay(0.1, buildTitle)
		task.delay(0.4, function()
			if not alive then return end
			addRing(0, diag * 0.55, 0.5, 6, LPUR, false)
		end)
	end

	conn = RunService.RenderStepped:Connect(function(dt)
		if not alive or not overlay.Parent then
			if conn then conn:Disconnect() conn = nil end
			return
		end
		dt = math.min(dt, 1 / 20)
		elapsed += dt
		if elapsed < hitStopUntil then
			local a = 3
			stage.Position = UDim2.new(0.5, rng:NextNumber(-a, a), 0.5, rng:NextNumber(-a, a))
			return
		end
		if contact and not exploded then
			explode()
		end

		if not contact then
			simT += dt
			local t = simT
			local p = math.clamp(t / T_RUN, 0, 1)
			local x = startX * (1 - p ^ 3)
			local v = 3 * p * p * startX / T_RUN -- px/s, per ball
			local stretch = 1 + math.clamp(v / 350, 0, 4.5)
			local charge = 1 - p
			for _, e in ipairs(balls) do
				local bx = -e.dir * x
				local by = math.sin(t * 70 + e.dir) * 2.2 * charge * charge
				setBall(e.b, bx, by, stretch)
				local pulse = 1 + 0.12 * math.sin(t * 14 + e.dir)
				e.b.layers[1].f.Size = UDim2.fromOffset(B * 2.2 * stretch * pulse, B * 2.2 * pulse)
				-- afterimage trail
				if v > 150 then
					spawnPuff(stage, bx, by, 0, 0, B * 0.95, -B * 3.5, e.col, 0.35, 0.24, stretch * 0.9, 1, 259)
				end
				-- Mach cone
				local coneLen = math.clamp((v - 650) * 0.45, 0, 420)
				for i, l in ipairs(e.cone) do
					if coneLen > 4 then
						l.Visible = true
						l.Position = UDim2.fromOffset(bx, by)
						l.Size = UDim2.fromOffset(coneLen, 3)
						l.Rotation = (e.dir == 1 and 180 or 0) + ((i == 1) and -22 or 22)
					end
				end
			end
			-- breaking the sound barrier
			if not machDone and v > 700 then
				machDone = true
				for _, e in ipairs(balls) do
					sonicBoom(-e.dir * x, 0, e.col)
				end
				shakeStart, shakeEnd = elapsed, elapsed + 0.2
			end
			-- streaks racing across the whole screen once supersonic
			if v > 550 then
				for _ = 1, 2 do
					local sy = rng:NextNumber(-scr.Y * 0.5, scr.Y * 0.5)
					local sxp = rng:NextNumber(-scr.X * 0.5, scr.X * 0.5)
					spawnSpark(stage, sxp, sy, 2600, (sxp < 0) and 0 or math.pi, (rng:NextNumber() < 0.5) and INK or LPUR, 0.13, rng:NextNumber(1, 2), 258)
				end
			end
			-- charging sparkle while they wind up
			trailClock += dt
			if trailClock > 0.07 and p < 0.7 then
				trailClock = 0
				for _, e in ipairs(balls) do
					spawnStar(stage, -e.dir * x, 0, rng:NextNumber(-30, 30), rng:NextNumber(-60, -10), rng:NextNumber(4, 9), e.col, rng:NextNumber(0.3, 0.6), -40, 259)
				end
			end
			-- screen shake builds with speed
			local amp = 1 + (tonumber(config.ShakeStrength) or 9) * p * p
			if elapsed >= shakeEnd then
				stage.Position = UDim2.new(0.5, rng:NextNumber(-amp, amp), 0.5, rng:NextNumber(-amp, amp))
			end
			if t >= T_RUN then
				contact = true
				hitStopUntil = elapsed + HITSTOP
				for _, e in ipairs(balls) do
					setBall(e.b, 0, 0, 1 + 4.5 * 0.4)
					for _, l in ipairs(e.cone) do l.Visible = false end
				end
			end
		end

		local ex = dt * 1.4 -- the blast plays a little faster to fit the short intro
		stepFire(ex)
		stepParticles(ex)
		stepRings(ex)
		stepRays(ex)

		if exploded then
			if elapsed < shakeEnd then
				local k = 1 - (elapsed - shakeStart) / math.max(1e-3, shakeEnd - shakeStart)
				local amp = (tonumber(config.ShakeStrength) or 9) * 1.6 * math.max(0, k) ^ 2
				stage.Position = UDim2.new(0.5, rng:NextNumber(-amp, amp), 0.5, rng:NextNumber(-amp, amp))
			elseif stage.Position ~= UDim2.fromScale(0.5, 0.5) then
				stage.Position = UDim2.fromScale(0.5, 0.5)
			end
		end
	end)

	-- fade the whole intro out for the last 0.3 seconds
	task.delay(math.max(0.5, D - 0.3), function()
		if not alive or not overlay.Parent then return end
		local info = ti(0.28)
		for _, d in ipairs(overlay:GetDescendants()) do
			if d:IsA("TextLabel") then
				safeGuiTween(d, info, { TextTransparency = 1, TextStrokeTransparency = 1 })
			elseif d:IsA("UIStroke") then
				safeGuiTween(d, info, { Transparency = 1 })
			elseif d:IsA("Frame") then
				safeGuiTween(d, info, { BackgroundTransparency = 1 })
			end
		end
	end)
	task.delay(D, cleanup)

	return
end


-- ===== navigation (kept: Settings and the other tabs) =====
local allPages = {
    [settingsBtn] = settingsPage,
}
local allNavs = { settingsBtn }

local function showPage(page)
    for _, c in ipairs(content:GetChildren()) do
        if c:IsA("GuiObject") then c.Visible = false end
    end
    page.Visible = true
end

for btn, page in pairs(allPages) do
    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(allNavs) do UI.paintNav(b, false) end
        UI.paintNav(btn, true)
        showPage(page)
    end)
end

showPage(settingsPage)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = COL_RED, BackgroundTransparency = 0.3 }):Play()
end)

closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
end)

minimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.15), { BackgroundColor3 = COL_CARD, BackgroundTransparency = 0.3 }):Play()
end)

minimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(minimizeBtn, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
end)

local dragging = false
local dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

uiScale.Scale = scaleVal * 0.94
TweenService:Create(uiScale, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = scaleVal }):Play()

main.BackgroundTransparency = 1
header.BackgroundTransparency = 1
sidebar.BackgroundTransparency = 1

TweenService:Create(main, TweenInfo.new(0.5), { BackgroundTransparency = 0 }):Play()
TweenService:Create(header, TweenInfo.new(0.5), { BackgroundTransparency = 0 }):Play()
TweenService:Create(sidebar, TweenInfo.new(0.5), { BackgroundTransparency = 0 }):Play()

do
    for _, x in ipairs({34, 606}) do
        local ear = Instance.new("Frame")
        ear.Name = "CatEar"
        ear.AnchorPoint = Vector2.new(0.5, 0.5)
        ear.Size = UDim2.fromOffset(44, 44)
        ear.Position = UDim2.fromOffset(x, 2)
        ear.Rotation = 45
        ear.BackgroundColor3 = Color3.fromRGB(255, 157, 61)
        ear.BackgroundTransparency = 1
        ear.BorderSizePixel = 0
        ear.ZIndex = 1
        ear.Parent = main
        Instance.new("UICorner", ear).CornerRadius = UDim.new(0, 6)

        local inner = Instance.new("Frame")
        inner.Name = "Inner"
        inner.AnchorPoint = Vector2.new(0.5, 0.5)
        inner.Size = UDim2.fromOffset(24, 24)
        inner.Position = UDim2.fromScale(0.5, 0.5)
        inner.BackgroundColor3 = Color3.fromRGB(255, 194, 160)
        inner.BackgroundTransparency = 1
        inner.BorderSizePixel = 0
        inner.ZIndex = 1
        inner.Parent = ear
        Instance.new("UICorner", inner).CornerRadius = UDim.new(0, 4)

        -- fade in together with the window (no gray pop-in)
        TweenService:Create(ear, TweenInfo.new(0.5), { BackgroundTransparency = 0 }):Play()
        TweenService:Create(inner, TweenInfo.new(0.5), { BackgroundTransparency = 0 }):Play()
    end

    local savedName = "Orange"
    pcall(function()
        local t = getgenv().CatHubTheme
        if t and t[localPlayer.UserId] then savedName = t[localPlayer.UserId] end
    end)
    local fname = "cathub_theme_" .. localPlayer.UserId .. ".txt"
    if isfile and readfile then
        local ok, ex = pcall(isfile, fname)
        if ok and ex then
            local ok2, v = pcall(readfile, fname)
            if ok2 and type(v) == "string" then savedName = v end
        end
    end
    local pick = COLOR_COMBOS[1]
    for _, c in ipairs(COLOR_COMBOS) do
        if c.name == savedName then pick = c end
    end
    applyTheme(pick)
    UI.paintEars(pick)
end

UI.polish()
if opts.Intro ~= false then
    UI.playIntro()
end

-- ===== PUBLIC API =====
local Window = {}
local tabCount = 0

function Window:AddTab(name)
    tabCount += 1
    local btn = makeNavButton(string.lower(tostring(name)), tabCount)

    local page = Instance.new("ScrollingFrame")
    page.Name = "Tab_" .. tostring(name)
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.ZIndex = 2
    page.ScrollBarThickness = 3
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Parent = content

    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0, 6)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", page).PaddingRight = UDim.new(0, 6)

    local head = Instance.new("TextLabel")
    head.BackgroundTransparency = 1
    head.Size = UDim2.new(1, 0, 0, 22)
    head.Font = Enum.Font.GothamBold
    head.TextSize = 14
    head.TextColor3 = COL_TEXT
    head.TextXAlignment = Enum.TextXAlignment.Left
    head.Text = tostring(name)
    head.LayoutOrder = 0
    head.Parent = page

    table.insert(allNavs, btn)
    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(allNavs) do UI.paintNav(b, false) end
        UI.paintNav(btn, true)
        showPage(page)
    end)

    local function safe(cb, ...)
        if type(cb) == "function" then
            local ok, err = pcall(cb, ...)
            if not ok then warn("[cat hub] " .. tostring(err)) end
        end
    end

    -- builds Label / Button / Toggle / Panel inside any container (tab page or panel body)
    local function buildElements(parent)
        local T = {}
        local order = 0
        local function nextOrder()
            order += 1
            return order
        end

        function T:AddLabel(text)
            local l = Instance.new("TextLabel")
            l.BackgroundTransparency = 1
            l.Size = UDim2.new(1, 0, 0, 16)
            l.Font = Enum.Font.GothamBold
            l.TextSize = 9
            l.TextColor3 = COL_MUTED
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Text = string.upper(tostring(text))
            l.LayoutOrder = nextOrder()
            l.Parent = parent
            return l
        end

        function T:AddButton(text, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 32)
            b.BackgroundColor3 = COL_ACCENT
            b.Text = tostring(text)
            b.Font = Enum.Font.GothamBold
            b.TextSize = 12
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.AutoButtonColor = false
            b.BorderSizePixel = 0
            b.LayoutOrder = nextOrder()
            b.Parent = parent
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            local g = Instance.new("UIGradient", b)
            g.Rotation = 90
            g.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(205, 205, 205))
            b.MouseButton1Click:Connect(function() safe(callback) end)
            return b
        end

        function T:AddToggle(text, default, callback)
            local state = default == true
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 32)
            b.BackgroundColor3 = COL_PANEL
            b.Font = Enum.Font.GothamBold
            b.TextSize = 11
            b.TextColor3 = COL_TEXT
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.AutoButtonColor = false
            b.BorderSizePixel = 0
            b.LayoutOrder = nextOrder()
            b.Parent = parent
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            Instance.new("UIPadding", b).PaddingLeft = UDim.new(0, 12)

            local dot = Instance.new("Frame")
            dot.AnchorPoint = Vector2.new(1, 0.5)
            dot.Position = UDim2.new(1, -10, 0.5, 0)
            dot.Size = UDim2.fromOffset(14, 14)
            dot.BorderSizePixel = 0
            dot.Parent = b
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

            local function paint()
                b.Text = tostring(text)
                dot.BackgroundColor3 = state and COL_GREEN or COL_MUTED
            end
            paint()
            b.MouseButton1Click:Connect(function()
                state = not state
                paint()
                safe(callback, state)
            end)
            return b
        end

        -- PANEL: a button that opens/closes a box with more buttons inside
        function T:AddPanel(text, startOpen)
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, 0, 0, 32)
            holder.AutomaticSize = Enum.AutomaticSize.Y
            holder.BackgroundColor3 = COL_PANEL
            holder.BorderSizePixel = 0
            holder.LayoutOrder = nextOrder()
            holder.Parent = parent
            Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 6)
            UI.edge(holder, 0.5)

            local hl = Instance.new("UIListLayout", holder)
            hl.SortOrder = Enum.SortOrder.LayoutOrder
            hl.Padding = UDim.new(0, 4)

            local head = Instance.new("TextButton")
            head.Size = UDim2.new(1, 0, 0, 32)
            head.BackgroundTransparency = 1
            head.Font = Enum.Font.GothamBold
            head.TextSize = 11
            head.TextColor3 = COL_TEXT
            head.TextXAlignment = Enum.TextXAlignment.Left
            head.AutoButtonColor = false
            head.LayoutOrder = 0
            head.Parent = holder
            Instance.new("UIPadding", head).PaddingLeft = UDim.new(0, 12)

            local body = Instance.new("Frame")
            body.Size = UDim2.new(1, 0, 0, 0)
            body.AutomaticSize = Enum.AutomaticSize.Y
            body.BackgroundTransparency = 1
            body.LayoutOrder = 1
            body.Parent = holder
            local bl = Instance.new("UIListLayout", body)
            bl.SortOrder = Enum.SortOrder.LayoutOrder
            bl.Padding = UDim.new(0, 6)
            local bp = Instance.new("UIPadding", body)
            bp.PaddingLeft = UDim.new(0, 8)
            bp.PaddingRight = UDim.new(0, 8)
            bp.PaddingBottom = UDim.new(0, 8)

            local open = startOpen == true
            local function paint()
                head.Text = (open and "-  " or "+  ") .. tostring(text)
                body.Visible = open
            end
            paint()
            head.MouseButton1Click:Connect(function()
                open = not open
                paint()
            end)

            return buildElements(body) -- same methods work inside the panel
        end

        return T
    end

    return buildElements(page)
end

function Window:PlayIntro()
    UI.playIntro()
end

function Window:Destroy()
    gui:Destroy()
end

print("[cat hub] library loaded.")
return Window
end -- CreateWindow


return Library
