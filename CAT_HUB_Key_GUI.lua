-- CAT HUB - Key GUI only
-- Standalone Roblox client GUI styled after the supplied reference.
-- Configure the three link URLs and KEY_API_URL before using.
-- The validation endpoint must be your own trusted server/Cloudflare Worker.
-- Expected POST JSON: {"key":"..."}
-- Expected response JSON: {"valid":true,"expiresAt":<unix timestamp>}
-- Never put a private API secret in this client script.

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- EDIT THESE VALUES
local LINK_URLS = {
    "https://YOUR-LINK-1.example",
    "https://YOUR-LINK-2.example",
    "https://YOUR-LINK-3.example",
}
local KEY_API_URL = "https://YOUR-CLOUDFLARE-WORKER.workers.dev/api/keys/validate"

local old = playerGui:FindFirstChild("CatHubKeyGUI")
if old then old:Destroy() end

local C = {
    bg = Color3.fromRGB(31, 20, 16),
    panel = Color3.fromRGB(42, 27, 20),
    card = Color3.fromRGB(53, 35, 26),
    stroke = Color3.fromRGB(90, 58, 40),
    orange = Color3.fromRGB(255, 140, 42),
    pale = Color3.fromRGB(255, 176, 102),
    text = Color3.fromRGB(255, 242, 230),
    sub = Color3.fromRGB(201, 165, 138),
    green = Color3.fromRGB(100, 220, 140),
    red = Color3.fromRGB(245, 125, 115),
    field = Color3.fromRGB(25, 25, 24),
}

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or C.stroke
    s.Thickness = thickness or 1
    s.Parent = obj
    return s
end

local function label(parent, text, size, color, bold)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or C.text
    l.TextSize = size or 14
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.TextWrapped = true
    l.Parent = parent
    return l
end

local gui = Instance.new("ScreenGui")
gui.Name = "CatHubKeyGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 999
gui.Parent = playerGui

local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 0.42
overlay.BorderSizePixel = 0
overlay.Parent = gui

local panel = Instance.new("Frame")
panel.Name = "KeyPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0.92, 0, 0, 610)
panel.BackgroundColor3 = C.bg
panel.BorderSizePixel = 0
panel.Parent = overlay
corner(panel, 18)
stroke(panel, C.stroke, 2)

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MaxSize = Vector2.new(560, 680)
sizeConstraint.MinSize = Vector2.new(280, 480)
sizeConstraint.Parent = panel

local scale = Instance.new("UIScale")
scale.Parent = panel
local function updateScale()
    local camera = workspace.CurrentCamera
    if camera then
        local v = camera.ViewportSize
        scale.Scale = math.clamp(math.min(v.X / 430, v.Y / 720), 0.72, 1)
    end
end
updateScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

-- Dragging
local dragging, dragStart, startPos
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 88)
header.BackgroundColor3 = C.panel
header.BorderSizePixel = 0
header.Parent = panel
corner(header, 18)

local dragButton = Instance.new("TextButton")
dragButton.Size = UDim2.new(1, -54, 1, 0)
dragButton.BackgroundTransparency = 1
dragButton.Text = ""
dragButton.Parent = header

dragButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local logo = Instance.new("Frame")
logo.Size = UDim2.fromOffset(48, 48)
logo.Position = UDim2.fromOffset(16, 19)
logo.BackgroundColor3 = C.card
logo.BorderSizePixel = 0
logo.Parent = header
corner(logo, 24)
stroke(logo, C.pale, 2)
local cat = label(logo, "🐱", 27, C.text, true)
cat.Size = UDim2.fromScale(1, 1)
cat.TextXAlignment = Enum.TextXAlignment.Center

local title = label(header, "CAT HUB", 21, C.text, true)
title.Position = UDim2.fromOffset(74, 17)
title.Size = UDim2.new(1, -140, 0, 30)
local subtitle = label(header, "Key required", 14, C.sub, false)
subtitle.Position = UDim2.fromOffset(75, 47)
subtitle.Size = UDim2.new(1, -140, 0, 22)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(40, 48)
close.Position = UDim2.new(1, -48, 0, 20)
close.BackgroundTransparency = 1
close.Text = "X"
close.TextColor3 = C.text
close.TextSize = 22
close.Font = Enum.Font.Gotham
close.Parent = header
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local line = Instance.new("Frame")
line.Position = UDim2.fromOffset(0, 87)
line.Size = UDim2.new(1, 0, 0, 1)
line.BackgroundColor3 = C.stroke
line.BorderSizePixel = 0
line.Parent = panel

