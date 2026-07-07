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
    Visible = true,
    CurrentTab = "General",
    MenuBind = Enum.KeyCode.RightControl,

    MenuR = 66, MenuG = 135, MenuB = 245,
    ESPFontSize = 14,
    RTXEnabled = false,
    TimeOfDay = 14,
    MenuFont = Enum.Font.Code,

    SilentAim = false, SilentAimBind = Enum.KeyCode.Unknown,
    NoSpread = false, NoSpreadBind = Enum.KeyCode.Unknown,
    Aimlock = false, AimlockBind = Enum.KeyCode.Unknown,
    AutoShoot = false, AutoShootBind = Enum.KeyCode.Unknown,
    AntiAim = false, AntiAimBind = Enum.KeyCode.Unknown,
    AntiKnife = true,
    DrawFOV = false, DrawFOVBind = Enum.KeyCode.Unknown,
    FOV = 150,
    
    AutoGun = false, AutoGunBind = Enum.KeyCode.Unknown,
    InfJump = false, InfJumpBind = Enum.KeyCode.Unknown,
    Noclip = false, NoclipBind = Enum.KeyCode.Unknown,
    SpeedHack = false, SpeedHackBind = Enum.KeyCode.Unknown,
    WalkSpeed = 25,
    JumpHack = false, JumpHackBind = Enum.KeyCode.Unknown,
    JumpPower = 60,
    Spinbot = false, SpinbotBind = Enum.KeyCode.Unknown,
    SpinSpeed = 30,

    MurdESP = true, MurdESPBind = Enum.KeyCode.Unknown,
    SheriffESP = true, SheriffESPBind = Enum.KeyCode.Unknown,
    InnocentESP = false, InnocentESPBind = Enum.KeyCode.Unknown,
    GunESP = true, GunESPBind = Enum.KeyCode.Unknown,
    NamesESP = true, NamesESPBind = Enum.KeyCode.Unknown,

    Nightmode = false, NightmodeBind = Enum.KeyCode.Unknown,
    FullBright = false, FullBrightBind = Enum.KeyCode.Unknown,
    NoShadows = false, NoShadowsBind = Enum.KeyCode.Unknown,
    WorldR = 255, WorldG = 255, WorldB = 255,

    Fling = false, FlingBind = Enum.KeyCode.Unknown,
    AntiFling = false, AntiFlingBind = Enum.KeyCode.Unknown,
    FlingTarget = "None"
}

local CurrentTarget = nil
local isFlinging = false
local flingReturnPos = nil
local wasNoclip = false

local OriginalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    TimeOfDay = Lighting.TimeOfDay,
    GlobalShadows = Lighting.GlobalShadows
}

local cfgName = "onehvh_config_v2.json"

local function SaveConfig()
    if not writefile then return end
    local save = {}
    for k, v in pairs(Settings) do
        if typeof(v) == "EnumItem" then 
            save[k] = {t = "Enum", e = tostring(v.EnumType), n = v.Name}
        elseif typeof(v) == "Color3" then 
            save[k] = {t = "Col", r = v.R, g = v.G, b = v.B}
        else 
            save[k] = v 
        end
    end
    pcall(function() writefile(cfgName, HttpService:JSONEncode(save)) end)
end

local function LoadConfig()
    if not (isfile and isfile(cfgName) and readfile) then return end
    local success, res = pcall(function() return HttpService:JSONDecode(readfile(cfgName)) end)
    if success and type(res) == "table" then
        for k, v in pairs(res) do
            if type(v) == "table" then
                if v.t == "Enum" then 
                    pcall(function() Settings[k] = Enum[v.e][v.n] end)
                elseif v.t == "Key" then 
                    pcall(function() Settings[k] = Enum.KeyCode[v.n] end)
                elseif v.t == "Col" then 
                    Settings[k] = Color3.new(v.r, v.g, v.b) 
                end
            elseif Settings[k] ~= nil then 
                Settings[k] = v 
            end
        end
    end
