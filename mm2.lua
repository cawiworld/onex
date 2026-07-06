-- oNex Hub v3.0 | MM2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("oNex_Hub") then
    CoreGui.oNex_Hub:Destroy()
end

local Settings = {
    Visible = true,
    CurrentTab = "General",
    MenuBind = Enum.KeyCode.RightControl,
    
    Noclip = false,
    SpeedHack = false,
    WalkSpeed = 25,
    JumpHack = false,
    JumpPower = 60,
    Spinbot = false,
    SpinSpeed = 30,
    SpinBind = Enum.KeyCode.C,
    AutoShoot = false,
    ShootBind = Enum.KeyCode.V,
    SilentAim = false,
    
    MurdESP = true,
    SheriffESP = true,
    InnocentESP = false,
    GunESP = true,
    NamesESP = true,
    
    MurdColor = Color3.fromRGB(255, 50, 50),
    SheriffColor = Color3.fromRGB(50, 120, 255),
    InnocentColor = Color3.fromRGB(50, 255, 50),
    GunColor = Color3.fromRGB(255, 215, 0),
    ESPFont = Enum.Font.GothamBold
}

-- UI Framework
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "oNex_Hub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 390)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -195)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 255, 255)
Stroke.Transparency = 0.85
Stroke.Thickness = 1
Stroke.Parent = MainFrame

local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 150, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
SideBar.BackgroundTransparency = 0.5
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = SideBar

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 60)
Logo.Position = UDim2.new(0, 15, 0, 10)
Logo.RichText = true
Logo.Text = "<font color='#FFFFFF'>o</font><font color='#4287f5'>Nex</font>"
Logo.TextSize = 26
Logo.Font = Enum.Font.GothamBold
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.BackgroundTransparency = 1
Logo.Parent = SideBar

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -10, 1, -80)
TabContainer.Position = UDim2.new(0, 5, 0, 70)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = SideBar

local TabList = Instance.new("UIListLayout")
TabList.Parent = TabContainer
TabList.Padding = UDim.new(0, 5)
TabList.SortOrder = Enum.SortOrder.LayoutOrder

local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -165, 1, -20)
PagesContainer.Position = UDim2.new(0, 155, 0, 10)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

local Pages = {}
local Tabs = {}

local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(66, 135, 245)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Parent = PagesContainer
    
    local List = Instance.new("UIListLayout")
    List.Parent = Page
    List.Padding = UDim.new(0, 8)
    List.SortOrder = Enum.SortOrder.LayoutOrder
    
    local Pad = Instance.new("UIPadding")
    Pad.Parent = Page
    Pad.PaddingTop = UDim.new(0, 2)
    Pad.PaddingLeft = UDim.new(0, 2)
    Pad.PaddingRight = UDim.new(0, 5)
    
    Pages[name] = Page
    return Page
end

local function SwitchTab(tabName)
    Settings.CurrentTab = tabName
    for name, page in pairs(Pages) do
        page.Visible = (name == tabName)
    end
    for name, btn in pairs(Tabs) do
        local isSelected = (name == tabName)
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = isSelected and Color3.fromRGB(66, 135, 245) or Color3.fromRGB(20, 20, 25),
            BackgroundTransparency = isSelected and 0.8 or 1
        }):Play()
        TweenService:Create(btn.TextLabel, TweenInfo.new(0.2), {
            TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
        }):Play()
    end
end

local function CreateTab(name)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 34)
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = TabContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn
    
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -15, 1, 0)
    Lbl.Position = UDim2.new(0, 15, 0, 0)
    Lbl.Text = name
    Lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 14
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.BackgroundTransparency = 1
    Lbl.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    Tabs[name] = Btn
end

