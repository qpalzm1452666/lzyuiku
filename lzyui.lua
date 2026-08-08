-- ============================================
-- LZYUI v2.0 - LinYu UI Library
-- Roblox UI Library with Tabs, Toggles, Sliders, Dropdowns, etc.
-- ============================================

local LZYUI = {}
LZYUI.__index = LZYUI

-- Default Colors (Light Theme)
local DEFAULT_COLORS = {
    PRIMARY   = Color3.fromRGB(180, 225, 245),
    ACCENT    = Color3.fromRGB(255, 210, 220),
    ACCENT2   = Color3.fromRGB(240, 190, 200),
    PRIMARY2  = Color3.fromRGB(160, 210, 235),
    BG        = Color3.fromRGB(248, 248, 250),
    TEXT      = Color3.fromRGB(70, 70, 80),
    TEXT2     = Color3.fromRGB(130, 130, 140),
    WHITE     = Color3.fromRGB(255, 255, 255),
    GRAY      = Color3.fromRGB(200, 200, 200),
    DARK      = Color3.fromRGB(35, 35, 40),
}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- Easing Presets
-- ============================================
LZYUI.EasingPresets = {
    Default = {Enum.EasingStyle.Quad, Enum.EasingDirection.Out},
    Bounce = {Enum.EasingStyle.Bounce, Enum.EasingDirection.Out},
    Elastic = {Enum.EasingStyle.Elastic, Enum.EasingDirection.Out},
    Expo = {Enum.EasingStyle.Expo, Enum.EasingDirection.Out},
    Back = {Enum.EasingStyle.Back, Enum.EasingDirection.Out},
    Sine = {Enum.EasingStyle.Sine, Enum.EasingDirection.Out},
    Linear = {Enum.EasingStyle.Linear, Enum.EasingDirection.Out},
}

-- ============================================
-- Utility Functions
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
-- Component: Toggle
-- ============================================
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
            if not ok then warn("Toggle error: " .. tostring(err)) end
        end
    end)

    return row, function() return enabled end
end

-- ============================================
-- Component: Slider
-- ============================================
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
            if not ok then warn("Slider error: " .. tostring(err)) end
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

-- ============================================
-- Component: Dropdown
-- ============================================
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
    selBtn.Text = options[defaultIdx] or options[1] or "Select"
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
                if not ok then warn("Dropdown error: " .. tostring(err)) end
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

-- ============================================
-- Component: Button
-- ============================================
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
            if not ok then warn("Button error: " .. tostring(err)) end
        end
    end)

    return btn
end

-- ============================================
-- Component: Label
-- ============================================
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

-- ============================================
-- Component: Divider
-- ============================================
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

-- ============================================
-- Component: Card
-- ============================================
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
-- NEW COMPONENTS
-- ============================================

