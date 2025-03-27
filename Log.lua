-- AltLogger.lua
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local AltLogger = {}

local folderName = "LS"          -- Folder in the exploit workspace
local altLogFile = folderName.."/alts.json"

-- Ensure the "LS" folder exists in the executor workspace
local function ensureFolderExists()
    if not isfolder(folderName) then
        makefolder(folderName)
    end
end

-- Load all alt data from "LS/alts.json"
function AltLogger:loadAlts()
    ensureFolderExists()
    if not isfile(altLogFile) then
        return {}
    end

    local data = readfile(altLogFile)
    local success, result = pcall(function()
        return HttpService:JSONDecode(data)
    end)
    if success and typeof(result) == "table" then
        return result
    end
    return {}
end

-- Save alt data to "LS/alts.json"
function AltLogger:saveAlts(alts)
    ensureFolderExists()
    local jsonData = HttpService:JSONEncode(alts)
    writefile(altLogFile, jsonData)
end

-- Assign a unique numeric ID to the current alt, if not already assigned
function AltLogger:registerAlt()
    local alts = self:loadAlts()
    local userId = tostring(Players.LocalPlayer.UserId)

    -- If this alt hasn't been registered, pick the next available numeric ID
    if not alts[userId] then
        local nextId = 1
        for _, existingId in pairs(alts) do
            if existingId >= nextId then
                nextId = existingId + 1
            end
        end
        alts[userId] = nextId
        self:saveAlts(alts)
    end

    return alts[userId]
end

-- Return this alt's position among all in-game alts (sorted by ID)
function AltLogger:getAltPosition()
    local alts = self:loadAlts()
    local currentAlts = {}

    for _, player in pairs(Players:GetPlayers()) do
        local uid = tostring(player.UserId)
        if alts[uid] then
            table.insert(currentAlts, {player = player, id = alts[uid]})
        end
    end

    -- Sort ascending by ID
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
