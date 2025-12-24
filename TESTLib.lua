local PlutoChamsUI = {}
PlutoChamsUI.__index = PlutoChamsUI

local Core = nil

function PlutoChamsUI.new(coreInstance)
    assert(coreInstance, "PlutoChamsUI requires a PlutoChamsCore instance")
    
    local self = setmetatable({}, PlutoChamsUI)
    self.Core = coreInstance
    self.gui = nil
    self.mainFrame = nil
    
    return self
end

function PlutoChamsUI:create()
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "PlutoChamsUI"
    
    if gethui then
        self.gui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(self.gui)
        self.gui.Parent = game.CoreGui
    else
        self.gui.Parent = game.CoreGui
    end
    
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Size = UDim2.new(0, 400, 0, 500)
    self.mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.mainFrame.BorderSizePixel = 1
    self.mainFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
    self.mainFrame.Active = true
    self.mainFrame.Draggable = true
    self.mainFrame.Parent = self.gui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    title.Text = "Pluto Chams v1.0"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = self.mainFrame
    
    self:createToggle("ESP", 50, function(value)
        self.Core:setESPEnabled(value)
    end)
    
    self:createToggle("Chams", 90, function(value)
        self.Core:setChamsEnabled(value)
    end)
    
    self:createToggle("Aimbot", 130, function(value)
        self.Core:setAimbotEnabled(value)
    end)
    
    self:createToggle("FOV Circle", 170, function(value)
        self.Core:setFOVEnabled(value)
    end)
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(1, -20, 0, 30)
    closeButton.Position = UDim2.new(0, 10, 1, -40)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "Close"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.Gotham
    closeButton.TextSize = 14
    closeButton.Parent = self.mainFrame
    
    closeButton.MouseButton1Click:Connect(function()
        self:hide()
    end)
    
    return self
end

function PlutoChamsUI:createToggle(text, yPos, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -20, 0, 30)
    toggleFrame.Position = UDim2.new(0, 10, 0, yPos)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = self.mainFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 24)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -12)
    toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleButton.Text = "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.Gotham
    toggleButton.TextSize = 12
    toggleButton.Parent = toggleFrame
    
    toggleButton.MouseButton1Click:Connect(function()
        local newState = toggleButton.Text == "OFF"
        toggleButton.Text = newState and "ON" or "OFF"
        toggleButton.BackgroundColor3 = newState and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 60)
        
        if callback then
            callback(newState)
        end
    end)
end

function PlutoChamsUI:show()
    if self.mainFrame then
        self.mainFrame.Visible = true
    end
end

function PlutoChamsUI:hide()
    if self.mainFrame then
        self.mainFrame.Visible = false
    end
end

function PlutoChamsUI:destroy()
    if self.gui then
        self.gui:Destroy()
        self.gui = nil
        self.mainFrame = nil
    end
end

return PlutoChamsUI
