-- Commands.lua
local cmds = {}
local player = game.Players.LocalPlayer
local cl = _G.LSDropper
local adMessage = cl.adx or "LS"

-- Globals
wallet = false
dropping = false
cDropping = false
airlock = false
advertising = false

-- HELPER: parse short input (e.g., "100k", "3m")
local function parseShortInput(str)
    if not str then return nil end
    str = string.lower(str)
    local multiplier = 1
    local lastChar = string.sub(str, -1)
    if lastChar == "m" then
        multiplier = 1000000
        str = string.sub(str, 1, -2)
    elseif lastChar == "k" then
        multiplier = 1000
        str = string.sub(str, 1, -2)
    end
    local numeric = tonumber(str)
    if not numeric then
        return nil
    end
    return math.floor(numeric * multiplier)
end

-- HELPER: format large integers (e.g. 150000 -> "150k")
local function shortNumber(n)
    if n >= 1000000 then
        local remainder = n % 1000000
        if remainder == 0 then
            return string.format("%dm", n // 1000000)
        else
            return string.format("%.2fm", n / 1000000)
        end
    elseif n >= 1000 then
        local remainder = n % 1000
        if remainder == 0 then
            return string.format("%dk", n // 1000)
        else
            return string.format("%.2fk", n / 1000)
        end
    else
        return tostring(n)
    end
end

-- HELPER: get dynamic alt index from AltLogger
local function getAltIndex()
    local pos = _G.LSDropper.AltLogger:getAltPosition()
    return pos or 1
end

-- Example grid-based positioning code
local function getGridPosition(index, columns, rows, xStart, xEnd, zStart, zEnd, y)
    local total = columns * rows
    if index < 1 then index = 1 end
    if index > total then index = total end
    local row = math.floor((index - 1) / columns)
    local col = (index - 1) % columns
    local x = xStart + (col * (xEnd - xStart) / (columns - 1))
    local z = zStart + (row * (zEnd - zStart) / (rows - 1))
    return CFrame.new(x, y, z)
end

local function getBankPosition(altIndex)
    local base = getGridPosition(altIndex, 5, 6, -390, -359, -338, -306, 21)
    return base * CFrame.Angles(0, math.rad(0), 0)
end

local function getKlubPosition(altIndex)
    local base = getGridPosition(altIndex, 5, 6, -290, -240, -404, -354, -6.2)
    return base * CFrame.Angles(0, math.rad(0), 0)
end

local function getRoofPosition(altIndex)
    local base = getGridPosition(altIndex, 5, 6, -446, -516, -304, -267, 39)
    return base * CFrame.Angles(0, math.rad(270), 0)
end

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

local function getMoneyOnFloor()
    local total = 0
    local dropFolder = workspace:FindFirstChild("Ignored") and workspace.Ignored:FindFirstChild("Drop")
    if not dropFolder then return 0 end
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

local function dropBag(amount)
    game.ReplicatedStorage.MainEvent:FireServer("DropMoney", amount)
end

-- Commands:
-- (Same as your original code, just referencing getAltIndex() where needed)

cmds["rejoin"] = function(args, p)
    game:GetService("TeleportService"):Teleport(game.PlaceId, player)
end

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

cmds["drop"] = function(args, p)
    if not dropping then
        dropping = true
        cDropping = false
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

cmds["cdrop"] = function(args, p)
    local textAmount = args[1]
    local numberToAdd = parseShortInput(textAmount)
    if numberToAdd then
        dropping = false
        cDropping = true
        local oldMoney = getMoneyOnFloor()
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Started cdrop! $"..shortNumber(numberToAdd), "All")
        dropBag(15000)
        coroutine.wrap(function()
            repeat
                wait(0.5)
                dropBag(15000)
            until not cDropping or (getMoneyOnFloor() >= (oldMoney + numberToAdd))
            if cDropping then
                cDropping = false
                dropping = false
                local finalAmount = shortNumber(getMoneyOnFloor())
                game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Cdrop done! $"..finalAmount, "All")
            end
        end)()
    else
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Usage: /cdrop <limit> (e.g. /cdrop 500k)", "All")
    end
end

cmds["dropped"] = function(args, p)
    local floorTotal = getMoneyOnFloor()
    local shortVal = shortNumber(floorTotal)
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Current floor total: $"..shortVal, "All")
end

cmds["stop"] = function(args, p)
    dropping = false
    cDropping = false
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Stopped!", "All")
end

local function teleportToLocation(loc, anchorAfter)
    local altIdx = getAltIndex() or 1
    local hrp = player.Character.HumanoidRootPart
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(loc.."!", "All")
    hrp.Anchored = false
    local currentRot = hrp.CFrame - hrp.CFrame.p
    if loc == "bank" then
        hrp.CFrame = getBankPosition(altIdx) * currentRot
    elseif loc == "klub" then
        hrp.CFrame = getKlubPosition(altIdx) * currentRot
    elseif loc == "train" then
        hrp.CFrame = (trainPositions[altIdx] or trainPositions[1]) * currentRot
    elseif loc == "roof" then
        hrp.CFrame = getRoofPosition(altIdx) * currentRot
    end
    if anchorAfter then
        wait(0.3)
        hrp.Anchored = true
    end
end

cmds["tp"] = function(args, p)
    if not args[1] or args[1] == "" then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Please input a valid location.", "All")
        return
    end
    teleportToLocation(string.lower(args[1]), false)
end

cmds["tpf"] = function(args, p)
    if not args[1] or args[1] == "" then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Please input place to teleport to.", "All")
        return
    end
    teleportToLocation(string.lower(args[1]), true)
end

cmds["goto"] = function(args, p)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.Anchored = false
    if not args[1] or args[1] == "" then
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

cmds["airlock"] = function(args, p)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local height = 10
    if args[1] then
        local customHeight = tonumber(args[1])
        if customHeight then
            height = customHeight
        end
    end
    local currentCFrame = hrp.CFrame
    local currentRot = currentCFrame - currentCFrame.p
    hrp.Anchored = false
    hrp.Velocity = Vector3.new(0,0,0)
    hrp.RotVelocity = Vector3.new(0,0,0)
    task.wait(0.3)
    local currentPos = hrp.Position
    local targetY = currentPos.Y + height
    local platform = Instance.new("Part")
    platform.Name = "AirlockPlatform"
    platform.Size = Vector3.new(5, 1, 5)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Position = Vector3.new(currentPos.X, targetY - 0.5, currentPos.Z)
    platform.Parent = workspace
    hrp.CFrame = CFrame.new(currentPos.X, targetY + 0.5, currentPos.Z) * currentRot
    task.wait(0.2)
    hrp.Anchored = true
    airlock = true
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Airlocked", "All")
    task.wait(0.1)
    if platform and platform.Parent then
        platform:Destroy()
    end
end

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

cmds["spot"] = function(args, p)
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        local controllerRoot = p.Character.HumanoidRootPart
        local hrp = player.Character.HumanoidRootPart
        hrp.Anchored = false
        hrp.CFrame = controllerRoot.CFrame * CFrame.new(0, 0, -2)
        wait(0.3)
        hrp.Anchored = true
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Spot!", "All")
    else
        warn("Controller's HumanoidRootPart not found; cannot execute spot command.")
    end
end

cmds["bring"] = function(args, p)
    if not args[1] or args[1] == "" then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Usage: /bring <playerName>", "All")
        return
    end
    local partial = string.lower(args[1])
    local foundPlayer = nil
    for _,plr in pairs(game.Players:GetPlayers()) do
        if string.sub(string.lower(plr.Name),1,#partial) == partial then
            foundPlayer = plr
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

cmds["line"] = function(args, p)
    if not (p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")) then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Controller not found.", "All")
        return
    end
    local hrp = player.Character.HumanoidRootPart
    hrp.Anchored = false
    local controllerRoot = p.Character.HumanoidRootPart
    local formationBase = controllerRoot.CFrame * CFrame.new(0, 0, 2)
    local altCount = #(_G.LSDropper.alts or {})
    local myIndex = getAltIndex()
    if not myIndex then return end
    local mid = (altCount + 1) / 2
    local offsetDist = (myIndex - mid) * 2
    local rightVec = controllerRoot.CFrame.RightVector
    local targetPos = formationBase.Position + rightVec * offsetDist
    hrp.CFrame = CFrame.new(targetPos, targetPos + controllerRoot.CFrame.LookVector)
    wait(0.3)
    hrp.Anchored = true
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Line!", "All")
end

cmds["circle"] = function(args, p)
    if not (p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")) then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Controller not found.", "All")
        return
    end
    local hrp = player.Character.HumanoidRootPart
    hrp.Anchored = false
    local controllerRoot = p.Character.HumanoidRootPart
    local basePos = controllerRoot.Position
    local altCount = #(_G.LSDropper.alts or {})
    local myIndex = getAltIndex()
    if not myIndex then return end
    local anglePerAlt = math.rad(360 / altCount)
    local myAngle = (myIndex - 1) * anglePerAlt
    local rotatedDir = (CFrame.fromAxisAngle(Vector3.new(0,1,0), myAngle)
        * Vector3.new(controllerRoot.CFrame.LookVector.X,
                      controllerRoot.CFrame.LookVector.Y,
                      controllerRoot.CFrame.LookVector.Z)).Unit
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

cmds["hide"] = function(args, p)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = false
        wait(0.1)
        hrp.CFrame = CFrame.new(hrp.Position.X, -10, hrp.Position.Z)
        wait(0.2)
        hrp.Anchored = true
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Hidden underground!", "All")
    end
end

cmds["ad"] = function(args, p)
    if advertising then
        advertising = false
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Stopped!", "All")
        return
    end
    advertising = true
    coroutine.wrap(function()
        while advertising do
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(adMessage, "All")
            wait(10)
        end
    end)()
end

cmds["admsg"] = function(args, p)
    local text = table.concat(args, " ")
    if text == "" then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Usage: /admsg <newMessage>", "All")
        return
    end
    adMessage = text
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Ad = "..adMessage, "All")
end

cmds["code"] = function(args, p)
    local codeToRedeem = table.concat(args, " ")
    if codeToRedeem == "" then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Usage: /code <SomeDahoodCode>", "All")
        return
    end
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Redeeming code: "..codeToRedeem, "All")
    game:GetService("ReplicatedStorage"):WaitForChild("MainEvent"):FireServer("EnterPromoCode", codeToRedeem)
end

cmds["say"] = function(args, p)
    local message = table.concat(args, " ")
    if message == "" then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Usage: /say <message>", "All")
        return
    end
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
end

_G.LSCommands = cmds
