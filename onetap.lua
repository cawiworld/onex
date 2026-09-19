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

if CoreGui:FindFirstChild("onehvh_Hub") then CoreGui.onehvh_Hub:Destroy() end
if CoreGui:FindFirstChild("onehvh_HUD") then CoreGui.onehvh_HUD:Destroy() end

local Settings = {
    Visible = true,
    CurrentTab = "Combat",
    MenuBind = Enum.KeyCode.RightControl,

    SilentAim = false, SilentAimBind = Enum.KeyCode.Unknown,
    Aimlock = false, AimlockBind = Enum.KeyCode.Unknown,
    VisibleOnly = true, VisibleOnlyBind = Enum.KeyCode.Unknown,
    Triggerbot = false, TriggerbotBind = Enum.KeyCode.Unknown,
    Spinbot = false, SpinbotBind = Enum.KeyCode.Unknown, SpinSpeed = 35,
    AntiAim = false, AntiAimBind = Enum.KeyCode.Unknown,
    Autoscope = false, AutoscopeBind = Enum.KeyCode.Unknown,
    DrawFOV = false, DrawFOVBind = Enum.KeyCode.Unknown,
    FOV = 120,

    SlowWalk = false, SlowWalkBind = Enum.KeyCode.LeftShift, SlowWalkSpeed = 8,

    PlayerESP = true, PlayerESPBind = Enum.KeyCode.Unknown,
    NameESP = true, NameESPBind = Enum.KeyCode.Unknown,
    EnemyColorR = 255, EnemyColorG = 50, EnemyColorB = 50,
    PriorityColorR = 255, PriorityColorG = 215, PriorityColorB = 0,
    PriorityPlayers = {},

    Nightmode = false, NightmodeBind = Enum.KeyCode.Unknown,
    Fullbright = false, FullbrightBind = Enum.KeyCode.Unknown,
    NoShadows = false, NoShadowsBind = Enum.KeyCode.Unknown,
    RTX = false, RTXBind = Enum.KeyCode.Unknown,
    WorldR = 255, WorldG = 255, WorldB = 255,

    UIColorR = 66, UIColorG = 135, UIColorB = 245
}

local CurrentTarget = nil
local isSlowWalkActive = false
local isScoping = false
local triggerDebounce = false

local OriginalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    TimeOfDay = Lighting.TimeOfDay,
    GlobalShadows = Lighting.GlobalShadows
}

local cfgName = "onehvh_onetap_cfg.json"

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
                if v.t == "Enum" then pcall(function() Settings[k] = Enum[v.e][v.n] end)
                elseif v.t == "Col" then Settings[k] = Color3.new(v.r, v.g, v.b) end
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

local ThemedToggles, ThemedFills, ThemedTexts, ThemedBGs = {}, {}, {}, {}
local Tabs, Pages = {}, {}
local WMStroke, MStroke, WMText, Logo

local function GetThemeColor()
    return Color3.fromRGB(Settings.UIColorR, Settings.UIColorG, Settings.UIColorB)
end

local function GetEnemyColor()
    return Color3.fromRGB(Settings.EnemyColorR, Settings.EnemyColorG, Settings.EnemyColorB)
end

local function GetPriorityColor()
    return Color3.fromRGB(Settings.PriorityColorR, Settings.PriorityColorG, Settings.PriorityColorB)
end

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
FOVStroke.Transparency = 0.4
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
WMText.Font = Enum.Font.SourceSansBold
WMText.TextSize = 14
WMText.TextXAlignment = Enum.TextXAlignment.Left
WMText.RichText = true
WMText.Parent = Watermark

local HUDCont = Instance.new("Frame")
HUDCont.Size = UDim2.new(0, 220, 1, -20)
HUDCont.Position = UDim2.new(1, -230, 0, 0)
HUDCont.BackgroundTransparency = 1
HUDCont.Parent = HUD

local HList = Instance.new("UIListLayout")
HList.VerticalAlignment = Enum.VerticalAlignment.Bottom
HList.Padding = UDim.new(0, 4)
HList.Parent = HUDCont

