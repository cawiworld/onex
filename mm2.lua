-- [[ oNex Hub v2.0 | Murder Mystery 2 ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Удаление старого интерфейса, если он был запущен
if CoreGui:FindFirstChild("oNex_Hub") then
    CoreGui.oNex_Hub:Destroy()
end

local Settings = {
    Visible = true,
    CurrentTab = "General",
    MenuKeybind = Enum.KeyCode.RightControl,
    
    Noclip = false,
    SpeedEnabled = false,
    WalkSpeed = 16,
    JumpEnabled = false,
    JumpPower = 50,
    Spinbot = false,
    SpinSpeed = 20,
    SpinBind = Enum.KeyCode.C,
    AutoShoot = false,
    ShootBind = Enum.KeyCode.V,
    SilentAim = false,
    
    MurdESP = true,
    SheriffESP = true,
    InnocentESP = false,
    GunESP = true,
    NamesESP = true,
    
    ESPFont = Enum.Font.GothamBold,
    MurdColor = Color3.fromRGB(255, 50, 50),
    SheriffColor = Color3.fromRGB(50, 120, 255),
    InnocentColor = Color3.fromRGB(50, 255, 50),
    GunColor = Color3.fromRGB(255, 215, 0),
}

-- Таблицы для хранения кнопок вкладок и страниц
local Tabs = {}
local TabHighlight = nil

-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "oNex_Hub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Главное окно (Стиль Liquid Glass + Vertex)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 560, 0, 380)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BackgroundTransparency = 0.5 -- Имитация стекла
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Перетаскивание меню
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Тень окна
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Position = UDim2.new(0, -20, 0, -20)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217" -- Квадратная тень
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.Parent = MainFrame

-- Светящаяся граница синего неона (Liquid Glass эффект)
local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(50, 120, 255)
FrameStroke.Transparency = 0.6
FrameStroke.Thickness = 2
FrameStroke.Parent = MainFrame

local BorderGradient = Instance.new("UIGradient")
BorderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 120, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 120, 255))
})
BorderGradient.Rotation = 45
BorderGradient.Parent = FrameStroke

-- Боковая панель (Сайдбар)
local SideBar = Instance.new("Frame")
SideBar.Name = "SideBar"
SideBar.Size = UDim2.new(0, 150, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
SideBar.BackgroundTransparency = 0.6
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 12)
SideCorner.Parent = SideBar

-- Логотип oNex (Верхний левый угол)
local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 60)
Logo.Position = UDim2.new(0, 15, 0, 15)
Logo.RichText = true -- Для разных цветов
Logo.Text = "<font color='#FFFFFF'>o</font><font color='#3278FF'>Nex</font>"
Logo.TextSize = 28
Logo.Font = Enum.Font.GothamBold
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.BackgroundTransparency = 1
Logo.Parent = SideBar

-- Контейнер для кнопок вкладок
local TabButtonsContainer = Instance.new("Frame")
TabButtonsContainer.Size = UDim2.new(1, -10, 1, -100)
TabButtonsContainer.Position = UDim2.new(0, 5, 0, 85)
TabButtonsContainer.BackgroundTransparency = 1
TabButtonsContainer.Parent = SideBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabButtonsContainer
TabListLayout.Padding = UDim.new(0, 6)

-- Скользящий прямоугольник-подсветка вкладок
TabHighlight = Instance.new("Frame")
TabHighlight.Name = "TabHighlight"
TabHighlight.Size = UDim2.new(1, 0, 0, 36)
TabHighlight.Position = UDim2.new(0, 0, 0, 0)
TabHighlight.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
TabHighlight.BackgroundTransparency = 0.8
TabHighlight.Visible = false 
TabHighlight.Parent = SideBar

local HighlightCorner = Instance.new("UICorner")
HighlightCorner.CornerRadius = UDim.new(0, 6)
HighlightCorner.Parent = TabHighlight

