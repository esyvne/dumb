print("[Dumb UI]: ui.lua execution started")

local hui = gethui or get_hidden_gui
local getexec = identifyexecutor or getexecutor or (function() return "Unknown" end)
local coregui = game:GetService("CoreGui")
local userinputservice = game:GetService("UserInputService")
local httpservice = game:GetService("HttpService")
local exservice = game:GetService("ExperienceService")
local getgitpath = getgitpath or (getgenv and getgenv().getgitpath) or _G.getgitpath

local targetParent = (hui and hui()) or coregui

local theme = {
    bg = Color3.fromRGB(0, 0, 0),
    panel = Color3.fromRGB(10, 10, 10),
    panel2 = Color3.fromRGB(16, 16, 16),
    border = Color3.fromRGB(40, 40, 40),
    accent = Color3.fromRGB(255, 255, 255),
    text = Color3.fromRGB(255, 255, 255),
    muted = Color3.fromRGB(230, 230, 230),
    green = Color3.fromRGB(255, 255, 255),
    red = Color3.fromRGB(255, 255, 255)
}

local function make(instanceType, parent, props)
    local inst = Instance.new(instanceType)
    if parent then
        inst.Parent = parent
    end
    if props then
        for prop, value in pairs(props) do
            inst[prop] = value
        end
    end
    return inst
end

local function makeCorner(inst, radius)
    local corner = inst:FindFirstChildOfClass("UICorner")
    if not corner then
        corner = Instance.new("UICorner")
        corner.Parent = inst
    end
    corner.CornerRadius = UDim.new(0, radius)
end

local function makeStroke(inst, color, transparency, thickness)
    local stroke = inst:FindFirstChildOfClass("UIStroke")
    if not stroke then
        stroke = Instance.new("UIStroke")
        stroke.Parent = inst
    end
    stroke.Color = color or theme.border
    stroke.Transparency = transparency or 0
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

print("[Dumb UI]: Creating custom black UI...")
local ui = Instance.new("ScreenGui")
ui.Name = "DumbSimpleUI"
ui.ResetOnSpawn = false
ui.IgnoreGuiInset = true
ui.Parent = targetParent

local main = make("Frame", ui, {
    Name = "MainFrame",
    Size = UDim2.new(0, 720, 0, 430),
    Position = UDim2.new(0.5, -360, 0.5, -215),
    BackgroundColor3 = theme.bg,
    BorderSizePixel = 0,
    ZIndex = 10
})
makeCorner(main, 4)
makeStroke(main, theme.border, 0.2, 1)

local topbar = make("Frame", main, {
    Name = "TopBar",
    Size = UDim2.new(1, -16, 0, 42),
    Position = UDim2.new(0, 8, 0, 8),
    BackgroundColor3 = theme.panel,
    BorderSizePixel = 0
})
makeCorner(topbar, 4)
makeStroke(topbar, theme.border, 0.2, 1)