-- 1. ColorPicker
function LZYUI:CreateColorPicker(parent, labelText, accentColor, defaultColor, onChange)
    accentColor = accentColor or self.Colors.ACCENT
    defaultColor = defaultColor or Color3.fromRGB(255, 100, 100)

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

    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.new(0, 40, 0, 28)
    colorBtn.Position = UDim2.new(1, -54, 0.5, -14)
    colorBtn.BackgroundColor3 = defaultColor
    colorBtn.Text = ""
    colorBtn.BorderSizePixel = 0
    colorBtn.ZIndex = 56
    colorBtn.Parent = row
    corner(colorBtn, UDim.new(0, 6))
    stroke(colorBtn, self.Colors.GRAY, 1)

    local pickerOpen = false
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.new(1, 0, 0, 0)
    pickerFrame.Position = UDim2.new(0, 0, 0, 48)
    pickerFrame.BackgroundColor3 = self.Colors.WHITE
    pickerFrame.BorderSizePixel = 0
    pickerFrame.ZIndex = 60
    pickerFrame.Visible = false
    pickerFrame.ClipsDescendants = true
    pickerFrame.Parent = row
    corner(pickerFrame, UDim.new(0, 10))
    stroke(pickerFrame, accentColor, 1)

    local currentColor = defaultColor
    local vals = {
        math.floor(defaultColor.R * 255),
        math.floor(defaultColor.G * 255),
        math.floor(defaultColor.B * 255)
    }
    local names = {"R", "G", "B"}
    local colors = {Color3.fromRGB(255, 100, 100), Color3.fromRGB(100, 255, 100), Color3.fromRGB(100, 100, 255)}

    for i = 1, 3 do
        local sRow = Instance.new("Frame")
        sRow.Size = UDim2.new(1, -16, 0, 30)
        sRow.Position = UDim2.new(0, 8, 0, 8 + (i-1) * 34)
        sRow.BackgroundTransparency = 1
        sRow.ZIndex = 61
        sRow.Parent = pickerFrame

        local sLbl = Instance.new("TextLabel")
        sLbl.Size = UDim2.new(0, 20, 1, 0)
        sLbl.BackgroundTransparency = 1
        sLbl.Text = names[i]
        sLbl.TextColor3 = colors[i]
        sLbl.TextSize = 12
        sLbl.Font = Enum.Font.GothamBold
        sLbl.ZIndex = 62
        sLbl.Parent = sRow

        local sTrack = Instance.new("Frame")
        sTrack.Size = UDim2.new(1, -60, 0, 4)
        sTrack.Position = UDim2.new(0, 28, 0.5, -2)
        sTrack.BackgroundColor3 = self.Colors.GRAY
        sTrack.BorderSizePixel = 0
        sTrack.ZIndex = 62
        sTrack.Parent = sRow
        corner(sTrack, UDim.new(1, 0))

        local sFill = Instance.new("Frame")
        sFill.Size = UDim2.new(vals[i] / 255, 0, 1, 0)
        sFill.BackgroundColor3 = colors[i]
        sFill.BorderSizePixel = 0
        sFill.ZIndex = 63
        sFill.Parent = sTrack
        corner(sFill, UDim.new(1, 0))

        local sKnob = Instance.new("TextButton")
        sKnob.Size = UDim2.new(0, 12, 0, 12)
        sKnob.Position = UDim2.new(vals[i] / 255, -6, 0.5, -6)
        sKnob.BackgroundColor3 = self.Colors.WHITE
        sKnob.Text = ""
        sKnob.BorderSizePixel = 0
        sKnob.ZIndex = 64
        sKnob.Parent = sTrack
        corner(sKnob, UDim.new(1, 0))
        local ks = Instance.new("UIStroke")
        ks.Color = colors[i]
        ks.Thickness = 2
        ks.Parent = sKnob

        local sValLbl = Instance.new("TextLabel")
        sValLbl.Size = UDim2.new(0, 30, 1, 0)
        sValLbl.Position = UDim2.new(1, -30, 0, 0)
        sValLbl.BackgroundTransparency = 1
        sValLbl.Text = tostring(vals[i])
        sValLbl.TextColor3 = self.Colors.TEXT
        sValLbl.TextSize = 11
        sValLbl.Font = Enum.Font.GothamBold
        sValLbl.ZIndex = 62
        sValLbl.Parent = sRow

        local dragging = false
        local idx = i

        local function updateS(px)
            local abs = sTrack.AbsolutePosition.X
            local size = sTrack.AbsoluteSize.X
            local rel = math.clamp((px - abs) / size, 0, 1)
            local v = math.floor(rel * 255)
            vals[idx] = v
            sValLbl.Text = tostring(v)
            sFill.Size = UDim2.new(rel, 0, 1, 0)
            sKnob.Position = UDim2.new(rel, -6, 0.5, -6)
            currentColor = Color3.fromRGB(vals[1], vals[2], vals[3])
            colorBtn.BackgroundColor3 = currentColor
            if onChange then
                local ok, err = pcall(onChange, currentColor)
                if not ok then warn("ColorPicker error: " .. tostring(err)) end
            end
        end

        sKnob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        sTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                updateS(input.Position.X)
                dragging = true
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateS(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    colorBtn.MouseButton1Click:Connect(function()
        pickerOpen = not pickerOpen
        pickerFrame.Visible = pickerOpen
        if pickerOpen then
            pickerFrame.Size = UDim2.new(1, 0, 0, 110)
            row.Size = UDim2.new(1, 0, 0, 160)
        else
            pickerFrame.Size = UDim2.new(1, 0, 0, 0)
            row.Size = UDim2.new(1, 0, 0, 46)
        end
    end)

    return row, function() return currentColor end
end

-- 2. TextBox
function LZYUI:CreateTextBox(parent, labelText, accentColor, placeholder, defaultText, onChange)
    accentColor = accentColor or self.Colors.ACCENT
    placeholder = placeholder or "Enter text..."
    defaultText = defaultText or ""

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 70)
    row.BackgroundColor3 = self.Colors.WHITE
    row.BorderSizePixel = 0
    row.ZIndex = 55
    row.Parent = parent
    corner(row, UDim.new(0, 10))
    stroke(row, accentColor, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 22)
    lbl.Position = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = self.Colors.TEXT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 56
    lbl.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -28, 0, 30)
    box.Position = UDim2.new(0, 14, 0, 34)
    box.BackgroundColor3 = self.Colors.BG
    box.Text = defaultText
    box.PlaceholderText = placeholder
    box.TextColor3 = self.Colors.TEXT
    box.PlaceholderColor3 = self.Colors.TEXT2
    box.TextSize = 12
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.BorderSizePixel = 0
    box.ZIndex = 56
    box.Parent = row
    corner(box, UDim.new(0, 6))

    box.FocusLost:Connect(function()
        if onChange then
            local ok, err = pcall(onChange, box.Text)
            if not ok then warn("TextBox error: " .. tostring(err)) end
        end
    end)

    return row, function() return box.Text end
end

-- 3. SearchBox
function LZYUI:CreateSearchBox(parent, labelText, accentColor, placeholder, onSearch)
    accentColor = accentColor or self.Colors.ACCENT
    placeholder = placeholder or "Search..."

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 70)
    row.BackgroundColor3 = self.Colors.WHITE
    row.BorderSizePixel = 0
    row.ZIndex = 55
    row.Parent = parent
    corner(row, UDim.new(0, 10))
    stroke(row, accentColor, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 22)
    lbl.Position = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = self.Colors.TEXT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 56
    lbl.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -70, 0, 30)
    box.Position = UDim2.new(0, 14, 0, 34)
    box.BackgroundColor3 = self.Colors.BG
    box.Text = ""
    box.PlaceholderText = placeholder
    box.TextColor3 = self.Colors.TEXT
    box.PlaceholderColor3 = self.Colors.TEXT2
    box.TextSize = 12
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.BorderSizePixel = 0
    box.ZIndex = 56
    box.Parent = row
    corner(box, UDim.new(0, 6))

    local searchBtn = Instance.new("TextButton")
    searchBtn.Size = UDim2.new(0, 36, 0, 30)
    searchBtn.Position = UDim2.new(1, -50, 0, 34)
    searchBtn.BackgroundColor3 = accentColor
    searchBtn.Text = "S"
    searchBtn.TextColor3 = self.Colors.WHITE
    searchBtn.TextSize = 14
    searchBtn.Font = Enum.Font.GothamBold
    searchBtn.BorderSizePixel = 0
    searchBtn.ZIndex = 56
    searchBtn.Parent = row
    corner(searchBtn, UDim.new(0, 6))

    local function doSearch()
        if onSearch then
            local ok, err = pcall(onSearch, box.Text)
            if not ok then warn("SearchBox error: " .. tostring(err)) end
        end
    end

    searchBtn.MouseButton1Click:Connect(doSearch)
    box.FocusLost:Connect(function(enterPressed)
        if enterPressed then doSearch() end
    end)

    return row, function() return box.Text end
end

