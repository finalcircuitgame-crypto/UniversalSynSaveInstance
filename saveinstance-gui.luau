--[[
    Universal Syn Save Instance - Executor GUI
    Modern dark interface for configuring the existing USSI save engine.

    Usage:
        loadstring(game:HttpGet("https://raw.githubusercontent.com/finalcircuitgame-crypto/UniversalSynSaveInstance/main/saveinstance-gui.luau"))()

    This is an unofficial UI wrapper. The save engine remains in saveinstance.luau.
    UniversalSynSaveInstance https://discord.gg/wx4ThpAsmw
]]

local REPO = "https://raw.githubusercontent.com/finalcircuitgame-crypto/UniversalSynSaveInstance/main/"
local GUI_NAME = "USSI_Executor_GUI"
local GUI_VERSION = "v1.12.0"

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Persist GUI settings between executions using the executor's file API.
local CONFIG_FILE = "USSI_Settings.json"
local SavedSettings = {}

local function loadSavedSettings()
    if type(readfile) ~= "function" then
        warn("[USSI GUI] readfile is unavailable; settings will not persist.")
        return
    end

    local ok, contents = pcall(readfile, CONFIG_FILE)
    if not ok or type(contents) ~= "string" or contents == "" then return end

    local decoded, data = pcall(function()
        return HttpService:JSONDecode(contents)
    end)
    if decoded and type(data) == "table" then
        SavedSettings = data
    else
        warn("[USSI GUI] Settings file was invalid; using defaults.")
    end
end

local function saveSavedSettings()
    if type(writefile) ~= "function" then return end

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(SavedSettings)
    end)
    if not ok then
        warn("[USSI GUI] Could not encode settings: " .. tostring(encoded))
        return
    end

    local written, err = pcall(writefile, CONFIG_FILE, encoded)
    if not written then
        warn("[USSI GUI] Could not save settings: " .. tostring(err))
    end
end

local function getSavedSetting(key, fallback, expectedType)
    local value = SavedSettings[key]
    if type(value) == (expectedType or type(fallback)) then
        return value
    end
    return fallback
end

local function setSavedSetting(key, value)
    SavedSettings[key] = value
    saveSavedSettings()
end

loadSavedSettings()

local Existing = nil
local GUI_PARENT = CoreGui

pcall(function()
    if gethui then GUI_PARENT = gethui() end
    Existing = GUI_PARENT:FindFirstChild(GUI_NAME)
    if Existing then Existing:Destroy() end
end)

local StartupGui, StartupCard, StartupTitle, StartupDetail, StartupFill

local function destroyStartupScreen()
    if not StartupGui then return end
    local gui = StartupGui
    StartupGui = nil
    pcall(function()
        local fade = TweenService:Create(
            StartupCard,
            TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.46) }
        )
        fade:Play()
        task.delay(0.24, function()
            if gui and gui.Parent then gui:Destroy() end
        end)
    end)
end

local function createStartupScreen()
    local ok = pcall(function()
        StartupGui = Instance.new("ScreenGui")
        StartupGui.Name = "USSI_LoadingScreen"
        StartupGui.IgnoreGuiInset = true
        StartupGui.ResetOnSpawn = false
        StartupGui.DisplayOrder = 1999999999
        StartupGui.Parent = GUI_PARENT

        StartupCard = Instance.new("Frame")
        StartupCard.AnchorPoint = Vector2.new(0.5, 0.5)
        StartupCard.Position = UDim2.fromScale(0.5, 0.54)
        StartupCard.Size = UDim2.fromOffset(430, 154)
        StartupCard.BackgroundColor3 = Color3.fromRGB(17, 20, 29)
        StartupCard.BorderSizePixel = 0
        StartupCard.Parent = StartupGui

        local scale = Instance.new("UIScale")
        scale.Scale = 0.94
        scale.Parent = StartupCard
        TweenService:Create(scale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Scale = 1
        }):Play()

        local radius = Instance.new("UICorner")
        radius.CornerRadius = UDim.new(0, 14)
        radius.Parent = StartupCard

        local outline = Instance.new("UIStroke")
        outline.Color = Color3.fromRGB(62, 65, 91)
        outline.Transparency = 0.12
        outline.Parent = StartupCard

        local accent = Instance.new("Frame")
        accent.BackgroundColor3 = Color3.fromRGB(125, 108, 255)
        accent.BorderSizePixel = 0
        accent.Size = UDim2.new(1, 0, 0, 3)
        accent.Parent = StartupCard

        local badge = Instance.new("TextLabel")
        badge.BackgroundColor3 = Color3.fromRGB(43, 39, 75)
        badge.Position = UDim2.fromOffset(20, 20)
        badge.Size = UDim2.fromOffset(44, 30)
        badge.Font = Enum.Font.GothamBold
        badge.Text = "USSI"
        badge.TextColor3 = Color3.fromRGB(202, 195, 255)
        badge.TextSize = 12
        badge.Parent = StartupCard
        local badgeCorner = Instance.new("UICorner")
        badgeCorner.CornerRadius = UDim.new(0, 8)
        badgeCorner.Parent = badge

        local heading = Instance.new("TextLabel")
        heading.BackgroundTransparency = 1
        heading.Position = UDim2.fromOffset(76, 19)
        heading.Size = UDim2.new(1, -96, 0, 15)
        heading.Font = Enum.Font.GothamBold
        heading.Text = "UNIVERSAL SYN SAVE INSTANCE"
        heading.TextColor3 = Color3.fromRGB(147, 153, 174)
        heading.TextSize = 9
        heading.TextXAlignment = Enum.TextXAlignment.Left
        heading.Parent = StartupCard

        StartupTitle = Instance.new("TextLabel")
        StartupTitle.BackgroundTransparency = 1
        StartupTitle.Position = UDim2.fromOffset(76, 38)
        StartupTitle.Size = UDim2.new(1, -96, 0, 24)
        StartupTitle.Font = Enum.Font.GothamSemibold
        StartupTitle.Text = "Starting USSI..."
        StartupTitle.TextColor3 = Color3.fromRGB(245, 246, 252)
        StartupTitle.TextSize = 16
        StartupTitle.TextXAlignment = Enum.TextXAlignment.Left
        StartupTitle.Parent = StartupCard

        StartupDetail = Instance.new("TextLabel")
        StartupDetail.BackgroundTransparency = 1
        StartupDetail.Position = UDim2.fromOffset(20, 78)
        StartupDetail.Size = UDim2.new(1, -40, 0, 18)
        StartupDetail.Font = Enum.Font.Gotham
        StartupDetail.Text = "Preparing interface and save engine..."
        StartupDetail.TextColor3 = Color3.fromRGB(153, 160, 178)
        StartupDetail.TextSize = 10
        StartupDetail.TextXAlignment = Enum.TextXAlignment.Left
        StartupDetail.TextTruncate = Enum.TextTruncate.AtEnd
        StartupDetail.Parent = StartupCard

        local track = Instance.new("Frame")
        track.Position = UDim2.fromOffset(20, 111)
        track.Size = UDim2.new(1, -40, 0, 5)
        track.BackgroundColor3 = Color3.fromRGB(42, 46, 61)
        track.BorderSizePixel = 0
        track.ClipsDescendants = true
        track.Parent = StartupCard
        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(1, 0)
        trackCorner.Parent = track

        StartupFill = Instance.new("Frame")
        StartupFill.Size = UDim2.new(0.12, 0, 1, 0)
        StartupFill.BackgroundColor3 = Color3.fromRGB(125, 108, 255)
        StartupFill.BorderSizePixel = 0
        StartupFill.Parent = track
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = StartupFill

        local footer = Instance.new("TextLabel")
        footer.BackgroundTransparency = 1
        footer.Position = UDim2.fromOffset(20, 123)
        footer.Size = UDim2.new(1, -40, 0, 16)
        footer.Font = Enum.Font.GothamMedium
        footer.Text = GUI_VERSION .. "  •  LOADING"
        footer.TextColor3 = Color3.fromRGB(102, 111, 132)
        footer.TextSize = 8
        footer.TextXAlignment = Enum.TextXAlignment.Left
        footer.Parent = StartupCard
    end)

    if not ok then
        if StartupGui then StartupGui:Destroy() end
        StartupGui = nil
        return
    end
end

local function updateStartupProgress(progress)
    if not StartupFill then return end
    local amount = math.clamp(progress, 0, 1)
    TweenService:Create(
        StartupFill,
        TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.new(amount, 0, 1, 0) }
    ):Play()
end

createStartupScreen()

local function setStartupStatus(title, detail, progress)
    if not StartupGui then return end
    StartupTitle.Text = title
    StartupDetail.Text = detail
    updateStartupProgress(progress)
end

