local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

if CoreGui:FindFirstChild("onehvh_Hub") then 
    CoreGui.onehvh_Hub:Destroy() 
end
if CoreGui:FindFirstChild("onehvh_HUD") then 
    CoreGui.onehvh_HUD:Destroy() 
end

local Settings = {
    Visible = true, CurrentTab = "Combat", MenuBind = Enum.KeyCode.RightControl,

    SilentAim = false, SilentAimBind = Enum.KeyCode.Unknown,
    Aimlock = false, AimlockBind = Enum.KeyCode.Unknown,
    TeamCheck = false, TeamCheckBind = Enum.KeyCode.Unknown,
    DrawFOV = false, DrawFOVBind = Enum.KeyCode.Unknown, FOV = 150,
    
    InfJump = false, InfJumpBind = Enum.KeyCode.Unknown,
    Noclip = false, NoclipBind = Enum.KeyCode.Unknown,
    SpeedHack = false, SpeedHackBind = Enum.KeyCode.Unknown, WalkSpeed = 25,
    JumpHack = false, JumpHackBind = Enum.KeyCode.Unknown, JumpPower = 60,
    Spinbot = false, SpinbotBind = Enum.KeyCode.Unknown, SpinSpeed = 30,

    ESP = true, ESPBind = Enum.KeyCode.Unknown,
    NamesESP = true, NamesESPBind = Enum.KeyCode.Unknown,

    Nightmode = false, NightmodeBind = Enum.KeyCode.Unknown,
    FullBright = false, FullBrightBind = Enum.KeyCode.Unknown,
    NoShadows = false, NoShadowsBind = Enum.KeyCode.Unknown,
    WorldR = 255, WorldG = 255, WorldB = 255,

    UIColorR = 66, UIColorG = 135, UIColorB = 245,
    RTX = false, RTXBind = Enum.KeyCode.Unknown,

    EnemyColor = Color3.fromRGB(255, 50, 50),
    TeamColor = Color3.fromRGB(50, 255, 50),
    ESPFont = Enum.Font.GothamBold
}

local CurrentTarget = nil
local wasNoclip = false
local OriginalC0s = {}

local OriginalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    TimeOfDay = Lighting.TimeOfDay,
    GlobalShadows = Lighting.GlobalShadows
}

local cfgName = "onehvh_universal_v1.json"

local function SaveConfig()
    if not writefile then return end
    local save = {}
    for k, v in pairs(Settings) do
        if typeof(v) == "EnumItem" then save[k] = {t = "Enum", e = tostring(v.EnumType), n = v.Name}
        elseif typeof(v) == "Color3" then save[k] = {t = "Col", r = v.R, g = v.G, b = v.B}
        else save[k] = v end
    end
    pcall(function() writefile(cfgName, HttpService:JSONEncode(save)) end)
end

local function LoadConfig()
    if not (isfile and isfile(cfgName) and readfile) then return end
    local success, res = pcall(function() return HttpService:JSONDecode(readfile(cfgName)) end)
    if success and type(res) == "table" then
        for k, v in pairs(res) do
            if type(v) == "table" then
                if v.t == "Enum" then pcall(function() Settings[k] = Enum[v.e][v.n] end)
                elseif v.t == "Key" then pcall(function() Settings[k] = Enum.KeyCode[v.n] end)
                elseif v.t == "Col" then Settings[k] = Color3.new(v.r, v.g, v.b) end
            elseif Settings[k] ~= nil then Settings[k] = v end
        end
    end
end
LoadConfig()

local function Tween(obj, props, time, style) 
    TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() 
end

local ThemedToggles = {}
local ThemedFills = {}
local ThemedTexts = {}
local ThemedBGs = {}

local function GetThemeColor()
    return Color3.fromRGB(Settings.UIColorR, Settings.UIColorG, Settings.UIColorB)
end

local Tabs = {}
local Pages = {}
local WMStroke, MStroke, WMText, Logo

