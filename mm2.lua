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
local function CreateSlider(parent, text, min, max, default)
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
    local targetPercent = percent -- Целевой процент для плавного «дотягивания»

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
    
    SliderBtn.MouseEnter:Connect(function()
        TweenService:Create(Stroke, TweenInfo.new(0.2), {Transparency = 0.7}):Play()
    end)
    SliderBtn.MouseLeave:Connect(function()
        if not dragging then
            TweenService:Create(Stroke, TweenInfo.new(0.2), {Transparency = 0.9}):Play()
        end
    end)

    -- Логика плавного отставания от курсора в цикле RenderStepped
    RunService.RenderStepped:Connect(function(dt)
        if dragging then
            local mousePos = UserInputService:GetMouseLocation().X
            local barPos = SliderBar.AbsolutePosition.X
            local barWidth = SliderBar.AbsoluteSize.X
            targetPercent = math.clamp((mousePos - barPos) / barWidth, 0, 1)
        end
        
        -- Плавно интерполируем (лерпим) текущий Fill:
        local currentPercent = Fill.Size.X.Scale
        local lerpPercent = currentPercent + (targetPercent - currentPercent) * dt * 15 -- Чем меньше dt * X, тем больше отставание
        
        -- Используем TweenService для совсем микро-движений
        TweenService:Create(Fill, TweenInfo.new(dt, Enum.EasingStyle.Linear), {Size = UDim2.new(lerpPercent, 0, 1, 0)}):Play()
        
        local value = math.floor(min + (lerpPercent * (max - min)))
        ValueLabel.Text = tostring(value)
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

--- [[[ НАПОЛНЕНИЕ ВКЛАДОК oNex 2.0 ]]] ---

-- 1. Вкладка: GENERAL (Movement & Combat)
CreateToggle(GenPage, "Noclip", "Noclip")

CreateToggle(GenPage, "SpeedHack", "SpeedEnabled")
CreateSlider(GenPage, "Настройка скорости", 16, 150, 16, function(val) Settings.WalkSpeed = val end)

CreateToggle(GenPage, "JumpHack", "JumpEnabled")
CreateSlider(GenPage, "Настройка прыжка", 50, 250, 50, function(val) Settings.JumpPower = val end)

CreateToggle(GenPage, "Silent Aim (Револьвер)", "SilentAim")

CreateToggle(GenPage, "AutoShoot (Оба оружия)", "AutoShoot")
CreateBind(GenPage, "Бинд AutoShoot", "ShootBind")

CreateToggle(GenPage, "SpinBot", "Spinbot")
CreateSlider(GenPage, "Скорость SpinBot", 10, 100, 20, function(val) Settings.SpinSpeed = val end)
CreateBind(GenPage, "Бинд SpinBot", "SpinBind")

-- 2. Вкладка: ESP (Наши функции + Улучшенные настройки)
CreateToggle(ESPPage, "Показывать Убийцу (Murderer)", "MurdESP")
CreateToggle(ESPPage, "Показывать Шерифа (Sheriff)", "SheriffESP")
CreateToggle(ESPPage, "Показывать Мирных (Innocents)", "InnocentESP")
CreateToggle(ESPPage, "Подсветка Оружия на полу (Gun Drop)", "GunESP")
CreateToggle(ESPPage, "Отображать никнеймы (ESP Nicknames)", "NamesESP")

-- Кастомизация Цветов
CreateCycleButton(ESPPage, "Цвет Убийцы", {"Красный", "Фиолетовый", "Розовый"}, 1, function(name)
    if name == "Красный" then Settings.MurdColor = Color3.fromRGB(255, 50, 50)
    elseif name == "Фиолетовый" then Settings.MurdColor = Color3.fromRGB(138, 43, 226)
    elseif name == "Розовый" then Settings.MurdColor = Color3.fromRGB(255, 20, 147) end
end)

CreateCycleButton(ESPPage, "Цвет Шерифа", {"Синий", "Голубой", "Зелёный"}, 1, function(name)
    if name == "Синий" then Settings.SheriffColor = Color3.fromRGB(50, 120, 255)
    elseif name == "Голубой" then Settings.SheriffColor = Color3.fromRGB(0, 255, 255)
    elseif name == "Зелёный" then Settings.SheriffColor = Color3.fromRGB(50, 200, 50) end
end)

-- Выбор Шрифта
CreateCycleButton(ESPPage, "Шрифт Никнеймов", {"Gotham", "Code", "Arcade"}, 1, function(name)
    if name == "Gotham" then Settings.ESPFont = Enum.Font.GothamBold
    elseif name == "Code" then Settings.ESPFont = Enum.Font.Code
    elseif name == "Arcade" then Settings.ESPFont = Enum.Font.Arcade end
end)

-- 3. Вкладка: OTHER (Бинд, Версия, Инфо)
local function CreateInfoText(parent, text, value)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 36)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent
    
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.5, 0, 1, 0)
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 14
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.BackgroundTransparency = 1
    Lbl.Parent = Frame
    
    local Val = Instance.new("TextLabel")
    Val.Size = UDim2.new(0.5, 0, 1, 0)
    Val.Position = UDim2.new(0.5, -12, 0, 0)
    Val.Text = value
    Val.TextColor3 = Color3.fromRGB(255, 255, 255)
    Val.Font = Enum.Font.GothamBold
    Val.TextSize = 14
    Val.TextXAlignment = Enum.TextXAlignment.Right
    Val.BackgroundTransparency = 1
    Val.Parent = Frame
