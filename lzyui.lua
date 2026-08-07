-- ============================================
-- LZYUI v1.0 - 林玉UI库
-- 一个简洁的Roblox UI库，支持标签页、开关、滑块、下拉框等
-- 作者：by
-- 用法：local LZYUI = loadstring(game:HttpGet("你的链接"))()
-- ============================================

local LZYUI = {}
LZYUI.__index = LZYUI

-- 默认颜色配置 - 全部改为浅色
local DEFAULT_COLORS = {
    PRIMARY   = Color3.fromRGB(180, 225, 245),  -- 主色（很浅的蓝色）
    ACCENT    = Color3.fromRGB(255, 210, 220),  -- 强调色（很浅的粉色）
    ACCENT2   = Color3.fromRGB(240, 190, 200),  -- 强调色2（浅粉）
    PRIMARY2  = Color3.fromRGB(160, 210, 235),  -- 主色2（浅蓝）
    BG        = Color3.fromRGB(248, 248, 250),  -- 背景
    TEXT      = Color3.fromRGB(70, 70, 80),     -- 文字
    TEXT2     = Color3.fromRGB(130, 130, 140),  -- 次要文字
    WHITE     = Color3.fromRGB(255, 255, 255),  -- 白色
    GRAY      = Color3.fromRGB(200, 200, 200),  -- 灰色
    DARK      = Color3.fromRGB(35, 35, 40),     -- 深色
}

-- 获取服务
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- 工具函数
-- ============================================
local function tween(obj, props, duration, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    duration = duration or 0.3
    TweenService:Create(obj, TweenInfo.new(duration, style, dir), props):Play()
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 12)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or DEFAULT_COLORS.GRAY
    s.Thickness = thickness or 1
    s.Transparency = 0.4
    s.Parent = parent
    return s
end

local function shadow(parent, offset, transparency)
    offset = offset or 8
    transparency = transparency or 0.85
    local sh = Instance.new("Frame")
    sh.Size = UDim2.new(1, offset*2, 1, offset*2)
    sh.Position = UDim2.new(0, -offset, 0, -offset)
    sh.BackgroundColor3 = Color3.fromRGB(0,0,0)
    sh.BackgroundTransparency = transparency
    sh.BorderSizePixel = 0
    sh.ZIndex = parent.ZIndex - 1
    sh.Parent = parent
    corner(sh, UDim.new(0, 16))
    return sh
end

-- ============================================
-- 组件创建函数
-- ============================================

-- 创建开关
function LZYUI:CreateToggle(parent, labelText, accentColor, onToggle)
    accentColor = accentColor or self.Colors.ACCENT

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = self.Colors.WHITE
    row.BorderSizePixel = 0
    row.ZIndex = 55
    row.Parent = parent
    corner(row, UDim.new(0, 10))
    stroke(row, accentColor, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = self.Colors.TEXT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 56
    lbl.Parent = row

    local toggleBg = Instance.new("TextButton")
    toggleBg.Size = UDim2.new(0, 48, 0, 26)
    toggleBg.Position = UDim2.new(1, -58, 0.5, -13)
    toggleBg.BackgroundColor3 = self.Colors.GRAY
    toggleBg.Text = ""
    toggleBg.BorderSizePixel = 0
    toggleBg.AutoButtonColor = false
    toggleBg.ZIndex = 56
    toggleBg.Parent = row
    corner(toggleBg, UDim.new(1, 0))

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 22, 0, 22)
    toggleKnob.Position = UDim2.new(0, 2, 0.5, -11)
    toggleKnob.BackgroundColor3 = self.Colors.WHITE
    toggleKnob.BorderSizePixel = 0
    toggleKnob.ZIndex = 57
    toggleKnob.Parent = toggleBg
    corner(toggleKnob, UDim.new(1, 0))

    local enabled = false

    toggleBg.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            tween(toggleBg, {BackgroundColor3 = accentColor}, 0.2)
            tween(toggleKnob, {Position = UDim2.new(0, 24, 0.5, -11)}, 0.2)
        else
            tween(toggleBg, {BackgroundColor3 = self.Colors.GRAY}, 0.2)
            tween(toggleKnob, {Position = UDim2.new(0, 2, 0.5, -11)}, 0.2)
        end
        if onToggle then 
            local ok, err = pcall(onToggle, enabled)
            if not ok then warn("Toggle回调错误: " .. tostring(err)) end
        end
    end)

    return row, function() return enabled end
