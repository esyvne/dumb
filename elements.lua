local getgitpath = getgitpath or (getgenv and getgenv().getgitpath) or _G.getgitpath
local httpservice = game:GetService("HttpService")

local stuff = {}
local gameList = {}
pcall(function()
    gameList = httpservice:JSONDecode(game:HttpGet(getgitpath("src") .. "gameslist.json"))
end)

local theme = {
    bg = Color3.fromRGB(7, 8, 12),
    panel = Color3.fromRGB(12, 14, 20),
    panel2 = Color3.fromRGB(18, 21, 29),
    border = Color3.fromRGB(40, 44, 56),
    accent = Color3.fromRGB(126, 58, 242),
    text = Color3.fromRGB(243, 245, 248),
    muted = Color3.fromRGB(147, 153, 172),
    green = Color3.fromRGB(46, 204, 113),
    red = Color3.fromRGB(231, 76, 60)
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

function stuff:Label(str, king)
    local lbl = make("TextLabel", king, {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = str,
        TextColor3 = theme.text,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    return lbl
end

function stuff:Button(str, king, cb)
    local btn = make("TextButton", king, {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = theme.panel2,
        BorderSizePixel = 0,
        Text = str,
        TextColor3 = theme.text,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        AutoButtonColor = false
    })
    makeCorner(btn, 8)
    makeStroke(btn, theme.border, 0.15, 1)

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = theme.panel
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = theme.panel2
    end)

    if cb then
        btn.MouseButton1Click:Connect(cb)
    end
    return btn
end

function stuff:Toggle(str, king, def, cb)
    local frame = make("Frame", king, {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = theme.panel2,
        BorderSizePixel = 0
    })
    makeCorner(frame, 8)
    makeStroke(frame, theme.border, 0.15, 1)

    local label = make("TextLabel", frame, {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = str,
        TextColor3 = theme.text,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local toggleBg = make("Frame", frame, {
        Size = UDim2.new(0, 44, 0, 20),
        Position = UDim2.new(1, -54, 0.5, -10),
        BackgroundColor3 = theme.border,
        BorderSizePixel = 0
    })
    makeCorner(toggleBg, 10)

    local knob = make("Frame", toggleBg, {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = theme.text,
        BorderSizePixel = 0
    })
    makeCorner(knob, 8)

    local isOn = def or false
    local function update()
        toggleBg.BackgroundColor3 = isOn and theme.accent or theme.border
        knob.Position = isOn and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    end
    update()

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isOn = not isOn
            update()
            if cb then
                cb(isOn)
            end
        end
    end)

    return frame
end

function stuff:Textbox(str, king, def, cb)
    local frame = make("Frame", king, {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = theme.panel2,
        BorderSizePixel = 0
    })
    makeCorner(frame, 8)
    makeStroke(frame, theme.border, 0.15, 1)

    local label = make("TextLabel", frame, {
        Size = UDim2.new(1, -16, 0, 18),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundTransparency = 1,
        Text = str,
        TextColor3 = theme.text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local box = make("TextBox", frame, {
        Size = UDim2.new(1, -16, 0, 24),
        Position = UDim2.new(0, 8, 0, 28),
        BackgroundColor3 = theme.panel,
        BorderSizePixel = 0,
        Text = tostring(def or ""),
        TextColor3 = theme.text,
        PlaceholderText = "Enter value",
        PlaceholderColor3 = theme.muted,
        Font = Enum.Font.Gotham,
        TextSize = 12
    })
    makeCorner(box, 8)
    makeStroke(box, theme.border, 0.15, 1)

    box.FocusLost:Connect(function()
        if cb then
            cb(box.Text)
        end
    end)

    return frame
end

function stuff:Unsupported(king, cb)
    local card = make("Frame", king, {
        Size = UDim2.new(1, 0, 0, 96),
        BackgroundColor3 = theme.panel2,
        BorderSizePixel = 0
    })
    makeCorner(card, 10)
    makeStroke(card, theme.border, 0.15, 1)

    make("TextLabel", card, {
        Size = UDim2.new(1, -16, 0, 18),
        Position = UDim2.new(0, 8, 0, 10),
        BackgroundTransparency = 1,
        Text = "Unsupported game",
        TextColor3 = theme.text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    make("TextLabel", card, {
        Size = UDim2.new(1, -16, 0, 24),
        Position = UDim2.new(0, 8, 0, 34),
        BackgroundTransparency = 1,
        Text = "This experience does not have a dedicated script yet.",
        TextColor3 = theme.muted,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })

    local btn = make("TextButton", card, {
        Size = UDim2.new(0, 120, 0, 28),
        Position = UDim2.new(0, 8, 0, 60),
        BackgroundColor3 = theme.accent,
        BorderSizePixel = 0,
        Text = "Browse games",
        TextColor3 = theme.text,
        Font = Enum.Font.Gotham,
        TextSize = 12
    })
    makeCorner(btn, 8)
    btn.MouseButton1Click:Connect(cb)

    return card
end

function stuff:addGame(king, gname, gstate, cb)
    local btn = make("TextButton", king, {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = theme.panel2,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    })
    makeCorner(btn, 8)
    makeStroke(btn, theme.border, 0.15, 1)

    local title = make("TextLabel", btn, {
        Size = UDim2.new(1, -42, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = gname,
        TextColor3 = theme.text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })

    local status = make("Frame", btn, {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -24, 0.5, -6),
        BackgroundColor3 = gstate == "🟢" and theme.green or (gstate == "🔴" and theme.red or theme.border),
        BorderSizePixel = 0
    })
    makeCorner(status, 6)

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = theme.panel
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = theme.panel2
    end)
    btn.MouseButton1Click:Connect(cb)

    return btn
end

function stuff:Searchbar(king)
    local frame = make("Frame", king, {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = theme.panel2,
        BorderSizePixel = 0
    })
    makeCorner(frame, 8)
    makeStroke(frame, theme.border, 0.15, 1)

    local box = make("TextBox", frame, {
        Size = UDim2.new(1, -12, 1, -8),
        Position = UDim2.new(0, 6, 0, 4),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search games",
        PlaceholderColor3 = theme.muted,
        TextColor3 = theme.text,
        Font = Enum.Font.Gotham,
        TextSize = 12
    })

    box:GetPropertyChangedSignal("Text"):Connect(function()
        for _, child in ipairs(king:GetChildren()) do
            if child.Name == "GameButton" then
                child:Destroy()
            end
        end

        for _, v in ipairs(gameList) do
            if v and v["game"] and v["game"]:lower():find(box.Text:lower()) then
                local gameBtn = stuff:addGame(king, v["game"], v["status"], function()
                    game:GetService("ExperienceService"):LaunchExperience({ placeId = v["id"] })
                end)
                gameBtn.Name = "GameButton"
            end
        end
    end)

    return frame
end

function stuff:CredHead(king, txt)
    local lbl = make("TextLabel", king, {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "> " .. txt,
        TextColor3 = theme.accent,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    return lbl
end

function stuff:CredPerson(king, txt)
    local lbl = make("TextLabel", king, {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = "  + " .. txt,
        TextColor3 = theme.muted,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    return lbl
end

return stuff

