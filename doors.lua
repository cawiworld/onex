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

-- Очистка старого UI
if CoreGui:FindFirstChild("onehvh_Hub") then CoreGui.onehvh_Hub:Destroy() end
if CoreGui:FindFirstChild("onehvh_HUD") then CoreGui.onehvh_HUD:Destroy() end

local Settings = {
    Visible = true, CurrentTab = "General", MenuBind = Enum.KeyCode.RightControl,

    -- General
    Noclip = false, NoclipBind = Enum.KeyCode.Unknown,
    SpeedHack = false, SpeedHackBind = Enum.KeyCode.Unknown,
    WalkSpeed = 21,
    JumpHack = false, JumpHackBind = Enum.KeyCode.Unknown,
    JumpPower = 60,
    TargetRoom = 50, -- Для телепорта

    -- one.aac Bypass
    AACEnabled = true, -- Мастер-переключатель байпасса
    AACSpeedValue = 14,
    AutoScreech = false, AutoScreechBind = Enum.KeyCode.Unknown,

    -- ESP Doors
    EntityESP = true, EntityESPBind = Enum.KeyCode.Unknown,
    ItemESP = true, ItemESPBind = Enum.KeyCode.Unknown,
    ObjectiveESP = true, ObjectiveESPBind = Enum.KeyCode.Unknown,
    DoorESP = true, DoorESPBind = Enum.KeyCode.Unknown,

    -- World
    Nightmode = false, NightmodeBind = Enum.KeyCode.Unknown,
    FullBright = false, FullBrightBind = Enum.KeyCode.Unknown,
    NoShadows = false, NoShadowsBind = Enum.KeyCode.Unknown,
    WorldR = 255, WorldG = 255, WorldB = 255,

    -- Colors
    EntityColor = Color3.fromRGB(255, 50, 50),
    ItemColor = Color3.fromRGB(255, 215, 0),
    ObjectiveColor = Color3.fromRGB(50, 150, 255),
    DoorColor = Color3.fromRGB(50, 255, 50)
}

local wasNoclip = false
local OriginalLighting = { Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, TimeOfDay = Lighting.TimeOfDay, GlobalShadows = Lighting.GlobalShadows }

local function Tween(obj, props, time, style) 
    TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() 
end

-- ========================================================
-- [ UI BUILDER ]
-- ========================================================
local HUD = Instance.new("ScreenGui")
HUD.Name = "onehvh_HUD" HUD.Parent = CoreGui HUD.ResetOnSpawn = false

local Watermark = Instance.new("Frame")
Watermark.Position = UDim2.new(0, 15, 0, 15) Watermark.BackgroundColor3 = Color3.fromRGB(15, 15, 20) Watermark.BackgroundTransparency = 0.4 Watermark.Parent = HUD
Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 6)
local WMStroke = Instance.new("UIStroke", Watermark) WMStroke.Color = Color3.fromRGB(66, 135, 245) WMStroke.Transparency = 0.5 WMStroke.Thickness = 1
local WMText = Instance.new("TextLabel", Watermark) WMText.Size = UDim2.new(1, -16, 1, 0) WMText.Position = UDim2.new(0, 8, 0, 0) WMText.BackgroundTransparency = 1 WMText.TextColor3 = Color3.fromRGB(255, 255, 255) WMText.Font = Enum.Font.GothamMedium WMText.TextSize = 13 WMText.TextXAlignment = Enum.TextXAlignment.Left WMText.RichText = true

local SG = Instance.new("ScreenGui")
SG.Name = "onehvh_Hub" SG.Parent = CoreGui SG.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 640, 0, 480) Main.Position = UDim2.new(0.5, -320, 0.5, -240) Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20) Main.BackgroundTransparency = 0.3 Main.Active = true Main.Draggable = true Main.Parent = SG
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local MStroke = Instance.new("UIStroke", Main) MStroke.Color = Color3.fromRGB(66, 135, 245) MStroke.Transparency = 0.7 MStroke.Thickness = 1.5

-- Фикс курсора мыши
local MouseUnlocker = Instance.new("TextButton", Main)
MouseUnlocker.Size = UDim2.new(0, 0, 0, 0) MouseUnlocker.BackgroundTransparency = 1 MouseUnlocker.Text = "" MouseUnlocker.Modal = Settings.Visible