-- UI Components
local function CreateToggle(parent, text, setKey)
    local Frm = Instance.new("Frame")
    Frm.Size = UDim2.new(1, 0, 0, 40)
    Frm.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frm.BackgroundTransparency = 0.5
    Frm.Parent = parent
    Instance.new("UICorner", Frm).CornerRadius = UDim.new(0, 6)
    
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.7, 0, 1, 0)
    Lbl.Position = UDim2.new(0, 15, 0, 0)
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.BackgroundTransparency = 1
    Lbl.Parent = Frm
    
    local Bg = Instance.new("Frame")
    Bg.Size = UDim2.new(0, 40, 0, 20)
    Bg.Position = UDim2.new(1, -55, 0, 10)
    Bg.BackgroundColor3 = Settings[setKey] and Color3.fromRGB(66, 135, 245) or Color3.fromRGB(50, 50, 55)
    Bg.Parent = Frm
    Instance.new("UICorner", Bg).CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = Settings[setKey] and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.Parent = Bg
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Frm
    
    Btn.MouseButton1Click:Connect(function()
        Settings[setKey] = not Settings[setKey]
        TweenService:Create(Bg, TweenInfo.new(0.2), {BackgroundColor3 = Settings[setKey] and Color3.fromRGB(66, 135, 245) or Color3.fromRGB(50, 50, 55)}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = Settings[setKey] and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
    end)
end

local function CreateSlider(parent, text, min, max, setKey)
    local Frm = Instance.new("Frame")
    Frm.Size = UDim2.new(1, 0, 0, 50)
    Frm.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frm.BackgroundTransparency = 0.5
    Frm.Parent = parent
    Instance.new("UICorner", Frm).CornerRadius = UDim.new(0, 6)
    
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.5, 0, 0, 20)
    Lbl.Position = UDim2.new(0, 15, 0, 5)
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.BackgroundTransparency = 1
    Lbl.Parent = Frm
    
    local Val = Instance.new("TextLabel")
    Val.Size = UDim2.new(0.3, 0, 0, 20)
    Val.Position = UDim2.new(1, -15, 0, 5)
    Val.Text = tostring(Settings[setKey])
    Val.TextColor3 = Color3.fromRGB(66, 135, 245)
    Val.Font = Enum.Font.GothamBold
    Val.TextSize = 13
    Val.TextXAlignment = Enum.TextXAlignment.Right
    Val.BackgroundTransparency = 1
    Val.Parent = Frm
    
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -30, 0, 6)
    Bar.Position = UDim2.new(0, 15, 0, 32)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Bar.Parent = Frm
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((Settings[setKey] - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(66, 135, 245)
    Fill.Parent = Bar
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Bar
    
    local dragging = false
    Btn.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mp = UserInputService:GetMouseLocation().X
            local bp = Bar.AbsolutePosition.X
            local bw = Bar.AbsoluteSize.X
            local perc = math.clamp((mp - bp) / bw, 0, 1)
            Fill.Size = UDim2.new(perc, 0, 1, 0)
            local num = math.floor(min + (perc * (max - min)))
            Settings[setKey] = num
            Val.Text = tostring(num)
        end
    end)
end

local function CreateBind(parent, text, setKey)
    local Frm = Instance.new("Frame")
    Frm.Size = UDim2.new(1, 0, 0, 40)
    Frm.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frm.BackgroundTransparency = 0.5
    Frm.Parent = parent
    Instance.new("UICorner", Frm).CornerRadius = UDim.new(0, 6)
    
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.5, 0, 1, 0)
    Lbl.Position = UDim2.new(0, 15, 0, 0)
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.BackgroundTransparency = 1
    Lbl.Parent = Frm
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 90, 0, 24)
    Btn.Position = UDim2.new(1, -105, 0, 8)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Btn.Text = Settings[setKey].Name
    Btn.TextColor3 = Color3.fromRGB(66, 135, 245)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.Parent = Frm
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    
    local waitInput = false
    Btn.MouseButton1Click:Connect(function() waitInput = true; Btn.Text = "..." end)
    
    UserInputService.InputBegan:Connect(function(inp)
        if waitInput and inp.UserInputType == Enum.UserInputType.Keyboard then
            Settings[setKey] = inp.KeyCode
            Btn.Text = inp.KeyCode.Name
            waitInput = false
        end
    end)