end

-- 创建滑块
function LZYUI:CreateSlider(parent, labelText, accentColor, minVal, maxVal, defaultVal, onChange)
    accentColor = accentColor or self.Colors.ACCENT
    minVal = minVal or 0
    maxVal = maxVal or 100
    defaultVal = defaultVal or minVal

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 62)
    row.BackgroundColor3 = self.Colors.WHITE
    row.BorderSizePixel = 0
    row.ZIndex = 55
    row.Parent = parent
    corner(row, UDim.new(0, 10))
    stroke(row, accentColor, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 0, 22)
    lbl.Position = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = self.Colors.TEXT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 56
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 0, 22)
    valLbl.Position = UDim2.new(1, -58, 0, 6)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(defaultVal)
    valLbl.TextColor3 = accentColor
    valLbl.TextSize = 13
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 56
    valLbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -28, 0, 5)
    track.Position = UDim2.new(0, 14, 0, 38)
    track.BackgroundColor3 = self.Colors.GRAY
    track.BorderSizePixel = 0
    track.ZIndex = 56
    track.Parent = row
    corner(track, UDim.new(1, 0))

    local fill = Instance.new("Frame")
    local rel = (defaultVal - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(rel, 0, 1, 0)
    fill.BackgroundColor3 = accentColor
    fill.BorderSizePixel = 0
    fill.ZIndex = 57
    fill.Parent = track
    corner(fill, UDim.new(1, 0))

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(rel, -8, 0.5, -8)
    knob.BackgroundColor3 = self.Colors.WHITE
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.ZIndex = 58
    knob.Parent = track
    corner(knob, UDim.new(1, 0))

    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = accentColor
    knobStroke.Thickness = 2
    knobStroke.Parent = knob

    local dragging = false
    local currentVal = defaultVal

    local function updateFromPos(px)
        local trackAbs = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local relPos = math.clamp((px - trackAbs) / trackSize, 0, 1)
        currentVal = math.floor(minVal + relPos * (maxVal - minVal))
        valLbl.Text = tostring(currentVal)
        fill.Size = UDim2.new(relPos, 0, 1, 0)
        knob.Position = UDim2.new(relPos, -8, 0.5, -8)
        if onChange then 
            local ok, err = pcall(onChange, currentVal)
            if not ok then warn("Slider回调错误: " .. tostring(err)) end
        end
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updateFromPos(input.Position.X)
            dragging = true
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromPos(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return row, function() return currentVal end
end

-- 创建下拉框
function LZYUI:CreateDropdown(parent, labelText, accentColor, options, defaultIdx, onSelect)
    accentColor = accentColor or self.Colors.ACCENT
    options = options or {}
    defaultIdx = defaultIdx or 1

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = self.Colors.WHITE
    row.BorderSizePixel = 0
    row.ZIndex = 55
    row.Parent = parent
    corner(row, UDim.new(0, 10))
    stroke(row, accentColor, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -130, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = self.Colors.TEXT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 56
    lbl.Parent = row

    local selBtn = Instance.new("TextButton")
    selBtn.Size = UDim2.new(0, 110, 0, 30)
    selBtn.Position = UDim2.new(1, -120, 0.5, -15)
    selBtn.BackgroundColor3 = accentColor
    selBtn.Text = options[defaultIdx] or options[1] or "选择"
    selBtn.TextColor3 = self.Colors.WHITE
    selBtn.TextSize = 12
    selBtn.Font = Enum.Font.GothamBold
    selBtn.BorderSizePixel = 0
    selBtn.ZIndex = 56
    selBtn.Parent = row
    corner(selBtn, UDim.new(0, 6))

    local dropdownOpen = false
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0, 110, 0, 0)
    dropdownFrame.Position = UDim2.new(1, -120, 0, 42)
    dropdownFrame.BackgroundColor3 = self.Colors.WHITE
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.ZIndex = 60
    dropdownFrame.Visible = false
    dropdownFrame.ClipsDescendants = true
    dropdownFrame.Parent = row
    corner(dropdownFrame, UDim.new(0, 6))
    stroke(dropdownFrame, accentColor, 1)

    local ddLayout = Instance.new("UIListLayout")
    ddLayout.Padding = UDim.new(0, 2)
    ddLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ddLayout.Parent = dropdownFrame

    local ddPadding = Instance.new("UIPadding")
    ddPadding.PaddingTop = UDim.new(0, 4)
    ddPadding.PaddingBottom = UDim.new(0, 4)
    ddPadding.PaddingLeft = UDim.new(0, 4)
    ddPadding.PaddingRight = UDim.new(0, 4)
    ddPadding.Parent = dropdownFrame

    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 26)
        optBtn.BackgroundColor3 = self.Colors.BG
        optBtn.Text = opt
        optBtn.TextColor3 = self.Colors.TEXT
        optBtn.TextSize = 12
        optBtn.Font = Enum.Font.Gotham
        optBtn.BorderSizePixel = 0
        optBtn.LayoutOrder = i
        optBtn.ZIndex = 61
        optBtn.Parent = dropdownFrame
        corner(optBtn, UDim.new(0, 4))

        optBtn.MouseButton1Click:Connect(function()
            selBtn.Text = opt
            dropdownOpen = false
            dropdownFrame.Visible = false
            if onSelect then 
                local ok, err = pcall(onSelect, opt)
                if not ok then warn("Dropdown回调错误: " .. tostring(err)) end
            end
        end)
    end

    selBtn.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        dropdownFrame.Visible = dropdownOpen
        if dropdownOpen then
            dropdownFrame.Size = UDim2.new(0, 110, 0, #options * 28 + 8)
        end
    end)

    return row, function() return selBtn.Text end
end

-- 创建按钮
function LZYUI:CreateButton(parent, labelText, accentColor, onClick)
    accentColor = accentColor or self.Colors.ACCENT

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = accentColor
    btn.Text = labelText
    btn.TextColor3 = self.Colors.WHITE
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.ZIndex = 55
    btn.Parent = parent
    corner(btn, UDim.new(0, 10))

    btn.MouseButton1Click:Connect(function()
        tween(btn, {BackgroundColor3 = self.Colors.WHITE}, 0.1)
        task.wait(0.1)
        tween(btn, {BackgroundColor3 = accentColor}, 0.15)
        if onClick then 
            local ok, err = pcall(onClick)
            if not ok then warn("Button回调错误: " .. tostring(err)) end
        end
    end)

    return btn
end

-- 创建标签
function LZYUI:CreateLabel(parent, text, textSize, textColor)
    textSize = textSize or 13
    textColor = textColor or self.Colors.TEXT

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = textColor
    lbl.TextSize = textSize
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.ZIndex = 55
    lbl.Parent = parent

    return lbl
end

-- 创建分割线
function LZYUI:CreateDivider(parent, accentColor)
    accentColor = accentColor or self.Colors.ACCENT

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 36, 0, 3)
    line.BackgroundColor3 = accentColor
    line.BorderSizePixel = 0
    line.ZIndex = 54
    line.Parent = parent
    corner(line, UDim.new(1, 0))

    return line
