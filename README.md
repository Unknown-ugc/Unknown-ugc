-- MainScript.lua
local createAutoActionsGUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Berbberb62/GUIS/refs/heads/main/MainGuibyBerun.lua"))()
local player = game.Players.LocalPlayer
local titleText = "BloxFruit"

-- Create GUI and get returned components
local screenGui, mainFrame, scrollingFrame, minimizeButton, terminateButton = createAutoActionsGUI(player, titleText)

-- Prevent GUI from disappearing when respawning
screenGui.ResetOnSpawn = false
scrollingFrame.ScrollingEnabled = false
-- Create a fixed TextLabel at the top of mainFrame
local fixedTextLabel = Instance.new("TextLabel")
fixedTextLabel.Size = UDim2.new(1, -20, 0, 30) -- Full width of the mainFrame with some padding
fixedTextLabel.Position = UDim2.new(-0.3, 0, 1, -20) -- Positioned at the top
fixedTextLabel.BackgroundTransparency = 1 -- Transparent background
fixedTextLabel.Text = "Made By Berun" -- Replace with your desired text
fixedTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text color
fixedTextLabel.Font = Enum.Font.Cartoon
fixedTextLabel.TextSize = 10 -- Adjust text size as needed
fixedTextLabel.Parent = mainFrame

-- Change MainFrame size for flexibility
mainFrame.Size = UDim2.new(0, 300, 0, 250)

-- Define button functionality
minimizeButton.MouseButton1Click:Connect(function()
    if mainFrame.Size == UDim2.new(0, 300, 0, 30) then
        mainFrame.Size = UDim2.new(0, 300, 0, 250)
        scrollingFrame.Visible = true
    else
        mainFrame.Size = UDim2.new(0, 300, 0, 30)
        scrollingFrame.Visible = false
    end
end)

terminateButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Function to create toggles
local toggleYOffset = 10 -- Start below the fixed TextLabel
local function createToggle(parent, actionName, actionFunc)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 30)
    ToggleFrame.Position = UDim2.new(0, 10, 0, toggleYOffset)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parent

    local ToggleText = Instance.new("TextLabel")
    ToggleText.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = actionName
    ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleText.Font = Enum.Font.Cartoon
    ToggleText.TextSize = 16
    ToggleText.Parent = ToggleFrame

    local ToggleCheckbox = Instance.new("TextButton")
    ToggleCheckbox.Size = UDim2.new(0.3, 0, 1, 0)
    ToggleCheckbox.Position = UDim2.new(0.7, 0, 0, 0)
    ToggleCheckbox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ToggleCheckbox.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCheckbox.Text = "â—¯"
    ToggleCheckbox.Font = Enum.Font.Cartoon
    ToggleCheckbox.TextSize = 20
    ToggleCheckbox.BorderSizePixel = 0
    ToggleCheckbox.Parent = ToggleFrame

    local isChecked = false
    ToggleCheckbox.MouseButton1Click:Connect(function()
        isChecked = not isChecked
        ToggleCheckbox.Text = isChecked and "â¦¿" or "â—¯"
        if isChecked then
            ToggleCheckbox.TextColor3 = Color3.fromRGB(221, 51, 255) -- Purple color when checked
        else
            ToggleCheckbox.TextColor3 = Color3.fromRGB(255, 255, 255) -- White color when unchecked
        end
        while isChecked and task.wait() do
            actionFunc()
        end
    end)

    toggleYOffset = toggleYOffset + 35
end

-- Function to create a simple title as filler
local function createTitle(parent, titleText)
    local TitleFrame = Instance.new("Frame")
    TitleFrame.Size = UDim2.new(1, -20, 0, 30)
    TitleFrame.Position = UDim2.new(0, 10, 0, toggleYOffset)
    TitleFrame.BackgroundTransparency = 1
    TitleFrame.Parent = parent

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = titleText
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.LuckiestGuy
    TitleLabel.TextSize = 16
    TitleLabel.Parent = TitleFrame

    toggleYOffset = toggleYOffset + 35
end

-- Function to create buttons
local function createButton(parent, buttonName, buttonFunc)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, -20, 0, 30)
    ButtonFrame.Position = UDim2.new(0, 10, 0, toggleYOffset)
    ButtonFrame.BackgroundTransparency = 1
    ButtonFrame.Parent = parent

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Gray color
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = buttonName
    Button.Font = Enum.Font.Cartoon
    Button.TextSize = 16
    Button.BorderSizePixel = 0
    Button.Parent = ButtonFrame

    -- Add rounded corners
    local cornerButton = Instance.new("UICorner")
    cornerButton.CornerRadius = UDim.new(0, 5) -- Adjust radius as needed
    cornerButton.Parent = Button

    Button.MouseButton1Click:Connect(buttonFunc)

    toggleYOffset = toggleYOffset + 35
end

-- Sample action functions
local args = {
    [1] = "Currency",
    [2] = 1000000
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlaytimeRewardsEvent"):FireServer(unpack(args))
