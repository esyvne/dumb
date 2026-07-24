-- Flick script

return function(section, data, mkButton, mkToggle, mkLabel, mkDivider, mkTextbox, mkSection)
    local HttpService = game:GetService("HttpService")

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.esp_enabled = setdata.esp_enabled ~= false
    setdata.esp_color = setdata.esp_color or "255,0,0"
    setdata.esp_fov = setdata.esp_fov or 350
    setdata.esp_skeleton = setdata.esp_skeleton ~= false
    data[tostring(game.PlaceId)] = setdata
    writefile("Dumb/Config.json", HttpService:JSONEncode(data))

    local function save()
        writefile("Dumb/Config.json", HttpService:JSONEncode(data))
    end

    if section then
        mkSection(section, "ESP Settings")
        mkToggle(section, "ESP Enabled", setdata.esp_enabled, function(v)
            setdata.esp_enabled = v
            save()
        end)
        mkTextbox(section, "ESP Color (R,G,B)", tostring(setdata.esp_color or "255,0,0"), function(v)
            setdata.esp_color = tostring(v or "255,0,0")
            save()
        end)
        mkTextbox(section, "ESP FOV", tostring(setdata.esp_fov or 350), function(v)
            local num = tonumber(v) or 350
            setdata.esp_fov = math.clamp(math.floor(num), 80, 800)
            save()
        end)
        mkToggle(section, "Show Skeleton", setdata.esp_skeleton, function(v)
            setdata.esp_skeleton = v
            save()
        end)
    end

    task.spawn(function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")
        local LocalPlayer = Players.LocalPlayer
        local Camera = workspace.CurrentCamera
        local Mouse = LocalPlayer:GetMouse()

        local HoldingLMB = false
        local Beam, Att0, Att1 = nil, nil, nil
        local FOV_RADIUS = 350

        local function getPlaceSettings()
            local settings = {}
            pcall(function()
                if isfile and isfile("Dumb/Config.json") then
                    local parsed = HttpService:JSONDecode(readfile("Dumb/Config.json"))
                    settings = parsed[tostring(game.PlaceId)] or {}
                end
            end)
            return settings
        end

        local function parseColor(value)
            if type(value) == "table" then
                return Color3.fromRGB(math.clamp(math.floor(value[1] or 255), 0, 255), math.clamp(math.floor(value[2] or 0), 0, 255), math.clamp(math.floor(value[3] or 0), 0, 255))
            end

            local numbers = {}
            if type(value) == "string" then
                for part in string.gmatch(value, "[^,]+") do
                    table.insert(numbers, tonumber(part))
                end
            end

            if #numbers >= 3 then
                return Color3.fromRGB(
                    math.clamp(math.floor(numbers[1] or 255), 0, 255),
                    math.clamp(math.floor(numbers[2] or 0), 0, 255),
                    math.clamp(math.floor(numbers[3] or 0), 0, 255)
                )
            end

            return Color3.fromRGB(255, 0, 0)
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "ESPGui"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

        local function getRainbow(t)
            local freq = 1.8
            return Color3.new(
                math.sin(freq * t) * 0.5 + 0.5,
                math.sin(freq * t + 2.1) * 0.5 + 0.5,
                math.sin(freq * t + 4.2) * 0.5 + 0.5
            )
        end

        local ESPObjects = {}
        local SkeletonLines = {}

        local function createFrame(props)
            local frame = Instance.new("Frame")
            frame.BackgroundColor3 = Color3.new(1, 1, 1)
            frame.BorderSizePixel = 0
            frame.Visible = false
            frame.Parent = screenGui
            for k, v in pairs(props or {}) do
                frame[k] = v
            end
            return frame
        end

        local function createLine(thickness)
            local line = Instance.new("Frame")
            line.BorderSizePixel = 0
            line.BackgroundColor3 = Color3.new(1, 1, 1)
            line.AnchorPoint = Vector2.new(0.5, 0.5)
            line.Visible = false
            line.Parent = screenGui
            return line
        end

        local function createESPElements()
            local box = {
                Top = createLine(),
                Bottom = createLine(),
                Left = createLine(),
                Right = createLine()
            }

            local name = Instance.new("TextLabel")
            name.BackgroundTransparency = 1
            name.TextColor3 = Color3.new(1, 1, 1)
            name.Font = Enum.Font.Code
            name.TextSize = 15
            name.TextStrokeTransparency = 0.5
            name.Visible = false
            name.Parent = screenGui

            local tracer = createLine()
            local healthBG = createLine()
            local healthFG = createLine()

            return {
                Box = box,
                Name = name,
                Tracer = tracer,
                HealthBG = healthBG,
                HealthFG = healthFG
            }
        end

        local function createCircle()
            local circle = Instance.new("ImageLabel")
            circle.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2)
            circle.BackgroundTransparency = 1
            circle.Image = "rbxassetid://"
            circle.ImageColor3 = Color3.new(1, 1, 1)
            circle.ImageTransparency = 0
            circle.Visible = true
            circle.Parent = screenGui
            return circle
        end

        local FOVCircle = createCircle()

        local SkeletonConnections = {
            R15 = {
                {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
                {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
                {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"},
                {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
                {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}
            },
            R6 = {
                {"Head", "Torso"},
                {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
                {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
            }
        }

        local function initSkeleton(plr)
            if SkeletonLines[plr] then return end
            SkeletonLines[plr] = {}
            for i = 1, #SkeletonConnections.R15 do
                SkeletonLines[plr][i] = createLine()
            end
        end

        local function updateLine(line, from, to, color, thickness)
            local distance = (to - from).Magnitude
            local midpoint = (from + to) / 2
            line.Position = UDim2.new(0, midpoint.X, 0, midpoint.Y)
            line.Size = UDim2.new(0, distance, 0, thickness or 2)
            line.Rotation = math.deg(math.atan2(to.Y - from.Y, to.X - from.X))
            line.BackgroundColor3 = color
            line.Visible = true
        end

        local function updateSkeleton(plr, rainbow)
            local lines = SkeletonLines[plr]
            if not lines then return end

            local char = plr.Character
            if not char then
                for _, line in pairs(lines) do line.Visible = false end
                return
            end

            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then
                for _, line in pairs(lines) do line.Visible = false end
                return
            end

            local conns = (hum.RigType == Enum.HumanoidRigType.R15) and SkeletonConnections.R15 or SkeletonConnections.R6
            for i, conn in ipairs(conns) do
                local line = lines[i]
                local p1 = char:FindFirstChild(conn[1])
                local p2 = char:FindFirstChild(conn[2])
                if p1 and p2 then
                    local s1, vis1 = Camera:WorldToViewportPoint(p1.Position)
                    local s2, vis2 = Camera:WorldToViewportPoint(p2.Position)
                    if vis1 and vis2 then
                        updateLine(line, Vector2.new(s1.X, s1.Y), Vector2.new(s2.X, s2.Y), rainbow, 2.3)
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            end
        end

        local function cleanupPlayer(plr)
            if ESPObjects[plr] then
                local data = ESPObjects[plr]
                if data.Box then
                    for _, line in pairs(data.Box) do line:Destroy() end
                end
                if data.Name then data.Name:Destroy() end
                if data.Tracer then data.Tracer:Destroy() end
                if data.HealthBG then data.HealthBG:Destroy() end
                if data.HealthFG then data.HealthFG:Destroy() end
                ESPObjects[plr] = nil
            end
            if SkeletonLines[plr] then
                for _, line in pairs(SkeletonLines[plr]) do line:Destroy() end
                SkeletonLines[plr] = nil
            end
        end

        RunService.RenderStepped:Connect(function()
            local settings = getPlaceSettings()
            if settings.esp_enabled == false then
                for _, data in pairs(ESPObjects) do
                    if data then
                        for _, line in pairs(data.Box or {}) do line.Visible = false end
                        if data.Name then data.Name.Visible = false end
                        if data.Tracer then data.Tracer.Visible = false end
                        if data.HealthBG then data.HealthBG.Visible = false end
                        if data.HealthFG then data.HealthFG.Visible = false end
                    end
                end
                if Beam then
                    Beam:Destroy()
                    Att0:Destroy()
                    Att1:Destroy()
                    Beam, Att0, Att1 = nil, nil, nil
                end
                return
            end

            local espColor = parseColor(settings.esp_color or "255,0,0")
            local radius = tonumber(settings.esp_fov) or FOV_RADIUS
            local showSkeleton = settings.esp_skeleton ~= false
            local rainbow = espColor
            local viewportSize = Camera.ViewportSize
            local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
            local mousePos = Vector2.new(Mouse.X, Mouse.Y)

            FOVCircle.Size = UDim2.new(0, radius * 2, 0, radius * 2)
            FOVCircle.Position = UDim2.new(0, center.X - radius, 0, center.Y - radius)
            FOVCircle.ImageColor3 = rainbow

            local closestTarget = nil
            local closestDist = radius

            for _, plr in ipairs(Players:GetPlayers()) do
                if plr == LocalPlayer or not plr.Character then continue end

                local char = plr.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")

                if not (hum and root and head and hum.Health > 0) then
                    local data = ESPObjects[plr]
                    if data then
                        for _, line in pairs(data.Box) do line.Visible = false end
                        data.Name.Visible = false
                        data.Tracer.Visible = false
                        data.HealthBG.Visible = false
                        data.HealthFG.Visible = false
                    end
                    if showSkeleton then
                        updateSkeleton(plr, rainbow)
                    else
                        local lines = SkeletonLines[plr]
                        if lines then
                            for _, line in pairs(lines) do line.Visible = false end
                        end
                    end
                    continue
                end

                local headScreen, headVisible = Camera:WorldToViewportPoint(head.Position)
                if not headVisible then
                    local data = ESPObjects[plr]
                    if data then
                        for _, line in pairs(data.Box) do line.Visible = false end
                        data.Name.Visible = false
                        data.Tracer.Visible = false
                        data.HealthBG.Visible = false
                        data.HealthFG.Visible = false
                    end
                    if showSkeleton then
                        updateSkeleton(plr, rainbow)
                    else
                        local lines = SkeletonLines[plr]
                        if lines then
                            for _, line in pairs(lines) do line.Visible = false end
                        end
                    end
                    continue
                end

                local distToMouse = (Vector2.new(headScreen.X, headScreen.Y) - mousePos).Magnitude
                if distToMouse < closestDist then
                    closestDist = distToMouse
                    closestTarget = head
                end

                local data = ESPObjects[plr]
                if not data then
                    data = createESPElements()
                    ESPObjects[plr] = data
                end

                initSkeleton(plr)

                local success, cframe, size = pcall(char.GetBoundingBox, char)
                if not (success and cframe and size and size.Magnitude > 2 and size.Magnitude < 50) then
                    for _, line in pairs(data.Box) do line.Visible = false end
                    data.Name.Visible = false
                    data.Tracer.Visible = false
                    continue
                end

                local points = {}
                local half = size / 2
                for x = -1, 1, 2 do
                    for y = -1, 1, 2 do
                        for z = -1, 1, 2 do
                            local corner = cframe * Vector3.new(half.X * x, half.Y * y, half.Z * z)
                            local screenPos, onScreen = Camera:WorldToViewportPoint(corner)
                            table.insert(points, Vector2.new(screenPos.X, screenPos.Y))
                        end
                    end
                end

                local minX, minY = math.huge, math.huge
                local maxX, maxY = -math.huge, -math.huge
                for _, pt in ipairs(points) do
                    minX = math.min(minX, pt.X)
                    minY = math.min(minY, pt.Y)
                    maxX = math.max(maxX, pt.X)
                    maxY = math.max(maxY, pt.Y)
                end

                local boxW = maxX - minX
                local boxH = maxY - minY
                if boxW < 1 or boxH < 1 then continue end

                local slimW = boxW * 0.75
                local slimX = minX + (boxW - slimW) / 2
                local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                local healthLen = boxH * healthPct

                local thickness = 2.2
                updateLine(data.Box.Top, Vector2.new(slimX, minY), Vector2.new(slimX + slimW, minY), rainbow, thickness)
                updateLine(data.Box.Bottom, Vector2.new(slimX, maxY), Vector2.new(slimX + slimW, maxY), rainbow, thickness)
                updateLine(data.Box.Left, Vector2.new(slimX, minY), Vector2.new(slimX, maxY), rainbow, thickness)
                updateLine(data.Box.Right, Vector2.new(slimX + slimW, minY), Vector2.new(slimX + slimW, maxY), rainbow, thickness)

                data.Name.Text = plr.Name
                data.Name.Position = UDim2.new(0, slimX + slimW / 2, 0, minY - 22)
                data.Name.TextColor3 = rainbow
                data.Name.Visible = true

                updateLine(data.Tracer, center, Vector2.new(slimX + slimW / 2, maxY), rainbow, 1.8)
                updateLine(data.HealthBG, Vector2.new(slimX - 8, minY), Vector2.new(slimX - 8, maxY), Color3.new(0, 0, 0), 5)
                updateLine(data.HealthFG, Vector2.new(slimX - 8, maxY), Vector2.new(slimX - 8, maxY - healthLen), rainbow, 3)

                updateSkeleton(plr, rainbow)
            end

            if HoldingLMB and closestTarget then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
                if not Beam then
                    Beam = Instance.new("Beam")
                    Att0 = Instance.new("Attachment", workspace.Terrain)
                    Att1 = Instance.new("Attachment", workspace.Terrain)
                    Beam.Attachment0 = Att0
                    Beam.Attachment1 = Att1
                    Beam.Color = ColorSequence.new(Color3.fromRGB(255, 50, 50))
                    Beam.Width0 = 0.25
                    Beam.Width1 = 0.25
                    Beam.FaceCamera = true
                    Beam.Transparency = NumberSequence.new(0.25)
                    Beam.LightEmission = 1
                    Beam.Parent = workspace.Terrain
                end
                Att0.WorldPosition = Camera.CFrame.Position
                Att1.WorldPosition = closestTarget.Position
            else
                if Beam then
                    Beam:Destroy()
                    Att0:Destroy()
                    Att1:Destroy()
                    Beam, Att0, Att1 = nil, nil, nil
                end
            end
        end)

        UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                HoldingLMB = true
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                HoldingLMB = false
            end
        end)

        Players.PlayerRemoving:Connect(cleanupPlayer)
    end)
end
