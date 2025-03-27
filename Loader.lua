local config = _G.LSDropper

if (_G.LSLoaded == true) then
    warn("Make sure you only execute LS once.")
    error("Make sure you only execute LS once.")
    return
else
    print("LS loading...")
    _G.LSLoaded = true 
end

local AltLogger = loadstring(game:HttpGet("https://raw.githubusercontent.com/A0LX/LS-Control/refs/heads/main/Log.lua"))()

config.AltLogger = AltLogger
config.myAltId = AltLogger:registerAlt()
print("AltLogger loaded. My Alt ID:", config.myAltId)

setfpscap(config.fps)
game:GetService("RunService"):Set3dRenderingEnabled(false)

print("Loading Commands...")
loadstring(game:HttpGet("https://raw.githubusercontent.com/A0LX/LS-Control/refs/heads/main/Commands.lua"))()
print("Commands Loaded!")

local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

repeat wait() until game:IsLoaded() and game.Players.LocalPlayer.Character

print("Loading Command Handler...")

function Command(player, msg)
    local cmd = string.split(msg, " ")
    print("Controller chatted: " .. cmd[1])
    
    if (string.sub(string.lower(cmd[1]), 1, 1) == config.Prefix) then
        local cmd1 = string.lower(cmd[1]):gsub(config.Prefix, "")
        if (_G.LSCommands[cmd1] ~= nil) then
            print("Running Command " .. cmd1 .. "...")
            _G.LSCommands[cmd1]({cmd[2], cmd[3], cmd[4], cmd[5], cmd[6], cmd[7], cmd[8], cmd[9], cmd[10], cmd[11]}, player)
        end
    end
end

game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(Data)
    local Player = game:GetService("Players")[Data.FromSpeaker]
    local Message = Data.Message
    
    for _, v in pairs(config.Controllers) do
        if (tostring(Player.UserId) == tostring(v)) then
            Command(Player, Message)
        end
    end
end)

print("Command Handler ready.")

print("Loading Libraries...")
loadstring(game:HttpGet("https://raw.githubusercontent.com/A0LX/LS-Control/refs/heads/main/scripts/DeleteChairs.lua"))()
print("Libraries loaded.")
print("LS loaded!")

game.StarterGui:SetCore("SendNotification", {
    Title = "LS",
    Text = "LS has loaded!",
    Duration = 10,
})
