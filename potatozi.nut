::ROOT <- getroottable();
if (!("ConstantNamingConvention" in ROOT))
{
	foreach(a, b in Constants)
		foreach(k, v in b)
			ROOT[k] <- v != null ? v : 0;
}

foreach(k, v in ::NetProps.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::NetProps[k].bindenv(::NetProps);

foreach(k, v in ::Entities.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::Entities[k].bindenv(::Entities);

local MAXPLAYERS = MaxClients().tointeger();

local TF_GAMERULES = FindByClassname(null, "tf_gamerules");
local TCP_MASTER   = null;
local SKY_CAMERA   = null;

local player_info = {};
local global_fog  = null;
local global_cc   = null;

// These can die at the end of the frame of HandleMapSpawn
local MAPSPAWN_ENT_KILL_LIST = [
	"team_control_point*", "tf_logic_*", "bot_hint_*", "func_nav_*", "func_tfbot_hint", "item_*", "env_sun",
];
// These must die immediately (we need to create them)
local MAPSPAWN_ENT_DESTROY_LIST = [
	"color_correction", "team_round_timer",
];

local function HandleMapSpawn()
{
	if (!TF_GAMERULES) TF_GAMERULES = FindByClassname(null, "tf_gamerules");
	if (!TCP_MASTER)   TCP_MASTER   = FindByClassname(null, "team_control_point_master");
	if (!SKY_CAMERA)   SKY_CAMERA   = FindByClassname(null, "sky_camera");
	
	Convars.SetValue("mp_tournament", 0);
	
	SetPropBool(TF_GAMERULES, "m_bInWaitingForPlayers", false);
	SetPropBool(TF_GAMERULES, "m_bInSetup", false);

	local gmprops = [
		"m_bIsInTraining", "m_bIsWaitingForTrainingContinue", "m_bIsTrainingHUDVisible",
		"m_bIsInItemTestingMode", "m_bPlayingKoth", "m_bPlayingMedieval", "m_bPlayingHybrid_CTF_CP",
		"m_bPlayingSpecialDeliveryMode", "m_bPlayingRobotDestructionMode", "m_bPlayingMannVsMachine",
		"m_bIsUsingSpells", "m_bCompetitiveMode", "m_bPowerupMode", "m_nForceEscortPushLogic",
		"m_bBountyModeEnabled",
	];
	foreach (prop in gmprops)
		SetPropBool(TF_GAMERULES, prop, false);

	// Open up the map
	for (local ent = null; ent = FindByClassname(ent, "func_door*");)
		ent.AcceptInput("Open", "", null, null);
	for (local ent = null; ent = FindByClassname(ent, "func_areaportal*");)
		ent.AcceptInput("Open", "", null, null);
	
	// Remove most huds
	SetPropInt(TF_GAMERULES, "m_nHudType", 2); // Change to cp hud
	if (TCP_MASTER)
	{
		// Move it off screen
		SetPropFloat(TCP_MASTER, "m_flCustomPositionX", 1.0);
		EntFireByHandle(TCP_MASTER, "RoundSpawn", "", 0, null, null);
	}
	
	SetSkyboxTexture("sky_downpour_heavy_storm");
	
	// Fog
	local old_fog = null;
	for (local ent = null; ent = FindByClassname(ent, "env_fog_controller");)
	{
		// Note any previous fogs from manual script loading
		if (ent.GetName() == "__potatozi_fog")
		{
			old_fog = ent;
			continue;
		}
		// Hijack master fog controller (it cannot be overriden or deleted)
		else if (!global_fog && GetPropInt(ent, "m_spawnflags") == 1)
		{
			global_fog = ent;
			continue;
		}
		// Disable everything else
		ent.AcceptInput("TurnOff", "", null, null);
		ent.AcceptInput("Disable", "", null, null);
	}
	// Reuse old fog instead of creating a new one each time we load the script
	if (old_fog && !global_fog)
		global_fog = old_fog;
	if (!global_fog)
		global_fog = CreateByClassname("env_fog_controller");

	global_fog.KeyValueFromString("targetname", "__potatozi_fog");
	global_fog.KeyValueFromInt("spawnflags", 1);
	global_fog.KeyValueFromInt("fogenable", 1);
	global_fog.KeyValueFromFloat("fogstart", 0.0);
	global_fog.KeyValueFromFloat("fogend", 2500.0);
	global_fog.KeyValueFromFloat("farz", 5000.0);
	global_fog.KeyValueFromFloat("fogmaxdensity", 1.0);
	global_fog.KeyValueFromString("fogcolor", "77 82 71");
	global_fog.KeyValueFromInt("fogblend", 0);
	global_fog.DispatchSpawn();
	
	// Skybox fog
	if (SKY_CAMERA)
	{
		SKY_CAMERA.KeyValueFromInt("fogenable", 1);
		SKY_CAMERA.KeyValueFromFloat("fogstart", 0.0);
		SKY_CAMERA.KeyValueFromFloat("fogend", 0.0);
		SKY_CAMERA.KeyValueFromFloat("fogmaxdensity", 1.0);
		SKY_CAMERA.KeyValueFromString("fogcolor", "77 82 71");
		SKY_CAMERA.KeyValueFromInt("fogblend", 0);
	}
	
	foreach (player, info in player_info)
	{
		if (!player) continue;

		player.ValidateScriptScope();
		local scope = player.GetScriptScope();
		
		// Maps like to use this input and it fucks with our fog
		scope.InputSetFogController <- function() {
			if (caller != global_fog)
				return false;
		};
		scope.Inputsetfogcontroller <- scope.InputSetFogController;
		
		player.AcceptInput("SetFogController", "__potatozi_fog", global_fog, global_fog);
		
		if (SKY_CAMERA)
		{
			SetPropFloat(player, "m_Local.m_skybox3d.fog.start", 0.0)
			SetPropFloat(player, "m_Local.m_skybox3d.fog.maxdensity", 1.0)
			SetPropFloat(player, "m_Local.m_skybox3d.fog.end", 0.0)
			SetPropBool(player, "m_Local.m_skybox3d.fog.enable", true)
			SetPropInt(player, "m_Local.m_skybox3d.fog.colorPrimary", 5067335)
			SetPropBool(player, "m_Local.m_skybox3d.fog.blend", false)
		}
	}
	
	// Commit mass murder
	// ..immediately
	local del = [];
	foreach (target in MAPSPAWN_ENT_DESTROY_LIST)
		for (local ent = null; ent = FindByClassname(ent, target);)
			del.append(ent);
	foreach (ent in del)
		ent.Destroy();
	
	// ..at the end of the frame
	foreach (target in MAPSPAWN_ENT_KILL_LIST)
		EntFire(target, "Kill");
		
	// Color correction
	global_cc = SpawnEntityFromTable("color_correction", {
		minfalloff = -1,
		maxfalloff = -1,
		filename = "materials/correction/ravenous.raw",
	});
}

::PotatoZI <- {
	function OnGameEvent_player_activate(params)
	{
		local player = GetPlayerFromUserID(params.userid);
		if (!player || player.IsBotOfType(1337)) return;
		
		player_info[player] <- {};
	},
	function OnGameEvent_player_disconnect(params)
	{
		if (params.bot) return;
		local player = GetPlayerFromUserID(params.userid);
		if (!player) return;
		
		if (player in player_info)
			delete player_info[player];
	},
	
	function OnGameEvent_post_inventory_application(params)
	{
		local player = GetPlayerFromUserID(params.userid);
		if (!player || player.IsBotOfType(1337)) return;
		
		player.AcceptInput("SetFogController", "__potatozi_fog", global_fog, global_fog);
	},

	function OnGameEvent_teamplay_round_start(params)
	{
		HandleMapSpawn();
	},
};
__CollectGameEventCallbacks(PotatoZI);

local script_entity = FindByName(null, "__potatozi_entity");
if (!script_entity)
	script_entity = SpawnEntityFromTable("info_teleport_destination", {targetname="__potatozi_entity"});

// Late load
if (TF_GAMERULES)
	HandleMapSpawn();