-- oNex Roblox | MM2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Settings = {
    CurrentTab = "General",
    MenuKeybind = Enum.KeyCode.RightControl,
    Visible = true,
    
    MurdESP = true,
    SheriffESP = true,
    InnocentESP = false,
    GunESP = true,
    NamesESP = true,
    
    ESPFont = Enum.Font.GothamBold,
    MurdColor = Color3.fromRGB(255, 50, 50),
    SheriffColor = Color3.fromRGB(50, 120, 255),
    InnocentColor = Color3.fromRGB(50, 255, 50),
    GunColor = Color3.fromRGB(255, 215, 0)
}

if CoreGui:FindFirstChild("oNex_Hub") then
    CoreGui.oNex_Hub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "oNex_Hub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 360)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(255, 255, 255)
FrameStroke.Transparency = 0.85
FrameStroke.Thickness = 1
FrameStroke.Parent = MainFrame

local SideBar = Instance.new("Frame")
SideBar.Name = "SideBar"
SideBar.Size = UDim2.new(0, 140, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
SideBar.BackgroundTransparency = 0.4
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 12)
SideCorner.Parent = SideBar

local SideCover = Instance.new("Frame")
SideCover.Size = UDim2.new(0, 20, 1, 0)
SideCover.Position = UDim2.new(1, -20, 0, 0)
SideCover.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
SideCover.BackgroundTransparency = 0.4
SideCover.BorderSizePixel = 0
SideCover.Parent = SideBar

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 50)
Logo.Position = UDim2.new(0, 15, 0, 10)
Logo.RichText = true
Logo.Text = "<font color='#FFFFFF'>o</font><font color='#3278FF'>Nex</font>"
Logo.TextSize = 24
Logo.Font = Enum.Font.GothamBold
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.BackgroundTransparency = 1
Logo.Parent = SideBar

local TabButtonsContainer = Instance.new("Frame")
TabButtonsContainer.Size = UDim2.new(1, -10, 1, -70)
TabButtonsContainer.Position = UDim2.new(0, 5, 0, 65)
TabButtonsContainer.BackgroundTransparency = 1
TabButtonsContainer.Parent = SideBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabButtonsContainer
TabListLayout.Padding = UDim.new(0, 5)

local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -150, 1, -20)
PagesContainer.Position = UDim2.new(0, 145, 0, 10)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

local Pages = {}

local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 450)
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(50, 120, 255)
    Page.Parent = PagesContainer
    
    local UIList = Instance.new("UIListLayout")
    UIList.Parent = Page
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 8)
    
    Pages[name] = Page
    return Page
end

local GenPage = CreatePage("General")
local ESPPage = CreatePage("ESP")
local OthPage = CreatePage("Other")

local function SwitchTab(tabName, button)
    Settings.CurrentTab = tabName
    for name, page in pairs(Pages) do
        page.Visible = (name == tabName)
    end
    
    for _, btn in pairs(TabButtonsContainer:GetChildren()) do
        if btn:IsA("TextButton") then
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = (btn == button) and Color3.fromRGB(35, 35, 45) or Color3.fromRGB(20, 20, 25),
                BackgroundTransparency = (btn == button) and 0 or 0.5
            }):Play()
            TweenService:Create(btn.TextLabel, TweenInfo.new(0.2), {
                TextColor3 = (btn == button) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
            }):Play()
        end
    end
end

local function CreateTabButton(name)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Button.BackgroundTransparency = 0.5
    Button.Text = ""
    Button.Parent = TabButtonsContainer
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(150, 150, 150)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Button
    Button:setAttribute("TextLabel", Label)
    
    Button.MouseButton1Click:Connect(function()
        SwitchTab(name, Button)
    end)
    
    return Button
end

local GenBtn = CreateTabButton("General")
local ESPBtn = CreateTabButton("ESP")
local OthBtn = CreateTabButton("Other")

SwitchTab("General", GenBtn)

local function CreateToggle(parent, text, settingName, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -5, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frame.BackgroundTransparency = 0.4
    Frame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame
    
    local ToggleBg = Instance.new("Frame")
    ToggleBg.Size = UDim2.new(0, 42, 0, 22)
    ToggleBg.Position = UDim2.new(1, -52, 0, 9)
    ToggleBg.BackgroundColor3 = Settings[settingName] and Color3.fromRGB(50, 120, 255) or Color3.fromRGB(50, 50, 55)
    ToggleBg.Parent = Frame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleBg
    
    local Ball = Instance.new("Frame")
    Ball.Size = UDim2.new(0, 16, 0, 16)
    Ball.Position = Settings[settingName] and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3)
    Ball.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Ball.Parent = ToggleBg
    
    local BallCorner = Instance.new("UICorner")
    BallCorner.CornerRadius = UDim.new(1, 0)
    BallCorner.Parent = Ball
    
    local ClickBtn = Instance.new("TextButton")
    ClickBtn.Size = UDim2.new(1, 0, 1, 0)
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.Text = ""
    ClickBtn.Parent = Frame
    
    ClickBtn.MouseButton1Click:Connect(function()
        Settings[settingName] = not Settings[settingName]
        
        TweenService:Create(ToggleBg, TweenInfo.new(0.25), {
            BackgroundColor3 = Settings[settingName] and Color3.fromRGB(50, 120, 255) or Color3.fromRGB(50, 50, 55)
        }):Play()
        
        TweenService:Create(Ball, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = Settings[settingName] and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3)
        }):Play()
        
        if callback then callback(Settings[settingName]) end
    end)
