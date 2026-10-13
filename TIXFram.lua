-- ==========================================
-- TSB Suiryu Auto-Behind & Invisibility Script
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Distance behind the target (ระยะห่างจากด้านหลังเป้าหมาย)
local DISTANCE_BEHIND = 3 

-- 1. ตรวจสอบว่าผู้เล่นใช้ตัวละคร Suiryu หรือไม่
local function isSuiryu()
    local char = LocalPlayer.Character
    if not char then return false end
    
    -- ตรวจสอบจาก Moveset / Moveset Control หรือชื่อโมเดลท่าเตะของ Suiryu
    local moveset = char:FindFirstChild("Moveset") or char:FindFirstChild("Style")
    if moveset and (string.find(string.lower(moveset.Value), "suiryu") or string.find(string.lower(moveset.Value), "martial")) then
        return true
    end
    
    -- ตรวจสอบจาก Tool / Skill ใน Backpack หรือ Character
    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        if string.find(string.lower(item.Name), "headbutt") or string.find(string.lower(item.Name), "fists of fury") or string.find(string.lower(item.Name), "vanquish") then
            return true
        end
    end
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") and (string.find(string.lower(item.Name), "headbutt") or string.find(string.lower(item.Name), "fists of fury")) then
            return true
        end
    end

    return false
end

if not isSuiryu() then
    warn("[TSB Script] สคริปต์นี้รองรับเฉพาะตัวละคร Suiryu (Martial Artist) เท่านั้น!")
    return
end

print("[TSB Script] ยืนยันตัวละคร Suiryu - เริ่มทำงาน...")

-- 2. ฟังก์ชันทำให้ตัวละครล่องหน (Invisibility)
local function makeInvisible(char)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = 1
        elseif part:IsA("BillboardGui") or part:IsA("SurfaceGui") then
            part.Enabled = false
        end
    end
end

-- 3. ค้นหาเป้าหมายถัดไปที่ยังมีชีวิตอยู่
local function getNextTarget()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and root then
                return player
            end
        end
    end
    return nil
end

-- ตัวแปรติดตามการทำงาน
local currentTarget = nil
local renderConnection = nil

-- Loop หลักในการทำงานแบบ Realtime
renderConnection = RunService.Heartbeat:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    if not myHum or myHum.Health <= 0 then return end
    
    -- ทำล่องหนซ้ำเพื่อป้องกันเกม Reset ค่า Transparency
    makeInvisible(myChar)
    
    -- ตรวจสอบเป้าหมายปัจจุบัน
    if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
        currentTarget = getNextTarget()
    else
        local targetHum = currentTarget.Character:FindFirstChildOfClass("Humanoid")
        if not targetHum or targetHum.Health <= 0 then
            -- เป้าหมายตาย สลับไปหาเป้าหมายใหม่
            currentTarget = getNextTarget()
        end
    end

    -- วาร์ปไปล็อคตำแหน่งข้างหลังเป้าหมาย
    if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = currentTarget.Character.HumanoidRootPart
        local myRoot = myChar.HumanoidRootPart
        
        -- คำนวณพิกัดด้านหลังของเป้าหมายพร้อมหันหน้าตามเป้าหมาย
        local behindCFrame = targetRoot.CFrame * CFrame.new(0, 0, DISTANCE_BEHIND)
        myRoot.CFrame = behindCFrame
    end
end)