end

CreateInfoText(OthPage, "Версия:", "oNex 2.0")
CreateInfoText(OthPage, "Идентификатор кода:", "Roblox_MurderMystery2")
CreateInfoText(OthPage, "Разработчик:", "cawiworld")

-- Настройка клавиши открытия (Keybind)
local BindFrame = Instance.new("Frame")
BindFrame.Size = UDim2.new(1, -10, 0, 42)
BindFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
BindFrame.BackgroundTransparency = 0.6
BindFrame.Parent = OthPage

local BindCorner = Instance.new("UICorner")
BindCorner.CornerRadius = UDim.new(0, 8)
BindCorner.Parent = BindFrame

local BindLabel = Instance.new("TextLabel")
BindLabel.Size = UDim2.new(0.5, 0, 1, 0)
BindLabel.Position = UDim2.new(0, 12, 0, 0)
BindLabel.Text = "Открыть/Закрыть меню"
BindLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
BindLabel.Font = Enum.Font.Gotham
BindLabel.TextSize = 14
BindLabel.TextXAlignment = Enum.TextXAlignment.Left
BindLabel.BackgroundTransparency = 1
BindLabel.Parent = BindFrame

local BindBtn = Instance.new("TextButton")
BindBtn.Size = UDim2.new(0, 110, 0, 28)
BindBtn.Position = UDim2.new(1, -120, 0, 7)
BindBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
BindBtn.Text = Settings.MenuKeybind.Name
BindBtn.TextColor3 = Color3.fromRGB(50, 120, 255)
BindBtn.Font = Enum.Font.GothamBold
BindBtn.TextSize = 13
BindBtn.Parent = BindFrame

local BindBtnCorner = Instance.new("UICorner")
BindBtnCorner.CornerRadius = UDim.new(0, 6)
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
        
        -- Плавная анимация скрытия/показа меню (твин масштабирования)
        MainFrame.Visible = true -- Всегда тру для анимации
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = Settings.Visible and UDim2.new(0.5, -280, 0.5, -190) or UDim2.new(0.5, -280, 1, 100),
            Transparency = Settings.Visible and 0 or 1
        }):Play()
        task.delay(0.3, function() if not Settings.Visible then MainFrame.Visible = false end end)
    end
end)


--- [[[ ЛОГИКА ESP С АВТОБИНДОМ ]]] ---

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
    
    -- Логика никнеймов (используем FindingChild для безопасности)
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
        txt.Font = Settings.ESPFont -- Используем выбранный шрифт
        txt.TextSize = 15
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
            
            -- Определение ролей
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
    
    -- Подсветка упавшего пистолета
    local gunDrop = workspace:FindFirstChild("GunDrop")
    if gunDrop and Settings.GunESP then
        local hl = gunDrop:FindFirstChild("oNex_GunHL") or Instance.new("Highlight")
        hl.Name = "oNex_GunHL"
        hl.FillColor = Settings.GunColor
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.Adornee = gunDrop
        hl.Parent = gunDrop
    elseif gunDrop and gunDrop:FindFirstChild("oNex_GunHL") then
        gunDrop.oNex_GunHL:Destroy()
    end
end)

--- [[[ ЛОГИКА GENERAL ФУНКЦИЙ ]]] ---

-- Функция поиска Убийцы для сайлент айма
local function GetMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and p.Character then
            local bp = p:FindFirstChild("Backpack")
            if (bp and bp:FindFirstChild("Knife")) or p.Character:FindFirstChild("Knife") then
                return p
            end
        end
    end
    return nil
end

-- Обработка биндов для включения/выключения
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp then
        if input.KeyCode == Settings.SpinBind then
            Settings.Spinbot = not Settings.Spinbot
        elseif input.KeyCode == Settings.ShootBind then
            Settings.AutoShoot = not Settings.AutoShoot
        end
    end
end)

-- Noclip (Срабатывает до просчета физики, чтобы не дергало)
RunService.Stepped:Connect(function()
    local char = Players.LocalPlayer.Character
    if char and Settings.Noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
    end
end)

-- WalkSpeed, JumpPower, Spinbot и AutoShoot
RunService.Heartbeat:Connect(function()
    local char = Players.LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    -- Обход сброса скорости в MM2
    if hum then
        if Settings.SpeedEnabled then hum.WalkSpeed = Settings.WalkSpeed end
        if Settings.JumpEnabled then hum.JumpPower = Settings.JumpPower end
    end
    
    -- Спинбот (Крутим HumanoidRootPart)
    if hrp and Settings.Spinbot then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Settings.SpinSpeed), 0)
    end
    
    -- AutoShoot: Автоматическая активация оружия, если оно в руках
    if Settings.AutoShoot then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and (tool.Name == "Gun" or tool.Name == "Knife") then
            local target = GetMurderer()
            -- Бьем только если цель найдена (для гана сайлент аим сам наведется)
            if target and target.Character then
                tool:Activate()
            end
        end
    end
end)

-- Silent Aim (Подмена позиции мыши для Револьвера через Hook)
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and Settings.SilentAim and self:IsA("PlayerMouse") then
        if key == "Hit" or key == "Target" then
            local target = GetMurderer()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                if key == "Hit" then
                    return target.Character.HumanoidRootPart.CFrame
                elseif key == "Target" then
                    return target.Character.HumanoidRootPart
                end
            end
        end
    end
    return oldIndex(self, key)
end)
