local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    TeamCheck = false,
    Rainbow = true,
    Box = true,
    Tracer = true,
    HeadDot = true,
    NameText = true,
    DistanceText = true,
    HealthBar = true,
    HealthText = true,
    Chams = true
}

local ESP = {}

function Create(type, props)
    local obj = Drawing.new(type)
    for prop, val in pairs(props) do
        obj[prop] = val
    end
    return obj
end

function ESP:AddPlayer(player)
    if player == LocalPlayer then return end

    ESP[player] = {
        box = Create("Square", {Thickness = 1, Filled = false, Visible = false, ZIndex = 2}),
        tracer = Create("Line", {Thickness = 1, Visible = false, ZIndex = 1}),
        headDot = Create("Circle", {Radius = 3, Filled = true, Visible = false, ZIndex = 2}),
        name = Create("Text", {Size = 14, Center = true, Outline = true, Visible = false}),
        distance = Create("Text", {Size = 13, Center = true, Outline = true, Visible = false}),
        healthText = Create("Text", {Size = 13, Center = true, Outline = true, Visible = false}),
        healthBar = Create("Square", {Filled = true, Visible = false, ZIndex = 2}),
        chamBack = Create("Square", {Filled = true, Color = Color3.new(0, 0, 0), Transparency = 0.4, Visible = false}),
    }
end

function ESP:RemovePlayer(player)
    if ESP[player] then
        for _, item in pairs(ESP[player]) do
            item:Remove()
        end
        ESP[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    ESP:AddPlayer(p)
end

Players.PlayerAdded:Connect(function(p) ESP:AddPlayer(p) end)
Players.PlayerRemoving:Connect(function(p) ESP:RemovePlayer(p) end)

RunService.RenderStepped:Connect(function()
    local hue = tick() % 5 / 5
    local color = Settings.Rainbow and Color3.fromHSV(hue, 1, 1) or Color3.fromRGB(255, 100, 100)

    for _, player in ipairs(Players:GetPlayers()) do
        local data = ESP[player]
        if player == LocalPlayer or not data then continue end

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if not (hrp and head and hum and hum.Health > 0) then
            for _, obj in pairs(data) do obj.Visible = false end
            continue
        end

        if Settings.TeamCheck and player.Team == LocalPlayer.Team then
            for _, obj in pairs(data) do obj.Visible = false end
            continue
        end

        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.2, 0))
        local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
        local scale = math.clamp(500 / distance, 1.5, 6)
        local boxSize = Vector2.new(4, 6) * scale
        local boxPos = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)

        if onScreen then
            if Settings.Box then
                data.box.Size = boxSize
                data.box.Position = boxPos
                data.box.Color = color
                data.box.Visible = true
            else data.box.Visible = false end

            if Settings.Tracer then
                data.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                data.tracer.To = Vector2.new(pos.X, pos.Y)
                data.tracer.Color = color
                data.tracer.Visible = true
            else data.tracer.Visible = false end

            if Settings.HeadDot then
                data.headDot.Position = Vector2.new(headPos.X, headPos.Y)
                data.headDot.Color = color
                data.headDot.Visible = true
            else data.headDot.Visible = false end

            if Settings.NameText then
                data.name.Text = player.Name
                data.name.Position = Vector2.new(pos.X, boxPos.Y - 16)
                data.name.Color = color
                data.name.Visible = true
            else data.name.Visible = false end

            if Settings.DistanceText then
                data.distance.Text = string.format("%.0fm", distance)
                data.distance.Position = Vector2.new(pos.X, boxPos.Y + boxSize.Y + 2)
                data.distance.Color = color
                data.distance.Visible = true
            else data.distance.Visible = false end

            if Settings.HealthText then
                data.healthText.Text = string.format("%d HP", hum.Health)
                data.healthText.Position = Vector2.new(boxPos.X - 30, pos.Y)
                data.healthText.Color = Color3.fromRGB(0, 255, 0)
                data.healthText.Visible = true
            else data.healthText.Visible = false end

            if Settings.HealthBar then
                local hpPerc = hum.Health / hum.MaxHealth
                data.healthBar.Size = Vector2.new(3, boxSize.Y * hpPerc)
                data.healthBar.Position = Vector2.new(boxPos.X - 6, boxPos.Y + (boxSize.Y * (1 - hpPerc)))
                data.healthBar.Color = Color3.fromRGB(0, 255, 0)
                data.healthBar.Visible = true
            else data.healthBar.Visible = false end

            if Settings.Chams then
                data.chamBack.Size = boxSize + Vector2.new(4, 4)
                data.chamBack.Position = boxPos - Vector2.new(2, 2)
                data.chamBack.Visible = true
            else data.chamBack.Visible = false end
        else
            for _, obj in pairs(data) do obj.Visible = false end
        end
    end
end)
