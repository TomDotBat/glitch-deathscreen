-- Network string
local NET = "gtavds_net";

local VEHICLES = {
  ["prop_vehicle_jeep"] = true,
  ["prop_vehicle_airboat"] = true,
  ["prop_vehicle_prisoner_pod"] = true
};

if SERVER then

  util.AddNetworkString(NET);

  --[[
    Send to the player who killed them
    @multiplayer
  ]]
  hook.Add("PlayerDeath", "gtavds_death_data", function(victim, inflictor, attacker)
    if (not IsValid(victim) or not victim:IsPlayer()) then return; end

    -- Collect weapon used
    local weapon = "";
    if (IsValid(inflictor)) then weapon = inflictor:GetClass(); end
    if (inflictor == attacker and attacker:IsPlayer() and IsValid(attacker:GetActiveWeapon())) then
      weapon = string.lower(game.GetAmmoName(attacker:GetActiveWeapon():GetPrimaryAmmoType()));
    end

    -- Collect enemy name
    local name = attacker:GetClass();

    -- If it's a vehicle, collect the player's name
    if (VEHICLES[name] and IsValid(attacker:GetDriver())) then
      weapon = attacker:GetClass();
      attacker = attacker:GetDriver();
    end

    -- If it's a player, collect their name
    if (attacker:IsPlayer()) then
      name = attacker:Nick();
    end

    -- Send data
    net.Start(NET);
    net.WriteString(weapon);
    net.WriteString(name);
    net.WriteBool(attacker:IsPlayer() or attacker:IsNPC());
    net.WriteBool(attacker == victim);
    net.WriteBool(attacker:IsPlayer());
    net.Send(victim);
  end);

end

if CLIENT then

  -- Parameters
  local TEXTURE = surface.GetTextureID("gui/center_gradient");
  local AMMO_TYPES = {
    ["pistol"] = "gunned you down.",
    ["357"] = "gunned you down.",
    ["smg1"] = "riddled you.",
    ["ar2"] = "gunned you down.",
    ["buckshot"] = "filled you with buckshot.",
    ["xbowbolt"] = "tore through you.",
    ["rpg_round"] = "blew you up.",
    ["rpg_missile"] = "blew you up.",
    ["grenade"] = "blew you up.",
    ["npc_grenade_frag"] = "blew you up."
  };
  local EXPLOSION = {
    ["env_explosion"] = true,
    ["entityflame"] = true
  };

  -- Create font
  surface.CreateFont( "gtavds_mp_title", {
    font = "Roboto",
    size = ScreenScale(44),
    weight = 700,
    antialias = true,
    additive = true
  });

  surface.CreateFont( "gtavds_mp_sub", {
    font = "Roboto",
    size = ScreenScale(11),
    weight = 500,
    antialias = true,
    additive = true
  });

  surface.CreateFont( "gtavds_mp_player", {
    font = "Roboto",
    size = ScreenScale(12),
    weight = 0,
    antialias = true,
    additive = true
  });

  -- Variables
  local tick = 0;
  local anim = 0;
  local attacker = "";
  local weapon = "";
  local wasUser = false;
  local wasSuicide = false;
  local wasPlayer = false;

  --[[
    Returns the string to use in the death motive
    @return {string} string
  ]]
  local function GetDeathString()
    if (wasSuicide) then return "You commited suicide."; end
    if (wasUser) then
      if (AMMO_TYPES[weapon]) then
        return AMMO_TYPES[weapon];
      elseif (VEHICLES[weapon]) then
        return "flattened you.";
      else
        if (wasPlayer) then
          return "killed you.";
        else
          return "You died.";
        end
      end
    else
      if (EXPLOSION[attacker]) then
        return "You blew up.";
      else
        return nil;
      end
    end
  end

  --[[
    Draws a label describing how a player killed you
    @param {number} x
    @param {number} y
    @param {string} name
    @param {string} label
  ]]
  local function DrawPlayerLabel(x, y, name, label)
    -- Get total text size
    surface.SetFont("gtavds_mp_player");
    local nameSize = surface.GetTextSize(name);
    surface.SetFont("gtavds_mp_sub");
    local labelSize = surface.GetTextSize(label);
    local size = nameSize + labelSize + ScreenScale(1);

    draw.SimpleText(name, "gtavds_mp_player", x - size + (size * 0.5), y, Color(223, 40, 40), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
    draw.SimpleText(label, "gtavds_mp_sub", x - size + (size * 0.5) + nameSize + ScreenScale(2), y, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
  end

  --[[
    Draws the multiplayer/next-gen background
    @void
  ]]
  function GTAVDS:DrawPoly()
    local poly = {
      {x = 0, y = ScrH() * 0.424, u = 0, v = 0},
      {x = ScrW(), y = ScrH() * 0.424, u = 1, v = 0},
      {x = ScrW(), y = ScrH() * 0.62, u = 1, v = 1},
      {x = 0, y = ScrH() * 0.62, u = 0, v = 1}
    };

    surface.SetTexture(TEXTURE);
    surface.SetDrawColor(Color(0, 0, 0, 225));
    surface.DrawPoly(poly);
  end

  --[[
    Draws the 'wasted' label in the middle of the screen
    @param {boolean} should be on standby
  ]]
  function GTAVDS:DrawWastedMP(standby)
    -- Play animation
    if (standby) then anim = 0; return; end
    if (tick < RealTime()) then
      anim = math.min(anim + 0.035, 1);
      tick = RealTime() + 0.01;
    end

    -- Draw
    GTAVDS:DrawPoly();

    local y = 0.5;
    if (GetDeathString() == nil) then y = 0.512; end
    draw.SimpleText("YOU DIED", "gtavds_mp_title", ScrW() * 0.5, ScrH() * y, Color(200 + 55 * anim, 40 + 215 * anim, 40 + 215 * anim), 1, 1);

    if (GetDeathString() ~= nil) then
      -- Draw label
      if (wasPlayer and not wasSuicide) then
        DrawPlayerLabel(ScrW() * 0.5, ScrH() * 0.575, attacker, GetDeathString());
      else
        local label = GetDeathString();
        if (wasUser and not wasPlayer) then label = "A " .. language.GetPhrase(attacker) .. " " .. label; end
        draw.SimpleText(label, "gtavds_mp_sub", ScrW() * 0.5, ScrH() * 0.575, Color(255, 255, 255), 1, 1);
      end
    end
  end

  net.Receive(NET, function(len)
    weapon = net.ReadString();
    attacker = net.ReadString();
    wasUser = net.ReadBool();
    wasSuicide = net.ReadBool();
    wasPlayer = net.ReadBool();
  end);

end
