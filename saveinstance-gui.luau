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
local GUI_VERSION = "v1.10.0"

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
        TweenService:Create(toggle, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = value and Theme.Accent or Theme.Border
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = value and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
        }):Play()
    end
    render()
    toggle.MouseButton1Click:Connect(function()
        value = not value
        render()
        setSavedSetting(title, value)
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
    selectionLabel.Size = UDim2.new(1, -185, 0, 20)
    selectionLabel.TextTruncate = Enum.TextTruncate.AtEnd
    selectionLabel.ZIndex = 63

    local useSelection = create("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = Theme.Accent,
        Position = UDim2.new(1, -153, 1, -43),
        Size = UDim2.fromOffset(135, 30),
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
        table.sort(roots, function(a, b) return string.lower(a.Name) < string.lower(b.Name) end)

        local function addBranch(instance, depth)
            addTreeRow(instance, depth, false)
            if expanded[instance] then
                local children = instance:GetChildren()
                table.sort(children, function(a, b) return string.lower(a.Name) < string.lower(b.Name) end)
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
            for _, instance in ipairs(descendants) do
                scanned = scanned + 1
                if string.find(string.lower(instance.Name), query, 1, true) then
                    table.insert(matches, instance)
                    if #matches >= 120 then break end
                end
                if scanned % 2500 == 0 then
                    task.wait()
                    if generation ~= searchGeneration or not overlay.Parent then return end
                end
            end

            if generation ~= searchGeneration or not overlay.Parent then return end
            clearTreeRows()
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
        overlay:Destroy()
    end)

    refreshTree()
end

browseInstancesButton.MouseButton1Click:Connect(openInstanceBrowser)

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
