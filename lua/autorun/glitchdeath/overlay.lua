--[[----------------------------------------------------
  OVERLAY
  Manages the animation and the main overlay effects
]]------------------------------------------------------

  if CLIENT then
  -- Parameters
  local MP_TIME = 0.98;
  local SOUND_TIME = 2.258;
  local NG_TIME = 1.95;
  local PRE_DARK = 0.21;
  local POST_DARK = 0.14;
  local COLOUR = 0.2;
  local VIGNETTE = surface.GetTextureID("glitchfire/death/vignette01");

  -- Variables
  local soundTime = 0; -- Time for the coloured flash to appear
  local faded = false; -- Bloom effect faded
  local bloom = 0; -- Bloom amount
  local colour = 0; -- Colour flash amount
  local greyscale = 0; -- Greyscale amount
  local titleShown = false; -- Was the 'wasted' title shown
  local darkness = 0; -- Darkness amount
  local vign = 0; -- Main vignette size
  local tick = 0;

  --[[
    Resets the animation variables
    @void
  ]]
  local function ResetAnimation()
    faded = false;
    bloom = 0;
    colour = 0;
    greyscale = 0;
    darkness = 0;
    titleShown = false;
    vign = 0;
  end

  --[[
    Animation portion that plays when killed
    @param {number} rate
  ]]
  local function FadeInAnimation()
    if (tick < RealTime()) then
      vign = math.min(vign + 0.04, 1);
      bloom = math.min(bloom + 0.05, 0.66);
      colour = 0;
      greyscale = math.min(greyscale + 0.025, 0.4);
      darkness = math.min(darkness + 0.03, 0.2);
      tick = RealTime() + 0.01;
    end
  end

  --[[
    Animation played after having the 'wasted' sign appear
    @param {number} rate
  ]]
  local function WastedAnimation()
    if (tick < RealTime()) then
      bloom = math.min(bloom + 0.01, 1);
      colour = 0;
      greyscale = math.min(greyscale + 0.01, 0.9);
      darkness = math.min(darkness + 0.01, 1);
      tick = RealTime() + 0.01;
    end
  end

  --[[
    Returns whether the 'clang' has been heard
    @return {boolean} has animation ended
  ]]
  function GTAVDS:HasAnimationEnded()
    return soundTime < RealTime();
  end

  --[[
    Returns the status of the bloom animation
    @return {number} animation
  ]]
  function GTAVDS:GetBloomAnimation()
    if (faded) then return 1; end
    return bloom;
  end

  --[[
    Plays the grey down and flash animations
    @param {boolean} is next gen
  ]]
  local function Animate()
    if (LocalPlayer():Alive()) then ResetAnimation(); return; end

    if (not GTAVDS:ShouldSoundPlay()) then
      soundTime = RealTime() + MP_TIME;
      return;
    end

    -- Play animation if sound has started
    if (not GTAVDS:HasAnimationEnded()) then
      FadeInAnimation();
    else
      WastedAnimation();
    end
  end

  --[[
    Draws a vignette effect
    @param {number} vignette texture id
    @param {number} size
  ]]
  local function DrawVignette(texture, size)
    size = size or 0;
    --surface.SetTexture(texture);
    --surface.SetDrawColor(Color(255, 255, 255));
    --surface.DrawTexturedRect(-(ScrW() * (size) * 0.5), -(ScrH() * (size) * 0.5), ScrW() * (1 + size), ScrH() * (1 + size));
  end

  --[[
    Draws the overlay
    @void
  ]]
  function GTAVDS:DrawOverlay()
    if (LocalPlayer():Alive()) then return; end
    -- Draw vignette
    if (GTAVDS:ShouldSoundPlay()) then DrawVignette(VIGNETTE, 1 - vign); end

    -- Draw text
    GTAVDS:DrawWastedMP(not GTAVDS:HasAnimationEnded());
  end

  --[[
    Generates post processing effects
    @void
  ]]
  function GTAVDS:PostProcessing()
    Animate();

    -- How much darkness will be applied
    local maxDarkness = PRE_DARK;
    local maxContrast = PRE_DARK;
    if (GTAVDS:HasAnimationEnded()) then
      maxDarkness = POST_DARK;
      maxContrast = POST_DARK;
    end

    -- Use player colour to display in the early animation
    local overlay = LocalPlayer():GetPlayerColor();

    -- Colour correction
    local tab = {
      [ "$pp_colour_addr" ] = overlay.r * COLOUR * colour,
      [ "$pp_colour_addg" ] = overlay.g * COLOUR * colour,
      [ "$pp_colour_addb" ] = overlay.b * COLOUR * colour,
      [ "$pp_colour_brightness" ] = -darkness * maxDarkness,
      [ "$pp_colour_contrast" ] = 1 + (darkness * maxContrast),
      [ "$pp_colour_colour" ] = 1 - greyscale,
      [ "$pp_colour_mulr" ] = 0,
      [ "$pp_colour_mulg" ] = 0,
      [ "$pp_colour_mulb" ] = 0
    };
    DrawColorModify( tab );

    -- Bloom
    DrawBloom( 0.42, 2.64, 4, 4, 0, 2, 1 * bloom, 1 * bloom, 1 * bloom );
  end
end
