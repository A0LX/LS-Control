---------------------------------------------------------------
-- Commands.lua (with old cdrop logic, no vault/admin alt spots)
---------------------------------------------------------------
local cmds = {}
local player = game.Players.LocalPlayer

wallet = false
dropping = false   -- for /drop
cDropping = false  -- for /cdrop
airlock = false

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

local bankPositions = {
    [1]  = CFrame.new(-390,   21, -338),
    [2]  = CFrame.new(-383.8, 21, -338),
    [3]  = CFrame.new(-377.6, 21, -338),
    [4]  = CFrame.new(-371.4, 21, -338),
    [5]  = CFrame.new(-365.2, 21, -338),
    [6]  = CFrame.new(-359,   21, -338),
    [7]  = CFrame.new(-390,   21, -330),
    [8]  = CFrame.new(-383.8, 21, -330),
    [9]  = CFrame.new(-377.6, 21, -330),
    [10] = CFrame.new(-371.4, 21, -330),
    [11] = CFrame.new(-365.2, 21, -330),
    [12] = CFrame.new(-359,   21, -330),
    [13] = CFrame.new(-390,   21, -322),
    [14] = CFrame.new(-383.8, 21, -322),
    [15] = CFrame.new(-377.6, 21, -322),
    [16] = CFrame.new(-371.4, 21, -322),
    [17] = CFrame.new(-365.2, 21, -322),
    [18] = CFrame.new(-359,   21, -322),
    [19] = CFrame.new(-390,   21, -314),
    [20] = CFrame.new(-383.8, 21, -314),
    [21] = CFrame.new(-377.6, 21, -314),
    [22] = CFrame.new(-371.4, 21, -314),
    [23] = CFrame.new(-365.2, 21, -314),
    [24] = CFrame.new(-359,   21, -314),
    [25] = CFrame.new(-390,   21, -306),
    [26] = CFrame.new(-383.8, 21, -306),
    [27] = CFrame.new(-377.6, 21, -306),
    [28] = CFrame.new(-371.4, 21, -306),
    [29] = CFrame.new(-365.2, 21, -306),
    [30] = CFrame.new(-359,   21, -306),
}

local klubPositions = {
    [1]  = CFrame.new(-290,   -6.2, -404),
    [2]  = CFrame.new(-277.5, -6.2, -404),
    [3]  = CFrame.new(-265,   -6.2, -404),
    [4]  = CFrame.new(-252.5, -6.2, -404),
    [5]  = CFrame.new(-240,   -6.2, -404),
    [6]  = CFrame.new(-290,   -6.2, -394),
    [7]  = CFrame.new(-277.5, -6.2, -394),
    [8]  = CFrame.new(-265,   -6.2, -394),
    [9]  = CFrame.new(-252.5, -6.2, -394),
    [10] = CFrame.new(-240,   -6.2, -394),
    [11] = CFrame.new(-290,   -6.2, -384),
    [12] = CFrame.new(-277.5, -6.2, -384),
    [13] = CFrame.new(-265,   -6.2, -384),
    [14] = CFrame.new(-252.5, -6.2, -384),
    [15] = CFrame.new(-240,   -6.2, -384),
    [16] = CFrame.new(-290,   -6.2, -374),
    [17] = CFrame.new(-277.5, -6.2, -374),
    [18] = CFrame.new(-265,   -6.2, -374),
    [19] = CFrame.new(-252.5, -6.2, -374),
    [20] = CFrame.new(-240,   -6.2, -374),
    [21] = CFrame.new(-290,   -6.2, -364),
    [22] = CFrame.new(-277.5, -6.2, -364),
    [23] = CFrame.new(-265,   -6.2, -364),
    [24] = CFrame.new(-252.5, -6.2, -364),
    [25] = CFrame.new(-240,   -6.2, -364),
    [26] = CFrame.new(-290,   -6.2, -354),
    [27] = CFrame.new(-277.5, -6.2, -354),
    [28] = CFrame.new(-265,   -6.2, -354),
    [29] = CFrame.new(-252.5, -6.2, -354),
    [30] = CFrame.new(-240,   -6.2, -354),
}


local trainPositions = {
    [1]  = CFrame.new(600, 34, -150),
    [2]  = CFrame.new(601, 34, -150),
    [3]  = CFrame.new(602, 34, -150),
    [4]  = CFrame.new(603, 34, -150),
    [5]  = CFrame.new(604, 34, -150),
    [6]  = CFrame.new(605, 34, -150),
    [7]  = CFrame.new(606, 34, -150),
    [8]  = CFrame.new(607, 34, -150),
    [9]  = CFrame.new(608, 34, -150),
    [10] = CFrame.new(609, 34, -150),
    -- expand to [38] as needed...
}