local function loadEngine()
    setStartupStatus("Downloading save engine", "Fetching saveinstance.luau from GitHub...", 0.22)
    local source = game:HttpGet(REPO .. "saveinstance.luau?v=" .. GUI_VERSION, true)
    assert(type(source) == "string" and #source > 1000, "GitHub returned an empty or incomplete save engine.")

    setStartupStatus("Compiling save engine", string.format("Downloaded %.1f KB • compiling serializer...", #source / 1024), 0.58)
    local chunk, err = loadstring(source, "USSI")
    assert(chunk, err)

    setStartupStatus("Initializing engine", "Preparing serializer and compatibility checks...", 0.82)
    local engine = chunk()
    assert(type(engine) == "function", "Save engine did not return a function.")
    setStartupStatus("Building interface", "Engine ready • creating the USSI workspace...", 0.94)
    return engine
end

local ok, synsaveinstance = pcall(loadEngine)
if not ok then
    warn("[USSI GUI] Could not load save engine: " .. tostring(synsaveinstance))
    setStartupStatus("Could not start USSI", string.sub(tostring(synsaveinstance), 1, 95), 1)
    task.delay(5, destroyStartupScreen)
    return
end

local Theme = {
    Background = Color3.fromRGB(15, 17, 23),
    Surface = Color3.fromRGB(22, 25, 33),
    Surface2 = Color3.fromRGB(29, 33, 43),
    Border = Color3.fromRGB(43, 48, 61),
    Text = Color3.fromRGB(238, 241, 248),
    Muted = Color3.fromRGB(145, 153, 170),
    Accent = Color3.fromRGB(119, 104, 255),
    AccentHover = Color3.fromRGB(139, 126, 255),
    Green = Color3.fromRGB(74, 205, 142),
    Red = Color3.fromRGB(239, 92, 106),
}

local ThemePresets = {
    ["Midnight Violet"] = {
        Background = Color3.fromRGB(15, 17, 23), Surface = Color3.fromRGB(22, 25, 33),
        Surface2 = Color3.fromRGB(29, 33, 43), Border = Color3.fromRGB(43, 48, 61),
        Text = Color3.fromRGB(238, 241, 248), Muted = Color3.fromRGB(145, 153, 170),
        Accent = Color3.fromRGB(119, 104, 255), AccentHover = Color3.fromRGB(139, 126, 255),
        Green = Color3.fromRGB(74, 205, 142), Red = Color3.fromRGB(239, 92, 106),
    },
    ["Ocean Blue"] = {
        Background = Color3.fromRGB(12, 19, 28), Surface = Color3.fromRGB(18, 30, 43),
        Surface2 = Color3.fromRGB(25, 42, 59), Border = Color3.fromRGB(42, 65, 84),
        Text = Color3.fromRGB(235, 245, 252), Muted = Color3.fromRGB(143, 167, 187),
        Accent = Color3.fromRGB(58, 160, 235), AccentHover = Color3.fromRGB(91, 184, 250),
        Green = Color3.fromRGB(75, 211, 163), Red = Color3.fromRGB(244, 105, 117),
    },
    ["Emerald"] = {
        Background = Color3.fromRGB(13, 21, 19), Surface = Color3.fromRGB(20, 31, 28),
        Surface2 = Color3.fromRGB(28, 44, 39), Border = Color3.fromRGB(47, 70, 60),
        Text = Color3.fromRGB(237, 246, 241), Muted = Color3.fromRGB(150, 174, 161),
        Accent = Color3.fromRGB(50, 183, 129), AccentHover = Color3.fromRGB(80, 211, 157),
        Green = Color3.fromRGB(82, 214, 145), Red = Color3.fromRGB(237, 101, 112),
    },
    ["Rose"] = {
        Background = Color3.fromRGB(25, 16, 23), Surface = Color3.fromRGB(36, 23, 33),
        Surface2 = Color3.fromRGB(49, 31, 45), Border = Color3.fromRGB(75, 46, 65),
        Text = Color3.fromRGB(250, 239, 246), Muted = Color3.fromRGB(186, 151, 172),
        Accent = Color3.fromRGB(219, 91, 153), AccentHover = Color3.fromRGB(241, 123, 179),
        Green = Color3.fromRGB(87, 204, 144), Red = Color3.fromRGB(245, 105, 130),
    },
    ["Amber"] = {
        Background = Color3.fromRGB(24, 20, 14), Surface = Color3.fromRGB(36, 29, 19),
        Surface2 = Color3.fromRGB(49, 39, 25), Border = Color3.fromRGB(77, 59, 35),
        Text = Color3.fromRGB(250, 244, 231), Muted = Color3.fromRGB(187, 169, 137),
        Accent = Color3.fromRGB(218, 153, 57), AccentHover = Color3.fromRGB(240, 183, 86),
        Green = Color3.fromRGB(112, 204, 119), Red = Color3.fromRGB(236, 102, 91),
    },
}

local CurrentThemeName = getSavedSetting("Theme preset", "Midnight Violet", "string")
if not ThemePresets[CurrentThemeName] then CurrentThemeName = "Midnight Violet" end
local ThemeBindings = setmetatable({}, { __mode = "k" })
local DensityBindings = {}
local CompactMode = getSavedSetting("Compact layout", false, "boolean")
local ReducedMotion = getSavedSetting("Reduced motion", false, "boolean")

local function registerDensity(object, property, normalValue, compactValue)
    DensityBindings[#DensityBindings + 1] = {
        Object = object, Property = property, Normal = normalValue, Compact = compactValue
    }
    object[property] = CompactMode and compactValue or normalValue
end

local function applyDensity()
    for _, binding in ipairs(DensityBindings) do
        if binding.Object and binding.Object.Parent then
            binding.Object[binding.Property] = CompactMode and binding.Compact or binding.Normal
        end
    end
end

local function create(className, props, parent)
    local object = Instance.new(className)
    local bindings
    for key, value in pairs(props or {}) do
        object[key] = value
        if typeof(value) == "Color3" then
            for role, themeColor in pairs(Theme) do
                if value == themeColor then
                    bindings = bindings or {}
                    bindings[key] = role
                    break
                end
            end
        end
    end
    if bindings then ThemeBindings[object] = bindings end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    local uiCorner = create("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
    uiCorner:SetAttribute("USSIBaseCorner", radius or 8)
    return uiCorner
end

local function stroke(parent, color, transparency)
    return create("UIStroke", {
        Color = color or Theme.Border,
        Transparency = transparency or 0,
        Thickness = 1,
    }, parent)
end

local function tween(object, duration, style, direction, properties)
    if ReducedMotion then
        for property, value in pairs(properties) do
            object[property] = value
        end
        return nil
    end
    local animation = TweenService:Create(
        object,
        TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
        properties
    )
    animation:Play()
    return animation
end

local function label(parent, text, size, color, font)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color or Theme.Text,
        TextSize = size or 13,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1, 0, 0, 20),
    }, parent)
end

local function button(parent, text, height, primary)
    local b = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = primary and Theme.Accent or Theme.Surface2,
        Size = UDim2.new(1, 0, 0, height or 36),
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
    }, parent)
    corner(b, 8)
    local outline = not primary and stroke(b) or nil
    local scale = create("UIScale", { Scale = 1 }, b)

    b.MouseEnter:Connect(function()
        tween(scale, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Scale = 1.025 })
        if primary then
            tween(b, 0.12, nil, nil, { BackgroundColor3 = Theme.AccentHover })
        elseif outline then
            tween(outline, 0.12, nil, nil, { Color = Theme.Accent, Transparency = 0.15 })
        end
    end)
    b.MouseLeave:Connect(function()
        tween(scale, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Scale = 1 })
        if primary then
            tween(b, 0.14, nil, nil, { BackgroundColor3 = Theme.Accent })
        elseif outline then
            tween(outline, 0.14, nil, nil, { Color = Theme.Border, Transparency = 0 })
        end
    end)
    b.MouseButton1Down:Connect(function()
        tween(scale, 0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, { Scale = 0.97 })
    end)
    b.MouseButton1Up:Connect(function()
        tween(scale, 0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1.025 })
    end)
    return b
end

local function makeCard(parent, title, description)
    local card = create("Frame", {
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, parent)
    corner(card, 10)
    stroke(card)
    local padding = create("UIPadding", {
        PaddingTop = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
    }, card)
    registerDensity(padding, "PaddingTop", UDim.new(0, 15), UDim.new(0, 10))
    registerDensity(padding, "PaddingBottom", UDim.new(0, 15), UDim.new(0, 10))
    registerDensity(padding, "PaddingLeft", UDim.new(0, 16), UDim.new(0, 12))
    registerDensity(padding, "PaddingRight", UDim.new(0, 16), UDim.new(0, 12))
    local layout = create("UIListLayout", {
        Padding = UDim.new(0, 11),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, card)
    registerDensity(layout, "Padding", UDim.new(0, 11), UDim.new(0, 7))
    local cardStroke = card:FindFirstChildOfClass("UIStroke")
    local cardScale = create("UIScale", { Scale = 1 }, card)
    card.MouseEnter:Connect(function()
        tween(cardStroke, 0.16, nil, nil, { Color = Theme.Accent, Transparency = 0.2 })
    end)
    card.MouseLeave:Connect(function()
        tween(cardStroke, 0.2, nil, nil, { Color = Theme.Border, Transparency = 0 })
    end)
    label(card, title, 14, Theme.Text, Enum.Font.GothamSemibold)
    if description then
        local desc = label(card, description, 11, Theme.Muted)
        desc.TextWrapped = true
    end
    return card
end

local function makeInput(parent, title, placeholder, initial)
    local wrap = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 55),
    }, parent)
    registerDensity(wrap, "Size", UDim2.new(1, 0, 0, 55), UDim2.new(1, 0, 0, 49))
    label(wrap, title, 12, Theme.Muted)
    local box = create("TextBox", {
        BackgroundColor3 = Theme.Surface2,
        Position = UDim2.fromOffset(0, 23),
        Size = UDim2.new(1, 0, 0, 32),
        ClearTextOnFocus = false,
        Text = getSavedSetting(title, initial or "", "string"),
        PlaceholderText = placeholder or "",
        PlaceholderColor3 = Theme.Muted,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, wrap)
    corner(box, 7)
    local boxStroke = stroke(box)
    box.Focused:Connect(function()
        tween(boxStroke, 0.16, nil, nil, { Color = Theme.Accent, Transparency = 0 })
        tween(box, 0.16, nil, nil, { BackgroundColor3 = Theme.Surface })
    end)
    box.FocusLost:Connect(function()
        tween(boxStroke, 0.16, nil, nil, { Color = Theme.Border, Transparency = 0 })
        tween(box, 0.16, nil, nil, { BackgroundColor3 = Theme.Surface2 })
        setSavedSetting(title, box.Text)
    end)
    create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, box)
    return box
