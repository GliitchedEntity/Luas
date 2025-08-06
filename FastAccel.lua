local isSilent = true --Hide from spectators
local duckSpeed = false
local accurateMove = true --Prevents sliding on high speeds

local plr = nil
local speedmul = accurateMove and 1 or 0.9
local movementKeys = IN_FORWARD | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT | IN_ATTACK 
callbacks.Register("CreateMove", function(cmd)
    if not plr or not plr:IsValid() then
        plr = entities.GetLocalPlayer()
        return
    end
    if not plr:IsAlive() then return end

    local buttons = cmd:GetButtons()
    local flags = plr:GetPropInt("m_fFlags")
    if (buttons & movementKeys) == 0 or
        (buttons & IN_ATTACK) ~= 0 or
        (flags & FL_ONGROUND) == 0 or
        (not duckSpeed and (flags & FL_DUCKING) == 2) or
        plr:EstimateAbsVelocity():Length2D() >= (plr:GetPropFloat("m_flMaxspeed")*speedmul) or
        (isSilent and (globals.TickCount() % 2 == 0 or clientstate.GetChokedCommands() >= 21)) then
        return
    end

    local vMove = Vector3(cmd.forwardmove, cmd.sidemove, 0.0)
    local angMoveReverse = (vMove * -1.0):Angles()
    local fmod = math.fmod(cmd.viewangles.y - angMoveReverse.y, 360)
    cmd:SetViewAngles(cmd.viewangles.x, fmod, 270)
    cmd.sendpacket = false
end)
