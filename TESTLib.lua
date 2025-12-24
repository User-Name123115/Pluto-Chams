local library = {}
local windowCount = 0
local sizes = {}
local listOffset = {}
local windows = {}
local pastSliders = {}
local dropdowns = {}
local dropdownSizes = {}
local destroyed

local colorPickers = {}

-- Create Toggle UI
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "TurtleUiToggle"
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.BorderSizePixel = 2
ToggleButton.Position = UDim2.new(1, -50, 0.5, -25)
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "T"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 20
ToggleButton.AutoButtonColor = false

local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0
BlurEffect.Parent = game:GetService("Lighting")

if game.CoreGui:FindFirstChild('TurtleUiLib') then
    game.CoreGui:FindFirstChild('TurtleUiLib'):Destroy()
    destroyed = true
end

-- Fade animation function
local TweenService = game:GetService("TweenService")
function FadeIn(obj, duration)
    local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, tweenInfo, {BackgroundTransparency = 0})
    tween:Play()
    return tween
end

function FadeOut(obj, duration)
    local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, tweenInfo, {BackgroundTransparency = 1})
    tween:Play()
    return tween
end

function FadeInText(obj, duration)
    local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, tweenInfo, {TextTransparency = 0})
    tween:Play()
    return tween
end

function FadeOutText(obj, duration)
    local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, tweenInfo, {TextTransparency = 1})
    tween:Play()
    return tween
end

function Lerp(a, b, c)
    return a + ((b - a) * c)
end

local players = game:GetService('Players');
local player = players.LocalPlayer;
local mouse = player:GetMouse();
local run = game:GetService('RunService');
local stepped = run.Stepped;

function Dragify(obj)
    spawn(function()
        local minitial;
        local initial;
        local isdragging;
        obj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isdragging = true;
                minitial = input.Position;
                initial = obj.Position;
                local con;
                con = stepped:Connect(function()
                    if isdragging then
                        local delta = Vector3.new(mouse.X, mouse.Y, 0) - minitial;
                        obj.Position = UDim2.new(initial.X.Scale, initial.X.Offset + delta.X, initial.Y.Scale, initial.Y.Offset + delta.Y);
                    else
                        con:Disconnect();
                    end;
                end);
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        isdragging = false;
                    end;
                end);
            end;
        end);
    end)
end

-- Instances:
local function protect_gui(obj) 
    if destroyed then
        obj.Parent = game.CoreGui
        return
    end
    if syn and syn.protect_gui then
        syn.protect_gui(obj)
        obj.Parent = game.CoreGui
    elseif PROTOSMASHER_LOADED then
        obj.Parent = get_hidden_gui()
    else
        obj.Parent = game.CoreGui
    end
end

local TurtleUiLib = Instance.new("ScreenGui")
TurtleUiLib.Name = "TurtleUiLib"
TurtleUiLib.DisplayOrder = 999

-- Create background frame for blur effect
local Background = Instance.new("Frame")
Background.Name = "Background"
Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Background.BackgroundTransparency = 1
Background.Size = UDim2.new(1, 0, 1, 0)
Background.ZIndex = -1
Background.Parent = TurtleUiLib

protect_gui(TurtleUiLib)

local xOffset = 20
local uis = game:GetService("UserInputService")
local keybindConnection

-- Functions for toggle button
local function ToggleUI()
    local isVisible = TurtleUiLib.Enabled
    if isVisible then
        -- Fade out UI
        for _, window in pairs(TurtleUiLib:GetDescendants()) do
            if window:IsA("Frame") then
                FadeOut(window, 0.2)
            elseif window:IsA("TextLabel") or window:IsA("TextButton") or window:IsA("TextBox") then
                FadeOutText(window, 0.2)
            end
        end
        
        -- Fade out background
        local bgTween = FadeOut(Background, 0.5)
        
        -- Decrease blur
        local blurTween = TweenService:Create(BlurEffect, TweenInfo.new(0.5), {Size = 0})
        blurTween:Play()
        
        wait(0.2)
        TurtleUiLib.Enabled = false
    else
        TurtleUiLib.Enabled = true
        
        -- Increase blur
        local blurTween = TweenService:Create(BlurEffect, TweenInfo.new(0.5), {Size = 15})
        blurTween:Play()
        
        -- Fade in background
        local bgTween = FadeIn(Background, 0.5)
        bgTween.Completed:Wait()
        
        -- Fade in UI elements
        for _, window in pairs(TurtleUiLib:GetDescendants()) do
            if window:IsA("Frame") then
                window.BackgroundTransparency = 1
                FadeIn(window, 0.3)
            elseif window:IsA("TextLabel") or window:IsA("TextButton") or window:IsA("TextBox") then
                window.TextTransparency = 1
                FadeInText(window, 0.3)
            end
        end
    end