-- 4. MultiSelect
function LZYUI:CreateMultiSelect(parent, labelText, accentColor, options, onChange)
    accentColor = accentColor or self.Colors.ACCENT
    options = options or {}

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = self.Colors.WHITE
    row.BorderSizePixel = 0
    row.ZIndex = 55
    row.Parent = parent
    corner(row, UDim.new(0, 10))
    stroke(row, accentColor, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 22)
    lbl.Position = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = self.Colors.TEXT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 56
    lbl.Parent = row

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 0)
    container.Position = UDim2.new(0, 10, 0, 30)
    container.BackgroundTransparency = 1
    container.ZIndex = 56
    container.Parent = row

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    local selected = {}

    for i, opt in ipairs(options) do
        local optRow = Instance.new("Frame")
        optRow.Size = UDim2.new(1, 0, 0, 28)
        optRow.BackgroundTransparency = 1
        optRow.LayoutOrder = i
        optRow.ZIndex = 57
        optRow.Parent = container

        local check = Instance.new("TextButton")
        check.Size = UDim2.new(0, 18, 0, 18)
        check.Position = UDim2.new(0, 4, 0.5, -9)
        check.BackgroundColor3 = self.Colors.BG
        check.Text = ""
        check.BorderSizePixel = 0
        check.ZIndex = 58
        check.Parent = optRow
        corner(check, UDim.new(0, 4))
        stroke(check, self.Colors.GRAY, 1)

        local checkMark = Instance.new("TextLabel")
        checkMark.Size = UDim2.new(1, 0, 1, 0)
        checkMark.BackgroundTransparency = 1
        checkMark.Text = "v"
        checkMark.TextColor3 = accentColor
        checkMark.TextSize = 14
        checkMark.Font = Enum.Font.GothamBold
        checkMark.ZIndex = 59
        checkMark.Visible = false
        checkMark.Parent = check

        local optLbl = Instance.new("TextLabel")
        optLbl.Size = UDim2.new(1, -30, 1, 0)
        optLbl.Position = UDim2.new(0, 28, 0, 0)
        optLbl.BackgroundTransparency = 1
        optLbl.Text = opt
        optLbl.TextColor3 = self.Colors.TEXT
        optLbl.TextSize = 12
        optLbl.Font = Enum.Font.Gotham
        optLbl.TextXAlignment = Enum.TextXAlignment.Left
        optLbl.ZIndex = 58
        optLbl.Parent = optRow

        local isChecked = false
        check.MouseButton1Click:Connect(function()
            isChecked = not isChecked
            checkMark.Visible = isChecked
            check.BackgroundColor3 = isChecked and accentColor or self.Colors.BG
            checkMark.TextColor3 = isChecked and self.Colors.WHITE or accentColor
            if isChecked then
                selected[opt] = true
            else
                selected[opt] = nil
            end
            if onChange then
                local ok, err = pcall(onChange, selected)
                if not ok then warn("MultiSelect error: " .. tostring(err)) end
            end
        end)
    end

    local totalH = #options * 32 + 36
    row.Size = UDim2.new(1, 0, 0, totalH)
    container.Size = UDim2.new(1, -20, 0, #options * 32)

    return row, function()
        local list = {}
        for k in pairs(selected) do table.insert(list, k) end
        return list
    end
end

-- 5. Keybind
function LZYUI:CreateKeybind(parent, labelText, accentColor, defaultKey, onBind)
    accentColor = accentColor or self.Colors.ACCENT
    defaultKey = defaultKey or "None"

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = self.Colors.WHITE
    row.BorderSizePixel = 0
    row.ZIndex = 55
    row.Parent = parent
    corner(row, UDim.new(0, 10))
    stroke(row, accentColor, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -100, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = self.Colors.TEXT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 56
    lbl.Parent = row

    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 80, 0, 30)
    bindBtn.Position = UDim2.new(1, -90, 0.5, -15)
    bindBtn.BackgroundColor3 = self.Colors.BG
    bindBtn.Text = tostring(defaultKey)
    bindBtn.TextColor3 = self.Colors.TEXT
    bindBtn.TextSize = 12
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.BorderSizePixel = 0
    bindBtn.ZIndex = 56
    bindBtn.Parent = row
    corner(bindBtn, UDim.new(0, 6))
    stroke(bindBtn, accentColor, 1)

    local listening = false
    local currentKey = defaultKey

    bindBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        bindBtn.Text = "..."
        bindBtn.BackgroundColor3 = accentColor
        bindBtn.TextColor3 = self.Colors.WHITE
    end)

    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not listening then return end
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            currentKey = input.KeyCode.Name
            bindBtn.Text = currentKey
            bindBtn.BackgroundColor3 = self.Colors.BG
            bindBtn.TextColor3 = self.Colors.TEXT
            if onBind then
                local ok, err = pcall(onBind, input.KeyCode)
                if not ok then warn("Keybind error: " .. tostring(err)) end
            end
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            listening = false
            bindBtn.Text = tostring(currentKey)
            bindBtn.BackgroundColor3 = self.Colors.BG
            bindBtn.TextColor3 = self.Colors.TEXT
        end
    end)

    row.Destroying:Connect(function()
        if conn then conn:Disconnect() end
    end)

    return row, function() return currentKey end
end

-- 6. NumberBox
function LZYUI:CreateNumberBox(parent, labelText, accentColor, minVal, maxVal, defaultVal, onChange)
    accentColor = accentColor or self.Colors.ACCENT
    minVal = minVal or 0
    maxVal = maxVal or 999999
    defaultVal = defaultVal or minVal

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = self.Colors.WHITE
    row.BorderSizePixel = 0
    row.ZIndex = 55
    row.Parent = parent
    corner(row, UDim.new(0, 10))
    stroke(row, accentColor, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -140, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = self.Colors.TEXT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 56
    lbl.Parent = row

    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 28, 0, 28)
    minusBtn.Position = UDim2.new(1, -118, 0.5, -14)
    minusBtn.BackgroundColor3 = accentColor
    minusBtn.Text = "-"
    minusBtn.TextColor3 = self.Colors.WHITE
    minusBtn.TextSize = 16
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.BorderSizePixel = 0
    minusBtn.ZIndex = 56
    minusBtn.Parent = row
    corner(minusBtn, UDim.new(0, 6))

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 50, 0, 28)
    box.Position = UDim2.new(1, -86, 0.5, -14)
    box.BackgroundColor3 = self.Colors.BG
    box.Text = tostring(defaultVal)
    box.TextColor3 = self.Colors.TEXT
    box.TextSize = 12
    box.Font = Enum.Font.GothamBold
    box.ClearTextOnFocus = false
    box.BorderSizePixel = 0
    box.ZIndex = 56
    box.Parent = row
    corner(box, UDim.new(0, 4))

    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 28, 0, 28)
    plusBtn.Position = UDim2.new(1, -54, 0.5, -14)
    plusBtn.BackgroundColor3 = accentColor
    plusBtn.Text = "+"
    plusBtn.TextColor3 = self.Colors.WHITE
    plusBtn.TextSize = 16
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.BorderSizePixel = 0
    plusBtn.ZIndex = 56
    plusBtn.Parent = row
    corner(plusBtn, UDim.new(0, 6))

    local currentVal = defaultVal

    local function setVal(v)
        currentVal = math.clamp(math.floor(v), minVal, maxVal)
        box.Text = tostring(currentVal)
        if onChange then
            local ok, err = pcall(onChange, currentVal)
            if not ok then warn("NumberBox error: " .. tostring(err)) end
        end
    end

    minusBtn.MouseButton1Click:Connect(function()
        setVal(currentVal - 1)
    end)
    plusBtn.MouseButton1Click:Connect(function()
        setVal(currentVal + 1)
    end)
    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then
            setVal(n)
        else
            box.Text = tostring(currentVal)
        end
    end)

    return row, function() return currentVal end
