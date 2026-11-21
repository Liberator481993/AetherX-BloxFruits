local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Theme = require(script.Parent.Theme)

local UI = {}
local C = Theme.Colors
local D = Theme.Dimensions

local function make(className, properties, parent)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do object[key] = value end
    object.Parent = parent
    return object
end

local function round(parent, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius)}, parent)
end

local function outline(parent, color, transparency)
    make("UIStroke", {
        Color = color or C.Border,
        Transparency = transparency or 0.35,
        Thickness = 1
    }, parent)
end

local reduceMotion = false

local function animate(object, duration, properties)
    if reduceMotion then
        for key, value in pairs(properties) do object[key] = value end
        return nil
    end
    local tween = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

local function bindHover(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        animate(button, 0.12, {BackgroundColor3 = hoverColor})
    end)
    button.MouseLeave:Connect(function()
        animate(button, 0.12, {BackgroundColor3 = normalColor})
    end)
end

local function label(parent, text, size, position, dimensions, font, color)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Position = position,
        Size = dimensions,
        Font = font or Theme.Font.Body,
        Text = text,
        TextColor3 = color or C.Text,
        TextSize = size,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, parent)
end

local function card(parent, height)
    local frame = make("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = C.Surface,
        BorderSizePixel = 0
    }, parent)
    round(frame, 13)
    outline(frame, C.Border, 0.55)
    return frame
end

local function createPage(parent, name)
    local page = make("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = C.Violet,
        ScrollBarImageTransparency = 0.18,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
        CanvasSize = UDim2.new(),
        Visible = false
    }, parent)
    make("UIPadding", {
        PaddingTop = UDim.new(0, 16),
        PaddingBottom = UDim.new(0, 16),
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16)
    }, page)
    local layout = make("UIListLayout", {
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 32)
    end)
    return page
end

local function addSection(parent, title, subtitle)
    local holder = make("Frame", {
        Size = UDim2.new(1, 0, 0, subtitle and 49 or 29),
        BackgroundTransparency = 1
    }, parent)
    label(holder, title, 18, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 25), Theme.Font.Heading)
    if subtitle then
        label(holder, subtitle, 10, UDim2.fromOffset(0, 27), UDim2.new(1, 0, 0, 17), Theme.Font.Body, C.Muted)
    end
    return holder
end

local function addInfo(parent, title, description, height)
    local box = card(parent, height or 70)
    label(box, title, 12, UDim2.fromOffset(15, 10), UDim2.new(1, -30, 0, 20), Theme.Font.Strong)
    local desc = label(box, description, 10, UDim2.fromOffset(15, 33), UDim2.new(1, -30, 0, (height or 70) - 39), Theme.Font.Body, C.Muted)
    desc.TextWrapped = true
    desc.TextYAlignment = Enum.TextYAlignment.Top
    local accent = make("Frame", {
        Position = UDim2.fromOffset(0, 12),
        Size = UDim2.new(0, 3, 1, -24),
        BackgroundColor3 = C.Violet,
        BackgroundTransparency = 0.28,
        BorderSizePixel = 0
    }, box)
    round(accent, 3)
    return box
end

