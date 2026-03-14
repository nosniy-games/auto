-- LocalScript at StarterPlayerScripts
if _G.ProfilesHUDLoaded then return end
_G.ProfilesHUDLoaded = true

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RequestProfile = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Misc"):WaitForChild("RequestProfile")

-- === Your HUD code and functions ===
local function toPercentString(value)
    if type(value) ~= "number" or value < 0 then
        return "N/A"
    end
    return string.format("%.2f%%", value * 100)
end

-- === Create HUD Frame ===
local HUDGui = Instance.new("ScreenGui")
HUDGui.Name = "RivalsHUD"
HUDGui.ResetOnSpawn = false
HUDGui.Parent = PlayerGui
HUDGui.Enabled = true

local HUDFrame = Instance.new("Frame")
HUDFrame.Name = "RivalsHUDFrame"
HUDFrame.Size = UDim2.new(0, 280, 0, 250)
HUDFrame.Position = UDim2.new(1, -300, 0, 380)
HUDFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
HUDFrame.BackgroundTransparency = 0.15
HUDFrame.BorderSizePixel = 0
HUDFrame.Parent = HUDGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = HUDFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(25, 25, 40)
UIStroke.Parent = HUDFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = HUDFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -8, 1, 0)
TitleLabel.Position = UDim2.new(0, 8, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "Player Profiles"
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Scrolling frame for players
local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Size = UDim2.new(1, -10, 1, -38)
ListFrame.Position = UDim2.new(0, 5, 0, 33)
ListFrame.BackgroundTransparency = 1
ListFrame.ScrollBarThickness = 6
ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ListFrame.Parent = HUDFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 4)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = ListFrame

-- Store player entries for updating
local PlayerEntries = {}

-- Function to create a player entry
local function createPlayerEntry(player, profile)
    local Frame = Instance.new("Frame")
    Frame.Name = "Entry_" .. player.UserId
    Frame.Size = UDim2.new(1, 0, 0, 75)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BackgroundTransparency = 0.1
    Frame.BorderSizePixel = 0
    Frame.Parent = ListFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame

    local Image = Instance.new("ImageLabel")
    Image.Size = UDim2.new(0, 50, 0, 50)
    Image.Position = UDim2.new(0, 10, 0.5, -25)
    Image.BackgroundTransparency = 1
    Image.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
    Image.Parent = Frame

    local ImageCorner = Instance.new("UICorner")
    ImageCorner.CornerRadius = UDim.new(0, 25)
    ImageCorner.Parent = Image

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Name = "InfoLabel"
    TextLabel.Size = UDim2.new(1, -75, 1, -10)
    TextLabel.Position = UDim2.new(0, 68, 0, 5)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextSize = 11
    TextLabel.TextWrapped = true

    if profile then
        local rankInfo = ""
        if profile.RankedCurrentELO then
            rankInfo = " | ELO: " .. tostring(profile.RankedCurrentELO)
        end
        
        TextLabel.Text = string.format(
            "%s (Lvl %s)%s\nCasual: %s | Ranked: %s\n%s | %s | %s | %s",
            player.Name,
            profile.Level or "?",
            rankInfo,
            toPercentString(profile.CasualWinPercent),
            toPercentString(profile.RankedWinPercent),
            profile.FavoriteWeapons and profile.FavoriteWeapons[1] and profile.FavoriteWeapons[1].Name or "N/A",
            profile.FavoriteWeapons and profile.FavoriteWeapons[2] and profile.FavoriteWeapons[2].Name or "N/A",
            profile.FavoriteWeapons and profile.FavoriteWeapons[3] and profile.FavoriteWeapons[3].Name or "N/A",
            profile.FavoriteWeapons and profile.FavoriteWeapons[4] and profile.FavoriteWeapons[4].Name or "N/A"
        )
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        TextLabel.Text = string.format("%s\nProfile unavailable\n(Privacy enabled or loading...)", player.Name)
        TextLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    end

    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.TextYAlignment = Enum.TextYAlignment.Top
    TextLabel.Parent = Frame
    
    PlayerEntries[player.UserId] = Frame
    return Frame
end

-- Optimized profile fetching
local function getProfile(player)
    -- Method 1: Try with player object (works for local player)
    local ok1, result1 = pcall(function()
        return RequestProfile:InvokeServer(player)
    end)
    if ok1 and type(result1) == "table" then
        return result1
    end
    
    task.wait(0.1) -- Small delay to avoid rate limiting
    
    -- Method 2: Try with UserId (works for most other players)
    local ok2, result2 = pcall(function()
        return RequestProfile:InvokeServer(player.UserId)
    end)
    if ok2 and type(result2) == "table" then
        return result2
    end
    
    return nil
end

-- Function to update canvas size
local function updateCanvasSize()
    ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end

-- Clear existing entries
local function clearEntries()
    for _, child in ipairs(ListFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    PlayerEntries = {}
end

-- Fetch all profiles
local function fetchAllProfiles()
    clearEntries()
    
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(function()
            local profile = getProfile(player)
            createPlayerEntry(player, profile)
            updateCanvasSize()
            
            -- Retry once after 3 seconds if no profile found
            if not profile then
                task.wait(3)
                if PlayerEntries[player.UserId] and player.Parent then
                    local retryProfile = getProfile(player)
                    if retryProfile then
                        local entry = PlayerEntries[player.UserId]
                        if entry then
                            entry:Destroy()
                        end
                        createPlayerEntry(player, retryProfile)
                        updateCanvasSize()
                    end
                end
            end
        end)
        task.wait(0.2) -- Stagger requests
    end
end

-- Initial fetch
fetchAllProfiles()

-- Handle new players joining
Players.PlayerAdded:Connect(function(player)
    task.wait(3) -- Wait for their data to load
    if player.Parent then
        local profile = getProfile(player)
        createPlayerEntry(player, profile)
        updateCanvasSize()
    end
end)

-- Handle players leaving
Players.PlayerRemoving:Connect(function(player)
    local entry = PlayerEntries[player.UserId]
    if entry then
        entry:Destroy()
        PlayerEntries[player.UserId] = nil
        updateCanvasSize()
    end
end)

-- Auto-update CanvasSize periodically
task.spawn(function()
    while HUDGui.Parent do
        task.wait(2)
        updateCanvasSize()
    end
end)

print("Rivals HUD loaded successfully!")

-- [Insert full HUD creation and profile fetching here]

-- === Queue this script to run on every teleport ===
local function queueForNextTeleport()
    -- We use the script's own source to queue it
    local source = [[
        loadstring(game:HttpGet("https://github.com/nosniy-games/auto/raw/refs/heads/main/autoload.lua"))()
    ]]
    -- Replace the above with your own source if not using HttpGet
    TeleportService:QueueOnTeleport(source)
end

-- Detect future teleports
LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.InProgress then
        queueForNextTeleport()
    end
end)

-- Queue for the first teleport
queueForNextTeleport()