local function UpdateHUD()
    for _, c in pairs(HUDCont:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    local bindsMap = {
        Aimlock = "Aimlock", SilentAim = "Silent Aim", Triggerbot = "Triggerbot",
        Autoscope = "Autoscope", SlowWalk = "Slow Walk"
    }
    for k, name in pairs(bindsMap) do
        if Settings[k] then
            local L = Instance.new("TextLabel")
            L.Size = UDim2.new(1, 0, 0, 18)
            L.BackgroundTransparency = 1
            L.Text = name .. " [ON]"
            L.TextColor3 = GetThemeColor()
            L.Font = Enum.Font.SourceSansBold
            L.TextSize = 14
            L.TextXAlignment = Enum.TextXAlignment.Right
            L.TextStrokeTransparency = 0.3
            L.Parent = HUDCont
        end
    end
end

local SG = Instance.new("ScreenGui")
SG.Name = "onehvh_Hub"
SG.Parent = CoreGui
SG.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 620, 0, 450)
Main.Position = UDim2.new(0.5, -310, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BackgroundTransparency = 0.25
Main.Active = true
Main.Draggable = true
Main.Parent = SG

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

MStroke = Instance.new("UIStroke")
MStroke.Color = GetThemeColor()
MStroke.Transparency = 0.6
MStroke.Thickness = 1.5
MStroke.Parent = Main

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Sidebar.BackgroundTransparency = 0.3
Sidebar.Parent = Main

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 60)
Logo.Position = UDim2.new(0, 15, 0, 10)
Logo.RichText = true
Logo.Text = "<font color='#FFFFFF'>one.</font><font color='#" .. GetThemeColor():ToHex() .. "'>hvh</font>"
Logo.TextSize = 28
Logo.Font = Enum.Font.SourceSansBold
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.BackgroundTransparency = 1
Logo.Parent = Sidebar

local TabCont = Instance.new("Frame")
TabCont.Size = UDim2.new(1, -20, 1, -80)
TabCont.Position = UDim2.new(0, 10, 0, 70)
TabCont.BackgroundTransparency = 1
TabCont.Parent = Sidebar

local TList = Instance.new("UIListLayout")
TList.Padding = UDim.new(0, 6)
TList.Parent = TabCont

local PageCont = Instance.new("Frame")
PageCont.Size = UDim2.new(1, -180, 1, -20)
PageCont.Position = UDim2.new(0, 170, 0, 10)
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
    L.Padding = UDim.new(0, 8)
    L.Parent = P

    local Pad = Instance.new("UIPadding")
    Pad.PaddingTop = UDim.new(0, 2)
    Pad.PaddingRight = UDim.new(0, 6)
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
                    child.Position = child.Position + UDim2.new(0, 12, 0, 0)
                    child.BackgroundTransparency = 1
                    Tween(child, {Position = orig, BackgroundTransparency = 0.5}, 0.25, Enum.EasingStyle.Cubic) 
                end
            end
        end
    end
    for n, b in pairs(Tabs) do
        local sel = (n == name)
        Tween(b, {BackgroundColor3 = sel and GetThemeColor() or Color3.fromRGB(20, 20, 25), BackgroundTransparency = sel and 0.5 or 1}, 0.2)
        Tween(b.TextLabel, {TextColor3 = sel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)}, 0.2)
    end
end

local function CreateTab(name)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 34)
    B.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    B.BackgroundTransparency = 1
    B.Text = ""
    B.Parent = TabCont

    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 6)
    BCorner.Parent = B

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -15, 1, 0)
    L.Position = UDim2.new(0, 15, 0, 0)
    L.Text = name
    L.TextColor3 = Color3.fromRGB(150, 150, 150)
    L.Font = Enum.Font.SourceSansBold
    L.TextSize = 15
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1
    L.Parent = B

    B.MouseButton1Click:Connect(function() SwitchTab(name) end)
    Tabs[name] = B
end

