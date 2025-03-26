local cmds = {}
local player = game.Players.LocalPlayer

local fpsCap = fps or 5
local adMessage = adx or "Fail"

-- Globals
wallet = false
dropping = false    -- for /drop
cDropping = false   -- for /cdrop
airlock = false
advertising = false

--
-- 1) HELPER: Parse short-format user input => integer (with debug)
--
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

--
-- 2) HELPER: Format large integers in short form
--
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

--
-- 3) HELPER: Figure out which alt index this local player is.
--
local function getAltIndex()
    local userId = player.UserId
    for i, altUserId in pairs(_G.LSDropper.alts or {}) do
        if altUserId == userId then
            return i
        end
    end
    return nil
end

--
-- Helper: compute a grid-based position from alt index.
--
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

--
-- Bank: 5 columns x 6 rows
--
local function getBankPosition(altIndex)
    return getGridPosition(
        altIndex,         -- index
        5, 6,            -- columns, rows
        -390, -359,      -- xStart, xEnd
        -338, -306,      -- zStart, zEnd
        21               -- y
    )
    -- If you wanted rotation, you’d do e.g. return base * CFrame.Angles(…)
end

--
-- Klub: 5 columns x 6 rows
--
local function getKlubPosition(altIndex)
    return getGridPosition(
        altIndex,          -- index
        5, 6,             -- columns, rows
        -290, -240,       -- xStart, xEnd
        -404, -354,       -- zStart, zEnd
        -6.2              -- y
    )
end

--
-- Roof: 5 columns x 6 rows (total 30)
--
local function getRoofPosition(altIndex)
    local base = getGridPosition(
        altIndex,    -- alt index
        5, 6,        -- columns, rows => 30 total
        -446, -516,  -- xStart, xEnd
        -304, -267,  -- zStart, zEnd
        39           -- y
    )
    -- Rotate so that “forward” is turned 270 degrees
    return base * CFrame.Angles(0, math.rad(270), 0)
end

--
-- Train positions
--
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

--
-- Summation of money on the floor
--
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

--
-- Helper to drop a bag of money
--
local function dropBag(amount)
    game.ReplicatedStorage.MainEvent:FireServer("DropMoney", amount)
end

--------------------------------------------------------------------------
-- Existing Commands
--------------------------------------------------------------------------

-- /rejoin
cmds["rejoin"] = function(args, p)
    local tpservice = game:GetService("TeleportService")
    tpservice:Teleport(game.PlaceId, player)
end

-- /wallet => toggles wallet equip/unequip
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
    if dropping then
        dropping = false
        cDropping = false
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Stopped dropping!", "All")
    end
end

-- /cdrop with 0.5 s check delay in the loop
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

-- /dropped => checks how much is on the floor
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
    advertising = false  -- also stop advertising
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Stopped!", "All")
end

--
-- Teleport helper that preserves current rotation.
--
local function teleportToLocation(loc, anchorAfter)
    local altIdx = getAltIndex() or 1
    local hrp = player.Character.HumanoidRootPart
    -- For user feedback
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

-- /goto => follow the main player's character
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

-- /airlock => create a temporary platform at specified height
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

    -- Teleport the alt so that HRP sits on top, preserving rotation
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

-- /unairlock => unanchor
cmds["unairlock"] = function(args, p)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local currentCFrame = hrp.CFrame
        hrp.Anchored = false
        hrp.CFrame = currentCFrame
        airlock = false
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Unairlocked!", "All")
    end
end

-- /spot => stand in front of controlling alt
cmds["spot"] = function(args, p)
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        local controllerRoot = p.Character.HumanoidRootPart
        local hrp = player.Character.HumanoidRootPart
        hrp.Anchored = false
        local targetCFrame = controllerRoot.CFrame * CFrame.new(0, 0, -2)
        hrp.CFrame = targetCFrame
        wait(0.3)
        hrp.Anchored = true
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Spot!", "All")
    else
        warn("Controller's HumanoidRootPart not found; cannot execute spot command.")
    end
end

-- /bring => bring target to me
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

