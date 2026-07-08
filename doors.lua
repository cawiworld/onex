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

    InfJump = false, InfJumpBind = Enum.KeyCode.Unknown,
    Noclip = false, NoclipBind = Enum.KeyCode.Unknown,
    SpeedHack = false, SpeedHackBind = Enum.KeyCode.Unknown,
    WalkSpeed = 21,
    JumpHack = false, JumpHackBind = Enum.KeyCode.Unknown,
    JumpPower = 60,
    AACSpeed = false,
    AACNoclip = false,
    AACSpeedValue = 0.14,

    EntityESP = true, EntityESPBind = Enum.KeyCode.Unknown,
    ItemESP = true, ItemESPBind = Enum.KeyCode.Unknown,
    DoorESP = true, DoorESPBind = Enum.KeyCode.Unknown,

    Nightmode = false, NightmodeBind = Enum.KeyCode.Unknown,
    FullBright = false, FullBrightBind = Enum.KeyCode.Unknown,
    NoShadows = false, NoShadowsBind = Enum.KeyCode.Unknown,
    WorldR = 255, WorldG = 255, WorldB = 255,

    EntityColor = Color3.fromRGB(255, 50, 50),
    ItemColor = Color3.fromRGB(255, 215, 0),
    DoorColor = Color3.fromRGB(50, 255, 50),
    ESPFont = Enum.Font.GothamBold
}

local wasNoclip = false

local OriginalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    TimeOfDay = Lighting.TimeOfDay,
    GlobalShadows = Lighting.GlobalShadows
}

local cfgName = "onehvh_doors_config.json"

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

local Watermark = Instance.new("Frame")
Watermark.Position = UDim2.new(0, 15, 0, 15)
Watermark.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Watermark.BackgroundTransparency = 0.4
Watermark.Parent = HUD

local WMCorner = Instance.new("UICorner")
WMCorner.CornerRadius = UDim.new(0, 6)
WMCorner.Parent = Watermark

local WMStroke = Instance.new("UIStroke")
WMStroke.Color = Color3.fromRGB(66, 135, 245)
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

local MouseUnlocker = Instance.new("TextButton")
MouseUnlocker.Name = "MouseUnlocker"
MouseUnlocker.Size = UDim2.new(0, 0, 0, 0)
MouseUnlocker.BackgroundTransparency = 1
MouseUnlocker.Text = ""
MouseUnlocker.Modal = Settings.Visible
MouseUnlocker.Parent = Main

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MStroke = Instance.new("UIStroke")
MStroke.Color = Color3.fromRGB(66, 135, 245)
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

local function CreatePage(name)
    local P = Instance.new("ScrollingFrame")
    P.Size = UDim2.new(1, 0, 1, 0)
    P.BackgroundTransparency = 1
    P.Visible = false
    P.ScrollBarThickness = 2
    P.ScrollBarImageColor3 = Color3.fromRGB(66, 135, 245)
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
        Tween(b, {BackgroundColor3 = sel and Color3.fromRGB(66, 135, 245) or Color3.fromRGB(20, 20, 25), BackgroundTransparency = sel and 0.6 or 1}, 0.2)
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
    Bg.BackgroundColor3 = Settings[key] and Color3.fromRGB(66, 135, 245) or Color3.fromRGB(45, 45, 50)
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
        Tween(Bg, {BackgroundColor3 = Settings[key] and Color3.fromRGB(66, 135, 245) or Color3.fromRGB(45, 45, 50)}, 0.25)
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
    V.TextColor3 = Color3.fromRGB(66, 135, 245)
    V.Font = Enum.Font.GothamBold
    V.TextSize = 14
    V.TextXAlignment = Enum.TextXAlignment.Right
    V.BackgroundTransparency = 1
    V.Parent = F

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
    Fill.BackgroundColor3 = Color3.fromRGB(66, 135, 245)
    Fill.Parent = Bar

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
            Settings[key] = val
            V.Text = tostring(val)
        end
    end)
end

local function CreateAction(parent, text, cb)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -5, 0, 44)
    B.BackgroundColor3 = Color3.fromRGB(66, 135, 245)
    B.BackgroundTransparency = 0.2
    B.Text = text
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Font = Enum.Font.GothamBold
    B.TextSize = 14
    B.Parent = parent

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
        InfJump="Inf Jump", Noclip="Noclip", SpeedHack="Speed", JumpHack="Jump", 
        EntityESP="Entity ESP", ItemESP="Item ESP", DoorESP="Door ESP",
        Nightmode="Nightmode", FullBright="FullBright"
    }
    for key, name in pairs(bindsMap) do
        if Settings[key] then
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, 0, 0, 22)
            l.BackgroundTransparency = 1
            l.Text = "> " .. name .. " [ON]"
            l.TextColor3 = Color3.fromRGB(66, 135, 245)
            l.Font = Enum.Font.GothamBold
            l.TextSize = 14
            l.TextXAlignment = Enum.TextXAlignment.Right
            l.Parent = HUDCont

            local st = Instance.new("UIStroke")
            st.Thickness = 1.2
            st.Color = Color3.fromRGB(0,0,0)
            st.Parent = l
        end
    end
