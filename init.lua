print("[Dumb UI]: Initializing loader...")

if not game:IsLoaded() then
    print("[Dumb UI]: Waiting for game to load...")
    pcall(function() game.Loaded:Wait() end)
end

local env = (getgenv and getgenv()) or _G or shared

if isfolder and not isfolder("Dumb") then 
    pcall(makefolder, "Dumb") 
end

if isfile and not isfile("Dumb/Config.json") then
    pcall(writefile, "Dumb/Config.json", game:GetService("HttpService"):JSONEncode({
        settings = {
            auto_rejoin_on_kick = false,
            disable_3d_rendering = false
        }
    }))
end

local function getgitpath(where)
    local mainBuild = "https://raw.githubusercontent.com/esyvne/dumb/main/"
    if where == "games" then
        return mainBuild .. "games/"
    end
    return mainBuild
end

local function import(id)
    print("[Dumb UI]: Importing asset -> " .. tostring(id))
    local getobj = getobjects or (game and game.GetObjects)
    if getobj then
        local ok, res = pcall(function()
            return getobj(game, id)[1]
        end)
        if ok and res then
            print("[Dumb UI]: Successfully imported " .. tostring(id))
            return res
        end
    end
    local ok2, res2 = pcall(function()
        return game:GetObjects(id)[1]
    end)
    if ok2 and res2 then
        print("[Dumb UI]: Successfully imported (fallback) " .. tostring(id))
        return res2
    end
    warn("[Dumb UI]: Failed to import asset " .. tostring(id))
    return nil
end

local function setconfig(key, value)
    local httpservice = game:GetService("HttpService")
    local dec = {}
    pcall(function()
        if isfile and isfile("Dumb/Config.json") then
            dec = httpservice:JSONDecode(readfile("Dumb/Config.json"))
        end
    end)
    if type(dec) ~= "table" then dec = {} end
    dec[tostring(game.PlaceId)] = dec[tostring(game.PlaceId)] or {}
    dec[tostring(game.PlaceId)][key] = value
    pcall(function()
        if writefile then
            writefile("Dumb/Config.json", httpservice:JSONEncode(dec))
        end
    end)
end

env.getgitpath = getgitpath
env.import = import
env.setconfig = setconfig
_G.getgitpath = getgitpath
_G.import = import
_G.setconfig = setconfig

pcall(function()
    game:GetService("GuiService").ErrorMessageChanged:Connect(function()
        if env.autorjjjj then
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        end
    end)
end)

pcall(function()
    game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(false)
end)

print("[Dumb UI]: Fetching ui.lua from " .. getgitpath() .. "ui.lua")

local success, err = pcall(function()
    local uiCode = game:HttpGet(getgitpath() .. "ui.lua")
    local func, loadErr = loadstring(uiCode)
    if not func then
        error("Syntax error in ui.lua: " .. tostring(loadErr))
    end
    func()
end)

if not success then
    warn("[Dumb UI Error]: Failed to load ui.lua - " .. tostring(err))
    print("[Dumb UI Error]: Failed to load ui.lua - " .. tostring(err))
else
    print("[Dumb UI]: ui.lua loaded successfully!")
end

if queue_on_teleport then
    pcall(function()
        queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/esyvne/dumb/main/init.lua"))()')
    end)
end



