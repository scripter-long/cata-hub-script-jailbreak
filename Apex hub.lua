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
    Name = "Multi-Area Orb + Hatch + TP",
    LoadingTitle = "Loading...",
    ConfigurationSaving = { Enabled = false }
})

-- Constants
local MULTIPLIER = 250
local ORB_LOOP_DELAY = 0.1
local HATCH_LOOP_DELAY = 0.1

-- Settings tab
local SettingsTab = Window:CreateTab("Settings")

SettingsTab:CreateSlider({
    Name = "Orb Collect Speed",
    Range = {0.001, 1},
    Increment = 0.001,
    Suffix = " sec delay",
    CurrentValue = ORB_LOOP_DELAY,
    Callback = function(value)
        ORB_LOOP_DELAY = value
    end
})

SettingsTab:CreateSlider({
    Name = "Hatch Speed",
    Range = {0.001, 1},
    Increment = 0.001,
    Suffix = " sec delay",
    CurrentValue = HATCH_LOOP_DELAY,
    Callback = function(value)
        HATCH_LOOP_DELAY = value
    end
})

-- Services
local RepStorage = game:GetService("ReplicatedStorage")
local orbEvent = RepStorage:WaitForChild("rEvents"):WaitForChild("orbEvent")
local crystalEvent = RepStorage:WaitForChild("rEvents"):WaitForChild("openCrystalRemote")
local tpEvent = RepStorage:WaitForChild("rEvents"):WaitForChild("areaTravelRemote")

-- Orb setup
local orbTypes = {"Blue", "Orange", "Yellow", "Red", "Gem"}
local orbNames = {Blue="Blue Orb", Orange="Orange Orb", Yellow="Yellow Orb", Red="Red Orb", Gem="Gem"}
local areaLocations = { [1]="City", [2]="Snow City", [3]="Magma City", [4]="Legends Highway", [5]="Speed Jungle" }

local orbToggles = {}
local orbLoopTasks = {}

for areaNum=1,5 do
    local Tab = Window:CreateTab("Area "..areaNum.." - "..areaLocations[areaNum])
    orbToggles[areaNum] = {}
    orbLoopTasks[areaNum] = {}

    -- Master toggle
    Tab:CreateToggle({
        Name = "Toggle All Orbs",
        CurrentValue = false,
        Callback = function(state)
            for _, orbType in ipairs(orbTypes) do
                orbToggles[areaNum][orbType] = state
                if orbLoopTasks[areaNum][orbType] then
                    task.cancel(orbLoopTasks[areaNum][orbType])
                    orbLoopTasks[areaNum][orbType] = nil
                end
                if state then
                    orbLoopTasks[areaNum][orbType] = task.spawn(function()
                        while true do
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
        orbLoopTasks[areaNum][orbType] = nil

        Tab:CreateToggle({
            Name = orbType.." Orb",
            CurrentValue = false,
            Callback = function(state)
                orbToggles[areaNum][orbType] = state
                if orbLoopTasks[areaNum][orbType] then
                    task.cancel(orbLoopTasks[areaNum][orbType])
                    orbLoopTasks[areaNum][orbType] = nil
                end
                if state then
                    orbLoopTasks[areaNum][orbType] = task.spawn(function()
                        while true do
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

-- Auto-Hatch setup
local hatchCrystals = {"Red Crystal", "Yellow Crystal", "Snow Crystal", "Lava Crystal", "Electro Legends Crystal", "Jungle Crystal"}
local hatchTasks = {}

local HatchTab = Window:CreateTab("Auto Hatch")
for _, crystalName in ipairs(hatchCrystals) do
    hatchTasks[crystalName] = nil
    HatchTab:CreateToggle({
        Name = crystalName,
        CurrentValue = false,
        Callback = function(state)
            if hatchTasks[crystalName] then
                task.cancel(hatchTasks[crystalName])
                hatchTasks[crystalName] = nil
            end
            if state then
                hatchTasks[crystalName] = task.spawn(function()
                    while true do
                        crystalEvent:InvokeServer("openCrystal", crystalName)
                        task.wait(HATCH_LOOP_DELAY)
                    end
                end)
            end
        end
    })
end

-- Teleport buttons (you said you’ll fix these later)
local tpTab = Window:CreateTab("Teleports")

tpTab:CreateButton({
    Name = "TP to City",
    Callback = function()
        local args = {"travelToArea", workspace:WaitForChild("areaCircles"):WaitForChild("areaCircle")}
        tpEvent:InvokeServer(unpack(args))
    end
})

tpTab:CreateButton({
    Name = "TP to Snow City",
    Callback = function()
        local args = {"travelToArea", workspace:WaitForChild("areaCircles"):WaitForChild("areaCircle")}
        tpEvent:InvokeServer(unpack(args))
    end
})

tpTab:CreateButton({
    Name = "TP to Magma City",
    Callback = function()
        local args = {"travelToArea", workspace:WaitForChild("areaCircles"):WaitForChild("areaCircle")}
        tpEvent:InvokeServer(unpack(args))
    end
})

tpTab:CreateButton({
    Name = "TP to Legends Highway",
    Callback = function()
        local args = {"travelToArea", workspace:WaitForChild("areaCircles"):WaitForChild("areaCircle")}
        tpEvent:InvokeServer(unpack(args))
    end
})

tpTab:CreateButton({
    Name = "TP to Speed Jungle",
    Callback = function()
        local args = {"travelToArea", workspace:WaitForChild("areaCircles"):WaitForChild("areaCircle")}
        tpEvent:InvokeServer(unpack(args))
    end
})