end

local function makeToggle(parent, title, description, default, onChanged)
    local row = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, description and 48 or 34),
    }, parent)
    registerDensity(row, "Size", UDim2.new(1, 0, 0, description and 48 or 34), UDim2.new(1, 0, 0, description and 42 or 30))
    local titleLabel = label(row, title, 12, Theme.Text, Enum.Font.GothamMedium)
    titleLabel.Size = UDim2.new(1, -58, 0, 18)
    if description then
        local desc = label(row, description, 10, Theme.Muted)
        desc.Position = UDim2.fromOffset(0, 20)
        registerDensity(desc, "Position", UDim2.fromOffset(0, 20), UDim2.fromOffset(0, 17))
        desc.Size = UDim2.new(1, -58, 0, 24)
        desc.TextWrapped = true
        desc.TextYAlignment = Enum.TextYAlignment.Top
    end
    local value = getSavedSetting(title, default == true, "boolean")
    local toggle = create("TextButton", {
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(40, 22),
        BackgroundColor3 = value and Theme.Accent or Theme.Border,
        Text = "",
    }, row)
    corner(toggle, 20)
    local knob = create("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        Size = UDim2.fromOffset(16, 16),
        Position = value and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3),
    }, toggle)
    corner(knob, 20)
    local function render()
        tween(toggle, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
            BackgroundColor3 = value and Theme.Accent or Theme.Border
        })
        tween(knob, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
            Position = value and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
        })
    end
    render()
    if onChanged then onChanged(value) end
    toggle.MouseButton1Click:Connect(function()
        value = not value
        render()
        setSavedSetting(title, value)
        if onChanged then onChanged(value) end
    end)
    return function() return value end
end

local function makeDropdown(parent, title, values, default)
    local wrap = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 57),
        ClipsDescendants = false,
    }, parent)
    label(wrap, title, 12, Theme.Muted)
    local savedSelection = getSavedSetting(title, default or values[1], "string")
    local selected = table.find(values, savedSelection) and savedSelection or (default or values[1])
    local drop = button(wrap, selected .. "   ▾", 32, false)
    drop.Position = UDim2.fromOffset(0, 23)
    drop.TextXAlignment = Enum.TextXAlignment.Left
    create("UIPadding", { PaddingLeft = UDim.new(0, 10) }, drop)

    local menu
    local opened = false
    local function closeMenu()
        if not opened then return end
        opened = false
        drop.Text = selected .. "   ▾"
        local targetHeight = 57
        TweenService:Create(wrap, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(1, 0, 0, targetHeight)
        }):Play()
        if menu then
            local closingMenu = menu
            local closeTween = TweenService:Create(closingMenu, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1
            })
            closeTween:Play()
            closeTween.Completed:Connect(function()
                if closingMenu and closingMenu.Parent then closingMenu:Destroy() end
            end)
            menu = nil
        end
    end

    local function openMenu()
        if opened then closeMenu() return end
        opened = true
        drop.Text = selected .. "   ▴"
        local menuHeight = #values * 32
        menu = create("Frame", {
            BackgroundColor3 = Theme.Surface2,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 59),
            Size = UDim2.new(1, 0, 0, 0),
            ZIndex = 30,
        }, wrap)
        corner(menu, 7)
        stroke(menu)
        local list = create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 1),
        }, menu)
        create("UIPadding", {
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
        }, menu)

        for index, item in ipairs(values) do
            local choice = create("TextButton", {
                BackgroundColor3 = Theme.Surface2,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                LayoutOrder = index,
                Text = item,
                TextColor3 = item == selected and Theme.AccentHover or Theme.Text,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 31,
            }, menu)
            create("UIPadding", { PaddingLeft = UDim.new(0, 11) }, choice)
            choice.TextTransparency = 1
            choice.Position = UDim2.fromOffset(5, 0)
            task.delay((index - 1) * 0.025, function()
                if choice.Parent then
                    tween(choice, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
                        TextTransparency = 0,
                        Position = UDim2.fromOffset(0, 0)
                    })
                end
            end)
            choice.MouseEnter:Connect(function()
                tween(choice, 0.1, nil, nil, { BackgroundTransparency = 0.15, TextColor3 = Theme.AccentHover })
            end)
            choice.MouseLeave:Connect(function()
                tween(choice, 0.12, nil, nil, {
                    BackgroundTransparency = 1,
                    TextColor3 = item == selected and Theme.AccentHover or Theme.Text
                })
            end)
            choice.MouseButton1Click:Connect(function()
                selected = item
                drop.Text = selected .. "   ▾"
                setSavedSetting(title, selected)
                closeMenu()
            end)
        end

        TweenService:Create(wrap, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 61 + menuHeight)
        }):Play()
        TweenService:Create(menu, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, menuHeight),
            BackgroundTransparency = 0
        }):Play()
    end

    drop.MouseButton1Click:Connect(openMenu)
    local getter = function() return selected end
    getter.SetValues = function(newValues, preferred)
        if type(newValues) ~= "table" or #newValues == 0 then
            newValues = { "None saved" }
        end
        if opened then closeMenu() end
        values = newValues
        if table.find(values, preferred) then
            selected = preferred
        elseif not table.find(values, selected) then
            selected = values[1]
        end
        drop.Text = selected .. "   ▾"
        setSavedSetting(title, selected)
    end
    return getter
end

local ScreenGui = create("ScreenGui", {
    Name = GUI_NAME,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false,
}, GUI_PARENT)

local saveRunning = false
local closeGuardToggle
local showToast

local ToastLayer = create("Frame", {
    Name = "ToastLayer",
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, -80),
    Size = UDim2.fromOffset(420, 58),
    ZIndex = 200,
}, ScreenGui)

showToast = function(message, isError)
    if not getSavedSetting("Save completion notifications", true, "boolean") then return end
    local existing = ToastLayer:FindFirstChild("Toast")
    if existing then existing:Destroy() end
    local toast = create("Frame", {
        Name = "Toast",
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 201,
    }, ToastLayer)
    corner(toast, 10)
    stroke(toast, isError and Theme.Red or Theme.Accent, 0.1)
    local dot = create("Frame", {
        BackgroundColor3 = isError and Theme.Red or Theme.Green,
        Position = UDim2.fromOffset(14, 19),
        Size = UDim2.fromOffset(8, 8),
        ZIndex = 202,
    }, toast)
    corner(dot, 8)
    local messageLabel = label(toast, message, 11, Theme.Text, Enum.Font.GothamMedium)
    messageLabel.Position = UDim2.fromOffset(32, 8)
    messageLabel.Size = UDim2.new(1, -46, 1, -16)
    messageLabel.TextWrapped = true
    messageLabel.ZIndex = 202
    if ReducedMotion then
        ToastLayer.Position = UDim2.new(0.5, 0, 0, 18)
    else
        tween(ToastLayer, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {
            Position = UDim2.new(0.5, 0, 0, 18)
        })
    end
    task.delay(3.2, function()
        if not ToastLayer.Parent or not toast.Parent then return end
        if ReducedMotion then
            ToastLayer.Position = UDim2.new(0.5, 0, 0, -80)
            toast:Destroy()
        else
            tween(ToastLayer, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
                Position = UDim2.new(0.5, 0, 0, -80)
            })
            task.delay(0.22, function()
                if toast.Parent then toast:Destroy() end
            end)
        end
    end)
end

local savedWindowWidth = math.clamp(tonumber(getSavedSetting("Window width", 800, "number")) or 800, 620, 1200)
local savedWindowHeight = math.clamp(tonumber(getSavedSetting("Window height", 560, "number")) or 560, 440, 900)
local savedWindowX = math.clamp(tonumber(getSavedSetting("Window X", 0, "number")) or 0, -1000, 1000)
local savedWindowY = math.clamp(tonumber(getSavedSetting("Window Y", 0, "number")) or 0, -700, 700)
local savedScaleText = getSavedSetting("UI scale", "100%", "string")
local savedScaleNumber = tonumber(savedScaleText:match("%d+")) or 100
local savedOpacityText = getSavedSetting("Window opacity", "100%", "string")
local savedOpacityNumber = tonumber(savedOpacityText:match("%d+")) or 100

local Window = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, savedWindowX, 0.5, savedWindowY),
    Size = UDim2.fromOffset(savedWindowWidth, savedWindowHeight),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 1 - math.clamp(savedOpacityNumber, 80, 100) / 100,
    ClipsDescendants = true,
}, ScreenGui)
corner(Window, 14)
stroke(Window, Theme.Border)
local WindowScale = create("UIScale", {Scale = ReducedMotion and savedScaleNumber / 100 or 0.94 * savedScaleNumber / 100}, Window)
if not ReducedMotion then
    TweenService:Create(WindowScale, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = savedScaleNumber / 100
    }):Play()
end