end

-- 7. ProgressBar
function LZYUI:CreateProgressBar(parent, labelText, accentColor, value)
    accentColor = accentColor or self.Colors.ACCENT
    value = value or 0

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3 = self.Colors.WHITE
    row.BorderSizePixel = 0
    row.ZIndex = 55
    row.Parent = parent
    corner(row, UDim.new(0, 10))
    stroke(row, accentColor, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 0, 20)
    lbl.Position = UDim2.new(0, 14, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = self.Colors.TEXT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 56
    lbl.Parent = row

    local pctLbl = Instance.new("TextLabel")
    pctLbl.Size = UDim2.new(0, 50, 0, 20)
    pctLbl.Position = UDim2.new(1, -58, 0, 4)
    pctLbl.BackgroundTransparency = 1
    pctLbl.Text = tostring(value) .. "%"
    pctLbl.TextColor3 = accentColor
    pctLbl.TextSize = 12
    pctLbl.Font = Enum.Font.GothamBold
    pctLbl.TextXAlignment = Enum.TextXAlignment.Right
    pctLbl.ZIndex = 56
    lbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -28, 0, 6)
    track.Position = UDim2.new(0, 14, 0, 30)
    track.BackgroundColor3 = self.Colors.GRAY
    track.BorderSizePixel = 0
    track.ZIndex = 56
    track.Parent = row
    corner(track, UDim.new(1, 0))

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(value / 100, 0, 1, 0)
    fill.BackgroundColor3 = accentColor
    fill.BorderSizePixel = 0
    fill.ZIndex = 57
    fill.Parent = track
    corner(fill, UDim.new(1, 0))

    local function setProgress(v)
        value = math.clamp(v, 0, 100)
        pctLbl.Text = tostring(math.floor(value)) .. "%"
        tween(fill, {Size = UDim2.new(value / 100, 0, 1, 0)}, 0.3)
    end

    return row, setProgress, function() return value end
end

-- 8. List / Table
function LZYUI:CreateList(parent, height, accentColor)
    accentColor = accentColor or self.Colors.ACCENT
    height = height or 150

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, height)
    card.BackgroundColor3 = self.Colors.WHITE
    card.BorderSizePixel = 0
    card.ZIndex = 54
    card.Parent = parent
    corner(card, UDim.new(0, 14))
    stroke(card, accentColor, 1)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -12, 1, -12)
    scroll.Position = UDim2.new(0, 6, 0, 6)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = accentColor
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ZIndex = 55
    scroll.Parent = card

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local items = {}

    local function addItem(text)
        local item = Instance.new("TextLabel")
        item.Size = UDim2.new(1, 0, 0, 24)
        item.BackgroundColor3 = self.Colors.BG
        item.Text = text
        item.TextColor3 = self.Colors.TEXT
        item.TextSize = 12
        item.Font = Enum.Font.Gotham
        item.TextXAlignment = Enum.TextXAlignment.Left
        item.ZIndex = 56
        item.Parent = scroll
        corner(item, UDim.new(0, 4))
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 8)
        pad.Parent = item
        table.insert(items, item)
        return item
    end

    local function clear()
        for _, item in ipairs(items) do
            item:Destroy()
        end
        items = {}
    end

    return card, {AddItem = addItem, Clear = clear, Items = items}
end

function LZYUI:CreateTable(parent, headers, height, accentColor)
    accentColor = accentColor or self.Colors.ACCENT
    height = height or 180
    headers = headers or {}

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, height)
    card.BackgroundColor3 = self.Colors.WHITE
    card.BorderSizePixel = 0
    card.ZIndex = 54
    card.Parent = parent
    corner(card, UDim.new(0, 14))
    stroke(card, accentColor, 1)

    local headerRow = Instance.new("Frame")
    headerRow.Size = UDim2.new(1, -12, 0, 28)
    headerRow.Position = UDim2.new(0, 6, 0, 6)
    headerRow.BackgroundColor3 = accentColor
    headerRow.BorderSizePixel = 0
    headerRow.ZIndex = 55
    headerRow.Parent = card
    corner(headerRow, UDim.new(0, 6))

    local colCount = #headers
    for i, h in ipairs(headers) do
        local hl = Instance.new("TextLabel")
        hl.Size = UDim2.new(1 / colCount, -4, 1, 0)
        hl.Position = UDim2.new((i-1) / colCount, 2, 0, 0)
        hl.BackgroundTransparency = 1
        hl.Text = h
        hl.TextColor3 = self.Colors.WHITE
        hl.TextSize = 11
        hl.Font = Enum.Font.GothamBold
        hl.ZIndex = 56
        hl.Parent = headerRow
    end

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -12, 1, -40)
    scroll.Position = UDim2.new(0, 6, 0, 36)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = accentColor
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ZIndex = 55
    scroll.Parent = card

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local rows = {}

    local function addRow(data)
        data = data or {}
        local rowFrame = Instance.new("Frame")
        rowFrame.Size = UDim2.new(1, 0, 0, 24)
        rowFrame.BackgroundColor3 = self.Colors.BG
        rowFrame.BorderSizePixel = 0
        rowFrame.ZIndex = 56
        rowFrame.Parent = scroll
        corner(rowFrame, UDim.new(0, 4))

        for i = 1, colCount do
            local cell = Instance.new("TextLabel")
            cell.Size = UDim2.new(1 / colCount, -4, 1, 0)
            cell.Position = UDim2.new((i-1) / colCount, 2, 0, 0)
            cell.BackgroundTransparency = 1
            cell.Text = tostring(data[i] or "")
            cell.TextColor3 = self.Colors.TEXT
            cell.TextSize = 11
            cell.Font = Enum.Font.Gotham
            cell.TextXAlignment = Enum.TextXAlignment.Left
            cell.ZIndex = 57
            cell.Parent = rowFrame
        end

        table.insert(rows, rowFrame)
        return rowFrame
    end

    local function clear()
        for _, r in ipairs(rows) do
            r:Destroy()
        end
        rows = {}
    end

    return card, {AddRow = addRow, Clear = clear, Rows = rows}
