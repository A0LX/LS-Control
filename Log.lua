-- AltLogger.lua
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local AltLogger = {}

local workspaceFolder = "workspace"  -- Local workspace folder path
local altLogFile = workspaceFolder .. "/alts.json"

function AltLogger:loadAlts()
    local file = io.open(altLogFile, "r")
    if file then
        local data = file:read("*a")
        file:close()
        local success, result = pcall(function() return HttpService:JSONDecode(data) end)
        if success then
            return result
        end
    end
    return {}  -- Return an empty table if the file doesn't exist or fails to decode.
end

function AltLogger:saveAlts(alts)
    local file = io.open(altLogFile, "w")
    if file then
        file:write(HttpService:JSONEncode(alts))
        file:close()
    end
end

function AltLogger:registerAlt()
    local alts = self:loadAlts()
    local userId = tostring(Players.LocalPlayer.UserId)
    if not alts[userId] then
        local nextId = 1
        for _, id in pairs(alts) do
            if id >= nextId then
                nextId = id + 1
            end
        end
        alts[userId] = nextId
        self:saveAlts(alts)
    end
    return alts[userId]
end

-- Returns the current in-game position of this alt based on the logged IDs.
function AltLogger:getAltPosition()
    local alts = self:loadAlts()
    local currentAlts = {}
    for _, player in pairs(Players:GetPlayers()) do
        local uid = tostring(player.UserId)
        if alts[uid] then
            table.insert(currentAlts, {player = player, id = alts[uid]})
        end
    end
    table.sort(currentAlts, function(a, b)
        return a.id < b.id
    end)
    local myAltId = alts[tostring(Players.LocalPlayer.UserId)]
    for index, alt in ipairs(currentAlts) do
        if alt.id == myAltId then
            return index, #currentAlts, currentAlts
        end
    end
    return nil
end

return AltLogger