local body = Instance.new("ScrollingFrame")
body.Position = UDim2.fromOffset(16, 102)
body.Size = UDim2.new(1, -32, 1, -118)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.ScrollBarThickness = 3
body.ScrollBarImageColor3 = C.orange
body.CanvasSize = UDim2.new()
body.AutomaticCanvasSize = Enum.AutomaticSize.Y
body.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = body

local intro = label(body, "Get your key in 3 steps", 19, C.text, true)
intro.Size = UDim2.new(1, 0, 0, 28)
intro.LayoutOrder = 1

local explain = label(body, "Copy each link, open it in your browser and finish the steps. The last page shows your key.", 14, C.sub, false)
explain.Size = UDim2.new(1, 0, 0, 48)
explain.LayoutOrder = 2

local copied = {}
for i = 1, 3 do
    local row = Instance.new("Frame")
    row.Name = "Link" .. i
    row.Size = UDim2.new(1, 0, 0, 66)
    row.BackgroundColor3 = C.card
    row.BorderSizePixel = 0
    row.LayoutOrder = i + 2
    row.Parent = body
    corner(row, 13)
    stroke(row, C.stroke, 1)

    local number = Instance.new("Frame")
    number.Size = UDim2.fromOffset(34, 34)
    number.Position = UDim2.fromOffset(14, 16)
    number.BackgroundColor3 = C.bg
    number.BorderSizePixel = 0
    number.Parent = row
    corner(number, 17)
    stroke(number, C.stroke, 1)
    local n = label(number, tostring(i), 17, C.pale, true)
    n.Size = UDim2.fromScale(1, 1)
    n.TextXAlignment = Enum.TextXAlignment.Center

    local linkLabel = label(row, "Link " .. i, 15, C.text, false)
    linkLabel.Position = UDim2.fromOffset(60, 0)
    linkLabel.Size = UDim2.new(1, -210, 1, 0)

    local copy = Instance.new("TextButton")
    copy.Size = UDim2.fromOffset(112, 40)
    copy.Position = UDim2.new(1, -126, 0.5, -20)
    copy.BackgroundColor3 = C.orange
    copy.Text = "Copy link"
    copy.TextColor3 = Color3.new(1, 1, 1)
    copy.TextSize = 14
    copy.Font = Enum.Font.GothamBold
    copy.AutoButtonColor = true
    copy.Parent = row
    corner(copy, 10)

    copy.MouseButton1Click:Connect(function()
        local url = LINK_URLS[i]
        if not url or url:find("YOUR%-LINK") then
            copy.Text = "Set URL first"
            task.delay(1.5, function() if copy.Parent then copy.Text = copied[i] and "Copied" or "Copy link" end end)
            return
        end
        local ok = pcall(function()
            if setclipboard then
                setclipboard(url)
            else
                error("Clipboard unavailable")
            end
        end)
        if ok then
            copied[i] = true
            copy.Text = "Copied"
            copy.BackgroundColor3 = C.bg
            copy.TextColor3 = C.pale
        else
            copy.Text = "No clipboard"
            task.delay(1.5, function() if copy.Parent then copy.Text = "Copy link" end end)
        end
    end)
end

local enter = label(body, "Enter your key", 16, C.text, true)
enter.Size = UDim2.new(1, 0, 0, 28)
enter.LayoutOrder = 6

