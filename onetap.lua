-- one.hvh - best hvh cheat in roblox community
-- version: 1.01
-- author: relosterpc
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
    AimVisibleOnly = true, AimVisibleOnlyBind = Enum.KeyCode.Unknown,
    Triggerbot = false, TriggerbotBind = Enum.KeyCode.Unknown,
    AutoScope = false, AutoScopeBind = Enum.KeyCode.Unknown,
    DrawFOV = false, DrawFOVBind = Enum.KeyCode.Unknown, 
    FOV = 120,

    SlowWalk = false, SlowWalkBind = Enum.KeyCode.LeftShift, SlowWalkSpeed = 8,
    SpeedHack = false, SpeedHackBind = Enum.KeyCode.Unknown, WalkSpeed = 24,
    JumpHack = false, JumpHackBind = Enum.KeyCode.Unknown, JumpPower = 55,
    InfJump = false, InfJumpBind = Enum.KeyCode.Unknown,
    Noclip = false, NoclipBind = Enum.KeyCode.Unknown,

    AllPlayersESP = true, AllPlayersESPBind = Enum.KeyCode.Unknown,
    NamesESP = true, NamesESPBind = Enum.KeyCode.Unknown,
    EnemyColorR = 255, EnemyColorG = 50, EnemyColorB = 50,
    PriorityColorR = 255, PriorityColorG = 215, PriorityColorB = 0,
    PriorityPlayers = {},

    Nightmode = false, NightmodeBind = Enum.KeyCode.Unknown,
    FullBright = false, FullBrightBind = Enum.KeyCode.Unknown,
    NoShadows = false, NoShadowsBind = Enum.KeyCode.Unknown,
    RTX = false, RTXBind = Enum.KeyCode.Unknown,
    WorldR = 255, WorldG = 255, WorldB = 255,

    UIColorR = 66, UIColorG = 135, UIColorB = 245
}

local CurrentTarget = nil
local wasNoclip = false
local isSlowWalkActive = false
local isScoping = false
local triggerDebounce = false

local OriginalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    TimeOfDay = Lighting.TimeOfDay,
    GlobalShadows = Lighting.GlobalShadows
}

local cfgName = "onehvh_onetap_config.json"

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
WMText.Font = Enum.Font.GothamMedium
WMText.TextSize = 13
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
HList.Padding = UDim.new(0, 5)
HList.Parent = HUDCont

