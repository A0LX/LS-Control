local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local AltLogger = {}

local folderName = "LS"
local altLogFile = folderName.."/alts.json"

local function ensureFolderExists()
    if not isfolder(folderName) then
        makefolder(folderName)
    end
end

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

function AltLogger:registerAlt()
    local alts = self:loadAlts()
    local userId = tostring(Players.LocalPlayer.UserId)

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
