local smartautostrafe = true;

local function faststop(cmd)
    local localPlayer = entities.GetLocalPlayer()
    if not localPlayer then return end
    local btns = cmd:GetButtons()

    --Don't do anything if player is holding any movement key
    if (btns & IN_FORWARD) ~= 0 or (btns & IN_BACK) ~= 0 or (btns & IN_MOVELEFT) ~= 0 or (btns & IN_MOVERIGHT) ~= 0 then
        if (smartautostrafe) then gui.SetValue("Auto Strafe", 2) end
        return
    end
    if (smartautostrafe) then gui.SetValue("Auto Strafe", 0) end

    local pFlags = localPlayer:GetPropInt("m_fFlags")
    local velocity = localPlayer:EstimateAbsVelocity()
    --Don't do anything if player is not on ground or slower than 15vel or holding a jump button
    if (pFlags & FL_ONGROUND) == 0 or velocity:Length2D() <= 15 or (btns & IN_JUMP) ~= 0 then return end

    -- If no keys are held, stop movement immediately by moving in the opposite direction of current velocity
    local cPitch, cYaw, cRoll = cmd:GetViewAngles()
    local dir = velocity:Angles()
    dir.y = cYaw - dir.y
    local forward = dir:Forward() * -velocity:Length2D()

    -- Set the movement speeds
    cmd.forwardmove, cmd.sidemove = forward.x, forward.y
end

callbacks.Register("CreateMove", "faststop", faststop)