local Topbar = create("Frame", {
    BackgroundColor3 = Theme.Surface,
    Size = UDim2.new(1, 0, 0, 58),
}, Window)
local topAccent = create("Frame", {
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 1, -2),
    Size = UDim2.new(0, 0, 0, 2),
}, Topbar)
tween(topAccent, 0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {
    Size = UDim2.new(1, 0, 0, 2)
})
local topTitle = label(Topbar, "  USSI", 17, Theme.Text, Enum.Font.GothamBold)
topTitle.Position = UDim2.fromOffset(15, 8)
topTitle.Size = UDim2.new(0, 150, 0, 22)
local topSubtitle = label(Topbar, "UNIVERSAL SYN SAVE INSTANCE  •  " .. GUI_VERSION, 9, Theme.Muted, Enum.Font.GothamMedium)
topSubtitle.Position = UDim2.fromOffset(17, 31)
topSubtitle.Size = UDim2.new(0, 260, 0, 15)
local minimize = button(Topbar, "—", 30, false)
minimize.Size = UDim2.fromOffset(32, 30)
minimize.Position = UDim2.new(1, -82, 0, 14)
minimize.TextSize = 18
minimize.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

local close = button(Topbar, "×", 30, false)
close.Size = UDim2.fromOffset(32, 30)
close.Position = UDim2.new(1, -44, 0, 14)
close.TextSize = 20
close.MouseButton1Click:Connect(function()
    if saveRunning and closeGuardToggle and closeGuardToggle() then
        if showToast then showToast("A save is running. Closing is disabled until it finishes.", true) end
        return
    end
    if ReducedMotion then
        ScreenGui:Destroy()
        return
    end
    local closeTween = TweenService:Create(WindowScale, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Scale = 0.94
    })
    closeTween:Play()
    closeTween.Completed:Connect(function()
        if ScreenGui.Parent then ScreenGui:Destroy() end
    end)
end)

local Sidebar = create("Frame", {
    BackgroundColor3 = Theme.Surface,
    Position = UDim2.fromOffset(0, 58),
    Size = UDim2.new(0, 170, 1, -58),
}, Window)
local sideLayout = create("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, Sidebar)
create("UIPadding", {
    PaddingTop = UDim.new(0, 18),
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12),
}, Sidebar)

local Content = create("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(190, 76),
    Size = UDim2.new(1, -210, 1, -94),
}, Window)

local pages = {}
local navButtons = {}
local activePage
local navOrder = 0

local function switchPage(name)
    local page = pages[name]
    if not page then return end
    if activePage then activePage.Visible = false end
    activePage = page
    page.Visible = true

    local pageScale = page:FindFirstChildOfClass("UIScale")
    if not pageScale then
        pageScale = create("UIScale", { Scale = ReducedMotion and 1 or 0.985 }, page)
    end
    if ReducedMotion then
        pageScale.Scale = 1
    else
        pageScale.Scale = 0.985
        tween(pageScale, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { Scale = 1 })
    end

    -- Soft staggered card entrance whenever a page is opened.
    for index, child in ipairs(page:GetChildren()) do
        if child:IsA("Frame") then
            local cardScale = child:FindFirstChildOfClass("UIScale")
            if not cardScale then cardScale = create("UIScale", { Scale = 1 }, child) end
            if ReducedMotion then
                cardScale.Scale = 1
            else
                cardScale.Scale = 0.97
                task.delay(math.min((index - 1) * 0.035, 0.14), function()
                    if child.Parent and page.Visible then
                        tween(cardScale, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })
                    end
                end)
            end
        end
    end

    for pageName, navButton in pairs(navButtons) do
        local selected = pageName == name
        navButton.BackgroundColor3 = selected and Theme.Accent or Theme.Surface2
        navButton.TextColor3 = selected and Color3.new(1, 1, 1) or Theme.Muted
        local navScale = navButton:FindFirstChildOfClass("UIScale")
        if navScale then
            tween(navScale, 0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = selected and 1.035 or 1 })
        end
    end
end

local function applyThemePreset(name)
    local preset = ThemePresets[name]
    if not preset then return false end
    CurrentThemeName = name
    for role, value in pairs(preset) do
        Theme[role] = value
    end
    for object, bindings in pairs(ThemeBindings) do
        if object and object.Parent then
            for property, role in pairs(bindings) do
                pcall(function() object[property] = Theme[role] end)
            end
        end
    end
    setSavedSetting("Theme preset", name)
    for pageName, navButton in pairs(navButtons) do
        local selected = pages[pageName] == activePage
        navButton.BackgroundColor3 = selected and Theme.Accent or Theme.Surface2
        navButton.TextColor3 = selected and Color3.new(1, 1, 1) or Theme.Muted
    end
    return true
end

local function makePage(name)
    local page = create("ScrollingFrame", {
        Name = name,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        Visible = false,
    }, Content)
    local pageLayout = create("UIListLayout", { Padding = UDim.new(0, 11), SortOrder = Enum.SortOrder.LayoutOrder }, page)
    registerDensity(pageLayout, "Padding", UDim.new(0, 11), UDim.new(0, 7))
    pages[name] = page
    local nav = button(Sidebar, name, 36, false)
    navOrder = navOrder + 1
    nav.LayoutOrder = navOrder
    nav.TextXAlignment = Enum.TextXAlignment.Left
    nav.TextColor3 = Theme.Muted
    navButtons[name] = nav
    nav.MouseButton1Click:Connect(function()
        switchPage(name)
    end)
    return page
end

local home = makePage("Overview")
local savePage = makePage("Save")
local optionsPage = makePage("Options")
local advancedPage = makePage("Advanced")
local visualsPage = makePage("Visuals")
local optimizationPage = makePage("Optimization")
local miscPage = makePage("Misc")
local usefulPage = makePage("Useful")
local aboutPage = makePage("About")

-- Apply saved appearance before creating the remaining pages and controls.
applyThemePreset(CurrentThemeName)

local function applyWindowScale(value)
    local amount = tonumber(tostring(value):match("%d+")) or 100
    amount = math.clamp(amount, 80, 120)
    WindowScale.Scale = amount / 100
    setSavedSetting("UI scale", tostring(amount) .. "%")
end

local statusText = "Ready"
local statusLabel = label(home, "●  " .. statusText, 12, Theme.Green, Enum.Font.GothamMedium)
local hero = makeCard(home, "Save your experience", "Configure a save and run it through the original USSI engine. The interface does not replace or modify the serializer.")
local heroButton = button(hero, "Open save settings  →", 38, true)
heroButton.MouseButton1Click:Connect(function()
    switchPage("Save")
end)

local info = makeCard(home, "Session", "Current place details")
label(info, "Place: " .. game.Name, 12, Theme.Text)
label(info, "Place ID: " .. tostring(game.PlaceId), 11, Theme.Muted)
label(info, "Job ID: " .. (game.JobId ~= "" and game.JobId or "Studio / local session"), 10, Theme.Muted)

local outputCard = makeCard(savePage, "OUTPUT", "Choose the exact Roblox file type, save mode, compression, and destination.")
local format = makeDropdown(outputCard, "File type", {
    "RBXL - Place (Binary)",
    "RBXM - Model (Binary)",
    "RBXLX - Place (XML)",
    "RBXMX - Model (XML)",
}, "RBXL - Place (Binary)")
local mode = makeDropdown(outputCard, "Save mode", {"optimized", "full", "scripts"}, "optimized")
local compression = makeDropdown(outputCard, "Compression", {"zstd", "lz4", "None"}, "zstd")
local outputNameBox = makeInput(
    outputCard,
    "Custom output name",
    "My Experience Backup",
    getSavedSetting("File path", "", "string")
)
local outputNameHint = label(
    outputCard,
    "Leave blank to use the game's automatic name. The selected format adds .rbxl, .rbxm, .rbxlx, or .rbxmx automatically. Example: Final Circuit - Night 1",
    10,
    Theme.Muted
)
outputNameHint.TextWrapped = true

local objectCard = makeCard(savePage, "SPECIFIC INSTANCE (OPTIONAL)", "Save one selected Instance instead of the whole game. RBXL/RBXLX creates a place file containing the selected hierarchy; RBXM/RBXMX creates a model file.")
local objectPathBox = makeInput(objectCard, "Instance path", 'game:GetService("ReplicatedStorage").Assets.CutScenes.NIGHT1TESTING', "")
local objectHint = label(objectCard, "Supports game:GetService(\"ServiceName\").Folder.Model paths and simple dot paths like ReplicatedStorage.Assets.CutScenes.NIGHT1TESTING.", 10, Theme.Muted)
objectHint.TextWrapped = true
local browseInstancesButton = button(objectCard, "Browse game instances  →", 36, false)
local validatePathButton = button(objectCard, "Validate instance path", 32, false)
local objectPathStatus = label(objectCard, "Path not checked yet.", 10, Theme.Muted)
objectPathStatus.TextWrapped = true

local saveOptionsCard = makeCard(savePage, "SAVE OPTIONS", "Control how the experience is captured and written.")
local safeMode = makeToggle(saveOptionsCard, "Safe mode", "Disconnects the local player while saving; enables protective save settings.", false)
local showStatus = makeToggle(saveOptionsCard, "Show status", "Display save progress on screen.", true)
local readme = makeToggle(saveOptionsCard, "Include README", "Add save details and warnings to the output.", true)
local avoidOverwrite = makeToggle(saveOptionsCard, "Avoid overwriting", "Append a number when a file with the same name exists.", true)

