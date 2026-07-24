-- Would You Rather Gear Tower X Script

return function(section, data, mkButton, mkToggle, mkLabel, mkDivider, mkTextbox, mkSection)
    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.autokickeveryone = setdata.autokickeveryone or false
    data[tostring(game.PlaceId)] = setdata
    writefile("Dumb/Config.json", game:GetService("HttpService"):JSONEncode(data))

    local running = false

    mkToggle(section, "Auto Kick Everyone", setdata.autokickeveryone, function(isOn)
        setconfig("autokickeveryone", isOn)
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
                    task.wait(0.1)
                end
            end)
        end
    end)
end
