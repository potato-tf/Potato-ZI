/*
	/ create team_round_timer
	generate areas and make resource caches functional
		/ since we opened the map, we should recalculate blockers with tf_point_nav_interface
		1. GetAllAreas
		2. Determine how many mesh islands there are in the nav mesh
			Until all nav areas are accounted for:
				Pick the first nav area in getallnavareas that is not within an island
				(first iteration is just the first area)
				Breadth First Search with this area start, the resulting stored areas are our island
		3. Determine if each island is invalid:
			Make a list of all respawn room nav areas (pick one inside a respawnroom)
			Pick any nav area within the island
				if the area has a spawnroom flag, check every area within the island
				if they all have spawnroom flags, this island is unreachable
			If the area we picked didnt have a spawnroom flag
				Try to path to an area within every spawnroom
				If no path can be made, this island is unreachable
		4. Remove unreachable islands from our list
		5. Divide each island into areas
			Do this by making a multi flood select function that will BFS search from
			multiple areas with respect to each frontier and cleared array

			most maps are linear, so we can get a line along which to place points for areas
			most maps also have spawnrooms for red and blue team
				create a path from red to blue spawn, and pick areas along this path
			otherwise
				pick n random nav areas, reroll m times if too close to another area,
		6. Generate spots for resource caches
			pick n random nav areas, reroll m times if too close to another area,


	/ make sure there is only 1 red spawn and 1 blue spawn

	work on base logic
		/ start waiting for players (30 s)
		/ players can join red or blue
		/ (make sure to set whatever convar controls autobalance and stuff)

		either teleport red when they spawn to the starting area,
		or move the info_player_teamspawn to that position
		suiciding as red does not put you on blue

		players who join blue will spawn
		a short distance away from red and facing where reds were spawned

		red and blue players cannot damage each other during waiting for players

		after waiting for players, we have setup time of 30s.
		teams are balanced if necessary
		players cannot switch teams
		everyone is respawned to where they spawned in waiting for players,
		resource caches are highlighted and red gets some annotations explaining their use,
		also annotations explaining to distance from large groups of players

		/ timer set to 15 minutes, when it ends red wins
		dying on red will change your team to blue
		zombie respawn time is based on timer value,
			starting at 6 seconds, every 2.5 min reduce respawn time by 1 second,
			to a minimum of 2 seconds at 5 minutes left
		every 5 minutes swap areas
		make sure round win for either team resets the match properly

	make the sickness debuff system
		it is not active during setup or waiting for players
	spawn sparse small ammo packs throughout the map
	use the same system (with a rarer value) to spawn 1 time powerups
	again the same system with rarer values for weapon pickups (the model can be
	a pile of junk that gets highlighted when you get close or something)
		when you interact with it, the pile is consumed and you get a random super
		weapon for your class (play the voiceline), and you get highlighted with
		orange to make the enemy team target you more often (blue will also
		get an annotation when you pick it up telling to target this person)
	make the zombie ghost system and controls
		zombies spawn normally during waiting for players,
			(no ground spawn, no ghost)
		in setup they spawn in their ghost state but cannot rise as zombies yet
		until round start
	make the zombie ground spawn logic
	copy over zombie abilities, etc from zi
*/
IncludeScript("potatozi/navmesh.nut");

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

local TF_GAMERULES  = FindByClassname(null, "tf_gamerules");
local TCP_MASTER    = null;
local SKY_CAMERA    = null;
local NAV_INTERFACE = null;

local player_info    = {};
local global_fog     = null;
local global_cc      = null;
local global_timer   = null;
local global_win_red = null;
local global_win_blu = null;

// Creating this now instead of later allows it to override other non master controllers
local backup_fog = CreateByClassname("env_fog_controller");
backup_fog.DispatchSpawn();

// These can die at the end of the frame of HandleMapSpawn
local MAPSPAWN_ENT_KILL_LIST = [
	"tf_logic_*", "bot_hint_*", "func_nav_*", "func_tfbot_hint", "item_*", "env_sun",
	"beam", "env_beam", "env_lightglow", "env_sprite", "env_soundscape*", "ambient_generic",
	"func_capturezone", "func_dustmotes", "func_smokevolume", "func_regenerate",
	"info_particle_system", "move_rope", "keyframe_rope", "func_respawnroom*",
	"trigger_capture_area",
];
// These must die immediately (we need to create them)
local MAPSPAWN_ENT_DESTROY_LIST = [
	"color_correction", "team_round_timer", "game_round_win",
];