local keyBox = Instance.new("TextBox")
keyBox.Name = "KeyInput"
keyBox.Size = UDim2.new(1, 0, 0, 58)
keyBox.BackgroundColor3 = C.field
keyBox.BorderSizePixel = 0
keyBox.PlaceholderText = "Paste your key here"
keyBox.PlaceholderColor3 = Color3.fromRGB(125, 125, 125)
keyBox.Text = ""
keyBox.TextColor3 = C.text
keyBox.TextSize = 18
keyBox.Font = Enum.Font.Gotham
keyBox.ClearTextOnFocus = false
keyBox.TextXAlignment = Enum.TextXAlignment.Left
keyBox.Parent = body
keyBox.LayoutOrder = 7
corner(keyBox, 11)
stroke(keyBox, Color3.fromRGB(55, 55, 52), 1)
local keyPadding = Instance.new("UIPadding")
keyPadding.PaddingLeft = UDim.new(0, 16)
keyPadding.PaddingRight = UDim.new(0, 12)
keyPadding.Parent = keyBox

local check = Instance.new("TextButton")
check.Name = "CheckKey"
check.Size = UDim2.new(1, 0, 0, 54)
check.BackgroundColor3 = C.orange
check.BorderSizePixel = 0
check.Text = "Check key"
check.TextColor3 = Color3.new(1, 1, 1)
check.TextSize = 17
check.Font = Enum.Font.GothamBold
check.Parent = body
check.LayoutOrder = 8
corner(check, 10)

local status = label(body, "", 14, C.red, false)
status.Size = UDim2.new(1, 0, 0, 44)
status.LayoutOrder = 9

local discord = Instance.new("TextButton")
discord.Size = UDim2.new(1, 0, 0, 48)
discord.BackgroundColor3 = C.bg
discord.BorderSizePixel = 0
discord.Text = "Join our Discord for help"
discord.TextColor3 = C.text
discord.TextSize = 14
discord.Font = Enum.Font.Gotham
discord.Parent = body
discord.LayoutOrder = 10
corner(discord, 10)
stroke(discord, C.stroke, 1)
discord.MouseButton1Click:Connect(function()
    if setclipboard then pcall(setclipboard, "https://discord.gg/FJK6QzNnf7") end
end)

local busy = false
check.MouseButton1Click:Connect(function()
    if busy then return end
    local key = keyBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if key == "" then
        status.TextColor3 = C.red
        status.Text = "Please enter your key."
        return
    end
    if KEY_API_URL:find("YOUR%-CLOUDFLARE") then
        status.TextColor3 = C.red
        status.Text = "Key API is not configured yet. Add your Cloudflare Worker URL."
        return
    end
    busy = true
    check.Text = "Checking..."
    check.BackgroundColor3 = C.pale
    status.TextColor3 = C.sub
    status.Text = "Checking your key..."
    task.spawn(function()
        local ok, response = pcall(function()
            local req = request or http_request
            if not req then error("HTTP requests are unavailable") end
            return req({
                Url = KEY_API_URL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({ key = key })
            })
        end)

        local valid, expiresAt = false, nil
        if ok and response then
            local statusCode = response.StatusCode or response.Status or 0
            local raw = response.Body or response.body or ""
            local decodedOk, data = pcall(function() return HttpService:JSONDecode(raw) end)
            if statusCode >= 200 and statusCode < 300 and decodedOk and type(data) == "table" then
                valid = data.valid == true
                expiresAt = tonumber(data.expiresAt)
            end
        end

        if valid then
            status.TextColor3 = C.green
            if expiresAt then
                local left = math.max(0, expiresAt - os.time())
                local hours = math.floor(left / 3600)
                local minutes = math.floor((left % 3600) / 60)
                status.Text = string.format("Key accepted! Time remaining: %dh %dm", hours, minutes)
            else
                status.Text = "Key accepted!"
            end
            check.Text = "Verified"
            check.BackgroundColor3 = C.green
            -- Add your own protected feature-start callback here after server validation.
        else
            status.TextColor3 = C.red
            status.Text = "That key is not valid or has expired. Get a new key with the 3 links."
            check.Text = "Check key"
            check.BackgroundColor3 = C.orange
        end
        busy = false
    end)
end)

-- Subtle entrance
panel.Position = UDim2.fromScale(0.5, 0.54)
panel.BackgroundTransparency = 1
TweenService:Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Position = UDim2.fromScale(0.5, 0.5),
    BackgroundTransparency = 0
}):Play()
