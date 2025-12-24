local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local ESP = {
    Enabled = true,
    Chams = true,
    Glow = true,
    Walls = true,
    Color = Color3.fromRGB(180, 0, 255),
    Material = "Plastic"
}

local Materials = {
    "Plastic", "Neon", "ForceField", "Glass", "SmoothPlastic",
    "Metal", "Wood", "Concrete", "Granite", "Marble"
}

local highlights = {}
local lights = {}

local function updateESP(newESP)
    ESP = newESP
    updateAllPlayers()
end

local function processPlayer(player)
    if player == LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
    if lights[player] then
        for _, light in ipairs(lights[player]) do
            light:Destroy()
        end
        lights[player] = nil
    end
    
    if not ESP.Enabled then return end
    
    task.spawn(function()
        task.wait(0.5)
        if not character then return end
        
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Accessory") or item:IsA("Hat") then
                item:Destroy()
            end
        end
        
        if ESP.Chams then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        part.Material = Enum.Material[ESP.Material]
                        part.Color = ESP.Color
                        part.Transparency = 0.2
                    end)
                end
            end
        end
        
        if ESP.Walls then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = ESP.Color
            highlight.OutlineColor = ESP.Color
            highlight.FillTransparency = 0.7
            highlight.OutlineTransparency = 0.3
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = character
            highlights[player] = highlight
        end
        
        if ESP.Glow then
            lights[player] = {}
            
            local root = character:FindFirstChild("HumanoidRootPart") or 
                         character:FindFirstChild("Torso") or 
                         character:FindFirstChild("UpperTorso")
            
            if root then
                local pointLight = Instance.new("PointLight")
                pointLight.Brightness = 5
                pointLight.Range = 15
                pointLight.Color = ESP.Color
                pointLight.Shadows = false
                pointLight.Parent = root
                table.insert(lights[player], pointLight)
            end
        end
    end)
end

function updateAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            processPlayer(player)
        end
    end
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character then
            processPlayer(player)
        end
        player.CharacterAdded:Connect(function()
            processPlayer(player)
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            processPlayer(player)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
    if lights[player] then
        for _, light in ipairs(lights[player]) do
            light:Destroy()
        end
        lights[player] = nil
    end
end)

return {
    updateESP = updateESP,
    getESP = function() return ESP end,
    updateAllPlayers = updateAllPlayers,
    Materials = Materials
}