end

-- 创建卡片容器
function LZYUI:CreateCard(parent, height)
    height = height or 100

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, height)
    card.BackgroundColor3 = self.Colors.WHITE
    card.BorderSizePixel = 0
    card.ZIndex = 54
    card.Parent = parent
    corner(card, UDim.new(0, 14))
    stroke(card, self.Colors.ACCENT, 1)

    return card
end

-- ============================================
-- 窗口创建
-- ============================================
function LZYUI.new(config)
    config = config or {}

    local self = setmetatable({}, LZYUI)
    self.Title = config.Title or "LZYUI"
    self.OrbText = config.OrbText or "Ly"
    self.Colors = {
        PRIMARY   = config.PrimaryColor or DEFAULT_COLORS.PRIMARY,
        ACCENT    = config.AccentColor or DEFAULT_COLORS.ACCENT,
        ACCENT2   = config.AccentColor2 or DEFAULT_COLORS.ACCENT2,
        PRIMARY2  = config.PrimaryColor2 or DEFAULT_COLORS.PRIMARY2,
        BG        = config.BgColor or DEFAULT_COLORS.BG,
        TEXT      = config.TextColor or DEFAULT_COLORS.TEXT,
        TEXT2     = config.TextColor2 or DEFAULT_COLORS.TEXT2,
        WHITE     = DEFAULT_COLORS.WHITE,
        GRAY      = DEFAULT_COLORS.GRAY,
        DARK      = DEFAULT_COLORS.DARK,
    }
    -- 窗口尺寸稍微缩小
    self.Width = config.Width or 0.70
    self.Height = self.Width * (420 / 320)
    self.Tabs = {}
    self.SelectedTab = 1
    self.IsOpen = false

    -- 创建主ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = self.Title .. "_UI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    self.ScreenGui.Parent = playerGui

    -- 创建悬浮球
    self.Orb = Instance.new("TextButton")
    self.Orb.Name = "Orb"
    self.Orb.Size = UDim2.new(0, 50, 0, 50)
    self.Orb.Position = UDim2.new(1, -70, 1, -70)
    self.Orb.BackgroundColor3 = self.Colors.PRIMARY
    self.Orb.BorderSizePixel = 0
    self.Orb.Text = self.OrbText
    self.Orb.TextColor3 = self.Colors.WHITE
    self.Orb.TextSize = 16
    self.Orb.Font = Enum.Font.GothamBold
    self.Orb.ZIndex = 100
    self.Orb.AutoButtonColor = false
    self.Orb.Parent = self.ScreenGui
    corner(self.Orb, UDim.new(1, 0))

    local orbStroke = Instance.new("UIStroke")
    orbStroke.Color = self.Colors.ACCENT
    orbStroke.Thickness = 2
    orbStroke.Transparency = 0.5
    orbStroke.Parent = self.Orb

    -- 创建主面板
    self.Panel = Instance.new("Frame")
    self.Panel.Name = "Panel"
    self.Panel.Size = UDim2.new(0, 0, 0, 0)
    self.Panel.Position = UDim2.new(1, -72, 1, -72)
    self.Panel.BackgroundColor3 = self.Colors.BG
    self.Panel.BackgroundTransparency = 1
    self.Panel.BorderSizePixel = 0
    self.Panel.Visible = false
    self.Panel.ClipsDescendants = true
    self.Panel.ZIndex = 50
    self.Panel.Parent = self.ScreenGui
    corner(self.Panel, UDim.new(0, 20))
    shadow(self.Panel)

    -- 创建inner并保存到self
    local inner = Instance.new("Frame")
    inner.Name = "Inner"
    inner.Size = UDim2.new(1, 0, 1, 0)
    inner.BackgroundColor3 = self.Colors.BG
    inner.BackgroundTransparency = 0
    inner.ClipsDescendants = true
    inner.ZIndex = 51
    inner.Parent = self.Panel
    corner(inner, UDim.new(0, 20))
    self.Inner = inner

    -- 顶部栏
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 50)
    topBar.BackgroundColor3 = self.Colors.PRIMARY
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 52
    topBar.Parent = inner
    corner(topBar, UDim.new(0, 20))

    -- 顶部栏遮罩（让底部变直）
    local topBarMask = Instance.new("Frame")
    topBarMask.Size = UDim2.new(1, 0, 0.5, 0)
    topBarMask.Position = UDim2.new(0, 0, 0.5, 0)
    topBarMask.BackgroundColor3 = self.Colors.PRIMARY
    topBarMask.BorderSizePixel = 0
    topBarMask.ZIndex = 53
    topBarMask.Parent = topBar

    local topTitle = Instance.new("TextLabel")
    topTitle.Size = UDim2.new(1, -110, 1, 0)
    topTitle.Position = UDim2.new(0, 18, 0, 0)
    topTitle.BackgroundTransparency = 1
    topTitle.Text = self.Title
    topTitle.TextColor3 = self.Colors.TEXT
    topTitle.TextSize = 18
    topTitle.Font = Enum.Font.GothamBold
    topTitle.TextXAlignment = Enum.TextXAlignment.Left
    topTitle.ZIndex = 54
    topTitle.Parent = topBar

    -- ========== 减号按钮（隐藏窗口）==========
    local shrinkBtn = Instance.new("TextButton")
    shrinkBtn.Name = "ShrinkBtn"
    shrinkBtn.Size = UDim2.new(0, 32, 0, 32)
    shrinkBtn.Position = UDim2.new(1, -76, 0, 9)
    shrinkBtn.BackgroundColor3 = self.Colors.ACCENT
    shrinkBtn.Text = "−"
    shrinkBtn.TextColor3 = self.Colors.TEXT
    shrinkBtn.TextSize = 20
    shrinkBtn.Font = Enum.Font.GothamBold
    shrinkBtn.BorderSizePixel = 0
    shrinkBtn.ZIndex = 55
    shrinkBtn.Parent = topBar
    corner(shrinkBtn, UDim.new(1, 0))

    shrinkBtn.MouseButton1Click:Connect(function()
        self:Hide()
    end)

    -- ========== 叉号按钮（销毁窗口）==========
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -40, 0, 9)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 55
    closeBtn.Parent = topBar
    corner(closeBtn, UDim.new(1, 0))

    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    -- 主体区域
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Size = UDim2.new(1, 0, 1, -50)
    body.Position = UDim2.new(0, 0, 0, 50)
    body.BackgroundTransparency = 1
    body.ClipsDescendants = true
    body.ZIndex = 51
    body.Parent = inner

    -- 导航栏
    local nav = Instance.new("ScrollingFrame")
    nav.Name = "Nav"
    nav.Size = UDim2.new(0.26, 0, 1, -24)
    nav.BackgroundColor3 = Color3.fromRGB(240, 240, 242)
    nav.BorderSizePixel = 0
    nav.ScrollBarThickness = 3
    nav.ScrollBarImageColor3 = self.Colors.PRIMARY2
    nav.CanvasSize = UDim2.new(0, 0, 0, 0)
    nav.AutomaticCanvasSize = Enum.AutomaticSize.Y
    nav.ZIndex = 52
    nav.Parent = body

    local navLayout = Instance.new("UIListLayout")
    navLayout.Padding = UDim.new(0, 8)
    navLayout.SortOrder = Enum.SortOrder.LayoutOrder
    navLayout.Parent = nav

    local navPadding = Instance.new("UIPadding")
    navPadding.PaddingLeft = UDim.new(0, 8)
    navPadding.PaddingRight = UDim.new(0, 8)
    navPadding.PaddingTop = UDim.new(0, 10)
    navPadding.PaddingBottom = UDim.new(0, 10)
    navPadding.Parent = nav

    self.Nav = nav
    self.NavButtons = {}

    -- 内容区域
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1 - 0.26 - 0.02, 0, 1, -24)
    content.Position = UDim2.new(0.26 + 0.02, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.ZIndex = 52
    content.Parent = body

    self.Content = content

    -- 设置拖拽
    self:_SetupDrag()

    return self
end

-- ============================================
-- 拖拽系统
-- ============================================
function LZYUI:_SetupDrag()
    local dragTouchId = nil
    local dragOffset = Vector2.new(0, 0)
    local dragStartPos = Vector2.new(0, 0)
    local isClick = true
    local CLICK_THRESHOLD = 10

    local function isOnOrb(pos)
        local orbPos = self.Orb.AbsolutePosition
        local orbSize = self.Orb.AbsoluteSize
        return pos.X >= orbPos.X - 15 and pos.X <= orbPos.X + orbSize.X + 15
           and pos.Y >= orbPos.Y - 15 and pos.Y <= orbPos.Y + orbSize.Y + 15
    end

    local function onInputBegan(input)
        if not self.Orb.Visible then return end
        if input.UserInputType ~= Enum.UserInputType.Touch 
           and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        if not isOnOrb(input.Position) then return end

        dragTouchId = input.UserInputType == Enum.UserInputType.Touch and input or "mouse"
        dragStartPos = input.Position
        dragOffset = Vector2.new(
            input.Position.X - self.Orb.AbsolutePosition.X,
            input.Position.Y - self.Orb.AbsolutePosition.Y
        )
        isClick = true
        tween(self.Orb, {Size = UDim2.new(0, 54, 0, 54)}, 0.1)
    end

    local function onInputChanged(input)
        if not dragTouchId then return end
        if input.UserInputType ~= Enum.UserInputType.Touch 
           and input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end
        if dragTouchId ~= "mouse" and dragTouchId ~= input then return end

        local pos = input.Position
        local dist = (pos - dragStartPos).Magnitude
        if dist > CLICK_THRESHOLD then isClick = false end

        local screenW = self.ScreenGui.AbsoluteSize.X
        local screenH = self.ScreenGui.AbsoluteSize.Y
        local orbW = 54
        local orbH = 54

        local newX = pos.X - dragOffset.X
        local newY = pos.Y - dragOffset.Y
        newX = math.clamp(newX, 0, screenW - orbW)
        newY = math.clamp(newY, 0, screenH - orbH)

        self.Orb.Position = UDim2.new(0, newX, 0, newY)
    end

    local function onInputEnded(input)
        if not dragTouchId then return end
        if input.UserInputType ~= Enum.UserInputType.Touch 
           and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end
        if dragTouchId ~= "mouse" and dragTouchId ~= input then return end

        dragTouchId = nil

        if isClick then
            self:Show()
        else
            local screenW = self.ScreenGui.AbsoluteSize.X
            local orbX = self.Orb.AbsolutePosition.X
            local orbW = 54
            local targetX = (orbX + orbW/2 < screenW / 2) and 12 or (screenW - orbW - 12)
            tween(self.Orb, {Position = UDim2.new(0, targetX, 0, self.Orb.AbsolutePosition.Y)}, 0.25)
        end
    end

    UserInputService.InputBegan:Connect(onInputBegan)
    UserInputService.InputChanged:Connect(onInputChanged)
    UserInputService.InputEnded:Connect(onInputEnded)
end

-- ============================================
-- 窗口控制 - 简洁缩放+淡入淡出过渡
-- ============================================
function LZYUI:Show()
    if self.IsOpen then return end
    self.IsOpen = true
    self.Orb.Visible = false
    self.Panel.Visible = true

    -- 初始状态：缩小+透明+偏上
    local targetX = (1 - self.Width) / 2
    local targetY = (1 - self.Height) / 2 - 0.05

    self.Panel.Size = UDim2.new(self.Width * 0.85, 0, self.Height * 0.85, 0)
    self.Panel.Position = UDim2.new(targetX + self.Width * 0.075, 0, targetY + self.Height * 0.075, 0)
    self.Panel.BackgroundTransparency = 1
    self.Inner.BackgroundTransparency = 0.4

    -- 同时播放缩放+淡入动画
    tween(self.Panel, {
        Size = UDim2.new(self.Width, 0, self.Height, 0),
        Position = UDim2.new(targetX, 0, targetY, 0),
        BackgroundTransparency = 1,
    }, 0.25)

    tween(self.Inner, {
        BackgroundTransparency = 0,
    }, 0.25)
end

function LZYUI:Hide()
    if not self.IsOpen then return end
    self.IsOpen = false

    local targetX = (1 - self.Width) / 2
    local targetY = (1 - self.Height) / 2 - 0.05

    -- 同时播放缩放+淡出动画
    tween(self.Panel, {
        Size = UDim2.new(self.Width * 0.85, 0, self.Height * 0.85, 0),
        Position = UDim2.new(targetX + self.Width * 0.075, 0, targetY + self.Height * 0.075, 0),
    }, 0.2)

    tween(self.Inner, {
        BackgroundTransparency = 0.4,
    }, 0.2)

    task.wait(0.2)
    self.Panel.Visible = false
    self.Orb.Visible = true
end

function LZYUI:SetTitle(title)
    self.Title = title
    for _, child in ipairs(self.Inner.TopBar:GetChildren()) do
        if child:IsA("TextLabel") then
            child.Text = title
            break
        end
    end
end

function LZYUI:SetOrbText(text)
    self.OrbText = text
    self.Orb.Text = text
end

function LZYUI:SetOrbColor(color)
    self.Orb.BackgroundColor3 = color
end

function LZYUI:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

-- ============================================
-- 标签页系统
-- ============================================
function LZYUI:AddTab(name, icon, accentColor)
    accentColor = accentColor or self.Colors.ACCENT
    icon = icon or ""

    local idx = #self.Tabs + 1

    -- 创建导航按钮
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 56)
    btn.BackgroundColor3 = (idx == 1) and accentColor or self.Colors.WHITE
    btn.BackgroundTransparency = 0
    btn.Text = icon
    btn.TextColor3 = self.Colors.TEXT
    btn.TextSize = 20
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.LayoutOrder = idx
    btn.ZIndex = 53
    btn.Parent = self.Nav
    corner(btn, UDim.new(0, 14))

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 14)
    lbl.Position = UDim2.new(0, 0, 1, -14)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = self.Colors.TEXT2
    lbl.TextSize = 10
    lbl.Font = Enum.Font.Gotham
    lbl.ZIndex = 54
    lbl.Parent = btn

    self.NavButtons[idx] = btn

    -- 创建内容页
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = accentColor
    page.CanvasSize = UDim2.new(0, 0, 0, 600)
    page.Visible = (idx == 1)
    page.ZIndex = 53
    page.Parent = self.Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.Parent = page

    -- 页面标题
    local divider = self:CreateDivider(page, accentColor)
    divider.LayoutOrder = 1

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 28)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = name
    titleLbl.TextColor3 = self.Colors.TEXT
    titleLbl.TextSize = 18
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.LayoutOrder = 2
    titleLbl.ZIndex = 54
    titleLbl.Parent = page

    -- 内容容器
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.LayoutOrder = 3
    container.ZIndex = 54
    container.Parent = page

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.Padding = UDim.new(0, 8)
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Parent = container

    -- 自动更新CanvasSize
    local function updateCanvas()
        container.Size = UDim2.new(1, 0, 0, containerLayout.AbsoluteContentSize.Y)
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
    end
    containerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    task.delay(0.1, updateCanvas)

    -- 按钮点击切换
    btn.MouseButton1Click:Connect(function()
        self:SwitchTab(idx)
    end)

    local tabObj = {
        Name = name,
        Page = page,
        Container = container,
        AccentColor = accentColor,
        Index = idx,
        Elements = {},
    }

    -- 为Tab对象添加快捷方法
    function tabObj:AddToggle(label, callback)
        local el, getVal = self.Window:CreateToggle(self.Container, label, self.AccentColor, callback)
        el.LayoutOrder = #self.Elements + 1
        table.insert(self.Elements, {Type = "Toggle", Element = el, GetValue = getVal})
        return el, getVal
    end

    function tabObj:AddSlider(label, min, max, default, callback)
        local el, getVal = self.Window:CreateSlider(self.Container, label, self.AccentColor, min, max, default, callback)
        el.LayoutOrder = #self.Elements + 1
        table.insert(self.Elements, {Type = "Slider", Element = el, GetValue = getVal})
        return el, getVal
    end

    function tabObj:AddDropdown(label, options, default, callback)
        local el, getVal = self.Window:CreateDropdown(self.Container, label, self.AccentColor, options, default, callback)
        el.LayoutOrder = #self.Elements + 1
        table.insert(self.Elements, {Type = "Dropdown", Element = el, GetValue = getVal})
        return el, getVal
    end

    function tabObj:AddButton(label, callback)
        local el = self.Window:CreateButton(self.Container, label, self.AccentColor, callback)
        el.LayoutOrder = #self.Elements + 1
        table.insert(self.Elements, {Type = "Button", Element = el})
        return el
    end

    function tabObj:AddLabel(text, size, color)
        local el = self.Window:CreateLabel(self.Container, text, size, color)
        el.LayoutOrder = #self.Elements + 1
        table.insert(self.Elements, {Type = "Label", Element = el})
        return el
    end

    function tabObj:AddCard(height)
        local el = self.Window:CreateCard(self.Container, height)
        el.LayoutOrder = #self.Elements + 1
        table.insert(self.Elements, {Type = "Card", Element = el})
        return el
    end

    -- 绑定Window引用
    tabObj.Window = self

    self.Tabs[idx] = tabObj
    return tabObj
