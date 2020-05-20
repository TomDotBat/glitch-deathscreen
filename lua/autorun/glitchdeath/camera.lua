--[[----------------------------------------------------
  CAMERA
  Manages camera position, angles, and field of view
]]------------------------------------------------------

if CLIENT then

  -- Parameters
  local FOV_MAX = 12;
  local ROTATION = 26;
  local ROT_START_TIME = 0.74;
  local ROT_STOP_TIME = 2;
  local ROT_STOP_TIME_MP = 6;
  local VERTICAL = 5;
  local DISTANCE = 60;

  -- Variables
  local rot = 0;
  local tilt = false;
  local fov;
  local time = 0;
  local tick = 0;
  local tickRot = 0;
  local vert = 0;

  --[[
    Resets camera animation variables
    @void
  ]]
  local function ResetCamData()
    rot = 0;
    fov = nil;
    tilt = false;
    time = RealTime() + ROT_START_TIME;
    vert = 0;
  end

  --[[
    Moves the camera according to the death animation status
  ]]
  hook.Add("CalcView", "gtavds_camera", function(player, origin, angles, dFov, znear, zfar )
    if LocalPlayer():Alive() then ResetCamData(); return; end

    -- Camera fov
    if (not fov) then fov = dFov; end
    fov = Lerp(RealFrameTime() * 10, fov, math.max(dFov - FOV_MAX, 0));

    -- Camera rotation
    if (not GTAVDS:HasAnimationEnded()) then
      time = RealTime() + ROT_STOP_TIME_MP;
    end

    if (time > RealTime()) then
      rot = Lerp(RealFrameTime() * 0.34, rot, 1);
    else
      rot = Lerp(RealFrameTime() * 0.24, rot, 0);
    end

    -- Camera repositioning
    if (tick < RealTime()) then
      vert = vert + 0.014 * rot;
      tick = CurTime() + 0.001;
    end

    -- Build view data
    local view = {};
  	view.origin = origin + (angles:Up() * 20);
  	view.angles = Angle(angles.p + (VERTICAL * (math.sin(vert) + 1)) + 10, angles.y, angles.r + (ROTATION * rot));
  	view.fov = fov;

	   return view;
  end);

end
