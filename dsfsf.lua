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

-- สร้าง UI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TopBar = Instance.new("Frame")
local TopBarCorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")

-- สร้างปุ่มเปิด/ปิด UI สำหรับมือถือ
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

-- Toggle Button (สำหรับมือถือ)
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -40)
ToggleButton.Size = UDim2.new(0, 80, 0, 80)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "⚔️"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 32
ToggleButton.Active = true
ToggleButton.Draggable = true

ToggleCorner.CornerRadius = UDim.new(0, 15)
ToggleCorner.Parent = ToggleButton



ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    
    -- แอนิเมชันกด
    local originalSize = ToggleButton.Size
    ToggleButton:TweenSize(UDim2.new(0, 70, 0, 70), "Out", "Quad", 0.1, true, function()
        ToggleButton:TweenSize(originalSize, "Out", "Quad", 0.1, true)
    end)
end)

-- Main Frame
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
MainFrame.Size = UDim2.new(0, 600, 0, 500)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true

UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

-- Top Bar
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TopBar.Size = UDim2.new(1, 0, 0, 50)

TopBarCorner.CornerRadius = UDim.new(0, 15)
TopBarCorner.Parent = TopBar

-- Title
Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0, 300, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "⚔️ ULTIMATE FARM SCRIPT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
CloseButton.Name = "CloseButton"
CloseButton.Parent = TopBar
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseButton.Position = UDim2.new(1, -45, 0.5, -15)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Minimize Button
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TopBar
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
MinimizeButton.Position = UDim2.new(1, -85, 0.5, -15)
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "−"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 18

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinimizeButton

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame:TweenSize(UDim2.new(0, 600, 0, 50), "Out", "Quad", 0.3, true)
        MinimizeButton.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 600, 0, 500), "Out", "Quad", 0.3, true)
        MinimizeButton.Text = "−"
    end
end)

-- Tab Container
TabContainer.Name = "TabContainer"
TabContainer.Parent = MainFrame
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 0, 0, 50)
TabContainer.Size = UDim2.new(1, 0, 1, -50)

-- Tabs Frame
TabsFrame.Name = "TabsFrame"
TabsFrame.Parent = TabContainer
TabsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabsFrame.Size = UDim2.new(0, 150, 1, 0)

-- Content Frame
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = TabContainer
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 150, 0, 0)
ContentFrame.Size = UDim2.new(1, -150, 1, 0)

-- ฟังก์ชันสร้าง Tab Button
local function createTabButton(name, index)
    local button = Instance.new("TextButton")
    button.Name = name .. "Button"
    button.Parent = TabsFrame
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    button.Position = UDim2.new(0, 10, 0, 10 + (index - 1) * 60)
    button.Size = UDim2.new(1, -20, 0, 50)
    button.Font = Enum.Font.GothamBold
    button.Text = name
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.TextSize = 16
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button
    
    return button
end

-- ฟังก์ชันสร้าง Content Frame
local function createContentFrame(name)
    local frame = Instance.new("ScrollingFrame")
    frame.Name = name .. "Content"
    frame.Parent = ContentFrame
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Visible = false
    frame.ScrollBarThickness = 6
    frame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    frame.CanvasSize = UDim2.new(0, 0, 0, 800)
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = frame
    layout.Padding = UDim.new(0, 15)
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

-- ฟังก์ชันสร้าง Section
local function createSection(parent, title)
    local section = Instance.new("Frame")
    section.Parent = parent
    section.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    section.Size = UDim2.new(1, -20, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = section
    
    local padding = Instance.new("UIPadding")
    padding.Parent = section
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingBottom = UDim.new(0, 15)
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = section
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = section
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    return section
end

-- ฟังก์ชันสร้าง Toggle
local function createToggle(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, 0, 0, 40)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Instance.new("TextButton")
    toggle.Parent = frame
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    toggle.Position = UDim2.new(1, -50, 0.5, -15)
    toggle.Size = UDim2.new(0, 50, 0, 30)
    toggle.Text = ""
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local indicator = Instance.new("Frame")
    indicator.Parent = toggle
    indicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    indicator.Position = UDim2.new(0, 3, 0.5, -12)
    indicator.Size = UDim2.new(0, 24, 0, 24)
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator
    
    local enabled = false
    
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        
        if enabled then
            toggle.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
            indicator:TweenPosition(UDim2.new(1, -27, 0.5, -12), "Out", "Quad", 0.2, true)
        else
            toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            indicator:TweenPosition(UDim2.new(0, 3, 0.5, -12), "Out", "Quad", 0.2, true)
        end
        
        callback(enabled)
    end)
    
    return frame