end

-- 9. Collapsible
function LZYUI:CreateCollapsible(parent, title, accentColor)
    accentColor = accentColor or self.Colors.ACCENT

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundColor3 = self.Colors.WHITE
    container.BorderSizePixel = 0
    container.ZIndex = 54
    container.Parent = parent
    corner(container, UDim.new(0, 12))
    stroke(container, accentColor, 1)

    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = accentColor
    header.Text = ""
    header.BorderSizePixel = 0
    header.ZIndex = 55
    header.Parent = container
    corner(header, UDim.new(0, 12))

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -50, 1, 0)
    titleLbl.Position = UDim2.new(0, 14, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = self.Colors.WHITE
    titleLbl.TextSize = 14
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 56
    titleLbl.Parent = header

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 30, 1, 0)
    arrow.Position = UDim2.new(1, -36, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "v"
    arrow.TextColor3 = self.Colors.WHITE
    arrow.TextSize = 14
    arrow.Font = Enum.Font.GothamBold
    arrow.ZIndex = 56
    arrow.Parent = header

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -12, 0, 0)
    content.Position = UDim2.new(0, 6, 0, 44)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.ZIndex = 55
    content.Parent = container

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content

    local expanded = false

    local function updateSize()
        local h = contentLayout.AbsoluteContentSize.Y
        content.Size = UDim2.new(1, -12, 0, h)
        if expanded then
            container.Size = UDim2.new(1, 0, 0, 48 + h)
        else
            container.Size = UDim2.new(1, 0, 0, 40)
        end
    end

    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

    header.MouseButton1Click:Connect(function()
        expanded = not expanded
        if expanded then
            tween(arrow, {Rotation = 180}, 0.2)
            updateSize()
        else
            tween(arrow, {Rotation = 0}, 0.2)
            container.Size = UDim2.new(1, 0, 0, 40)
        end
    end)

    return container, content
end

-- 10. SubTabs
function LZYUI:CreateSubTabs(parent, tabNames, accentColor)
    accentColor = accentColor or self.Colors.ACCENT
    tabNames = tabNames or {}

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 200)
    container.BackgroundColor3 = self.Colors.WHITE
    container.BorderSizePixel = 0
    container.ZIndex = 54
    container.Parent = parent
    corner(container, UDim.new(0, 14))
    stroke(container, accentColor, 1)

    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -12, 0, 34)
    tabBar.Position = UDim2.new(0, 6, 0, 6)
    tabBar.BackgroundTransparency = 1
    tabBar.ZIndex = 55
    tabBar.Parent = container

    local tabBarLayout = Instance.new("UIListLayout")
    tabBarLayout.FillDirection = Enum.FillDirection.Horizontal
    tabBarLayout.Padding = UDim.new(0, 4)
    tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabBarLayout.Parent = tabBar

    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -12, 1, -46)
    contentContainer.Position = UDim2.new(0, 6, 0, 42)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ZIndex = 55
    contentContainer.Parent = container

    local tabs = {}
    local selectedIdx = 1

    for i, name in ipairs(tabNames) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1 / #tabNames, -4, 1, 0)
        tabBtn.BackgroundColor3 = (i == 1) and accentColor or self.Colors.BG
        tabBtn.Text = name
        tabBtn.TextColor3 = (i == 1) and self.Colors.WHITE or self.Colors.TEXT
        tabBtn.TextSize = 11
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.BorderSizePixel = 0
        tabBtn.LayoutOrder = i
        tabBtn.ZIndex = 56
        tabBtn.Parent = tabBar
        corner(tabBtn, UDim.new(0, 6))

        local tabContent = Instance.new("Frame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = (i == 1)
        tabContent.ZIndex = 55
        tabContent.Parent = contentContainer

        local tabLayout = Instance.new("UIListLayout")
        tabLayout.Padding = UDim.new(0, 6)
        tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabLayout.Parent = tabContent

        table.insert(tabs, {Button = tabBtn, Content = tabContent, Name = name})

        tabBtn.MouseButton1Click:Connect(function()
            if selectedIdx == i then return end
            tabs[selectedIdx].Button.BackgroundColor3 = self.Colors.BG
            tabs[selectedIdx].Button.TextColor3 = self.Colors.TEXT
            tabs[selectedIdx].Content.Visible = false

            tabBtn.BackgroundColor3 = accentColor
            tabBtn.TextColor3 = self.Colors.WHITE
            tabContent.Visible = true
            selectedIdx = i
        end)
    end

    return container, tabs
end

-- 11. ImageLabel
function LZYUI:CreateImageLabel(parent, imageId, size, accentColor)
    accentColor = accentColor or self.Colors.ACCENT
    size = size or 80

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, size + 16)
    row.BackgroundColor3 = self.Colors.WHITE
    row.BorderSizePixel = 0
    row.ZIndex = 55
    row.Parent = parent
    corner(row, UDim.new(0, 10))
    stroke(row, accentColor, 1)

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, size, 0, size)
    img.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
    img.BackgroundColor3 = self.Colors.BG
    img.Image = imageId or ""
    img.BorderSizePixel = 0
    img.ZIndex = 56
    img.Parent = row
    corner(img, UDim.new(1, 0))

    return row, img
