-- Enhanced Auto Chest Collector for Blox Fruits
-- Ensure game is fully loaded
repeat task.wait() until game:IsLoaded()

local chestsCollected = 0 -- Counter to track the number of chests collected

-- Function to smoothly teleport to a chest using TweenService for better anti-cheat bypass
local function teleportToChest(chest)
    local player = game.Players.LocalPlayer
    local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart and chest and chest:IsA("BasePart") then
        local TweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear) -- Tween over 1 second

        -- Create a goal position slightly above the chest for smoother landing
        local chestPosition = chest.Position + Vector3.new(0, 3, 0)
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(chestPosition)})

        tween:Play()
        tween.Completed:Wait() -- Wait for the movement to complete
        firesignal(chest.Touched, humanoidRootPart) -- Trigger the chest's touch event
    end
end

-- Function to find the next chest
local function findAndCollectChest()
    local chests = {"Chest4", "Chest3", "Chest2", "Chest1", "Chest"} -- Priority order of chests
    for _, chestName in ipairs(chests) do
        local chest = game.Workspace:FindFirstChild(chestName)
        if chest then
            teleportToChest(chest)
            chestsCollected = chestsCollected + 1 -- Increment the chest counter
            task.wait(math.random(1, 2)) -- Random delay between each chest collection
            return true -- Chest found and collected
        end
    end
    return false -- No chest found
end

-- Function to reset the player's character after collecting 5 chests
local function resetCharacter()
    if chestsCollected >= 5 then
        chestsCollected = 0 -- Reset the chest counter
        game.Players.LocalPlayer.Character:BreakJoints() -- Reset the character
        task.wait(5) -- Wait a few seconds before continuing to avoid detection
    end
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
    resetCharacter() -- Check if the character needs to reset after collecting 5 chests
    if not chestFound then
        serverHop() -- Hop to another server if no chests are found
    end
end
