---------------------------------------------------------------
-- Commands.lua
---------------------------------------------------------------
local cmds = {}
local player = game.Players.LocalPlayer

wallet = false
dropping = false   -- for /drop
cDropping = false  -- for /cdrop
blocking = false

---------------------------------------------------------------
-- 1) HELPER: Parse short-format user input => integer
--    "1m" => 1000000, "50k" => 50000, "12345" => 12345
---------------------------------------------------------------
local function parseShortInput(str)
    if not str then return nil end
    str = string.lower(str)

    local multiplier = 1
    local lastChar = string.sub(str, -1)
    if lastChar == "m" then
        multiplier = 1000000
        str = string.sub(str, 1, -2) -- remove 'm'
    elseif lastChar == "k" then
        multiplier = 1000
        str = string.sub(str, 1, -2) -- remove 'k'
    end

    local numeric = tonumber(str)
    if not numeric then
        return nil
    end

    return math.floor(numeric * multiplier)
end

---------------------------------------------------------------
-- 2) HELPER: Format large integers in short form
--    1000000 => "1m", 1250000 => "1.25m", 100000 => "100k"
---------------------------------------------------------------
local function shortNumber(n)
    if n >= 1000000 then
        local remainder = n % 1000000
        if remainder == 0 then
            return string.format("%dm", n // 1000000)
        else
            local val = n / 1000000
            return string.format("%.2fm", val)
        end
    elseif n >= 1000 then
        local remainder = n % 1000
        if remainder == 0 then
            return string.format("%dk", n // 1000)
        else
            local val = n / 1000
            return string.format("%.2fk", val)
        end
    else
        return tostring(n)
    end
end

---------------------------------------------------------------
-- 3) HELPER: Figure out which alt index this local player is.
---------------------------------------------------------------
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
-- 4) Large bankPositions array (Alt1..Alt38)
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
-- 5) Summation of money on the floor
--    Looks under workspace.Drop for each "MoneyDrop" with
--    BillboardGui -> TextLabel (e.g. "$12,250")
---------------------------------------------------------------
local function getMoneyOnFloor()
    local total = 0
    local dropFolder = workspace:FindFirstChild("Drop")
    if not dropFolder then
        return 0
    end
    
    for _, obj in pairs(dropFolder:GetChildren()) do
        if obj.Name == "MoneyDrop" then
            local billboard = obj:FindFirstChild("BillboardGui")
            if billboard then
                local label = billboard:FindFirstChild("TextLabel")
                if label and label:IsA("TextLabel") then
                    local text = label.Text or ""
                    local numericString = text:gsub("[^%d]", "") 
                    local amount = tonumber(numericString)
                    if amount then
                        total += amount
                    end
                end
            end
        end
    end
    return total
end

---------------------------------------------------------------
-- Helper to drop a bag of money
---------------------------------------------------------------
local function dropBag(amount)
    game.ReplicatedStorage.MainEvent:FireServer("DropMoney", amount)
end

---------------------------------------------------------------
-- re -> Respawn
---------------------------------------------------------------
cmds["re"] = function(args, p)
    local origin_spot = player.Character.HumanoidRootPart.CFrame
    player.Character.Humanoid.Health = 0
    wait(7.5)
    player.Character.HumanoidRootPart.CFrame = origin_spot
end

---------------------------------------------------------------
-- freeze -> Toggles anchored
---------------------------------------------------------------
cmds["freeze"] = function(args, p)
    player.Character.HumanoidRootPart.Anchored = not player.Character.HumanoidRootPart.Anchored
end

---------------------------------------------------------------
-- chat -> /chat [message...]
---------------------------------------------------------------
cmds["chat"] = function(args, p)
    if (args[1] == "" or args[1] == nil) then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("LS ON TOP!", "All")
    else
        local str = ""
        for i = 1, 50 do
            if (args[i]) then
                str = str .. " " .. args[i]
            end
        end
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
    end
end

---------------------------------------------------------------
-- drop (infinite) => /drop
---------------------------------------------------------------
cmds["drop"] = function(args, p)
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Started Dropping!", "All")
    dropping = true
    repeat
        dropBag(15000)  -- 15k per bag
        wait(0.3)
    until not dropping
end

---------------------------------------------------------------
-- cdrop => /cdrop <limitShort>
-- e.g. /cdrop 500k => drop 15k each time until floor >= 500,000
-- e.g. /cdrop 1m   => drop 15k each time until floor >= 1,000,000
---------------------------------------------------------------
cmds["cdrop"] = function(args, p)
    local floorLimit = parseShortInput(args[1])
    if not floorLimit then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
            "[LS] Usage: /cdrop <limit> (e.g. /cdrop 500k)", 
            "All"
        )
        return
    end

    local limitMsg = shortNumber(floorLimit)
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
        "[LS] Conditional Dropping... bag=15k, limit="..limitMsg, 
        "All"
    )

    cDropping = true
    while cDropping do
        local currentFloor = getMoneyOnFloor()
        if currentFloor < floorLimit then
            dropBag(15000)   -- always 15k
            wait(0.3)
        else
            local shortFinal = shortNumber(currentFloor)
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
                "[LS] cdrop done! Floor has $"..shortFinal.." now.",
                "All"
            )
            cDropping = false
        end

        if not cDropping then
            break
        end
    end
end

---------------------------------------------------------------
-- dropped => /dropped
-- Announces how much is on the floor in short format
---------------------------------------------------------------
cmds["dropped"] = function(args, p)
    local floorTotal = getMoneyOnFloor()
    local shortValue = shortNumber(floorTotal)
    local msg = "[LS] Current floor total: $" .. shortValue
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
end

---------------------------------------------------------------
-- stop => stops both /drop and /cdrop
---------------------------------------------------------------
cmds["stop"] = function(args, p)
    dropping = false
    cDropping = false
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Stopped dropping!", "All")
end

---------------------------------------------------------------
-- tp, tpf, goto, rejoin, wallet, etc.
-- These remain unchanged from before...
-- Bank teleports for alt #1..#38, etc.
---------------------------------------------------------------
cmds["tp"] = function(args, p)
    if (not args[1] or args[1] == "") then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Please input place to teleport to.", "All")
    else
        local loc = string.lower(args[1])
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Teleporting to '" .. loc .. "'!", "All")

        if loc == "bank" then
            player.Character.HumanoidRootPart.Anchored = false
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

cmds["tpf"] = function(args, p)
    if (not args[1] or args[1] == "") then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Please input place to teleport to.", "All")
    else
        player.Character.HumanoidRootPart.Anchored = false
        local loc = string.lower(args[1])
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Teleporting to '" .. loc .. "'!", "All")

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

cmds["goto"] = function(args, p)
    if (not args[1] or args[1] == "") then
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
    tpservice:Teleport(game.PlaceId, player)
end

cmds["wallet"] = function(args, p)
    if (wallet == false) then
        local backpack = player.Backpack
        if backpack:FindFirstChild("Wallet") then
            player.Character.Humanoid:EquipTool(backpack.Wallet)
        end
        wallet = true
    else
        if player.Character:FindFirstChild("Wallet") then
            player.Character.Humanoid:UnequipTools()
        end
        wallet = false
    end
end

---------------------------------------------------------------
-- AIRWALK code
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
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
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
-- Expose to _G
---------------------------------------------------------------
_G.LSCommands = cmds
