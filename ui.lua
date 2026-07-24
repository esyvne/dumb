print("[Dumb UI]: ui.lua started (Minimalist)")

local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local httpservice      = game:GetService("HttpService")
local exservice        = game:GetService("ExperienceService")

local getexec    = identifyexecutor or getexecutor or (function() return "Unknown" end)
local getgitpath = getgitpath or (getgenv and getgenv().getgitpath) or _G.getgitpath

if not getgitpath then
    warn("[Dumb UI Error]: 'getgitpath' is nil!")
    return
end

-- ── Palette ────────────────────────────────────────────────────────────────────
local T = {
    Bg        = Color3.fromRGB(11, 11, 11),
    Sidebar   = Color3.fromRGB(17, 17, 17),
    Card      = Color3.fromRGB(22, 22, 22),
    CardHover = Color3.fromRGB(30, 30, 30),
    Accent    = Color3.fromRGB(230, 230, 230),
    TextPri   = Color3.fromRGB(200, 200, 200),
    TextMuted = Color3.fromRGB(70, 70, 70),
    Divider   = Color3.fromRGB(28, 28, 28),
    ToggleOn  = Color3.fromRGB(85, 85, 85),
    ToggleOff = Color3.fromRGB(30, 30, 30),
}

-- ── ScreenGui ──────────────────────────────────────────────────────────────────
local hui = (gethui and gethui()) or game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DumbUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = hui

-- ── Main Frame ─────────────────────────────────────────────────────────────────
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 540, 0, 330)
Main.BackgroundColor3 = T.Bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true

do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = Main
end

-- ── Topbar ─────────────────────────────────────────────────────────────────────
local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Parent = Main
Topbar.Size = UDim2.new(1, 0, 0, 26)
Topbar.BackgroundColor3 = T.Sidebar
Topbar.BorderSizePixel = 0

local Logo = Instance.new("ImageLabel")
Logo.Parent = Topbar
Logo.Position = UDim2.new(0, 12, 0.5, -9)
Logo.Size = UDim2.new(0, 60, 0, 18)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://139415606656378"
Logo.ScaleType = Enum.ScaleType.Fit

local function makeTopBtn(icon, xOffset)
    local btn = Instance.new("TextButton")
    btn.Parent = Topbar
    btn.Position = UDim2.new(1, xOffset, 0, 0)
    btn.Size = UDim2.new(0, 26, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = icon
    btn.TextColor3 = T.TextMuted
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 17
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.MouseEnter:Connect(function() btn.TextColor3 = T.TextPri end)
    btn.MouseLeave:Connect(function() btn.TextColor3 = T.TextMuted end)
    return btn
end

local CloseBtn = makeTopBtn("×", -26)
local MinBtn   = makeTopBtn("−", -52)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(Main, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
        Size = minimized and UDim2.new(0, 540, 0, 26) or UDim2.new(0, 540, 0, 330)
    }):Play()
end)

-- ── Re-open Button ─────────────────────────────────────────────────────────────
local ReopenBtn = Instance.new("TextButton")
ReopenBtn.Parent = ScreenGui
ReopenBtn.Position = UDim2.new(0, 10, 0.5, -13)
ReopenBtn.Size = UDim2.new(0, 50, 0, 26)
ReopenBtn.BackgroundColor3 = T.Sidebar
ReopenBtn.BorderSizePixel = 0
ReopenBtn.Text = "dumb"
ReopenBtn.TextColor3 = T.TextPri
ReopenBtn.Font = Enum.Font.Gotham
ReopenBtn.TextSize = 13
ReopenBtn.AutoButtonColor = false
ReopenBtn.Visible = false
do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = ReopenBtn
end

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    ReopenBtn.Visible = true
end)
ReopenBtn.MouseButton1Click:Connect(function()
    Main.Visible = true
    ReopenBtn.Visible = false
    minimized = false
    Main.Size = UDim2.new(0, 540, 0, 330)
end)

-- ── Dragging ───────────────────────────────────────────────────────────────────
local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
Topbar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; mousePos = i.Position; framePos = Main.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Topbar.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement then dragInput = i end
end)
UserInputService.InputChanged:Connect(function(i)
    if i == dragInput and dragging then
        local d = i.Position - mousePos
        Main.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + d.X, framePos.Y.Scale, framePos.Y.Offset + d.Y)
    end
end)

-- ── Layout ─────────────────────────────────────────────────────────────────────
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = Main
Sidebar.Position = UDim2.new(0, 0, 0, 26)
Sidebar.Size = UDim2.new(0, 100, 1, -26)
Sidebar.BackgroundColor3 = T.Sidebar
Sidebar.BorderSizePixel = 0

