local cmds = {}
local player = game.Players.LocalPlayer

wallet = false
dropping = false   -- for /drop
cDropping = false  -- for /cdrop
airlock = false

-- 1) HELPER: Parse short-format user input => integer (with debug)
local function parseShortInput(str)
    print("parseShortInput => raw input:", str)
    if not str then return nil end
    str = string.lower(str)
    print("parseShortInput => after lower:", str)

    local multiplier = 1
    local lastChar = string.sub(str, -1)
    print("parseShortInput => lastChar:", lastChar)

    if lastChar == "m" then
        multiplier = 1000000
        str = string.sub(str, 1, -2) -- remove 'm'
        print("parseShortInput => detected 'm', new str:", str, "multiplier:", multiplier)
    elseif lastChar == "k" then
        multiplier = 1000
        str = string.sub(str, 1, -2) -- remove 'k'
        print("parseShortInput => detected 'k', new str:", str, "multiplier:", multiplier)
    end

    local numeric = tonumber(str)
    print("parseShortInput => numeric:", numeric)

    if not numeric then
        return nil
    end

    local finalVal = math.floor(numeric * multiplier)
    print("parseShortInput => finalVal:", finalVal)
    return finalVal
end

-- 2) HELPER: Format large integers in short form
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

-- 3) HELPER: Figure out which alt index this local player is.
local function getAltIndex()
    local userId = player.UserId
    for i, altUserId in pairs(_G.LSDropper.alts or {}) do
        if altUserId == userId then
            return i
        end
    end
    return nil
end

-- Helper: compute a grid-based position from alt index.
local function getGridPosition(index, columns, rows, xStart, xEnd, zStart, zEnd, y)
    local total = columns * rows
    if index < 1 then index = 1 end
    if index > total then index = total end
    local row = math.floor((index - 1) / columns)
    local col = (index - 1) % columns

    -- linearly spread out columns
    local x = xStart + (col * (xEnd - xStart) / (columns - 1))
    -- linearly spread out rows
    local z = zStart + (row * (zEnd - zStart) / (rows - 1))

    return CFrame.new(x, y, z)
end

-- Bank: 6 columns x 5 rows
local function getBankPosition(altIndex)
    return getGridPosition(
        altIndex,         -- index
        6, 5,            -- columns, rows
        -390, -359,      -- xStart, xEnd
        -338, -306,      -- zStart, zEnd
        21               -- y
    )
end

-- Klub: 5 columns x 6 rows
local function getKlubPosition(altIndex)
    return getGridPosition(
        altIndex,          -- index
        5, 6,             -- columns, rows
        -290, -240,       -- xStart, xEnd
        -404, -354,       -- zStart, zEnd
        -6.2              -- y
    )
end

-- Roof: 5 columns x 6 rows (total 30)
-- from start=(-446,39,-304) to end=(-516,39,-267), rotated +90 deg.
local function getRoofPosition(altIndex)
    local base = getGridPosition(
        altIndex,    -- alt index
        5, 6,        -- columns, rows => 30 total
        -446, -516,  -- xStart, xEnd
        -304, -267,  -- zStart, zEnd
        39           -- y
    )
    return base * CFrame.Angles(0, math.rad(90), 0)
end

-- We'll keep train positions as is (small set)
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
}

-- Summation of money on the floor
local function getMoneyOnFloor()
    local total = 0
    local dropFolder = workspace:FindFirstChild("Ignored") and workspace.Ignored:FindFirstChild("Drop")
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
                        total = total + amount
                    end
                end
            end
        end
    end
    return total
end

-- Helper to drop a bag of money
local function dropBag(amount)
    game.ReplicatedStorage.MainEvent:FireServer("DropMoney", amount)
end

-- /rejoin
cmds["rejoin"] = function(args, p)
    local tpservice = game:GetService("TeleportService")
    tpservice:Teleport(game.PlaceId, player)
end

-- /wallet => toggles wallet equip/unequip (FIXED)
cmds["wallet"] = function(args, p)
    local backpack = player.Backpack
    if not wallet then
        if backpack:FindFirstChild("[Wallet]") then
            player.Character.Humanoid:EquipTool(backpack["[Wallet]"])
        end
        wallet = true
    else
        if player.Character:FindFirstChild("[Wallet]") then
            player.Character.Humanoid:UnequipTools()
        end
        wallet = false
    end
end

-- /drop
cmds["drop"] = function(args, p)
    if not dropping then
        dropping = true
        cDropping = false  -- turn off custom dropping if it was on

        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Started Dropping!", "All")

        while dropping do
            dropBag(15000)
            wait(2.5)
        end
    end
end