end

function LZYUI:SwitchTab(idx)
    if self.SelectedTab == idx then
        self.NavButtons[idx].BackgroundColor3 = math.random() > 0.5 and self.Colors.PRIMARY or self.Colors.ACCENT
        return
    end

    if self.NavButtons[self.SelectedTab] then
        self.NavButtons[self.SelectedTab].BackgroundColor3 = self.Colors.WHITE
    end

    if self.NavButtons[idx] then
        self.NavButtons[idx].BackgroundColor3 = self.Tabs[idx].AccentColor
    end

    if self.Tabs[self.SelectedTab] then
        self.Tabs[self.SelectedTab].Page.Visible = false
    end

    if self.Tabs[idx] then
        self.Tabs[idx].Page.Visible = true
        self.Tabs[idx].Page.Position = UDim2.new(0.05, 0, 0, 0)
        tween(self.Tabs[idx].Page, {Position = UDim2.new(0, 0, 0, 0)}, 0.25)
    end

    self.SelectedTab = idx
end

-- ============================================
-- 通知系统 - 移到左上角屏幕外
-- ============================================
function LZYUI:Notify(title, text, duration)
    duration = duration or 3

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 280, 0, 80)
    -- 初始位置在左上角屏幕外
    notif.Position = UDim2.new(0, -300, 0, -100)
    notif.BackgroundColor3 = self.Colors.WHITE
    notif.BorderSizePixel = 0
    notif.ZIndex = 200
    notif.Parent = self.ScreenGui
    corner(notif, UDim.new(0, 14))
    shadow(notif, 6, 0.8)

    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = self.Colors.ACCENT
    notifStroke.Thickness = 1.5
    notifStroke.Transparency = 0.3
    notifStroke.Parent = notif

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -20, 0, 22)
    titleLbl.Position = UDim2.new(0, 10, 0, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = self.Colors.TEXT
    titleLbl.TextSize = 14
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 201
    titleLbl.Parent = notif

    local textLbl = Instance.new("TextLabel")
    textLbl.Size = UDim2.new(1, -20, 0, 40)
    textLbl.Position = UDim2.new(0, 10, 0, 30)
    textLbl.BackgroundTransparency = 1
    textLbl.Text = text
    textLbl.TextColor3 = self.Colors.TEXT2
    textLbl.TextSize = 12
    textLbl.Font = Enum.Font.Gotham
    textLbl.TextXAlignment = Enum.TextXAlignment.Left
    textLbl.TextWrapped = true
    textLbl.ZIndex = 201
    textLbl.Parent = notif

    -- 滑入动画 - 从左上角屏幕外滑入到左上角可见区域
    tween(notif, {Position = UDim2.new(0, 20, 0, 20)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    task.delay(duration, function()
        -- 滑出动画 - 滑回左上角屏幕外
        tween(notif, {Position = UDim2.new(0, -300, 0, -100)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.wait(0.3)
        notif:Destroy()
    end)
end

-- ============================================
-- 主题切换
-- ============================================
function LZYUI:SetTheme(theme)
    if theme == "dark" then
        self.Colors.BG = Color3.fromRGB(35, 35, 42)
        self.Colors.TEXT = Color3.fromRGB(230, 230, 240)
        self.Colors.TEXT2 = Color3.fromRGB(160, 160, 170)
        self.Colors.WHITE = Color3.fromRGB(50, 50, 58)
        self.Colors.GRAY = Color3.fromRGB(80, 80, 90)
    elseif theme == "light" then
        self.Colors.BG = Color3.fromRGB(245, 245, 247)
        self.Colors.TEXT = Color3.fromRGB(55, 55, 65)
        self.Colors.TEXT2 = Color3.fromRGB(110, 110, 120)
        self.Colors.WHITE = Color3.fromRGB(255, 255, 255)
        self.Colors.GRAY = Color3.fromRGB(190, 190, 190)
    end
    self:Notify("主题切换", "主题已切换为 " .. theme .. "，重启后完全生效", 2)
end

-- ============================================
-- 返回库
-- ============================================
return LZYUI
