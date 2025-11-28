local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local settings = {
    killAura = {
        enabled = false,
        range = 50,
        delay = 0.05
    },
    autoCollect = {
        enabled = false,
        range = 100
    },
    speedHack = {
        enabled = false,
        speed = 16,
        originalSpeed = 16
    }
}

-- สร้าง UI (ขนาดเล็กลงสำหรับมือถือ)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TopBar = Instance.new("Frame")
local TopBarCorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")

-- สร้างปุ่มเปิด/ปิด UI สำหรับมือถือ (เล็กลง)
local ToggleButton = Instance.new("TextButton")
local ToggleCorner = Instance.new("UICorner")

-- Tab System
local TabContainer = Instance.new("Frame")
local TabsFrame = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")

-- สร้าง Tabs
local tabs = {"Settings", "Combat", "Collect", "Speed"}
local tabButtons = {}
local tabContents = {}

ScreenGui.Name = "FarmingScriptUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- Toggle Button (เล็กลงสำหรับมือถือ)
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -30)
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "⚔️"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 24
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.ZIndex = 10

ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    
    -- แอนิเมชันกด
    local originalSize = ToggleButton.Size
    ToggleButton:TweenSize(UDim2.new(0, 52, 0, 52), "Out", "Quad", 0.1, true, function()
        ToggleButton:TweenSize(originalSize, "Out", "Quad", 0.1, true)
    end)
end)

-- Main Frame (เล็กลงเหลือ 70% ของขนาดเดิม)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -160)
MainFrame.Size = UDim2.new(0, 360, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.ZIndex = 2

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Top Bar (เล็กลง)
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.ZIndex = 3

TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

-- แก้ไขให้มุมล่างเป็นเหลี่ยม
local TopBarFix = Instance.new("Frame")
TopBarFix.Parent = TopBar
TopBarFix.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TopBarFix.BorderSizePixel = 0
TopBarFix.Position = UDim2.new(0, 0, 1, -12)
TopBarFix.Size = UDim2.new(1, 0, 0, 12)
TopBarFix.ZIndex = 3

-- Title (ขนาดตัวอักษรเล็กลง)
Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "⚔️ FARM SCRIPT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 4

-- Close Button (เล็กลง)
CloseButton.Name = "CloseButton"
CloseButton.Parent = TopBar
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -30, 0.5, -10)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.ZIndex = 4

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Minimize Button (เล็กลง)
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TopBar
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Position = UDim2.new(1, -55, 0.5, -10)
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "−"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 14
MinimizeButton.ZIndex = 4

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeButton

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 360, 0, 35), "Out", "Quad", 0.3, true)
        MinimizeButton.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 360, 0, 320), "Out", "Quad", 0.3, true)
        MinimizeButton.Text = "−"
    end
end)

-- Tab Container
TabContainer.Name = "TabContainer"
TabContainer.Parent = MainFrame
TabContainer.BackgroundTransparency = 1
TabContainer.BorderSizePixel = 0
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.Size = UDim2.new(1, 0, 1, -35)
TabContainer.ZIndex = 2

-- Tabs Frame (เล็กลง)
TabsFrame.Name = "TabsFrame"
TabsFrame.Parent = TabContainer
TabsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabsFrame.BorderSizePixel = 0
TabsFrame.Size = UDim2.new(0, 90, 1, 0)
TabsFrame.ZIndex = 2

-- Content Frame
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = TabContainer
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.Position = UDim2.new(0, 90, 0, 0)
ContentFrame.Size = UDim2.new(1, -90, 1, 0)
ContentFrame.ZIndex = 2

-- ฟังก์ชันสร้าง Tab Button (เล็กลง)
local function createTabButton(name, index)
    local button = Instance.new("TextButton")
    button.Name = name .. "Button"
    button.Parent = TabsFrame
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    button.BorderSizePixel = 0
    button.Position = UDim2.new(0, 5, 0, 5 + (index - 1) * 40)
    button.Size = UDim2.new(1, -10, 0, 35)
    button.Font = Enum.Font.GothamBold
    button.Text = name
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.TextSize = 11
    button.ZIndex = 3
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    return button
end