local SBLayout = Instance.new("UIListLayout")
SBLayout.Parent = Sidebar
SBLayout.SortOrder = Enum.SortOrder.LayoutOrder
SBLayout.Padding = UDim.new(0, 1)

local SBPad = Instance.new("UIPadding")
SBPad.Parent = Sidebar
SBPad.PaddingTop = UDim.new(0, 8)
SBPad.PaddingLeft = UDim.new(0, 8)
SBPad.PaddingRight = UDim.new(0, 8)

-- thin divider
do
    local d = Instance.new("Frame")
    d.Parent = Main
    d.Position = UDim2.new(0, 100, 0, 26)
    d.Size = UDim2.new(0, 1, 1, -26)
    d.BackgroundColor3 = T.Divider
    d.BorderSizePixel = 0
end

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Parent = Main
ContentArea.Position = UDim2.new(0, 101, 0, 26)
ContentArea.Size = UDim2.new(1, -101, 1, -26)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ClipsDescendants = true

-- ── Tab Factory ────────────────────────────────────────────────────────────────
local currentTab = nil
local tabList    = {}

local function makeTab(name, order)
    -- sidebar button
    local Btn = Instance.new("TextButton")
    Btn.Name = name .. "Tab"
    Btn.Parent = Sidebar
    Btn.LayoutOrder = order
    Btn.Size = UDim2.new(1, 0, 0, 26)
    Btn.BackgroundTransparency = 1
    Btn.Text = name
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 13
    Btn.TextColor3 = T.TextMuted
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.AutoButtonColor = false
    Btn.BorderSizePixel = 0
    do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = Btn
    end
    local BPad = Instance.new("UIPadding")
    BPad.Parent = Btn
    BPad.PaddingLeft = UDim.new(0, 8)

    -- left indicator bar
    local Bar = Instance.new("Frame")
    Bar.Parent = Btn
    Bar.AnchorPoint = Vector2.new(0, 0.5)
    Bar.Position = UDim2.new(0, -8, 0.5, 0)
    Bar.Size = UDim2.new(0, 2, 0, 12)
    Bar.BackgroundColor3 = T.Accent
    Bar.BorderSizePixel = 0
    Bar.Visible = false
    do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = Bar
    end

    -- scrollable content frame
    local Scrl = Instance.new("ScrollingFrame")
    Scrl.Name = name .. "Content"
    Scrl.Parent = ContentArea
    Scrl.Size = UDim2.new(1, 0, 1, 0)
    Scrl.BackgroundTransparency = 1
    Scrl.BorderSizePixel = 0
    Scrl.ScrollBarThickness = 2
    Scrl.ScrollBarImageColor3 = T.Divider
    Scrl.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scrl.Visible = false
    Scrl.ClipsDescendants = true

    local SLayout = Instance.new("UIListLayout")
    SLayout.Parent = Scrl
    SLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SLayout.Padding = UDim.new(0, 4)
    SLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scrl.CanvasSize = UDim2.new(0, 0, 0, SLayout.AbsoluteContentSize.Y + 20)
    end)

    local SPad = Instance.new("UIPadding")
    SPad.Parent = Scrl
    SPad.PaddingTop    = UDim.new(0, 10)
    SPad.PaddingLeft   = UDim.new(0, 10)
    SPad.PaddingRight  = UDim.new(0, 10)
    SPad.PaddingBottom = UDim.new(0, 10)

    local tabObj = {Btn = Btn, Bar = Bar, Scrl = Scrl}

    local function activate()
        if currentTab == tabObj then return end
        if currentTab then
            TweenService:Create(currentTab.Btn, TweenInfo.new(0.2), {TextColor3 = T.TextMuted, BackgroundTransparency = 1}):Play()
            currentTab.Bar.Visible = false
            currentTab.Scrl.Visible = false
        end
        currentTab = tabObj
        TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = T.TextPri, BackgroundTransparency = 0, BackgroundColor3 = T.Card}):Play()
        Bar.Size = UDim2.new(0, 2, 0, 0)
        Bar.Visible = true
        TweenService:Create(Bar, TweenInfo.new(0.2), {Size = UDim2.new(0, 2, 0, 12)}):Play()
        
        Scrl.Position = UDim2.new(0, 10, 0, 0)
        Scrl.Visible = true
        TweenService:Create(Scrl, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    end

    Btn.MouseEnter:Connect(function()
        if currentTab ~= tabObj then Btn.TextColor3 = Color3.fromRGB(130, 130, 130) end
    end)
    Btn.MouseLeave:Connect(function()
        if currentTab ~= tabObj then Btn.TextColor3 = T.TextMuted end
    end)
    Btn.MouseButton1Click:Connect(activate)

    tabList[name] = {activate = activate, content = Scrl}
    return Scrl, activate
end

-- ── Element Helpers ────────────────────────────────────────────────────────────
local function mkLabel(parent, text, clr)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = parent
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = clr or T.TextMuted
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    return lbl
end

local function mkDivider(parent)
    local holder = Instance.new("Frame")
    holder.Parent = parent
    holder.Size = UDim2.new(1, 0, 0, 12)
    holder.BackgroundTransparency = 1
    local line = Instance.new("Frame")
    line.Parent = holder
    line.AnchorPoint = Vector2.new(0, 0.5)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.BackgroundColor3 = T.Divider
    line.BorderSizePixel = 0
end

local function mkButton(parent, text, cb)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = T.Card
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = T.TextPri
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.AutoButtonColor = false
    do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = btn
    end
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = T.CardHover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = T.Card}):Play()
    end)
    btn.MouseButton1Click:Connect(function() pcall(cb) end)
    return btn
