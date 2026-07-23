-- Example Game Script

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.exampleToggle = setdata.exampleToggle or false
    data[tostring(game.PlaceId)] = setdata
    writefile("Dumb/Config.json", game:GetService("HttpService"):JSONEncode(data))

    elements:Toggle("Example Toggle", section, setdata.exampleToggle, function(isOn)
        setconfig("exampleToggle", isOn)
        if isOn then
            print("Example feature enabled")
        else
            print("Example feature disabled")
        end
    end)
end
