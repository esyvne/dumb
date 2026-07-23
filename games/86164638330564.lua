-- Would You Rather Gear Tower X Script

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.autoPrompt = setdata.autoPrompt or false
    data[tostring(game.PlaceId)] = setdata
    writefile("Dumb/Config.json", game:GetService("HttpService"):JSONEncode(data))

    local running = false

    elements:Toggle("Auto Prompt Purchase", section, setdata.autoPrompt, function(isOn)
        setconfig("autoPrompt", isOn)
        running = isOn
        if isOn then
            task.spawn(function()
                local m = game:GetService("MarketplaceService")
                local p = game:GetService("Players")
                local id = 3565103225
                while running do
                    pcall(function()
                        m:SignalPromptProductPurchaseFinished(p.LocalPlayer.UserId, id, true)
                    end)
                    task.wait(1)
                end
            end)
        end
    end)
end