-- ฟังก์ชันสร้าง Content Frame
local function createContentFrame(name)
    local frame = Instance.new("ScrollingFrame")
    frame.Name = name .. "Content"
    frame.Parent = ContentFrame
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Visible = false
    frame.ScrollBarThickness = 4
    frame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    frame.CanvasSize = UDim2.new(0, 0, 0, 500)
    frame.ZIndex = 2
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = frame
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    return frame
end

-- สร้างแต่ละ Tab
for i, tabName in ipairs(tabs) do
    local button = createTabButton(tabName, i)
    local content = createContentFrame(tabName)
    
    tabButtons[tabName] = button
    tabContents[tabName] = content
    
    button.MouseButton1Click:Connect(function()
        for _, btn in pairs(tabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        for _, cnt in pairs(tabContents) do
            cnt.Visible = false
        end
        
        button.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        content.Visible = true
    end)
end

-- แสดง Tab แรก (Settings)
tabButtons[tabs[1]].BackgroundColor3 = Color3.fromRGB(50, 120, 255)
tabButtons[tabs[1]].TextColor3 = Color3.fromRGB(255, 255, 255)
tabContents[tabs[1]].Visible = true

-- ฟังก์ชันสร้าง Section (เล็กลง)
local function createSection(parent, title)
    local section = Instance.new("Frame")
    section.Parent = parent
    section.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    section.BorderSizePixel = 0
    section.Size = UDim2.new(1, -10, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.ZIndex = 3
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = section
    
    local padding = Instance.new("UIPadding")
    padding.Parent = section
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = section
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = section
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, 0, 0, 18)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 4
    
    return section
end

-- ฟังก์ชันสร้าง Toggle (เล็กลง)
local function createToggle(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.ZIndex = 4
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -45, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 5
    
    local toggle = Instance.new("TextButton")
    toggle.Parent = frame
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    toggle.BorderSizePixel = 0
    toggle.Position = UDim2.new(1, -38, 0.5, -10)
    toggle.Size = UDim2.new(0, 38, 0, 20)
    toggle.Text = ""
    toggle.ZIndex = 5
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local indicator = Instance.new("Frame")
    indicator.Parent = toggle
    indicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    indicator.BorderSizePixel = 0
    indicator.Position = UDim2.new(0, 2, 0.5, -8)
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.ZIndex = 6
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator
    
    local enabled = false
    
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        
        if enabled then
            toggle.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
            indicator:TweenPosition(UDim2.new(1, -18, 0.5, -8), "Out", "Quad", 0.2, true)
        else
            toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            indicator:TweenPosition(UDim2.new(0, 2, 0.5, -8), "Out", "Quad", 0.2, true)
        end
        
        callback(enabled)
    end)
    
    return frame
end

-- ฟังก์ชันสร้าง Slider (เล็กลง)
local function createSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.ZIndex = 4
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 14)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 5
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = frame
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(1, -45, 0, 0)
    valueLabel.Size = UDim2.new(0, 45, 0, 14)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    valueLabel.TextSize = 11
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 5
    
    local sliderBack = Instance.new("Frame")
    sliderBack.Parent = frame
    sliderBack.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBack.BorderSizePixel = 0
    sliderBack.Position = UDim2.new(0, 0, 0, 20)
    sliderBack.Size = UDim2.new(1, 0, 0, 16)
    sliderBack.ZIndex = 5
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderBack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBack
    sliderFill.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.ZIndex = 6
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    local dragging = false
    
    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    sliderBack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * pos)
            
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            valueLabel.Text = tostring(value)
            callback(value)
        end
    end)
    
    return frame
end

-- === SETTINGS TAB ===
local settingsContent = tabContents["Settings"]
local infoSection = createSection(settingsContent, "ℹ️ Info")