end
LoadConfig()

local function Tween(obj, props, time, style) 
    TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() 
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

local WMStroke = Instance.new("UIStroke")
WMStroke.Color = Color3.fromRGB(Settings.MenuR, Settings.MenuG, Settings.MenuB)
WMStroke.Transparency = 0.5
WMStroke.Thickness = 1
WMStroke.Parent = Watermark

local WMText = Instance.new("TextLabel")
WMText.Size = UDim2.new(1, -16, 1, 0)
WMText.Position = UDim2.new(0, 8, 0, 0)
WMText.BackgroundTransparency = 1
WMText.TextColor3 = Color3.fromRGB(255, 255, 255)
WMText.Font = Enum.Font.GothamMedium
WMText.TextSize = 13
WMText.TextXAlignment = Enum.TextXAlignment.Left
WMText.RichText = true
WMText.Text = "one.hvh v2.0"
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

local MStroke = Instance.new("UIStroke")
MStroke.Color = Color3.fromRGB(Settings.MenuR, Settings.MenuG, Settings.MenuB)
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

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 70)
Logo.Position = UDim2.new(0, 20, 0, 10)
Logo.RichText = true
Logo.Text = "<font color='#FFFFFF'>one.</font><font color='#4287f5'>hvh</font>"
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

local Pages = {}
local Tabs = {}

local function UpdateMenuColors()
    local c = Color3.fromRGB(Settings.MenuR, Settings.MenuG, Settings.MenuB)
    MStroke.Color = c
    WMStroke.Color = c
    for n, b in pairs(Tabs) do
        if Settings.CurrentTab == n then
            b.BackgroundColor3 = c
        end
    end
end

local function CreatePage(name)
    local P = Instance.new("ScrollingFrame")
    P.Size = UDim2.new(1, 0, 1, 0)
    P.BackgroundTransparency = 1
    P.Visible = false
    P.ScrollBarThickness = 2
    P.ScrollBarImageColor3 = Color3.fromRGB(Settings.MenuR, Settings.MenuG, Settings.MenuB)
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
    local c = Color3.fromRGB(Settings.MenuR, Settings.MenuG, Settings.MenuB)
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
        Tween(b, {BackgroundColor3 = sel and c or Color3.fromRGB(20, 20, 25), BackgroundTransparency = sel and 0.6 or 1}, 0.2)
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

    local S = Instance.new("UIStroke")
    S.Color = Color3.fromRGB(255, 255, 255)
    S.Transparency = 0.9
    S.Parent = F

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
    Bg.BackgroundColor3 = Settings[key] and Color3.fromRGB(Settings.MenuR, Settings.MenuG, Settings.MenuB) or Color3.fromRGB(45, 45, 50)
    Bg.Parent = F

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

    local currentBind = Settings[bindKey]
    local bindName = currentBind == Enum.KeyCode.Unknown and "[None]" or "[" .. currentBind.Name .. "]"

    local BBg = Instance.new("TextButton")
    BBg.Size = UDim2.new(0, 45, 0, 20)
    BBg.Position = UDim2.new(1, -110, 0, 13)
    BBg.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    BBg.Text = bindName
    BBg.TextColor3 = Color3.fromRGB(150, 150, 150)
    BBg.Font = Enum.Font.Gotham
    BBg.TextSize = 11
    BBg.ZIndex = 2
    BBg.Parent = F

    local BBgCorner = Instance.new("UICorner")
    BBgCorner.CornerRadius = UDim.new(0, 4)
    BBgCorner.Parent = BBg

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.ZIndex = 1
    Btn.Parent = F
    
    local function UpdateVis()
        Tween(Bg, {BackgroundColor3 = Settings[key] and Color3.fromRGB(Settings.MenuR, Settings.MenuG, Settings.MenuB) or Color3.fromRGB(45, 45, 50)}, 0.25)
        Tween(C, {Position = Settings[key] and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)}, 0.3, Enum.EasingStyle.Back)
    end

    Btn.MouseButton1Click:Connect(function() 
        Settings[key] = not Settings[key]
        UpdateVis()
        SaveConfig() 
    end)
    Btn.MouseEnter:Connect(function() Tween(S, {Transparency = 0.7}, 0.2) end)
    Btn.MouseLeave:Connect(function() Tween(S, {Transparency = 0.9}, 0.2) end)
    
    local waitB = false
    BBg.MouseButton1Click:Connect(function() 
        waitB = true
        BBg.Text = "..." 
    end)

    UserInputService.InputBegan:Connect(function(inp)
        if waitB and inp.UserInputType == Enum.UserInputType.Keyboard then
            local k = inp.KeyCode
            if k == Enum.KeyCode.Escape or k == Enum.KeyCode.Backspace then 
                k = Enum.KeyCode.Unknown 
            end
            Settings[bindKey] = k
            BBg.Text = k == Enum.KeyCode.Unknown and "[None]" or "[" .. k.Name .. "]"
            waitB = false
            SaveConfig()
        elseif not waitB and inp.KeyCode == Settings[bindKey] and Settings[bindKey] ~= Enum.KeyCode.Unknown then
            Settings[key] = not Settings[key]
            UpdateVis()
        end
    end)
