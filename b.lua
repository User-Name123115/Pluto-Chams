local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local Config = {
    AimKey = Enum.KeyCode.LeftControl,
    FOVSize = 250, -- Increased from 100 to 250
    AimSmoothing = 0.25,
    AimOffset = Vector3.new(0, 2, 0),
    MaxAimDistance = 800,
    TeamCheck = true,
    ClickInterval = 0.12,
    Mouse5AutoShoot = true,
}

local State = {
    TargetPlayer = nil,
    IsAiming = false,
    Mouse5Down = false,
    AutoClickConnection = nil,
    LastClickTime = 0,
    CtrlPressed = false,
    IsEnabled = true,
    IsAutoShooting = false,
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotFOV"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.Size = UDim2.new(0, Config.FOVSize * 2, 0, Config.FOVSize * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.ZIndex = 999
fovCircle.Visible = true
fovCircle.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = fovCircle

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.3
UIStroke.Parent = fovCircle

RunService.RenderStepped:Connect(function()
    if State.CtrlPressed and State.TargetPlayer then
        UIStroke.Color = Color3.fromRGB(0, 255, 0)
    elseif State.CtrlPressed then
        UIStroke.Color = Color3.fromRGB(255, 165, 0)
    else
        UIStroke.Color = Color3.fromRGB(255, 255, 255)
    end
end)

local function isLobbyVisible()
    local mainGui = localPlayer:FindFirstChild("PlayerGui")
    if not mainGui then return false end
    
    local success, result = pcall(function()
        local lobby = mainGui:FindFirstChild("MainGui")
        if not lobby then return false end
        
        local lobbyFrame = lobby:FindFirstChild("MainFrame")
        if not lobbyFrame then return false end
        
        local currency = lobbyFrame:FindFirstChild("Lobby")
        if not currency then return false end
        
        return currency:FindFirstChild("Currency") and currency.Currency.Visible
    end)
    
    return success and result or false
end

local function isAlive(player)
    local character = player.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function isTeamMate(player)
    if not Config.TeamCheck then return false end
    
    local localTeam = localPlayer.Team
    local targetTeam = player.Team
    
    return localTeam and targetTeam and localTeam == targetTeam
end

local function getClosestPlayerToCrosshair()
    local closestPlayer = nil
    local closestDistance = math.huge
    local screenCenter = camera.ViewportSize / 2
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == localPlayer then continue end
        if not isAlive(player) then continue end
        if isTeamMate(player) then continue end
        
        local character = player.Character
        local head = character and character:FindFirstChild("Head")
        if not head then continue end
        
        local headScreenPos, onScreen = camera:WorldToViewportPoint(head.Position + Config.AimOffset)
        if not onScreen then continue end
        
        local distanceFromCamera = (head.Position - camera.CFrame.Position).Magnitude
        if distanceFromCamera > Config.MaxAimDistance then continue end
        
        local screenPos = Vector2.new(headScreenPos.X, headScreenPos.Y)
        local distance = (screenPos - screenCenter).Magnitude
        
        -- Check if player is within FOV circle
        if distance <= Config.FOVSize then
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer
end

local function smoothAimToTarget()
    if not State.TargetPlayer then return end
    
    local character = State.TargetPlayer.Character
    if not character then return end
    
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    local cameraCFrame = camera.CFrame
    local cameraPosition = cameraCFrame.Position
    local targetPosition = head.Position + Config.AimOffset
    local direction = (targetPosition - cameraPosition).Unit
    
    local currentLook = cameraCFrame.LookVector
    local smoothedLook = currentLook:Lerp(direction, 1 - Config.AimSmoothing)
    
    camera.CFrame = CFrame.new(cameraPosition, cameraPosition + smoothedLook)
end

local function startAutoShooting()
    if State.AutoClickConnection then
        State.AutoClickConnection:Disconnect()
    end
    
    State.IsAutoShooting = true
    State.AutoClickConnection = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        
        if (currentTime - State.LastClickTime) < Config.ClickInterval then
            return
        end
        
        if State.TargetPlayer and not isLobbyVisible() then
            mouse1click()
            State.LastClickTime = currentTime
        end
    end)
end

local function stopAutoShooting()
    if State.AutoClickConnection then
        State.AutoClickConnection:Disconnect()
        State.AutoClickConnection = nil
    end
    State.IsAutoShooting = false
end

UserInputService.InputBegan:Connect(function(input, isProcessed)
    if isProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        State.IsEnabled = not State.IsEnabled
        print("Script", State.IsEnabled and "Enabled" or "Disabled")
        return
    end
    
    if input.KeyCode == Config.AimKey then
        State.CtrlPressed = true
        State.IsAiming = true
        
        State.TargetPlayer = getClosestPlayerToCrosshair()
        
        if State.TargetPlayer then
            startAutoShooting()
        end
        
        print("Aiming at:", State.TargetPlayer and State.TargetPlayer.Name or "No target")
    end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if Config.Mouse5AutoShoot and State.CtrlPressed and State.TargetPlayer then
            mouse1click()
        end
    end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Config.Mouse5AutoShoot and State.CtrlPressed and State.TargetPlayer then
            mouse2click()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, isProcessed)
    if isProcessed then return end
    
    if input.KeyCode == Config.AimKey then
        State.CtrlPressed = false
        State.IsAiming = false
        State.TargetPlayer = nil
        stopAutoShooting()
    end
end)

RunService.Heartbeat:Connect(function()
    if not State.IsEnabled or isLobbyVisible() then
        if State.IsAutoShooting then
            stopAutoShooting()
        end
        return
    end
    
    if State.CtrlPressed then
        State.TargetPlayer = getClosestPlayerToCrosshair()
        
        if State.TargetPlayer then
            smoothAimToTarget()
            
            if not State.IsAutoShooting then
                startAutoShooting()
            end
        else
            if State.IsAutoShooting then
                stopAutoShooting()
            end
        end
    end
end)

localPlayer.CharacterAdded:Connect(function()
    stopAutoShooting()
    State.IsAiming = false
    State.CtrlPressed = false
    State.TargetPlayer = nil
    State.IsAutoShooting = false
end)

Players.PlayerRemoving:Connect(function(player)
    if player == State.TargetPlayer then
        State.TargetPlayer = nil
    end
end)
