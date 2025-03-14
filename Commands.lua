---------------------------------------------------------------
local cmds = {}
local player = game.Players.LocalPlayer

---------------------------------------------------------------

wallet = false
dropping = false
blocking = false

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

cmds["tp"] = function(args, p)
    if (args[1] == "" or args[1] == nil) then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Please input place to teleport to.", "All")
    else
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Teleporting to '" .. args[1] .. "'!", "All")
        
        -- Teleport to 'bank' if typed "/tp bank"
        if (string.lower(args[1]) == "bank") then
            player.Character.HumanoidRootPart.Anchored = false
            for i, userId in pairs(_G.LSDropper.alts) do
                if i == "Alt1" or i == 1 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-389, 21, -338)
                elseif i == "Alt2" or i == 2 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-385, 21, -338)
                elseif i == "Alt3" or i == 3 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-380, 21, -337)
                elseif i == "Alt4" or i == 4 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-376, 21, -338)
                elseif i == "Alt5" or i == 5 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-370, 21, -338)
                elseif i == "Alt6" or i == 6 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-366, 21, -338)
                elseif i == "Alt7" or i == 7 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-361, 21, -338)
                elseif i == "Alt8" or i == 8 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-361, 21, -333)
                elseif i == "Alt9" or i == 9 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-365, 21, -334)
                elseif i == "Alt10" or i == 10 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-370, 21, -334)
                elseif i == "Alt11" or i == 11 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-375, 21, -334)
                elseif i == "Alt12" or i == 12 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-381, 21, -334)
                elseif i == "Alt13" or i == 13 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-386, 21, -334)
                elseif i == "Alt14" or i == 14 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-390, 21, -334)
                elseif i == "Alt15" or i == 15 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-390, 21, -331)
                elseif i == "Alt16" or i == 16 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-386, 21, -331)
                elseif i == "Alt17" or i == 17 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-382, 21, -331)
                elseif i == "Alt18" or i == 18 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-376, 21, -331)
                elseif i == "Alt19" or i == 19 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-371, 21, -331)
                elseif i == "Alt20" or i == 20 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-366, 21, -331)
                elseif i == "Alt21" or i == 21 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-361, 21, -331)
                elseif i == "Alt22" or i == 22 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-361, 21, -327)
                elseif i == "Alt23" or i == 23 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-365, 21, -327)
                elseif i == "Alt24" or i == 24 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-371, 21, -326)
                elseif i == "Alt25" or i == 25 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-376, 21, -327)
                elseif i == "Alt26" or i == 26 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-381, 21, -326)
                elseif i == "Alt27" or i == 27 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-385, 21, -327)
                elseif i == "Alt28" or i == 28 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-390, 21, -323)
                elseif i == "Alt29" or i == 29 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-390, 21, -326)
                elseif i == "Alt30" or i == 30 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-390, 21, -323)
                elseif i == "Alt31" or i == 31 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-385, 21, -323)
                elseif i == "Alt32" or i == 32 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-381, 21, -323)
                elseif i == "Alt33" or i == 33 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-375, 21, -324)
                elseif i == "Alt34" or i == 34 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-370, 21, -323)
                elseif i == "Alt35" or i == 35 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-365, 21, -324)
                elseif i == "Alt36" or i == 36 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-360, 21, -324)
                elseif i == "Alt37" or i == 37 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-359, 21, -318)
                elseif i == "Alt38" or i == 38 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-364, 21, -319)
                end
            end
        end

        -- Teleport to 'safezone1' if typed "/tp safezone1"
        if (string.lower(args[1]) == "safezone1") then
            player.Character.HumanoidRootPart.Anchored = false
            player.Character.HumanoidRootPart.CFrame = CFrame.new(-117.270287, -58.7000618, 146.536087, 
                0.999873519, 5.21876942e-08, -0.0159031227, 
                -5.22713037e-08, 1, -4.84179008e-09, 
                0.0159031227, 5.67245495e-09, 0.999873519
            )
        end

        -- Teleport to 'safezone2' if typed "/tp safezone2"
        if (string.lower(args[1]) == "safezone2") then
            player.Character.HumanoidRootPart.Anchored = false
            player.Character.HumanoidRootPart.CFrame = CFrame.new(207.48085, 38.25, 200014.953, 
                0.507315397, 0, -0.861760437, 
                0, 1, 0, 
                0.861760437, 0, 0.507315397
            )
        end

        -- Teleport to 'station' if typed "/tp station"
        if (string.lower(args[1]) == "station") then
            player.Character.HumanoidRootPart.Anchored = false
            player.Character.HumanoidRootPart.CFrame = CFrame.new(591.680725, 49.0000458, -256.818298, 
                -0.0874911696, -3.41755495e-08, -0.996165276, 
                1.23318324e-08, 1, -3.53901868e-08, 
                0.996165276, -1.53808717e-08, -0.0874911696
            )
        end

        -- Teleport to 'taco' if typed "/tp taco"
        if (string.lower(args[1]) == "taco") then
            player.Character.HumanoidRootPart.Anchored = false
            player.Character.HumanoidRootPart.CFrame = CFrame.new(583.931641, 51.061409, -476.954193, 
                -0.999745369, 1.49123665e-08, -0.0225663595, 
                1.44838328e-08, 1, 1.91533687e-08, 
                0.0225663595, 1.88216429e-08, -0.999745369
            )
        end
    end