local HighlightStroke = Instance.new("UIStroke")
HighlightStroke.Color = Color3.fromRGB(50, 120, 255)
HighlightStroke.Thickness = 1
HighlightStroke.Parent = TabHighlight

-- Контейнер для страниц вкладок (Справа)
local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -165, 1, -30)
PagesContainer.Position = UDim2.new(0, 155, 0, 15)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

-- Функция создания страниц (контента)
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false -- Скрыта по умолчанию
    Page.CanvasSize = UDim2.new(0, 0, 0, 0) -- Автоматический размер
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(50, 120, 255)
    Page.Parent = PagesContainer
    
    local UIList = Instance.new("UIListLayout")
    UIList.Parent = Page
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 10)
    
    local UIPadding = Instance.new("UIPadding")
    UIPadding.Parent = Page
    UIPadding.PaddingLeft = UDim.new(0, 5)
    UIPadding.PaddingTop = UDim.new(0, 5)
    UIPadding.PaddingBottom = UDim.new(0, 10)
    
    return Page
end

local GenPage = CreatePage("General")
local ESPPage = CreatePage("ESP")
local OthPage = CreatePage("Other")

-- Страницы хранятся в таблице для быстрого переключения
local Pages = {
    General = GenPage,
    ESP = ESPPage,
    Other = OthPage,
}

local function SwitchTab(tabName, button)
    Settings.CurrentTab = tabName
    
    TabHighlight.Visible = true
    local targetY = button.AbsolutePosition.Y - SideBar.AbsolutePosition.Y
    
    TweenService:Create(TabHighlight, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 5, 0, targetY)
    }):Play()
    
    for name, page in pairs(Pages) do
        page.Visible = (name == tabName)
    end
    
    for _, btn in pairs(Tabs) do
        TweenService:Create(btn:FindFirstChild("TextLabel"), TweenInfo.new(0.2), {
            TextColor3 = (btn == button) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
        }):Play()
    end
end

-- Функция создания кнопок вкладок
local function CreateTabButton(name)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 36)
    Button.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Button.BackgroundTransparency = 1 -- Скрыт
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
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        SwitchTab(name, Button)
    end)
    
    table.insert(Tabs, Button)
    return Button
end

local GenBtn = CreateTabButton("General")
local ESPBtn = CreateTabButton("ESP")
local OthBtn = CreateTabButton("Other")

-- Установка первой вкладки по умолчанию
SwitchTab("General", GenBtn)

--- [[[ УЛУЧШЕННЫЕ ЭЛЕМЕНТЫ ИНТЕРФЕЙСА С АНИМАЦИЯМИ ]]] ---

-- 1. Анимированный Переключатель (Toggle)
local function CreateToggle(parent, text, settingName, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 42)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frame.BackgroundTransparency = 0.6
    Frame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(50, 120, 255)
    Stroke.Transparency = 0.9
    Stroke.Thickness = 1
    Stroke.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame
    
    local ToggleBg = Instance.new("Frame")
    ToggleBg.Size = UDim2.new(0, 44, 0, 24)
    ToggleBg.Position = UDim2.new(1, -56, 0, 9)
    ToggleBg.BackgroundColor3 = Settings[settingName] and Color3.fromRGB(50, 120, 255) or Color3.fromRGB(50, 50, 55)
    ToggleBg.Parent = Frame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleBg
    
    local Ball = Instance.new("Frame")
    Ball.Size = UDim2.new(0, 18, 0, 18)
    Ball.Position = Settings[settingName] and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3)
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
    
    -- Плавная анимация наведения
    ClickBtn.MouseEnter:Connect(function()
        TweenService:Create(Stroke, TweenInfo.new(0.2), {Transparency = 0.7}):Play()
    end)
    ClickBtn.MouseLeave:Connect(function()
        TweenService:Create(Stroke, TweenInfo.new(0.2), {Transparency = 0.9}):Play()
    end)
    
    ClickBtn.MouseButton1Click:Connect(function()
        Settings[settingName] = not Settings[settingName]
        
        -- Анимация цвета и положения
        TweenService:Create(ToggleBg, TweenInfo.new(0.25), {
            BackgroundColor3 = Settings[settingName] and Color3.fromRGB(50, 120, 255) or Color3.fromRGB(50, 50, 55)
        }):Play()
        
        TweenService:Create(Ball, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = Settings[settingName] and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3)
        }):Play()
        
        if callback then callback(Settings[settingName]) end
    end)