end

ToggleButton.MouseButton1Click:Connect(ToggleUI)

function library:Destroy()
    TurtleUiLib:Destroy()
    if keybindConnection then
        keybindConnection:Disconnect()
    end
    ToggleButton:Destroy()
    BlurEffect:Destroy()
end

function library:Hide()
    ToggleUI()
end

function library:Keybind(key)
    if keybindConnection then keybindConnection:Disconnect() end

    keybindConnection = uis.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode[key] then
            ToggleUI()
        end
    end)
end

-- Insert toggle button
ToggleButton.Parent = game.CoreGui

function library:Window(name) 
    windowCount = windowCount + 1
    local winCount = windowCount
    local zindex = winCount * 7
    
    local UiWindow = Instance.new("Frame")
    UiWindow.Name = "UiWindow"
    UiWindow.Parent = TurtleUiLib
    UiWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    UiWindow.BorderColor3 = Color3.fromRGB(255, 255, 255)
    UiWindow.BorderSizePixel = 2
    UiWindow.Position = UDim2.new(0, xOffset, 0, 20)
    UiWindow.Size = UDim2.new(0, 220, 0, 35)
    UiWindow.ZIndex = 4 + zindex
    UiWindow.Active = true
    Dragify(UiWindow)

    xOffset = xOffset + 245

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = UiWindow
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Header.BorderColor3 = Color3.fromRGB(255, 255, 255)
    Header.BorderSizePixel = 1
    Header.Position = UDim2.new(0, 0, -0.0202544238, 0)
    Header.Size = UDim2.new(0, 220, 0, 28)
    Header.ZIndex = 5 + zindex

    local HeaderText = Instance.new("TextLabel")
    HeaderText.Name = "HeaderText"
    HeaderText.Parent = Header
    HeaderText.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    HeaderText.BackgroundTransparency = 1.000
    HeaderText.Position = UDim2.new(0, 10, 0, 0)
    HeaderText.Size = UDim2.new(0, 180, 0, 28)
    HeaderText.ZIndex = 6 + zindex
    HeaderText.Font = Enum.Font.GothamBold
    HeaderText.Text = name or "Window"
    HeaderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeaderText.TextSize = 14.000
    HeaderText.TextXAlignment = Enum.TextXAlignment.Left

    local Minimise = Instance.new("TextButton")
    local Window = Instance.new("Frame")
    Minimise.Name = "Minimise"
    Minimise.Parent = Header
    Minimise.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Minimise.BorderColor3 = Color3.fromRGB(255, 255, 255)
    Minimise.BorderSizePixel = 1
    Minimise.Position = UDim2.new(0, 195, 0, 3)
    Minimise.Size = UDim2.new(0, 20, 0, 20)
    Minimise.ZIndex = 7 + zindex
    Minimise.Font = Enum.Font.Gotham
    Minimise.Text = "-"
    Minimise.TextColor3 = Color3.fromRGB(255, 255, 255)
    Minimise.TextSize = 16.000
    Minimise.AutoButtonColor = false
    Minimise.MouseButton1Up:connect(function()
        Window.Visible = not Window.Visible
        if Window.Visible then
            Minimise.Text = "-"
        else
            Minimise.Text = "+"
        end
    end)

    Window.Name = "Window"
    Window.Parent = Header
    Window.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Window.BorderColor3 = Color3.fromRGB(255, 255, 255)
    Window.BorderSizePixel = 1
    Window.Position = UDim2.new(0, 0, 0, 28)
    Window.Size = UDim2.new(0, 220, 0, 35)
    Window.ZIndex = 1 + zindex

    local functions = {}
    sizes[winCount] = 35
    listOffset[winCount] = 10
    
    function functions:Button(name, callback)
        local name = name or "Button"
        local callback = callback or function() end

        sizes[winCount] = sizes[winCount] + 34
        Window.Size = UDim2.new(0, 220, 0, sizes[winCount] + 10)

        local Button = Instance.new("TextButton")
        listOffset[winCount] = listOffset[winCount] + 34
        Button.Name = "Button"
        Button.Parent = Window
        Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Button.BorderColor3 = Color3.fromRGB(255, 255, 255)
        Button.BorderSizePixel = 1
        Button.Position = UDim2.new(0, 10, 0, listOffset[winCount])
        Button.Size = UDim2.new(0, 200, 0, 28)
        Button.ZIndex = 2 + zindex
        Button.Selected = true
        Button.Font = Enum.Font.Gotham
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 14.000
        Button.TextStrokeTransparency = 123.000
        Button.TextWrapped = true
        Button.Text = name
        Button.AutoButtonColor = false
        
        local originalColor = Button.BackgroundColor3
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = originalColor}):Play()
        end)
        
        Button.MouseButton1Down:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
            wait(0.1)
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            callback()
        end)

        pastSliders[winCount] = false
        
        -- Initialize with fade
        Button.TextTransparency = 1
        spawn(function()
            wait(0.1 * winCount + 0.05)
            FadeInText(Button, 0.3)
        end)
    end
    
    function functions:Label(text, color)
        local color = color or Color3.fromRGB(220, 220, 220)

        sizes[winCount] = sizes[winCount] + 32
        Window.Size = UDim2.new(0, 220, 0, sizes[winCount] + 10)

        listOffset[winCount] = listOffset[winCount] + 32
        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Parent = Window
        Label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Label.BackgroundTransparency = 1.000
        Label.BorderColor3 = Color3.fromRGB(27, 42, 53)
        Label.Position = UDim2.new(0, 10, 0, listOffset[winCount])
        Label.Size = UDim2.new(0, 200, 0, 28)
        Label.Font = Enum.Font.Gotham
        Label.Text = text or "Label"
        Label.TextSize = 14.000
        Label.TextColor3 = color
        Label.ZIndex = 2 + zindex

        if type(color) == "boolean" and color then
            spawn(function()
                while wait() do
                    local hue = tick() % 5 / 5
                    Label.TextColor3 = Color3.fromHSV(hue, 1, 1)
                end
            end)
        else
            Label.TextColor3 = color
        end
        pastSliders[winCount] = false
        
        -- Initialize with fade
        Label.TextTransparency = 1
        spawn(function()
            wait(0.1 * winCount + 0.05)
            FadeInText(Label, 0.3)
        end)
        
        return Label
    end
    
    function functions:Toggle(text, default, callback)
        local default = default or false
        local callback = callback or function() end

        sizes[winCount] = sizes[winCount] + 34
        Window.Size = UDim2.new(0, 220, 0, sizes[winCount] + 10)

        listOffset[winCount] = listOffset[winCount] + 34

        local ToggleDescription = Instance.new("TextLabel")
        local ToggleButton = Instance.new("TextButton")

        ToggleDescription.Name = "ToggleDescription"
        ToggleDescription.Parent = Window
        ToggleDescription.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        ToggleDescription.BackgroundTransparency = 1.000
        ToggleDescription.Position = UDim2.new(0, 10, 0, listOffset[winCount])
        ToggleDescription.Size = UDim2.new(0, 140, 0, 28)
        ToggleDescription.Font = Enum.Font.Gotham
        ToggleDescription.Text = text or "Toggle"
        ToggleDescription.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleDescription.TextSize = 14.000
        ToggleDescription.TextWrapped = true
        ToggleDescription.TextXAlignment = Enum.TextXAlignment.Left
        ToggleDescription.ZIndex = 2 + zindex

        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = ToggleDescription
        ToggleButton.BackgroundColor3 = default and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(30, 30, 30)
        ToggleButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.BorderSizePixel = 1
        ToggleButton.Position = UDim2.new(0, 145, 0, 3)
        ToggleButton.Size = UDim2.new(0, 50, 0, 22)
        ToggleButton.Font = Enum.Font.Gotham
        ToggleButton.Text = default and "ON" or "OFF"
        ToggleButton.TextColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        ToggleButton.TextSize = 12.000
        ToggleButton.ZIndex = 2 + zindex
        ToggleButton.AutoButtonColor = false
        
        ToggleButton.MouseButton1Up:Connect(function()
            default = not default
            ToggleButton.Text = default and "ON" or "OFF"
            ToggleButton.TextColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
            TweenService:Create(ToggleButton, TweenInfo.new(0.1), {BackgroundColor3 = default and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(35, 35, 35)}):Play()
            wait(0.1)
            TweenService:Create(ToggleButton, TweenInfo.new(0.1), {BackgroundColor3 = default and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(30, 30, 30)}):Play()
            callback(default)
        end)
        
        ToggleButton.MouseEnter:Connect(function()
            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        end)
        
        ToggleButton.MouseLeave:Connect(function()
            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
        end)

        pastSliders[winCount] = false
        
        -- Initialize with fade
        ToggleDescription.TextTransparency = 1
        ToggleButton.TextTransparency = 1
        spawn(function()
            wait(0.1 * winCount + 0.05)
            FadeInText(ToggleDescription, 0.3)
            FadeInText(ToggleButton, 0.3)
        end)
    end
    
    function functions:Box(text, callback)
        local callback = callback or function() end

        sizes[winCount] = sizes[winCount] + 34
        Window.Size = UDim2.new(0, 220, 0, sizes[winCount] + 10)

        listOffset[winCount] = listOffset[winCount] + 34
        local TextBox = Instance.new("TextBox")
        local BoxDescription = Instance.new("TextLabel")
        TextBox.Parent = Window
        TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TextBox.BorderColor3 = Color3.fromRGB(255, 255, 255)
        TextBox.BorderSizePixel = 1
        TextBox.Position = UDim2.new(0, 110, 0, listOffset[winCount])
        TextBox.Size = UDim2.new(0, 100, 0, 28)
        TextBox.Font = Enum.Font.Gotham
        TextBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
        TextBox.PlaceholderText = "..."
        TextBox.Text = ""
        TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextBox.TextSize = 14.000
        TextBox.TextStrokeColor3 = Color3.fromRGB(245, 246, 250)
        TextBox.ZIndex = 2 + zindex
        TextBox.FocusLost:Connect(function()
            callback(TextBox.Text, true)
        end)

        BoxDescription.Name = "BoxDescription"
        BoxDescription.Parent = TextBox
        BoxDescription.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        BoxDescription.BackgroundTransparency = 1.000
        BoxDescription.Position = UDim2.new(-1.1, 0, 0, 0)
        BoxDescription.Size = UDim2.new(0, 100, 0, 28)
        BoxDescription.Font = Enum.Font.Gotham
        BoxDescription.Text = text or "Box"
        BoxDescription.TextColor3 = Color3.fromRGB(255, 255, 255)
        BoxDescription.TextSize = 14.000
        BoxDescription.TextXAlignment = Enum.TextXAlignment.Left
        BoxDescription.ZIndex = 2 + zindex
        pastSliders[winCount] = false
        
        -- Initialize with fade
        TextBox.TextTransparency = 1
        BoxDescription.TextTransparency = 1
        spawn(function()
            wait(0.1 * winCount + 0.05)
            FadeInText(TextBox, 0.3)
            FadeInText(BoxDescription, 0.3)
        end)
    end
    
    function functions:Slider(text, min, max, default, callback)
        local text = text or "Slider"
        local min = min or 1
        local max = max or 100
        local default = default or math.floor((min + max) / 2)
        local callback = callback or function() end
        local offset = 70
        if default > max then
            default = max
        elseif default < min then
            default = min
        end

        if pastSliders[winCount] then
            offset = 60
        end

        sizes[winCount] = sizes[winCount] + offset
        Window.Size = UDim2.new(0, 220, 0, sizes[winCount] + 10)

        listOffset[winCount] = listOffset[winCount] + offset

        local Slider = Instance.new("Frame")
        local SliderButton = Instance.new("Frame")
        local Description = Instance.new("TextLabel")
        local SilderFiller = Instance.new("Frame")
        local Current = Instance.new("TextLabel")
        local Min = Instance.new("TextLabel")
        local Max = Instance.new("TextLabel")

        function SliderMovement(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isdragging = true;
                minitial = input.Position.X;
                initial = SliderButton.Position.X.Offset;
                local delta1 = SliderButton.AbsolutePosition.X - initial
                local con;
                con = stepped:Connect(function()
                    if isdragging then
                        local xOffset = mouse.X - delta1 - 3
                        if xOffset > 190 then
                            xOffset = 190
                        elseif xOffset < 0 then
                            xOffset = 0
                        end
                        SliderButton.Position = UDim2.new(0, xOffset , -1.33333337, 0);
                        SilderFiller.Size = UDim2.new(0, xOffset, 0, 6)
                        local value = Lerp(min, max, SliderButton.Position.X.Offset/(Slider.Size.X.Offset-5))
                        local roundedValue = math.round(value)
                        Current.Text = tostring(roundedValue)
                        callback(roundedValue)
                    else
                        con:Disconnect();
                    end;
                end);
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        isdragging = false;
                    end;
                end);
            end;
        end

        Slider.Name = "Slider"
        Slider.Parent = Window
        Slider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Slider.BorderColor3 = Color3.fromRGB(255, 255, 255)
        Slider.BorderSizePixel = 1
        Slider.Position = UDim2.new(0, 15, 0, listOffset[winCount])
        Slider.Size = UDim2.new(0, 190, 0, 6)
        Slider.ZIndex = 2 + zindex
        Slider.InputBegan:Connect(SliderMovement) 

        SliderButton.Position = UDim2.new(0, (Slider.Size.X.Offset - 5) * ((default - min)/(max-min)), -1.333337, 0)
        SliderButton.Name = "SliderButton"
        SliderButton.Parent = Slider
        SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
        SliderButton.BorderSizePixel = 1
        SliderButton.Size = UDim2.new(0, 8, 0, 22)
        SliderButton.ZIndex = 3 + zindex
        SliderButton.InputBegan:Connect(SliderMovement)   

        Current.Name = "Current"
        Current.Parent = SliderButton
        Current.BackgroundTransparency = 1.000
        Current.Position = UDim2.new(0, 3, 0, 22)
        Current.Size = UDim2.new(0, 0, 0, 18)
        Current.Font = Enum.Font.Gotham
        Current.Text = tostring(default)
        Current.TextColor3 = Color3.fromRGB(255, 255, 255)
        Current.TextSize = 12.000  
        Current.ZIndex = 2 + zindex

        Description.Name = "Description"
        Description.Parent = Slider
        Description.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Description.BackgroundTransparency = 1.000
        Description.Position = UDim2.new(0, -10, 0, -35)
        Description.Size = UDim2.new(0, 200, 0, 21)
        Description.Font = Enum.Font.Gotham
        Description.Text = text
        Description.TextColor3 = Color3.fromRGB(255, 255, 255)
        Description.TextSize = 14.000
        Description.ZIndex = 2 + zindex

        SilderFiller.Name = "SilderFiller"
        SilderFiller.Parent = Slider
        SilderFiller.BackgroundColor3 = Color3.fromRGB(0, 168, 255)
        SilderFiller.BorderColor3 = Color3.fromRGB(30, 30, 30)
        SilderFiller.BorderSizePixel = 0
        SilderFiller.Size = UDim2.new(0, (Slider.Size.X.Offset - 5) * ((default - min)/(max-min)), 0, 6)
        SilderFiller.ZIndex = 2 + zindex
        SilderFiller.BorderMode = Enum.BorderMode.Inset

        Min.Name = "Min"
        Min.Parent = Slider
        Min.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Min.BackgroundTransparency = 1.000
        Min.Position = UDim2.new(-0.00555555569, 0, -7.33333397, 0)
        Min.Size = UDim2.new(0, 80, 0, 50)
        Min.Font = Enum.Font.Gotham
        Min.Text = tostring(min)
        Min.TextColor3 = Color3.fromRGB(200, 200, 200)
        Min.TextSize = 12.000
        Min.TextXAlignment = Enum.TextXAlignment.Left
        Min.ZIndex = 2 + zindex

        Max.Name = "Max"
        Max.Parent = Slider
        Max.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Max.BackgroundTransparency = 1.000
        Max.Position = UDim2.new(0.577777743, 0, -7.33333397, 0)
        Max.Size = UDim2.new(0, 80, 0, 50)
        Max.Font = Enum.Font.Gotham
        Max.Text = tostring(max)
        Max.TextColor3 = Color3.fromRGB(200, 200, 200)
        Max.TextSize = 12.000
        Max.TextXAlignment = Enum.TextXAlignment.Right
        Max.ZIndex = 2 + zindex
        pastSliders[winCount] = true
        
        -- Initialize with fade
        Description.TextTransparency = 1
        Current.TextTransparency = 1
        Min.TextTransparency = 1
        Max.TextTransparency = 1
        spawn(function()
            wait(0.1 * winCount + 0.05)
            FadeInText(Description, 0.3)
            FadeInText(Current, 0.3)
            FadeInText(Min, 0.3)
            FadeInText(Max, 0.3)
        end)

        local slider = {}
        function slider:SetValue(value)
            value = math.clamp(value, min, max)
            local xOffset = (value-min)/max * (Slider.Size.X.Offset)
            SliderButton.Position = UDim2.new(0, xOffset , -1.33333337, 0);
            SilderFiller.Size = UDim2.new(0, xOffset, 0, 6)
            Current.Text = tostring(math.round(value))
            callback(value)
        end
        return slider
    end
    
    function functions:Dropdown(text, buttons, callback)
        local text = text or "Dropdown"
        local buttons = buttons or {}
        local callback = callback or function() end

        local Dropdown = Instance.new("TextButton")
        local DownSign = Instance.new("TextLabel")
        local DropdownFrame = Instance.new("ScrollingFrame")

        sizes[winCount] = sizes[winCount] + 34
        Window.Size = UDim2.new(0, 220, 0, sizes[winCount] + 10)

        listOffset[winCount] = listOffset[winCount] + 34

        Dropdown.Name = "Dropdown"
        Dropdown.Parent = Window
        Dropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Dropdown.BorderColor3 = Color3.fromRGB(255, 255, 255)
        Dropdown.BorderSizePixel = 1
        Dropdown.Position = UDim2.new(0, 10, 0, listOffset[winCount])
        Dropdown.Size = UDim2.new(0, 200, 0, 28)
        Dropdown.Selected = true
        Dropdown.Font = Enum.Font.Gotham
        Dropdown.Text = tostring(text)
        Dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
        Dropdown.TextSize = 14.000
        Dropdown.TextStrokeTransparency = 123.000
        Dropdown.TextWrapped = true
        Dropdown.ZIndex = 3 + zindex
        Dropdown.AutoButtonColor = false
        
        Dropdown.MouseEnter:Connect(function()
            TweenService:Create(Dropdown, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        end)
        
        Dropdown.MouseLeave:Connect(function()
            TweenService:Create(Dropdown, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
        end)
        
        Dropdown.MouseButton1Up:Connect(function()
            for i, v in pairs(dropdowns) do
                if v ~= DropdownFrame then
                    v.Visible = false
                    DownSign.Rotation = 0
                end
            end
            if DropdownFrame.Visible then
                DownSign.Rotation = 0
                TweenService:Create(Dropdown, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
            else
                DownSign.Rotation = 180
                TweenService:Create(Dropdown, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            end
            DropdownFrame.Visible = not DropdownFrame.Visible
        end)

        DownSign.Name = "DownSign"
        DownSign.Parent = Dropdown
        DownSign.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        DownSign.BackgroundTransparency = 1.000
        DownSign.Position = UDim2.new(0, 175, 0, 4)
        DownSign.Size = UDim2.new(0, 20, 0, 20)
        DownSign.Font = Enum.Font.GothamBold
        DownSign.Text = "▼"
        DownSign.TextColor3 = Color3.fromRGB(255, 255, 255)
        DownSign.TextSize = 14.000
        DownSign.ZIndex = 4 + zindex

        DropdownFrame.Name = "DropdownFrame"
        DropdownFrame.Parent = Dropdown
        DropdownFrame.Active = true
        DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        DropdownFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
        DropdownFrame.BorderSizePixel = 1
        DropdownFrame.Position = UDim2.new(0, 0, 0, 30)
        DropdownFrame.Size = UDim2.new(0, 200, 0, 0)
        DropdownFrame.Visible = false
        DropdownFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        DropdownFrame.ScrollBarThickness = 4
        DropdownFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left
        DropdownFrame.ZIndex = 5 + zindex
        DropdownFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        DropdownFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
        table.insert(dropdowns, DropdownFrame)
        
        local dropFunctions = {}
        local canvasSize = 0
        function dropFunctions:Button(name)
            local name = name or ""
            local Button_2 = Instance.new("TextButton")
            Button_2.Name = "Button"
            Button_2.Parent = DropdownFrame
            Button_2.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Button_2.BorderColor3 = Color3.fromRGB(255, 255, 255)
            Button_2.BorderSizePixel = 0
            Button_2.Position = UDim2.new(0, 2, 0, canvasSize + 1)
            Button_2.Size = UDim2.new(0, 196, 0, 26)
            Button_2.Selected = true
            Button_2.Font = Enum.Font.Gotham
            Button_2.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button_2.TextSize = 13.000
            Button_2.TextStrokeTransparency = 123.000
            Button_2.ZIndex = 6 + zindex
            Button_2.Text = name
            Button_2.TextWrapped = true
            Button_2.AutoButtonColor = false
            
            Button_2.MouseEnter:Connect(function()
                TweenService:Create(Button_2, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            end)
            
            Button_2.MouseLeave:Connect(function()
                TweenService:Create(Button_2, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
            end)
            
            canvasSize = canvasSize + 27
            DropdownFrame.CanvasSize = UDim2.new(0, 200, 0, canvasSize + 1)
            if #DropdownFrame:GetChildren() < 8 then
                DropdownFrame.Size = UDim2.new(0, 200, 0, DropdownFrame.Size.Y.Offset + 27)
            end
            
            Button_2.MouseButton1Up:Connect(function()
                TweenService:Create(Button_2, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
                wait(0.1)
                TweenService:Create(Button_2, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                callback(name)
                DropdownFrame.Visible = false
                DownSign.Rotation = 0
                TweenService:Create(Dropdown, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
            end)
        end
        
        function dropFunctions:Remove(name)
            local foundIt
            for i, v in pairs(DropdownFrame:GetChildren()) do
                if foundIt then
                    canvasSize = canvasSize - 27
                    v.Position = UDim2.new(0, 2, 0, v.Position.Y.Offset - 27)
                    DropdownFrame.CanvasSize = UDim2.new(0, 200, 0, canvasSize + 1)
                end
                if v.Text == name then
                    foundIt = true
                    v:Destroy()
                    if #DropdownFrame:GetChildren() < 8 then
                        DropdownFrame.Size = UDim2.new(0, 200, 0, DropdownFrame.Size.Y.Offset - 27)
                    end
                end
            end
            if not foundIt then
                warn("The button you tried to remove didn't exist!")
            end
        end

        for i,v in pairs(buttons) do
            dropFunctions:Button(v)
        end
        
        -- Initialize with fade
        Dropdown.TextTransparency = 1
        DownSign.TextTransparency = 1
        spawn(function()
            wait(0.1 * winCount + 0.05)
            FadeInText(Dropdown, 0.3)
            FadeInText(DownSign, 0.3)
        end)

        return dropFunctions
    end

    -- Initialize window with fade effect
    UiWindow.BackgroundTransparency = 1
    Header.BackgroundTransparency = 1
    Window.BackgroundTransparency = 1
    HeaderText.TextTransparency = 1
    Minimise.TextTransparency = 1
    
    spawn(function()
        wait(0.1 * winCount)
        FadeIn(UiWindow, 0.3)
        FadeIn(Header, 0.3)
        FadeIn(Window, 0.3)
        FadeInText(HeaderText, 0.3)
        FadeInText(Minimise, 0.3)
    end)

    return functions
end

return library
