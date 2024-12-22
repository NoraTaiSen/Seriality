-- Đảm bảo Webhook đã được thiết lập
if not getgenv().webhook or getgenv().webhook == "" then
    warn("Vui lòng thiết lập getgenv().webhook trước khi chạy script!")
    return
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Lấy Webhook từ getgenv()
local webhookURL = getgenv().webhook

-- Hàm gửi thông tin qua Webhook
local function sendWebhookLog()
    local username = LocalPlayer.Name
    local userId = LocalPlayer.UserId
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    local gameId = game.GameId
    local hwid = "Không xác định" -- Dùng `getrenv()` nếu HWID có thể lấy được (yêu cầu exploit)

    -- Dữ liệu gửi
    local data = {
        ["embeds"] = {{
            ["title"] = "Thông tin người dùng",
            ["description"] = "Dưới đây là thông tin chi tiết:",
            ["color"] = 16711680, -- Màu đỏ
            ["fields"] = {
                {["name"] = "Tên người dùng", ["value"] = username, ["inline"] = true},
                {["name"] = "UserID", ["value"] = tostring(userId), ["inline"] = true},
                {["name"] = "Game đang chơi", ["value"] = gameName .. " (" .. tostring(gameId) .. ")", ["inline"] = false},
                {["name"] = "HWID", ["value"] = hwid, ["inline"] = false}
            },
            ["footer"] = {
                ["text"] = "FPS Booster Logger"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    -- Gửi Webhook
    local success, err = pcall(function()
        HttpService:PostAsync(
            webhookURL,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson
        )
    end)

    if success then
        print("Gửi thông tin Webhook thành công!")
    else
        warn("Không thể gửi thông tin Webhook: " .. tostring(err))
    end
end

-- Gửi thông tin qua Webhook khi script được chạy
sendWebhookLog()

-- Tạo GUI hiển thị FPS
local screenGui = Instance.new("ScreenGui")
local textLabel = Instance.new("TextLabel")

screenGui.Parent = game.CoreGui
screenGui.DisplayOrder = 100

textLabel.Parent = screenGui
textLabel.Size = UDim2.new(0, 300, 0, 50)
textLabel.Position = UDim2.new(0, 10, 0, 10) 
textLabel.Font = Enum.Font.FredokaOne 
textLabel.TextScaled = true 
textLabel.BackgroundTransparency = 1 
textLabel.TextStrokeTransparency = 0

local function rainbowColor()
    local Dreamon = 0
    while true do
        Dreamon = Dreamon + 0.01
        if Dreamon > 1 then Dreamon = 0 end
        textLabel.TextColor3 = Color3.fromHSV(Dreamon, 1, 1) 
        RunService.RenderStepped:Wait()
    end
end

local frameCount = 0
local lastUpdate = tick()

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()

    if now - lastUpdate >= 1 then
        local fps = frameCount / (now - lastUpdate)
        frameCount = 0
        lastUpdate = now

        local userName = LocalPlayer.Name
        textLabel.Text = string.format("%s, FPS: %d", userName, math.floor(fps))
    end
end)

spawn(rainbowColor)

-- Hàm xóa hiệu ứng
local function removeEffectsAndSetTransparency()
    local function clearEffectsInInstance(instance)
        for _, child in ipairs(instance:GetChildren()) do
            if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("Beam") or child:IsA("Smoke") or child:IsA("Sparkles") or child:IsA("Fire") then
                child:Destroy()
            end
            clearEffectsInInstance(child)
        end
    end

    clearEffectsInInstance(game.Workspace)

    for i, v in next, workspace:GetDescendants() do
        pcall(function()
            if v:IsA("BasePart") then
                v.Transparency = 1
            end
        end)
    end

    for i, v in next, getnilinstances() do
        pcall(function()
            if v:IsA("BasePart") then
                v.Transparency = 1
                for i1, v1 in next, v:GetDescendants() do
                    if v1:IsA("BasePart") then
                        v1.Transparency = 1
                    end
                end
            end
        end)
    end

    local a = workspace
    a.DescendantAdded:Connect(function(v)
        pcall(function()
            if v:IsA("BasePart") then
                v.Transparency = 1
            end
        end)
    end)

    print("Đã xóa tất cả hiệu ứng và thiết lập Transparency.")
end

-- Gọi hàm
removeEffectsAndSetTransparency()

-- FPS Booster Settings
_G.Settings = {
    Players = {
        ["Ignore Me"] = true,
        ["Ignore Others"] = true
    },
    Meshes = {
        Destroy = false,
        LowDetail = true
    },
    Images = {
        Invisible = true,
        LowDetail = false,
        Destroy = false
    },
    ["No Particles"] = true,
    ["No Camera Effects"] = true,
    ["No Explosions"] = true,
    ["No Clothes"] = true,
    ["Low Water Graphics"] = true,
    ["No Shadows"] = true,
    ["Low Rendering"] = true,
    ["Low Quality Parts"] = true
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/FPSBooster.lua"))()