local function UpdateTheme()
    local c = GetThemeColor()
    if WMStroke then WMStroke.Color = c end
    if MStroke then MStroke.Color = c end
    if Logo then Logo.Text = "<font color='#FFFFFF'>one.</font><font color='#" .. c:ToHex() .. "'>hvh</font>" end
    
    for _, p in pairs(Pages) do p.ScrollBarImageColor3 = c end
    for n, b in pairs(Tabs) do if Settings.CurrentTab == n then b.BackgroundColor3 = c end end
    for _, t in ipairs(ThemedToggles) do if Settings[t.Key] then t.Bg.BackgroundColor3 = c end end
    for _, f in ipairs(ThemedFills) do f.BackgroundColor3 = c end
    for _, t in ipairs(ThemedTexts) do t.TextColor3 = c end
    for _, bg in ipairs(ThemedBGs) do bg.BackgroundColor3 = c end
end

local HUD = Instance.new("ScreenGui")
HUD.Name = "onehvh_HUD"
HUD.Parent = CoreGui
HUD.ResetOnSpawn = false

local FOVCircle = Instance.new("Frame")
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.Parent = HUD

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.5
FOVStroke.Parent = FOVCircle

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local Watermark = Instance.new("Frame")
Watermark.Position = UDim2.new(0, 15, 0, 15)
Watermark.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Watermark.BackgroundTransparency = 0.4
Watermark.Parent = HUD

local WMCorner = Instance.new("UICorner")
WMCorner.CornerRadius = UDim.new(0, 6)
WMCorner.Parent = Watermark

WMStroke = Instance.new("UIStroke")
WMStroke.Color = GetThemeColor()
WMStroke.Transparency = 0.5
WMStroke.Thickness = 1
WMStroke.Parent = Watermark

WMText = Instance.new("TextLabel")
WMText.Size = UDim2.new(1, -16, 1, 0)
WMText.Position = UDim2.new(0, 8, 0, 0)
WMText.BackgroundTransparency = 1
WMText.TextColor3 = Color3.fromRGB(255, 255, 255)
WMText.Font = Enum.Font.GothamMedium
WMText.TextSize = 13
WMText.TextXAlignment = Enum.TextXAlignment.Left
WMText.RichText = true
WMText.Parent = Watermark

local SG = Instance.new("ScreenGui")
SG.Name = "onehvh_Hub"
SG.Parent = CoreGui
SG.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 640, 0, 480)
Main.Position = UDim2.new(0.5, -320, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BackgroundTransparency = 0.3
Main.Active = true
Main.Draggable = true
Main.Parent = SG

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

MStroke = Instance.new("UIStroke")
MStroke.Color = GetThemeColor()
MStroke.Transparency = 0.7
MStroke.Thickness = 1.5
MStroke.Parent = Main

local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 60, 1, 60)
Shadow.Position = UDim2.new(0, -30, 0, -30)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.4
Shadow.ZIndex = -1
Shadow.Parent = Main

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 170, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Sidebar.BackgroundTransparency = 0.4
Sidebar.Parent = Main

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 70)
Logo.Position = UDim2.new(0, 20, 0, 10)
Logo.RichText = true
Logo.Text = "<font color='#FFFFFF'>one.</font><font color='#" .. GetThemeColor():ToHex() .. "'>hvh</font>"
Logo.TextSize = 32
Logo.Font = Enum.Font.GothamBold
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.BackgroundTransparency = 1
Logo.Parent = Sidebar

local TabCont = Instance.new("Frame")
TabCont.Size = UDim2.new(1, -20, 1, -90)
TabCont.Position = UDim2.new(0, 10, 0, 80)
TabCont.BackgroundTransparency = 1
TabCont.Parent = Sidebar

local TList = Instance.new("UIListLayout")
TList.Padding = UDim.new(0, 8)
TList.Parent = TabCont

local PageCont = Instance.new("Frame")
PageCont.Size = UDim2.new(1, -190, 1, -30)
PageCont.Position = UDim2.new(0, 180, 0, 15)
PageCont.BackgroundTransparency = 1
PageCont.Parent = Main