end

local Gen = CreatePage("General")
local Esp = CreatePage("ESP")
local Wld = CreatePage("World")
local Oth = CreatePage("Other")
local Aac = CreatePage("one.aac")

CreateTab("General")
CreateTab("ESP")
CreateTab("World")
CreateTab("Other")
CreateTab("one.aac")
SwitchTab("General")

CreateToggle(Gen, "Бесконечный прыжок", "InfJump")
CreateToggle(Gen, "Noclip (Сквозь стены)", "Noclip")
CreateToggle(Gen, "SpeedHack (Осторожно с античитом)", "SpeedHack")
CreateSlider(Gen, "Скорость", 16, 24, "WalkSpeed")
CreateToggle(Gen, "JumpHack", "JumpHack")
CreateSlider(Gen, "Прыжок", 50, 75, "JumpPower")

CreateToggle(Esp, "Сущности (Rush, Ambush, Figure...)", "EntityESP")
CreateToggle(Esp, "Предметы (Ключи, Монеты, Лут)", "ItemESP")
CreateToggle(Esp, "Двери", "DoorESP")

CreateToggle(Aac, "one.aac Speed (CFrame Bypass)", "AACSpeed")
CreateSlider(Aac, "Сила подталкивания", 10, 25, "AACSpeedValue")
CreateToggle(Aac, "one.aac Noclip (Phase Bypass)", "AACNoclip")

local AACInfo = Instance.new("TextLabel")
AACInfo.Size = UDim2.new(1, -5, 0, 70)
AACInfo.BackgroundTransparency = 1
AACInfo.Text = "one.aac - это наш проект по обходам анти-читов в играх. Мы делаем интересные bypass-тесты, что-бы античит детектил в разы меньше наших функций, нежели у других читов."
AACInfo.TextColor3 = Color3.fromRGB(120, 120, 130)
AACInfo.Font = Enum.Font.GothamMedium
AACInfo.TextSize = 12
AACInfo.TextWrapped = true
AACInfo.TextXAlignment = Enum.TextXAlignment.Center
AACInfo.Parent = Aac

CreateToggle(Wld, "Nightmode (Темнота везде)", "Nightmode")
CreateToggle(Wld, "FullBright (Отключить темноту)", "FullBright")
CreateToggle(Wld, "Убрать тени (No Shadows)", "NoShadows")
CreateSlider(Wld, "Цвет Мира (Красный)", 0, 255, "WorldR")
CreateSlider(Wld, "Цвет Мира (Зеленый)", 0, 255, "WorldG")
CreateSlider(Wld, "Цвет Мира (Синий)", 0, 255, "WorldB")

local mf = Instance.new("Frame")
mf.Size = UDim2.new(1, -5, 0, 46)
mf.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mf.BackgroundTransparency = 0.6
mf.Parent = Oth

local mfCorner = Instance.new("UICorner")
mfCorner.CornerRadius = UDim.new(0, 8)
mfCorner.Parent = mf

local ml = Instance.new("TextLabel")
ml.Size = UDim2.new(0.6, 0, 1, 0)
ml.Position = UDim2.new(0, 15, 0, 0)
ml.Text = "Скрыть/Показать Меню"
ml.TextColor3 = Color3.fromRGB(230, 230, 230)
ml.Font = Enum.Font.GothamMedium
ml.TextSize = 14
ml.TextXAlignment = Enum.TextXAlignment.Left
ml.BackgroundTransparency = 1
ml.Parent = mf

local mb = Instance.new("TextButton")
mb.Size = UDim2.new(0, 90, 0, 24)
mb.Position = UDim2.new(1, -105, 0, 11)
mb.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
mb.Text = "[" .. (Settings.MenuBind and Settings.MenuBind.Name or "Unknown") .. "]"
mb.TextColor3 = Color3.fromRGB(66, 135, 245)
mb.Font = Enum.Font.Gotham
mb.TextSize = 12
mb.Parent = mf

local mbCorner = Instance.new("UICorner")
mbCorner.CornerRadius = UDim.new(0, 4)
mbCorner.Parent = mb

local waitM = false
mb.MouseButton1Click:Connect(function() 
    waitM = true
    mb.Text = "..." 
end)

