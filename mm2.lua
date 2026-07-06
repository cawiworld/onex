-- oNex hub | Murder Mystery 2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local Settings = {
    MurdESP = true,
    SheriffESP = true,
    InnocentESP = false,
    GunESP = true,
    NamesESP = true,
    
    MurdColor = Color3.fromRGB(255, 50, 50),
    SheriffColor = Color3.fromRGB(50, 50, 255),
    InnocentColor = Color3.fromRGB(50, 255, 50),
    GunColor = Color3.fromRGB(255, 215, 0)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "oNex"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "oNex Menu v1.0 | Murder Mystery 2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BackgroundTransparency = 1
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 45)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 0, 400)
Content.ScrollBarThickness = 4
Content.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = Content
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)

local function CreateToggle(name, settingName, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = Content
    
    local TFCorner = Instance.new("UICorner")
    TFCorner.CornerRadius = UDim.new(0, 6)
    TFCorner.Parent = ToggleFrame
    
    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(0.7, 0, 1, 0)
    Text.Position = UDim2.new(0, 10, 0, 0)
    Text.Text = name
    Text.TextColor3 = Color3.fromRGB(200, 200, 200)
    Text.TextSize = 14
    Text.Font = Enum.Font.Gotham
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.BackgroundTransparency = 1
    Text.Parent = ToggleFrame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 50, 0, 24)
    Button.Position = UDim2.new(1, -60, 0, 8)
    Button.BackgroundColor3 = Settings[settingName] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 100)
    Button.Text = ""
    Button.Parent = ToggleFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 12)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        Settings[settingName] = not Settings[settingName]
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Settings[settingName] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 100)
        }):Play()
        if callback then callback(Settings[settingName]) end
    end)
end

CreateToggle("Показывать Убийцу (ESP Murderer)", "MurdESP")
CreateToggle("Показывать Шерифа (ESP Sheriff)", "SheriffESP")
CreateToggle("Показывать Мирных (ESP Innocents)", "InnocentESP")
CreateToggle("Подсветка Оружия на полу (Gun ESP)", "GunESP")
CreateToggle("Показывать Никнеймы (ESP Nicknames)", "NamesESP")

local function CreateHighlight(player, color)
    local char = player.Character
    if not char then return end
    
    if char:FindFirstChild("oNex_Highlight") then
        char.oNex_Highlight:Destroy()
    end
    
    local hl = Instance.new("Highlight")
    hl.Name = "oNex_Highlight"
    hl.FillColor = color
    hl.FillTransparency = 0.5
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0
    hl.Adornee = char
    hl.Parent = char
    
    if Settings.NamesESP and not char:FindFirstChild("oNex_NameTag") then
        local bbg = Instance.new("BillboardGui")
        bbg.Name = "oNex_NameTag"
        bbg.Size = UDim2.new(0, 200, 0, 50)
        bbg.AlwaysOnTop = true
        bbg.StudsOffset = Vector3.new(0, 3, 0)
        bbg.Adornee = char:FindFirstChild("HumanoidRootPart")
        
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = player.Name
        txt.TextColor3 = color
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 14
        txt.Parent = bbg
        bbg.Parent = char
    end
end

local function CleanESP(player)
    if player.Character then
        if player.Character:FindFirstChild("oNex_Highlight") then player.Character.oNex_Highlight:Destroy() end
        if player.Character:FindFirstChild("oNex_NameTag") then player.Character.oNex_NameTag:Destroy() end
    end
end

RunService.Heartbeat:Connect(function()
    if not ScreenGui.Parent then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local backpack = p:FindFirstChild("Backpack")
            local char = p.Character
            
            local isMurd = (backpack and backpack:FindFirstChild("Knife")) or char:FindFirstChild("Knife")
            local isSheriff = (backpack and backpack:FindFirstChild("Gun")) or char:FindFirstChild("Gun")
            
            if isMurd and Settings.MurdESP then
                CreateHighlight(p, Settings.MurdColor)
            elseif isSheriff and Settings.SheriffESP then
                CreateHighlight(p, Settings.SheriffColor)
            elseif not isMurd and not isSheriff and Settings.InnocentESP then
                CreateHighlight(p, Settings.InnocentColor)
            else
                CleanESP(p)
            end
        end
    end
    
    if Settings.GunESP then
        local gunDrop = workspace:FindFirstChild("GunDrop")
        if gunDrop and not gunDrop:FindFirstChild("oNex_GunHL") then
            local hl = Instance.new("Highlight")
            hl.Name = "oNex_GunHL"
            hl.FillColor = Settings.GunColor
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.Adornee = gunDrop
            hl.Parent = gunDrop
        end
    end
end)
