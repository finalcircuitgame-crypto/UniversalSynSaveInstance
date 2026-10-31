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

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Existing = nil
local GUI_PARENT = CoreGui

pcall(function()
    if gethui then GUI_PARENT = gethui() end
    Existing = GUI_PARENT:FindFirstChild(GUI_NAME)
    if Existing then Existing:Destroy() end
end)

local function loadEngine()
    local source = game:HttpGet(REPO .. "saveinstance.luau", true)
    local chunk, err = loadstring(source, "USSI")
    assert(chunk, err)
    return chunk()
end

local ok, synsaveinstance = pcall(loadEngine)
if not ok then
    warn("[USSI GUI] Could not load save engine: " .. tostring(synsaveinstance))
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

local function create(className, props, parent)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    create("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
end

local function stroke(parent, color, transparency)
    create("UIStroke", {
        Color = color or Theme.Border,
        Transparency = transparency or 0,
        Thickness = 1,
    }, parent)
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
    if not primary then stroke(b) end
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {
            BackgroundColor3 = primary and Theme.AccentHover or Theme.Border
        }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {
            BackgroundColor3 = primary and Theme.Accent or Theme.Surface2
        }):Play()
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
        PaddingTop = UDim.new(0, 13),
        PaddingBottom = UDim.new(0, 13),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
    }, card)
    local layout = create("UIListLayout", {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, card)
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
    label(wrap, title, 12, Theme.Muted)
    local box = create("TextBox", {
        BackgroundColor3 = Theme.Surface2,
        Position = UDim2.fromOffset(0, 23),
        Size = UDim2.new(1, 0, 0, 32),
        ClearTextOnFocus = false,
        Text = initial or "",
        PlaceholderText = placeholder or "",
        PlaceholderColor3 = Theme.Muted,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, wrap)
    corner(box, 7)
    stroke(box)
    create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, box)
    return box
end

local function makeToggle(parent, title, description, default)
    local row = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, description and 48 or 34),
    }, parent)
    local titleLabel = label(row, title, 12, Theme.Text, Enum.Font.GothamMedium)
    titleLabel.Size = UDim2.new(1, -58, 0, 18)
    if description then
        local desc = label(row, description, 10, Theme.Muted)
        desc.Position = UDim2.fromOffset(0, 20)
        desc.Size = UDim2.new(1, -58, 0, 24)
        desc.TextWrapped = true
        desc.TextYAlignment = Enum.TextYAlignment.Top
    end
    local toggle = create("TextButton", {
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(40, 22),
        BackgroundColor3 = default and Theme.Accent or Theme.Border,
        Text = "",
    }, row)
    corner(toggle, 20)
    local knob = create("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        Size = UDim2.fromOffset(16, 16),
        Position = default and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3),
    }, toggle)
    corner(knob, 20)
    local value = default == true
    local function render()
        TweenService:Create(toggle, TweenInfo.new(0.12), {
            BackgroundColor3 = value and Theme.Accent or Theme.Border
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.12), {
            Position = value and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
        }):Play()
    end
    toggle.MouseButton1Click:Connect(function()
        value = not value
        render()
    end)
    return function() return value end
end

local function makeDropdown(parent, title, values, default)
    local wrap = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 57),
    }, parent)
    label(wrap, title, 12, Theme.Muted)
    local selected = default or values[1]
    local drop = button(wrap, selected .. "   ▾", 32, false)
    drop.Position = UDim2.fromOffset(0, 23)
    drop.TextXAlignment = Enum.TextXAlignment.Left
    create("UIPadding", { PaddingLeft = UDim.new(0, 10) }, drop)
    local menu
    drop.MouseButton1Click:Connect(function()
        if menu then menu:Destroy() menu = nil return end
        menu = create("Frame", {
            BackgroundColor3 = Theme.Surface2,
            Position = UDim2.new(0, 0, 1, 4),
            Size = UDim2.new(1, 0, 0, #values * 30),
            ZIndex = 20,
        }, wrap)
        corner(menu, 7)
        stroke(menu)
        for index, item in ipairs(values) do
            local choice = create("TextButton", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, (index - 1) * 30),
                Size = UDim2.new(1, 0, 0, 30),
                Text = item,
                TextColor3 = Theme.Text,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                ZIndex = 21,
            }, menu)
            choice.MouseButton1Click:Connect(function()
                selected = item
                drop.Text = selected .. "   ▾"
                menu:Destroy()
                menu = nil
            end)
        end
    end)
    return function() return selected end