end

-- 12. Console
function LZYUI:CreateConsole(parent, height, accentColor)
    accentColor = accentColor or self.Colors.ACCENT
    height = height or 180

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, height)
    card.BackgroundColor3 = self.Colors.WHITE
    card.BorderSizePixel = 0
    card.ZIndex = 54
    card.Parent = parent
    corner(card, UDim.new(0, 14))
    stroke(card, accentColor, 1)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -12, 1, -40)
    scroll.Position = UDim2.new(0, 6, 0, 34)
    scroll.BackgroundColor3 = self.Colors.DARK
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = accentColor
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ZIndex = 55
    scroll.Parent = card
    corner(scroll, UDim.new(0, 8))

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -12, 0, 24)
    titleLbl.Position = UDim2.new(0, 6, 0, 6)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "Console"
    titleLbl.TextColor3 = self.Colors.TEXT
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 55
    titleLbl.Parent = card

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 50, 0, 22)
    clearBtn.Position = UDim2.new(1, -58, 0, 6)
    clearBtn.BackgroundColor3 = accentColor
    clearBtn.Text = "Clear"
    clearBtn.TextColor3 = self.Colors.WHITE
    clearBtn.TextSize = 10
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.BorderSizePixel = 0
    clearBtn.ZIndex = 55
    clearBtn.Parent = card
    corner(clearBtn, UDim.new(0, 4))

    local logs = {}
    local colors = {
        info = Color3.fromRGB(200, 200, 200),
        warn = Color3.fromRGB(255, 200, 100),
        error = Color3.fromRGB(255, 100, 100),
        success = Color3.fromRGB(100, 255, 150),
    }

    local function log(text, level)
        level = level or "info"
        local line = Instance.new("TextLabel")
        line.Size = UDim2.new(1, -8, 0, 18)
        line.BackgroundTransparency = 1
        line.Text = tostring(text)
        line.TextColor3 = colors[level] or colors.info
        line.TextSize = 11
        line.Font = Enum.Font.Code
        line.TextXAlignment = Enum.TextXAlignment.Left
        line.ZIndex = 56
        line.Parent = scroll
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 6)
        pad.Parent = line
        table.insert(logs, line)
        if #logs > 100 then
            logs[1]:Destroy()
            table.remove(logs, 1)
        end
        scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y)
        return line
    end

    local function clear()
        for _, l in ipairs(logs) do
            l:Destroy()
        end
        logs = {}
    end

    clearBtn.MouseButton1Click:Connect(clear)

    return card, {Log = log, Clear = clear, Logs = logs}
end