end

local function CreateDropdown(parent, text, opts, setKey, customLogic)
    local Frm = Instance.new("Frame")
    Frm.Size = UDim2.new(1, 0, 0, 40)
    Frm.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Frm.BackgroundTransparency = 0.5
    Frm.Parent = parent
    Instance.new("UICorner", Frm).CornerRadius = UDim.new(0, 6)
    
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.5, 0, 1, 0)
    Lbl.Position = UDim2.new(0, 15, 0, 0)
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.BackgroundTransparency = 1
    Lbl.Parent = Frm
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 110, 0, 24)
    Btn.Position = UDim2.new(1, -125, 0, 8)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Btn.Text = opts[1]
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.Parent = Frm
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    
    local idx = 1
    Btn.MouseButton1Click:Connect(function()
        idx = (idx % #opts) + 1
        Btn.Text = opts[idx]
        if customLogic then customLogic(opts[idx]) end
    end)
end

-- Pages Generation
local Gen = CreatePage("General")
local Esp = CreatePage("ESP")
local Oth = CreatePage("Other")

CreateTab("General")
CreateTab("ESP")
CreateTab("Other")
SwitchTab("General")

-- General
CreateToggle(Gen, "Noclip (Проход сквозь стены)", "Noclip")
CreateToggle(Gen, "SpeedHack", "SpeedHack")
CreateSlider(Gen, "WalkSpeed", 16, 120, "WalkSpeed")
CreateToggle(Gen, "JumpHack", "JumpHack")
CreateSlider(Gen, "JumpPower", 50, 200, "JumpPower")
CreateToggle(Gen, "Silent Aim", "SilentAim")
CreateToggle(Gen, "AutoShoot", "AutoShoot")
CreateBind(Gen, "Бинд AutoShoot", "ShootBind")
CreateToggle(Gen, "Spinbot", "Spinbot")
CreateSlider(Gen, "Spinbot Скорость", 10, 100, "SpinSpeed")
CreateBind(Gen, "Бинд Spinbot", "SpinBind")

-- ESP
CreateToggle(Esp, "Убийца (Murderer)", "MurdESP")
CreateToggle(Esp, "Шериф (Sheriff)", "SheriffESP")
CreateToggle(Esp, "Мирные (Innocent)", "InnocentESP")
CreateToggle(Esp, "Оружие на полу (Gun)", "GunESP")
CreateToggle(Esp, "Никнеймы (Names)", "NamesESP")
CreateDropdown(Esp, "Шрифт", {"GothamBold", "Code", "Arcade"}, "ESPFont", function(v)
    Settings.ESPFont = (v == "Code" and Enum.Font.Code) or (v == "Arcade" and Enum.Font.Arcade) or Enum.Font.GothamBold
end)

-- Other
CreateBind(Oth, "Скрыть/Показать Меню", "MenuBind")
local InfoFrm = Instance.new("TextLabel")
InfoFrm.Size = UDim2.new(1, 0, 0, 40)
InfoFrm.BackgroundTransparency = 1
InfoFrm.Text = "oNex Hub v3.0 | Roblox_MurderMystery2\nDesigned by cawiworld"
InfoFrm.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoFrm.Font = Enum.Font.Gotham
InfoFrm.TextSize = 12
InfoFrm.Parent = Oth

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Settings.MenuBind then
        Settings.Visible = not Settings.Visible
        MainFrame.Visible = Settings.Visible
    elseif inp.KeyCode == Settings.SpinBind then
        Settings.Spinbot = not Settings.Spinbot
    elseif inp.KeyCode == Settings.ShootBind then
        Settings.AutoShoot = not Settings.AutoShoot
    end
end)