::PZI <- {
	function HandleMapSpawn()
	{
		TF_GAMERULES  = FindByClassname(null, "tf_gamerules");
		TCP_MASTER    = FindByClassname(null, "team_control_point_master");
		SKY_CAMERA    = FindByClassname(null, "sky_camera");
		NAV_INTERFACE = FindByClassname(null, "tf_point_nav_interface");
		if (!NAV_INTERFACE)
		{
			NAV_INTERFACE = SpawnEntityFromTable("tf_point_nav_interface", {
				targetname = "__potatozi_nav_interface",
			});
		}
		EntFireByHandle(NAV_INTERFACE, "RecomputeBlockers", "", 1.0, null, null);
		EntFireByHandle(NAV_INTERFACE, "RecomputeBlockers", "", 5.0, null, null);

		Convars.SetValue("mp_autoteambalance", 0);
		Convars.SetValue("mp_scrambleteams_auto", 0);
		Convars.SetValue("mp_teams_unbalance_limit", 0);
		//Convars.SetValue("mp_forceautoteam", 2);
		//Convars.SetValue("mp_respawnwavetime", 6);
		//mp_humans_must_join_team red (see if we're still able to force switch teams)
		Convars.SetValue("mp_tournament", 0);

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
		{
			ent.AcceptInput("Open", "", null, null);

			// Stay open
			ent.ValidateScriptScope();
			local scope = ent.GetScriptScope();
			scope.InputClose <- function() { return false; }
			scope.Inputclose <- scope.InputClose;
		}
		for (local ent = null; ent = FindByClassname(ent, "func_areaportal*");)
		{
			ent.AcceptInput("Open", "", null, null);

			// Stay open
			ent.ValidateScriptScope();
			local scope = ent.GetScriptScope();
			scope.InputClose <- function() { return false; }
			scope.Inputclose <- scope.InputClose;
		}

		// Remove most huds
		SetPropInt(TF_GAMERULES, "m_nHudType", 2); // Change to cp hud
		if (TCP_MASTER)
		{
			// Move it off screen
			SetPropFloat(TCP_MASTER, "m_flCustomPositionX", 1.0);
			EntFireByHandle(TCP_MASTER, "RoundSpawn", "", 0, null, null);
		}
		// Deleting these with a tcp_master present crashes the game
		// todo disable again after setup?
		EntFire("team_control_point", "Disable");

		SetSkyboxTexture("sky_downpour_heavy_storm");

		// Fog
		local old_fog = null;
		for (local ent = null; ent = FindByClassname(ent, "env_fog_controller");)
		{
			// Note any previous fog from manual script loading
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
			global_fog = backup_fog;

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

		// Look for nav mesh islands
		// (Disconnected pieces of the nav mesh, think of multi area maps like Thundermountain)
		for (local ent = null; ent = FindByClassname(ent, "info_player_teamspawn");)
		{
			if (!PZI_NavMesh.ISLANDS_PARSED)
			{
				local area = NavMesh.GetNearestNavArea(ent.GetOrigin(), 128.0, false, true);
				if (area)
				{
					// Is this area in another island?
					local reached = false;
					foreach (island in PZI_NavMesh.ISLANDS)
					{
						if (area in island)
						{
							reached = true;
							break;
						}
					}

					// Nope, create a new island
					if (!reached)
					{
						local island = PZI_NavMesh.FloodSelect(area);

						// 25 is a quick and dirty arbitrary number to filter out islands that aren't big enough for gameplay
						// in an efficient manner. Typically map islands will be in the thousands in length
						// and iterating that many times just to tally up size is wastefully expensive
						if (island && island.len() > 25)
							PZI_NavMesh.ISLANDS.append(island);
					}
				}
			}
		}

		PZI_NavMesh.ISLANDS_PARSED = true;
		printl(PZI_NavMesh.ISLANDS.len());

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
			targetname = "__potatozi_cc",
			minfalloff = -1,
			maxfalloff = -1,
			filename   = "materials/correction/ravenous.raw",
		});

		global_timer = SpawnEntityFromTable("team_round_timer", {
			targetname   = "__potatozi_timer",
			start_paused = 0,
			reset_time   = 1,
			show_in_hud  = 1,
			max_length   = 900,
			timer_length = 900,
			setup_length = 30,
		});
		global_timer.AcceptInput("Resume", "", null, null);
		EntityOutputs.AddOutput(global_timer, "OnFinished", "__potatozi_win_red", "RoundWin", "", 0, -1);

		global_win_red = SpawnEntityFromTable("game_round_win", {
			targetname      = "__potatozi_win_red",
			force_map_reset = 1,
			switch_teams    = false,
			TeamNum         = 2,
		});
	},

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
__CollectGameEventCallbacks(PZI);

local script_entity = FindByName(null, "__potatozi_entity");
if (!script_entity)
	script_entity = SpawnEntityFromTable("info_teleport_destination", {targetname="__potatozi_entity"});

// Late load
if (TF_GAMERULES)
	PZI.HandleMapSpawn();