end

local ScreenGui = create("ScreenGui", {
    Name = GUI_NAME,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false,
}, GUI_PARENT)

local Window = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(760, 520),
    BackgroundColor3 = Theme.Background,
    ClipsDescendants = true,
}, ScreenGui)
corner(Window, 14)
stroke(Window, Theme.Border)

local Topbar = create("Frame", {
    BackgroundColor3 = Theme.Surface,
    Size = UDim2.new(1, 0, 0, 58),
}, Window)
local topTitle = label(Topbar, "  USSI", 17, Theme.Text, Enum.Font.GothamBold)
topTitle.Position = UDim2.fromOffset(15, 8)
topTitle.Size = UDim2.new(0, 150, 0, 22)
local topSubtitle = label(Topbar, "UNIVERSAL SYN SAVE INSTANCE", 9, Theme.Muted, Enum.Font.GothamMedium)
topSubtitle.Position = UDim2.fromOffset(17, 31)
topSubtitle.Size = UDim2.new(0, 260, 0, 15)
local close = button(Topbar, "×", 30, false)
close.Size = UDim2.fromOffset(32, 30)
close.Position = UDim2.new(1, -44, 0, 14)
close.TextSize = 20
close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

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
local activePage
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
    create("UIListLayout", { Padding = UDim.new(0, 11), SortOrder = Enum.SortOrder.LayoutOrder }, page)
    pages[name] = page
    local nav = button(Sidebar, name, 36, false)
    nav.LayoutOrder = #pages
    nav.MouseButton1Click:Connect(function()
        if activePage then activePage.Visible = false end
        activePage = page
        page.Visible = true
        for pageName, pageButton in pairs(pages) do
            -- Nav colors are handled by the selected page's visibility.
        end
        nav.BackgroundColor3 = Theme.Accent
    end)
    return page
end

local home = makePage("Overview")
local savePage = makePage("Save")
local optionsPage = makePage("Options")
local advancedPage = makePage("Advanced")
local aboutPage = makePage("About")

local statusText = "Ready"
local statusLabel = label(home, "●  " .. statusText, 12, Theme.Green, Enum.Font.GothamMedium)
local hero = makeCard(home, "Save your experience", "Configure a save and run it through the original USSI engine. The interface does not replace or modify the serializer.")
local heroButton = button(hero, "Open save settings  →", 38, true)
heroButton.MouseButton1Click:Connect(function()
    if activePage then activePage.Visible = false end
    activePage = savePage
    savePage.Visible = true
end)

local info = makeCard(home, "Session", "Current place details")
label(info, "Place: " .. game.Name, 12, Theme.Text)
label(info, "Place ID: " .. tostring(game.PlaceId), 11, Theme.Muted)
label(info, "Job ID: " .. (game.JobId ~= "" and game.JobId or "Studio / local session"), 10, Theme.Muted)

local format = makeDropdown(savePage, "Output format", {"Binary (.rbxl / .rbxm)", "XML (.rbxlx / .rbxmx)"}, "Binary (.rbxl / .rbxm)")
local mode = makeDropdown(savePage, "Save mode", {"optimized", "full", "scripts"}, "optimized")
local compression = makeDropdown(savePage, "Compression", {"zstd", "lz4", "None"}, "zstd")
local pathBox = makeInput(savePage, "File path", "workspace/PlaceName", "")
local safeMode = makeToggle(savePage, "Safe mode", "Disconnects the local player while saving; enables protective save settings.", false)
local showStatus = makeToggle(savePage, "Show status", "Display save progress on screen.", true)
local readme = makeToggle(savePage, "Include README", "Add save details and warnings to the output.", true)
local avoidOverwrite = makeToggle(savePage, "Avoid overwriting", "Append a number when a file with the same name exists.", true)

local decompile = makeToggle(optionsPage, "Decompile scripts", "Attempt to recover readable source for scripts.", true)
local bytecode = makeToggle(optionsPage, "Save bytecode", "Include compiled bytecode when the executor supports it.", false)
local recoverAssets = makeToggle(optionsPage, "Recover published scripts", "Try to recover original source from published script assets.", true)
local scriptCache = makeToggle(optionsPage, "Cache decompilation", "Reuse decompiled source during this and later runs.", true)
local nilInstances = makeToggle(optionsPage, "Save nil instances", "Include unparented instances when getnilinstances is available.", false)
local saveCharacters = makeToggle(optionsPage, "Save player characters", "Include player characters that are normally skipped.", false)
local ignoreDefaults = makeToggle(optionsPage, "Ignore default properties", "Reduce XML size by skipping properties at their class defaults.", true)
local ignoreSpecial = makeToggle(optionsPage, "Ignore special properties", "Avoid executor hidden-property reads.", false)
local antiIdle = makeToggle(optionsPage, "Anti-idle", "Prevent the normal idle kick while the save is running.", true)

