---------------------------------------------------------------
local cmds = {}
local player = game.Players.LocalPlayer

---------------------------------------------------------------
wallet = false
dropping = false
blocking = false

---------------------------------------------------------------
-- Find which alt number this local player is (based on LSDropper.alts)
local function getAltIndex()
    local userId = player.UserId
    for i, altUserId in pairs(_G.LSDropper.alts) do
        if altUserId == userId then
            return i
        end
    end
    return nil
end

---------------------------------------------------------------
-- This array holds all the "bank" positions from Alt1 through Alt38
-- from your original if-statements. The array index #1 matches Alt1, #2 => Alt2, etc.
---------------------------------------------------------------
local bankPositions = {
    [1]  = CFrame.new(-389, 21, -338),
    [2]  = CFrame.new(-385, 21, -338),
    [3]  = CFrame.new(-380, 21, -337),
    [4]  = CFrame.new(-376, 21, -338),
    [5]  = CFrame.new(-370, 21, -338),
    [6]  = CFrame.new(-366, 21, -338),
    [7]  = CFrame.new(-361, 21, -338),
    [8]  = CFrame.new(-361, 21, -333),
    [9]  = CFrame.new(-365, 21, -334),
    [10] = CFrame.new(-370, 21, -334),
    [11] = CFrame.new(-375, 21, -334),
    [12] = CFrame.new(-381, 21, -334),
    [13] = CFrame.new(-386, 21, -334),
    [14] = CFrame.new(-390, 21, -334),
    [15] = CFrame.new(-390, 21, -331),
    [16] = CFrame.new(-386, 21, -331),
    [17] = CFrame.new(-382, 21, -331),
    [18] = CFrame.new(-376, 21, -331),
    [19] = CFrame.new(-371, 21, -331),
    [20] = CFrame.new(-366, 21, -331),
    [21] = CFrame.new(-361, 21, -331),
    [22] = CFrame.new(-361, 21, -327),
    [23] = CFrame.new(-365, 21, -327),
    [24] = CFrame.new(-371, 21, -326),
    [25] = CFrame.new(-376, 21, -327),
    [26] = CFrame.new(-381, 21, -326),
    [27] = CFrame.new(-385, 21, -327),
    [28] = CFrame.new(-390, 21, -323),
    [29] = CFrame.new(-390, 21, -326),
    [30] = CFrame.new(-390, 21, -323),
    [31] = CFrame.new(-385, 21, -323),
    [32] = CFrame.new(-381, 21, -323),
    [33] = CFrame.new(-375, 21, -324),
    [34] = CFrame.new(-370, 21, -323),
    [35] = CFrame.new(-365, 21, -324),
    [36] = CFrame.new(-360, 21, -324),
    [37] = CFrame.new(-359, 21, -318),
    [38] = CFrame.new(-364, 21, -319),
}

---------------------------------------------------------------
cmds["re"] = function(args, p)
    local origin_spot = player.Character.HumanoidRootPart.CFrame
    player.Character.Humanoid.Health = 0
    wait(7.5)
    player.Character.HumanoidRootPart.CFrame = origin_spot
end

cmds["freeze"] = function(args, p)
    player.Character.HumanoidRootPart.Anchored = not player.Character.HumanoidRootPart.Anchored
end

cmds["chat"] = function(args, p)
    if (args[1] == "" or args[1] == nil) then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("LS ON TOP!", "All")
    else
        local str = ""
        for i = 1, 50 do
            if (args[i] ~= nil) then
                str = str .. " " .. args[i]
            end
        end
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
    end
end