local scriptCard = makeCard(optionsPage, "SCRIPT HANDLING", "Choose how scripts and their source are captured.")
local decompile = makeToggle(scriptCard, "Decompile scripts", "Attempt to recover readable source for scripts.", true)
local bytecode = makeToggle(scriptCard, "Save bytecode", "Include compiled bytecode when the executor supports it.", false)
local recoverAssets = makeToggle(scriptCard, "Recover published scripts", "Try to recover original source from published script assets.", true)
local scriptCache = makeToggle(scriptCard, "Cache decompilation", "Reuse decompiled source during this and later runs.", true)
local instanceCard = makeCard(optionsPage, "INSTANCE CAPTURE", "Include additional objects that are normally skipped.")
local nilInstances = makeToggle(instanceCard, "Save nil instances", "Include unparented instances when getnilinstances is available.", false)
local saveCharacters = makeToggle(instanceCard, "Save player characters", "Include player characters that are normally skipped.", false)
local propertyCard = makeCard(optionsPage, "PROPERTY HANDLING", "Adjust how instance properties are read and stored.")
local ignoreDefaults = makeToggle(propertyCard, "Ignore default properties", "Reduce XML size by skipping properties at their class defaults.", true)
local ignoreSpecial = makeToggle(propertyCard, "Ignore special properties", "Avoid executor hidden-property reads.", false)
local antiIdle = makeToggle(propertyCard, "Anti-idle", "Prevent the normal idle kick while the save is running.", true)

local tuningCard = makeCard(advancedPage, "TIMEOUTS & COMPRESSION", "Advanced performance and serialization settings.")
local timeoutBox = makeInput(tuningCard, "Decompile timeout (seconds)", "10", "10")
local bytecodeTimeoutBox = makeInput(tuningCard, "Bytecode timeout (seconds)", "3", "3")
local compressionLevelBox = makeInput(tuningCard, "Compression level (-7 to 22)", "9", "9")
local saveCacheBox = makeInput(tuningCard, "Save cache interval", "56320", "56320")
local behaviorCard = makeCard(advancedPage, "OUTPUT & SESSION", "Optional executor and player handling features.")
local copyClipboard = makeToggle(behaviorCard, "Copy to clipboard", "Requires executor clipboard support. Best for small saves.", false)
local isolatePlayer = makeToggle(behaviorCard, "Isolate local player", "Save the local player as a Folder instead of a Player instance.", false)
local isolateStarter = makeToggle(behaviorCard, "Isolate StarterPlayer", "Move StarterPlayer children into a top-level folder.", false)
local shutdown = makeToggle(behaviorCard, "Shutdown when done", "Close the game after a successful save.", false)

local performanceCard = makeCard(advancedPage, "PERFORMANCE & SCRIPT CONTROL", "Additional engine controls. Safe Mode automatically enables the first two; either can also be enabled when Safe Mode is off.")
local killAllScripts = makeToggle(performanceCard, "Stop other running scripts", "Disables other running scripts during capture. Some experiences may stop responding to input.", false)
local boostFPS = makeToggle(performanceCard, "Boost FPS while saving", "Temporarily disables 3D rendering during the save, then restores it.", false)

local playerCard = makeCard(advancedPage, "PLAYER & INSTANCE OUTPUT", "Change how player-related instances are represented in the saved file.")
local isolatePlayers = makeToggle(playerCard, "Isolate all players", "Place Player objects in a top-level Players folder instead of the Players service.", false)
local isolateCharacter = makeToggle(playerCard, "Isolate local character", "Save your character as a standalone Model named LocalPlayer Character.", false)
local ignoreDefaultScripts = makeToggle(playerCard, "Ignore default player scripts", "Skip Roblox default scripts such as PlayerModule and BubbleChat. Can reduce decompiler issues.", false)

local fileCard = makeCard(advancedPage, "FILE WRITING & SIZE", "Options that affect file output, storage, and compatibility.")
local alternativeWrite = makeToggle(fileCard, "Write file in chunks", "Use appendfile in smaller pieces where supported, with engine fallback behavior.", true)
local sharedBinary = makeToggle(fileCard, "Share repeated binary data", "Store identical meshes and images once. Can reduce file size when assets repeat.", false)
local unionsAsParts = makeToggle(fileCard, "Convert unions to Parts", "Risky: keeps visible geometry on limited executors, but loses the merged union shape.", false)

local scriptPropertyCard = makeCard(advancedPage, "SCRIPT MODE & PRIVACY", "Extra filtering and identity replacement options.")
local scriptOnlyProperties = makeToggle(scriptPropertyCard, "Skip non-script properties in Scripts mode", "Only serialize properties for script objects when using Scripts mode.", false)
local anonymize = makeToggle(scriptPropertyCard, "Anonymize local player", "Replace the local player's name and UserId in the output. Matching text or numbers elsewhere may also change.", false)

-- VISUALS: five live appearance controls.
local appearanceCard = makeCard(visualsPage, "APPEARANCE", "Change the look of the GUI without restarting it.")
local themeDropdown = makeDropdown(appearanceCard, "Color theme", {
    "Midnight Violet", "Ocean Blue", "Emerald", "Rose", "Amber"
}, CurrentThemeName)
local scaleDropdown = makeDropdown(appearanceCard, "Interface scale", {
    "80%", "90%", "100%", "110%", "120%"
}, getSavedSetting("UI scale", "100%", "string"))
local densityToggle = makeToggle(appearanceCard, "Compact layout", "Reduce card and control spacing to fit more settings on screen.", CompactMode, function(value)
    CompactMode = value
    applyDensity()
end)
local motionToggle = makeToggle(appearanceCard, "Reduced motion", "Disable most hover, page, and control animations.", ReducedMotion, function(value)
    ReducedMotion = value
end)
local opacityDropdown = makeDropdown(appearanceCard, "Window opacity", {
    "100%", "96%", "92%", "88%"
}, getSavedSetting("Window opacity", "100%", "string"))
themeDropdown -- selected theme is applied by the callback below


themeDropdown.SetValues({ "Midnight Violet", "Ocean Blue", "Emerald", "Rose", "Amber" }, CurrentThemeName)
local function refreshVisualSettings()
    applyThemePreset(themeDropdown())
    applyWindowScale(scaleDropdown())
    local opacity = tonumber(opacityDropdown():match("%d+")) or 100
    Window.BackgroundTransparency = 1 - math.clamp(opacity, 80, 100) / 100
    setSavedSetting("Window opacity", tostring(opacity) .. "%")
end


-- OPTIMIZATION: five controls for save and Explorer performance.
local optimizationCard = makeCard(optimizationPage, "SAVE PRESETS", "Choose a practical balance. The preset modifies only the listed save options for the next run.")
local savePresetDropdown = makeDropdown(optimizationCard, "Save profile", {
    "Balanced", "Fastest save", "Smaller output", "Maximum detail"
}, getSavedSetting("Save profile", "Balanced", "string"))
local writeChunkBox = makeInput(optimizationCard, "Write chunk size (MB, 1-16)", "4", getSavedSetting("Write chunk size (MB)", "4", "string"))

local explorerPerformanceCard = makeCard(optimizationPage, "EXPLORER PERFORMANCE", "Tune how much the instance browser searches and how it displays results.")
local explorerResultLimit = makeDropdown(explorerPerformanceCard, "Maximum search results", {
    "50", "100", "250", "500"
}, getSavedSetting("Explorer max results", "100", "string"))
local explorerYieldInterval = makeDropdown(explorerPerformanceCard, "Search yield interval", {
    "500", "1000", "2500", "5000"
}, getSavedSetting("Explorer yield interval", "2500", "string"))
local explorerSort = makeToggle(explorerPerformanceCard, "Sort Explorer alphabetically", "Alphabetical sorting is easier to scan; disabling it can speed up large tree expansions.", true)

themeDropdown.SetValues({ "Midnight Violet", "Ocean Blue", "Emerald", "Rose", "Amber" }, CurrentThemeName)
themeDropdown -- UI control for active palette
themeDropdown = themeDropdown


-- MISC: five window and workflow quality-of-life controls.
local windowCard = makeCard(miscPage, "WINDOW BEHAVIOR", "Control how the interface opens, hides, and remembers its layout.")
local hotkeyInfo = label(windowCard, "Toggle visibility: Left Ctrl + Left Shift + U", 11, Theme.Muted)
local resetWindowButton = button(windowCard, "Reset window position and size", 34, false)
local notificationsToggle = makeToggle(windowCard, "Save completion notifications", "Show a small in-GUI toast when a save finishes or fails.", true)
closeGuardToggle = makeToggle(windowCard, "Prevent closing during a save", "Ignore the close button while the serializer is running.", true)
resetWindowButton.MouseButton1Click:Connect(function()
    Window.Size = UDim2.fromOffset(800, 560)
    Window.Position = UDim2.fromScale(0.5, 0.5)
    setSavedSetting("Window width", 800)
    setSavedSetting("Window height", 560)
    setSavedSetting("Window X", 0)
    setSavedSetting("Window Y", 0)
    if showToast then showToast("Window layout reset.", false) end
end)
local windowTips = label(windowCard, "Use the small dash in the title bar to minimize. The hotkey restores the GUI.", 10, Theme.Muted)
windowTips.TextWrapped = true

-- USEFUL: five tools for repeatedly targeting the same objects.
local targetToolsCard = makeCard(usefulPage, "INSTANCE SHORTCUTS", "Keep frequently used targets close and validate paths before starting a save.")
local recentTargets = getSavedSetting("Recent instance paths", {}, "table")
local favoriteTargets = getSavedSetting("Favorite instance paths", {}, "table")
if #recentTargets == 0 then recentTargets = { "No recent targets" } end
if #favoriteTargets == 0 then favoriteTargets = { "No favorites saved" } end
local recentTargetsDropdown = makeDropdown(targetToolsCard, "Recent targets", recentTargets, recentTargets[1])
local useRecentTargetButton = button(targetToolsCard, "Use recent target", 32, false)
local favoriteTargetsDropdown = makeDropdown(targetToolsCard, "Favorite targets", favoriteTargets, favoriteTargets[1])
local useFavoriteTargetButton = button(targetToolsCard, "Use favorite target", 32, false)
local addFavoriteButton = button(targetToolsCard, "Add current target to favorites", 32, false)
local copyTargetPathButton = button(targetToolsCard, "Copy current target path", 32, false)
local nameFromTargetButton = button(targetToolsCard, "Use target name as output name", 32, false)

