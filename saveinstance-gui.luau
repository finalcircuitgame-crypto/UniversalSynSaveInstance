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
local GUI_VERSION = "v1.4.0"

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
    return create("UIStroke", {
        Color = color or Theme.Border,
        Transparency = transparency or 0,
        Thickness = 1,
    }, parent)
end

local function tween(object, duration, style, direction, properties)
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
    local layout = create("UIListLayout", {
        Padding = UDim.new(0, 11),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, card)
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
    local boxStroke = stroke(box)
    box.Focused:Connect(function()
        tween(boxStroke, 0.16, nil, nil, { Color = Theme.Accent, Transparency = 0 })
        tween(box, 0.16, nil, nil, { BackgroundColor3 = Theme.Surface })
    end)
    box.FocusLost:Connect(function()
        tween(boxStroke, 0.16, nil, nil, { Color = Theme.Border, Transparency = 0 })
        tween(box, 0.16, nil, nil, { BackgroundColor3 = Theme.Surface2 })
    end)
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
        TweenService:Create(toggle, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = value and Theme.Accent or Theme.Border
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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
        ClipsDescendants = false,
    }, parent)
    label(wrap, title, 12, Theme.Muted)
    local selected = default or values[1]
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
    Size = UDim2.fromOffset(800, 560),
    BackgroundColor3 = Theme.Background,
    ClipsDescendants = true,
}, ScreenGui)
corner(Window, 14)
stroke(Window, Theme.Border)
local WindowScale = create("UIScale", {Scale = 0.94}, Window)
TweenService:Create(WindowScale, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Scale = 1
}):Play()

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
local close = button(Topbar, "×", 30, false)
close.Size = UDim2.fromOffset(32, 30)
close.Position = UDim2.new(1, -44, 0, 14)
close.TextSize = 20
close.MouseButton1Click:Connect(function()
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
        pageScale = create("UIScale", { Scale = 0.985 }, page)
    else
        pageScale.Scale = 0.985
    end
    tween(pageScale, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { Scale = 1 })

    -- Soft staggered card entrance whenever a page is opened.
    for index, child in ipairs(page:GetChildren()) do
        if child:IsA("Frame") then
            local cardScale = child:FindFirstChildOfClass("UIScale")
            if not cardScale then cardScale = create("UIScale", { Scale = 0.97 }, child) end
            cardScale.Scale = 0.97
            task.delay(math.min((index - 1) * 0.035, 0.14), function()
                if child.Parent and page.Visible then
                    tween(cardScale, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out, { Scale = 1 })
                end
            end)
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
local aboutPage = makePage("About")

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

local outputCard = makeCard(savePage, "OUTPUT", "Choose the file type, save mode, compression, and destination.")
local format = makeDropdown(outputCard, "Output format", {"Binary (.rbxl / .rbxm)", "XML (.rbxlx / .rbxmx)"}, "Binary (.rbxl / .rbxm)")
local mode = makeDropdown(outputCard, "Save mode", {"optimized", "full", "scripts"}, "optimized")
local compression = makeDropdown(outputCard, "Compression", {"zstd", "lz4", "None"}, "zstd")
local pathBox = makeInput(outputCard, "File path", "workspace/PlaceName", "")
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

local about = makeCard(aboutPage, "About this interface", "A standalone executor interface for the existing Universal Syn Save Instance project.")
label(about, "Engine: saveinstance.luau", 12, Theme.Text)
label(about, "UI: saveinstance-gui.luau  •  " .. GUI_VERSION, 12, Theme.Text)
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

print("[USSI GUI] " .. GUI_VERSION .. " loaded. UniversalSynSaveInstance https://discord.gg/wx4ThpAsmw")
