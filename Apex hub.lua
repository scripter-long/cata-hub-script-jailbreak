local success, Rayfield = pcall(function()
    local RayfieldCode = game:HttpGet("https://sirius.menu/rayfield")
    local func = loadstring(RayfieldCode)
    return func()
end)

if not success then
    warn("Failed to load Rayfield library:", Rayfield)
    return
end

local Window = Rayfield:CreateWindow({
    Name = "Multi-Area Orb + Hatch + TP + Rebirth",
    LoadingTitle = "Loading...",
    ConfigurationSaving = { Enabled = false }
})

-- Constants
local MULTIPLIER = 50
local ORB_LOOP_DELAY = 0.01
local HATCH_LOOP_DELAY = 0.1
local AUTO_REBIRTH_DELAY = 1

-- Services
local RepStorage = game:GetService("ReplicatedStorage")
local orbEvent = RepStorage:WaitForChild("rEvents"):WaitForChild("orbEvent")
local crystalEvent = RepStorage:WaitForChild("rEvents"):WaitForChild("openCrystalRemote")
local tpEvent = RepStorage:WaitForChild("rEvents"):WaitForChild("areaTravelRemote")
local rebirthEvent = RepStorage:WaitForChild("rEvents"):WaitForChild("rebirthEvent")

-- Orb + area setup
local orbTypes = {"Blue", "Orange", "Yellow", "Red", "Gem"}
local orbNames = {Blue="Blue Orb", Orange="Orange Orb", Yellow="Yellow Orb", Red="Red Orb", Gem="Gem"}
local areaLocations = { [1]="City", [2]="Snow City", [3]="Magma City", [4]="Legends Highway", [5]="Speed Jungle" }

-- Loop trackers
local orbToggles, orbLoopFlags = {}, {}
local hatchTasks, hatchFlags = {}, {}
local autoRebirthFlag = false

-- === Misc Tab ===
local MiscTab = Window:CreateTab("Misc")

MiscTab:CreateSlider({
    Name = "Orb Collect Speed",
    Range = {0.001, 1},
    Increment = 0.001,
    Suffix = " sec delay",
    CurrentValue = ORB_LOOP_DELAY,
    Callback = function(value)
        ORB_LOOP_DELAY = value
    end
})

MiscTab:CreateSlider({
    Name = "Hatch Speed",
    Range = {0.001, 1},
    Increment = 0.001,
    Suffix = " sec delay",
    CurrentValue = HATCH_LOOP_DELAY,
    Callback = function(value)
        HATCH_LOOP_DELAY = value
    end
})

MiscTab:CreateSlider({
    Name = "Auto Rebirth Delay",
    Range = {0.1, 10},
    Increment = 0.1,
    Suffix = " sec",
    CurrentValue = AUTO_REBIRTH_DELAY,
    Callback = function(value)
        AUTO_REBIRTH_DELAY = value
    end
})

MiscTab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Callback = function(state)
        autoRebirthFlag = state
        if state then
            task.spawn(function()
                while autoRebirthFlag do
                    rebirthEvent:FireServer("rebirthRequest")
                    task.wait(AUTO_REBIRTH_DELAY)
                end
            end)
        end
    end
})

-- === Orb Tabs ===
for areaNum=1,5 do
    local Tab = Window:CreateTab("Area "..areaNum.." - "..areaLocations[areaNum])
    orbToggles[areaNum] = {}
    orbLoopFlags[areaNum] = {}

    -- Master toggle
    Tab:CreateToggle({
        Name = "Toggle All Orbs",
        CurrentValue = false,
        Callback = function(state)
            for _, orbType in ipairs(orbTypes) do
                orbToggles[areaNum][orbType] = state
                orbLoopFlags[areaNum][orbType] = state
                if state then
                    task.spawn(function()
                        while orbLoopFlags[areaNum][orbType] do
                            for i=1,MULTIPLIER do
                                orbEvent:FireServer("collectOrb", orbNames[orbType], areaLocations[areaNum])
                            end
                            task.wait(ORB_LOOP_DELAY)
                        end
                    end)
                end
            end
        end
    })

    -- Individual orb toggles
    for _, orbType in ipairs(orbTypes) do
        orbToggles[areaNum][orbType] = false
        orbLoopFlags[areaNum][orbType] = false

        Tab:CreateToggle({
            Name = orbType.." Orb",
            CurrentValue = false,
            Callback = function(state)
                orbToggles[areaNum][orbType] = state
                orbLoopFlags[areaNum][orbType] = state
                if state then
                    task.spawn(function()
                        while orbLoopFlags[areaNum][orbType] do
                            for i=1,MULTIPLIER do
                                orbEvent:FireServer("collectOrb", orbNames[orbType], areaLocations[areaNum])
                            end
                            task.wait(ORB_LOOP_DELAY)
                        end
                    end)
                end
            end
        })
    end
end

-- === Auto Hatch ===
local hatchCrystals = {"Red Crystal", "Yellow Crystal", "Snow Crystal", "Lava Crystal", "Electro Legends Crystal", "Jungle Crystal"}
local HatchTab = Window:CreateTab("Auto Hatch")

for _, crystalName in ipairs(hatchCrystals) do
    hatchFlags[crystalName] = false
    hatchTasks[crystalName] = nil

    HatchTab:CreateToggle({
        Name = crystalName,
        CurrentValue = false,
        Callback = function(state)
            hatchFlags[crystalName] = state
            if state then
                hatchTasks[crystalName] = task.spawn(function()
                    while hatchFlags[crystalName] do
                        crystalEvent:InvokeServer("openCrystal", crystalName)
                        task.wait(HATCH_LOOP_DELAY)
                    end
                end)
            end
        end
    })
end

-- === Teleports ===
local tpTab = Window:CreateTab("Teleports")
local areaCirclesFolder = workspace:WaitForChild("areaCircles")

for _, areaCircle in ipairs(areaCirclesFolder:GetChildren()) do
    local areaValue = areaCircle:FindFirstChild("areaName")
    if areaValue and areaValue:IsA("StringValue") then
        local buttonName = areaValue.Value

        tpTab:CreateButton({
            Name = "TP to "..buttonName,
            Callback = function()
                tpEvent:InvokeServer("travelToArea", buttonName)
            end
        })
    end
end
