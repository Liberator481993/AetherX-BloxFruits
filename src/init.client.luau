local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local Modules = script:WaitForChild("Modules")
local UI = require(Modules:WaitForChild("UI"))
local FruitScanner = require(Modules:WaitForChild("FruitScanner"))
local Diagnostics = require(Modules:WaitForChild("Diagnostics"))

local scanner = FruitScanner.new()
scanner.OnDetected = function(fruitName)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "AETHER X • Fruit detected",
            Text = fruitName,
            Duration = 4,
        })
    end)
end

local function notify(title, message)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = 3,
        })
    end)
end

local mounted = UI.Mount({
    OnFruitEspChanged = function(enabled)
        local count = scanner:SetEnabled(enabled)
        notify("Fruit ESP", enabled and (tostring(count) .. " valid fruit model(s) found") or "ESP disabled")
    end,
    OnFruitScan = function()
        if not scanner.Enabled then
            notify("Fruit Radar", "Enable Fruit ESP before scanning.")
            return
        end
        local count = scanner:Scan()
        notify("Fruit Radar", tostring(count) .. " new valid marker(s) added.")
    end,
    GetDiagnostics = function(currentPage)
        return Diagnostics.Collect(scanner, currentPage)
    end,
})

local player = Players.LocalPlayer
player.CharacterRemoving:Connect(function()
    -- Fruit models are world objects; keep scanner state while the character respawns.
end)

mounted.Screen.Destroying:Connect(function()
    scanner:Destroy()
end)

notify("AETHER X", "Modular interface loaded.")