-- /cdrop with 0.5 s check delay in the loop.
cmds["cdrop"] = function(args, p)
    local textAmount = args[1]
    print("[cdrop] => textAmount:", textAmount)
    local numberToAdd = parseShortInput(textAmount)
    print("[cdrop] => numberToAdd:", numberToAdd)

    local dropFolder = workspace:FindFirstChild("Ignored") and workspace.Ignored:FindFirstChild("Drop")
    print("[cdrop] => dropFolder found?:", dropFolder)

    if numberToAdd and dropFolder then
        dropping = false
        cDropping = true

        local oldMoney = getMoneyOnFloor()
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
            "Started cdrop! $" .. shortNumber(numberToAdd),
            "All"
        )

        dropBag(15000)

        coroutine.wrap(function()
            repeat
                wait(0.5)
                dropBag(15000)
            until not dropFolder
               or not cDropping
               or (getMoneyOnFloor() >= (oldMoney + numberToAdd))

            if cDropping then
                cDropping = false
                dropping = false
                local finalAmount = shortNumber(getMoneyOnFloor())
                game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
                    "Cdrop done! $" .. finalAmount,
                    "All"
                )
            end
        end)()
    else
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
            "Usage: /cdrop <limit> (e.g. /cdrop 500k)",
            "All"
        )
    end
end

-- /dropped
cmds["dropped"] = function(args, p)
    local floorTotal = getMoneyOnFloor()
    local shortValue = shortNumber(floorTotal)
    local msg = "Current floor total: $" .. shortValue
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
end

-- /stop => stops /drop and /cdrop
cmds["stop"] = function(args, p)
    dropping = false
    cDropping = false
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Stopped dropping!", "All")
end

-- Teleport helper that preserves current rotation.
local function teleportToLocation(loc, anchorAfter)
    local altIdx = getAltIndex() or 1
    local hrp = player.Character.HumanoidRootPart
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(loc .. "!", "All")
    hrp.Anchored = false
    local currentRot = hrp.CFrame - hrp.CFrame.p  -- capture rotation only

    if loc == "bank" then
        hrp.CFrame = getBankPosition(altIdx) * currentRot
    elseif loc == "klub" then
        hrp.CFrame = getKlubPosition(altIdx) * currentRot
    elseif loc == "train" then
        if trainPositions[altIdx] then
            hrp.CFrame = trainPositions[altIdx] * currentRot
        else
            hrp.CFrame = trainPositions[1] * currentRot
        end
    elseif loc == "roof" then
        hrp.CFrame = getRoofPosition(altIdx) * currentRot
    end

    if anchorAfter then
        wait(0.3)
        hrp.Anchored = true
    end
end

-- /tp => no anchor after
cmds["tp"] = function(args, p)
    if (not args[1] or args[1] == "") then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Please input a valid location.", "All")
        return
    end
    teleportToLocation(string.lower(args[1]), false)
end

-- /tpf => anchor after
cmds["tpf"] = function(args, p)
    if (not args[1] or args[1] == "") then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Please input place to teleport to.", "All")
        return
    end
    teleportToLocation(string.lower(args[1]), true)
end

-- goto => /goto [playerName]
cmds["goto"] = function(args, p)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    hrp.Anchored = false

    if (not args[1] or args[1] == "") then
        local target = game.Workspace:FindFirstChild(p.Name)
        if target and target:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = target.HumanoidRootPart.CFrame
        end
    else
        local target = game.Workspace:FindFirstChild(args[1])
        if not target or not target:FindFirstChild("HumanoidRootPart") then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Character doesn't exist.", "All")
        else
            hrp.CFrame = target.HumanoidRootPart.CFrame
        end
    end
end

-- /airlock: Creates a temporary platform at the designated height,
-- teleports the player onto it (keeping the same rotation), anchors, then deletes the platform.
cmds["airlock"] = function(args, p)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Determine target height offset (default is 10 studs)
    local height = 10
    if args[1] then
        local customHeight = tonumber(args[1])
        if customHeight then
            height = customHeight
        end
    end

    -- Preserve current rotation
    local currentCFrame = hrp.CFrame
    local currentRot = currentCFrame - currentCFrame.p

    hrp.Anchored = false
    hrp.Velocity = Vector3.new(0,0,0)
    hrp.RotVelocity = Vector3.new(0,0,0)
    task.wait(0.3)

    local currentPos = hrp.Position
    local targetY = currentPos.Y + height

    -- Create temporary platform whose top is exactly at targetY
    local platform = Instance.new("Part")
    platform.Name = "AirlockPlatform"
    platform.Size = Vector3.new(5, 1, 5)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Position = Vector3.new(currentPos.X, targetY - (platform.Size.Y / 2), currentPos.Z)
    platform.Parent = workspace

    -- Teleport the player so that HRP sits on top of the platform,
    -- preserving the current rotation.
    hrp.CFrame = CFrame.new(currentPos.X, targetY + (platform.Size.Y / 2), currentPos.Z) * currentRot
    task.wait(0.2)
    hrp.Anchored = true
    airlock = true
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Airlocked", "All")
    task.wait(0.1)
    if platform and platform.Parent then
        platform:Destroy()
    end