local about = makeCard(aboutPage, "About this interface", "A standalone executor interface for the existing Universal Syn Save Instance project.")
label(about, "Engine: saveinstance.luau", 12, Theme.Text)
label(about, "UI: saveinstance-gui.luau  •  " .. GUI_VERSION, 12, Theme.Text)
label(about, "This fork is unofficial and is not affiliated with Roblox Corporation.", 11, Theme.Muted)
label(about, "UniversalSynSaveInstance https://discord.gg/wx4ThpAsmw", 10, Theme.Muted)
local repoButton = button(about, "Open project repository", 34, false)
repoButton.MouseButton1Click:Connect(function()
    if setclipboard then pcall(setclipboard, "https://github.com/finalcircuitgame-crypto/UniversalSynSaveInstance") end
end)

themeDropdown -- Apply default theme at initial render.
applyThemePreset(themeDropdown())
applyWindowScale(scaleDropdown())
local startupOpacity = tonumber(opacityDropdown():match("%d+")) or 100
Window.BackgroundTransparency = 1 - math.clamp(startupOpacity, 80, 100) / 100
themeDropdown -- retained for live color theme selection

local function saveWindowGeometry()
    setSavedSetting("Window width", Window.Size.X.Offset)
    setSavedSetting("Window height", Window.Size.Y.Offset)
    setSavedSetting("Window X", Window.Position.X.Offset)
    setSavedSetting("Window Y", Window.Position.Y.Offset)
end

local runCard = makeCard(savePage, "Ready to save?", "Check your settings before starting. Large experiences can take a while and may use substantial memory.")
local runButton = button(runCard, "Start save", 42, true)
local runStatus = label(runCard, "Waiting for configuration.", 11, Theme.Muted)
local runProgressTrack = create("Frame", {
    BackgroundColor3 = Theme.Surface2,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 5),
}, runCard)
corner(runProgressTrack, 5)
local runProgressFill = create("Frame", {
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 0, 1, 0),
}, runProgressTrack)
corner(runProgressFill, 5)
local runProgressTween
local runProgressMode

local function setStatus(message, color, progress)
    statusLabel.Text = "●  " .. message
    statusLabel.TextColor3 = color or Theme.Green
    runStatus.Text = message
    runStatus.TextColor3 = color or Theme.Muted

    if color == Theme.Red then
        runProgressFill.BackgroundColor3 = Theme.Red
        if progress == nil then progress = 0 end
    elseif color == Theme.Green then
        runProgressFill.BackgroundColor3 = Theme.Green
    else
        runProgressFill.BackgroundColor3 = Theme.Accent
    end

    if progress == nil then
        if runProgressMode ~= "indeterminate" then
            if runProgressTween then pcall(function() runProgressTween:Cancel() end) end
            runProgressFill.Position = UDim2.new(-0.25, 0, 0, 0)
            runProgressFill.Size = UDim2.new(0.25, 0, 1, 0)
            runProgressMode = "indeterminate"
            runProgressTween = TweenService:Create(
                runProgressFill,
                TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, false),
                { Position = UDim2.new(1, 0, 0, 0) }
            )
            runProgressTween:Play()
        end
    else
        if runProgressTween then
            pcall(function() runProgressTween:Cancel() end)
            runProgressTween = nil
        end
        runProgressMode = "determinate"
        runProgressFill.Position = UDim2.new(0, 0, 0, 0)
        tween(runProgressFill, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
            Size = UDim2.new(math.clamp(progress, 0, 1), 0, 1, 0)
        })
    end
end

-- Resolve a user-entered Instance path without executing arbitrary Lua code.
-- Supported examples:
--   game:GetService("ReplicatedStorage").Assets.CutScenes.NIGHT1TESTING
--   ReplicatedStorage.Assets.CutScenes.NIGHT1TESTING
--   workspace.Map
local function resolveInstancePath(path)
    path = tostring(path or ""):match("^%s*(.-)%s*$")
    if path == "" then return nil, "No instance path was provided." end

    local serviceName, remainder = path:match('^game:GetService%("([^"]+)"%)%.?(.*)$')
    if not serviceName then
        serviceName, remainder = path:match("^game:GetService%('([^']+)'%)%.?(.*)$")
    end

    local current
    local segments = {}

    if serviceName then
        local ok, service = pcall(function()
            return game:GetService(serviceName)
        end)
        if not ok then
            return nil, "Could not access service: " .. serviceName
        end
        current = service
        for segment in remainder:gmatch("[^%.]+") do
            table.insert(segments, segment)
        end
    else
        path = path:gsub("^game%.", "")
        for segment in path:gmatch("[^%.]+") do
            table.insert(segments, segment)
        end
        if #segments == 0 then return nil, "The instance path is empty." end

        local first = table.remove(segments, 1)
        if first == "workspace" or first == "Workspace" then
            current = workspace
        elseif first == "game" then
            current = game
        else
            local ok, service = pcall(function()
                return game:GetService(first)
            end)
            current = ok and service or game:FindFirstChild(first)
            if not current then
                return nil, "Could not find service or child: " .. first
            end
        end
    end

    for _, segment in ipairs(segments) do
        local child = current:FindFirstChild(segment)
        if not child then
            return nil, "Could not find '" .. segment .. "' under " .. current:GetFullName()
        end
        current = child
    end

    return current
end

