local import = import or (getgenv and getgenv().import) or _G.import
local getgitpath = getgitpath or (getgenv and getgenv().getgitpath) or _G.getgitpath

local elements = import("rbxassetid://113037265185555")
local stuff = {}
local gameList = {}
pcall(function()
    gameList = game:GetService("HttpService"):JSONDecode(game:HttpGet(getgitpath("src") .. "gameslist.json"))
end)


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

local function applyElementTheme(inst)
    if inst:IsA("GuiObject") then
        if inst:IsA("Frame") or inst:IsA("ScrollingFrame") or inst:IsA("CanvasGroup") then
            if inst.BackgroundTransparency < 0.95 then
                inst.BackgroundColor3 = DarkTheme.CardBg
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
            if inst.BackgroundTransparency < 0.95 then
                inst.BackgroundColor3 = DarkTheme.CardBg
            end
        elseif inst:IsA("UIStroke") then
            inst.Color = DarkTheme.StrokeColor
        end
    end
    for _, child in ipairs(inst:GetChildren()) do
        applyElementTheme(child)
    end
end

function stuff:Label(str, king)
    local newLabel = elements.LabelElement:Clone()
    if newLabel:IsA("TextLabel") then
        newLabel.Text = str
        newLabel.TextColor3 = DarkTheme.TextPrimary
    elseif newLabel:FindFirstChild("TextLabel") then
        newLabel.TextLabel.Text = str
        newLabel.TextLabel.TextColor3 = DarkTheme.TextPrimary
    end
    applyElementTheme(newLabel)
    newLabel.Parent = king
end

function stuff:Button(str, king, cb)
    local newBtn = elements.ButtonElement:Clone()
    if newBtn:FindFirstChild("TextLabel") then
        newBtn.TextLabel.Text = str
        newBtn.TextLabel.TextColor3 = DarkTheme.TextPrimary
    elseif newBtn:IsA("TextButton") then
        newBtn.Text = str
        newBtn.TextColor3 = DarkTheme.TextPrimary
    end
    
    if newBtn:IsA("GuiObject") and newBtn.BackgroundTransparency < 0.95 then
        newBtn.BackgroundColor3 = DarkTheme.CardBg
    end
    applyElementTheme(newBtn)

    newBtn.MouseEnter:Connect(function()
        if newBtn:IsA("GuiObject") and newBtn.BackgroundTransparency < 0.95 then
            newBtn.BackgroundColor3 = DarkTheme.CardHoverBg
        end
    end)
    newBtn.MouseLeave:Connect(function()
        if newBtn:IsA("GuiObject") and newBtn.BackgroundTransparency < 0.95 then
            newBtn.BackgroundColor3 = DarkTheme.CardBg
        end
    end)

    newBtn.Parent = king
    newBtn.MouseButton1Click:Connect(cb)
end

function stuff:Toggle(str, king, def, cb)
    local newTog = elements.ToggleElement:Clone()
    if newTog:FindFirstChild("TextLabel") then
        newTog.TextLabel.Text = str
        newTog.TextLabel.TextColor3 = DarkTheme.TextPrimary
    end
    if newTog:IsA("GuiObject") and newTog.BackgroundTransparency < 0.95 then
        newTog.BackgroundColor3 = DarkTheme.CardBg
    end
    applyElementTheme(newTog)

    local isTog = def
    local function updateToggleVisual()
        if isTog then
            newTog.togglebg.BackgroundColor3 = DarkTheme.ToggleOn
            newTog.togglebg.leftrightlol.AnchorPoint = Vector2.new(1, 0.5)
            newTog.togglebg.leftrightlol.Position = UDim2.new(1, 0, 0.5, 0)
        else
            newTog.togglebg.BackgroundColor3 = DarkTheme.ToggleOff
            newTog.togglebg.leftrightlol.AnchorPoint = Vector2.new(0, 0.5)
            newTog.togglebg.leftrightlol.Position = UDim2.new(0, 0, 0.5, 0)
        end
        if newTog.togglebg:FindFirstChild("leftrightlol") then
            newTog.togglebg.leftrightlol.BackgroundColor3 = DarkTheme.ToggleKnob
        end
    end

    updateToggleVisual()
    task.defer(function() cb(isTog) end)

    newTog.MouseButton1Click:Connect(function()
        isTog = not isTog
        updateToggleVisual()
        cb(isTog)
    end)

    newTog.Parent = king
end