local infoLabel = Instance.new("TextLabel")
infoLabel.Parent = infoSection
infoLabel.BackgroundTransparency = 1
infoLabel.Size = UDim2.new(1, 0, 0, 110)
infoLabel.Font = Enum.Font.Gotham
infoLabel.Text = [[
╔═══════════════╗
 ULTIMATE FARM
╚═══════════════╝

📱 Mobile Optimized
⚔️ Kill Aura
💎 Auto Collect
🚀 Speed Boost

v2.6 | Edited Hub
]]
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
infoLabel.TextSize = 10
infoLabel.TextWrapped = true
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.ZIndex = 4

-- === COMBAT TAB ===
local combatContent = tabContents["Combat"]
local combatSection = createSection(combatContent, "⚔️ Kill Aura")

createToggle(combatSection, "Enable Kill Aura", function(enabled)
    settings.killAura.enabled = enabled
end)

createSlider(combatSection, "Attack Range", 10, 60, 50, function(value)
    settings.killAura.range = value
end)

-- === COLLECT TAB ===
local collectContent = tabContents["Collect"]
local collectSection = createSection(collectContent, "💎 Auto Collect")

createToggle(collectSection, "Enable Auto Collect", function(enabled)
    settings.autoCollect.enabled = enabled
end)

createSlider(collectSection, "Collect Range", 20, 1000, 100, function(value)
    settings.autoCollect.range = value
end)

-- === SPEED TAB ===
local speedContent = tabContents["Speed"]
local speedSection = createSection(speedContent, "🚀 Speed Hack")

createToggle(speedSection, "Enable Speed Hack", function(enabled)
    settings.speedHack.enabled = enabled
end)

createSlider(speedSection, "Walk Speed", 16, 500, 16, function(value)
    settings.speedHack.speed = value
end)

-- ฟังก์ชัน Kill Aura
local function attackMob(mobId)
    spawn(function()
        pcall(function()
            local args = {{ mobId }}
            ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Event"):WaitForChild("Combat"):WaitForChild("M1"):FireServer(unpack(args))
        end)
    end)
end

local function findNearbyMobs()
    local mobs = {}
    pcall(function()
        if not Workspace:FindFirstChild("Live") then return end
        local liveFolder = Workspace.Live
        if not liveFolder:FindFirstChild("MobModel") then return end
        local mobFolder = liveFolder.MobModel
        
        for _, mob in pairs(mobFolder:GetChildren()) do
            if mob:IsA("Model") then
                local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                local mobHumanoid = mob:FindFirstChild("Humanoid")
                
                if mobRoot and mobHumanoid and mobHumanoid.Health > 0 then
                    local distance = (humanoidRootPart.Position - mobRoot.Position).Magnitude
                    if distance <= settings.killAura.range then
                        table.insert(mobs, { id = mob.Name, distance = distance })
                    end
                end
            end
        end
    end)
    
    table.sort(mobs, function(a, b) return a.distance < b.distance end)
    return mobs
end

-- ฟังก์ชัน Auto Collect
local function findDroppedItems()
    local items = {}
    pcall(function()
        if not Workspace:FindFirstChild("Live") then return end
        local liveFolder = Workspace.Live
        if not liveFolder:FindFirstChild("DropItem") then return end
        local dropFolder = liveFolder.DropItem
        
        for _, item in pairs(dropFolder:GetChildren()) do
            if item:IsA("Model") or item:IsA("Part") or item:IsA("MeshPart") then
                local itemPos = item:FindFirstChild("HumanoidRootPart") or item:FindFirstChild("PrimaryPart") or item
                
                if itemPos and itemPos:IsA("BasePart") then
                    local distance = (humanoidRootPart.Position - itemPos.Position).Magnitude
                    if distance <= settings.autoCollect.range then
                        table.insert(items, { part = itemPos })
                    end
                end
            end
        end
    end)
    return items
end

local function pressE()
    spawn(function()
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            wait(0.01)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
    end)
end

-- ลูป Kill Aura
spawn(function()
    while true do
        wait(settings.killAura.delay)
        if settings.killAura.enabled and humanoidRootPart then
            local mobs = findNearbyMobs()
            for _, mob in pairs(mobs) do
                attackMob(mob.id)
            end
        end
    end
end)