-- Logic Core
local function GetSmartTarget()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local amIMurd = (myChar:FindFirstChild("Knife") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Knife"))) ~= nil
    
    local bestTarget = nil
    local shortestDist = math.huge
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local isMurd = (p.Character:FindFirstChild("Knife") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife"))) ~= nil
            
            if amIMurd then
                local dist = (p.Character.HumanoidRootPart.Position - myChar.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    bestTarget = p
                end
            else
                if isMurd then return p end
            end
        end
    end
    return bestTarget
end

RunService.Stepped:Connect(function()
    if Settings.Noclip and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide and p.Name ~= "HumanoidRootPart" then
                p.CanCollide = false
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if hum then
        if Settings.SpeedHack then hum.WalkSpeed = Settings.WalkSpeed end
        if Settings.JumpHack then
            hum.UseJumpPower = true
            hum.JumpPower = Settings.JumpPower
        end
    end
    
    if hrp then
        local bav = hrp:FindFirstChild("oNexSpin")
        if Settings.Spinbot then
            if not bav then
                bav = Instance.new("BodyAngularVelocity")
                bav.Name = "oNexSpin"
                bav.MaxTorque = Vector3.new(0, math.huge, 0)
                bav.Parent = hrp
            end
            bav.AngularVelocity = Vector3.new(0, Settings.SpinSpeed, 0)
        else
            if bav then bav:Destroy() end
        end
    end
    
    if Settings.AutoShoot then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and (tool.Name == "Gun" or tool.Name == "Knife") then
            local target = GetSmartTarget()
            if target then tool:Activate() end
        end
    end
    
    -- ESP Logic
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local isMurd = p.Character:FindFirstChild("Knife") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife"))
            local isSheriff = p.Character:FindFirstChild("Gun") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun"))
            
            local hl = p.Character:FindFirstChild("oNexESP")
            local tag = p.Character:FindFirstChild("oNexTag")
            
            local show = false
            local clr = Color3.new(1,1,1)
            
            if isMurd and Settings.MurdESP then show, clr = true, Settings.MurdColor
            elseif isSheriff and Settings.SheriffESP then show, clr = true, Settings.SheriffColor
            elseif not isMurd and not isSheriff and Settings.InnocentESP then show, clr = true, Settings.InnocentColor end
            
            if show then
                if not hl then hl = Instance.new("Highlight", p.Character); hl.Name = "oNexESP"; hl.FillTransparency = 0.5; hl.OutlineTransparency = 0 end
                hl.FillColor = clr
                
                if Settings.NamesESP then
                    if not tag then
                        tag = Instance.new("BillboardGui", p.Character); tag.Name = "oNexTag"; tag.Size = UDim2.new(0,200,0,50)
                        tag.AlwaysOnTop = true; tag.StudsOffset = Vector3.new(0,3,0); tag.Adornee = p.Character.HumanoidRootPart
                        local txt = Instance.new("TextLabel", tag); txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1; txt.TextSize = 14
                    end
                    tag.TextLabel.Text = p.Name
                    tag.TextLabel.TextColor3 = clr
                    tag.TextLabel.Font = Settings.ESPFont
                elseif tag then tag:Destroy() end
            else
                if hl then hl:Destroy() end
                if tag then tag:Destroy() end
            end
        end
    end
    
    local gunDrop = workspace:FindFirstChild("GunDrop")
    if gunDrop and Settings.GunESP then
        local hl = gunDrop:FindFirstChild("oNexGun") or Instance.new("Highlight", gunDrop)
        hl.Name = "oNexGun"; hl.FillColor = Settings.GunColor; hl.FillTransparency = 0.5
    elseif gunDrop and gunDrop:FindFirstChild("oNexGun") then
        gunDrop.oNexGun:Destroy()
    end
end)

local oldIdx
oldIdx = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and Settings.SilentAim and typeof(self) == "Instance" and self:IsA("PlayerMouse") then
        if key == "Hit" or key == "Target" then
            local target = GetSmartTarget()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                if key == "Hit" then return target.Character.HumanoidRootPart.CFrame end
                if key == "Target" then return target.Character.HumanoidRootPart end
            end
        end
    end
    return oldIdx(self, key)
end)
