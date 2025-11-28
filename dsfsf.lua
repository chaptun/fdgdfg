-- Roblox Aimbot Script with Left Ctrl toggle
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ตัวแปรสำหรับเปิด/ปิด Aimbot
local AimbotEnabled = false
local LockedTarget = nil

-- ฟังก์ชันตรวจสอบทีม (ปรับปรุงให้ป้องกันการล็อคทีมตัวเอง)
local function IsEnemy(player)
    -- ถ้าไม่มีระบบทีม ให้ถือว่าเป็นศัตรู
    if not LocalPlayer.Team or not player.Team then
        return true
    end
    
    -- ต้องเป็นคนละทีมกันเท่านั้น
    return player.Team ~= LocalPlayer.Team
end

-- ฟังก์ชันหาตัวละครและหัว
local function GetCharacterHead(player)
    local character = player.Character
    if character then
        local head = character:FindFirstChild("Head")
        if head then
            return head
        end
    end
    return nil
end

-- ฟังก์ชันคำนวณระยะห่างจากเมาส์
local function GetDistanceFromMouse(position)
    local screenPoint = Camera:WorldToScreenPoint(position)
    local mouseLocation = Vector2.new(Mouse.X, Mouse.Y)
    local screenPosition = Vector2.new(screenPoint.X, screenPoint.Y)
    return (screenPosition - mouseLocation).Magnitude
end

-- ฟังก์ชันหาเป้าหมายที่ใกล้เมาส์ที่สุด (เฉพาะทีมศัตรู)
local function GetClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        -- ข้ามผู้เล่นตัวเองและตรวจสอบว่าเป็นศัตรูหรือไม่
        if player ~= LocalPlayer and player.Character and IsEnemy(player) then
            local head = GetCharacterHead(player)
            if head then
                -- ตรวจสอบว่ามองเห็นได้หรือไม่
                local ray = Ray.new(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 500)
                local part = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
                
                if part and part:IsDescendantOf(player.Character) then
                    local distance = GetDistanceFromMouse(head.Position)
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestEnemy = player
                    end
                end
            end
        end
    end
    
    return closestEnemy
end

-- ฟังก์ชันล็อคเป้าหมาย
local function LockOnTarget()
    if LockedTarget and LockedTarget.Character then
        local head = GetCharacterHead(LockedTarget)
        if head then
            -- ตรวจสอบว่ายังเป็นศัตรูอยู่หรือไม่
            if not IsEnemy(LockedTarget) then
                LockedTarget = nil
                print("⚠ เป้าหมายเปลี่ยนทีม - ยกเลิกการล็อค")
                return
            end
            
            -- ล็อคกล้องไปที่หัว
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        else
            LockedTarget = nil
        end
    end
end

-- ระบบอัปเดตทุกเฟรม
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        -- หาเป้าหมายใหม่ถ้ายังไม่มีเป้าหมาย
        if not LockedTarget or not LockedTarget.Character then
            LockedTarget = GetClosestEnemy()
        end
        
        -- ล็อคเป้าหมาย
        if LockedTarget then
            LockOnTarget()
        end
    else
        LockedTarget = nil
    end
end)

-- ระบบกดปุ่ม Left Ctrl เพื่อเปิด/ปิด
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.LeftControl then
            AimbotEnabled = not AimbotEnabled
            LockedTarget = nil
            
            -- แจ้งเตือนสถานะ
            if AimbotEnabled then
                print("✓ Aimbot เปิดใช้งาน - ล็อคเฉพาะทีมศัตรูเท่านั้น (กด Left Ctrl อีกครั้งเพื่อปิด)")
            else
                print("✗ Aimbot ปิดใช้งาน")
            end
        end
    end
end)

print("🎯 Aimbot Script โหลดสำเร็จ - กด Left Ctrl เพื่อเปิด/ปิด")