local function UpdateHUD()
    for _, c in pairs(HUDCont:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    local bindsMap = {
        Aimlock = "Aimlock", SilentAim = "Silent Aim", Triggerbot = "Triggerbot",
        AutoScope = "Autoscope", SlowWalk = "Slow Walk", SpeedHack = "Speed",
        JumpHack = "Jump", InfJump = "Inf Jump", Noclip = "Noclip"
    }
    for k, name in pairs(bindsMap) do
        if Settings[k] then
            local L = Instance.new("TextLabel")
            L.Size = UDim2.new(1, 0, 0, 20)
            L.BackgroundTransparency = 1
            L.Text = name .. " [ON]"
            L.TextColor3 = GetThemeColor()
            L.Font = Enum.Font.GothamBold
            L.TextSize = 13
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
Logo.TextSize = 30
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
    L.Padding = UDim.new(0, 8)
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
                    child.Position = child.Position + UDim2.new(0, 15, 0, 0)
                    child.BackgroundTransparency = 1
                    Tween(child, {Position = orig, BackgroundTransparency = 0.6}, 0.35, Enum.EasingStyle.Cubic) 
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
    B.Size = UDim2.new(1, 0, 0, 36)
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
    F.Size = UDim2.new(1, -5, 0, 44)
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
    L.TextSize = 13
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1
    L.Parent = F

    local Bg = Instance.new("Frame")
    Bg.Size = UDim2.new(0, 40, 0, 20)
    Bg.Position = UDim2.new(1, -50, 0, 12)
    Bg.BackgroundColor3 = Settings[key] and GetThemeColor() or Color3.fromRGB(45, 45, 50)
    Bg.Parent = F
    
    table.insert(ThemedToggles, {Bg = Bg, Key = key})

    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(1, 0)
    BgCorner.Parent = Bg

    local C = Instance.new("Frame")
    C.Size = UDim2.new(0, 16, 0, 16)
    C.Position = Settings[key] and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
    C.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    C.Parent = Bg

    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(1, 0)
    CCorner.Parent = C

    local currentBind = Settings[bindKey]
    local bindName = currentBind == Enum.KeyCode.Unknown and "[None]" or "[" .. currentBind.Name .. "]"

    local BBg = Instance.new("TextButton")
    BBg.Size = UDim2.new(0, 48, 0, 20)
    BBg.Position = UDim2.new(1, -105, 0, 12)
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
        Tween(Bg, {BackgroundColor3 = Settings[key] and GetThemeColor() or Color3.fromRGB(45, 45, 50)}, 0.25)
        Tween(C, {Position = Settings[key] and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)}, 0.25, Enum.EasingStyle.Back)
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
            BBg.Text = k == Enum.KeyCode.Unknown and "[None]" or "[" .. k.Name .. "]"
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
    F.Size = UDim2.new(1, -5, 0, 52)
    F.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    F.BackgroundTransparency = 0.6
    F.Parent = parent

    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(0, 8)
    FCorner.Parent = F

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(0.5, 0, 0, 22)
    L.Position = UDim2.new(0, 15, 0, 4)
    L.Text = text
    L.TextColor3 = Color3.fromRGB(230, 230, 230)
    L.Font = Enum.Font.GothamMedium
    L.TextSize = 13
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1
    L.Parent = F

    local V = Instance.new("TextLabel")
    V.Size = UDim2.new(0.3, 0, 0, 22)
    V.Position = UDim2.new(1, -15, 0, 4)
    V.Text = tostring(Settings[key])
    V.TextColor3 = GetThemeColor()
    V.Font = Enum.Font.GothamBold
    V.TextSize = 13
    V.TextXAlignment = Enum.TextXAlignment.Right
    V.BackgroundTransparency = 1
    V.Parent = F
    
    table.insert(ThemedTexts, V)

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -30, 0, 6)
    Bar.Position = UDim2.new(0, 15, 0, 32)
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
            Tween(Fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.05, Enum.EasingStyle.Linear)
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
    B.Size = UDim2.new(1, -5, 0, 40)
    B.BackgroundColor3 = GetThemeColor()
    B.BackgroundTransparency = 0.2
    B.Text = text
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Font = Enum.Font.GothamBold
    B.TextSize = 13
    B.Parent = parent
    
    table.insert(ThemedBGs, B)

    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 8)
    BCorner.Parent = B

    B.MouseButton1Click:Connect(function()
        Tween(B, {Size = UDim2.new(1, -11, 0, 38)}, 0.1)
        task.wait(0.1)
        Tween(B, {Size = UDim2.new(1, -5, 0, 40)}, 0.1, Enum.EasingStyle.Back)
        cb()
    end)
end

local function CreateInput(parent, placeholder, btnText, cb)
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, -5, 0, 44)
    F.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    F.BackgroundTransparency = 0.6
    F.Parent = parent

    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(0, 8)
    FCorner.Parent = F

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -100, 1, 0)
    Box.Position = UDim2.new(0, 15, 0, 0)
    Box.BackgroundTransparency = 1
    Box.PlaceholderText = placeholder
    Box.Text = ""
    Box.TextColor3 = Color3.fromRGB(240, 240, 240)
    Box.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 13
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.ClearTextOnFocus = false
    Box.Parent = F

    local B = Instance.new("TextButton")
    B.Size = UDim2.new(0, 75, 0, 28)
    B.Position = UDim2.new(1, -85, 0, 8)
    B.BackgroundColor3 = GetThemeColor()
    B.Text = btnText
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Font = Enum.Font.GothamBold
    B.TextSize = 12
    B.Parent = F
    
    table.insert(ThemedBGs, B)

    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 6)
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

CreateToggle(Cmb, "Silent Aim (Невидимая наводка)", "SilentAim")
CreateToggle(Cmb, "Aimlock (Наводка камеры)", "Aimlock")
CreateToggle(Cmb, "Только видимые цели (Wallcheck)", "AimVisibleOnly")
CreateToggle(Cmb, "Triggerbot (Авто-выстрел)", "Triggerbot")
CreateToggle(Cmb, "Autoscope (Зажатие ПКМ при захвате)", "AutoScope")
CreateToggle(Cmb, "Slow Walk (Замедление по бинду)", "SlowWalk")
CreateSlider(Cmb, "Скорость Slow Walk", 3, 14, "SlowWalkSpeed")
CreateToggle(Cmb, "Показывать FOV", "DrawFOV")
CreateSlider(Cmb, "Радиус FOV", 20, 600, "FOV")