local function CreateToggle(parent, text, key)
    local bindKey = key .. "Bind"
    if Settings[bindKey] == nil then Settings[bindKey] = Enum.KeyCode.Unknown end

    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, -5, 0, 40)
    F.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    F.BackgroundTransparency = 0.5
    F.Parent = parent

    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(0, 6)
    FCorner.Parent = F

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(0.6, 0, 1, 0)
    L.Position = UDim2.new(0, 12, 0, 0)
    L.Text = text
    L.TextColor3 = Color3.fromRGB(230, 230, 230)
    L.Font = Enum.Font.SourceSansBold
    L.TextSize = 15
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1
    L.Parent = F

    local Bg = Instance.new("Frame")
    Bg.Size = UDim2.new(0, 38, 0, 18)
    Bg.Position = UDim2.new(1, -48, 0, 11)
    Bg.BackgroundColor3 = Settings[key] and GetThemeColor() or Color3.fromRGB(45, 45, 50)
    Bg.Parent = F
    
    table.insert(ThemedToggles, {Bg = Bg, Key = key})

    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(1, 0)
    BgCorner.Parent = Bg

    local C = Instance.new("Frame")
    C.Size = UDim2.new(0, 14, 0, 14)
    C.Position = Settings[key] and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)
    C.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    C.Parent = Bg

    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(1, 0)
    CCorner.Parent = C

    local currentBind = Settings[bindKey]
    local bindName = currentBind == Enum.KeyCode.Unknown and "[-]" or "[" .. currentBind.Name .. "]"

    local BBg = Instance.new("TextButton")
    BBg.Size = UDim2.new(0, 50, 0, 18)
    BBg.Position = UDim2.new(1, -104, 0, 11)
    BBg.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    BBg.Text = bindName
    BBg.TextColor3 = Color3.fromRGB(160, 160, 160)
    BBg.Font = Enum.Font.SourceSans
    BBg.TextSize = 12
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
        Tween(Bg, {BackgroundColor3 = Settings[key] and GetThemeColor() or Color3.fromRGB(45, 45, 50)}, 0.2)
        Tween(C, {Position = Settings[key] and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)}, 0.2, Enum.EasingStyle.Back)
    end

    Btn.MouseButton1Click:Connect(function() 
        Settings[key] = not Settings[key]
        UpdateVis()
        SaveConfig() 
    end)
    
    local waitB = false
    BBg.MouseButton1Click:Connect(function() 
        waitB = true
        BBg.Text = "..." 
    end)

    UserInputService.InputBegan:Connect(function(inp)
        if waitB and inp.UserInputType == Enum.UserInputType.Keyboard then
            local k = inp.KeyCode
            if k == Enum.KeyCode.Escape or k == Enum.KeyCode.Backspace then k = Enum.KeyCode.Unknown end
            Settings[bindKey] = k
            BBg.Text = k == Enum.KeyCode.Unknown and "[-]" or "[" .. k.Name .. "]"
            waitB = false
            SaveConfig()
        elseif not waitB and inp.KeyCode == Settings[bindKey] and Settings[bindKey] ~= Enum.KeyCode.Unknown then
            if key == "SlowWalk" then
                isSlowWalkActive = true
            else
                Settings[key] = not Settings[key]
                UpdateVis()
            end
        end
    end)

    if key == "SlowWalk" then
        UserInputService.InputEnded:Connect(function(inp)
            if inp.KeyCode == Settings[bindKey] and Settings[bindKey] ~= Enum.KeyCode.Unknown then
                isSlowWalkActive = false
            end
        end)
    end
end

local function CreateSlider(parent, text, min, max, key)
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, -5, 0, 48)
    F.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    F.BackgroundTransparency = 0.5
    F.Parent = parent

    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(0, 6)
    FCorner.Parent = F

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(0.5, 0, 0, 20)
    L.Position = UDim2.new(0, 12, 0, 4)
    L.Text = text
    L.TextColor3 = Color3.fromRGB(230, 230, 230)
    L.Font = Enum.Font.SourceSansBold
    L.TextSize = 14
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1
    L.Parent = F

    local V = Instance.new("TextLabel")
    V.Size = UDim2.new(0.3, 0, 0, 20)
    V.Position = UDim2.new(1, -12, 0, 4)
    V.Text = tostring(Settings[key])
    V.TextColor3 = GetThemeColor()
    V.Font = Enum.Font.SourceSansBold
    V.TextSize = 14
    V.TextXAlignment = Enum.TextXAlignment.Right
    V.BackgroundTransparency = 1
    V.Parent = F
    
    table.insert(ThemedTexts, V)

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -24, 0, 5)
    Bar.Position = UDim2.new(0, 12, 0, 30)
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
            Fill.Size = UDim2.new(p, 0, 1, 0)
            local val = math.floor(min + (p * (max - min)))
            if Settings[key] ~= val then
                Settings[key] = val
                V.Text = tostring(val)
                if string.find(key, "UIColor") then
                    UpdateTheme()
                end
            end
        end
    end)
end

local function CreateAction(parent, text, cb)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -5, 0, 36)
    B.BackgroundColor3 = GetThemeColor()
    B.BackgroundTransparency = 0.2
    B.Text = text
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Font = Enum.Font.SourceSansBold
    B.TextSize = 14
    B.Parent = parent
    
    table.insert(ThemedBGs, B)

    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 6)
    BCorner.Parent = B

    B.MouseButton1Click:Connect(cb)