end

-- /unairlock: Unanchors the player while keeping their rotation unchanged.
cmds["unairlock"] = function(args, p)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local currentCFrame = hrp.CFrame  -- preserve rotation
        hrp.Anchored = false
        hrp.CFrame = currentCFrame
        airlock = false
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Unairlocked!", "All")
    end
end

-- /spot => stand behind controlling alt
cmds["spot"] = function(args, p)
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        local controllerRoot = p.Character.HumanoidRootPart
        player.Character.HumanoidRootPart.Anchored = false
        local targetCFrame = controllerRoot.CFrame * CFrame.new(0, 0, -2)
        player.Character.HumanoidRootPart.CFrame = targetCFrame
        wait(0.3)
        player.Character.HumanoidRootPart.Anchored = true
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Spot!", "All")
    else
        warn("Controller's HumanoidRootPart not found; cannot execute spot command.")
    end
end

-- /whoami => prints which alt index we are
cmds["whoami"] = function(args, p)
    local idx = getAltIndex()
    local userId = player.UserId

    if idx then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("I am alt #" .. tostring(idx) .. " with userId " .. tostring(userId), "All")
    else
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("I am not recognized as an alt in LSDropper.alts", "All")
    end
end

-- /bring => /bring <partialName>
cmds["bring"] = function(args, p)
    if not args[1] or args[1] == "" then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Usage: /bring <playerName>", "All")
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
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Brought "..foundPlayer.Name.." to me!", "All")
        end
    else
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Could not find or bring target "..args[1], "All")
    end
end

----------------------------------------------------------
-- New Formation Commands
----------------------------------------------------------

-- /line: Arrange alts in a lateral line relative to the controller.
cmds["line"] = function(args, p)
    if not (p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")) then 
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Controller not found.", "All")
        return 
    end
    player.Character.HumanoidRootPart.Anchored = false
    local controllerRoot = p.Character.HumanoidRootPart
    -- Base formation point is 2 studs behind the controller
    local formationBase = controllerRoot.CFrame * CFrame.new(0, 0, 2)
    
    local altList = _G.LSDropper.alts or {}
    local total = #altList
    local myIndex = getAltIndex()
    if not myIndex then return end

    -- Compute lateral offset.
    local mid = (total + 1) / 2
    local offsetDist = (myIndex - mid) * 2  -- 2 studs spacing
    local rightVec = controllerRoot.CFrame.RightVector

    local targetPos = formationBase.Position + rightVec * offsetDist
    local hrp = player.Character.HumanoidRootPart
    -- Teleport while matching controller’s forward direction
    hrp.CFrame = CFrame.new(targetPos, targetPos + controllerRoot.CFrame.LookVector)
    wait(0.3)
    player.Character.HumanoidRootPart.Anchored = true
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Line!", "All")
end

-- /circle: Arrange alts in a circle around the controller.
cmds["circle"] = function(args, p)
    if not (p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")) then 
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Controller not found.", "All")
        return 
    end
    player.Character.HumanoidRootPart.Anchored = false
    local controllerRoot = p.Character.HumanoidRootPart
    local basePos = controllerRoot.Position
    local altList = _G.LSDropper.alts or {}
    local total = #altList
    local myIndex = getAltIndex()
    if not myIndex then return end

    -- Divide 360° among all alts.
    local anglePerAlt = math.rad(360 / total)
    local myAngle = (myIndex - 1) * anglePerAlt

    -- Rotate controller's forward vector by myAngle around Y.
    local rotatedDir = (CFrame.fromAxisAngle(Vector3.new(0,1,0), myAngle) * Vector3.new(controllerRoot.CFrame.LookVector.X, controllerRoot.CFrame.LookVector.Y, controllerRoot.CFrame.LookVector.Z)).Unit
    local radius = 4  -- 4 studs away from the controller
    local targetPos = basePos + rotatedDir * radius

    local hrp = player.Character.HumanoidRootPart
    hrp.CFrame = CFrame.new(targetPos, targetPos + controllerRoot.CFrame.LookVector)
    wait(0.3)
    player.Character.HumanoidRootPart.Anchored = true
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Circle!", "All")
end

-- Expose commands to _G
_G.LSCommands = cmds