CreateToggle(Esp, "ESP All Players", "AllPlayersESP")
CreateToggle(Esp, "Отображать никнеймы", "NamesESP")
CreateSlider(Esp, "Цвет врагов [R]", 0, 255, "EnemyColorR")
CreateSlider(Esp, "Цвет врагов [G]", 0, 255, "EnemyColorG")
CreateSlider(Esp, "Цвет врагов [B]", 0, 255, "EnemyColorB")

CreateSlider(Esp, "Цвет приоритета [R]", 0, 255, "PriorityColorR")
CreateSlider(Esp, "Цвет приоритета [G]", 0, 255, "PriorityColorG")
CreateSlider(Esp, "Цвет приоритета [B]", 0, 255, "PriorityColorB")

local PlrListLabel = Instance.new("TextLabel")
PlrListLabel.Size = UDim2.new(1, -5, 0, 25)
PlrListLabel.BackgroundTransparency = 1
PlrListLabel.Text = "Список особых игроков: (пусто)"
PlrListLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
PlrListLabel.Font = Enum.Font.Gotham
PlrListLabel.TextSize = 12
PlrListLabel.TextXAlignment = Enum.TextXAlignment.Left
PlrListLabel.Parent = Esp

local function RefreshPriorityLabel()
    local names = {}
    for n, _ in pairs(Settings.PriorityPlayers) do table.insert(names, n) end
    if #names == 0 then
        PlrListLabel.Text = "Список особых игроков: (пусто)"
    else
        PlrListLabel.Text = "Особые: " .. table.concat(names, ", ")
    end
end

CreateInput(Esp, "Введите ник игрока...", "Добавить", function(name)
    Settings.PriorityPlayers[name] = true
    RefreshPriorityLabel()
    SaveConfig()
end)

CreateAction(Esp, "Очистить список особых игроков", function()
    Settings.PriorityPlayers = {}
    RefreshPriorityLabel()
    SaveConfig()
end)

CreateToggle(Wld, "Nightmode", "Nightmode")
CreateToggle(Wld, "FullBright", "FullBright")
CreateToggle(Wld, "Убрать тени", "NoShadows")
CreateToggle(Wld, "RTX Graphics", "RTX")
CreateSlider(Wld, "Освещение Мира [R]", 0, 255, "WorldR")
CreateSlider(Wld, "Освещение Мира [G]", 0, 255, "WorldG")
CreateSlider(Wld, "Освещение Мира [B]", 0, 255, "WorldB")

CreateSlider(Wld, "Цвет Меню [R]", 0, 255, "UIColorR")
CreateSlider(Wld, "Цвет Меню [G]", 0, 255, "UIColorG")
CreateSlider(Wld, "Цвет Меню [B]", 0, 255, "UIColorB")

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -5, 0, 45)
Info.BackgroundTransparency = 1
Info.Text = "one.hvh [One Tap]\nАвтор: relosterpc\nВерсия: 1.01"
Info.TextColor3 = Color3.fromRGB(120, 120, 120)
Info.Font = Enum.Font.Gotham
Info.TextSize = 12
Info.Parent = Oth

CreateAction(Oth, "Сохранить конфигурацию", function()
    SaveConfig()
end)

local RTX_CC = Instance.new("ColorCorrectionEffect", Lighting)
RTX_CC.Brightness = 0.05
RTX_CC.Contrast = 0.2
RTX_CC.Saturation = 0.4
RTX_CC.Enabled = false

local RTX_Bloom = Instance.new("BloomEffect", Lighting)
RTX_Bloom.Intensity = 0.8
RTX_Bloom.Size = 22
RTX_Bloom.Threshold = 1.1
RTX_Bloom.Enabled = false

local RTX_Sun = Instance.new("SunRaysEffect", Lighting)
RTX_Sun.Intensity = 0.15
RTX_Sun.Spread = 0.8
RTX_Sun.Enabled = false

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function IsTargetVisible(headPart)
    local char = LocalPlayer.Character
    if not char or not headPart then return false end
    rayParams.FilterDescendantsInstances = {char, Camera}
    local result = Workspace:Raycast(Camera.CFrame.Position, (headPart.Position - Camera.CFrame.Position), rayParams)
    return not result or result.Instance:IsDescendantOf(headPart.Parent)
end

local function GetClosestTarget()
    local mPos = UserInputService:GetMouseLocation()
    local tgt = nil
    local minD = math.huge

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head")
            local hrp = char:FindFirstChild("HumanoidRootPart")

            if hum and hum.Health > 0 and head and hrp then
                if Settings.AimVisibleOnly and not IsTargetVisible(head) then 
                    continue 
                end

                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mPos).Magnitude
                    if dist <= Settings.FOV and dist < minD then
                        minD = dist
                        tgt = p
                    end
                end
            end
        end
    end
    return tgt
