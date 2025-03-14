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
     for i = 1,50 do
      if (args[i] ~= nil) then str = str .. " " .. args[i] end
     end
  
     game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
  end
end

cmds["tp"] = function(args, p)
  if (args[1] == "" or args[1] == nil) then
     game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Please input place to teleport to.", "All")
  else
       game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Teleporting to '" .. args[1] .. "'!", "All")
       if (string.lower(args[1]) == "bank") then 
           player.Character.HumanoidRootPart.Anchored = false
           player.Character.HumanoidRootPart.CFrame = CFrame.new(-437.125885, 38.9783134, -285.587372, 0.0165725499, 5.298579e-08, -0.99986279, 1.16139711e-08, 1, 5.31855591e-08, 0.99986279, -1.24937944e-08, 0.0165725499)
       end
       if (string.lower(args[1]) == "safezone1") then 
           player.Character.HumanoidRootPart.Anchored = false
           player.Character.HumanoidRootPart.CFrame = CFrame.new(-117.270287, -58.7000618, 146.536087, 0.999873519, 5.21876942e-08, -0.0159031227, -5.22713037e-08, 1, -4.84179008e-09, 0.0159031227, 5.67245495e-09, 0.999873519)
       end
       if (string.lower(args[1]) == "safezone2") then 
           player.Character.HumanoidRootPart.Anchored = false
           player.Character.HumanoidRootPart.CFrame = CFrame.new(207.48085, 38.25, 200014.953, 0.507315397, 0, -0.861760437, 0, 1, 0, 0.861760437, 0, 0.507315397)
       end
       if (string.lower(args[1]) == "station") then 
           player.Character.HumanoidRootPart.Anchored = false
           player.Character.HumanoidRootPart.CFrame = CFrame.new(591.680725, 49.0000458, -256.818298, -0.0874911696, -3.41755495e-08, -0.996165276, 1.23318324e-08, 1, -3.53901868e-08, 0.996165276, -1.53808717e-08, -0.0874911696)
       end
       if (string.lower(args[1]) == "taco") then 
           player.Character.HumanoidRootPart.Anchored = false
           player.Character.HumanoidRootPart.CFrame = CFrame.new(583.931641, 51.061409, -476.954193, -0.999745369, 1.49123665e-08, -0.0225663595, 1.44838328e-08, 1, 1.91533687e-08, 0.0225663595, 1.88216429e-08, -0.999745369)
       end
  end
end

cmds["tpf"] = function(args, p)
    if (args[1] == "" or args[1] == nil) then
       game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Please input place to teleport to.", "All")
    else
       player.Character.HumanoidRootPart.Anchored = false
       game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("[LS] Teleporting to '" .. args[1] .. "'!", "All")
       if (string.lower(args[1]) == "bank") then 
           player.Character.HumanoidRootPart.CFrame = CFrame.new(-437.125885, 38.9783134, -285.587372, 0.0165725499, 5.298579e-08, -0.99986279, 1.16139711e-08, 1, 5.31855591e-08, 0.99986279, -1.24937944e-08, 0.0165725499)
       end
       if (string.lower(args[1]) == "safezone1") then 
           player.Character.HumanoidRootPart.CFrame = CFrame.new(-117.270287, -58.7000618, 146.536087, 0.999873519, 5.21876942e-08, -0.0159031227, -5.22713037e-08, 1, -4.84179008e-09, 0.0159031227, 5.67245495e-09, 0.999873519)
       end
       if (string.lower(args[1]) == "safezone2") then 
           player.Character.HumanoidRootPart.CFrame = CFrame.new(207.48085, 38.25, 200014.953, 0.507315397, 0, -0.861760437, 0, 1, 0, 0.861760437, 0, 0.507315397)
       end
       if (string.lower(args[1]) == "station") then 
           player.Character.HumanoidRootPart.CFrame = CFrame.new(591.680725, 49.0000458, -256.818298, -0.0874911696, -3.41755495e-08, -0.996165276, 1.23318324e-08, 1, -3.53901868e-08, 0.996165276, -1.53808717e-08, -0.0874911696)
       end
       if (string.lower(args[1]) == "taco") then 
           player.Character.HumanoidRootPart.CFrame = CFrame.new(583.931641, 51.061409, -476.954193, -0.999745369, 1.49123665e-08, -0.0225663595, 1.44838328e-08, 1, 1.91533687e-08, 0.0225663595, 1.88216429e-08, -0.999745369)
       end
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
    game.Players.LocalPlayer.Character.Humanoid:UnequipTools(game.Players.LocalPlayer.Character:FindFirstChild("Wallet"))
    wallet = false
  end
end

local testsquadAIR = {
   Airwalk = Enum.KeyCode.LeftAlt;
}

local ContextAction = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local function ForEach(t, f)
   for Index, Value in pairs(t) do
       f(Value, Index)
   end
end 
_G.ForEach = ForEach;

local function Create(ClassName)
   local Object = Instance.new(ClassName)
   return function(Properties)
       ForEach(Properties, function(Value, Property)
           Object[Property] = Value
       end)
       return Object
   end
end 
_G.Create = Create;

do
   local airwalkState = false
   local currentPart = nil
   RunService.RenderStepped:Connect(function()
       if airwalkState then
           if not currentPart then
               warn("On")
               currentPart = Create("Part") {
                   Parent = workspace.CurrentCamera;
                   Name = "AWP";
                   Transparency = 1;
                   Size = Vector3.new(2, 1, 2);
                   Anchored = true;
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
   player.Character.HumanoidRootPart.Anchored = false
   airwalkState = not airwalkState
end

cmds["spot"] = function(args, p)
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.Anchored = false
        local controllerRoot = p.Character.HumanoidRootPart
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