local function CreatePage(name)
    local P = Instance.new("ScrollingFrame")
    P.Size = UDim2.new(1, 0, 1, 0)
    P.BackgroundTransparency = 1
    P.Visible = false
    P.ScrollBarThickness = 2
    P.ScrollBarImageColor3 = GetThemeColor()
    P.AutomaticCanvasSize = Enum.AutomaticSize.Y
    P.Parent = PageCont

    local L = Instance.new("UIListLayout")
    L.Padding = UDim.new(0, 10)
    L.Parent = P

    local Pad = Instance.new("UIPadding")
    Pad.PaddingTop = UDim.new(0, 2)
    Pad.PaddingRight = UDim.new(0, 5)
    Pad.Parent = P

    Pages[name] = P
    return P
end

local function SwitchTab(name)
    Settings.CurrentTab = name
    for n, p in pairs(Pages) do
        p.Visible = (n == name)
        if p.Visible then 
            p.CanvasPosition = Vector2.new(0,0)
            for _, child in ipairs(p:GetChildren()) do
                if child:IsA("Frame") then 
                    local orig = child.Position
                    child.Position = child.Position + UDim2.new(0, 20, 0, 0)
                    child.BackgroundTransparency = 1
                    Tween(child, {Position = orig, BackgroundTransparency = 0.6}, 0.4, Enum.EasingStyle.Cubic) 
                end
            end
        end
    end
    for n, b in pairs(Tabs) do
        local sel = (n == name)
        Tween(b, {BackgroundColor3 = sel and GetThemeColor() or Color3.fromRGB(20, 20, 25), BackgroundTransparency = sel and 0.6 or 1}, 0.2)
        Tween(b.TextLabel, {TextColor3 = sel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 130, 130)}, 0.2)
    end
end

local function CreateTab(name)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 38)
    B.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    B.BackgroundTransparency = 1
    B.Text = ""
    B.Parent = TabCont

    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 8)
    BCorner.Parent = B

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -15, 1, 0)
    L.Position = UDim2.new(0, 15, 0, 0)
    L.Text = name
    L.TextColor3 = Color3.fromRGB(130, 130, 130)
    L.Font = Enum.Font.GothamMedium
    L.TextSize = 14
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1
    L.Parent = B

    B.MouseButton1Click:Connect(function() SwitchTab(name) end)
    B.MouseEnter:Connect(function() if Settings.CurrentTab ~= name then Tween(L, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.1) end end)
    B.MouseLeave:Connect(function() if Settings.CurrentTab ~= name then Tween(L, {TextColor3 = Color3.fromRGB(130, 130, 130)}, 0.1) end end)
    Tabs[name] = B
end

local function CreateToggle(parent, text, key)
    local bindKey = key .. "Bind"
    if Settings[bindKey] == nil then Settings[bindKey] = Enum.KeyCode.Unknown end

    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, -5, 0, 46)
    F.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    F.BackgroundTransparency = 0.6
    F.Parent = parent

    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(0, 8)
    FCorner.Parent = F

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(0.6, 0, 1, 0)
    L.Position = UDim2.new(0, 15, 0, 0)
    L.Text = text
    L.TextColor3 = Color3.fromRGB(230, 230, 230)
    L.Font = Enum.Font.GothamMedium
    L.TextSize = 14
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1
    L.Parent = F

    local Bg = Instance.new("Frame")
    Bg.Size = UDim2.new(0, 42, 0, 22)
    Bg.Position = UDim2.new(1, -55, 0, 12)
    Bg.BackgroundColor3 = Settings[key] and GetThemeColor() or Color3.fromRGB(45, 45, 50)
    Bg.Parent = F
    
    table.insert(ThemedToggles, {Bg = Bg, Key = key})

    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(1, 0)
    BgCorner.Parent = Bg

    local C = Instance.new("Frame")
    C.Size = UDim2.new(0, 18, 0, 18)
    C.Position = Settings[key] and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)
    C.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    C.Parent = Bg

    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(1, 0)
    CCorner.Parent = C

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.ZIndex = 1
    Btn.Parent = F
    
    local function UpdateVis()
        Tween(Bg, {BackgroundColor3 = Settings[key] and GetThemeColor() or Color3.fromRGB(45, 45, 50)}, 0.25)
        Tween(C, {Position = Settings[key] and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)}, 0.3, Enum.EasingStyle.Back)
    end

    Btn.MouseButton1Click:Connect(function() 
        Settings[key] = not Settings[key]
        UpdateVis()
        SaveConfig() 
    end)