-- ปรับแต่ง ProximityPrompts ให้ไม่บังจอ
spawn(function()
    local function setupProximityPrompts()
        pcall(function()
            local proximityGui = player.PlayerGui:FindFirstChild("ProximityPrompts")
            if proximityGui then
                local prompt = proximityGui:FindFirstChild("Prompt")
                if prompt then
                    -- ทำให้เล็กและโปร่งใสมาก
                    prompt.Size = UDim2.new(0, 40, 0, 25)
                    prompt.Position = UDim2.new(0.5, 0, 0.92, 0) -- มุมล่างสุด
                    prompt.BackgroundTransparency = 0.95
                    
                    -- ทำให้ทะลุได้
                    for _, child in pairs(prompt:GetDescendants()) do
                        if child:IsA("GuiObject") then
                            child.Active = false
                            child.ZIndex = 1
                        end
                        if child:IsA("TextLabel") or child:IsA("TextButton") then
                            child.TextTransparency = 0.9
                            child.TextSize = 8
                        end
                    end
                    
                    -- ถ้าอยากซ่อนเลย ให้เอา comment ออก
                    -- prompt.Visible = false
                end
            end
        end)
    end
    
    while true do
        setupProximityPrompts()
        wait(0.1)
    end
end)

-- ลูป Auto Collect (ดึงไอเทมมาหาตัวเรา + ไม่กระทบการเดิน)
spawn(function()
    while true do
        wait(0.05) -- เร็วขึ้นหน่อย
        if settings.autoCollect.enabled and humanoidRootPart then
            local items = findDroppedItems()
            for _, item in pairs(items) do
                spawn(function()
                    pcall(function()
                        if item.part and item.part.Parent then
                            -- ดึงไอเทมมาหาตัว (ไม่ดึงตัวเราไป)
                            local targetPos = humanoidRootPart.Position + Vector3.new(0, -2, 0) -- ใต้เท้านิดหน่อย
                            
                            -- ปิด CanCollide เพื่อไม่ให้บังหรือดัน
                            if item.part:IsA("BasePart") then
                                item.part.CanCollide = false
                            end
                            
                            -- ถ้ามี Parent เป็น Model ให้ปิด CanCollide ทั้งหมด
                            if item.part.Parent:IsA("Model") then
                                for _, part in pairs(item.part.Parent:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        part.CanCollide = false
                                    end
                                end
                            end
                            
                            -- ดึงมาหาตัว (ใช้ CFrame แทน Position เพื่อความรวดเร็ว)
                            item.part.CFrame = CFrame.new(targetPos)
                            
                            -- ถ้ามี Velocity ให้ตั้งเป็น 0
                            if item.part:IsA("BasePart") then
                                item.part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                item.part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                            end
                            
                            -- รอนิดหนึ่งแล้วหา ProximityPrompt
                            wait(0.01)
                            
                            local proximityPrompt = nil
                            if item.part.Parent:IsA("Model") then
                                proximityPrompt = item.part.Parent:FindFirstChildOfClass("ProximityPrompt", true)
                            end
                            if not proximityPrompt then
                                proximityPrompt = item.part:FindFirstChildOfClass("ProximityPrompt", true)
                            end
                            
                            -- Trigger ProximityPrompt
                            if proximityPrompt then
                                fireproximityprompt(proximityPrompt, 0)
                            else
                                -- ถ้าไม่มี ProximityPrompt ใช้วิธีกด E
                                pressE()
                            end
                        end
                    end)
                end)
            end
        end
    end
end)

-- Speed Hack
spawn(function()
    while true do
        wait(0.1)
        if settings.speedHack.enabled and humanoid then
            pcall(function()
                humanoid.WalkSpeed = settings.speedHack.speed
            end)
        end
    end
end)

-- อัพเดท Character
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    settings.speedHack.originalSpeed = humanoid.WalkSpeed
end)