local title = make("TextLabel", topbar, {
    Size = UDim2.new(0, 220, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "Dumb Hub",
    TextColor3 = theme.text,
    Font = Enum.Font.GothamSemibold,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left
})

local hideBtn = make("TextButton", topbar, {
    Size = UDim2.new(0, 34, 0, 24),
    Position = UDim2.new(1, -46, 0.5, -12),
    BackgroundColor3 = theme.panel2,
    BorderSizePixel = 0,
    Text = "—",
    TextColor3 = theme.muted,
    Font = Enum.Font.GothamBold,
    TextSize = 14
})
makeCorner(hideBtn, 3)
makeStroke(hideBtn, theme.border, 0.3, 1)

local toggleBtn = make("TextButton", ui, {
    Name = "ToggleBtn",
    Size = UDim2.new(0, 54, 0, 32),
    Position = UDim2.new(0, 18, 0, 18),
    BackgroundColor3 = theme.panel,
    BorderSizePixel = 0,
    Text = "☰",
    TextColor3 = theme.text,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    Visible = false,
    ZIndex = 20
})
makeCorner(toggleBtn, 3)
makeStroke(toggleBtn, theme.border, 0.3, 1)

local sidebar = make("Frame", main, {
    Name = "TabList",
    Size = UDim2.new(0, 150, 1, -64),
    Position = UDim2.new(0, 8, 0, 58),
    BackgroundColor3 = theme.panel,
    BorderSizePixel = 0
})
makeCorner(sidebar, 4)
makeStroke(sidebar, theme.border, 0.2, 1)

local content = make("Frame", main, {
    Name = "ContentFrame",
    Size = UDim2.new(1, -174, 1, -64),
    Position = UDim2.new(0, 166, 0, 58),
    BackgroundTransparency = 1
})

local sectionLayout = make("UIListLayout", sidebar, {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder
})

local sections = {}
local curSection

local function createSectionContainer(name)
    local frame = make("Frame", content, {
        Name = name .. "Frame",
        Size = UDim2.new(1, -12, 1, -12),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundTransparency = 1,
        Visible = false
    })

    local list = make("UIListLayout", frame, {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local pad = make("UIPadding", frame, {
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8)
    })

    return frame
end

local function createTabButton(name, text)
    local btn = make("TextButton", sidebar, {
        Name = name .. "Tab",
        Size = UDim2.new(1, -12, 0, 34),
        BackgroundColor3 = theme.panel2,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = theme.muted,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        AutoButtonColor = false
    })
    makeCorner(btn, 3)
    makeStroke(btn, theme.border, 0.3, 1)
    return btn
end

local function setActiveSection(name)
    for key, sect in pairs(sections) do
        if sect.TabBtn then
            sect.TabBtn.BackgroundColor3 = (key == name) and theme.panel2 or theme.panel
            sect.TabBtn.TextColor3 = (key == name) and theme.text or theme.muted
        end
        if sect.Container then
            sect.Container.Visible = (key == name)
        end
    end
    curSection = sections[name]
end

sections.Home = {
    TabBtn = createTabButton("Home", "Home"),
    Container = createSectionContainer("home")
}
sections.Game = {
    TabBtn = createTabButton("Game", "Game"),
    Container = createSectionContainer("game")
}
sections.GamesList = {
    TabBtn = createTabButton("GamesList", "Games"),
    Container = createSectionContainer("games")
}
sections.Settings = {
    TabBtn = createTabButton("Settings", "Settings"),
    Container = createSectionContainer("settings")
}
sections.Credits = {
    TabBtn = createTabButton("Credits", "Credits"),
    Container = createSectionContainer("credits")
}

for name, sect in pairs(sections) do
    sect.TabBtn.MouseButton1Click:Connect(function()
        setActiveSection(name)
    end)
end

setActiveSection("Home")

local function addHeader(parent, text, size)
    return make("TextLabel", parent, {
        Size = UDim2.new(1, 0, 0, size or 18),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = theme.text,
        Font = Enum.Font.GothamSemibold,
        TextSize = size and (size - 2) or 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
end

local function addSubText(parent, text)
    return make("TextLabel", parent, {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = theme.muted,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
end

local function addCard(parent, title, body)
    local card = make("Frame", parent, {
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = theme.panel2,
        BorderSizePixel = 0
    })
    makeCorner(card, 4)
    makeStroke(card, theme.border, 0.25, 1)

    make("TextLabel", card, {
        Size = UDim2.new(1, -16, 0, 20),
        Position = UDim2.new(0, 8, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = theme.text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    make("TextLabel", card, {
        Size = UDim2.new(1, -16, 0, 26),
        Position = UDim2.new(0, 8, 0, 32),
        BackgroundTransparency = 1,
        Text = body,
        TextColor3 = theme.muted,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    return card
end

local function updateHomeContent()
    local home = sections.Home.Container
    addHeader(home, "Simple black UI")
    addSubText(home, "Lightweight and clean for your scripts.")
    addCard(home, "Executor", "Unknown")
    addCard(home, "Version", "0.33 BETA")
    addCard(home, "Discord", "discord.gg/vaehz")
end

updateHomeContent()

local dragging = false
local dragInput
local startPos
local startMouse

local function beginDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        startPos = main.Position
        startMouse = input.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end

topbar.InputBegan:Connect(beginDrag)
main.InputBegan:Connect(beginDrag)

userinputservice.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - startMouse
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    elseif input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

hideBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    toggleBtn.Visible = true
end)

toggleBtn.MouseButton1Click:Connect(function()
    main.Visible = true
    toggleBtn.Visible = false
end)

local elements
local elemOk, elemErr = pcall(function()
    elements = loadstring(game:HttpGet(getgitpath("src") .. "elements.lua"))()
end)

if not elemOk or not elements then
    warn("[Dumb UI Error]: Failed to load elements.lua - " .. tostring(elemErr))
    print("[Dumb UI Error]: Failed to load elements.lua - " .. tostring(elemErr))
    return
end

local function refreshHomeInfo()
    local home = sections.Home.Container
    local children = home:GetChildren()
    for _, child in ipairs(children) do
        if child:IsA("Frame") and child:FindFirstChildOfClass("TextLabel") then
            local title = child:FindFirstChildOfClass("TextLabel")
            local body = child:FindFirstChildOfClass("TextLabel")
            if title and body then
                if title.Text == "Executor" then
                    body.Text = getexec()
                elseif title.Text == "Version" then
                    body.Text = "0.33 BETA"
                elseif title.Text == "Discord" then
                    body.Text = "discord.gg/vaehz"
                end
            end
        end
    end
end

refreshHomeInfo()

print("[Dumb UI]: Checking game script for place " .. tostring(game.PlaceId) .. "...")
local gameScriptUrl = getgitpath("games") .. tostring(game.PlaceId) .. ".lua"
local ok, gamePath = pcall(function()
    return game:HttpGet(gameScriptUrl)
end)

local gameList = {}
pcall(function()
    gameList = httpservice:JSONDecode(game:HttpGet(getgitpath("src") .. "gameslist.json"))
end)

local creditsList = {}
pcall(function()
    creditsList = httpservice:JSONDecode(game:HttpGet(getgitpath("src") .. "credits.json"))
end)

if elements then
    if not ok or type(gamePath) ~= "string" or #gamePath == 0 or gamePath:find("404") then
        local handledLocally = false

        if getgenv and getgenv().FileScripts then
            if isfile and isfile("Dumb/" .. tostring(game.PlaceId) .. ".lua") then
                pcall(function()
                    local gameModule = loadstring(readfile("Dumb/" .. tostring(game.PlaceId) .. ".lua"))()
                    local cfg = {}
                    if isfile("Dumb/Config.json") then
                        cfg = httpservice:JSONDecode(readfile("Dumb/Config.json"))
                    end
                    gameModule(sections.Game.Container, cfg)
                    handledLocally = true
                end)
            end
        end

        if not handledLocally and sections.Game and sections.Game.Container then
            elements:Unsupported(sections.Game.Container, function()
                setActiveSection("GamesList")
            end)
        end
    else
        local gOk, gErr = pcall(function()
            local gameModule = loadstring(gamePath)()
            local cfg = {}
            if isfile and isfile("Dumb/Config.json") then
                cfg = httpservice:JSONDecode(readfile("Dumb/Config.json"))
            end
            gameModule(sections.Game.Container, cfg)
        end)
        if not gOk then
            warn("[Dumb UI Error]: Error executing game script: " .. tostring(gErr))
            print("[Dumb UI Error]: Error executing game script: " .. tostring(gErr))
        end
    end

    if sections.GamesList and sections.GamesList.Container then
        elements:Searchbar(sections.GamesList.Container)
        for _, g in ipairs(gameList) do
            if g and g["game"] then
                elements:addGame(sections.GamesList.Container, g["game"], g["status"], function()
                    exservice:LaunchExperience({ placeId = g.id })
                end)
            end
        end
    end

    if sections.Credits and sections.Credits.Container then
        for sect, c in pairs(creditsList) do
            elements:CredHead(sections.Credits.Container, sect)
            for _, person in ipairs(c) do
                elements:CredPerson(sections.Credits.Container, person)
            end
        end
    end

    local dec1 = { settings = { disable_3d_rendering = false, auto_rejoin_on_kick = false } }
    pcall(function()
        if isfile and isfile("Dumb/Config.json") then
            local parsed = httpservice:JSONDecode(readfile("Dumb/Config.json"))
            if parsed and parsed.settings then dec1 = parsed end
        end
    end)

    if sections.Settings and sections.Settings.Container then
        elements:Toggle("Disable 3D Rendering", sections.Settings.Container, dec1.settings.disable_3d_rendering, function(v)
            pcall(function()
                local dec = httpservice:JSONDecode(readfile("Dumb/Config.json"))
                dec.settings.disable_3d_rendering = v
                writefile("Dumb/Config.json", httpservice:JSONEncode(dec))
                game:GetService("RunService"):Set3dRenderingEnabled(not v)
            end)
        end)

        elements:Toggle("Auto Rejoin (when kicked)", sections.Settings.Container, dec1.settings.auto_rejoin_on_kick, function(v)
            pcall(function()
                local dec = httpservice:JSONDecode(readfile("Dumb/Config.json"))
                dec.settings.auto_rejoin_on_kick = v
                writefile("Dumb/Config.json", httpservice:JSONEncode(dec))
                local env = getgenv and getgenv() or _G
                env.autorjjjj = v
            end)
        end)
    end
end

print("[Dumb UI]: UI loaded and visible successfully!")