local function addToggle(parent, title, description, initial, callback)
    local box = card(parent, 72)
    local titleLabel = label(box, title, 12, UDim2.fromOffset(15, 10), UDim2.new(1, -100, 0, 20), Theme.Font.Strong)
    local descriptionLabel = label(box, description, 9, UDim2.fromOffset(15, 35), UDim2.new(1, -145, 0, 18), Theme.Font.Body, C.Muted)
    descriptionLabel.TextWrapped = true
    descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
    local stateLabel = label(box, initial and "ON" or "OFF", 9,
        UDim2.new(1, -108, 0.5, -8), UDim2.fromOffset(35, 16),
        Theme.Font.Strong, initial and C.Cyan or C.Muted)
    stateLabel.TextXAlignment = Enum.TextXAlignment.Center

    local track = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -15, 0.5, 0),
        Size = UDim2.fromOffset(48, 27),
        BackgroundColor3 = initial and C.Violet or C.SurfaceRaised,
        Text = "",
        AutoButtonColor = false
    }, box)
    round(track, 15)
    local knob = make("Frame", {
        Position = initial and UDim2.fromOffset(24, 3) or UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(21, 21),
        BackgroundColor3 = C.Text,
        BorderSizePixel = 0
    }, track)
    round(knob, 12)

    local function updateLayout()
        if box.AbsoluteSize.X < 280 then
            box.Size = UDim2.new(1, 0, 0, 104)
            titleLabel.Size = UDim2.new(1, -30, 0, 20)
            descriptionLabel.Position = UDim2.fromOffset(15, 34)
            descriptionLabel.Size = UDim2.new(1, -30, 0, 32)
            stateLabel.Position = UDim2.fromOffset(15, 78)
            track.AnchorPoint = Vector2.new(1, 1)
            track.Position = UDim2.new(1, -15, 1, -10)
        else
            box.Size = UDim2.new(1, 0, 0, 72)
            titleLabel.Size = UDim2.new(1, -145, 0, 20)
            descriptionLabel.Position = UDim2.fromOffset(15, 35)
            descriptionLabel.Size = UDim2.new(1, -145, 0, 18)
            stateLabel.Position = UDim2.new(1, -108, 0.5, -8)
            track.AnchorPoint = Vector2.new(1, 0.5)
            track.Position = UDim2.new(1, -15, 0.5, 0)
        end
    end
    box:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout)
    updateLayout()

    local value = initial == true
    local function setValue(nextValue)
        value = nextValue
        stateLabel.Text = value and "ON" or "OFF"
        stateLabel.TextColor3 = value and C.Cyan or C.Muted
        animate(track, 0.16, {BackgroundColor3 = value and C.Violet or C.SurfaceRaised})
        animate(knob, 0.16, {Position = value and UDim2.fromOffset(24, 3) or UDim2.fromOffset(3, 3)})
        callback(value)
    end
    track.Activated:Connect(function() setValue(not value) end)
    return setValue
end

local function addAction(parent, title, description, buttonText, callback)
    local box = card(parent, 74)
    local titleLabel = label(box, title, 12, UDim2.fromOffset(15, 9), UDim2.new(1, -142, 0, 20), Theme.Font.Strong)
    local descriptionLabel = label(box, description, 9, UDim2.fromOffset(15, 34), UDim2.new(1, -142, 0, 25), Theme.Font.Body, C.Muted)
    descriptionLabel.TextWrapped = true

    local button = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(112, 40),
        BackgroundColor3 = C.SurfaceRaised,
        Text = buttonText,
        TextColor3 = C.Text,
        TextSize = 10,
        Font = Theme.Font.Strong,
        AutoButtonColor = false
    }, box)
    round(button, 9)
    outline(button, C.Violet, 0.35)
    bindHover(button, C.SurfaceRaised, C.SurfaceHover)

    local function updateLayout()
        if box.AbsoluteSize.X < 280 then
            box.Size = UDim2.new(1, 0, 0, 112)
            titleLabel.Position = UDim2.fromOffset(15, 8)
            titleLabel.Size = UDim2.new(1, -30, 0, 20)
            descriptionLabel.Position = UDim2.fromOffset(15, 31)
            descriptionLabel.Size = UDim2.new(1, -30, 0, 25)
            button.AnchorPoint = Vector2.new(1, 1)
            button.Position = UDim2.new(1, -14, 1, -9)
            button.Size = UDim2.fromOffset(112, 40)
        else
            box.Size = UDim2.new(1, 0, 0, 74)
            titleLabel.Position = UDim2.fromOffset(15, 9)
            titleLabel.Size = UDim2.new(1, -142, 0, 20)
            descriptionLabel.Position = UDim2.fromOffset(15, 34)
            descriptionLabel.Size = UDim2.new(1, -142, 0, 25)
            button.AnchorPoint = Vector2.new(1, 0.5)
            button.Position = UDim2.new(1, -14, 0.5, 0)
            button.Size = UDim2.fromOffset(112, 40)
        end
    end
    box:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLayout)
    updateLayout()
    button.Activated:Connect(callback)
