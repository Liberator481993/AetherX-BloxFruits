local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Diagnostics = {}

function Diagnostics.Collect(fruitScanner, currentPage)
    local player = Players.LocalPlayer
    local character = player and player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")

    local level = "Unavailable"
    if player then
        local data = player:FindFirstChild("Data")
        local levelValue = data and data:FindFirstChild("Level")
        if levelValue and levelValue:IsA("ValueBase") then
            level = tostring(levelValue.Value)
        end
    end

    return table.concat({
        "AETHER X  |  CLIENT DIAGNOSTICS",
        "Player: " .. (player and player.Name or "Unavailable"),
        "Level: " .. level,
        "Character: " .. tostring(character ~= nil),
        "Humanoid: " .. tostring(humanoid ~= nil),
        "RootPart: " .. tostring(root ~= nil),
        "Workspace descendants: " .. tostring(#Workspace:GetDescendants()),
        "Fruit markers: " .. tostring(fruitScanner and fruitScanner:GetCount() or 0),
        "Current page: " .. tostring(currentPage or "Unknown"),
        "Runtime: " .. (RunService:IsStudio() and "Studio" or "Client"),
    }, "\n")
end

return Diagnostics
