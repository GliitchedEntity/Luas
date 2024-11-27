local screen_x, screen_y = draw.GetScreenSize()
local font = draw.CreateFont("Verdana", 24, 700)
local class_ents = {}

local function get_class_entity()
    local plr = entities.GetLocalPlayer()
    if not plr then return end
    
    local local_team_num = plr:GetPropInt("m_iTeamNum")
    local players = entities.FindByClass("CTFPlayer")
    local temp_ents = {}

    for _, v in pairs(players) do
        if not v:IsDormant()
            and v:GetPropInt("m_iClass") == 8
            and v:GetPropInt("m_iTeamNum") ~= local_team_num
            and v:IsAlive()
            and not v:InCond(E_TFCOND.TFCond_Cloaked) then
            
            local distance = vector.Distance(v:GetAbsOrigin(), plr:GetAbsOrigin())
            if distance <= 500 then
                table.insert(temp_ents, { name = v:GetName(), distance = math.floor(distance) })
            end
        end
    end
    class_ents = temp_ents
end

local function paint_spy()
    if #class_ents == 0 then return end
    draw.SetFont(font)
    draw.Color(255, 0, 0, 255)
    for i, ent in ipairs(class_ents) do
        local str = string.format("%s [%d]", ent.name, ent.distance)
        local text_x, _ = draw.GetTextSize(str)
        draw.Text(math.floor((screen_x - text_x) / 2), math.floor((screen_y / 1.9) + 16 * (i - 1)), str)
    end
end

callbacks.Register("CreateMove", "find_spies", get_class_entity)
callbacks.Register("Draw", "paint_spy_draw", paint_spy)
