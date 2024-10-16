-- Auto Chest Collector Script for Blox Fruits
-- Ensure game is fully loaded
repeat task.wait() until game:IsLoaded()

-- Function to teleport to a specific chest
local function teleportToChest(chest)
    if chest and chest:IsA("BasePart") then
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character:PivotTo(chest:GetPivot())
            firesignal(chest.Touched, player.Character.HumanoidRootPart)
        end
    end
end

-- Function to find the next chest
local function findAndCollectChest()
    local chests = {"Chest4", "Chest3", "Chest2", "Chest1", "Chest"} -- Priority order of chests
    for _, chestName in ipairs(chests) do
        local chest = game.Workspace:FindFirstChild(chestName)
        if chest then
            teleportToChest(chest)
            task.wait(1) -- Delay between each chest collection (1 second)
            return true -- Chest found and collected
        end
    end
    return false -- No chest found
end

-- Function to server hop if no chests are available
local function serverHop()
    local TeleportService = game:GetService("TeleportService")
    local PlaceID = game.PlaceId
    local Servers = game.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100"))
    
    for _, server in ipairs(Servers.data) do
        if server.playing < server.maxPlayers then
            TeleportService:TeleportToPlaceInstance(PlaceID, server.id, game.Players.LocalPlayer)
            break
        end
    end
end

-- Main loop to collect chests
while task.wait(2) do -- Check every 2 seconds
    local chestFound = findAndCollectChest()
    if not chestFound then
        serverHop() -- Hop to another server if no chests are found
    end
end
