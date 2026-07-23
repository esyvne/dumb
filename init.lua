if not game:IsLoaded() then
    game.Loaded:Wait()
end
local env = getgenv()

if not isfolder("Dumb") then makefolder("Dumb") end
if not isfile("Dumb/Config.json") then
    writefile("Dumb/Config.json", game:GetService("HttpService"):JSONEncode({
        settings = {
            auto_rejoin_on_kick = false,
            disable_3d_rendering = false
        }
    }))
end

function env.import(id)
    return game:GetObjects(id)[1]
end

function env.getgitpath(where)
    local mainBuild = "https://raw.githubusercontent.com/esyvne/dumb/refs/heads/main/"
    if where == "games" then
        return mainBuild .. "games/"
    end
    return mainBuild
end

function env.setconfig(key, value)
    local httpservice = game:GetService("HttpService")
    local dec = httpservice:JSONDecode(readfile("Dumb/Config.json"))
    dec[tostring(game.PlaceId)] = dec[tostring(game.PlaceId)] or {}
    dec[tostring(game.PlaceId)][key] = value
    writefile("Dumb/Config.json", httpservice:JSONEncode(dec))
end

game:GetService("GuiService").ErrorMessageChanged:Connect(function()
    if env.autorjjjj then
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
end)

game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(false)

loadstring(game:HttpGet(getgitpath("src").."ui.lua"))()

if queue_on_teleport then
    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/esyvne/dumb/refs/heads/main/init.lua"))()')
end

