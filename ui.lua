print("[Dumb UI]: ui.lua execution started (DiscordLib edition)")

local getexec     = identifyexecutor or getexecutor or (function() return "Unknown" end)
local httpservice = game:GetService("HttpService")
local exservice   = game:GetService("ExperienceService")

local import      = import      or (getgenv and getgenv().import)      or _G.import
local getgitpath  = getgitpath  or (getgenv and getgenv().getgitpath)  or _G.getgitpath

if not getgitpath then
    warn("[Dumb UI Error]: 'getgitpath' function is nil!")
    return
end

-- ─── Load DiscordLib from repo ────────────────────────────────────────────────
print("[Dumb UI]: Loading DiscordLib...")
local DiscordLib
local dlOk, dlErr = pcall(function()
    DiscordLib = loadstring(game:HttpGet(getgitpath() .. "discordlib.lua"))()
end)

if not dlOk or not DiscordLib then
    warn("[Dumb UI Error]: Failed to load DiscordLib - " .. tostring(dlErr))
    return
end
print("[Dumb UI]: DiscordLib loaded successfully!")

-- ─── Create Window ────────────────────────────────────────────────────────────
local win = DiscordLib:Window("Dumb")

-- ─── Home Server ──────────────────────────────────────────────────────────────
local homeServ = win:Server("Home", "http://www.roblox.com/asset/?id=6031075938")
local homeChannel = homeServ:Channel("Info")

local execName = "Unknown"
pcall(function()
    local res = getexec()
    if type(res) == "string" then execName = res end
end)

homeChannel:Label("Version: 0.33 BETA")
homeChannel:Label("Executor: " .. execName)
homeChannel:Seperator()
homeChannel:Label("discord.gg/vaehz")
homeChannel:Button("Copy Discord Link", function()
    pcall(setclipboard, "https://discord.gg/vaehz")
    DiscordLib:Notification("Dumb", "Discord link copied to clipboard!", "Okay!")
end)

-- ─── Game Server ──────────────────────────────────────────────────────────────
local gameServ  = win:Server("Game", "")
local gameChan  = gameServ:Channel("Scripts")

print("[Dumb UI]: Checking game script for place " .. tostring(game.PlaceId) .. "...")

local gameScriptUrl = getgitpath("games") .. tostring(game.PlaceId) .. ".lua"
print("[Dumb UI]: Fetching game script from " .. gameScriptUrl)

local ok, gamePath = pcall(function()
    return game:HttpGet(gameScriptUrl)
end)

if not ok or type(gamePath) ~= "string" or #gamePath == 0 or gamePath:find("404") then
    print("[Dumb UI]: No specific game script found for place " .. tostring(game.PlaceId) .. " (Unsupported)")
    local handledLocally = false

    if getgenv and getgenv().FileScripts then
        if isfile and isfile("Dumb/" .. tostring(game.PlaceId) .. ".lua") then
            pcall(function()
                local cfg = {}
                if isfile and isfile("Dumb/Config.json") then
                    cfg = httpservice:JSONDecode(readfile("Dumb/Config.json"))
                end
                local gameModule = loadstring(readfile("Dumb/" .. tostring(game.PlaceId) .. ".lua"))()
                gameModule(gameChan, cfg)
                handledLocally = true
            end)
        end
    end

    if not handledLocally then
        gameChan:Label("This game is not supported yet.")
        gameChan:Seperator()
        gameChan:Label("Want your game added?")
        gameChan:Button("Suggest on Discord", function()
            pcall(setclipboard, "https://discord.gg/vaehz")
            DiscordLib:Notification("Dumb", "Discord link copied! Let us know what game you want.", "Okay!")
        end)
    end
else
    print("[Dumb UI]: Found game script for place " .. tostring(game.PlaceId) .. "! Executing...")
    local gOk, gErr = pcall(function()
        local cfg = {}
        if isfile and isfile("Dumb/Config.json") then
            cfg = httpservice:JSONDecode(readfile("Dumb/Config.json"))
        end
        local gameModule = loadstring(gamePath)()
        gameModule(gameChan, cfg)
    end)
    if not gOk then
        warn("[Dumb UI Error]: Error executing game script: " .. tostring(gErr))
        gameChan:Label("Error loading game script!")
        gameChan:Label(tostring(gErr))
    else
        print("[Dumb UI]: Game script executed successfully!")
    end
end

-- ─── Games List Server ────────────────────────────────────────────────────────
local gameList = {}
pcall(function()
    gameList = httpservice:JSONDecode(game:HttpGet(getgitpath() .. "gameslist.json"))
end)

local glServ = win:Server("Games", "")
local glChan = glServ:Channel("All Games")

if #gameList > 0 then
    for _, g in ipairs(gameList) do
        if g and g["game"] then
            local statusText = ""
            if g["status"] == "🟢" then
                statusText = " [Working]"
            elseif g["status"] == "🟡" then
                statusText = " [Partial]"
            elseif g["status"] == "🔴" then
                statusText = " [Broken]"
            end
            glChan:Button(g["game"] .. statusText, function()
                local launchOk, launchErr = pcall(function()
                    exservice:LaunchExperience({placeId = g.id})
                end)
                if not launchOk then
                    DiscordLib:Notification("Error", "Could not launch game: " .. tostring(launchErr), "Okay!")
                end
            end)
        end
    end
else
    glChan:Label("No games available.")
end

-- ─── Settings Server ──────────────────────────────────────────────────────────
local dec1 = { settings = { disable_3d_rendering = false, auto_rejoin_on_kick = false } }
pcall(function()
    if isfile and isfile("Dumb/Config.json") then
        local parsed = httpservice:JSONDecode(readfile("Dumb/Config.json"))
        if parsed and parsed.settings then dec1 = parsed end
    end
end)

local settingsServ = win:Server("Settings", "http://www.roblox.com/asset/?id=6031280882")
local settingsChan = settingsServ:Channel("General")

settingsChan:Toggle("Disable 3D Rendering", dec1.settings.disable_3d_rendering, function(v)
    pcall(function()
        local dec = httpservice:JSONDecode(readfile("Dumb/Config.json"))
        dec.settings.disable_3d_rendering = v
        writefile("Dumb/Config.json", httpservice:JSONEncode(dec))
        game:GetService("RunService"):Set3dRenderingEnabled(not v)
    end)
end)

settingsChan:Toggle("Auto Rejoin (when kicked)", dec1.settings.auto_rejoin_on_kick, function(v)
    pcall(function()
        local dec = httpservice:JSONDecode(readfile("Dumb/Config.json"))
        dec.settings.auto_rejoin_on_kick = v
        writefile("Dumb/Config.json", httpservice:JSONEncode(dec))
        local env = getgenv and getgenv() or _G
        env.autorjjjj = v
    end)
end)

-- ─── Credits Server ───────────────────────────────────────────────────────────
local creditsList = {}
pcall(function()
    creditsList = httpservice:JSONDecode(game:HttpGet(getgitpath() .. "credits.json"))
end)

local credServ = win:Server("Credits", "")
local credChan = credServ:Channel("Contributors")

if next(creditsList) then
    for section, people in pairs(creditsList) do
        credChan:Label("── " .. tostring(section) .. " ──")
        for _, person in ipairs(people) do
            credChan:Label("  + " .. tostring(person))
        end
        credChan:Seperator()
    end
else
    credChan:Label("No credits to display.")
end

print("[Dumb UI]: DiscordLib UI loaded and running!")
