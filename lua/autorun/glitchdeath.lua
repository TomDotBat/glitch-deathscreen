-- Framework table
GTAVDS = {};

--[[
  Correctly includes a file
  @param {string} file
  @void
]]--
function GTAVDS:IncludeFile(file)
  if SERVER then
    include(file);
    AddCSLuaFile(file);
  end
  if CLIENT then
    include(file);
  end
end

-- Include components
GTAVDS:IncludeFile("glitchdeath/sound.lua");
GTAVDS:IncludeFile("glitchdeath/main.lua");
GTAVDS:IncludeFile("glitchdeath/overlay.lua");
GTAVDS:IncludeFile("glitchdeath/camera.lua");

if CLIENT then
  -- Draw overlay
  hook.Add("HUDPaint", "gtavds_draw", function()
    GTAVDS:PlaySound();
    GTAVDS:DrawOverlay();
  end);

  hook.Add("RenderScreenspaceEffects", "gtavds_postprocessing", function()
    GTAVDS:PostProcessing();
  end);

  hook.Add("HUDShouldDraw", "gtavds_hide_hud", function(name)
    if (LocalPlayer().Alive ~= nil and LocalPlayer():Alive()) then return; end
    if (name == "CHudDamageIndicator") then return false; end
  end);
end


if SERVER then

  -- Add resources
  resource.AddFile("sound/glitchfire/death/mp_sound.wav");
  resource.AddFile("materials/glitchfire/death/vignette01.vtf");
  resource.AddFile("materials/glitchfire/death/vignette01.vtm");

  --[[
    Overrides the player's death sound
  ]]
  hook.Add("PlayerDeathSound", "gtavds_deathsound", function()
    return true;
  end);

end
