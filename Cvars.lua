--Please, do not add sv_cheats to this list, spoof needed cvars directly to stay undetected to anticheats
local cmds = {
    {"fog_override", 1},
    {"fog_enable", 0},
    {"mat_dynamic_tonemapping", 0},
    {"mat_disable_bloom", 1},
    --{"r_drawparticles", 0}
}
callbacks.Register("FireGameEvent", function(e)
    local eventName = e:GetName()
    if (eventName == "game_newmap") then
        for _, cmd in ipairs(cmds) do
            client.SetConVar(cmd[1], cmd[2])
        end
        client.ChatPrintf( "\x06[\x07FF1122LmaoBox\x06] \x04Cvars bypassed!" )
    end
end)
