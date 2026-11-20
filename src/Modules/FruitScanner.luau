local Workspace = game:GetService("Workspace")

local FruitScanner = {}
FruitScanner.__index = FruitScanner

local FRUIT_NAMES = {
    bomb=true, spike=true, chop=true, spring=true, spin=true, flame=true,
    falcon=true, ice=true, sand=true, dark=true, diamond=true, light=true,
    rubber=true, barrier=true, ghost=true, magma=true, quake=true, buddha=true,
    love=true, spider=true, sound=true, phoenix=true, portal=true, rumble=true,
    pain=true, blizzard=true, gravity=true, mammoth=true, trex=true, dough=true,
    shadow=true, venom=true, control=true, spirit=true, dragon=true, leopard=true,
    kitsune=true,
}

local MAX_MARKERS = 20

local function normalizeName(name)
    return string.lower(name):gsub("[%s_%-]", "")
end

local function isFruitModel(instance)
    if not instance:IsA("Model") then return false end
    local normalized = normalizeName(instance.Name)
    if FRUIT_NAMES[normalized] == true then return true end

    if normalized == "fruit" then
        for _, child in ipairs(instance:GetChildren()) do
            if child:IsA("Model") and FRUIT_NAMES[normalizeName(child.Name)] == true then
                return true
            end
        end
    end
    return false
end

local function getLabelName(model)
    if normalizeName(model.Name) == "fruit" then
        for _, child in ipairs(model:GetChildren()) do
            if child:IsA("Model") and FRUIT_NAMES[normalizeName(child.Name)] == true then
                return child.Name
            end
        end
    end
    return model.Name
end

function FruitScanner.new()
    return setmetatable({
        Enabled = false,
        Markers = {},
        AddedConnection = nil,
        RemovingConnection = nil,
        OnDetected = nil,
    }, FruitScanner)
end

function FruitScanner:_remove(model)
    local marker = self.Markers[model]
    if not marker then return end
    if marker.Highlight then marker.Highlight:Destroy() end
    if marker.Billboard then marker.Billboard:Destroy() end
    self.Markers[model] = nil
end

function FruitScanner:_add(model)
    if not self.Enabled or self.Markers[model] or not model.Parent or not isFruitModel(model) then
        return false
    end

    local count = 0
    for _ in pairs(self.Markers) do count += 1 end
    if count >= MAX_MARKERS then return false end

    local adornee = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    if not adornee then return false end

    local highlight = Instance.new("Highlight")
    highlight.Name = "AetherX_FruitHighlight"
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(151, 105, 255)
    highlight.OutlineColor = Color3.fromRGB(71, 218, 255)
    highlight.FillTransparency = 0.78
    highlight.OutlineTransparency = 0.08
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = model

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AetherX_FruitLabel"
    billboard.Adornee = adornee
    billboard.Size = UDim2.fromOffset(150, 28)
    billboard.StudsOffset = Vector3.new(0, 2.6, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1500
    billboard.Parent = model

    local label = Instance.new("TextLabel")
    label.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
    label.BackgroundTransparency = 0.12
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.Text = "✦  " .. getLabelName(model)
    label.TextColor3 = Color3.fromRGB(244, 246, 255)
    label.TextSize = 11
    label.Parent = billboard

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = label

    self.Markers[model] = { Highlight = highlight, Billboard = billboard }
    if self.OnDetected then task.spawn(self.OnDetected, getLabelName(model)) end
    return true
end

function FruitScanner:Scan()
    if not self.Enabled then return 0 end
    local found = 0
    for _, instance in ipairs(Workspace:GetDescendants()) do
        if isFruitModel(instance) and self:_add(instance) then found += 1 end
    end
    return found
end

function FruitScanner:SetEnabled(enabled)
    self.Enabled = enabled == true
    if self.Enabled then
        if not self.AddedConnection then
            self.AddedConnection = Workspace.DescendantAdded:Connect(function(instance)
                if isFruitModel(instance) then
                    task.defer(function() self:_add(instance) end)
                end
            end)
        end
        if not self.RemovingConnection then
            self.RemovingConnection = Workspace.DescendantRemoving:Connect(function(instance)
                if instance:IsA("Model") then
                    self:_remove(instance)
                end
            end)
        end
        return self:Scan()
    end

    local models = {}
    for model in pairs(self.Markers) do table.insert(models, model) end
    for _, model in ipairs(models) do self:_remove(model) end
    if self.AddedConnection then
        self.AddedConnection:Disconnect()
        self.AddedConnection = nil
    end
    if self.RemovingConnection then
        self.RemovingConnection:Disconnect()
        self.RemovingConnection = nil
    end
    return 0
end

function FruitScanner:GetCount()
    local count = 0
    for _ in pairs(self.Markers) do count += 1 end
    return count
end

function FruitScanner:Destroy()
    self:SetEnabled(false)
    self.OnDetected = nil
end

return FruitScanner