end

local function CreateSlider(parent, text, min, max, default)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -5, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frame.BackgroundTransparency = 0.4
    Frame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 3)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 25)
    ValueLabel.Position = UDim2.new(1, -110, 0, 3)
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(50, 120, 255)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Parent = Frame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -20, 0, 6)
    SliderBar.Position = UDim2.new(0, 10, 0, 34)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SliderBar.Parent = Frame
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = SliderBar
    
    local Fill = Instance.new("Frame")
    local percent = (default - min) / (max - min)
    Fill.Size = UDim2.new(percent, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
    Fill.Parent = SliderBar
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill
    
    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(1, 0, 1, 0)
    SliderBtn.BackgroundTransparency = 1
    SliderBtn.Text = ""
    SliderBtn.Parent = SliderBar
    
    local dragging = false
    SliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation().X
            local barPos = SliderBar.AbsolutePosition.X
            local barWidth = SliderBar.AbsoluteSize.X
            local relX = math.clamp((mousePos - barPos) / barWidth, 0, 1)
            
            TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(relX, 0, 1, 0)}):Play()
            local value = math.floor(min + (relX * (max - min)))
            ValueLabel.Text = tostring(value)
        end
    end)
end

local function CreateCycleButton(parent, text, options, defaultIndex, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -5, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frame.BackgroundTransparency = 0.4
    Frame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame
    
    local OptBtn = Instance.new("TextButton")
    OptBtn.Size = UDim2.new(0, 120, 0, 26)
    OptBtn.Position = UDim2.new(1, -130, 0, 7)
    OptBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    local currentIndex = defaultIndex
    OptBtn.Text = options[currentIndex]
    OptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    OptBtn.Font = Enum.Font.GothamBold
    OptBtn.TextSize = 12
    OptBtn.Parent = Frame
    
    local OptCorner = Instance.new("UICorner")
    OptCorner.CornerRadius = UDim.new(0, 4)
    OptCorner.Parent = OptBtn
    
    OptBtn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #options then currentIndex = 1 end
        OptBtn.Text = options[currentIndex]
        if callback then callback(options[currentIndex], currentIndex) end
    end)
end

CreateToggle(GenPage, "Тестовая функция 1 (Test Toggle)", "Test1", function(val) print("Test 1:", val) end)
CreateToggle(GenPage, "Тестовая функция 2 (Animated)", "Test2")
CreateSlider(GenPage, "Скорость бега (Test WalkSpeed)", 16, 100, 16)
CreateSlider(GenPage, "Высота прыжка (Test JumpPower)", 50, 150, 50)

CreateToggle(ESPPage, "Показывать Убийцу (Murderer)", "MurdESP")
CreateToggle(ESPPage, "Показывать Шерифа (Sheriff)", "SheriffESP")
CreateToggle(ESPPage, "Показывать Мирных (Innocents)", "InnocentESP")
CreateToggle(ESPPage, "Подсветка Оружия на полу (Gun Drop)", "GunESP")
CreateToggle(ESPPage, "Отображать никнеймы (ESP Nicknames)", "NamesESP")

CreateCycleButton(ESPPage, "Цвет Убийцы", {"Красный", "Розовый", "Оранжевый"}, 1, function(name)
    if name == "Красный" then Settings.MurdColor = Color3.fromRGB(255, 50, 50)
    elseif name == "Розовый" then Settings.MurdColor = Color3.fromRGB(255, 20, 147)
    elseif name == "Оранжевый" then Settings.MurdColor = Color3.fromRGB(255, 140, 0) end
end)

CreateCycleButton(ESPPage, "Цвет Шерифа", {"Синий", "Голубой", "Фиолетовый"}, 1, function(name)
    if name == "Синий" then Settings.SheriffColor = Color3.fromRGB(50, 120, 255)
    elseif name == "Голубой" then Settings.SheriffColor = Color3.fromRGB(0, 255, 255)
    elseif name == "Фиолетовый" then Settings.SheriffColor = Color3.fromRGB(138, 43, 226) end
end)

CreateCycleButton(ESPPage, "Шрифт Никнеймов", {"Gotham", "Code", "Arcade", "SciFi"}, 1, function(name)
    if name == "Gotham" then Settings.ESPFont = Enum.Font.GothamBold
    elseif name == "Code" then Settings.ESPFont = Enum.Font.Code
    elseif name == "Arcade" then Settings.ESPFont = Enum.Font.Arcade
    elseif name == "SciFi" then Settings.ESPFont = Enum.Font.SciFi end
end)