end

-- ฟังก์ชันสร้าง Slider
local function createSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, 0, 0, 60)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = frame
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(1, -60, 0, 0)
    valueLabel.Size = UDim2.new(0, 60, 0, 20)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderBack = Instance.new("Frame")
    sliderBack.Parent = frame
    sliderBack.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBack.Position = UDim2.new(0, 0, 0, 30)
    sliderBack.Size = UDim2.new(1, 0, 0, 20)
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderBack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBack
    sliderFill.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    
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

-- === SETTINGS TAB (ย้ายมาเป็นแท็บแรก) ===
local settingsContent = tabContents["Settings"]
local infoSection = createSection(settingsContent, "ℹ️ Information")

local infoLabel = Instance.new("TextLabel")
infoLabel.Parent = infoSection
infoLabel.BackgroundTransparency = 1
infoLabel.Size = UDim2.new(1, 0, 0, 200)
infoLabel.Font = Enum.Font.Gotham
infoLabel.Text = [[
╔════════════════════════╗
   ULTIMATE FARM SCRIPT
╚════════════════════════╝

📱 Mobile Optimized UI
⚔️ Multi-Target Kill Aura
💎 Smart Auto Collect
🚀 Speed Boost System

────────────────────────
Version: 2.5 | Edited Hub
Made with ❤️ for Gamers
────────────────────────
]]
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
infoLabel.TextSize = 13
infoLabel.TextWrapped = true
infoLabel.TextYAlignment = Enum.TextYAlignment.Top

-- === COMBAT TAB ===
local combatContent = tabContents["Combat"]
local combatSection = createSection(combatContent, "⚔️ Kill Aura Settings")

createToggle(combatSection, "Enable Kill Aura", function(enabled)
    settings.killAura.enabled = enabled
    print("Kill Aura:", enabled and "ON" or "OFF")
end)

createSlider(combatSection, "Attack Range", 10, 60, 50, function(value)
    settings.killAura.range = value
end)

-- === COLLECT TAB ===
local collectContent = tabContents["Collect"]
local collectSection = createSection(collectContent, "💎 Auto Collect Settings")

createToggle(collectSection, "Enable Auto Collect", function(enabled)
    settings.autoCollect.enabled = enabled
    print("Auto Collect:", enabled and "ON" or "OFF")
end)

createSlider(collectSection, "Collect Range", 20, 1000, 100, function(value)
    settings.autoCollect.range = value
end)

-- === SPEED TAB ===
local speedContent = tabContents["Speed"]
local speedSection = createSection(speedContent, "🚀 Speed Hack Settings")

createToggle(speedSection, "Enable Speed Hack", function(enabled)
    settings.speedHack.enabled = enabled
    print("Speed Hack:", enabled and "ON" or "OFF")
end)

createSlider(speedSection, "Walk Speed", 16, 500, 16, function(value)
    settings.speedHack.speed = value
end)

-- ฟังก์ชัน Kill Aura (แก้ไขให้ตีหลายตัวพร้อมกัน)
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

-- ลูป Kill Aura (ตีหลายตัวพร้อมกัน)
spawn(function()
    while true do
        wait(settings.killAura.delay)
        if settings.killAura.enabled and humanoidRootPart then
            local mobs = findNearbyMobs()
            -- ตีทุกตัวที่อยู่ในระยะพร้อมกัน
            for _, mob in pairs(mobs) do
                attackMob(mob.id)
            end
        end
    end
end)

-- ลูป Auto Collect
spawn(function()
    while true do
        wait(0.1)
        if settings.autoCollect.enabled and humanoidRootPart then
            local items = findDroppedItems()
            for _, item in pairs(items) do
                spawn(function()
                    pcall(function()
                        item.part.CFrame = humanoidRootPart.CFrame
                        wait(0.05)
                        pressE()
                    end)
                end)
            end
        end
    end
end)

-- Speed Hack with Anti-Kick
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