end

-- 2. Анимированный Ползунок (Slider - «Отставание от курсора»)
local function CreateSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 56)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frame.BackgroundTransparency = 0.6
    Frame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(50, 120, 255)
    Stroke.Transparency = 0.9
    Stroke.Thickness = 1
    Stroke.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 0, 28)
    Label.Position = UDim2.new(0, 12, 0, 5)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 28)
    ValueLabel.Position = UDim2.new(1, -120, 0, 5)
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(50, 120, 255)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Parent = Frame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -24, 0, 8)
    SliderBar.Position = UDim2.new(0, 12, 0, 38)
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
    
    local FillGradient = Instance.new("UIGradient")
    FillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 120, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    FillGradient.Rotation = 90
    FillGradient.Parent = Fill
    
    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(1, 0, 1, 0)
    SliderBtn.BackgroundTransparency = 1
    SliderBtn.Text = ""
    SliderBtn.Parent = SliderBar
    
    local dragging = false
    local targetPercent = percent

    SliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    SliderBtn.MouseEnter:Connect(function() TweenService:Create(Stroke, TweenInfo.new(0.2), {Transparency = 0.7}):Play() end)
    SliderBtn.MouseLeave:Connect(function() if not dragging then TweenService:Create(Stroke, TweenInfo.new(0.2), {Transparency = 0.9}):Play() end end)

    local lastValue = default
    RunService.RenderStepped:Connect(function(dt)
        if dragging then
            local mousePos = UserInputService:GetMouseLocation().X
            local barPos = SliderBar.AbsolutePosition.X
            local barWidth = SliderBar.AbsoluteSize.X
            targetPercent = math.clamp((mousePos - barPos) / barWidth, 0, 1)
        end
        
        local currentPercent = Fill.Size.X.Scale
        local lerpPercent = currentPercent + (targetPercent - currentPercent) * dt * 15 
        
        TweenService:Create(Fill, TweenInfo.new(dt, Enum.EasingStyle.Linear), {Size = UDim2.new(lerpPercent, 0, 1, 0)}):Play()
        
        local value = math.floor(min + (lerpPercent * (max - min)))
        ValueLabel.Text = tostring(value)
        
        if value ~= lastValue then
            lastValue = value
            if callback then callback(value) end
        end
    end)
end

-- 3. Циклическая кнопка выбора (Dropdown замена)
local function CreateCycleButton(parent, text, options, defaultIndex, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 42)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frame.BackgroundTransparency = 0.6
    Frame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame
    
    local OptBtn = Instance.new("TextButton")
    OptBtn.Size = UDim2.new(0, 130, 0, 28)
    OptBtn.Position = UDim2.new(1, -140, 0, 7)
    OptBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    OptBtn.BackgroundTransparency = 0.5
    local currentIndex = defaultIndex
    OptBtn.Text = options[currentIndex]
    OptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    OptBtn.Font = Enum.Font.GothamBold
    OptBtn.TextSize = 13
    OptBtn.Parent = Frame
    
    local OptCorner = Instance.new("UICorner")
    OptCorner.CornerRadius = UDim.new(0, 6)
    OptCorner.Parent = OptBtn
    
    OptBtn.MouseEnter:Connect(function()
        TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)
    OptBtn.MouseLeave:Connect(function()
        TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
    end)
    
    OptBtn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #options then currentIndex = 1 end
        
        -- Сочная анимация изменения текста (твин масштабирования)
        TweenService:Create(OptBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextSize = 15}):Play()
        task.wait(0.05)
        OptBtn.Text = options[currentIndex]
        TweenService:Create(OptBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextSize = 13}):Play()
        
        if callback then callback(options[currentIndex], currentIndex) end
    end)