---------------------------------------------------------------
-- Summation of money on the floor
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
-- Helper to drop a bag of money (always 15k)
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
    player.Character.HumanoidRootPart.Anchored = 
        not player.Character.HumanoidRootPart.Anchored
end

---------------------------------------------------------------
-- chat -> /chat [message...]
---------------------------------------------------------------
cmds["chat"] = function(args, p)
    if (args[1] == "" or args[1] == nil) then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
            FireServer("LS ON TOP!", "All")
    else
        local str = ""
        for i = 1, 50 do
            if (args[i]) then
                str = str .. " " .. args[i]
            end
        end
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
            FireServer(str, "All")
    end
end

---------------------------------------------------------------
-- drop => /drop (infinite)
---------------------------------------------------------------
cmds["drop"] = function(args, p)
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
        FireServer("[LS] Started Dropping!", "All")
    dropping = true
    repeat
        dropBag(15000)
        wait(0.3)
    until not dropping
end

---------------------------------------------------------------
-- cdrop => /cdrop <limitShort>
-- (OLD LOGIC restored per request)
---------------------------------------------------------------
cmds["cdrop"] = function(args, p)
    local floorLimit = parseShortInput(args[1])
    if not floorLimit then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
            FireServer("[LS] Usage: /cdrop <limit> (e.g. /cdrop 500k)", "All")
        return
    end

    local limitMsg = shortNumber(floorLimit)
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
        FireServer("[LS] Started dropping "..limitMsg, "All")

    cDropping = true
    while cDropping do
        local currentFloor = getMoneyOnFloor()
        if currentFloor < floorLimit then
            dropBag(15000)   -- always 15k
            wait(0.3)
        else
            local shortFinal = shortNumber(currentFloor)
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
                FireServer("[LS] Done dropping "..shortFinal..".", "All")
            cDropping = false
        end

        if not cDropping then
            break
        end
    end
end

---------------------------------------------------------------
-- dropped => /dropped
---------------------------------------------------------------
cmds["dropped"] = function(args, p)
    local floorTotal = getMoneyOnFloor()
    local shortValue = shortNumber(floorTotal)
    local msg = "[LS] Current floor total: $" .. shortValue
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
        FireServer(msg, "All")
end

---------------------------------------------------------------
-- stop => stops /drop and /cdrop
---------------------------------------------------------------
cmds["stop"] = function(args, p)
    dropping = false
    cDropping = false
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
        FireServer("[LS] Stopped dropping!", "All")
end

---------------------------------------------------------------
-- tp => /tp [bank, klub, train, safezone1, safezone2, station, taco]
---------------------------------------------------------------
cmds["tp"] = function(args, p)
    if (not args[1] or args[1] == "") then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
            FireServer("[LS] Please input place to teleport to.", "All")
        return
    end

    local loc = string.lower(args[1])
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
        FireServer("[LS] Teleporting to '" .. loc .. "'!", "All")

    player.Character.HumanoidRootPart.Anchored = false
    local altIdx = getAltIndex() or 1

    if loc == "bank" then
        if bankPositions[altIdx] then
            player.Character.HumanoidRootPart.CFrame = bankPositions[altIdx]
        else
            player.Character.HumanoidRootPart.CFrame = bankPositions[1]
        end

    elseif loc == "klub" then
        if klubPositions[altIdx] then
            player.Character.HumanoidRootPart.CFrame = klubPositions[altIdx]
        else
            player.Character.HumanoidRootPart.CFrame = klubPositions[1]
        end

    elseif loc == "train" then
        if trainPositions[altIdx] then
            player.Character.HumanoidRootPart.CFrame = trainPositions[altIdx]
        else
            player.Character.HumanoidRootPart.CFrame = trainPositions[1]
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
end

---------------------------------------------------------------
-- tpf => same as /tp but then "Anchors"
---------------------------------------------------------------
cmds["tpf"] = function(args, p)
    if (not args[1] or args[1] == "") then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
            FireServer("[LS] Please input place to teleport to.", "All")
        return
    end

    local loc = string.lower(args[1])
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
        FireServer("[LS] Teleporting to '" .. loc .. "'!", "All")

    player.Character.HumanoidRootPart.Anchored = false
    local altIdx = getAltIndex() or 1

    if loc == "bank" then
        if bankPositions[altIdx] then
            player.Character.HumanoidRootPart.CFrame = bankPositions[altIdx]
        else
            player.Character.HumanoidRootPart.CFrame = bankPositions[1]
        end

    elseif loc == "klub" then
        if klubPositions[altIdx] then
            player.Character.HumanoidRootPart.CFrame = klubPositions[altIdx]
        else
            player.Character.HumanoidRootPart.CFrame = klubPositions[1]
        end

    elseif loc == "train" then
        if trainPositions[altIdx] then
            player.Character.HumanoidRootPart.CFrame = trainPositions[altIdx]
        else
            player.Character.HumanoidRootPart.CFrame = trainPositions[1]
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