-- 14. Modal Dialog
function LZYUI:CreateModal(title, text, buttons, onResult)
    buttons = buttons or {"OK", "Cancel"}

    local modal = Instance.new("Frame")
    modal.Name = "ModalOverlay"
    modal.Size = UDim2.new(1, 0, 1, 0)
    modal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    modal.BackgroundTransparency = 0.5
    modal.BorderSizePixel = 0
    modal.ZIndex = 300
    modal.Parent = self.ScreenGui

    local dialog = Instance.new("Frame")
    dialog.Size = UDim2.new(0, 320, 0, 0)
    dialog.Position = UDim2.new(0.5, -160, 0.5, 0)
    dialog.BackgroundColor3 = self.Colors.WHITE
    dialog.BorderSizePixel = 0
    dialog.ZIndex = 301
    dialog.Parent = modal
    corner(dialog, UDim.new(0, 16))
    shadow(dialog, 10, 0.75)
    stroke(dialog, self.Colors.ACCENT, 1)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -20, 0, 26)
    titleLbl.Position = UDim2.new(0, 10, 0, 12)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title or "Notice"
    titleLbl.TextColor3 = self.Colors.TEXT
    titleLbl.TextSize = 16
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 302
    titleLbl.Parent = dialog

    local textLbl = Instance.new("TextLabel")
    textLbl.Size = UDim2.new(1, -20, 0, 0)
    textLbl.Position = UDim2.new(0, 10, 0, 44)
    textLbl.BackgroundTransparency = 1
    textLbl.Text = text or ""
    textLbl.TextColor3 = self.Colors.TEXT2
    textLbl.TextSize = 13
    textLbl.Font = Enum.Font.Gotham
    textLbl.TextXAlignment = Enum.TextXAlignment.Left
    textLbl.TextWrapped = true
    textLbl.ZIndex = 302
    textLbl.Parent = dialog

    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, -20, 0, 36)
    btnContainer.Position = UDim2.new(0, 10, 0, 0)
    btnContainer.BackgroundTransparency = 1
    btnContainer.ZIndex = 302
    btnContainer.Parent = dialog

    local btnLayout = Instance.new("UIListLayout")
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    btnLayout.Padding = UDim.new(0, 8)
    btnLayout.Parent = btnContainer

    local textHeight = math.max(40, textLbl.TextBounds.Y)
    textLbl.Size = UDim2.new(1, -20, 0, textHeight)
    btnContainer.Position = UDim2.new(0, 10, 0, 50 + textHeight)
    dialog.Size = UDim2.new(0, 320, 0, 100 + textHeight)
    dialog.Position = UDim2.new(0.5, -160, 0.5, -(100 + textHeight) / 2)

    for i, btnText in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 80, 0, 32)
        btn.BackgroundColor3 = (i == 1) and self.Colors.ACCENT or self.Colors.BG
        btn.Text = btnText
        btn.TextColor3 = (i == 1) and self.Colors.WHITE or self.Colors.TEXT
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.ZIndex = 303
        btn.Parent = btnContainer
        corner(btn, UDim.new(0, 8))

        btn.MouseButton1Click:Connect(function()
            tween(modal, {BackgroundTransparency = 1}, 0.15)
            tween(dialog, {Size = UDim2.new(0, 300, 0, dialog.AbsoluteSize.Y - 20)}, 0.15)
            task.wait(0.15)
            modal:Destroy()
            if onResult then
                local ok, err = pcall(onResult, btnText, i)
                if not ok then warn("Modal error: " .. tostring(err)) end
            end
        end)
    end

    tween(modal, {BackgroundTransparency = 0.5}, 0.2)
    tween(dialog, {Size = UDim2.new(0, 320, 0, 100 + textHeight)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    return modal
end

-- 16. CopyButton
function LZYUI:CreateCopyButton(parent, textToCopy, labelText, accentColor)
    accentColor = accentColor or self.Colors.ACCENT
    labelText = labelText or "Copy"

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = self.Colors.BG
    btn.Text = labelText
    btn.TextColor3 = self.Colors.TEXT
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.ZIndex = 55
    btn.Parent = parent
    corner(btn, UDim.new(0, 8))
    stroke(btn, accentColor, 1)

    btn.MouseButton1Click:Connect(function()
        local text = type(textToCopy) == "function" and textToCopy() or tostring(textToCopy)
        if setclipboard then
            setclipboard(text)
            btn.Text = "Copied!"
            btn.BackgroundColor3 = accentColor
            btn.TextColor3 = self.Colors.WHITE
            task.delay(1.5, function()
                btn.Text = labelText
                btn.BackgroundColor3 = self.Colors.BG
                btn.TextColor3 = self.Colors.TEXT
            end)
        else
            warn("Clipboard not available")
        end
    end)

    return btn
end

-- 17. RangeSlider
function LZYUI:CreateRangeSlider(parent, labelText, accentColor, minVal, maxVal, defaultMin, defaultMax, onChange)
    accentColor = accentColor or self.Colors.ACCENT
    minVal = minVal or 0
    maxVal = maxVal or 100
    defaultMin = defaultMin or minVal
    defaultMax = defaultMax or maxVal

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 70)
    row.BackgroundColor3 = self.Colors.WHITE
    row.BorderSizePixel = 0
    row.ZIndex = 55
    row.Parent = parent
    corner(row, UDim.new(0, 10))
    stroke(row, accentColor, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 0, 22)
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
    valLbl.Size = UDim2.new(0, 80, 0, 22)
    valLbl.Position = UDim2.new(1, -88, 0, 6)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(defaultMin) .. " - " .. tostring(defaultMax)
    valLbl.TextColor3 = accentColor
    valLbl.TextSize = 12
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 56
    valLbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -28, 0, 5)
    track.Position = UDim2.new(0, 14, 0, 42)
    track.BackgroundColor3 = self.Colors.GRAY
    track.BorderSizePixel = 0
    track.ZIndex = 56
    track.Parent = row
    corner(track, UDim.new(1, 0))

    local fill = Instance.new("Frame")
    local relMin = (defaultMin - minVal) / (maxVal - minVal)
    local relMax = (defaultMax - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(relMax - relMin, 0, 1, 0)
    fill.Position = UDim2.new(relMin, 0, 0, 0)
    fill.BackgroundColor3 = accentColor
    fill.BorderSizePixel = 0
    fill.ZIndex = 57
    fill.Parent = track
    corner(fill, UDim.new(1, 0))

    local knob1 = Instance.new("TextButton")
    knob1.Size = UDim2.new(0, 16, 0, 16)
    knob1.Position = UDim2.new(relMin, -8, 0.5, -8)
    knob1.BackgroundColor3 = self.Colors.WHITE
    knob1.Text = ""
    knob1.BorderSizePixel = 0
    knob1.ZIndex = 58
    knob1.Parent = track
    corner(knob1, UDim.new(1, 0))
    local ks1 = Instance.new("UIStroke")
    ks1.Color = accentColor
    ks1.Thickness = 2
    ks1.Parent = knob1

    local knob2 = Instance.new("TextButton")
    knob2.Size = UDim2.new(0, 16, 0, 16)
    knob2.Position = UDim2.new(relMax, -8, 0.5, -8)
    knob2.BackgroundColor3 = self.Colors.WHITE
    knob2.Text = ""
    knob2.BorderSizePixel = 0
    knob2.ZIndex = 58
    knob2.Parent = track
    corner(knob2, UDim.new(1, 0))
    local ks2 = Instance.new("UIStroke")
    ks2.Color = accentColor
    ks2.Thickness = 2
    ks2.Parent = knob2

    local dragging1 = false
    local dragging2 = false
    local currentMin = defaultMin
    local currentMax = defaultMax

    local function updateFromPos(px, isMin)
        local trackAbs = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local relPos = math.clamp((px - trackAbs) / trackSize, 0, 1)
        local val = math.floor(minVal + relPos * (maxVal - minVal))

        if isMin then
            currentMin = math.min(val, currentMax)
            local r = (currentMin - minVal) / (maxVal - minVal)
            knob1.Position = UDim2.new(r, -8, 0.5, -8)
        else
            currentMax = math.max(val, currentMin)
            local r = (currentMax - minVal) / (maxVal - minVal)
            knob2.Position = UDim2.new(r, -8, 0.5, -8)
        end

        local r1 = (currentMin - minVal) / (maxVal - minVal)
        local r2 = (currentMax - minVal) / (maxVal - minVal)
        fill.Position = UDim2.new(r1, 0, 0, 0)
        fill.Size = UDim2.new(r2 - r1, 0, 1, 0)
        valLbl.Text = tostring(currentMin) .. " - " .. tostring(currentMax)

        if onChange then
            local ok, err = pcall(onChange, currentMin, currentMax)
            if not ok then warn("RangeSlider error: " .. tostring(err)) end
        end
    end

    knob1.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging1 = true
        end
    end)
    knob2.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging2 = true
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if (dragging1 or dragging2) and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromPos(input.Position.X, dragging1)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging1 = false
            dragging2 = false
        end
    end)

    return row, function() return currentMin, currentMax end
end