---------------------------------------------------------------
-- /tp [location]
---------------------------------------------------------------
cmds["tp"] = function(args, p)
    if (args[1] == "" or args[1] == nil) then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Please input place to teleport to.", "All")
    else
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Teleporting to '" .. args[1] .. "'!", "All")

        local loc = string.lower(args[1])
        if loc == "bank" then
            player.Character.HumanoidRootPart.Anchored = false

            -- Get which alt index (1..38). If the index is bigger than we have positions, default to the first
            local idx = getAltIndex()
            if idx and bankPositions[idx] then
                player.Character.HumanoidRootPart.CFrame = bankPositions[idx]
            else
                player.Character.HumanoidRootPart.CFrame = bankPositions[1]
            end

        elseif loc == "safezone1" then
            player.Character.HumanoidRootPart.Anchored = false
            player.Character.HumanoidRootPart.CFrame = CFrame.new(
                -117.270287, -58.7000618, 146.536087,
                 0.999873519, 5.21876942e-08, -0.0159031227,
                -5.22713037e-08, 1, -4.84179008e-09,
                 0.0159031227, 5.67245495e-09, 0.999873519
            )

        elseif loc == "safezone2" then
            player.Character.HumanoidRootPart.Anchored = false
            player.Character.HumanoidRootPart.CFrame = CFrame.new(
                207.48085, 38.25, 200014.953,
                0.507315397, 0, -0.861760437,
                0, 1, 0,
                0.861760437, 0, 0.507315397
            )

        elseif loc == "station" then
            player.Character.HumanoidRootPart.Anchored = false
            player.Character.HumanoidRootPart.CFrame = CFrame.new(
                591.680725, 49.0000458, -256.818298,
               -0.0874911696, -3.41755495e-08, -0.996165276,
                1.23318324e-08, 1, -3.53901868e-08,
                0.996165276, -1.53808717e-08, -0.0874911696
            )

        elseif loc == "taco" then
            player.Character.HumanoidRootPart.Anchored = false
            player.Character.HumanoidRootPart.CFrame = CFrame.new(
                583.931641, 51.061409, -476.954193,
               -0.999745369, 1.49123665e-08, -0.0225663595,
                1.44838328e-08, 1, 1.91533687e-08,
                0.0225663595, 1.88216429e-08, -0.999745369
            )
        end
    end
end

---------------------------------------------------------------
-- /tpf [location] (same as /tp but anchors them at the end)
---------------------------------------------------------------
cmds["tpf"] = function(args, p)
    if (args[1] == "" or args[1] == nil) then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Please input place to teleport to.", "All")
    else
        player.Character.HumanoidRootPart.Anchored = false
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Teleporting to '" .. args[1] .. "'!", "All")

        local loc = string.lower(args[1])
        if loc == "bank" then
            local idx = getAltIndex()
            if idx and bankPositions[idx] then
                player.Character.HumanoidRootPart.CFrame = bankPositions[idx]
            else
                player.Character.HumanoidRootPart.CFrame = bankPositions[1]
            end

        elseif loc == "safezone1" then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(
                -117.270287, -58.7000618, 146.536087,
                 0.999873519, 5.21876942e-08, -0.0159031227,
                -5.22713037e-08, 1, -4.84179008e-09,
                 0.0159031227, 5.67245495e-09, 0.999873519
            )

        elseif loc == "safezone2" then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(
                207.48085, 38.25, 200014.953,
                0.507315397, 0, -0.861760437,
                0, 1, 0,
                0.861760437, 0, 0.507315397
            )

        elseif loc == "station" then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(
                591.680725, 49.0000458, -256.818298,
               -0.0874911696, -3.41755495e-08, -0.996165276,
                1.23318324e-08, 1, -3.53901868e-08,
                0.996165276, -1.53808717e-08, -0.0874911696
            )

        elseif loc == "taco" then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(
                583.931641, 51.061409, -476.954193,
               -0.999745369, 1.49123665e-08, -0.0225663595,
                1.44838328e-08, 1, 1.91533687e-08,
                0.0225663595, 1.88216429e-08, -0.999745369
            )
        end

        wait(0.3)
        player.Character.HumanoidRootPart.Anchored = true
    end
end

---------------------------------------------------------------
cmds["start"] = function(args, p)
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Started Dropping!", "All")
    dropping = true
    repeat
        game.ReplicatedStorage.MainEvent:FireServer("DropMoney", 17500)
        wait(0.3)
    until dropping == false