local function addRecentTarget(path)
    if type(path) ~= "string" or path == "" then return end
    local recent = getSavedSetting("Recent instance paths", {}, "table")
    local nextList = { path }
    for _, item in ipairs(recent) do
        if item ~= path and #nextList < 10 then
            nextList[#nextList + 1] = item
        end
    end
    setSavedSetting("Recent instance paths", nextList)
    recentTargetsDropdown.SetValues(nextList, path)
end

local function addFavoriteTarget(path)
    if type(path) ~= "string" or path == "" then return false end
    local favorites = getSavedSetting("Favorite instance paths", {}, "table")
    for _, item in ipairs(favorites) do
        if item == path then return false end
    end
    favorites[#favorites + 1] = path
    setSavedSetting("Favorite instance paths", favorites)
    favoriteTargetsDropdown.SetValues(favorites, path)
    return true
end



-- Explorer-style browser for selecting an Instance without typing its path.
local browserSelectedInstance = nil
local browserSelectedPath = nil

objectPathBox:GetPropertyChangedSignal("Text"):Connect(function()
    if browserSelectedPath and objectPathBox.Text ~= browserSelectedPath then
        browserSelectedInstance = nil
        browserSelectedPath = nil
    end
end)

local function openInstanceBrowser()
    local overlay = create("Frame", {
        Name = "InstanceBrowserOverlay",
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.32,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 60,
    }, ScreenGui)

    local panel = create("Frame", {
        Name = "InstanceBrowser",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(650, 470),
        BackgroundColor3 = Theme.Background,
        ZIndex = 61,
    }, overlay)
    corner(panel, 12)
    stroke(panel, Theme.Border)

    local header = create("Frame", {
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(1, 0, 0, 48),
        ZIndex = 62,
    }, panel)
    corner(header, 12)
    local headerTitle = label(header, "INSTANCE EXPLORER", 14, Theme.Text, Enum.Font.GothamBold)
    headerTitle.Position = UDim2.fromOffset(17, 0)
    headerTitle.Size = UDim2.new(1, -75, 1, 0)
    headerTitle.ZIndex = 63

    local closeBrowser = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Surface2,
        Position = UDim2.new(1, -42, 0, 9),
        Size = UDim2.fromOffset(30, 30),
        Text = "×",
        TextColor3 = Theme.Text,
        TextSize = 20,
        Font = Enum.Font.GothamMedium,
        ZIndex = 64,
    }, header)
    corner(closeBrowser, 7)
    closeBrowser.MouseButton1Click:Connect(function() overlay:Destroy() end)

    local searchBox = create("TextBox", {
        BackgroundColor3 = Theme.Surface2,
        Position = UDim2.fromOffset(17, 60),
        Size = UDim2.new(1, -265, 0, 32),
        ClearTextOnFocus = false,
        Text = "",
        PlaceholderText = "Search instances by name...",
        PlaceholderColor3 = Theme.Muted,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 63,
    }, panel)
    corner(searchBox, 7)
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    }, searchBox)

    local function browserActionButton(text, x, width)
        local item = create("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Theme.Surface2,
            Position = UDim2.fromOffset(x, 60),
            Size = UDim2.fromOffset(width, 32),
            Text = text,
            TextColor3 = Theme.Text,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            ZIndex = 63,
        }, panel)
        corner(item, 7)
        stroke(item)
        return item
    end

    local searchButton = browserActionButton("Search", 395, 68)
    local refreshButton = browserActionButton("Refresh tree", 470, 82)
    local clearButton = browserActionButton("Clear", 559, 73)

    local help = label(panel, "Expand arrows to browse. Select an instance by clicking its name.", 10, Theme.Muted)
    help.Position = UDim2.fromOffset(18, 96)
    help.Size = UDim2.new(1, -36, 0, 16)
    help.ZIndex = 63

    local tree = create("ScrollingFrame", {
        Name = "InstanceTree",
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(17, 119),
        Size = UDim2.new(1, -34, 1, -174),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent,
        ZIndex = 62,
    }, panel)
    corner(tree, 8)
    create("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
    }, tree)
    create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tree)

    local selectionLabel = label(panel, "Selected: none", 10, Theme.Muted)
    selectionLabel.Position = UDim2.fromOffset(18, 411)
    selectionLabel.Size = UDim2.new(1, -400, 0, 20)
    selectionLabel.TextTruncate = Enum.TextTruncate.AtEnd
    selectionLabel.ZIndex = 63

    local favoriteSelection = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Surface2,
        Position = UDim2.new(1, -365, 1, -43),
        Size = UDim2.fromOffset(100, 30),
        Text = "★ Favorite",
        TextColor3 = Theme.Text,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        ZIndex = 64,
    }, panel)
    corner(favoriteSelection, 7)
    local copySelection = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Surface2,
        Position = UDim2.new(1, -255, 1, -43),
        Size = UDim2.fromOffset(82, 30),
        Text = "Copy path",
        TextColor3 = Theme.Text,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        ZIndex = 64,
    }, panel)
    corner(copySelection, 7)

    local useSelection = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(1, -160, 1, -43),
        Size = UDim2.fromOffset(142, 30),
        Text = "Use selected",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 12,
        Font = Enum.Font.GothamSemibold,
        ZIndex = 64,
    }, panel)
    corner(useSelection, 7)

    local expanded = {}
    local selected = nil
    local selectedButton = nil
    local refreshTree
    local searchGeneration = 0
    local rowOrder = 0

    local function clearTreeRows()
        for _, child in ipairs(tree:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end
        selectedButton = nil
        rowOrder = 0
    end

    local function setBrowserSelection(instance)
        selected = instance
        if instance then
            local ok, fullName = pcall(function() return instance:GetFullName() end)
            selectionLabel.Text = "Selected: " .. (ok and fullName or instance.Name)
        else
            selectionLabel.Text = "Selected: none"
        end
    end

    local function addTreeRow(instance, depth, searchable)
        rowOrder = rowOrder + 1
        local row = create("Frame", {
            BackgroundColor3 = Theme.Surface,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -4, 0, 27),
            LayoutOrder = rowOrder,
            ZIndex = 63,
        }, tree)

        local indent = math.min(depth * 14, 175)
        local hasChildren = #instance:GetChildren() > 0
        local expand = create("TextButton", {
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(indent, 0),
            Size = UDim2.fromOffset(23, 26),
            Text = searchable and "·" or (hasChildren and (expanded[instance] and "▾" or "▸") or "·"),
            TextColor3 = Theme.Muted,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            ZIndex = 64,
        }, row)

        local nameButton = create("TextButton", {
            Name = "InstanceName",
            AutoButtonColor = false,
            BackgroundColor3 = selected == instance and Theme.Accent or Theme.Surface,
            BackgroundTransparency = selected == instance and 0.72 or 1,
            Position = UDim2.fromOffset(indent + 24, 1),
            Size = UDim2.new(1, -indent - 28, 0, 25),
            Text = instance.Name .. "   [" .. instance.ClassName .. "]",
            TextColor3 = selected == instance and Theme.AccentHover or Theme.Text,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 64,
        }, row)
        corner(nameButton, 5)

        expand.MouseButton1Click:Connect(function()
            if searchable or not hasChildren then return end
            expanded[instance] = not expanded[instance]
            searchBox.Text = ""
            searchGeneration = searchGeneration + 1
            refreshTree()
        end)
        nameButton.MouseButton1Click:Connect(function()
            if selectedButton and selectedButton.Parent then
                selectedButton.BackgroundColor3 = Theme.Surface
                selectedButton.BackgroundTransparency = 1
                selectedButton.TextColor3 = Theme.Text
            end
            setBrowserSelection(instance)
            selectedButton = nameButton
            nameButton.BackgroundColor3 = Theme.Accent
            nameButton.BackgroundTransparency = 0.72
            nameButton.TextColor3 = Theme.AccentHover
        end)
    end

    refreshTree = function()
        clearTreeRows()
        local roots = game:GetChildren()
        if explorerSort() then
            table.sort(roots, function(a, b) return string.lower(a.Name) < string.lower(b.Name) end)
        end

        local function addBranch(instance, depth)
            addTreeRow(instance, depth, false)
            if expanded[instance] then
                local children = instance:GetChildren()
                if explorerSort() then
                    table.sort(children, function(a, b) return string.lower(a.Name) < string.lower(b.Name) end)
                end
                for _, child in ipairs(children) do
                    addBranch(child, depth + 1)
                end
            end
        end

        for _, service in ipairs(roots) do
            addBranch(service, 0)
        end
    end

    local function performSearch()
        local query = string.lower(searchBox.Text:match("^%s*(.-)%s*$") or "")
        searchGeneration = searchGeneration + 1
        local generation = searchGeneration
        if query == "" then
            refreshTree()
            return
        end

        clearTreeRows()
        local searchingRow = label(tree, "Searching instance names...", 11, Theme.Muted)
        searchingRow.LayoutOrder = 1
        searchingRow.Size = UDim2.new(1, -8, 0, 25)
        searchingRow.ZIndex = 64

        task.spawn(function()
            local descendants = game:GetDescendants()
            local matches = {}
            local scanned = 0
            local maxResults = tonumber(explorerResultLimit()) or 100
            local yieldInterval = tonumber(explorerYieldInterval()) or 2500
            for _, instance in ipairs(descendants) do
                scanned = scanned + 1
                if string.find(string.lower(instance.Name), query, 1, true) then
                    table.insert(matches, instance)
                    if #matches >= maxResults then break end
                end
                if scanned % yieldInterval == 0 then
                    task.wait()
                    if generation ~= searchGeneration or not overlay.Parent then return end
                end
            end

            if generation ~= searchGeneration or not overlay.Parent then return end
            clearTreeRows()
            if explorerSort() then
                table.sort(matches, function(a, b) return string.lower(a.Name) < string.lower(b.Name) end)
            end
            if #matches == 0 then
                local empty = label(tree, "No matching instances found.", 11, Theme.Muted)
                empty.LayoutOrder = 1
                empty.Size = UDim2.new(1, -8, 0, 25)
                empty.ZIndex = 64
                return
            end
            for _, instance in ipairs(matches) do
                addTreeRow(instance, 0, true)
            end
        end)
    end

    searchButton.MouseButton1Click:Connect(performSearch)
    searchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then performSearch() end
    end)
    refreshButton.MouseButton1Click:Connect(function()
        searchGeneration = searchGeneration + 1
        searchBox.Text = ""
        expanded = {}
        refreshTree()
    end)
    clearButton.MouseButton1Click:Connect(function()
        searchGeneration = searchGeneration + 1
        searchBox.Text = ""
        refreshTree()
    end)
    favoriteSelection.MouseButton1Click:Connect(function()
        if not selected then
            selectionLabel.Text = "Select an instance first."
            return
        end
        local ok, fullName = pcall(function() return selected:GetFullName() end)
        if not ok then return end
        local added = addFavoriteTarget(fullName)
        selectionLabel.Text = added and "Added to favorites: " .. fullName or "Already in favorites: " .. fullName
    end)

    copySelection.MouseButton1Click:Connect(function()
        if not selected then
            selectionLabel.Text = "Select an instance first."
            return
        end
        local ok, fullName = pcall(function() return selected:GetFullName() end)
        if ok and type(setclipboard) == "function" then
            local copied = pcall(setclipboard, fullName)
            selectionLabel.Text = copied and "Copied: " .. fullName or "Clipboard copy failed."
        else
            selectionLabel.Text = "Clipboard function is unavailable."
        end
    end)

    useSelection.MouseButton1Click:Connect(function()
        if not selected or not selected.Parent then
            selectionLabel.Text = "Select an instance first."
            return
        end
        local ok, fullName = pcall(function() return selected:GetFullName() end)
        if not ok then
            selectionLabel.Text = "Could not read the selected instance path."
            return
        end
        objectPathBox.Text = fullName
        browserSelectedInstance = selected
        browserSelectedPath = objectPathBox.Text
        setSavedSetting("Instance path", objectPathBox.Text)
        addRecentTarget(fullName)
        overlay:Destroy()
    end)

    refreshTree()
end

browseInstancesButton.MouseButton1Click:Connect(openInstanceBrowser)

validatePathButton.MouseButton1Click:Connect(function()
    local target, err = resolveInstancePath(objectPathBox.Text)
    if not target then
        objectPathStatus.Text = "Invalid path: " .. tostring(err)
        objectPathStatus.TextColor3 = Theme.Red
        if showToast then showToast("Instance path could not be resolved.", true) end
        return
    end
    local fullName = target:GetFullName()
    local childCount = #target:GetChildren()
    objectPathStatus.Text = string.format("Valid %s • %d direct children • %s", target.ClassName, childCount, fullName)
    objectPathStatus.TextColor3 = Theme.Green
    addRecentTarget(fullName)
end)

useRecentTargetButton.MouseButton1Click:Connect(function()
    local path = recentTargetsDropdown()
    if path and path ~= "No recent targets" then
        objectPathBox.Text = path
        objectPathStatus.Text = "Recent target loaded. Validate before saving."
        objectPathStatus.TextColor3 = Theme.Muted
    end
end)

useFavoriteTargetButton.MouseButton1Click:Connect(function()
    local path = favoriteTargetsDropdown()
    if path and path ~= "No favorites saved" then
        objectPathBox.Text = path
        objectPathStatus.Text = "Favorite loaded. Validate before saving."
        objectPathStatus.TextColor3 = Theme.Muted
    end
end)

