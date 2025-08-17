local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    warn("Failed to load Rayfield library: ", Rayfield)
    return
end
print("Rayfield library loaded successfully")

local Window = Rayfield:CreateWindow({
    Name = "Apex hub",
    LoadingTitle = "Apex hub loading...",
    ConfigurationSaving = { Enabled = false }
})

-- Multiplier (how many times to collect per cycle)
local MULTIPLIER = 100 -- optional

-- Tables
local orbToggles = {}
local orbToggleUIRefs = {}
local loopTasks = {}
local loopDelays = {}

-- Orb types
local orbTypes = {"Blue", "Orange", "Yellow", "Red"}
local orbNames = {
    Blue = "Blue Orb",
    Orange = "Orange Orb",
    Yellow = "Yellow Orb",
    Red = "Red Orb"
}

-- Areas
local areaLocations = {
    [1] = "City",
    [2] = "snow",
    [3] = "magma",
    [4] = "something I don't remember",
    [5] = "jungle"
}

-- Remote event
local success, orbEvent = pcall(function()
    return game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("orbEvent")
end)
if not success then
    warn("Failed to find orbEvent: ", orbEvent)
    return
end
print("orbEvent found successfully")

for areaNum = 1, 5 do
    local Tab = Window:CreateTab("Area "..areaNum)
    orbToggles[areaNum] = {}
    orbToggleUIRefs[areaNum] = {}
    loopTasks[areaNum] = {}
    loopDelays[areaNum] = 0.1

    -- Slider for delay
    Tab:CreateSlider({
        Name = "Orb Collection Speed (seconds)",
        Range = {0.001, 1},
        Increment = 0.05,
        Suffix = "s",
        CurrentValue = 0.1,
        Callback = function(value)
            loopDelays[areaNum] = value
            print("Area "..areaNum.." loop delay set to "..value.." seconds")
        end,
    })

    -- Master toggle
    local masterToggle = Tab:CreateToggle({
        Name = "Toggle All Orbs in Area "..areaNum,
        CurrentValue = false,
        Callback = function(state)
            for _, orbType in ipairs(orbTypes) do
                orbToggles[areaNum][orbType] = state
                if orbToggleUIRefs[areaNum][orbType] then
                    orbToggleUIRefs[areaNum][orbType]:Set(state)
                end
            end
            print("Master toggle Area "..areaNum.." set to "..tostring(state))
        end,
    })

    -- Individual orb toggles
    for _, orbType in ipairs(orbTypes) do
        orbToggles[areaNum][orbType] = false
        loopTasks[areaNum][orbType] = nil

        orbToggleUIRefs[areaNum][orbType] = Tab:CreateToggle({
            Name = orbType.." Orb",
            CurrentValue = false,
            Callback = function(state)
                orbToggles[areaNum][orbType] = state

                -- Stop existing loop if running
                if loopTasks[areaNum][orbType] then
                    task.cancel(loopTasks[areaNum][orbType])
                    loopTasks[areaNum][orbType] = nil
                end

                if state then
                    -- Start loop for this orb
                    loopTasks[areaNum][orbType] = task.spawn(function()
                        while true do
                            for i = 1, MULTIPLIER do
                                orbEvent:FireServer("collectOrb", orbNames[orbType], areaLocations[areaNum])
                            end
                            task.wait(loopDelays[areaNum]) -- use slider delay
                        end
                    end)
                end

                print("Area "..areaNum.." "..orbType.." Orb toggled "..tostring(state))

                -- Sync with master toggle
                local allOn, allOff = true, true
                for _, oType in ipairs(orbTypes) do
                    if not orbToggles[areaNum][oType] then allOn = false end
                    if orbToggles[areaNum][oType] then allOff = false end
                end
                if allOn and not masterToggle.CurrentValue then
                    masterToggle:Set(true)
                elseif allOff and masterToggle.CurrentValue then
                    masterToggle:Set(false)
                end
            end,
        })
    end
end