end

local function CreateKeybindSelector(parent, text, currentProp, cb)
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, -5, 0, 40)
    F.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    F.BackgroundTransparency = 0.5
    F.Parent = parent

    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(0, 6)
    FCorner.Parent = F

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(0.6, 0, 1, 0)
    L.Position = UDim2.new(0, 12, 0, 0)
    L.Text = text
    L.TextColor3 = Color3.fromRGB(230, 230, 230)
    L.Font = Enum.Font.SourceSansBold
    L.TextSize = 15
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1
    L.Parent = F

    local B = Instance.new("TextButton")
    B.Size = UDim2.new(0, 80, 0, 24)
    B.Position = UDim2.new(1, -90, 0, 8)
    B.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    B.Text = "[" .. Settings[currentProp].Name .. "]"
    B.TextColor3 = Color3.fromRGB(200, 200, 200)
    B.Font = Enum.Font.SourceSansBold
    B.TextSize = 13
    B.Parent = F

    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 4)
    BCorner.Parent = B

    local waiting = false
    B.MouseButton1Click:Connect(function()
        waiting = true
        B.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(inp)
        if waiting and inp.UserInputType == Enum.UserInputType.Keyboard then
            local k = inp.KeyCode
            if k == Enum.KeyCode.Escape then k = Enum.KeyCode.Unknown end
            Settings[currentProp] = k
            B.Text = "[" .. k.Name .. "]"
            waiting = false
            SaveConfig()
            if cb then cb(k) end
        end
    end)
end

local function CreateInput(parent, placeholder, btnText, cb)
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, -5, 0, 40)
    F.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    F.BackgroundTransparency = 0.5
    F.Parent = parent

    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(0, 6)
    FCorner.Parent = F

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -95, 1, 0)
    Box.Position = UDim2.new(0, 12, 0, 0)
    Box.BackgroundTransparency = 1
    Box.PlaceholderText = placeholder
    Box.Text = ""
    Box.TextColor3 = Color3.fromRGB(240, 240, 240)
    Box.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    Box.Font = Enum.Font.SourceSans
    Box.TextSize = 14
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.ClearTextOnFocus = false
    Box.Parent = F

    local B = Instance.new("TextButton")
    B.Size = UDim2.new(0, 70, 0, 26)
    B.Position = UDim2.new(1, -80, 0, 7)
    B.BackgroundColor3 = GetThemeColor()
    B.Text = btnText
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Font = Enum.Font.SourceSansBold
    B.TextSize = 13
    B.Parent = F
    
    table.insert(ThemedBGs, B)

    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 4)
    BCorner.Parent = B

    B.MouseButton1Click:Connect(function()
        if Box.Text ~= "" then
            cb(Box.Text)
            Box.Text = ""
        end
    end)
end

CreateTab("Combat")
CreateTab("Visuals")
CreateTab("World")
CreateTab("Other")

local Cmb = CreatePage("Combat")
local Esp = CreatePage("Visuals")
local Wld = CreatePage("World")
local Oth = CreatePage("Other")
SwitchTab("Combat")

CreateToggle(Cmb, "Silent Aim", "SilentAim")
CreateToggle(Cmb, "Aimlock", "Aimlock")
CreateToggle(Cmb, "Visible Only", "VisibleOnly")
CreateToggle(Cmb, "Triggerbot", "Triggerbot")
CreateToggle(Cmb, "Autoscope", "Autoscope")
CreateToggle(Cmb, "Slow Walk", "SlowWalk")
CreateSlider(Cmb, "Slow Speed", 3, 14, "SlowWalkSpeed")
CreateToggle(Cmb, "Spinbot", "Spinbot")
CreateSlider(Cmb, "Spin Speed", 5, 100, "SpinSpeed")
CreateToggle(Cmb, "Anti-Aim", "AntiAim")
CreateToggle(Cmb, "Draw FOV", "DrawFOV")
CreateSlider(Cmb, "FOV Radius", 20, 600, "FOV")

CreateToggle(Esp, "Player ESP", "PlayerESP")
CreateToggle(Esp, "Player Names", "NameESP")
CreateSlider(Esp, "Enemy [R]", 0, 255, "EnemyColorR")
CreateSlider(Esp, "Enemy [G]", 0, 255, "EnemyColorG")
CreateSlider(Esp, "Enemy [B]", 0, 255, "EnemyColorB")