local timeoutBox = makeInput(advancedPage, "Decompile timeout (seconds)", "10", "10")
local bytecodeTimeoutBox = makeInput(advancedPage, "Bytecode timeout (seconds)", "3", "3")
local compressionLevelBox = makeInput(advancedPage, "Compression level (-7 to 22)", "9", "9")
local saveCacheBox = makeInput(advancedPage, "Save cache interval", "56320", "56320")
local copyClipboard = makeToggle(advancedPage, "Copy to clipboard", "Requires executor clipboard support. Best for small saves.", false)
local isolatePlayer = makeToggle(advancedPage, "Isolate local player", "Save the local player as a Folder instead of a Player instance.", false)
local isolateStarter = makeToggle(advancedPage, "Isolate StarterPlayer", "Move StarterPlayer children into a top-level folder.", false)
local shutdown = makeToggle(advancedPage, "Shutdown when done", "Close the game after a successful save.", false)

local about = makeCard(aboutPage, "About this interface", "A standalone executor interface for the existing Universal Syn Save Instance project.")
label(about, "Engine: saveinstance.luau", 12, Theme.Text)
label(about, "UI: saveinstance-gui.luau", 12, Theme.Text)
label(about, "This fork is unofficial and is not affiliated with Roblox Corporation.", 11, Theme.Muted)
label(about, "UniversalSynSaveInstance https://discord.gg/wx4ThpAsmw", 10, Theme.Muted)
local repoButton = button(about, "Open project repository", 34, false)
repoButton.MouseButton1Click:Connect(function()
    if setclipboard then pcall(setclipboard, "https://github.com/finalcircuitgame-crypto/UniversalSynSaveInstance") end
end)

local runCard = makeCard(savePage, "Ready to save?", "Check your settings before starting. Large experiences can take a while and may use substantial memory.")
local runButton = button(runCard, "Start save", 42, true)
local runStatus = label(runCard, "Waiting for configuration.", 11, Theme.Muted)

local function setStatus(message, color)
    statusLabel.Text = "●  " .. message
    statusLabel.TextColor3 = color or Theme.Green
    runStatus.Text = message
    runStatus.TextColor3 = color or Theme.Muted
end

runButton.MouseButton1Click:Connect(function()
    if runButton:GetAttribute("Running") then return end
    local timeout = tonumber(timeoutBox.Text) or 10
    local byteTimeout = tonumber(bytecodeTimeoutBox.Text) or 3
    local compressionLevel = math.clamp(tonumber(compressionLevelBox.Text) or 9, -7, 22)
    local cacheInterval = math.max(1, tonumber(saveCacheBox.Text) or 56320)
    local isBinary = format() == "Binary (.rbxl / .rbxm)"
    local compressionMode = compression()
    if compressionMode == "None" then compressionMode = false end
    local options = {
        mode = mode(),
        Binary = isBinary,
        CompressionMode = compressionMode,
        CompressionLevel = compressionLevel,
        FilePath = pathBox.Text ~= "" and pathBox.Text or false,
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
    }
    runButton:SetAttribute("Running", true)
    runButton.Text = "Saving..."
    runButton.BackgroundColor3 = Theme.Border
    setStatus("Save started. Check the USSI status display and F9 console.", Theme.Accent)
    task.spawn(function()
        local success, err = pcall(synsaveinstance, options)
        if success then
            setStatus("Save routine finished. Check the output file.", Theme.Green)
        else
            setStatus("Save failed: " .. tostring(err), Theme.Red)
            warn("[USSI GUI] Save failed: " .. tostring(err))
        end
        runButton:SetAttribute("Running", false)
        runButton.Text = "Start save"
        runButton.BackgroundColor3 = Theme.Accent
    end)
end)

-- Drag the window from its title bar.
do
    local dragging = false
    local dragStart, startPosition
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = Window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end)
end

-- Default to Overview.
activePage = home
home.Visible = true

print("[USSI GUI] Loaded. UniversalSynSaveInstance https://discord.gg/wx4ThpAsmw")
