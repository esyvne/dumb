print("[Dumb UI]: ui.lua execution started")

local hui = gethui or get_hidden_gui
local getexec = identifyexecutor or getexecutor or (function() return "Unknown" end)
local coregui = game:GetService("CoreGui")
local userinputservice = game:GetService("UserInputService")
local httpservice = game:GetService("HttpService")
local exservice = game:GetService("ExperienceService")
local tweenservice = game:GetService("TweenService")

local import = import or (getgenv and getgenv().import) or _G.import
local getgitpath = getgitpath or (getgenv and getgenv().getgitpath) or _G.getgitpath

if not import then
    warn("[Dumb UI Error]: 'import' function is nil!")
    print("[Dumb UI Error]: 'import' function is nil!")
    return
end

print("[Dumb UI]: Importing UI model...")
local ui = import("rbxassetid://75281832304062")

if not ui then
    warn("[Dumb UI Error]: Failed to load UI asset model (rbxassetid://75281832304062)")
    print("[Dumb UI Error]: Failed to load UI asset model (rbxassetid://75281832304062)")
    return
end

print("[Dumb UI]: UI asset loaded successfully!")

pcall(function()
    if ui:IsA("ScreenGui") then
        ui.Enabled = true
    end
end)

local targetParent = (hui and hui()) or coregui
ui.Parent = targetParent
print("[Dumb UI]: UI parented to " .. tostring(targetParent.Name))

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

local ToggleButton = ui:FindFirstChild("togglebtn") or ui:FindFirstChild("ToggleBtn")
local MainFrame = ui:FindFirstChild("Frame") or ui:FindFirstChild("MainFrame")

if not MainFrame then
    warn("[Dumb UI Error]: Main frame not found in UI asset")
    print("[Dumb UI Error]: Main frame not found in UI asset")
    return
end

MainFrame.Visible = true
if ToggleButton then
    ToggleButton.Visible = false
end

local Topbar = MainFrame:FindFirstChild("TopBar") or MainFrame:FindFirstChild("Topbar")
local SectionContainers = MainFrame:FindFirstChild("sectionContainers") or MainFrame:FindFirstChild("SectionContainers")
local TabList = MainFrame:FindFirstChild("tablist") or MainFrame:FindFirstChild("TabList")

local HideButton = Topbar and (Topbar:FindFirstChild("hidebtn") or Topbar:FindFirstChild("HideBtn"))

local Sections = {
    Home = {
        TabBtn = TabList and TabList:FindFirstChild("HomeTab"),
        Container = SectionContainers and SectionContainers:FindFirstChild("homeframe")
    },

    Game = {
        TabBtn = TabList and TabList:FindFirstChild("GameTab"),
        Container = SectionContainers and SectionContainers:FindFirstChild("gameFrame")
    },

    GamesList = {
        TabBtn = TabList and TabList:FindFirstChild("GameslistTab"),
        Container = SectionContainers and SectionContainers:FindFirstChild("gamelistFrame")
    },

    Settings = {
        TabBtn = TabList and TabList:FindFirstChild("SettingsTab"),
        Container = SectionContainers and SectionContainers:FindFirstChild("settingsFrame")
    },

    Credits = {
        TabBtn = TabList and TabList:FindFirstChild("CreditsTab"),
        Container = SectionContainers and SectionContainers:FindFirstChild("creditsFrame")
    }
}

print("[Dumb UI]: Applying Dark Theme to UI elements...")

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
if Topbar then Topbar.BackgroundColor3 = DarkTheme.TopbarBg end
if TabList then TabList.BackgroundColor3 = DarkTheme.TabListBg end
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
    if not sect or not sect.TabBtn then return end
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
    if sect.TabBtn then
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

            if CurSection and CurSection.Container then
                updateTabVisuals(CurSection, false)
                CurSection.Container:TweenPosition(UDim2.new(0.5, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2)
            end

            updateTabVisuals(sect, true)
            if sect.Container then
                sect.Container:TweenPosition(UDim2.new(0.5, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2)
                sect.Container.Visible = true
            end

            CurSection = sect
        end)
    end
end

if HideButton then
    HideButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        if ToggleButton then ToggleButton.Visible = true end
    end)
end

if ToggleButton then
    ToggleButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        ToggleButton.Visible = false
    end)
end

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

pcall(function()
    if Sections.Home and Sections.Home.Container then
        local c = Sections.Home.Container
        if c:FindFirstChild("bugsLabel") then c.bugsLabel.Text = c.bugsLabel.Text:gsub("redacted", "discord.gg/vaehz") end
        if c:FindFirstChild("discan") then c.discan.Text = c.discan.Text:gsub("redacted", "discord.gg/vaehz") end
        if c:FindFirstChild("ythead") then c.ythead.Text = c.ythead.Text:gsub("redacted", "YouTube") end
        
        local execName = "Unknown"
        pcall(function()
            local res = getexec()
            if type(res) == "string" then execName = res end
        end)
        if c:FindFirstChild("execLabel") then c.execLabel.Text = "Executor: " .. tostring(execName) end
        if c:FindFirstChild("versionLabel") then c.versionLabel.Text = "Version: 0.33 BETA" end
    end
end)