local Shadow = Instance.new("ImageLabel", Main)
Shadow.Size = UDim2.new(1, 60, 1, 60) Shadow.Position = UDim2.new(0, -30, 0, -30) Shadow.BackgroundTransparency = 1 Shadow.Image = "rbxassetid://1316045217" Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0) Shadow.ImageTransparency = 0.4 Shadow.ZIndex = -1

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 170, 1, 0) Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 14) Sidebar.BackgroundTransparency = 0.4
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local Logo = Instance.new("TextLabel", Sidebar)
Logo.Size = UDim2.new(1, 0, 0, 70) Logo.Position = UDim2.new(0, 20, 0, 10) Logo.RichText = true Logo.Text = "<font color='#FFFFFF'>one.</font><font color='#4287f5'>hvh</font>" Logo.TextSize = 32 Logo.Font = Enum.Font.GothamBold Logo.TextXAlignment = Enum.TextXAlignment.Left Logo.BackgroundTransparency = 1

local TabCont = Instance.new("Frame", Sidebar)
TabCont.Size = UDim2.new(1, -20, 1, -90) TabCont.Position = UDim2.new(0, 10, 0, 80) TabCont.BackgroundTransparency = 1
Instance.new("UIListLayout", TabCont).Padding = UDim.new(0, 8)

local PageCont = Instance.new("Frame", Main)
PageCont.Size = UDim2.new(1, -190, 1, -30) PageCont.Position = UDim2.new(0, 180, 0, 15) PageCont.BackgroundTransparency = 1

local Pages = {} local Tabs = {}

local function CreatePage(name)
    local P = Instance.new("ScrollingFrame", PageCont)
    P.Size = UDim2.new(1, 0, 1, 0) P.BackgroundTransparency = 1 P.Visible = false P.ScrollBarThickness = 2 P.ScrollBarImageColor3 = Color3.fromRGB(66, 135, 245) P.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", P).Padding = UDim.new(0, 10)
    local Pad = Instance.new("UIPadding", P) Pad.PaddingTop = UDim.new(0, 2) Pad.PaddingRight = UDim.new(0, 5)
    Pages[name] = P return P
end

local function SwitchTab(name)
    Settings.CurrentTab = name
    for n, p in pairs(Pages) do
        p.Visible = (n == name)
        if p.Visible then 
            p.CanvasPosition = Vector2.new(0,0)
            for _, child in ipairs(p:GetChildren()) do
                if child:IsA("Frame") then 
                    local orig = child.Position child.Position = child.Position + UDim2.new(0, 20, 0, 0) child.BackgroundTransparency = 1
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
    local B = Instance.new("TextButton", TabCont)
    B.Size = UDim2.new(1, 0, 0, 38) B.BackgroundColor3 = Color3.fromRGB(20, 20, 25) B.BackgroundTransparency = 1 B.Text = ""
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 8)
    local L = Instance.new("TextLabel", B) L.Size = UDim2.new(1, -15, 1, 0) L.Position = UDim2.new(0, 15, 0, 0) L.Text = name L.TextColor3 = Color3.fromRGB(130, 130, 130) L.Font = Enum.Font.GothamMedium L.TextSize = 14 L.TextXAlignment = Enum.TextXAlignment.Left L.BackgroundTransparency = 1
    B.MouseButton1Click:Connect(function() SwitchTab(name) end)
    B.MouseEnter:Connect(function() if Settings.CurrentTab ~= name then Tween(L, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.1) end end)
    B.MouseLeave:Connect(function() if Settings.CurrentTab ~= name then Tween(L, {TextColor3 = Color3.fromRGB(130, 130, 130)}, 0.1) end end)
    Tabs[name] = B
end