end

cmds["stop"] = function(args, p)
    dropping = false
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Stopped dropping!", "All")
end

cmds["goto"] = function(args, p)
    if (args[1] == "" or args[1] == nil) then
        player.Character.HumanoidRootPart.Anchored = false
        player.Character.HumanoidRootPart.CFrame = game.Workspace:FindFirstChild(p.Name).HumanoidRootPart.CFrame
    else
        if (game.Workspace:FindFirstChild(args[1]) == nil) then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Character doesn't exist.", "All")
        else
            player.Character.HumanoidRootPart.CFrame = game.Workspace:FindFirstChild(args[1]).HumanoidRootPart.CFrame
        end
    end
end

cmds["rejoin"] = function(args, p)
    local tpservice = game:GetService("TeleportService")
    local plr = game.Players.LocalPlayer
    tpservice:Teleport(game.PlaceId, plr)
end

cmds["wallet"] = function(args, p)
    if (wallet == false) then
        game.Players.LocalPlayer.Character.Humanoid:EquipTool(
            game.Players.LocalPlayer.Backpack:FindFirstChild("Wallet")
        )
        wallet = true
    else
        if game.Players.LocalPlayer.Character:FindFirstChild("Wallet") then
            game.Players.LocalPlayer.Character.Humanoid:UnequipTools()
        end
        wallet = false
    end
end

---------------------------------------------------------------
-- AIRWALK helper code:
---------------------------------------------------------------
local RunService = game:GetService("RunService")

local function ForEach(t, f)
    for Index, Value in pairs(t) do
        f(Value, Index)
    end
end
_G.ForEach = ForEach

local function Create(ClassName)
    local Object = Instance.new(ClassName)
    return function(Properties)
        ForEach(Properties, function(Value, Property)
            Object[Property] = Value
        end)
        return Object
    end
end
_G.Create = Create

do
    local airwalkState = false
    local currentPart = nil
    RunService.RenderStepped:Connect(function()
        if airwalkState then
            if not currentPart then
                warn("On")
                currentPart = Create("Part") {
                    Parent = workspace.CurrentCamera,
                    Name = "AWP",
                    Transparency = 1,
                    Size = Vector3.new(2, 1, 2),
                    Anchored = true,
                }
            end
            local character = game.Players.LocalPlayer.Character
            if character then
                currentPart.CFrame = character.HumanoidRootPart.CFrame - Vector3.new(0, 3.6, 0)
            end
        else
            if currentPart then
                warn("Off")
                currentPart:Destroy()
                currentPart = nil
            end
        end
    end)
end

---------------------------------------------------------------
cmds["airlock"] = function(args, p)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.Anchored = false
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.Jump = true
        end
        wait(0.3)
        char.HumanoidRootPart.Anchored = true
    end
end

cmds["spot"] = function(args, p)
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        local controllerRoot = p.Character.HumanoidRootPart
        player.Character.HumanoidRootPart.Anchored = false
        local targetCFrame = controllerRoot.CFrame * CFrame.new(0, 0, -2)
        player.Character.HumanoidRootPart.CFrame = targetCFrame
        wait(0.3)
        player.Character.HumanoidRootPart.Anchored = true
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Spot!", "All")
    else
        warn("Controller's HumanoidRootPart not found; cannot execute spot command.")
    end
end

---------------------------------------------------------------
-- Optional "whoami" command, to confirm alt indexing
---------------------------------------------------------------
cmds["whoami"] = function(args, p)
    local idx = getAltIndex()
    local userId = player.UserId

    if idx then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
            FireServer("I am alt #" .. tostring(idx) .. " with userId " .. tostring(userId), "All")
    else
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
            FireServer("I am not recognized as an alt in LSDropper.alts", "All")
    end
end

---------------------------------------------------------------
_G.LSCommands = cmds
---------------------------------------------------------------
