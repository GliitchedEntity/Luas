--Settings
local cachesuspects = true --Save suspects to file
local keywords = {"%[stac%]", "smac ", "cheat", "hack"} --Keywords to look for in ban reasons
local apikey = "CLVZ*****************************" --Your steamhistory API key
local host = "https://steamhistory.net/api/sourcebans?key=" .. apikey .. "&shouldkey=0&steamids="

--Place json.lua in your appdata\Local
local json = require "json" --https://github.com/appgurueu/json.lua/blob/fix-write-complexity/json.lua
local count = 0

local suspectIDS = {}
local uncheckedIDS = {}

local function tableToKeys(tbl)
    local result = {}
    for k in pairs(tbl) do table.insert(result, tostring(k)) end
    return result
end

local function keysToTable(array)
    local result = {}
    for _, v in ipairs(array) do result[tonumber(v)] = true end
    return result
end

local function cacheSuspects(write)
    local path = "Scanner/suspects.txt"
    filesystem.CreateDirectory("Scanner")
    if write then
        local file = io.open(path, "w")
        if file then
            file:write(json.encode(tableToKeys(suspectIDS)))
            file:close()
        end
    else
        local file = io.open(path, "r")
        if file then
            local content = file:read("*a")
            suspectIDS = #content > 2 and keysToTable(json.decode(content)) or {}
            file:close()
        end
    end
end

local function handleSuspect(ent, sid, reason)
    if not suspectIDS[sid] then
        playerlist.SetPriority(ent, 7)
        client.ChatPrintf(string.format(
            "\x06[ \x07FF7F27LmaoBox \x06] \x0700ffff%s \x04marked for: \x07FF1122%s",
            ent:GetName(), reason
        ))
        suspectIDS[sid] = true
    end
end

local function scanPlayers()
    if next(uncheckedIDS) == nil then client.ChatPrintf(
        "\x06[ \x07FF7F27LmaoBox \x06] \x07FF1122No players to scan!") return end
    client.ChatPrintf(string.format(
        "\x06[ \x07FF7F27LmaoBox \x06] \x04Scanning: %s players..",
        count
    ))
    print(string.format("Scanning %s players...",count))

    local url = host .. table.concat(tableToKeys(uncheckedIDS), ",")
    local res = json.decode(http.Get(url)) or {response = {}}

    for _, v in pairs(res.response) do
        local sid, uid = tonumber(v.SteamID), uncheckedIDS[tonumber(v.SteamID)].UserID
        local ent = entities.GetByUserID(uid)
        if ent and ent:IsValid() then
            print(string.format("[%s] %s banned for: %s", v.Server, ent:GetName(), v.BanReason))
            local reason = string.lower(v.BanReason)
            for _, keyword in ipairs(keywords) do
                if reason:find(keyword) then
                    handleSuspect(ent, sid, v.BanReason)
                    break
                end
            end
        end
    end

    uncheckedIDS = {} -- Clear unchecked IDs after processing
end

local function updatePlayers()
    local localPlayer = entities.GetLocalPlayer()
    for _, player in pairs(entities.FindByClass("CTFPlayer")) do
        if player and player ~= localPlayer then
            local info = client.GetPlayerInfo(player:GetIndex())
            local sid64 = steam.ToSteamID64(info.SteamID)
            if suspectIDS[sid64] then
                client.ChatPrintf(string.format(
                    "\x06[ \x07FF7F27LmaoBox \x06] \x0700ffff%s \x07FF1122is a known cheater!",
                    player:GetName()
                ))
                playerlist.SetPriority(player, 7)
            else
                count = count + 1
                uncheckedIDS[sid64] = info
            end
        end
    end

end

-- Load cached suspects, process players, and save cache
if cachesuspects then cacheSuspects(false) end
updatePlayers()
scanPlayers()
cacheSuspects(true)