local function CreateToggle(parent, text, key)
    local F = Instance.new("Frame", parent)
    F.Size = UDim2.new(1, -5, 0, 46) F.BackgroundColor3 = Color3.fromRGB(25, 25, 30) F.BackgroundTransparency = 0.6
    Instance.new("UICorner", F).CornerRadius = UDim.new(0, 8)
    local S = Instance.new("UIStroke", F) S.Color = Color3.fromRGB(255, 255, 255) S.Transparency = 0.9
    local L = Instance.new("TextLabel", F) L.Size = UDim2.new(0.6, 0, 1, 0) L.Position = UDim2.new(0, 15, 0, 0) L.Text = text L.TextColor3 = Color3.fromRGB(230, 230, 230) L.Font = Enum.Font.GothamMedium L.TextSize = 14 L.TextXAlignment = Enum.TextXAlignment.Left L.BackgroundTransparency = 1
    local Bg = Instance.new("Frame", F) Bg.Size = UDim2.new(0, 42, 0, 22) Bg.Position = UDim2.new(1, -55, 0, 12) Bg.BackgroundColor3 = Settings[key] and Color3.fromRGB(66, 135, 245) or Color3.fromRGB(45, 45, 50)
    Instance.new("UICorner", Bg).CornerRadius = UDim.new(1, 0)
    local C = Instance.new("Frame", Bg) C.Size = UDim2.new(0, 18, 0, 18) C.Position = Settings[key] and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2) C.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", C).CornerRadius = UDim.new(1, 0)
    local Btn = Instance.new("TextButton", F) Btn.Size = UDim2.new(1, 0, 1, 0) Btn.BackgroundTransparency = 1 Btn.Text = "" Btn.ZIndex = 2
    
    Btn.MouseButton1Click:Connect(function() 
        Settings[key] = not Settings[key]
        Tween(Bg, {BackgroundColor3 = Settings[key] and Color3.fromRGB(66, 135, 245) or Color3.fromRGB(45, 45, 50)}, 0.25)
        Tween(C, {Position = Settings[key] and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)}, 0.3, Enum.EasingStyle.Back)
    end)
    Btn.MouseEnter:Connect(function() Tween(S, {Transparency = 0.7}, 0.2) end)
    Btn.MouseLeave:Connect(function() Tween(S, {Transparency = 0.9}, 0.2) end)
end