end

local function HandleTriggerbot()
    if not Settings.Triggerbot or triggerDebounce then return end
    
    local center = Camera.ViewportSize / 2
    local ray = Camera:ViewportPointToRay(center.X, center.Y)
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)

    if result and result.Instance and result.Instance.Parent then
        local targetPlr = Players:GetPlayerFromCharacter(result.Instance.Parent)
        if targetPlr and targetPlr ~= LocalPlayer then
            local hum = targetPlr.Character and targetPlr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                triggerDebounce = true
                if mouse1click then 
                    mouse1click() 
                else 
                    game:GetService("VirtualUser"):ClickButton1(Vector2.new(0, 0))
                end
                task.delay(0.12, function() triggerDebounce = false end)
            end
        end
    end
end

local function HandleAutoScope()
    if not Settings.AutoScope then
        if isScoping then
            if mouse2release then mouse2release() end
            isScoping = false
        end
        return
    end

    if CurrentTarget and CurrentTarget.Character then
        if not isScoping then
            if mouse2press then mouse2press() end
            isScoping = true
        end
    else
        if isScoping then
            if mouse2release then mouse2release() end
            isScoping = false
        end
    end
end

local function UpdateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local isAlive = hum and hum.Health > 0

            local isPriority = Settings.PriorityPlayers[p.Name] ~= nil
            local color = isPriority and GetPriorityColor() or GetEnemyColor()
            local shouldShow = Settings.AllPlayersESP and isAlive

            local hl = char:FindFirstChild("onehvh_HL")
            if shouldShow then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "onehvh_HL"
                    hl.FillTransparency = 0.5
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
                if shouldShow and Settings.NamesESP then
                    if not bg then
                        bg = Instance.new("BillboardGui")
                        bg.Name = "onehvh_Name"
                        bg.Size = UDim2.new(0, 140, 0, 30)
                        bg.StudsOffset = Vector3.new(0, 2.2, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = head

                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.TextStrokeTransparency = 0.2
                        txt.Font = Enum.Font.GothamBold
                        txt.TextSize = 12
                        txt.Parent = bg
                    end
                    bg.TextLabel.Text = p.Name .. (isPriority and " [PRIORITY]" or "")
                    bg.TextLabel.TextColor3 = color
                elseif bg then
                    bg:Destroy()
                end
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Settings.MenuBind and Settings.MenuBind ~= Enum.KeyCode.Unknown then
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

RunService.RenderStepped:Connect(function()
    UpdateHUD()
    UpdateESP()

    local thm = GetThemeColor()
    WMText.Text = "<font color='#" .. thm:ToHex() .. "'>one.hvh</font> One Tap | " .. LocalPlayer.Name .. " | " .. os.date("%H:%M:%S")
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
        Lighting.Ambient = Color3.fromRGB(10, 10, 15)
        Lighting.OutdoorAmbient = Color3.fromRGB(10, 10, 15)
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
    Lighting.GlobalShadows = not Settings.NoShadows

    RTX_CC.Enabled = Settings.RTX
    RTX_Bloom.Enabled = Settings.RTX
    RTX_Sun.Enabled = Settings.RTX

    CurrentTarget = GetClosestTarget()

    if Settings.Aimlock and CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, CurrentTarget.Character.Head.Position)
    end

    HandleTriggerbot()
    HandleAutoScope()

    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if isSlowWalkActive then
                hum.WalkSpeed = Settings.SlowWalkSpeed
            elseif Settings.SpeedHack then
                hum.WalkSpeed = Settings.WalkSpeed
            else
                hum.WalkSpeed = 16
            end
        end
    end
end)

local oldIdx
oldIdx = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and Settings.SilentAim and typeof(self) == "Instance" and self:IsA("PlayerMouse") then
        if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then
            if key == "Hit" then return CurrentTarget.Character.Head.CFrame end
            if key == "Target" then return CurrentTarget.Character.Head end
        end
    end
    return oldIdx(self, key)
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if not checkcaller() and Settings.SilentAim and CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then
        if method == "FireServer" or method == "InvokeServer" then
            local targetHeadPos = CurrentTarget.Character.Head.Position
            for i, v in ipairs(args) do
                if typeof(v) == "Vector3" then
                    args[i] = targetHeadPos
                end
            end
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)