end

cmds["tpf"] = function(args, p)
    if (args[1] == "" or args[1] == nil) then
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Please input place to teleport to.", "All")
    else
        -- Unanchor first
        player.Character.HumanoidRootPart.Anchored = false
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Teleporting to '" .. args[1] .. "'!", "All")

        if (string.lower(args[1]) == "bank") then
            for i, userId in pairs(_G.LSDropper.alts) do
                if i == "Alt1" or i == 1 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-389, 21, -338)
                elseif i == "Alt2" or i == 2 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-385, 21, -338)
                elseif i == "Alt3" or i == 3 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-380, 21, -337)
                elseif i == "Alt4" or i == 4 then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(-376, 21, -338)
                -- etc… (same pattern up to Alt38)
                end
            end
        end

        if (string.lower(args[1]) == "safezone1") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(-117.270287, -58.7000618, 146.536087,
                0.999873519, 5.21876942e-08, -0.0159031227,
                -5.22713037e-08, 1, -4.84179008e-09,
                0.0159031227, 5.67245495e-09, 0.999873519
            )
        end

        if (string.lower(args[1]) == "safezone2") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(207.48085, 38.25, 200014.953, 
                0.507315397, 0, -0.861760437, 
                0, 1, 0, 
                0.861760437, 0, 0.507315397
            )
        end

        if (string.lower(args[1]) == "station") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(591.680725, 49.0000458, -256.818298, 
                -0.0874911696, -3.41755495e-08, -0.996165276, 
                1.23318324e-08, 1, -3.53901868e-08, 
                0.996165276, -1.53808717e-08, -0.0874911696
            )
        end

        if (string.lower(args[1]) == "taco") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(583.931641, 51.061409, -476.954193, 
                -0.999745369, 1.49123665e-08, -0.0225663595, 
                1.44838328e-08, 1, 1.91533687e-08, 
                0.0225663595, 1.88216429e-08, -0.999745369
            )
        end
        
        -- Now freeze after teleport
        wait(0.3)
        player.Character.HumanoidRootPart.Anchored = true
    end
end

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
        game.Players.LocalPlayer.Character.Humanoid:EquipTool(game.Players.LocalPlayer.Backpack:FindFirstChild("Wallet"))
        wallet = true
    else
        if game.Players.LocalPlayer.Character:FindFirstChild("Wallet") then
            game.Players.LocalPlayer.Character.Humanoid:UnequipTools()
        end
        wallet = false
    end
end

---------------------------------------------------------------
-- Helper functions for “airwalk” code:
---------------------------------------------------------------
local ContextAction = game:GetService("ContextActionService")
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
_G.LSCommands = cmds
---------------------------------------------------------------
