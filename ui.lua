local hui = gethui or get_hidden_gui
local getexec = identifyexecutor
local coregui = game:GetService("CoreGui")
local userinputservice = game:GetService("UserInputService")
local httpservice = game:GetService("HttpService")
local exservice = game:GetService("ExperienceService")
local tweenservice = game:GetService("TweenService")

local ui = import("rbxassetid://75281832304062")

ui.Parent = hui and hui() or coregui

-- Dark Testing UI Theme Palette
local DarkTheme = {
    MainBg = Color3.fromRGB(15, 16, 22),          -- Deep Obsidian (#0F1016)
    TopbarBg = Color3.fromRGB(20, 22, 30),        -- Dark Topbar (#14161E)
    TabListBg = Color3.fromRGB(18, 19, 26),       -- Dark Tab Sidebar (#12131A)
    TabActiveBg = Color3.fromRGB(34, 37, 50),     -- Active Tab Highlight (#222532)
    CardBg = Color3.fromRGB(24, 26, 36),          -- Dark Card / Button (#181A24)
    CardHoverBg = Color3.fromRGB(34, 37, 50),     -- Card Hover State (#222532)
    InputBg = Color3.fromRGB(18, 19, 26),         -- Dark Textbox Input (#12131A)
    StrokeColor = Color3.fromRGB(45, 48, 64),     -- Testing UI Crisp Border (#2D3040)
    Accent = Color3.fromRGB(99, 102, 241),        -- Indigo Testing Accent (#6366F1)
    TextPrimary = Color3.fromRGB(240, 242, 248),   -- Primary Text (#F0F2F8)
    TextSecondary = Color3.fromRGB(150, 155, 175), -- Secondary Text (#969BAA)
    ToggleOn = Color3.fromRGB(46, 189, 89),       -- Testing Toggle Green (#2EBD59)
    ToggleOff = Color3.fromRGB(40, 42, 56),       -- Toggle Off (#282A38)
    ToggleKnob = Color3.fromRGB(245, 245, 250)     -- Toggle Knob White (#F5F5FA)
}

local ToggleButton = ui.togglebtn
local MainFrame = ui.Frame

local Topbar = MainFrame.TopBar
local SectionContainers = MainFrame.sectionContainers
local TabList = MainFrame.tablist

local HideButton = Topbar.hidebtn

local Sections = {
    Home = {
        TabBtn = TabList.HomeTab,
        Container = SectionContainers.homeframe
    },

    Game = {
        TabBtn = TabList.GameTab,
        Container = SectionContainers.gameFrame
    },

    GamesList = {
        TabBtn = TabList.GameslistTab,
        Container = SectionContainers.gamelistFrame
    },

    Settings = {
        TabBtn = TabList.SettingsTab,
        Container = SectionContainers.settingsFrame
    },

    Credits = {
        TabBtn = TabList.CreditsTab,
        Container = SectionContainers.creditsFrame
    }
}

-- Apply Dark Theme to Main UI Framework
local function themeInstance(inst)
    if inst:IsA("GuiObject") then
        if inst:IsA("Frame") or inst:IsA("ScrollingFrame") or inst:IsA("CanvasGroup") then
            if inst.BackgroundTransparency < 0.95 then
                local name = inst.Name:lower()
                if name == "frame" and inst == MainFrame then
                    inst.BackgroundColor3 = DarkTheme.MainBg
                elseif name:find("topbar") or name:find("top_bar") then
                    inst.BackgroundColor3 = DarkTheme.TopbarBg
                elseif name:find("tablist") or name:find("sidebar") then
                    inst.BackgroundColor3 = DarkTheme.TabListBg
                elseif name:find("container") or name:find("frame") then
                    inst.BackgroundColor3 = DarkTheme.MainBg
                else
                    inst.BackgroundColor3 = DarkTheme.CardBg
                end
            end
            if inst:IsA("ScrollingFrame") then
                inst.ScrollBarImageColor3 = DarkTheme.StrokeColor
            end
        elseif inst:IsA("TextLabel") then
            inst.TextColor3 = DarkTheme.TextPrimary
        elseif inst:IsA("TextBox") then
            inst.TextColor3 = DarkTheme.TextPrimary
            inst.PlaceholderColor3 = DarkTheme.TextSecondary
            if inst.BackgroundTransparency < 0.95 then
                inst.BackgroundColor3 = DarkTheme.InputBg
            end
        elseif inst:IsA("TextButton") then
            inst.TextColor3 = DarkTheme.TextPrimary
            if inst.BackgroundTransparency < 0.95 and inst ~= HideButton and not inst.Name:find("Tab") then
                inst.BackgroundColor3 = DarkTheme.CardBg
            end
        elseif inst:IsA("UIStroke") then
            inst.Color = DarkTheme.StrokeColor
        end
    end
end

themeInstance(ui)
for _, desc in ipairs(ui:GetDescendants()) do
    themeInstance(desc)
end

MainFrame.BackgroundColor3 = DarkTheme.MainBg
Topbar.BackgroundColor3 = DarkTheme.TopbarBg
TabList.BackgroundColor3 = DarkTheme.TabListBg
if SectionContainers then
    SectionContainers.BackgroundColor3 = DarkTheme.MainBg
    for _, child in ipairs(SectionContainers:GetChildren()) do
        if child:IsA("GuiObject") and child.BackgroundTransparency < 0.95 then
            child.BackgroundColor3 = DarkTheme.MainBg
        end
    end
end

if ToggleButton then
    ToggleButton.BackgroundColor3 = DarkTheme.TopbarBg
    for _, child in ipairs(ToggleButton:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            child.TextColor3 = DarkTheme.TextPrimary
        elseif child:IsA("UIStroke") then
            child.Color = DarkTheme.StrokeColor
        end
    end
end

if HideButton then
    HideButton.BackgroundColor3 = DarkTheme.CardBg
    if HideButton:IsA("TextButton") then
        HideButton.TextColor3 = DarkTheme.TextSecondary
    end
    for _, child in ipairs(HideButton:GetChildren()) do
        if child:IsA("TextLabel") then
            child.TextColor3 = DarkTheme.TextSecondary
        end
    end
end

local CurSection

local function updateTabVisuals(sect, isActive)
    if isActive then
        sect.TabBtn.BackgroundColor3 = DarkTheme.TabActiveBg
        sect.TabBtn.BackgroundTransparency = 0
        if sect.TabBtn:IsA("TextButton") then
            sect.TabBtn.TextColor3 = DarkTheme.TextPrimary
        end
        for _, child in ipairs(sect.TabBtn:GetChildren()) do
            if child:IsA("TextLabel") then
                child.TextColor3 = DarkTheme.TextPrimary
            end
        end
    else
        sect.TabBtn.BackgroundTransparency = 1
        if sect.TabBtn:IsA("TextButton") then
            sect.TabBtn.TextColor3 = DarkTheme.TextSecondary
        end
        for _, child in ipairs(sect.TabBtn:GetChildren()) do
            if child:IsA("TextLabel") then
                child.TextColor3 = DarkTheme.TextSecondary
            end
        end
    end
end

for _, sect in pairs(Sections) do
    updateTabVisuals(sect, false)

    sect.TabBtn.MouseEnter:Connect(function()
        if CurSection ~= sect then
            sect.TabBtn.BackgroundTransparency = 0.6
            sect.TabBtn.BackgroundColor3 = DarkTheme.CardHoverBg
        end
        for _, stroke in pairs(sect.TabBtn:GetChildren()) do
            if stroke.Name == "InnerShadow" then
                stroke.Transparency = 0.95
            end
        end
    end)

    sect.TabBtn.MouseLeave:Connect(function()
        if CurSection ~= sect then
            updateTabVisuals(sect, false)
        end
        for _, stroke in pairs(sect.TabBtn:GetChildren()) do
            if stroke.Name == "InnerShadow" then
                stroke.Transparency = 1
            end
        end
    end)

    sect.TabBtn.MouseButton1Click:Connect(function()
        if CurSection == sect then return end

        if CurSection then
            updateTabVisuals(CurSection, false)
            CurSection.Container:TweenPosition(UDim2.new(0.5, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2)
        end

        updateTabVisuals(sect, true)
        sect.Container:TweenPosition(UDim2.new(0.5, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2)
        sect.Container.Visible = true

        CurSection = sect
    end)
end

HideButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleButton.Visible = true
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ToggleButton.Visible = false
end)

local dragging = false
local dragInput, mousePos, framePos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

userinputservice.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)

Sections.Home.Container.bugsLabel.Text = Sections.Home.Container.bugsLabel.Text:gsub("redacted", "discord.gg/vaehz")
Sections.Home.Container.discan.Text = Sections.Home.Container.discan.Text:gsub("redacted", "discord.gg/vaehz")
Sections.Home.Container.ythead.Text = Sections.Home.Container.ythead.Text:gsub("redacted", "YouTube")
Sections.Home.Container.execLabel.Text = "Executor: " .. getexec()
Sections.Home.Container.versionLabel.Text = "Version: 0.33 BETA"


local ok, gamePath = pcall(function()
    return game:HttpGet(getgitpath("games") .. tostring(game.PlaceId) .. ".lua")
end)
local gameList = httpservice:JSONDecode(game:HttpGet(getgitpath("src").. "gameslist.json"))
local creditsList = httpservice:JSONDecode(game:HttpGet(getgitpath("src").. "credits.json"))
local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
if not ok or #gamePath == 0 or gamePath == "404: Not Found" then
    local handledLocally = false

    if getgenv().FileScripts then
        if isfile("Dumb/"..tostring(game.PlaceId)..".lua") then
            local gameModule = loadstring(readfile("Dumb/"..tostring(game.PlaceId)..".lua"))()
            gameModule(Sections.Game.Container, httpservice:JSONDecode(readfile("Dumb/Config.json")))
            handledLocally = true
        end
    end

    if not handledLocally then
        elements:Unsupported(Sections.Game.Container, function()
            if CurSection then
                updateTabVisuals(CurSection, false)
                CurSection.Container:TweenPosition(UDim2.new(0.5, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2)
            end

            updateTabVisuals(Sections.GamesList, true)
            Sections.GamesList.Container:TweenPosition(UDim2.new(0.5, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2)
            Sections.GamesList.Container.Visible = true

            CurSection = Sections.GamesList
        end)
    end
else
    local gameModule = loadstring(gamePath)()
    gameModule(Sections.Game.Container, httpservice:JSONDecode(readfile("Dumb/Config.json")))
end
elements:Searchbar(Sections.GamesList.Container)
for _, g in ipairs(gameList) do
    elements:addGame(Sections.GamesList.Container, g["game"], g["status"], function()
        exservice:LaunchExperience({placeId = g.id})
    end)
end

for sect, c in pairs(creditsList) do
    elements:CredHead(Sections.Credits.Container, sect)

    for _, person in ipairs(c) do
        elements:CredPerson(Sections.Credits.Container, person)
    end
end

local dec1 = httpservice:JSONDecode(readfile("Dumb/Config.json"))

elements:Toggle("Disable 3D Rendering", Sections.Settings.Container, dec1.settings.disable_3d_rendering, function(v)
    local dec = httpservice:JSONDecode(readfile("Dumb/Config.json"))
    dec.settings.disable_3d_rendering = v
    writefile("Dumb/Config.json", httpservice:JSONEncode(dec))
    game:GetService("RunService"):Set3dRenderingEnabled(not v)
end)

elements:Toggle("Auto Rejoin (when kicked)", Sections.Settings.Container, dec1.settings.auto_rejoin_on_kick, function(v)
    local dec = httpservice:JSONDecode(readfile("Dumb/Config.json"))
    dec.settings.auto_rejoin_on_kick = v
    writefile("Dumb/Config.json", httpservice:JSONEncode(dec))
    getgenv().autorjjjj = v
end)