---------------------------------------------------------------
-- goto => /goto [playerName]
---------------------------------------------------------------
cmds["goto"] = function(args, p)
    if (not args[1] or args[1] == "") then
        -- goto p => local alt goto the command sender
        player.Character.HumanoidRootPart.Anchored = false
        local target = game.Workspace:FindFirstChild(p.Name)
        if target and target:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame =
                target.HumanoidRootPart.CFrame
        end
    else
        local target = game.Workspace:FindFirstChild(args[1])
        if not target or not target:FindFirstChild("HumanoidRootPart") then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
                FireServer("[LS] Character doesn't exist.", "All")
        else
            player.Character.HumanoidRootPart.CFrame =
                target.HumanoidRootPart.CFrame
        end
    end
end

---------------------------------------------------------------
-- rejoin => /rejoin
---------------------------------------------------------------
cmds["rejoin"] = function(args, p)
    local tpservice = game:GetService("TeleportService")
    tpservice:Teleport(game.PlaceId, player)
end

---------------------------------------------------------------
-- wallet => toggles wallet equip/unequip
---------------------------------------------------------------
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
-- AIRWALK code (unchanged)
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
                currentPart.CFrame =
                    character.HumanoidRootPart.CFrame - Vector3.new(0, 3.6, 0)
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
-- airlock => floats you in place
---------------------------------------------------------------
cmds["airlock"] = function(args, p)
    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Default height is 10
    local height = 10
    if args[1] then
        local customHeight = tonumber(args[1])
        if customHeight then
            height = customHeight
        end
    end

    -- Unanchor, zero velocity, wait a moment
    hrp.Anchored = false
    hrp.Velocity = Vector3.new(0,0,0)
    hrp.RotVelocity = Vector3.new(0,0,0)
    task.wait(0.1)  -- let alt “settle” so we get consistent results

    -- Shift up by 'height' studs from current position, keep same rotation
    local currentPos = hrp.Position
    local rx, ry, rz = hrp.CFrame:ToEulerAnglesXYZ()
    hrp.CFrame = CFrame.new(currentPos.X, currentPos.Y + height, currentPos.Z)
                  * CFrame.Angles(rx, ry, rz)

    -- Finally anchor
    hrp.Anchored = true
    airlock = true

    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
        "[LS] Airlocked at "..tostring(height).." studs!",
        "All"
    )
end

cmds["unairlock"] = function(args, p)
    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp.Anchored then
        hrp.Anchored = false
        airlock = false
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
            "[LS] Unairlocked!",
            "All"
        )
    end
end


---------------------------------------------------------------
-- spot => /spot
---------------------------------------------------------------
cmds["spot"] = function(args, p)
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        local controllerRoot = p.Character.HumanoidRootPart
        player.Character.HumanoidRootPart.Anchored = false
        local targetCFrame = controllerRoot.CFrame * CFrame.new(0, 0, -2)
        player.Character.HumanoidRootPart.CFrame = targetCFrame
        wait(0.3)
        player.Character.HumanoidRootPart.Anchored = true
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
            FireServer("[LS] Spot!", "All")
    else
        warn("Controller's HumanoidRootPart not found; cannot execute spot command.")
    end
end

---------------------------------------------------------------
-- whoami => prints which alt index we are
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
-- bring => /bring <partialName> => Teleport target to your alt
---------------------------------------------------------------
cmds["bring"] = function(args, p)
    if not args[1] or args[1] == "" then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
            FireServer("[LS] Usage: /bring <playerName>", "All")
        return
    end

    local partial = string.lower(args[1])
    local foundPlayer = nil
    for _,pl in pairs(game.Players:GetPlayers()) do
        if string.sub(string.lower(pl.Name),1,#partial) == partial then
            foundPlayer = pl
            break
        end
    end

    if foundPlayer and foundPlayer.Character and foundPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local altHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if altHRP then
            foundPlayer.Character.HumanoidRootPart.CFrame = altHRP.CFrame + Vector3.new(0,2,0)
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
                FireServer("[LS] Brought "..foundPlayer.Name.." to me!", "All")
        end
    else
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:
            FireServer("[LS] Could not find or bring target "..args[1], "All")
    end
end

---------------------------------------------------------------
-- Expose to _G
---------------------------------------------------------------
_G.LSCommands = cmds
