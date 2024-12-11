--Settings
local teamcolors = true --Team colors or Ally/Enemy colors

local lp = entities:GetLocalPlayer()
local players = {}
local lpteam = 0
local red = [["VertexLitGeneric"
{
  $basetexture "vgui/white_additive"
  $bumpmap "models/player/shared/shared_normal"
  $envmap "skybox/sky_dustbowl_01"
  $envmapfresnel "1"
  $phong "1"
  $phongfresnelranges "[0 1 1]"
  $selfillum "1"
  $selfillumfresnel "1"
  $selfillumfresnelminmaxexp "[0.5 0.5 0]"
  $selfillumtint "[0 0 0]"
  $envmaptint "[1 0 0]"
}
]]

local blue = [["VertexLitGeneric"
{
  $basetexture "vgui/white_additive"
  $bumpmap "models/player/shared/shared_normal"
  $envmap "skybox/sky_dustbowl_01"
  $envmapfresnel "1"
  $phong "1"
  $phongfresnelranges "[0 1 1]"
  $selfillum "1"
  $selfillumfresnel "1"
  $selfillumfresnelminmaxexp "[0.5 0.5 0]"
  $selfillumtint "[0 0 0]"
  $envmaptint "[0 1 1]"
}
]]

local redd = [["VertexLitGeneric"
{
  $basetexture "vgui/white_additive"
  $bumpmap "models/player/shared/shared_normal"
  $envmap "skybox/sky_dustbowl_01"
  $envmapfresnel "1"
  $phong "1"
  $phongfresnelranges "[0 1 1]"
  $selfillum "1"
  $selfillumfresnel "1"
  $selfillumfresnelminmaxexp "[0.5 0.5 0]"
  $selfillumtint "[0 0 0]"
  $envmaptint "[0.2 0 0]"
}
]]

local blued = [["VertexLitGeneric"
{
  $basetexture "vgui/white_additive"
  $bumpmap "models/player/shared/shared_normal"
  $envmap "skybox/sky_dustbowl_01"
  $envmapfresnel "1"
  $phong "1"
  $phongfresnelranges "[0 1 1]"
  $selfillum "1"
  $selfillumfresnel "1"
  $selfillumfresnelminmaxexp "[0.5 0.5 0]"
  $selfillumtint "[0 0 0]"
  $envmaptint "[0 0.2 0.2]"
}
]]

if (client.GetConVar("mat_specular") == 0 or client.GetConVar("mat_bumpmap") == 0 or client.GetConVar("mat_phong") == 0) then
  client.ChatPrintf(
        "\x06[ \x07FF7F27LmaoBox \x06] \x07FF1122Please set mat_specular; mat_bumpmap; mat_phong to 1!")
  return
end

local EnemyMat = materials.Create( "EnemyMat", red )
local TeamMat = materials.Create( "TeamMat", blue )
local EnemyOccl = materials.Create( "EnemyOccl", redd )
local TeamOccl = materials.Create( "TeamOccl", blued )

local materialTable = {
  [2] = { mat = EnemyMat, oclmat = EnemyOccl },
  [3] = { mat = TeamMat,  oclmat = TeamOccl }
}

callbacks.Register("CreateMove", function()
  lp = entities:GetLocalPlayer()
  lpteam = lp:GetTeamNumber()
  local templist = {}
  for _, player in pairs(entities.FindByClass("CTFPlayer")) do
    if player then
      templist[player:GetIndex()] = player:GetTeamNumber()
    end
  end
  players = templist
  TeamOccl:SetMaterialVarFlag( MATERIAL_VAR_IGNOREZ, true )
  EnemyOccl:SetMaterialVarFlag( MATERIAL_VAR_IGNOREZ, true )
end)

callbacks.Register("DrawModel", function(ctx)
  local entity = ctx:GetEntity()
  local entityIndex = entity and entity:GetIndex()

  if not entityIndex or not players[entityIndex] or ctx:IsDrawingGlow() or ctx:IsDrawingBackTrack() then
    return
  end
  local teamNum = players[entityIndex]
  local matSet
  if teamcolors then
    matSet = materialTable[teamNum]
  else
    matSet = materialTable[teamNum == lpteam and 3 or 2]
  end
  ctx:ForcedMaterialOverride(matSet.oclmat)
  ctx.Execute(ctx)
  ctx:ForcedMaterialOverride(matSet.mat)
end)