end

local function CreateSlider(parent, text, min, max, key)
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, -5, 0, 56)
    F.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    F.BackgroundTransparency = 0.6
    F.Parent = parent

    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(0, 8)
    FCorner.Parent = F

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(0.5, 0, 0, 25)
    L.Position = UDim2.new(0, 15, 0, 5)
    L.Text = text
    L.TextColor3 = Color3.fromRGB(230, 230, 230)
    L.Font = Enum.Font.GothamMedium
    L.TextSize = 14
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1
    L.Parent = F

    local V = Instance.new("TextLabel")
    V.Size = UDim2.new(0.3, 0, 0, 25)
    V.Position = UDim2.new(1, -15, 0, 5)
    V.Text = tostring(Settings[key])
    V.TextColor3 = GetThemeColor()
    V.Font = Enum.Font.GothamBold
    V.TextSize = 14
    V.TextXAlignment = Enum.TextXAlignment.Right
    V.BackgroundTransparency = 1
    V.Parent = F
    
    table.insert(ThemedTexts, V)

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -30, 0, 6)
    Bar.Position = UDim2.new(0, 15, 0, 36)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Bar.Parent = F

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(math.clamp((Settings[key] - min) / (max - min), 0, 1), 0, 1, 0)
    Fill.BackgroundColor3 = GetThemeColor()
    Fill.Parent = Bar
    
    table.insert(ThemedFills, Fill)

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.ZIndex = 2
    Btn.Parent = F

    local drag = false
    Btn.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end 
    end)
    UserInputService.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end 
    end)

    RunService.RenderStepped:Connect(function()
        if drag then
            local p = math.clamp((UserInputService:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Tween(Fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.1, Enum.EasingStyle.Linear)
            local val = math.floor(min + (p * (max - min)))
            if Settings[key] ~= val then
                Settings[key] = val
                V.Text = tostring(val)
                if key == "UIColorR" or key == "UIColorG" or key == "UIColorB" then
                    UpdateTheme()
                end
            end
        end
    end)
end

local function CreateAction(parent, text, cb)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -5, 0, 44)
    B.BackgroundColor3 = GetThemeColor()
    B.BackgroundTransparency = 0.2
    B.Text = text
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Font = Enum.Font.GothamBold
    B.TextSize = 14
    B.Parent = parent
    
    table.insert(ThemedBGs, B)

    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 8)
    BCorner.Parent = B

    B.MouseButton1Click:Connect(function()
        Tween(B, {Size = UDim2.new(1, -11, 0, 40)}, 0.1)
        task.wait(0.1)
        Tween(B, {Size = UDim2.new(1, -5, 0, 44)}, 0.1, Enum.EasingStyle.Back)
        cb()
    end)
end

CreateTab("Combat")
CreateTab("Movement")
CreateTab("Visuals")
CreateTab("World")
CreateTab("Other")

local Cmb = CreatePage("Combat")
local Mov = CreatePage("Movement")
local Esp = CreatePage("Visuals")
local Wld = CreatePage("World")
local Oth = CreatePage("Other")
SwitchTab("Combat")

CreateToggle(Cmb, "Silent Aim", "SilentAim")
CreateToggle(Cmb, "Aimlock (Камера)", "Aimlock")
CreateToggle(Cmb, "Проверка на команду (Team Check)", "TeamCheck")
CreateToggle(Cmb, "Показывать FOV", "DrawFOV")
CreateSlider(Cmb, "Радиус FOV", 10, 800, "FOV")