function stuff:Textbox(str, king, def, cb)
    local newTb = elements.TextboxElement:Clone()
    if newTb:FindFirstChild("TextLabel") then
        newTb.TextLabel.Text = str
        newTb.TextLabel.TextColor3 = DarkTheme.TextPrimary
    end
    if newTb:IsA("GuiObject") and newTb.BackgroundTransparency < 0.95 then
        newTb.BackgroundColor3 = DarkTheme.CardBg
    end
    applyElementTheme(newTb)

    if newTb:FindFirstChild("tbbg") then
        newTb.tbbg.BackgroundColor3 = DarkTheme.InputBg
        if newTb.tbbg:FindFirstChild("Inp") then
            newTb.tbbg.Inp.TextColor3 = DarkTheme.TextPrimary
            newTb.tbbg.Inp.PlaceholderColor3 = DarkTheme.TextSecondary
            if def then
                newTb.tbbg.Inp.Text = tostring(def)
            end
            newTb.tbbg.Inp.FocusLost:Connect(function(ep)
                cb(newTb.tbbg.Inp.Text)
            end)
        end
    end

    newTb.Parent = king
end

function stuff:Unsupported(king, cb)
    local newUs = elements.unsupportElement:Clone()
    applyElementTheme(newUs)

    if newUs:FindFirstChild("suggestbtn") then
        newUs.suggestbtn.BackgroundColor3 = DarkTheme.CardHoverBg
        newUs.suggestbtn.TextColor3 = DarkTheme.TextPrimary
        newUs.suggestbtn.MouseButton1Click:Connect(function()
            setclipboard("https://discord.gg/vaehz")
            newUs.suggestbtn.Text = "Copied Link!"
            wait(1)
            newUs.suggestbtn.Text = "Suggest Game"
        end)
    end

    if newUs:FindFirstChild("glbtn") then
        newUs.glbtn.BackgroundColor3 = DarkTheme.CardHoverBg
        newUs.glbtn.TextColor3 = DarkTheme.TextPrimary
        newUs.glbtn.MouseButton1Click:Connect(cb)
    end

    newUs.Parent = king
end

function stuff:addGame(king, gname, gstate, cb)
    local newGame = elements.GameElement:Clone()
    applyElementTheme(newGame)

    if newGame:FindFirstChild("ButtonElement") then
        newGame.ButtonElement.BackgroundColor3 = DarkTheme.CardBg
        if newGame.ButtonElement:FindFirstChild("header") then
            newGame.ButtonElement.header.Text = gname
            newGame.ButtonElement.header.TextColor3 = DarkTheme.TextPrimary
        end

        if gstate == "🟢" then
            newGame.ButtonElement.status.ImageColor3 = Color3.fromRGB(46, 204, 113)
        elseif gstate == "🟡" then
            newGame.ButtonElement.status.ImageColor3 = Color3.fromRGB(241, 196, 15)
        elseif gstate == "🔴" then
            newGame.ButtonElement.status.ImageColor3 = Color3.fromRGB(231, 76, 60)
        end

        newGame.ButtonElement.MouseEnter:Connect(function()
            newGame.ButtonElement.BackgroundColor3 = DarkTheme.CardHoverBg
        end)
        newGame.ButtonElement.MouseLeave:Connect(function()
            newGame.ButtonElement.BackgroundColor3 = DarkTheme.CardBg
        end)

        newGame.ButtonElement.MouseButton1Click:Connect(cb)
    end

    newGame.Parent = king
end

-- to finish
function stuff:Searchbar(king)
    local newSearch = elements.searchBar:Clone()
    applyElementTheme(newSearch)

    if newSearch:FindFirstChild("searchbar") then
        newSearch.searchbar.BackgroundColor3 = DarkTheme.InputBg
        if newSearch.searchbar:FindFirstChild("Inp") then
            newSearch.searchbar.Inp.TextColor3 = DarkTheme.TextPrimary
            newSearch.searchbar.Inp.PlaceholderColor3 = DarkTheme.TextSecondary
            newSearch.searchbar.Inp:GetPropertyChangedSignal("Text"):Connect(function()
                for i, v in pairs(king:GetChildren()) do
                    if v.Name == "GameElement" then
                        v:Destroy()
                    end
                end

                for i, v in pairs(gameList) do
                    if v["game"]:lower():find(newSearch.searchbar.Inp.Text:lower()) then
                        stuff:addGame(king, v["game"], v["status"], function()
                            game:GetService("ExperienceService"):LaunchExperience({placeId = v["id"]})
                        end)
                    end
                end
            end)
        end
    end

    newSearch.Parent = king
end

function stuff:CredHead(king, txt)
    local newHead = elements.CreditHeader:Clone()
    newHead.Text = "> " .. txt
    newHead.TextColor3 = DarkTheme.Accent
    newHead.Parent = king
end

function stuff:CredPerson(king, txt)
    local newCred = elements.CreditPerson:Clone()
    newCred.Text = "      + " .. txt
    newCred.TextColor3 = DarkTheme.TextSecondary
    newCred.Parent = king
end

return stuff