CreateSlider(Esp, "Priority [R]", 0, 255, "PriorityColorR")
CreateSlider(Esp, "Priority [G]", 0, 255, "PriorityColorG")
CreateSlider(Esp, "Priority [B]", 0, 255, "PriorityColorB")

local PlrListLabel = Instance.new("TextLabel")
PlrListLabel.Size = UDim2.new(1, -5, 0, 22)
PlrListLabel.BackgroundTransparency = 1
PlrListLabel.Text = "Priority List: (empty)"
PlrListLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
PlrListLabel.Font = Enum.Font.SourceSans
PlrListLabel.TextSize = 13
PlrListLabel.TextXAlignment = Enum.TextXAlignment.Left
PlrListLabel.Parent = Esp

local function RefreshPriorityLabel()
    local names = {}
    for n, _ in pairs(Settings.PriorityPlayers) do table.insert(names, n) end
    if #names == 0 then
        PlrListLabel.Text = "Priority List: (empty)"
    else
        PlrListLabel.Text = "Priority: " .. table.concat(names, ", ")
    end
end

CreateInput(Esp, "Enter username...", "Add", function(name)
    Settings.PriorityPlayers[name] = true
    RefreshPriorityLabel()
    SaveConfig()
end)

CreateAction(Esp, "Clear Priority List", function()
    Settings.PriorityPlayers = {}
    RefreshPriorityLabel()
    SaveConfig()
end)

CreateToggle(Wld, "Nightmode", "Nightmode")
CreateToggle(Wld, "Fullbright", "Fullbright")
CreateToggle(Wld, "No Shadows", "NoShadows")
CreateToggle(Wld, "RTX Visuals", "RTX")
CreateSlider(Wld, "World Ambient [R]", 0, 255, "WorldR")
CreateSlider(Wld, "World Ambient [G]", 0, 255, "WorldG")
CreateSlider(Wld, "World Ambient [B]", 0, 255, "WorldB")

CreateSlider(Wld, "Theme Color [R]", 0, 255, "UIColorR")
CreateSlider(Wld, "Theme Color [G]", 0, 255, "UIColorG")
CreateSlider(Wld, "Theme Color [B]", 0, 255, "UIColorB")

CreateKeybindSelector(Oth, "Menu Toggle Key", "MenuBind")
CreateAction(Oth, "Save Config", function()
    SaveConfig()
end)

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -5, 0, 30)
Info.BackgroundTransparency = 1
Info.Text = "one.hvh | One Tap Edition"
Info.TextColor3 = Color3.fromRGB(120, 120, 120)
Info.Font = Enum.Font.SourceSans
Info.TextSize = 13
Info.Parent = Oth

local RTX_CC = Instance.new("ColorCorrectionEffect", Lighting)
RTX_CC.Brightness = 0.04
RTX_CC.Contrast = 0.2
RTX_CC.Saturation = 0.35
RTX_CC.Enabled = false

local RTX_Bloom = Instance.new("BloomEffect", Lighting)
RTX_Bloom.Intensity = 0.7
RTX_Bloom.Size = 20
RTX_Bloom.Threshold = 1.1
RTX_Bloom.Enabled = false

local RTX_Sun = Instance.new("SunRaysEffect", Lighting)
RTX_Sun.Intensity = 0.12
RTX_Sun.Spread = 0.8
RTX_Sun.Enabled = false

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function GetTargetPart(model)
    if not model or not model:IsA("Model") then return nil end
    local hitbox = model:FindFirstChild("Hitbox")
    if hitbox then
        local headHB = hitbox:FindFirstChild("Hitbox_Head")
        if headHB and headHB:IsA("BasePart") then return headHB end
        local torsoHB = hitbox:FindFirstChild("Hitbox_Torso")
        if torsoHB and torsoHB:IsA("BasePart") then return torsoHB end
    end
    local head = model:FindFirstChild("Head")
    if head and head:IsA("BasePart") then return head end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:IsA("BasePart") then return hrp end
    return nil
end