print("[Dumb UI]: Checking game script for place " .. tostring(game.PlaceId) .. "...")

local gameScriptUrl = getgitpath("games") .. tostring(game.PlaceId) .. ".lua"
print("[Dumb UI]: Fetching game script from " .. gameScriptUrl)

local ok, gamePath = pcall(function()
    return game:HttpGet(gameScriptUrl)
end)

local gameList = {}
pcall(function()
    gameList = httpservice:JSONDecode(game:HttpGet(getgitpath("src").. "gameslist.json"))
end)

local creditsList = {}
pcall(function()
    creditsList = httpservice:JSONDecode(game:HttpGet(getgitpath("src").. "credits.json"))
end)

print("[Dumb UI]: Loading elements.lua...")
local elements
local elemOk, elemErr = pcall(function()
    elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
end)

if not elemOk or not elements then
    warn("[Dumb UI Error]: Failed to load elements.lua - " .. tostring(elemErr))
    print("[Dumb UI Error]: Failed to load elements.lua - " .. tostring(elemErr))
else
    print("[Dumb UI]: elements.lua loaded successfully!")
end

if elements then
    if not ok or type(gamePath) ~= "string" or #gamePath == 0 or gamePath:find("404") then
        print("[Dumb UI]: No specific game script found for place " .. tostring(game.PlaceId) .. " (Unsupported)")
        local handledLocally = false

        if getgenv and getgenv().FileScripts then
            if isfile and isfile("Dumb/"..tostring(game.PlaceId)..".lua") then
                pcall(function()
                    local gameModule = loadstring(readfile("Dumb/"..tostring(game.PlaceId)..".lua"))()
                    local cfg = {}
                    if isfile("Dumb/Config.json") then
                        cfg = httpservice:JSONDecode(readfile("Dumb/Config.json"))
                    end
                    gameModule(Sections.Game.Container, cfg)
                    handledLocally = true
                end)
            end
        end

        if not handledLocally and Sections.Game and Sections.Game.Container then
            elements:Unsupported(Sections.Game.Container, function()
                if CurSection and CurSection.Container then
                    updateTabVisuals(CurSection, false)
                    CurSection.Container:TweenPosition(UDim2.new(0.5, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2)
                end

                updateTabVisuals(Sections.GamesList, true)
                if Sections.GamesList and Sections.GamesList.Container then
                    Sections.GamesList.Container:TweenPosition(UDim2.new(0.5, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2)
                    Sections.GamesList.Container.Visible = true
                end

                CurSection = Sections.GamesList
            end)
        end
    else
        print("[Dumb UI]: Found game script for place " .. tostring(game.PlaceId) .. "! Executing...")
        local gOk, gErr = pcall(function()
            local gameModule = loadstring(gamePath)()
            local cfg = {}
            if isfile and isfile("Dumb/Config.json") then
                cfg = httpservice:JSONDecode(readfile("Dumb/Config.json"))
            end
            gameModule(Sections.Game.Container, cfg)
        end)
        if not gOk then
            warn("[Dumb UI Error]: Error executing game script: " .. tostring(gErr))
            print("[Dumb UI Error]: Error executing game script: " .. tostring(gErr))
        else
            print("[Dumb UI]: Game script executed successfully!")
        end
    end

    if Sections.GamesList and Sections.GamesList.Container then
        elements:Searchbar(Sections.GamesList.Container)
        for _, g in ipairs(gameList) do
            if g and g["game"] then
                elements:addGame(Sections.GamesList.Container, g["game"], g["status"], function()
                    exservice:LaunchExperience({placeId = g.id})
                end)
            end
        end
    end

    if Sections.Credits and Sections.Credits.Container then
        for sect, c in pairs(creditsList) do
            elements:CredHead(Sections.Credits.Container, sect)

            for _, person in ipairs(c) do
                elements:CredPerson(Sections.Credits.Container, person)
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

    if Sections.Settings and Sections.Settings.Container then
        elements:Toggle("Disable 3D Rendering", Sections.Settings.Container, dec1.settings.disable_3d_rendering, function(v)
            pcall(function()
                local dec = httpservice:JSONDecode(readfile("Dumb/Config.json"))
                dec.settings.disable_3d_rendering = v
                writefile("Dumb/Config.json", httpservice:JSONEncode(dec))
                game:GetService("RunService"):Set3dRenderingEnabled(not v)
            end)
        end)

        elements:Toggle("Auto Rejoin (when kicked)", Sections.Settings.Container, dec1.settings.auto_rejoin_on_kick, function(v)
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