end

local function mkToggle(parent, text, default, cb)
    local row = Instance.new("Frame")
    row.Parent = parent
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundColor3 = T.Card
    row.BorderSizePixel = 0
    do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = row
    end

    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Size = UDim2.new(1, -54, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = T.TextPri
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local track = Instance.new("Frame")
    track.Parent = row
    track.AnchorPoint = Vector2.new(1, 0.5)
    track.Position = UDim2.new(1, -10, 0.5, 0)
    track.Size = UDim2.new(0, 30, 0, 14)
    track.BackgroundColor3 = default and T.ToggleOn or T.ToggleOff
    track.BorderSizePixel = 0
    do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = track
    end

    local knob = Instance.new("Frame")
    knob.Parent = track
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = default and UDim2.new(0.73, 0, 0.5, 0) or UDim2.new(0.27, 0, 0.5, 0)
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.BackgroundColor3 = T.TextPri
    knob.BorderSizePixel = 0
    do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = knob
    end

    local toggled = default
    local clickBtn = Instance.new("TextButton")
    clickBtn.Parent = row
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.AutoButtonColor = false
    clickBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        TweenService:Create(track, TweenInfo.new(0.14), {BackgroundColor3 = toggled and T.ToggleOn or T.ToggleOff}):Play()
        TweenService:Create(knob, TweenInfo.new(0.14), {
            Position = toggled and UDim2.new(0.73, 0, 0.5, 0) or UDim2.new(0.27, 0, 0.5, 0)
        }):Play()
        pcall(cb, toggled)
    end)
    return row
end