-- /line => Arrange alts in a line behind the controller
cmds["line"] = function(args, p)
    if not (p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")) then 
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Controller not found.", "All")
        return 
    end
    local hrp = player.Character.HumanoidRootPart
    hrp.Anchored = false
    
    local controllerRoot = p.Character.HumanoidRootPart
    -- Base formation point is 2 studs behind the controller
    local formationBase = controllerRoot.CFrame * CFrame.new(0, 0, 2)
    
    local altList = _G.LSDropper.alts or {}
    local total = #altList
    local myIndex = getAltIndex()
    if not myIndex then return end

    -- Compute lateral offset
    local mid = (total + 1) / 2
    local offsetDist = (myIndex - mid) * 2  -- spacing
    local rightVec = controllerRoot.CFrame.RightVector

    local targetPos = formationBase.Position + rightVec * offsetDist
    -- Teleport while matching controller’s forward direction
    hrp.CFrame = CFrame.new(targetPos, targetPos + controllerRoot.CFrame.LookVector)
    wait(0.3)
    hrp.Anchored = true
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Line!", "All")
end

-- /circle => Arrange alts in a circle around the controller
cmds["circle"] = function(args, p)
    if not (p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")) then 
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Controller not found.", "All")
        return 
    end
    local hrp = player.Character.HumanoidRootPart
    hrp.Anchored = false

    local controllerRoot = p.Character.HumanoidRootPart
    local basePos = controllerRoot.Position
    local altList = _G.LSDropper.alts or {}
    local total = #altList
    local myIndex = getAltIndex()
    if not myIndex then return end

    -- Circle geometry
    local anglePerAlt = math.rad(360 / total)
    local myAngle = (myIndex - 1) * anglePerAlt

    -- Rotate controller's forward vector by myAngle around Y
    local rotatedDir = (CFrame.fromAxisAngle(Vector3.new(0,1,0), myAngle)
        * Vector3.new(controllerRoot.CFrame.LookVector.X,
                      controllerRoot.CFrame.LookVector.Y,
                      controllerRoot.CFrame.LookVector.Z)
    ).Unit
    local radius = 4
    if args[1] then
        local r = tonumber(args[1])
        if r then
            radius = r
        end
    end

    local targetPos = basePos + rotatedDir * radius
    hrp.CFrame = CFrame.new(targetPos, basePos)
    wait(0.3)
    hrp.Anchored = true
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Circle!", "All")
end

--------------------------------------------------------------------------
-- NEW Commands
--------------------------------------------------------------------------

-- /hide => send alt underground (Y = -10 by default)
cmds["hide"] = function(args, p)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = false
        wait(0.1)
        local currentCFrame = hrp.CFrame
        -- Move alt ~10 studs below ground
        hrp.CFrame = CFrame.new(currentCFrame.X, -10, currentCFrame.Z)
        wait(0.2)
        hrp.Anchored = true
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Hidden underground!", "All")
    end
end

-- /ad => alts start repeatedly chatting the current ad message
-- (stop with /stop or /ad "" to cancel)
cmds["ad"] = function(args, p)
    local text = table.concat(args, " ")
    if text and text ~= "" then
        adMessage = text
    end
    advertising = true
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Started advertising!", "All")

    coroutine.wrap(function()
        while advertising do
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(adMessage, "All")
            wait(15) -- repeat every 3s (adjust if needed)
        end
    end)()
end

-- /admsg => change the advertising message without restarting the ad loop
cmds["admsg"] = function(args, p)
    local text = table.concat(args, " ")
    if text == "" then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Usage: /admsg <newMessage>", "All")
        return
    end
    adMessage = text
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Ad message updated!", "All")
end

-- /fps => set fps cap (if your environment supports setfpscap)
cmds["fps"] = function(args, p)
    local val = tonumber(args[1])
    if val then
        fpsCap = val
        setfpscap(fpsCap)
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("FPS cap set to "..val, "All")
    else
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Usage: /fps <number>", "All")
    end
end

-- Redeem code through chat command
cmds["code"] = function(args, p)
    local codeToRedeem = table.concat(args, " ")
    
    if codeToRedeem == "" then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Usage: /code <SomeDahoodCode>", "All")
        return
    end

    -- Tell the player the code is being redeemed
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Redeeming code: " .. codeToRedeem, "All")

    -- Send the redeem request to the server
    local args = {
        [1] = "EnterPromoCode",
        [2] = codeToRedeem
    }
    game:GetService("ReplicatedStorage"):WaitForChild("MainEvent"):FireServer(unpack(args))
end


-- /say => alt says the provided message once
cmds["say"] = function(args, p)
    local message = table.concat(args, " ")
    if message == "" then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Usage: /say <message>", "All")
        return
    end
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
end

--------------------------------------------------------------------------
-- Expose commands to global
--------------------------------------------------------------------------
_G.LSCommands = cmds