-- 20. ToggleGroup
function LZYUI:CreateToggleGroup(parent, labelText, accentColor, options, defaultIdx, onChange)
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
    lbl.Size = UDim2.new(1, -20, 0, 22)
    lbl.Position = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = self.Colors.TEXT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 56
    lbl.Parent = row

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 28)
    container.Position = UDim2.new(0, 10, 0, 30)
    container.BackgroundTransparency = 1
    container.ZIndex = 56
    container.Parent = row

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    local selectedIdx = defaultIdx
    local btns = {}

    for i, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1 / #options, -6, 1, 0)
        btn.BackgroundColor3 = (i == defaultIdx) and accentColor or self.Colors.BG
        btn.Text = opt
        btn.TextColor3 = (i == defaultIdx) and self.Colors.WHITE or self.Colors.TEXT
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.LayoutOrder = i
        btn.ZIndex = 57
        btn.Parent = container
        corner(btn, UDim.new(0, 6))

        btn.MouseButton1Click:Connect(function()
            if selectedIdx == i then return end
            btns[selectedIdx].BackgroundColor3 = self.Colors.BG
            btns[selectedIdx].TextColor3 = self.Colors.TEXT
            btn.BackgroundColor3 = accentColor
            btn.TextColor3 = self.Colors.WHITE
            selectedIdx = i
            if onChange then
                local ok, err = pcall(onChange, opt, i)
                if not ok then warn("ToggleGroup error: " .. tostring(err)) end
            end
        end)

        btns[i] = btn
    end

    local totalH = 30 + 28 + 10
    row.Size = UDim2.new(1, 0, 0, totalH)

    return row, function() return selectedIdx, options[selectedIdx] end
end

-- ============================================
-- WINDOW CREATION
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
    self.Width = config.Width or 0.70
    self.Height = self.Width * (420 / 320)
    self.Tabs = {}
    self.SelectedTab = 1
    self.IsOpen = false
    self.Easing = config.Easing or "Default"

    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = self.Title .. "_UI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    self.ScreenGui.Parent = playerGui

    -- 22. UI Scale
    if config.UIScale then
        local uiScale = Instance.new("UIScale")
        uiScale.Scale = config.UIScale
        uiScale.Parent = self.ScreenGui
        self.UIScale = uiScale
    end

    -- Create Orb (no breathing animation)
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

    -- Create Panel
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

    -- 23. Blur Background
    if config.BlurBackground then
        self.BlurFrame = Instance.new("Frame")
        self.BlurFrame.Name = "BlurBackground"
        self.BlurFrame.Size = UDim2.new(1, 0, 1, 0)
        self.BlurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        self.BlurFrame.BackgroundTransparency = 1
        self.BlurFrame.BorderSizePixel = 0
        self.BlurFrame.ZIndex = 49
        self.BlurFrame.Visible = false
        self.BlurFrame.Parent = self.ScreenGui
    end

    -- Inner frame
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

    -- Top bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 50)
    topBar.BackgroundColor3 = self.Colors.PRIMARY
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 52
    topBar.Parent = inner
    corner(topBar, UDim.new(0, 20))

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

    -- Shrink button
    local shrinkBtn = Instance.new("TextButton")
    shrinkBtn.Name = "ShrinkBtn"
    shrinkBtn.Size = UDim2.new(0, 32, 0, 32)
    shrinkBtn.Position = UDim2.new(1, -76, 0, 9)
    shrinkBtn.BackgroundColor3 = self.Colors.ACCENT
    shrinkBtn.Text = "-"
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

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -40, 0, 9)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
    closeBtn.Text = "x"
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

    -- Body
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Size = UDim2.new(1, 0, 1, -50)
    body.Position = UDim2.new(0, 0, 0, 50)
    body.BackgroundTransparency = 1
    body.ClipsDescendants = true
    body.ZIndex = 51
    body.Parent = inner

    -- Navigation
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

    -- Content area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1 - 0.26 - 0.02, 0, 1, -24)
    content.Position = UDim2.new(0.26 + 0.02, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.ZIndex = 52
    content.Parent = body

    self.Content = content

    -- Setup drag
    self:_SetupDrag()

    return self
end

-- ============================================
-- DRAG SYSTEM
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
-- WINDOW CONTROL
-- ============================================
function LZYUI:Show()
    if self.IsOpen then return end
    self.IsOpen = true
    self.Orb.Visible = false
    self.Panel.Visible = true

    if self.BlurFrame then
        self.BlurFrame.Visible = true
        tween(self.BlurFrame, {BackgroundTransparency = 0.6}, 0.2)
    end

    local targetX = (1 - self.Width) / 2
    local targetY = (1 - self.Height) / 2 - 0.05

    self.Panel.Size = UDim2.new(self.Width * 0.85, 0, self.Height * 0.85, 0)
    self.Panel.Position = UDim2.new(targetX + self.Width * 0.075, 0, targetY + self.Height * 0.075, 0)
    self.Panel.BackgroundTransparency = 1
    self.Inner.BackgroundTransparency = 0.4

    local ease = self.EasingPresets[self.Easing] or self.EasingPresets.Default
    tween(self.Panel, {
        Size = UDim2.new(self.Width, 0, self.Height, 0),
        Position = UDim2.new(targetX, 0, targetY, 0),
        BackgroundTransparency = 1,
    }, 0.25, ease[1], ease[2])

    tween(self.Inner, {
        BackgroundTransparency = 0,
    }, 0.25, ease[1], ease[2])
end

function LZYUI:Hide()
    if not self.IsOpen then return end
    self.IsOpen = false

    local targetX = (1 - self.Width) / 2
    local targetY = (1 - self.Height) / 2 - 0.05

    local ease = self.EasingPresets[self.Easing] or self.EasingPresets.Default
    tween(self.Panel, {
        Size = UDim2.new(self.Width * 0.85, 0, self.Height * 0.85, 0),
        Position = UDim2.new(targetX + self.Width * 0.075, 0, targetY + self.Height * 0.075, 0),
    }, 0.2, ease[1], ease[2])

    tween(self.Inner, {
        BackgroundTransparency = 0.4,
    }, 0.2, ease[1], ease[2])

    if self.BlurFrame then
        tween(self.BlurFrame, {BackgroundTransparency = 1}, 0.2)
    end

    task.wait(0.2)
    self.Panel.Visible = false
    if self.BlurFrame then
        self.BlurFrame.Visible = false
    end
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