addFavoriteButton.MouseButton1Click:Connect(function()
    if objectPathBox.Text == "" then
        if showToast then showToast("Enter or select an instance path first.", true) end
        return
    end
    local target, err = resolveInstancePath(objectPathBox.Text)
    if not target then
        objectPathStatus.Text = "Invalid path: " .. tostring(err)
        objectPathStatus.TextColor3 = Theme.Red
        return
    end
    local fullName = target:GetFullName()
    local added = addFavoriteTarget(fullName)
    if showToast then
        showToast(added and "Added instance to favorites." or "That instance is already a favorite.", false)
    end
end)

copyTargetPathButton.MouseButton1Click:Connect(function()
    if objectPathBox.Text == "" then
        if showToast then showToast("There is no instance path to copy.", true) end
        return
    end
    if type(setclipboard) == "function" then
        local ok = pcall(setclipboard, objectPathBox.Text)
        if showToast then showToast(ok and "Instance path copied." or "Clipboard copy failed.", not ok) end
    else
        if showToast then showToast("This executor does not expose setclipboard.", true) end
    end
end)

nameFromTargetButton.MouseButton1Click:Connect(function()
    local rawPath = objectPathBox.Text:match("^%s*(.-)%s*$")
    if rawPath == "" then
        if showToast then showToast("Select an instance first.", true) end
        return
    end
    local target, err = resolveInstancePath(rawPath)
    if not target then
        if showToast then showToast("Invalid target path: " .. tostring(err), true) end
        return
    end
    outputNameBox.Text = target.Name
    setSavedSetting("Custom output name", target.Name)
    if showToast then showToast("Output name set to " .. target.Name .. ".", false) end
end)

themeDropdown -- references the existing theme dropdown
themeDropdown.SetValues({ "Midnight Violet", "Ocean Blue", "Emerald", "Rose", "Amber" }, CurrentThemeName)


runButton.MouseButton1Click:Connect(function()
    if runButton:GetAttribute("Running") then return end
    local timeout = tonumber(timeoutBox.Text) or 10
    local byteTimeout = tonumber(bytecodeTimeoutBox.Text) or 3
    local compressionLevel = math.clamp(tonumber(compressionLevelBox.Text) or 9, -7, 22)
    local cacheInterval = math.max(1, tonumber(saveCacheBox.Text) or 56320)
    local targetObject = nil
    if objectPathBox.Text ~= "" then
        if browserSelectedInstance and objectPathBox.Text == browserSelectedPath then
            targetObject = browserSelectedInstance
        else
            local resolveError
            targetObject, resolveError = resolveInstancePath(objectPathBox.Text)
            if not targetObject then
                setStatus("Instance path error: " .. tostring(resolveError), Theme.Red)
                return
            end
        end
    end

    local selectedFormat = format()
    local isBinary = selectedFormat == "RBXL - Place (Binary)" or selectedFormat == "RBXM - Model (Binary)"
    local isModel = selectedFormat == "RBXM - Model (Binary)" or selectedFormat == "RBXMX - Model (XML)"

    if targetObject then
        local ok, targetName = pcall(function() return targetObject:GetFullName() end)
        if ok then addRecentTarget(targetName) end
    end

    local compressionMode = compression()
    if compressionMode == "None" then compressionMode = false end
    local options = {
        mode = mode(),
        Binary = isBinary,
        CompressionMode = compressionMode,
        CompressionLevel = compressionLevel,
        FilePath = outputNameBox.Text:match("^%s*(.-)%s*$") ~= "" and outputNameBox.Text:match("^%s*(.-)%s*$") or false,
        Object = targetObject or false,
        IsModel = isModel,
        SafeMode = safeMode(),
        ShowStatus = showStatus(),
        ReadMe = readme(),
        AvoidFileOverwrite = avoidOverwrite(),
        Decompile = decompile(),
        SaveBytecode = bytecode(),
        RecoverScriptsFromAssets = recoverAssets(),
        scriptcache = scriptCache(),
        DecompileTimeout = timeout,
        BytecodeTimeout = byteTimeout,
        NilInstances = nilInstances(),
        SavePlayerCharacters = saveCharacters(),
        IgnoreDefaultProperties = ignoreDefaults(),
        IgnoreSpecialProperties = ignoreSpecial(),
        AntiIdle = antiIdle(),
        CopyToClipboard = copyClipboard(),
        IsolateLocalPlayer = isolatePlayer(),
        IsolateStarterPlayer = isolateStarter(),
        ShutdownWhenDone = shutdown(),
        SaveCacheInterval = cacheInterval,
        WriteChunkSize = math.clamp(tonumber(writeChunkBox.Text) or 4, 1, 16) * 1024 * 1024,

        -- Additional supported engine options.
        -- Leave these nil unless enabled so SafeMode can apply its own defaults.
        KillAllScripts = killAllScripts() and true or nil,
        BoostFPS = boostFPS() and true or nil,
        IsolatePlayers = isolatePlayers(),
        IsolateLocalPlayerCharacter = isolateCharacter(),
        IgnoreDefaultPlayerScripts = ignoreDefaultScripts(),
        AlternativeWritefile = alternativeWrite(),
        SharedBinaryStrings = sharedBinary(),
        TreatUnionsAsParts = unionsAsParts(),
        IgnorePropertiesOfNotScriptsOnScriptsMode = scriptOnlyProperties(),
        Anonymous = anonymize(),
    }

    local selectedProfile = savePresetDropdown()
    if selectedProfile == "Fastest save" then
        options.Decompile = false
        options.SaveBytecode = false
        options.RecoverScriptsFromAssets = false
        options.CompressionMode = "lz4"
        options.CompressionLevel = 1
    elseif selectedProfile == "Smaller output" then
        options.CompressionMode = "zstd"
        options.CompressionLevel = 22
        options.SharedBinaryStrings = true
        options.IgnoreDefaultProperties = true
    elseif selectedProfile == "Maximum detail" then
        options.Decompile = true
        options.SaveBytecode = true
        options.RecoverScriptsFromAssets = true
        options.IgnoreDefaultProperties = false
    end

    saveRunning = true
    runButton:SetAttribute("Running", true)
    runButton.Text = "Saving..."
    runButton.BackgroundColor3 = Theme.Border
    setStatus("Save started. Detailed progress is shown in the USSI progress panel.", Theme.Accent, nil)
    task.spawn(function()
        local success, err = pcall(synsaveinstance, options)
        if success then
            setStatus("Save routine finished. Check the output file.", Theme.Green, 1)
            if showToast then showToast("Save completed successfully.", false) end
        else
            setStatus("Save failed: " .. tostring(err), Theme.Red)
            if showToast then showToast("Save failed. Check the F9 console.", true) end
            warn("[USSI GUI] Save failed: " .. tostring(err))
        end
        saveRunning = false
        runButton:SetAttribute("Running", false)
        runButton.Text = "Start save"
        runButton.BackgroundColor3 = Theme.Accent
    end)
end)


-- Drag the window from the title bar and resize it from the lower-right grip.
local dragging = false
local resizing = false
local dragInput
local dragStart
local startPosition
local startSize
local MIN_WIDTH, MIN_HEIGHT = 620, 440

local ResizeGrip = create("TextButton", {
    Name = "ResizeGrip",
    AutoButtonColor = false,
    BackgroundColor3 = Theme.Surface2,
    BackgroundTransparency = 0.15,
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -5, 1, -5),
    Size = UDim2.fromOffset(20, 20),
    Text = "◢",
    TextColor3 = Theme.Muted,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    ZIndex = 50,
}, Window)
corner(ResizeGrip, 5)

local function beginDrag(input)
    dragging = true
    resizing = false
    dragStart = input.Position
    startPosition = Window.Position
    dragInput = input
end

local function beginResize(input)
    resizing = true
    dragging = false
    dragStart = input.Position
    startSize = Window.Size
    dragInput = input
end

Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if input.Position.X < Topbar.AbsolutePosition.X + Topbar.AbsoluteSize.X - 58 then
            beginDrag(input)
        end
    end
end)

ResizeGrip.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        beginResize(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragInput then return end
    local isMatchingInput = input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
    if not isMatchingInput then return end

    local delta = input.Position - dragStart
    if dragging then
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
        local halfW, halfH = Window.AbsoluteSize.X / 2, Window.AbsoluteSize.Y / 2
        local x = math.clamp(startPosition.X.Offset + delta.X, -viewport.X / 2 + halfW, viewport.X / 2 - halfW)
        local y = math.clamp(startPosition.Y.Offset + delta.Y, -viewport.Y / 2 + halfH, viewport.Y / 2 - halfH)
        Window.Position = UDim2.new(startPosition.X.Scale, x, startPosition.Y.Scale, y)
    elseif resizing then
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
        local width = math.clamp(startSize.X.Offset + delta.X, MIN_WIDTH, viewport.X - 24)
        local height = math.clamp(startSize.Y.Offset + delta.Y, MIN_HEIGHT, viewport.Y - 24)
        Window.Size = UDim2.fromOffset(width, height)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        resizing = false
        dragInput = nil
    end
end)

-- Default to Overview.
switchPage("Overview")
setStartupStatus("USSI ready", "GUI and save engine loaded successfully.", 1)
task.delay(0.12, destroyStartupScreen)

print("[USSI GUI] " .. GUI_VERSION .. " loaded. UniversalSynSaveInstance https://discord.gg/wx4ThpAsmw")