local function mkTextbox(parent, text, default, cb)
    local row = Instance.new("Frame")
    row.Parent = parent
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundColor3 = T.Card
    row.BorderSizePixel = 0
    do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = row
    end

    local lbl = Instance.new("TextLabel")
    lbl.Parent = row
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Size = UDim2.new(0.5, -10, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = T.TextPri
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local inputBg = Instance.new("Frame")
    inputBg.Parent = row
    inputBg.AnchorPoint = Vector2.new(1, 0.5)
    inputBg.Position = UDim2.new(1, -6, 0.5, 0)
    inputBg.Size = UDim2.new(0.5, -10, 0, 20)
    inputBg.BackgroundColor3 = T.Sidebar
    inputBg.BorderSizePixel = 0
    do
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = inputBg
    end

    local box = Instance.new("TextBox")
    box.Parent = inputBg
    box.Size = UDim2.new(1, -12, 1, 0)
    box.Position = UDim2.new(0, 6, 0, 0)
    box.BackgroundTransparency = 1
    box.Text = tostring(default or "")
    box.TextColor3 = T.TextPri
    box.PlaceholderColor3 = T.TextMuted
    box.Font = Enum.Font.Gotham
    box.TextSize = 11
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false

    box.FocusLost:Connect(function()
        pcall(cb, box.Text)
    end)
    return row
end

-- ── Build Tabs ─────────────────────────────────────────────────────────────────
local homeC,     homeAct     = makeTab("Home",     1)
local gameC,     gameAct     = makeTab("Game",     2)
local gamesC,    gamesAct    = makeTab("Games",    3)
local settingsC, settingsAct = makeTab("Settings", 4)
local creditsC,  creditsAct  = makeTab("Credits",  5)

homeAct() -- open Home by default

-- ── Home ───────────────────────────────────────────────────────────────────────
local execName = "Unknown"
pcall(function()
    local r = getexec()
    if type(r) == "string" then execName = r end
end)

mkLabel(homeC, "v0.33 BETA  ·  " .. execName, T.TextMuted)
mkDivider(homeC)
mkButton(homeC, "Copy Discord  ( discord.gg/vaehz )", function()
    pcall(setclipboard, "https://discord.gg/vaehz")
end)

-- ── Game ───────────────────────────────────────────────────────────────────────
local ok, gamePath = pcall(function()
    return game:HttpGet(getgitpath("games") .. tostring(game.PlaceId) .. ".lua")
end)

if not ok or type(gamePath) ~= "string" or #gamePath == 0 or gamePath:find("404") then
    local localDone = false
    if getgenv and getgenv().FileScripts then
        if isfile and isfile("Dumb/" .. tostring(game.PlaceId) .. ".lua") then
            pcall(function()
                local cfg = {}
                if isfile and isfile("Dumb/Config.json") then
                    cfg = httpservice:JSONDecode(readfile("Dumb/Config.json"))
                end
                local mod = loadstring(readfile("Dumb/" .. tostring(game.PlaceId) .. ".lua"))()
                mod(gameC, cfg, mkButton, mkToggle, mkLabel, mkDivider, mkTextbox)
                localDone = true
            end)
        end
    end
    if not localDone then
        mkLabel(gameC, "Game not supported.", T.TextMuted)
        mkDivider(gameC)
        mkButton(gameC, "Suggest on Discord", function()
            pcall(setclipboard, "https://discord.gg/vaehz")
        end)
    end
else
    local gOk, gErr = pcall(function()
        local cfg = {}
        if isfile and isfile("Dumb/Config.json") then
            cfg = httpservice:JSONDecode(readfile("Dumb/Config.json"))
        end
        local mod = loadstring(gamePath)()
        mod(gameC, cfg, mkButton, mkToggle, mkLabel, mkDivider, mkTextbox)
    end)
    if not gOk then
        warn("[Dumb UI]: " .. tostring(gErr))
        mkLabel(gameC, "Error loading script.", T.TextMuted)
    end
end

-- ── Games List ─────────────────────────────────────────────────────────────────
local gameList = {}
pcall(function()
    gameList = httpservice:JSONDecode(game:HttpGet(getgitpath() .. "gameslist.json"))
end)

if #gameList > 0 then
    for _, g in ipairs(gameList) do
        if g and g["game"] then
            local dot = g["status"] == "🟢" and " ●" or g["status"] == "🟡" and " ◐" or " ○"
            mkButton(gamesC, g["game"] .. dot, function()
                pcall(exservice.LaunchExperience, exservice, {placeId = g.id})
            end)
        end
    end
else
    mkLabel(gamesC, "No games available.", T.TextMuted)
end

-- ── Settings ───────────────────────────────────────────────────────────────────
local cfg1 = { settings = { disable_3d_rendering = false, auto_rejoin_on_kick = false } }
pcall(function()
    if isfile and isfile("Dumb/Config.json") then
        local p = httpservice:JSONDecode(readfile("Dumb/Config.json"))
        if p and p.settings then cfg1 = p end
    end
end)

mkToggle(settingsC, "Disable 3D Rendering", cfg1.settings.disable_3d_rendering, function(v)
    pcall(function()
        local d = httpservice:JSONDecode(readfile("Dumb/Config.json"))
        d.settings.disable_3d_rendering = v
        writefile("Dumb/Config.json", httpservice:JSONEncode(d))
        game:GetService("RunService"):Set3dRenderingEnabled(not v)
    end)
end)

mkToggle(settingsC, "Auto Rejoin on Kick", cfg1.settings.auto_rejoin_on_kick, function(v)
    pcall(function()
        local d = httpservice:JSONDecode(readfile("Dumb/Config.json"))
        d.settings.auto_rejoin_on_kick = v
        writefile("Dumb/Config.json", httpservice:JSONEncode(d))
        local env = getgenv and getgenv() or _G
        env.autorjjjj = v
    end)
end)

-- ── Credits ────────────────────────────────────────────────────────────────────
local creditsList = {}
pcall(function()
    creditsList = httpservice:JSONDecode(game:HttpGet(getgitpath() .. "credits.json"))
end)

if next(creditsList) then
    for section, people in pairs(creditsList) do
        mkLabel(creditsC, section, T.TextPri)
        for _, person in ipairs(people) do
            mkLabel(creditsC, "  " .. person, T.TextMuted)
        end
        mkDivider(creditsC)
    end
else
    mkLabel(creditsC, "No credits.", T.TextMuted)
end

print("[Dumb UI]: Minimalist UI loaded!")
