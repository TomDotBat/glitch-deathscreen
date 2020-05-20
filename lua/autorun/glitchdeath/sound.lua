--[[----------------------------------------------------
  SOUND
  Play the iconic sound
]]------------------------------------------------------

if CLIENT then

  -- Parameters
  local DELAY = 0.2;
  local MP_SOUND = "glitchfire/death/mp_sound.wav";

  -- Precache sounds
  util.PrecacheSound(MP_SOUND);

  -- Variables
  local lastSound = nil; -- The last soundfile played
  local sound = nil; -- The actual sound entity
  local delay = 0; -- Sound play delay

  --[[
    Plays the sound on death, cancels it out if alive
    @param {boolean} is next gen
  ]]
  function GTAVDS:PlaySound()
    if (LocalPlayer():Alive()) then delay = RealTime() + DELAY; GTAVDS:StopSound(); return; end
    if (not GTAVDS:ShouldSoundPlay()) then return; end
    if (sound == nil or lastSound ~= MP_SOUND) then -- Initialize sound if nil
      sound = CreateSound(LocalPlayer(), MP_SOUND);
      lastSound = MP_SOUND;
    end
    if (not sound:IsPlaying()) then
      sound:Play();
    end
  end

  --[[
    Stops the sound from playing
    @void
  ]]
  function GTAVDS:StopSound()
    if (sound ~= nil and sound:IsPlaying()) then sound:Stop(); end
  end

  --[[
    Whether the sound delay is over
    @return {boolean} should play
  ]]
  function GTAVDS:ShouldSoundPlay()
    return delay < RealTime();
  end

end