CreateToggle(Mov, "Бесконечный прыжок", "InfJump")
CreateToggle(Mov, "Noclip (Сквозь стены)", "Noclip")
CreateToggle(Mov, "SpeedHack", "SpeedHack")
CreateSlider(Mov, "Скорость", 16, 250, "WalkSpeed")
CreateToggle(Mov, "JumpHack", "JumpHack")
CreateSlider(Mov, "Прыжок", 50, 300, "JumpPower")

CreateToggle(Esp, "Включить ESP (Подсветка)", "ESP")
CreateToggle(Esp, "Никнеймы", "NamesESP")

CreateToggle(Wld, "Nightmode (Ночь)", "Nightmode")
CreateToggle(Wld, "FullBright (Яркий мир)", "FullBright")
CreateToggle(Wld, "RTX Эффекты (Визуалы)", "RTX")
CreateSlider(Wld, "Цвет Мира (Красный)", 0, 255, "WorldR")
CreateSlider(Wld, "Цвет Мира (Зеленый)", 0, 255, "WorldG")
CreateSlider(Wld, "Цвет Мира (Синий)", 0, 255, "WorldB")

CreateSlider(Wld, "Цвет Меню (Красный)", 0, 255, "UIColorR")
CreateSlider(Wld, "Цвет Меню (Зеленый)", 0, 255, "UIColorG")
CreateSlider(Wld, "Цвет Меню (Синий)", 0, 255, "UIColorB")

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -5, 0, 40)
Info.BackgroundTransparency = 1
Info.Text = "one.hvh Universal\nBased on your custom UI"
Info.TextColor3 = Color3.fromRGB(100, 100, 100)
Info.Font = Enum.Font.Gotham
Info.TextSize = 12
Info.Parent = Oth
CreateAction(Oth, "Сохранить конфиг", function()
    SaveConfig()
    print("Конфиг сохранен!")
end)

local RTX_CC = Instance.new("ColorCorrectionEffect")
RTX_CC.Name = "RTX_ColorCorrection"
RTX_CC.Brightness = 0.05
RTX_CC.Contrast = 0.2
RTX_CC.Saturation = 0.5
RTX_CC.TintColor = Color3.fromRGB(255, 225, 190)
RTX_CC.Enabled = false
RTX_CC.Parent = Lighting

local RTX_Bloom = Instance.new("BloomEffect")
RTX_Bloom.Name = "RTX_Bloom"
RTX_Bloom.Intensity = 0.7
RTX_Bloom.Size = 24
RTX_Bloom.Threshold = 1.2
RTX_Bloom.Enabled = false
RTX_Bloom.Parent = Lighting

local RTX_Sun = Instance.new("SunRaysEffect")
RTX_Sun.Name = "RTX_SunRays"
RTX_Sun.Intensity = 0.15
RTX_Sun.Spread = 0.9
RTX_Sun.Enabled = false
RTX_Sun.Parent = Lighting

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function IsVisible(targetPart)
    local char = LocalPlayer.Character
    if not char or not targetPart then return false end
    rayParams.FilterDescendantsInstances = {char}
    local result = Workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), rayParams)
    return not result or result.Instance:IsDescendantOf(targetPart.Parent)
end

local function GetSmartTarget()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local mPos = UserInputService:GetMouseLocation()
    local tgt = nil
    local minD = math.huge
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") then
            -- Проверка на команду
            if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mPos).Magnitude
                if dist <= Settings.FOV and dist < minD then
                    minD = dist
                    tgt = p
                end
            end
        end
    end
    return tgt