local function IsAlive(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then
        return hum.Health > 0
    end
    return true
end

local ignoredNames = {
    Camera = true, Terrain = true, Map = true, Lobby = true,
    Weapons = true, Effects = true, SpawnLocation = true,
    Baseplate = true, Guide = true
}

local function GetAllTargets()
    local targets = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character and not ignoredNames[obj.Name] then
            local part = GetTargetPart(obj)
            if part and IsAlive(obj) then
                table.insert(targets, {Model = obj, Part = part, Name = obj.Name})
            end
        end
    end
    return targets
end

local function IsVisible(part, model)
    local char = LocalPlayer.Character
    if not char or not part then return false end
    rayParams.FilterDescendantsInstances = {char, Camera}
    local result = Workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), rayParams)
    return not result or result.Instance:IsDescendantOf(model)
end

local function GetClosestTarget()
    local mPos = UserInputService:GetMouseLocation()
    local tgt = nil
    local minD = math.huge

    for _, entity in ipairs(GetAllTargets()) do
        if Settings.VisibleOnly and not IsVisible(entity.Part, entity.Model) then
            continue
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(entity.Part.Position)
        if onScreen then
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mPos).Magnitude
            if dist <= Settings.FOV and dist < minD then
                minD = dist
                tgt = entity
            end
        end
    end
    return tgt
end

local function HandleTriggerbot()
    if not Settings.Triggerbot or triggerDebounce then return end
    
    local center = Camera.ViewportSize / 2
    local ray = Camera:ViewportPointToRay(center.X, center.Y)
    
    local filterList = {LocalPlayer.Character, Camera}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character and not ignoredNames[obj.Name] then
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("Accessory") then
                    table.insert(filterList, child)
                end
            end
        end
    end
    
    rayParams.FilterDescendantsInstances = filterList
    local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)

    if result and result.Instance then
        local hitInstance = result.Instance
        local hitModel = hitInstance:FindFirstAncestorOfClass("Model")
        
        if hitModel and hitModel ~= LocalPlayer.Character and not ignoredNames[hitModel.Name] then
            local isHitboxPart = hitInstance.Name:find("Hitbox") ~= nil or hitInstance.Name == "Head" or hitInstance.Name == "Torso"
            if isHitboxPart and IsAlive(hitModel) then
                triggerDebounce = true
                if mouse1click then 
                    mouse1click() 
                else 
                    game:GetService("VirtualUser"):ClickButton1(Vector2.new(0, 0))
                end
                task.delay(0.18, function() triggerDebounce = false end)
            end
        end
    end
end

local lastScopeTargetTime = 0

local function HandleAutoscope()
    if not Settings.Autoscope then
        if isScoping then
            if mouse2release then mouse2release() end
            isScoping = false
        end
        return
    end

    if CurrentTarget and CurrentTarget.Part then
        lastScopeTargetTime = os.clock()
        if not isScoping then
            if mouse2press then mouse2press() end
            isScoping = true
        end
    else
        if isScoping and (os.clock() - lastScopeTargetTime > 0.35) then
            if mouse2release then mouse2release() end
            isScoping = false
        end
    end
end

local function UpdateESP()
    local currentEntities = GetAllTargets()
    local aliveSet = {}

    for _, entity in ipairs(currentEntities) do
        aliveSet[entity.Model] = true
        local isPriority = Settings.PriorityPlayers[entity.Name] ~= nil
        local color = isPriority and GetPriorityColor() or GetEnemyColor()
        local shouldShow = Settings.PlayerESP

        local existingDH = entity.Model:FindFirstChild("DeployHighlight")
        if existingDH then 
            existingDH:Destroy() 
        end

        local hl = entity.Model:FindFirstChild("onehvh_HL")
        if shouldShow then
            if not hl then
                hl = Instance.new("Highlight")
                hl.Name = "onehvh_HL"
                hl.FillTransparency = 0.4
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Adornee = entity.Model
                hl.Parent = entity.Model
            end
            hl.FillColor = color
            hl.OutlineColor = color
        elseif hl then
            hl:Destroy()
        end

        local head = entity.Model:FindFirstChild("Head") or entity.Part
        if head then
            local bg = head:FindFirstChild("onehvh_Name")
            if shouldShow and Settings.NameESP then
                if not bg then
                    bg = Instance.new("BillboardGui")
                    bg.Name = "onehvh_Name"
                    bg.Size = UDim2.new(0, 140, 0, 24)
                    bg.StudsOffset = Vector3.new(0, 2.2, 0)
                    bg.AlwaysOnTop = true
                    bg.Adornee = head
                    bg.Parent = head

                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextStrokeTransparency = 0.2
                    txt.Font = Enum.Font.SourceSansBold
                    txt.TextSize = 13
                    txt.Parent = bg
                end
                bg.TextLabel.Text = entity.Name .. (isPriority and " [PRIORITY]" or "")
                bg.TextLabel.TextColor3 = color
            elseif bg then
                bg:Destroy()
            end
        end
    end

    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and not aliveSet[obj] then
            local hl = obj:FindFirstChild("onehvh_HL")
            if hl then hl:Destroy() end
            local head = obj:FindFirstChild("Head")
            if head then
                local bg = head:FindFirstChild("onehvh_Name")
                if bg then bg:Destroy() end
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Settings.MenuBind and Settings.MenuBind ~= Enum.KeyCode.Unknown then
        Settings.Visible = not Settings.Visible
        Tween(Main, {Position = Settings.Visible and UDim2.new(0.5, -310, 0.5, -225) or UDim2.new(0.5, -310, 2, 0)}, 0.35, Enum.EasingStyle.Cubic)
    end