end

local function CreateSlider(parent, text, min, max, key)
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, -5, 0, 50)
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
    V.Position = UDim2.new(1, -45, 0, 5)
    V.Text = tostring(Settings[key])
    V.TextColor3 = Color3.fromRGB(255, 255, 255)
    V.Font = Enum.Font.Gotham
    V.TextSize = 13
    V.TextXAlignment = Enum.TextXAlignment.Right
    V.BackgroundTransparency = 1
    V.Parent = F

    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -30, 0, 6)
    SliderBg.Position = UDim2.new(0, 15, 0, 35)
    SliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    SliderBg.Parent = F

    local SliderBgCorner = Instance.new("UICorner")
    SliderBgCorner.CornerRadius = UDim.new(1, 0)
    SliderBgCorner.Parent = SliderBg

    local SliderFill = Instance.new("Frame")
    local pct = (Settings[key] - min) / (max - min)
    SliderFill.Size = UDim2.new(pct, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(Settings.MenuR, Settings.MenuG, Settings.MenuB)
    SliderFill.Parent = SliderBg

    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(1, 0)
    SliderFillCorner.Parent = SliderFill

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = SliderBg

    local isDragging = false
    Btn.MouseButton1Down:Connect(function() isDragging = true end)
    UserInputService.InputEnded:Connect(function(inp) 
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end 
    end)
    
    UserInputService.InputChanged:Connect(function(inp)
        if isDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation().X
            local rel = math.clamp((mousePos - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            SliderFill.Size = UDim2.new(rel, 0, 1, 0)
            local val = math.floor(min + (max - min) * rel)
            Settings[key] = val
            V.Text = tostring(val)
            if key == "MenuR" or key == "MenuG" or key == "MenuB" then
                UpdateMenuColors()
                SliderFill.BackgroundColor3 = Color3.fromRGB(Settings.MenuR, Settings.MenuG, Settings.MenuB)
            end
            SaveConfig()
        end
    end)
end

local function CreateAction(parent, text, cb)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -5, 0, 40)
    B.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    B.BackgroundTransparency = 0.6
    B.Text = text
    B.TextColor3 = Color3.fromRGB(230, 230, 230)
    B.Font = Enum.Font.GothamMedium
    B.TextSize = 14
    B.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = B
    B.MouseButton1Click:Connect(cb)
end

local Gen = CreatePage("General")
local Esp = CreatePage("Visuals")
local Wrd = CreatePage("World & Settings")
local Oth = CreatePage("Misc")

CreateTab("General")
CreateTab("Visuals")
CreateTab("World & Settings")
CreateTab("Misc")

CreateToggle(Gen, "Silent Aim", "SilentAim")
CreateSlider(Gen, "Silent Aim (FOV)", 0, 800, "FOV")
CreateToggle(Gen, "Anti-Aim", "AntiAim")
CreateToggle(Gen, "Anti-Knife", "AntiKnife")
CreateToggle(Gen, "Авто-подбор оружия", "AutoGun")
CreateToggle(Gen, "Бесконечный прыжок", "InfJump")
CreateToggle(Gen, "Noclip", "Noclip")
CreateToggle(Gen, "SpeedHack", "SpeedHack")
CreateSlider(Gen, "Скорость", 16, 150, "WalkSpeed")
CreateToggle(Gen, "JumpHack", "JumpHack")
CreateSlider(Gen, "Прыжок", 50, 200, "JumpPower")
CreateToggle(Gen, "Spinbot", "Spinbot")
CreateSlider(Gen, "Скорость вращения", 10, 150, "SpinSpeed")

CreateToggle(Esp, "Убийца (Murderer)", "MurdESP")
CreateToggle(Esp, "Шериф (Sheriff)", "SheriffESP")
CreateToggle(Esp, "Мирные (Innocent)", "InnocentESP")
CreateToggle(Esp, "Оружие (Gun)", "GunESP")

CreateToggle(Wrd, "RTX Visuals", "RTXEnabled")
CreateSlider(Wrd, "Время суток", 0, 24, "TimeOfDay")
CreateToggle(Wrd, "Убрать тени", "NoShadows")
CreateSlider(Wrd, "Цвет Меню: Красный", 0, 255, "MenuR")
CreateSlider(Wrd, "Цвет Меню: Зеленый", 0, 255, "MenuG")
CreateSlider(Wrd, "Цвет Меню: Синий", 0, 255, "MenuB")
CreateSlider(Wrd, "Размер шрифта ESP", 8, 32, "ESPFontSize")

CreateAction(Wrd, "Применить RTX", function()
    if Settings.RTXEnabled then
        Lighting.GlobalShadows = true
        Lighting.Technology = Enum.Technology.Future
        Lighting.Ambient = Color3.fromRGB(50, 50, 50)
        Lighting.Brightness = 3
        Lighting.ExposureCompensation = 0.5
        Lighting.ClockTime = Settings.TimeOfDay

        if not Lighting:FindFirstChild("RTX_ColorCorrection") then
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "RTX_ColorCorrection"
            cc.Brightness = 0.1
            cc.Contrast = 0.25
            cc.Saturation = 0.35
            cc.TintColor = Color3.fromRGB(255, 248, 235)
            cc.Parent = Lighting
        end
        if not Lighting:FindFirstChild("RTX_Bloom") then
            local bloom = Instance.new("BloomEffect")
            bloom.Name = "RTX_Bloom"
            bloom.Intensity = 0.9
            bloom.Size = 26
            bloom.Threshold = 1.2
            bloom.Parent = Lighting
        end
        if not Lighting:FindFirstChild("RTX_SunRays") then
            local sun = Instance.new("SunRaysEffect")
            sun.Name = "RTX_SunRays"
            sun.Intensity = 0.08
            sun.Spread = 0.9
            sun.Parent = Lighting
        end
        if not Lighting:FindFirstChild("RTX_Atmosphere") then
            local atm = Instance.new("Atmosphere")
            atm.Name = "RTX_Atmosphere"
            atm.Density = 0.3
            atm.Offset = 0.25
            atm.Color = Color3.fromRGB(199, 199, 199)
            atm.Decay = Color3.fromRGB(106, 112, 125)
            atm.Glare = 0
            atm.Haze = 0
            atm.Parent = Lighting
        end
    else
        if Lighting:FindFirstChild("RTX_ColorCorrection") then Lighting.RTX_ColorCorrection:Destroy() end
        if Lighting:FindFirstChild("RTX_Bloom") then Lighting.RTX_Bloom:Destroy() end
        if Lighting:FindFirstChild("RTX_SunRays") then Lighting.RTX_SunRays:Destroy() end
        if Lighting:FindFirstChild("RTX_Atmosphere") then Lighting.RTX_Atmosphere:Destroy() end
        Lighting.Technology = Enum.Technology.ShadowMap
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.Brightness = 1
        Lighting.ExposureCompensation = 0
        Lighting.ClockTime = Settings.TimeOfDay
    end
end)

SwitchTab("General")
UpdateMenuColors()

UserInputService.InputBegan:Connect(function(inp, proc)
    if not proc and inp.KeyCode == Settings.MenuBind then
        Settings.Visible = not Settings.Visible
        Main.Visible = Settings.Visible
    end
end)

local function getClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = Settings.FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if magnitude < shortestDistance then
                    closestPlayer = player
                    shortestDistance = magnitude
                end
            end
        end
    end
    return closestPlayer
end

local gm = getrawmetatable(game)
setreadonly(gm, false)
local oldNamecall = gm.__namecall
gm.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if Settings.SilentAim and not checkcaller() then
        if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "Raycast" then
            local target = getClosestPlayerToCursor()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local origin = typeof(args[1]) == "Ray" and args[1].Origin or args[1]
                local direction = (target.Character.HumanoidRootPart.Position - origin).Unit * 1000
                
                if method == "Raycast" then
                    args[2] = direction
                else
                    args[1] = Ray.new(origin, direction)
                end
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)
setreadonly(gm, true)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    
    if not hrp or not humanoid or humanoid.Health <= 0 then return end
    
    if Settings.AntiKnife then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local isDanger = false
                if p.Character:FindFirstChild("Knife") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife")) then
                    isDanger = true
                end
                
                if isDanger then
                    local targetHrp = p.Character.HumanoidRootPart
                    local distance = (hrp.Position - targetHrp.Position).Magnitude
                    
                    if distance < 15 then
                        local moveDir = (hrp.Position - targetHrp.Position).Unit
                        hrp.CFrame = CFrame.new(hrp.Position + Vector3.new(moveDir.X * 18, 0, moveDir.Z * 18), hrp.Position + moveDir * 36)
                    end
                end
            end
        end
    end

    if Settings.AntiAim then
        local rootJoint = hrp.Parent:FindFirstChild("LowerTorso") and hrp.Parent.LowerTorso:FindFirstChild("Root") or hrp.Parent:FindFirstChild("HumanoidRootPart") and hrp.Parent.HumanoidRootPart:FindFirstChild("RootJoint")
        if rootJoint then
            local fakePitch = math.rad(-85)
            local randomYaw = math.rad(math.random(-180, 180))
            rootJoint.C0 = CFrame.new(rootJoint.C0.Position) * CFrame.Angles(fakePitch, randomYaw, 0)
            
            local jitterOffset = Vector3.new(math.random(-25, 25) / 10, 0, math.random(-25, 25) / 10)
            hrp.CFrame = hrp.CFrame + jitterOffset
            hrp.AssemblyLinearVelocity = Vector3.new(math.random(-50, 50), hrp.AssemblyLinearVelocity.Y, math.random(-50, 50))
        end
    end
    
    if Settings.Spinbot then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Settings.SpinSpeed), 0)
    end
    
    if Settings.DrawFOV then
        FOVCircle.Visible = true
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = UDim2.new(0, mousePos.X - Settings.FOV, 0, mousePos.Y - Settings.FOV)
        FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
    else
        FOVCircle.Visible = false
    end
end)

RunService.Stepped:Connect(function()
    if Settings.Noclip and LocalPlayer.Character then
        wasNoclip = true
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    elseif wasNoclip and LocalPlayer.Character then
        wasNoclip = false
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name == "HumanoidRootPart" or v.Name == "UpperTorso" or v.Name == "LowerTorso" or v.Name == "Head") then
                v.CanCollide = true
            end
        end
    end
    
    if Settings.SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
    end
    if Settings.JumpHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = Settings.JumpPower
    end
end)