end

function UI.Mount(config)
    assert(type(config) == "table", "UI.Mount expects a configuration table")
    assert(type(config.OnFruitEspChanged) == "function", "OnFruitEspChanged callback is required")
    assert(type(config.OnFruitScan) == "function", "OnFruitScan callback is required")
    assert(type(config.GetDiagnostics) == "function", "GetDiagnostics callback is required")

    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local old = playerGui:FindFirstChild("AetherX")
    if old then old:Destroy() end

    local screen = make("ScreenGui", {
        Name = "AetherX",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 90,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, playerGui)

    local launcher = make("TextButton", {
        Name = "Launcher",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -18, 0.5, 0),
        Size = UDim2.fromOffset(52, 52),
        BackgroundColor3 = C.Surface,
        Text = "AX",
        TextColor3 = C.Text,
        TextSize = 17,
        Font = Theme.Font.Heading,
        Visible = false,
        AutoButtonColor = false
    }, screen)
    round(launcher, 18)
    outline(launcher, C.Violet, 0.05)

    local main = make("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.52),
        Size = UDim2.fromOffset(D.DesktopWidth, D.DesktopHeight),
        BackgroundColor3 = C.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, screen)
    round(main, 17)
    outline(main, C.Border, 0.2)

    local scale = make("UIScale", {Scale = 1}, main)
    local sidebarWidth = D.SidebarWidth
    local sidebar, content
    local navRefs = {}
    local compactMode = false
    local brandTitle, brandSubtitle, statusDot, statusText, accentBar

    local function resize()
        local camera = Workspace.CurrentCamera
        if not camera then return end
        local viewport = camera.ViewportSize
        compactMode = viewport.X < 600 or viewport.Y < 460
        local baseWidth = compactMode and D.MobileWidth or D.DesktopWidth
        local baseHeight = compactMode and D.MobileHeight or D.DesktopHeight
        sidebarWidth = compactMode and 112 or D.SidebarWidth

        local widthScale = math.max(0, viewport.X - 20) / baseWidth
        local heightScale = math.max(0, viewport.Y - 76) / baseHeight
        scale.Scale = math.max(0.35, math.min(widthScale, heightScale, 1))
        main.Size = UDim2.fromOffset(baseWidth, baseHeight)

        if sidebar then
            sidebar.Size = UDim2.new(0, sidebarWidth, 1, -D.HeaderHeight)
        end
        if content then
            content.Position = UDim2.fromOffset(sidebarWidth, D.HeaderHeight)
            content.Size = UDim2.new(1, -sidebarWidth, 1, -D.HeaderHeight)
        end

        if brandTitle then
            brandTitle.Position = compactMode and UDim2.fromOffset(16, 7) or UDim2.fromOffset(22, 8)
            brandTitle.Size = compactMode and UDim2.fromOffset(132, 27) or UDim2.fromOffset(240, 27)
            brandTitle.TextSize = compactMode and 17 or 21
        end
        if brandSubtitle then
            brandSubtitle.Position = compactMode and UDim2.fromOffset(16, 37) or UDim2.fromOffset(93, 37)
            brandSubtitle.Size = compactMode and UDim2.fromOffset(190, 16) or UDim2.fromOffset(190, 16)
        end
        if statusDot then statusDot.Visible = not compactMode end
        if statusText then statusText.Visible = not compactMode end
        if accentBar then accentBar.Visible = not compactMode end

        for _, refs in pairs(navRefs) do
            if refs.Icon then
                refs.Icon.Position = compactMode and UDim2.new(0.5, -12, 0, 0) or UDim2.fromOffset(13, 0)
            end
            if refs.Label then refs.Label.Visible = not compactMode end
        end
    end
    local viewportConnection
    local cameraConnection
    local function bindCamera()
        if viewportConnection then viewportConnection:Disconnect() end
        if Workspace.CurrentCamera then
            viewportConnection = Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
        end
        if sidebar and content then resize() end
    end
    cameraConnection = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
    bindCamera()

    local header = make("Frame", {
        Size = UDim2.new(1, 0, 0, D.HeaderHeight),
        BackgroundColor3 = C.Surface,
        BorderSizePixel = 0
    }, main)
    make("UIGradient", {
        Color = ColorSequence.new(C.SurfaceRaised, C.Surface),
        Rotation = 0
    }, header)

    brandTitle = label(header, "AETHER X", 21, UDim2.fromOffset(22, 8), UDim2.fromOffset(240, 27), Theme.Font.Heading)
    accentBar = make("Frame", {
        Position = UDim2.fromOffset(23, 43),
        Size = UDim2.fromOffset(58, 3),
        BackgroundColor3 = C.Violet,
        BorderSizePixel = 0
    }, header)
    round(accentBar, 3)
    make("UIGradient", {Color = ColorSequence.new(C.Violet, C.Cyan)}, accentBar)
    brandSubtitle = label(header, "BLOX FRUITS  •  v0.2.0", 9, UDim2.fromOffset(93, 37), UDim2.fromOffset(190, 16), Theme.Font.Medium, C.Muted)

    statusDot = make("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -91, 0.5, 0),
        Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = C.Green,
        BorderSizePixel = 0
    }, header)
    round(statusDot, 5)
    statusText = label(header, "UI ONLINE", 9, UDim2.new(1, -83, 0.5, -9), UDim2.fromOffset(75, 18), Theme.Font.Medium, C.Muted)

    local close = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(34, 34),
        BackgroundColor3 = C.SurfaceRaised,
        Text = "×",
        TextColor3 = C.Text,
        TextSize = 23,
        Font = Theme.Font.Body,
        AutoButtonColor = false
    }, header)
    round(close, 10)
    bindHover(close, C.SurfaceRaised, C.SurfaceHover)

    sidebar = make("Frame", {
        Position = UDim2.fromOffset(0, D.HeaderHeight),
        Size = UDim2.new(0, D.SidebarWidth, 1, -D.HeaderHeight),
        BackgroundColor3 = C.Surface,
        BorderSizePixel = 0
    }, main)
    local navLayout = make("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, sidebar)
    make("UIPadding", {
        PaddingTop = UDim.new(0, 18),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12)
    }, sidebar)

    content = make("Frame", {
        Position = UDim2.fromOffset(sidebarWidth, D.HeaderHeight),
        Size = UDim2.new(1, -sidebarWidth, 1, -D.HeaderHeight),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    }, main)

    resize()

    local pageNames = {"Overview", "Fruits", "Farm", "Settings", "Diagnostics"}
    local icons = {Overview = "⌂", Fruits = "✦", Farm = "⚔", Settings = "⚙", Diagnostics = "⌁"}
    local pages = {}
    local currentPage = "Overview"

    for index, name in ipairs(pageNames) do
        pages[name] = createPage(content, name)
        local nav = make("TextButton", {
            LayoutOrder = index,
            Size = UDim2.new(1, 0, 0, 43),
            BackgroundColor3 = C.Surface,
            Text = "",
            AutoButtonColor = false
        }, sidebar)
        round(nav, 10)
        local indicator = make("Frame", {
            Position = UDim2.fromOffset(0, 9),
            Size = UDim2.fromOffset(3, 25),
            BackgroundColor3 = C.Violet,
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        }, nav)
        round(indicator, 3)
        local iconLabel = label(nav, icons[name], 15, UDim2.fromOffset(13, 0), UDim2.fromOffset(24, 43), Theme.Font.Strong, C.Muted)
        local textLabel = label(nav, name, 11, UDim2.fromOffset(44, 0), UDim2.new(1, -50, 1, 0), Theme.Font.Medium, C.Muted)
        navRefs[name] = {Button = nav, Indicator = indicator, Label = textLabel, Icon = iconLabel}
        nav.MouseEnter:Connect(function()
            if currentPage ~= name then
                animate(nav, 0.12, {BackgroundColor3 = C.SurfaceHover})
            end
        end)
        nav.MouseLeave:Connect(function()
            if currentPage ~= name then
                animate(nav, 0.12, {BackgroundColor3 = C.Surface})
            end
        end)
        nav.Activated:Connect(function()
            if currentPage == name then return end
            currentPage = name
            for pageName, page in pairs(pages) do
                local selected = pageName == name
                page.Visible = selected
                if selected then
                    page.Position = UDim2.fromOffset(9, 0)
                    animate(page, 0.16, {Position = UDim2.fromOffset(0, 0)})
                end
            end
            for navName, refs in pairs(navRefs) do
                local selected = navName == name
                animate(refs.Button, 0.16, {BackgroundColor3 = selected and C.SurfaceRaised or C.Surface})
                animate(refs.Indicator, 0.16, {BackgroundTransparency = selected and 0 or 1})
                refs.Label.TextColor3 = selected and C.Text or C.Muted
                refs.Icon.TextColor3 = selected and C.Cyan or C.Muted
            end
        end)
    end

    -- Apply the current viewport mode after all responsive references exist.
    resize()

    -- Overview page
    local home = pages.Overview
    addSection(home, "Welcome back", "Your compact control center")
    local hero = card(home, 112)
    make("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 31, 83)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 57, 76))
        }),
        Rotation = 12
    }, hero)
    label(hero, "AETHER X", 25, UDim2.fromOffset(17, 13), UDim2.new(1, -34, 0, 31), Theme.Font.Heading)
    label(hero, "A refined Blox Fruits companion interface.", 11, UDim2.fromOffset(18, 49), UDim2.new(1, -36, 0, 21), Theme.Font.Medium, Color3.fromRGB(218, 222, 244))
    label(hero, "MOBILE FIRST   •   MODULAR   •   v0.2.0", 9, UDim2.fromOffset(18, 79), UDim2.new(1, -36, 0, 16), Theme.Font.Medium, Color3.fromRGB(192, 185, 255))
    addSection(home, "Modules", "Only features that are implemented are shown as available")
    addInfo(home, "Fruit radar", "Strict fruit-model allowlist. Off by default; map meshes and unrelated objects are ignored.", 72)
    addInfo(home, "Diagnostics", "Client state, character readiness, and current ESP marker count.", 72)

    -- Fruits page
    local fruits = pages.Fruits
    addSection(fruits, "Fruit radar", "Opt-in detection with strict name matching")
    local fruitToggle
    fruitToggle = addToggle(fruits, "Fruit ESP", "Highlight confirmed fruit models only", false, function(enabled)
        config.OnFruitEspChanged(enabled)
    end)
    addInfo(fruits, "Detection rules", "Only exact known fruit names on Model instances are accepted. Generic map meshes and names containing the word 'fruit' are not enough.", 86)
    addAction(fruits, "Scan workspace", "Count valid fruit markers while ESP is enabled", "SCAN", function()
        config.OnFruitScan()
    end)

    -- Farm page: explicit honest roadmap, no fake controls.
    local farm = pages.Farm
    addSection(farm, "Farm systems", "Modules are being built and tested independently")
    addInfo(farm, "Auto Farm", "Not available in this build. Target selection, combat behavior, and safe movement require separate implementation and in-game validation.", 96)
    addInfo(farm, "Auto Quest", "Not available in this build. Quest selection and NPC interactions are not wired yet.", 88)
    addInfo(farm, "Combat / movement", "No inactive buttons pretending to work. Each module will appear here after it is implemented.", 78)

    -- Settings page
    local settings = pages.Settings
    addSection(settings, "Preferences", "Interface controls")
    addAction(settings, "Reset window", "Center the hub and restore the default layout", "RESET", function()
        main.Position = UDim2.fromScale(0.5, 0.52)
        main.Visible = true
        launcher.Visible = false
    end)
    addToggle(settings, "Reduce animations", "Disable interface tweens for a calmer, lower-motion experience", false, function(enabled)
        reduceMotion = enabled
    end)
    addInfo(settings, "Responsive layout", "Navigation automatically switches to icon-only mode on narrow screens. Pages remain scrollable when content is taller than the display.", 78)
    addInfo(settings, "Input", "Supports touch and mouse dragging. Use the close button to collapse the hub to the AX launcher.", 72)

    -- Diagnostics page
    local diagnostics = pages.Diagnostics
    addSection(diagnostics, "Diagnostics", "Live runtime snapshot")
    local diagCard = card(diagnostics, 220)
    local diagText = make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 13),
        Size = UDim2.new(1, -30, 1, -26),
        Font = Enum.Font.Code,
        Text = "Press RUN CHECK to collect client status.",
        TextColor3 = C.Muted,
        TextSize = 9,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    }, diagCard)
    addAction(diagnostics, "Run diagnostics", "Collect player, character, and scanner status", "RUN CHECK", function()
        diagText.Text = config.GetDiagnostics(currentPage)
    end)

    -- Dragging from the header; touch and mouse.
    local dragging, dragInput, dragStart, startPosition = false, nil, nil, nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local closePosition = close.AbsolutePosition
            local closeSize = close.AbsoluteSize
            local overClose = input.Position.X >= closePosition.X
                and input.Position.X <= closePosition.X + closeSize.X
                and input.Position.Y >= closePosition.Y
                and input.Position.Y <= closePosition.Y + closeSize.Y
            if overClose then return end
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local camera = Workspace.CurrentCamera
            local viewport = camera and camera.ViewportSize
            if not viewport then return end

            local halfWidth = main.AbsoluteSize.X / 2
            local halfHeight = main.AbsoluteSize.Y / 2
            local minX = -viewport.X / 2 + halfWidth + 8
            local maxX = viewport.X / 2 - halfWidth - 8
            local minY = -viewport.Y / 2 + halfHeight + 8
            local maxY = viewport.Y / 2 - halfHeight - 8
            if minX > maxX then minX, maxX = 0, 0 end
            if minY > maxY then minY, maxY = 0, 0 end

            local nextX = math.clamp(startPosition.X.Offset + delta.X, minX, maxX)
            local nextY = math.clamp(startPosition.Y.Offset + delta.Y, minY, maxY)
            main.Position = UDim2.new(startPosition.X.Scale, nextX, startPosition.Y.Scale, nextY)
        end
    end)

    close.Activated:Connect(function()
        main.Visible = false
        launcher.Visible = true
    end)
    launcher.Activated:Connect(function()
        launcher.Visible = false
        main.Visible = true
    end)

    pages.Overview.Visible = true
    navRefs.Overview.Button.BackgroundColor3 = C.SurfaceRaised
    navRefs.Overview.Indicator.BackgroundTransparency = 0
    navRefs.Overview.Label.TextColor3 = C.Text
    navRefs.Overview.Icon.TextColor3 = C.Cyan

    screen.Destroying:Connect(function()
        if viewportConnection then viewportConnection:Disconnect() end
        if cameraConnection then cameraConnection:Disconnect() end
        if inputChangedConnection then inputChangedConnection:Disconnect() end
    end)

    return {
        Screen = screen,
        SetFruitToggle = fruitToggle,
    }
end

return UI
