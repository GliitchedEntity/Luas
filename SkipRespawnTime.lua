local reconnecting = false
local classID, teamID = 1, 3

local TEAM_NAMES = { [2] = "Red", [3] = "Blue", [0] = "Spectator" }
local CLASS_NAMES = { "Scout", "Soldier", "Pyro", "Demoman", "Heavy", "Engineer", "Medic", "Sniper", "Spy" }

callbacks.Register("FireGameEvent", function(e)
    local eventName = e:GetName()
    if eventName == "player_death" then
        local plr = entities.GetLocalPlayer()
        if plr and client.GetPlayerInfo(plr:GetIndex()).UserID == e:GetInt("userid") then
            classID, teamID = plr:GetPropInt("m_iClass"), plr:GetPropInt("m_iTeamNum")
            reconnecting = true
            client.Command("retry", true)
            return
        end
    elseif reconnecting then
        if eventName == "player_team" then
            client.Command(string.format("jointeam %s", TEAM_NAMES[teamID]), true)
        elseif eventName == "localplayer_changeteam" then
            client.Command(string.format("join_class %s", CLASS_NAMES[classID]), true)
            reconnecting = false
        end
    end
end)