CreateAction(Oth, "💾 Сохранить настройки", function() SaveConfig() end)

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, 0, 0, 50)
Info.BackgroundTransparency = 1
Info.Text = "one.hvh DOORS Edition\nМодифицировано для режима Doors"
Info.TextColor3 = Color3.fromRGB(100, 100, 100)
Info.Font = Enum.Font.Gotham
Info.TextSize = 12
Info.Parent = Oth

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    
    if waitM and i.UserInputType == Enum.UserInputType.Keyboard then
        Settings.MenuBind = i.KeyCode
        mb.Text = "[" .. i.KeyCode.Name .. "]"
        waitM = false
        SaveConfig()
    elseif not waitM and i.KeyCode == Settings.MenuBind and Settings.MenuBind ~= Enum.KeyCode.Unknown then
        Settings.Visible = not Settings.Visible

        MouseUnlocker.Modal = Settings.Visible
            
        Tween(Main, {Position = Settings.Visible and UDim2.new(0.5, -320, 0.5, -240) or UDim2.new(0.5, -320, 1.2, 0)}, 0.4, Enum.EasingStyle.Back)
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
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    elseif wasNoclip and LocalPlayer.Character then
        wasNoclip = false
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end)

local function UpdateESP(instance, name, color, isEnabled)
    local hl = instance:FindFirstChild(name)
    if isEnabled then
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = name
            hl.FillColor = color
            hl.OutlineColor = color
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.Parent = instance
        end
    else
        if hl then hl:Destroy() end
    end
end

RunService.RenderStepped:Connect(function()
    UpdateHUD()
    WMText.Text = "<font color='#4287f5'>one.hvh</font> DOORS | " .. LocalPlayer.Name .. " | " .. os.date("%H:%M:%S")
    Watermark.Size = UDim2.new(0, WMText.TextBounds.X + 16, 0, 26)

    Lighting.GlobalShadows = not Settings.NoShadows
    if Settings.Nightmode then
        Lighting.TimeOfDay = "00:00:00"
        Lighting.Ambient = Color3.fromRGB(15, 15, 20)
        Lighting.OutdoorAmbient = Color3.fromRGB(15, 15, 20)
    elseif Settings.FullBright then
        Lighting.TimeOfDay = "12:00:00"
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.TimeOfDay = OriginalLighting.TimeOfDay
        if Settings.WorldR ~= 255 or Settings.WorldG ~= 255 or Settings.WorldB ~= 255 then
            local custColor = Color3.fromRGB(Settings.WorldR, Settings.WorldG, Settings.WorldB)
            Lighting.Ambient = custColor
            Lighting.OutdoorAmbient = custColor
        else
            Lighting.Ambient = OriginalLighting.Ambient
            Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        end

        local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        
        if hum then
            if Settings.SpeedHack and not Settings.AACSpeed then 
                hum.WalkSpeed = Settings.WalkSpeed 
            end
            
            if Settings.JumpHack then 
                hum.UseJumpPower = true
                hum.JumpPower = Settings.JumpPower 
            end

            if Settings.AACSpeed and not Settings.SpeedHack then
                hum.WalkSpeed = 16
                
                if hum.MoveDirection.Magnitude > 0 and hrp then
                    local bypassStep = Settings.AACSpeedValue / 100
                    hrp.CFrame = hrp.CFrame + (hum.MoveDirection * bypassStep)
                end
            end
            
            if Settings.AACNoclip then
                if hrp then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = false
                        end
                    end
                    
                    if hum.MoveDirection.Magnitude > 0 then
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterDescendantsInstances = {char}
                        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                        
                        local raycastResult = workspace:Raycast(hrp.Position, hum.MoveDirection * 2.5, raycastParams)
                        
                        if raycastResult and raycastResult.Instance then
                            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * 3.5)
                        end
                    end
                end
            elseif wasNoclip and not Settings.Noclip then
                wasNoclip = false
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end

    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Settings.SpeedHack then hum.WalkSpeed = Settings.WalkSpeed end
            if Settings.JumpHack then 
                hum.UseJumpPower = true
                hum.JumpPower = Settings.JumpPower 
            end
        end
    end
    
    local currentRooms = workspace:FindFirstChild("CurrentRooms")
    if currentRooms then
        for _, room in pairs(currentRooms:GetChildren()) do
            
            local door = room:FindFirstChild("Door")
            if door then
                UpdateESP(door, "onehvhDoorESP", Settings.DoorColor, Settings.DoorESP)
            end
            
            local assets = room:FindFirstChild("Assets")
            if assets then
                for _, asset in pairs(assets:GetChildren()) do
                    if asset:IsA("Model") and (asset.Name == "KeyObtain" or asset.Name == "GoldPile" or asset.Name == "Lighter" or asset.Name == "Flashlight") then
                        UpdateESP(asset, "onehvhItemESP", Settings.ItemColor, Settings.ItemESP)
                    end
                end
            end
        end
    end

    local entityNames = {RushMoving = true, AmbushMoving = true, FigureRig = true, SeekMoving = true}
    for _, obj in pairs(workspace:GetChildren()) do
        if entityNames[obj.Name] then
            UpdateESP(obj, "onehvhEntityESP", Settings.EntityColor, Settings.EntityESP)
        end
    end
end)