end

-- 4. Элемент Бинда (Keybind)
local function CreateBind(parent, text, settingName, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 42)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frame.BackgroundTransparency = 0.6
    Frame.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame
    
    local BindBtn = Instance.new("TextButton")
    BindBtn.Size = UDim2.new(0, 80, 0, 28)
    BindBtn.Position = UDim2.new(1, -90, 0, 7)
    BindBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    BindBtn.Text = Settings[settingName].Name
    BindBtn.TextColor3 = Color3.fromRGB(50, 120, 255)
    BindBtn.Font = Enum.Font.GothamBold
    BindBtn.TextSize = 13
    BindBtn.Parent = Frame
    
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 6)
    BCorner.Parent = BindBtn
    
    local isListening = false
    BindBtn.MouseButton1Click:Connect(function()
        isListening = true
        BindBtn.Text = "..."
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if isListening and input.UserInputType == Enum.UserInputType.Keyboard then
            Settings[settingName] = input.KeyCode
            BindBtn.Text = input.KeyCode.Name
            isListening = false
            if callback then callback(input.KeyCode) end
        end
    end)
end

--- [[[ ЛОГИКА GENERAL ФУНКЦИЙ ]]] ---

-- Надежный поиск Убийцы
local function GetMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and p.Character then
            -- Проверяем инвентарь и руки
            if p.Character:FindFirstChild("Knife") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife")) then
                return p
            end
        end
    end
    return nil
end

-- Обработка биндов
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp then
        if input.KeyCode == Settings.SpinBind then
            Settings.Spinbot = not Settings.Spinbot
        elseif input.KeyCode == Settings.ShootBind then
            Settings.AutoShoot = not Settings.AutoShoot
        end
    end
end)

-- Noclip (Используем Stepped, так как он выполняется до просчета физики движком)
RunService.Stepped:Connect(function()
    if Settings.Noclip then
        local char = Players.LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- WalkSpeed, JumpPower, Spinbot и AutoShoot (Используем RenderStepped для обхода анти-чита)
RunService.RenderStepped:Connect(function()
    local char = Players.LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if hum then
        -- Жестко перебиваем скорость каждый кадр
        if Settings.SpeedEnabled then 
            hum.WalkSpeed = Settings.WalkSpeed 
        end
        -- Включаем принудительное использование JumpPower
        if Settings.JumpEnabled then 
            hum.UseJumpPower = true
            hum.JumpPower = Settings.JumpPower 
        end
    end
    
    -- ФИКС СПИНБОТА: Крутим через RotVelocity, чтобы можно было бегать!
    if hrp then
        if Settings.Spinbot then
            hrp.RotVelocity = Vector3.new(0, Settings.SpinSpeed * 3, 0)
        else
            -- Возвращаем в норму, если выключен (опционально)
            if hrp.RotVelocity.Y > 20 then hrp.RotVelocity = Vector3.new(hrp.RotVelocity.X, 0, hrp.RotVelocity.Z) end
        end
    end
    
    -- AutoShoot
    if Settings.AutoShoot then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and (tool.Name == "Gun" or tool.Name == "Knife") then
            local target = GetMurderer()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                tool:Activate()
            end
        end
    end
end)

-- Silent Aim (Перехват позиции мыши)
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    -- Проверяем, что запрос исходит от игры, а не от наших скриптов, и что это мышка
    if Settings.SilentAim and not checkcaller() and typeof(self) == "Instance" and self:IsA("PlayerMouse") then
        if key == "Hit" then
            local target = GetMurderer()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                return target.Character.HumanoidRootPart.CFrame
            end
        elseif key == "Target" then
            local target = GetMurderer()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                return target.Character.HumanoidRootPart
            end
        end
    end
    return oldIndex(self, key)
end)