local function CreateSlider(parent, text, min, max, key)
    local F = Instance.new("Frame", parent)
    F.Size = UDim2.new(1, -5, 0, 56) F.BackgroundColor3 = Color3.fromRGB(25, 25, 30) F.BackgroundTransparency = 0.6
    Instance.new("UICorner", F).CornerRadius = UDim.new(0, 8)
    local L = Instance.new("TextLabel", F) L.Size = UDim2.new(0.5, 0, 0, 25) L.Position = UDim2.new(0, 15, 0, 5) L.Text = text L.TextColor3 = Color3.fromRGB(230, 230, 230) L.Font = Enum.Font.GothamMedium L.TextSize = 14 L.TextXAlignment = Enum.TextXAlignment.Left L.BackgroundTransparency = 1
    local V = Instance.new("TextLabel", F) V.Size = UDim2.new(0.3, 0, 0, 25) V.Position = UDim2.new(1, -15, 0, 5) V.Text = tostring(Settings[key]) V.TextColor3 = Color3.fromRGB(66, 135, 245) V.Font = Enum.Font.GothamBold V.TextSize = 14 V.TextXAlignment = Enum.TextXAlignment.Right V.BackgroundTransparency = 1
    local Bar = Instance.new("Frame", F) Bar.Size = UDim2.new(1, -30, 0, 6) Bar.Position = UDim2.new(0, 15, 0, 36) Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
    local Fill = Instance.new("Frame", Bar) Fill.Size = UDim2.new(math.clamp((Settings[key] - min) / (max - min), 0, 1), 0, 1, 0) Fill.BackgroundColor3 = Color3.fromRGB(66, 135, 245)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    local Btn = Instance.new("TextButton", F) Btn.Size = UDim2.new(1, 0, 1, 0) Btn.BackgroundTransparency = 1 Btn.Text = "" Btn.ZIndex = 2

    local drag = false
    Btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    RunService.RenderStepped:Connect(function()
        if drag then
            local p = math.clamp((UserInputService:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Tween(Fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.1, Enum.EasingStyle.Linear)
            local val = math.floor(min + (p * (max - min)))
            Settings[key] = val V.Text = tostring(val)
        end
    end)
end

local function CreateAction(parent, text, cb)
    local B = Instance.new("TextButton", parent)
    B.Size = UDim2.new(1, -5, 0, 44) B.BackgroundColor3 = Color3.fromRGB(66, 135, 245) B.BackgroundTransparency = 0.2 B.Text = text B.TextColor3 = Color3.fromRGB(255, 255, 255) B.Font = Enum.Font.GothamBold B.TextSize = 14
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 8)
    B.MouseButton1Click:Connect(function() 
        Tween(B, {Size = UDim2.new(1, -11, 0, 40)}, 0.1) task.wait(0.1) Tween(B, {Size = UDim2.new(1, -5, 0, 44)}, 0.1, Enum.EasingStyle.Back)
        cb() 
    end)
end

local Gen = CreatePage("General")
local Esp = CreatePage("ESP")
local Wld = CreatePage("World")
local Aac = CreatePage("one.aac")

CreateTab("General")
CreateTab("ESP")
CreateTab("World")
CreateTab("one.aac")
SwitchTab("General")

CreateToggle(Gen, "Noclip (Сквозь стены)", "Noclip")
CreateToggle(Gen, "SpeedHack", "SpeedHack")
CreateSlider(Gen, "Скорость", 16, 24, "WalkSpeed")
CreateToggle(Gen, "JumpHack", "JumpHack")
CreateSlider(Gen, "Прыжок", 50, 100, "JumpPower")

local function GetCurrentRoom()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return 0 end
    local closest, minDist = 0, math.huge
    if workspace:FindFirstChild("CurrentRooms") then
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            local entrance = room:FindFirstChild("RoomEntrance")
            if entrance then
                local dist = (entrance.Position - char.HumanoidRootPart.Position).Magnitude
                if dist < minDist then minDist = dist closest = tonumber(room.Name) or 0 end
            end
        end
    end
    return closest
end

CreateSlider(Gen, "Выбор комнаты (Телепорт)", 0, 100, "TargetRoom")
CreateAction(Gen, "Телепорт (Макс 20 дверей)", function()
    local currentRoomNum = GetCurrentRoom()
    local safeTarget = math.clamp(Settings.TargetRoom, 0, currentRoomNum + 20)
    
    local targetRoomModel = workspace.CurrentRooms:FindFirstChild(tostring(safeTarget))
    if targetRoomModel then
        local dest = targetRoomModel:FindFirstChild("RoomEntrance")
        if dest and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = dest.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

-- ESP
CreateToggle(Esp, "Сущности (Rush, Ambush, Figure)", "EntityESP")
CreateToggle(Esp, "Цели (Книги, Рычаги, Щиток)", "ObjectiveESP")
CreateToggle(Esp, "Предметы (Ключи, Монеты)", "ItemESP")
CreateToggle(Esp, "Двери", "DoorESP")

-- WORLD
CreateToggle(Wld, "Nightmode (Темнота)", "Nightmode")
CreateToggle(Wld, "FullBright (Убрать темноту)", "FullBright")
CreateToggle(Wld, "No Shadows", "NoShadows")
CreateSlider(Wld, "Red", 0, 255, "WorldR") CreateSlider(Wld, "Green", 0, 255, "WorldG") CreateSlider(Wld, "Blue", 0, 255, "WorldB")

-- ONE.AAC
CreateToggle(Aac, "Включить one.aac Bypass", "AACEnabled")
CreateSlider(Aac, "Сила CFrame (Speed)", 10, 25, "AACSpeedValue")
CreateToggle(Aac, "Авто-наводка на Скрича (Screech)", "AutoScreech")

local AACInfo = Instance.new("TextLabel", Aac)
AACInfo.Size = UDim2.new(1, -5, 0, 70) AACInfo.BackgroundTransparency = 1 AACInfo.Text = "one.aac - это наш проект по обходам анти-читов. Если Bypass ВКЛЮЧЕН, то обычные функции (Speed, Noclip) будут использовать CFrame и Phase-методы для обмана сервера." AACInfo.TextColor3 = Color3.fromRGB(120, 120, 130) AACInfo.Font = Enum.Font.GothamMedium AACInfo.TextSize = 12 AACInfo.TextWrapped = true AACInfo.TextXAlignment = Enum.TextXAlignment.Center

-- [ LOGIC CORE ]
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Settings.MenuBind then
        Settings.Visible = not Settings.Visible
        MouseUnlocker.Modal = Settings.Visible
        Tween(Main, {Position = Settings.Visible and UDim2.new(0.5, -320, 0.5, -240) or UDim2.new(0.5, -320, 1.2, 0)}, 0.4, Enum.EasingStyle.Back)
    end
end)

local function UpdateESP(instance, name, color, isEnabled)
    local hl = instance:FindFirstChild(name)
    if isEnabled then
        if not hl then
            hl = Instance.new("Highlight", instance)
            hl.Name = name hl.FillColor = color hl.OutlineColor = color hl.FillTransparency = 0.5 hl.OutlineTransparency = 0
        end
    else
        if hl then hl:Destroy() end
    end
end

RunService.RenderStepped:Connect(function()
    WMText.Text = "<font color='#4287f5'>one.hvh</font> DOORS | " .. LocalPlayer.Name
    Watermark.Size = UDim2.new(0, WMText.TextBounds.X + 16, 0, 26)

    Lighting.GlobalShadows = not Settings.NoShadows
    if Settings.Nightmode then
        Lighting.TimeOfDay = "00:00:00" Lighting.Ambient = Color3.fromRGB(15, 15, 20) Lighting.OutdoorAmbient = Color3.fromRGB(15, 15, 20)
    elseif Settings.FullBright then
        Lighting.TimeOfDay = "12:00:00" Lighting.Ambient = Color3.fromRGB(255, 255, 255) Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.TimeOfDay = OriginalLighting.TimeOfDay Lighting.Ambient = Color3.fromRGB(Settings.WorldR, Settings.WorldG, Settings.WorldB) Lighting.OutdoorAmbient = Lighting.Ambient
    end

    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        
        -- [ ОБЪЕДИНЕННАЯ ЛОГИКА ДВИЖЕНИЯ ]
        if hum and hrp then
            -- JumpHack
            if Settings.JumpHack then hum.UseJumpPower = true hum.JumpPower = Settings.JumpPower end
            
            -- SpeedHack (AAC / Обычный)
            if Settings.SpeedHack then
                if Settings.AACEnabled then
                    hum.WalkSpeed = 16 -- Скрываем скорость от античета
                    if hum.MoveDirection.Magnitude > 0 then
                        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (Settings.AACSpeedValue / 100))
                    end
                else
                    hum.WalkSpeed = Settings.WalkSpeed
                end
            end

            -- Noclip (AAC / Обычный)
            if Settings.Noclip then
                if Settings.AACEnabled then
                    -- AAC Phase Noclip: Отключаем коллизию только для конечностей
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = false end
                    end
                    -- Телепортируемся сквозь стены, если уперлись
                    if hum.MoveDirection.Magnitude > 0 then
                        local params = RaycastParams.new() params.FilterDescendantsInstances = {char} params.FilterType = Enum.RaycastFilterType.Exclude
                        local ray = workspace:Raycast(hrp.Position, hum.MoveDirection * 2.5, params)
                        if ray and ray.Instance then hrp.CFrame = hrp.CFrame + (hum.MoveDirection * 3.5) end
                    end
                else
                    -- Обычный Noclip (Отключаем вообще всё)
                    wasNoclip = true
                    for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
                end
            elseif not Settings.AACEnabled and wasNoclip then
                wasNoclip = false
                for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
            end
        end
    end
    
    -- [ АВТО-НАВОДКА НА СКРИЧА ]
    if Settings.AutoScreech then
        local screech = workspace.CurrentCamera:FindFirstChild("Screech")
        if screech and screech:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then
            -- Поворачиваем камеру прямо на Скрича, чтобы он сразу испугался
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, screech.HumanoidRootPart.Position)
        end
    end

    -- [ ESP ]
    local entityNames = {RushMoving = true, AmbushMoving = true, FigureRig = true, SeekMoving = true, Screech = true, HaltRoom = true}
    for _, obj in pairs(workspace:GetChildren()) do
        if entityNames[obj.Name] then UpdateESP(obj, "onehvhEntityESP", Settings.EntityColor, Settings.EntityESP) end
    end

    local currentRooms = workspace:FindFirstChild("CurrentRooms")
    if currentRooms then
        for _, room in pairs(currentRooms:GetChildren()) do
            -- Двери
            local door = room:FindFirstChild("Door")
            if door then UpdateESP(door, "onehvhDoorESP", Settings.DoorColor, Settings.DoorESP) end
            
            -- Предметы и Объекты
            local assets = room:FindFirstChild("Assets")
            if assets then
                for _, asset in pairs(assets:GetChildren()) do
                    if asset:IsA("Model") then
                        -- Обычный лут
                        if asset.Name == "KeyObtain" or asset.Name == "GoldPile" or asset.Name == "Lighter" or asset.Name == "Flashlight" or asset.Name == "Lockpick" then
                            UpdateESP(asset, "onehvhItemESP", Settings.ItemColor, Settings.ItemESP)
                        -- Книги, щитки, рычаги
                        elseif asset.Name == "LiveHintBook" or asset.Name == "LiveBreakerPolePickup" or asset.Name == "LeverForGate" then
                            UpdateESP(asset, "onehvhObjESP", Settings.ObjectiveColor, Settings.ObjectiveESP)
                        end
                    end
                end
            end
        end
    end
end)