end

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Settings.MenuBind then
        Settings.Visible = not Settings.Visible
        Tween(Main, {Position = Settings.Visible and UDim2.new(0.5, -320, 0.5, -240) or UDim2.new(0.5, -320, 2, 0)}, 0.4, Enum.EasingStyle.Cubic)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Stepped:Connect(function()
    if Settings.Noclip and LocalPlayer.Character then
        wasNoclip = true
        for _, p in pairs(LocalPlayer.Character:GetChildren()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    elseif wasNoclip and LocalPlayer.Character then
        wasNoclip = false
        for _, p in pairs(LocalPlayer.Character:GetChildren()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end)

local function UpdateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local hl = char:FindFirstChild("onehvh_HL")
            
            local isTeammate = (p.Team == LocalPlayer.Team)
            local color = isTeammate and Settings.TeamColor or Settings.EnemyColor
            
            if Settings.ESP then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "onehvh_HL"
                    hl.FillTransparency = 0.6
                    hl.OutlineTransparency = 0.1
                    hl.Parent = char
                end
                hl.FillColor = color
                hl.OutlineColor = color
            elseif hl then
                hl:Destroy()
            end

            local head = char:FindFirstChild("Head")
            if head then
                local bg = head:FindFirstChild("onehvh_Name")
                if Settings.ESP and Settings.NamesESP then
                    if not bg then
                        bg = Instance.new("BillboardGui")
                        bg.Name = "onehvh_Name"
                        bg.Size = UDim2.new(0, 150, 0, 40)
                        bg.StudsOffset = Vector3.new(0, 2.5, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = head
                        
                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.TextStrokeTransparency = 0.3
                        txt.Font = Settings.ESPFont
                        txt.TextSize = 13
                        txt.Parent = bg
                    end
                    bg.TextLabel.Text = p.Name
                    bg.TextLabel.TextColor3 = color
                elseif bg then
                    bg:Destroy()
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    UpdateESP()
    local thm = GetThemeColor()
    WMText.Text = "<font color='#" .. thm:ToHex() .. "'>one.hvh</font> Universal | " .. LocalPlayer.Name
    Watermark.Size = UDim2.new(0, WMText.TextBounds.X + 16, 0, 26)

    if Settings.DrawFOV then
        local mPos = UserInputService:GetMouseLocation()
        FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
        FOVCircle.Position = UDim2.new(0, mPos.X - Settings.FOV, 0, mPos.Y - Settings.FOV)
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    if Settings.Nightmode then
        Lighting.TimeOfDay = "00:00:00"
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    elseif Settings.FullBright then
        Lighting.TimeOfDay = "12:00:00"
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.TimeOfDay = OriginalLighting.TimeOfDay
        local customColor = Color3.fromRGB(Settings.WorldR, Settings.WorldG, Settings.WorldB)
        Lighting.Ambient = customColor
        Lighting.OutdoorAmbient = customColor
    end
    
    RTX_CC.Enabled = Settings.RTX
    RTX_Bloom.Enabled = Settings.RTX
    RTX_Sun.Enabled = Settings.RTX

    CurrentTarget = GetSmartTarget()

    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if Settings.Aimlock and CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, CurrentTarget.Character.HumanoidRootPart.Position)
    end

    if hum then
        if Settings.SpeedHack then 
            hum.WalkSpeed = Settings.WalkSpeed 
        else
            hum.WalkSpeed = 16
        end
        
        if Settings.JumpHack then
            hum.UseJumpPower = true
            hum.JumpPower = Settings.JumpPower
        else
            hum.UseJumpPower = true
            hum.JumpPower = 50
        end
    end
end)

local oldIdx
oldIdx = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and Settings.SilentAim and typeof(self) == "Instance" and self:IsA("PlayerMouse") then
        if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
            if key == "Hit" then return CurrentTarget.Character.HumanoidRootPart.CFrame end
            if key == "Target" then return CurrentTarget.Character.HumanoidRootPart end
        end
    end
    return oldIdx(self, key)
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if not checkcaller() and Settings.SilentAim and CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
        if method == "FireServer" or method == "InvokeServer" then
            local isShoot = string.find(string.lower(self.Name), "shoot") or string.find(string.lower(self.Name), "fire")
            if isShoot or typeof(args[1]) == "Vector3" or typeof(args[2]) == "Vector3" then
                for i, v in ipairs(args) do
                    if typeof(v) == "Vector3" then
                        args[i] = CurrentTarget.Character.HumanoidRootPart.Position
                    end
                end
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)