end)

RunService.RenderStepped:Connect(function()
    UpdateHUD()
    UpdateESP()

    local thm = GetThemeColor()
    WMText.Text = "<font color='#" .. thm:ToHex() .. "'>one.hvh</font> One Tap | " .. LocalPlayer.Name .. " | " .. os.date("%H:%M:%S")
    Watermark.Size = UDim2.new(0, WMText.TextBounds.X + 16, 0, 24)

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
        Lighting.Ambient = Color3.fromRGB(10, 10, 15)
        Lighting.OutdoorAmbient = Color3.fromRGB(10, 10, 15)
    elseif Settings.Fullbright then
        Lighting.TimeOfDay = "12:00:00"
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.TimeOfDay = OriginalLighting.TimeOfDay
        local customColor = Color3.fromRGB(Settings.WorldR, Settings.WorldG, Settings.WorldB)
        Lighting.Ambient = customColor
        Lighting.OutdoorAmbient = customColor
    end
    Lighting.GlobalShadows = not Settings.NoShadows

    RTX_CC.Enabled = Settings.RTX
    RTX_Bloom.Enabled = Settings.RTX
    RTX_Sun.Enabled = Settings.RTX

    CurrentTarget = GetClosestTarget()

    if Settings.Aimlock and CurrentTarget and CurrentTarget.Part then
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, CurrentTarget.Part.Position)
    end

    HandleTriggerbot()
    HandleAutoscope()

    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if Settings.Spinbot then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Settings.SpinSpeed), 0)
        end
        
        if Settings.AntiAim then
            local pitchAngle = math.rad(-75)
            local jitterYaw = math.rad(math.random(-180, 180))
            local rootJoint = char:FindFirstChild("LowerTorso") and char.LowerTorso:FindFirstChild("Root") or hrp:FindFirstChild("RootJoint")
            if rootJoint then
                rootJoint.C0 = CFrame.new(rootJoint.C0.Position) * CFrame.Angles(pitchAngle, jitterYaw, 0)
            end
        end
    end

    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if isSlowWalkActive then
                hum.WalkSpeed = Settings.SlowWalkSpeed
            else
                hum.WalkSpeed = 16
            end
        end
    end
end)

local oldIdx
oldIdx = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if not checkcaller() and Settings.SilentAim and typeof(self) == "Instance" and self:IsA("PlayerMouse") then
        if CurrentTarget and CurrentTarget.Part then
            if key == "Hit" then return CurrentTarget.Part.CFrame end
            if key == "Target" then return CurrentTarget.Part end
        end
    end
    return oldIdx(self, key)
end))

local oldRaycast
oldRaycast = hookfunction(workspace.Raycast, newcclosure(function(self, origin, direction, params)
    if not checkcaller() and Settings.SilentAim and CurrentTarget and CurrentTarget.Part then
        local targetPos = CurrentTarget.Part.Position
        local mag = direction.Magnitude
        if mag > 0 then
            direction = (targetPos - origin).Unit * mag
        end
    end
    return oldRaycast(self, origin, direction, params)
end))

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if not checkcaller() and Settings.SilentAim and CurrentTarget and CurrentTarget.Part then
        if (method == "Raycast" or method == "raycast") and self == Workspace then
            local origin = args[1]
            local direction = args[2]
            if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
                local mag = direction.Magnitude
                args[2] = (CurrentTarget.Part.Position - origin).Unit * mag
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end))