local function CreateInfoText(parent, text, value)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -5, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent
    
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.5, 0, 1, 0)
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.BackgroundTransparency = 1
    Lbl.Parent = Frame
    
    local Val = Instance.new("TextLabel")
    Val.Size = UDim2.new(0.5, 0, 1, 0)
    Val.Position = UDim2.new(0.5, 0, 0, 0)
    Val.Text = value
    Val.TextColor3 = Color3.fromRGB(255, 255, 255)
    Val.Font = Enum.Font.GothamBold
    Val.TextSize = 13
    Val.TextXAlignment = Enum.TextXAlignment.Right
    Val.BackgroundTransparency = 1
    Val.Parent = Frame
end

CreateInfoText(OthPage, "Версия скрипта:", "oNex 1.1")
CreateInfoText(OthPage, "Идентификатор кода:", "Roblox_MurderMystery2")

local BindFrame = Instance.new("Frame")
BindFrame.Size = UDim2.new(1, -5, 0, 40)
BindFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
BindFrame.BackgroundTransparency = 0.4
BindFrame.Parent = OthPage

local BindCorner = Instance.new("UICorner")
BindCorner.CornerRadius = UDim.new(0, 6)
BindCorner.Parent = BindFrame

local BindLabel = Instance.new("TextLabel")
BindLabel.Size = UDim2.new(0.5, 0, 1, 0)
BindLabel.Position = UDim2.new(0, 10, 0, 0)
BindLabel.Text = "Открыть/Закрыть меню"
BindLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
BindLabel.Font = Enum.Font.Gotham
BindLabel.TextSize = 14
BindLabel.TextXAlignment = Enum.TextXAlignment.Left
BindLabel.BackgroundTransparency = 1
BindLabel.Parent = BindFrame

local BindBtn = Instance.new("TextButton")
BindBtn.Size = UDim2.new(0, 100, 0, 26)
BindBtn.Position = UDim2.new(1, -110, 0, 7)
BindBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
BindBtn.Text = Settings.MenuKeybind.Name
BindBtn.TextColor3 = Color3.fromRGB(50, 120, 255)
BindBtn.Font = Enum.Font.GothamBold
BindBtn.TextSize = 12
BindBtn.Parent = BindFrame

local BindBtnCorner = Instance.new("UICorner")
BindBtnCorner.CornerRadius = UDim.new(0, 4)
BindBtnCorner.Parent = BindBtn

local listeningForBind = false
BindBtn.MouseButton1Click:Connect(function()
    listeningForBind = true
    BindBtn.Text = "..."
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if listeningForBind and input.UserInputType == Enum.UserInputType.Keyboard then
        Settings.MenuKeybind = input.KeyCode
        BindBtn.Text = input.KeyCode.Name
        listeningForBind = false
    elseif not gameProcessed and input.KeyCode == Settings.MenuKeybind then
        Settings.Visible = not Settings.Visible
        MainFrame.Visible = Settings.Visible
    end
end)

local function CreateHighlight(player, color)
    local char = player.Character
    if not char then return end
    
    local hl = char:FindFirstChild("oNex_Highlight") or Instance.new("Highlight")
    hl.Name = "oNex_Highlight"
    hl.FillColor = color
    hl.FillTransparency = 0.5
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0
    hl.Adornee = char
    hl.Parent = char
    
    if Settings.NamesESP then
        local bbg = char:FindFirstChild("oNex_NameTag") or Instance.new("BillboardGui")
        bbg.Name = "oNex_NameTag"
        bbg.Size = UDim2.new(0, 200, 0, 50)
        bbg.AlwaysOnTop = true
        bbg.StudsOffset = Vector3.new(0, 3, 0)
        bbg.Adornee = char:FindFirstChild("HumanoidRootPart")
        
        local txt = bbg:FindFirstChild("TextLabel") or Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = player.Name
        txt.TextColor3 = color
        txt.Font = Settings.ESPFont
        txt.TextSize = 14
        txt.Parent = bbg
        bbg.Parent = char
    else
        if char:FindFirstChild("oNex_NameTag") then char.oNex_NameTag:Destroy() end
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
    
    local gunDrop = workspace:FindFirstChild("GunDrop")
    if gunDrop and Settings.GunESP then
        local hl = gunDrop:FindFirstChild("oNex_GunHL") or Instance.new("Highlight")
        hl.Name = "oNex_GunHL"
        hl.FillColor = Settings.GunColor
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.Adornee = gunDrop
        hl.Parent = gunDrop
    elseif gunDrop and not Settings.GunESP and gunDrop:FindFirstChild("oNex_GunHL") then
        gunDrop.oNex_GunHL:Destroy()
    end
end)
