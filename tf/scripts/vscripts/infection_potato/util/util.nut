// All Global Utility Functions go here

PZI_CREATE_SCOPE( "__pzi_util", "PZI_Util", null, "PZI_UtilThink" )

PZI_Util.HumanTable  <- {} // player caching for faster player handle/userid lookups
PZI_Util.ZombieTable <- {}
PZI_Util.PlayerTable <- {}
PZI_Util.BotTable 	 <- {}

PZI_Util.HumanArray  <- [] // array variants
PZI_Util.ZombieArray <- []
PZI_Util.PlayerArray <- []
PZI_Util.BotArray 	 <- []

PZI_Util.kill_on_spawn <- {} // wearables to delete on player spawn
PZI_Util.kill_on_death <- {} // wearables to delete on player death

// entity caching for faster iteration/lookup
PZI_Util.EntTable <- {

	[First()] = {

		name 	  = First().GetName()
		scope     = null
		entidx    = 0
		classname = "worldspawn"
		scriptid  = First().GetScriptId()
		thinkfunc = ""
		cachetime = Time()
	}

	ByName          = { cachetime = Time(), BigNet = { [ FindByName( null, "BigNet" ) ] = {} } }
	ByClassname     = { cachetime = Time(), worldspawn = { [ First() ] = {} } }
	ByModel         = { cachetime = Time(), [ First().GetModelName() ] = { [ First() ] = {} } }
	ByTarget        = { cachetime = Time(), [ GetPropString( First(), "m_target" ) ] = { [ First() ] = {} } }
	ByScriptID      = { cachetime = Time(), [ First().GetScriptId() ] = { [ First() ] = {} } }
	ByThinkFunc     = { cachetime = Time(), [ First().GetScriptThinkFunc() ] = { [ First() ] = {} } }

}.setdelegate( {

	function _newslot( key, value ) {

		if ( typeof key != "instance" || !( key instanceof CBaseEntity ) )
			Assert( false, format( "Invalid entity key: \"%s\"", key.tostring() ) )

		if ( !value ) {

			value = {

				name 	  = key.GetName()
				scope     = key.GetScriptScope()
				entidx    = key.entindex()
				classname = key.GetClassname()
				scriptid  = key.GetScriptId()
				thinkfunc = key.GetScriptThinkFunc()
				cachetime = Time()
			}
		}

		this.rawset( key, value )
	}

	function _delslot( key ) {

		if ( key && key.IsValid() )
			EntFireByHandle( key, "Kill", "", -1, null, null )

		this.rawdelete( key )
	}
} )

// class index -> class string lookup
PZI_Util.Classes 	 <- ["", "scout", "sniper", "soldier", "demo", "medic", "heavy", "pyro", "spy", "engineer", "civilian"]
PZI_Util.ClassesCaps <- ["", "Scout", "Sniper", "Soldier", "Demoman", "Medic", "Heavy", "Pyro", "Spy", "Engineer", "Civilian"]
PZI_Util.Slots   	 <- ["slot_primary", "slot_secondary", "slot_melee", "slot_utility", "slot_building", "slot_pda", "slot_pda2"]

PZI_Util.ConVars      <- {} // convar tracking to revert to original values
PZI_Util.EntShredder  <- [] // entity shredder.  Fixed number of entities deleted per tick.
PZI_Util.AllNavAreas  <- {} // gets filled by GetAllAreas at the end of this file
PZI_Util.SafeNavAreas <- {} // gets filled by GetAllAreas at the end of this file
PZI_Util.NAV_DEBUG    <- false // draw nav areas


PZI_Util.ROBOT_ARM_PATHS <- [

	"", // Dummy
	"models/weapons/c_models/c_scout_bot_arms.mdl",
	"models/weapons/c_models/c_sniper_bot_arms.mdl",
	"models/weapons/c_models/c_soldier_bot_arms.mdl",
	"models/weapons/c_models/c_demo_bot_arms.mdl",
	"models/weapons/c_models/c_medic_bot_arms.mdl",
	"models/weapons/c_models/c_heavy_bot_arms.mdl",
	"models/weapons/c_models/c_pyro_bot_arms.mdl",
	"models/weapons/c_models/c_spy_bot_arms.mdl",
	"models/weapons/c_models/c_engineer_bot_arms.mdl",
	"", // Civilian
]

PZI_Util.HUMAN_ARM_PATHS <- [

	"models/weapons/c_models/c_medic_arms.mdl", //dummy
	"models/weapons/c_models/c_scout_arms.mdl",
	"models/weapons/c_models/c_sniper_arms.mdl",
	"models/weapons/c_models/c_soldier_arms.mdl",
	"models/weapons/c_models/c_demo_arms.mdl",
	"models/weapons/c_models/c_medic_arms.mdl",
	"models/weapons/c_models/c_heavy_arms.mdl",
	"models/weapons/c_models/c_pyro_arms.mdl",
	"models/weapons/c_models/c_spy_arms.mdl",
	"models/weapons/c_models/c_engineer_arms.mdl",
	"models/weapons/c_models/c_engineer_gunslinger.mdl",	//CIVILIAN/Gunslinger
]

PZI_Util.MaxAmmoTable <- {

	[TF_CLASS_SCOUT] = {
		["tf_weapon_scattergun"]            = 32,
		["tf_weapon_handgun_scout_primary"] = 32,
		["tf_weapon_soda_popper"]           = 32,
		["tf_weapon_pep_brawler_blaster"]   = 32,

		["tf_weapon_handgun_scout_secondary"] = 36,
		["tf_weapon_pistol"]                  = 36,
	},
	[TF_CLASS_SOLDIER] = {
		["tf_weapon_rocketlauncher"]           = 20,
		["tf_weapon_rocketlauncher_directhit"] = 20,
		["tf_weapon_rocketlauncher_airstrike"] = 20,
		[ID_ROCKET_JUMPER] = 60,

		["tf_weapon_shotgun_soldier"] = 32,
		["tf_weapon_shotgun"]         = 32,
	},
	[TF_CLASS_PYRO] = {
		["tf_weapon_flamethrower"]            = 200,
		["tf_weapon_rocketlauncher_fireball"] = 40,

		["tf_weapon_shotgun_pyro"] = 32,
		["tf_weapon_shotgun"]      = 32,
		["tf_weapon_flaregun"]     = 16,
	},
	[TF_CLASS_DEMOMAN] = {
		["tf_weapon_grenadelauncher"] = 16,
		["tf_weapon_cannon"]          = 16,

		["tf_weapon_pipebomblauncher"] = 24,
		[ID_STICKYBOMB_JUMPER] = 72,
	},
	[TF_CLASS_HEAVYWEAPONS] = {
		["tf_weapon_minigun"]     = 200,

		["tf_weapon_shotgun_hwg"] = 32,
		["tf_weapon_shotgun"]     = 32,
	},
	[TF_CLASS_ENGINEER] = {
		["tf_weapon_shotgun"]                 = 32,
		["tf_weapon_sentry_revenge"]          = 32,
		["tf_weapon_shotgun_building_rescue"] = 16,
		[ID_SHOTGUN_PRIMARY] = 32,

		["tf_weapon_pistol"] = 200,
	},
	[TF_CLASS_MEDIC] = {
		["tf_weapon_syringegun_medic"] = 150,
		["tf_weapon_crossbow"]         = 38,
	},
	[TF_CLASS_SNIPER] = {
		["tf_weapon_sniperrifle"]         = 25,
		["tf_weapon_sniperrifle_decap"]   = 25,
		["tf_weapon_sniperrifle_classic"] = 25,
		["tf_weapon_compound_bow"]        = 12,

		["tf_weapon_smg"]         = 75,
		["tf_weapon_charged_smg"] = 75,
	},
	[TF_CLASS_SPY] = {
		["tf_weapon_revolver"] = 24,
	},
}

PZI_Util.PROJECTILE_WEAPONS <- {

	tf_weapon_jar_milk 				   = true
	tf_weapon_cleaver 				   = true

	tf_weapon_rocketlauncher 		   = true
	tf_weapon_rocketlauncher_airstrike = true
	tf_weapon_rocketlauncher_directhit = true
	tf_weapon_particle_cannon 		   = true
	tf_weapon_raygun 				   = true

	tf_weapon_rocketlauncher_fireball  = true
	tf_weapon_flaregun 				   = true
	tf_weapon_flaregun_revenge 		   = true
	tf_weapon_jar_gas 				   = true

	tf_weapon_grenadelauncher  		   = true
	tf_weapon_cannon		  		   = true
	tf_weapon_pipebomblauncher 		   = true

	tf_weapon_shotgun_building_rescue  = true
	tf_weapon_drg_pomson 			   = true

	tf_weapon_syringegun_medic 		   = true

	tf_weapon_compound_bow 			   = true
	tf_weapon_jar 					   = true
}

// All entity classname prefixes listed here will have their think functions overwritten and throw a warning
// Think functions will instead be added to a table with the value of the first element in the array
// You should always use PopExtUtil.AddThink instead to handle these gracefully.

// e.g. calling AddThinkToEnt( player, "MyFunc") with the default config:
// - Creates a table named "PlayerThinkTable" and a think function named "PlayerThinks" in player scope
// - The "true" think function is set to "PlayerThinks", this function iterates over the table and calls each function
// - Passing null will simply clear the think table


PZI_Util.ThinkTableSetup <- {

    // entity classname prefixes to overwrite, and the name of the think table
    player 			= [ "ThinkTable", "PlayerThinks" ]
    tf_projectile_ 	= [ "ThinkTable", "ProjectileThinks" ]
    tf_weapon_ 		= [ "ThinkTable", "WeaponThinks" ]
    tf_wearable 	= [ "ThinkTable", "WearableThinks" ]
}

PZI_Util.ROCKET_LAUNCHER_CLASSNAMES <- [

	"tf_weapon_rocketlauncher",
	"tf_weapon_rocketlauncher_airstrike",
	"tf_weapon_rocketlauncher_directhit",
	"tf_weapon_particle_cannon",
]

PZI_Util.DeflectableProjectiles <- {

	tf_projectile_arrow				   = 1 // Huntsman arrow, Rescue Ranger bolt
	tf_projectile_ball_ornament		   = 1 // Wrap Assassin
	tf_projectile_cleaver			   = 1 // Flying Guillotine
	tf_projectile_energy_ball		   = 1 // Cow Mangler charge shot
	tf_projectile_flare				   = 1 // Flare guns projectile
	tf_projectile_healing_bolt		   = 1 // Crusader's Crossbow
	tf_projectile_jar				   = 1 // Jarate
	tf_projectile_jar_gas			   = 1 // Gas Passer explosion
	tf_projectile_jar_milk			   = 1 // Mad Milk
	tf_projectile_lightningorb		   = 1 // Spell Variant from Short Circuit
	tf_projectile_mechanicalarmorb	   = 1 // Short Circuit energy ball
	tf_projectile_pipe				   = 1 // Grenade Launcher bomb
	tf_projectile_pipe_remote		   = 1 // Stickybomb Launcher bomb
	tf_projectile_rocket			   = 1 // Rocket Launcher rocket
	tf_projectile_sentryrocket		   = 1 // Sentry gun rocket
	tf_projectile_stun_ball			   = 1 // Baseball
}

function PZI_Util::_OnDestroy() {

	ResetConvars( false )

	foreach( i, ent in EntShredder ) {

		if ( ent && ent.IsValid() ) {

			SetPropBool( ent, STRING_NETPROP_PURGESTRINGS, true )
			EntFireByHandle( ent, "Kill", "", i * 0.1, null, null )
		}
	}
}

function PZI_Util::EntityManager() {

	// strip out leftover nulls
	EntShredder = EntShredder.filter(@(_, ent) ent && ent.IsValid())

	foreach( i, ent in EntShredder ) {

		if ( !(i % 10) )
			yield ent

		SetPropBool( ent, STRING_NETPROP_PURGESTRINGS, true )
		EntFireByHandle( ent, "Kill", "", -1, null, null )
	}
}

local gen = null
function PZI_Util::ThinkTable::EntityManagerThink() {

	if ( !EntShredder.len() )
		return 0.5

	if ( !gen || gen.getstatus() == "dead" )
		gen = EntityManager()

	local result = resume gen
	return -1
}

function PZI_Util::GetEntScope( ent ) {

	local scope = ent.GetScriptScope() || ( ent.ValidateScriptScope(), ent.GetScriptScope() )

	return scope
}

function PZI_Util::TouchCrashFix() { return activator && activator.IsValid() }

function PZI_Util::SetTargetname( ent, name ) {

	local oldname = GetPropString( ent, STRING_NETPROP_NAME )
	SetPropString( ent, STRING_NETPROP_NAME, name )

	if ( oldname != "" )
		PZI_GameStrings.StringTable[ oldname ] <- null
}

// function PZI_Util::PurgeGameString( str, urgent = false, str2 = null ) {

// 	if ( urgent ) {

// 		local tempent = CreateByClassname( "logic_autosave" )
// 		SetTargetname( tempent, str )
// 		SetPropBool( tempent, STRING_NETPROP_PURGESTRINGS, true )
// 		tempent.Kill()

// 		if ( str2 ) {

// 			local tempent = CreateByClassname( "logic_autosave" )
// 			SetTargetname( tempent, str2 )
// 			SetPropBool( tempent, STRING_NETPROP_PURGESTRINGS, true )
// 			tempent.Kill()
// 		}
// 		return
// 	}

// 	GameStrings[str] <- str2
// 	// SpawnEnt( "logic_autosave", str, true )
// }

// spawn permanent ents or tempents that are automatically wiped out on map reset/fixed timer
function PZI_Util::SpawnEnt( ... ) {

	local classname = vargv[0]
	local name = vargv[1]
	local temp = 2 in vargv ? vargv[2] : false
	local args = 3 in vargv ? vargv.slice( 3 ) : []

	local ent = CreateByClassname( classname )
	SetTargetname( ent, name )

	local args_len = args.len()

	if ( args && args_len ) {

		for ( local i = 0; i < args_len; i += 2 ) {

			if ( !( i in args ) || !( i + 1 in args ) )
				break

			ent.KeyValueFromString( args[i], args[i + 1].tostring() )
		}
	}

	if ( temp ) {
		EntShredder.append( ent )
		return ent
	}

	ent.ValidateScriptScope()

	// auto-detect triggers
	if ( HasProp( ent, "m_hTouchingEntities" ) ) {

		SetPropInt( ent, "m_spawnflags", SF_TRIGGER_ALLOW_CLIENTS )
		local scope = GetEntScope( ent )
		scope.InputStartTouch <- TouchCrashFix
		scope.Inputstarttouch <- TouchCrashFix
		scope.InputEndTouch <- TouchCrashFix
		scope.Inputendtouch <- TouchCrashFix
		::DispatchSpawn( ent )
		ent.SetSolid( SOLID_BBOX )
		ent.SetSize( sizemin, sizemax )
	}

	SetPropBool( ent, STRING_NETPROP_PURGESTRINGS, true )

	return ent
}

PZI_Util.Worldspawn 	   <- First()
PZI_Util.StartRelay 	   <- FindByName( null, "wave_start_relay" )
PZI_Util.FinishedRelay 	   <- FindByName( null, "wave_finished_relay" )
PZI_Util.GameRules 		   <- FindByClassname( null, "tf_gamerules" )
PZI_Util.ObjectiveResource <- FindByClassname( null, "tf_objective_resource" )
PZI_Util.MonsterResource   <- FindByClassname( null, "monster_resource" )
PZI_Util.MvMLogicEnt 	   <- FindByClassname( null, "tf_logic_mann_vs_machine" )
PZI_Util.MvMStatsEnt 	   <- FindByClassname( null, "tf_mann_vs_machine_stats" )
PZI_Util.PlayerManager 	   <- FindByClassname( null, "tf_player_manager" )
PZI_Util.TriggerHurt 	   <- PZI_Util.SpawnEnt( "trigger_hurt", "__pzi_triggerhurt", false )
PZI_Util.ClientCommand 	   <- PZI_Util.SpawnEnt( "point_clientcommand", "__pzi_clientcommand", false )
PZI_Util.RespawnOverride   <- PZI_Util.SpawnEnt( "trigger_player_respawn_override", "__pzi_respawnoverride", false )
PZI_Util.TriggerParticle   <- PZI_Util.SpawnEnt( "trigger_particle", "__pzi_triggerparticle", false, "attachment_type", 4 )

PZI_Util.CommentaryNode	   <- @() FindByName( null, "__pzi_hide_fcvar_notify" ) ||
								PZI_Util.SpawnEnt( "point_commentary_node", "__pzi_hide_fcvar_notify", true, "commentaryfile", " ", "commentaryfilenohdr", " " )

PZI_Util.PopInterface 	   <- FindByClassname( null, "point_populator_interface" ) ||
								PZI_Util.SpawnEnt( "point_populator_interface", "__pzi_pop_interface", false )

PZI_Util.NavInterface 	   <- FindByClassname( null, "tf_point_nav_interface" ) ||
								PZI_Util.SpawnEnt( "tf_point_nav_interface", "__pzi_nav_interface", false )

PZI_Util.IsInSetup 	       <- false
PZI_Util.CurrentWaveNum    <- GetPropInt( PZI_Util.ObjectiveResource, "m_nMannVsMachineWaveCount" )
PZI_Util.IsLinux 		   <- RAND_MAX != 32767

// all the one-liners
function PZI_Util::ShowMessage( message ) 		    { ClientPrint( null, HUD_PRINTCENTER, message ) }
function PZI_Util::WeaponSwitchSlot( player, slot ) { EntFire( "__pzi_util_clientcommand", "Command", format( "slot%d", slot + 1 ), -1, player ) }
function PZI_Util::SwitchWeaponSlot( player, slot ) { EntFire( "__pzi_util_clientcommand", "Command", format( "slot%d", slot + 1 ), -1, player ) }
function PZI_Util::ShowHintMessage( message ) 	    { SendGlobalGameEvent( "player_hintmessage", {hintmessage = message} ) }
function PZI_Util::HideAnnotation( id = 0 ) 		{ SendGlobalGameEvent( "hide_annotation", {id = id} ) }
function PZI_Util::SetItemIndex( item, index ) 	    { SetPropInt( item, STRING_NETPROP_ITEMDEF, index ) }
function PZI_Util::PrecacheParticle( name ) 		{ PrecacheEntityFromTable( { classname = "info_particle_system", effect_name = name } ) }
function PZI_Util::PrecacheModelGibs( name ) 		{ PrecacheEntityFromTable( { classname = "tf_generic_bomb", model = name } ) }
function PZI_Util::DisableCloak( player ) 		    { SetPropFloat( player, "m_Shared.m_flStealthNextChangeTime", Time() * INT_MAX ) }
function PZI_Util::SetPlayerName( player, name ) 	{ SetPropString( player, "m_szNetname", name ) }
function PZI_Util::PlayerRespawn() 				    { self.ForceRegenerateAndRespawn() }
function PZI_Util::SetEffect( ent, value ) 		    { SetPropInt( ent, "m_fEffects", value ) }
function PZI_Util::GetPlayerSteamID( player ) 	    { return GetPropString( player, "m_szNetworkIDString" ) }
function PZI_Util::IsDucking( player ) 			    { return player.GetFlags() & FL_DUCKING }
function PZI_Util::IsOnGround( player ) 			{ return player.GetFlags() & FL_ONGROUND }
function PZI_Util::GetItemIndex( item ) 			{ return GetPropInt( item, STRING_NETPROP_ITEMDEF ) }
function PZI_Util::GetHammerID( ent ) 			    { return GetPropInt( ent, "m_iHammerID" ) }
function PZI_Util::GetSpawnFlags( ent ) 			{ return GetPropInt( ent, "m_spawnflags" ) }
function PZI_Util::GetPopfileName() 	 			{ return GetPropString( ObjectiveResource, STRING_NETPROP_POPNAME ) }
function PZI_Util::GetPlayerName( player ) 		    { return GetPropString( player, "m_szNetname" ) }
function PZI_Util::GetPlayerUserID( player ) 		{ return GetPropIntArray( PlayerManager, "m_iUserID", player.entindex() ) }
function PZI_Util::InUpgradeZone( player ) 		    { return GetPropBool( player, "m_Shared.m_bInUpgradeZone" ) }
function PZI_Util::InButton( player, button ) 	    { return GetPropInt( player, "m_nButtons" ) & button }
function PZI_Util::HasEffect( ent, value ) 		    { return GetPropInt( ent, "m_fEffects" ) == value }
function PZI_Util::DispatchEffect( ent, effect ) 	{ if ( ent && effect ) DispatchParticleEffect( effect, typeof ent == "Vector" ? ent : ent.GetLocalOrigin(), typeof ent == "Vector" ? Vector() : ent.GetLocalAngles() + Vector() ) }

function PZI_Util::ForceChangeClass( player, classindex = 1 ) {

	player.SetPlayerClass( classindex )
	SetPropInt( player, "m_Shared.m_iDesiredPlayerClass", classindex )
	player.ForceRegenerateAndRespawn()
}

function PZI_Util::PlayerClassCount() {

	local classes = array( TF_CLASS_COUNT_ALL, 0 )
	foreach ( player in HumanArray )
		classes[player.GetPlayerClass()]++
	return classes
}

function PZI_Util::ChangePlayerTeamMvM( player, teamnum = TF_TEAM_PVE_INVADERS, forcerespawn = false ) {

	if ( GameRules ) {
		SetPropBool( GameRules, "m_bPlayingMannVsMachine", false )
		player.ForceChangeTeam( teamnum, false )
		SetPropBool( GameRules, "m_bPlayingMannVsMachine", true )

		if ( forcerespawn )
			ScriptEntFireSafe( player, "self.ForceRespawn()", SINGLE_TICK )
	}
}

// example
// ChatPrint( null, "{player} {color}guessed the answer first!", player, TF_COLOR_DEFAULT )
function PZI_Util::ShowChatMessage( target, fmt, ... ) {

	local result = "\x07FFCC22[Map] "
	local start = 0
	local end = fmt.find( "{" )
	local i = 0
	while ( end != null ) {
		result += fmt.slice( start, end )
		start = end + 1
		end = fmt.find( "}", start )
		if ( end == null )
			break
		local word = fmt.slice( start, end )

		if ( word == "player" ) {
			local player = vargv[i++]

			local team = player.GetTeam()
			if ( team == TEAM_HUMAN )
				result += "\x07" + TF_COLOR_RED
			else if ( team == TEAM_ZOMBIE )
				result += "\x07" + TF_COLOR_BLUE
			else
				result += "\x07" + TF_COLOR_SPEC
			result += GetPlayerName( player )
		}
		else if ( word == "color" ) {
			result += "\x07" + vargv[i++]
		}
		else if ( word == "int" || word == "float" ) {
			result += vargv[i++].tostring()
		}
		else if ( word == "str" ) {
			result += vargv[i++]
		}
		else {
			result += "{" + word + "}"
		}

		start = end + 1
		end = fmt.find( "{", start )
	}

	result += fmt.slice( start )

	ClientPrint( target, HUD_PRINTTALK, result )
}

function PZI_Util::CopyTable( table, keyfunc = null, valuefunc = null ) {

	if ( !table || typeof table != "table" ) return

	local newtable = {}

	foreach ( key, value in table ) {

		//run optional functions on the key and value
		if ( keyfunc != null )
			key = keyfunc( key )

		if ( valuefunc != null )
			value = valuefunc( value )

		newtable[key] <- value
		if ( typeof value == "table" || typeof value == "array" ) {

			newtable[key] = CopyTable( value )
		}
		else {

			newtable[key] <- value
		}
	}
	return newtable
}

function PZI_Util::HexOrIntToRgb( hex_or_int, alpha = false, return_as = null ) {

	local rgba = [0, 0, 0, 255]

	if ( typeof hex_or_int == "string" ) {

		rgba[0] = hex_or_int.slice( 0, 2 ).tointeger( 16 )
		rgba[1] = hex_or_int.slice( 2, 4 ).tointeger( 16 )
		rgba[2] = hex_or_int.slice( 4, 6 ).tointeger( 16 )

		if ( alpha )
			rgba[3] = hex_or_int.slice( 6, 8 ).tointeger( 16 )
	}
	else if ( typeof hex_or_int == "integer" ) {

	rgba[0] = hex_or_int & 0xFF
	rgba[1] = ( hex_or_int >> 8 ) & 0xFF
	rgba[2] = ( hex_or_int >> 16 ) & 0xFF

		if ( alpha )
			rgba[3] = ( hex_or_int >> 24 ) & 0xFF
	}

	if ( return_as ) {

		switch ( return_as ) {

			case "int":
				return rgba[0] | ( rgba[1] << 8 ) | ( rgba[2] << 16 ) | ( rgba[3] << 24 )

			case "hex":
				return format( "#%02X%02X%02X%02X", rgba[0], rgba[1], rgba[2], rgba[3] )

			default:
				return rgba
		}
	}

	return rgba
}

function PZI_Util::CountAlivePlayers( countbots = false, printout = false ) {

	if ( !IsInSetup ) return

	local playersalive = 0

	PZI_Util.ValidatePlayerTables()

	local player_array = countbots ? BotArray : HumanArray

	foreach ( player in player_array )
		if ( player.IsAlive() )
			playersalive++

	if ( printout ) {

		ClientPrint( null, HUD_PRINTTALK, format( "Players Alive: %d", playersalive ) )
		printf( "Players Alive: %d\n", playersalive )
	}

	return playersalive
}

function PZI_Util::SetParentLocalOriginDo( child, parent, attachment = null ) {

	SetPropEntity( child, "m_hMovePeer", parent.FirstMoveChild() )
	SetPropEntity( parent, "m_hMoveChild", child )
	SetPropEntity( child, "m_hMoveParent", parent )

	local orig_pos = child.GetLocalOrigin()
	child.SetLocalOrigin( orig_pos + Vector( 0, 0, 1 ) )
	child.SetLocalOrigin( orig_pos )

	local orig_angles = child.GetLocalAngles()
	child.SetLocalAngles( orig_angles + QAngle( 0, 0, 1 ) )
	child.SetLocalAngles( orig_angles )

	local orig_vel = child.GetAbsVelocity()
	child.SetAbsVelocity( orig_vel + Vector( 0, 0, 1 ) )
	child.SetAbsVelocity( orig_vel )

	EntFireByHandle( child, "SetParent", "!activator", -1, parent, parent )
	if ( attachment != null ) {
		SetPropEntity( child, "m_iParentAttachment", parent.LookupAttachment( attachment ) )
		EntFireByHandle( child, "SetParentAttachmentMaintainOffset", attachment, -1, parent, parent )
	}
}

// Sets parent immediately in a dirty way. Does not retain absolute origin, retains local origin instead.
// child parameter may also be an array of entities
function PZI_Util::SetParentLocalOrigin( child, parent, attachment = null ) {

	if ( typeof child == "array" )
		foreach( child_in in child )
			SetParentLocalOriginDo( child_in, parent, attachment )
	else
		SetParentLocalOriginDo( child, parent, attachment )
}

// Setup collision bounds of a trigger entity
// TODO: probably obsolete? what does this do that SetSize doesn't?
function PZI_Util::SetupTriggerBounds( trigger, mins = null, maxs = null ) {

	trigger.SetModel( "models/weapons/w_models/w_rocket.mdl" )

	if ( mins != null ) {
		SetPropVector( trigger, "m_Collision.m_vecMinsPreScaled", mins )
		SetPropVector( trigger, "m_Collision.m_vecMins", mins )
	}
	if ( maxs != null ) {
		SetPropVector( trigger, "m_Collision.m_vecMaxsPreScaled", maxs )
		SetPropVector( trigger, "m_Collision.m_vecMaxs", maxs )
	}

	trigger.SetSolid( SOLID_BBOX )
}

function PZI_Util::PrintTable( table ) {

	if ( !table || ( typeof table != "table" && typeof table != "array" ) ) {
		ClientPrint( null, 2, ""+table )
		return
	}

	DoPrintTable( table, 0 )
}

function PZI_Util::DoPrintTable( table, indent ) {

	local line = ""
	for ( local i = 0; i < indent; i++ ) {
		line += " "
	}
	line += typeof table == "array" ? "[" : "{"

	ClientPrint( null, 2, line )

	indent += 2
	foreach( k, v in table ) {
		line = ""
		for ( local i = 0; i < indent; i++ ) {
			line += " "
		}
		line += k.tostring()
		line += " = "

		if ( typeof v == "table" || typeof v == "array" ) {
			ClientPrint( null, 2, line )
			DoPrintTable( v, indent )
		}
		else {
			try {
				line += v.tostring()
			}
			catch ( e ) {
				line += typeof v
			}

			ClientPrint( null, 2, line )
		}
	}
	indent -= 2

	line = ""
	for ( local i = 0; i < indent; i++ ) {
		line += " "
	}
	line += typeof table == "array" ? "]" : "}"

	ClientPrint( null, 2, line )
}

// Make a fake wearable that is attached to the player.  Applies to ragdolls
// The wearable is automatically removed on respawn.
// killed on spawn instead of death
function PZI_Util::GiveWearableItem( player, item_id, model = null ) {

	local dummy = CreateByClassname( "tf_weapon_parachute" )
	SetPropInt( dummy, STRING_NETPROP_ITEMDEF, ID_BASE_JUMPER )
	SetPropBool( dummy, STRING_NETPROP_INIT, true )
	dummy.SetTeam( player.GetTeam() )
	::DispatchSpawn( dummy )
	player.Weapon_Equip( dummy )

	local wearable = GetPropEntity( dummy, "m_hExtraWearable" )
	dummy.Kill()

	InitEconItem( wearable, item_id )
	::DispatchSpawn( wearable )
	SetTargetname( wearable, format( "__pzi_util_wearable_%d", wearable.entindex() ) )
	SetPropBool( wearable, STRING_NETPROP_PURGESTRINGS, true )

	if ( model )
		wearable.SetModelSimple( model )

	// avoid infinite loops from post_inventory_application hooks
	player.AddEFlags( EFL_IS_BEING_LIFTED_BY_BARNACLE )
	SendGlobalGameEvent( "post_inventory_application",  { userid = PlayerTable[ player ] } )
	player.RemoveEFlags( EFL_IS_BEING_LIFTED_BY_BARNACLE )

	// add wearable to global table for removal on death/respawn
	if (player.entindex() in PZI_Util.kill_on_spawn)
		PZI_Util.kill_on_spawn[ player ].append( wearable )
	else
		PZI_Util.kill_on_spawn[ player ] <- wearable

	return wearable
}

//killed on death instead of spawn
function PZI_Util::CreateWearable( player, model, bonemerge = true, attachment = null, auto_destroy = true ) {

	local model_index = GetModelIndex( model )
	if ( model_index == -1 )
		model_index = PrecacheModel( model )

	local wearable = CreateByClassname( "tf_wearable" )
	SetPropInt( wearable, STRING_NETPROP_MODELINDEX, model_index )
	SetTargetname( wearable, format( "__pzi_util_wearable_%d", wearable.entindex() ) )
	wearable.SetSkin( player.GetTeam() )
	wearable.SetTeam( player.GetTeam() )
	wearable.SetSolidFlags( 4 )
	wearable.SetCollisionGroup( 11 )
	SetPropBool( wearable, STRING_NETPROP_ATTACH, true )
	SetPropBool( wearable, STRING_NETPROP_INIT, true )
	SetPropInt( wearable, "m_AttributeManager.m_Item.m_iEntityQuality", 0 )
	SetPropInt( wearable, "m_AttributeManager.m_Item.m_iEntityLevel", 1 )
	SetPropInt( wearable, "m_AttributeManager.m_Item.m_iItemIDLow", 2048 )
	SetPropInt( wearable, "m_AttributeManager.m_Item.m_iItemIDHigh", 0 )

	wearable.SetOwner( player )
	::DispatchSpawn( wearable )
	SetPropBool( wearable, STRING_NETPROP_PURGESTRINGS, true )
	SetPropInt( wearable, "m_fEffects", bonemerge ? EF_BONEMERGE|EF_BONEMERGE_FASTCULL : 0 )
	SetParentLocalOrigin( wearable, player, attachment )

	if ( auto_destroy )
		if (player.entindex() in PZI_Util.kill_on_death)
			PZI_Util.kill_on_death[ player ].append( wearable )
		else
			PZI_Util.kill_on_death[ player ] <- wearable

	return wearable
}

function PZI_Util::StripWeapon( player, slot = -1 ) {

	if ( slot == -1 ) slot = player.GetActiveWeapon().GetSlot()

	for ( local i = 0; i < SLOT_COUNT; i++ ) {

		local weapon = GetItemInSlot( player, i )

		if ( !weapon || weapon.GetSlot() != slot ) continue

		EntFireByHandle( weapon, "Kill", null, -1, null, null )
		break
	}
}

function PZI_Util::DoExplanation( message, print_color = COLOR_YELLOW, message_prefix = "Explanation: ", sync_chat_with_game_text = false, text_print_time = -1, text_scan_time = 0.02 ) {

	local rgb = HexOrIntToRgb( "FFFF66" )

	local txtent = SpawnEntityFromTable( "game_text", {
		effect = 2,
		spawnflags = SF_ENVTEXT_ALLPLAYERS,
		color = format( "%d %d %d", rgb[0], rgb[1], rgb[2] ),
		color2 = "255 254 255",
		fxtime = text_scan_time,
		// holdtime = 5,
		fadeout = 0.01,
		fadein = 0.01,
		channel = 3,
		x = 0.3,
		y = 0.3
	} )

	SetPropBool( txtent, STRING_NETPROP_PURGESTRINGS, true )
	SetTargetname( txtent, format( "__pzi_util_explanation_text%d", txtent.entindex() ) )
	local strarray = []

	//avoid needing to do a ton of function calls for multiple announcements.
	local newlines = split( message, "|" )

	foreach ( n in newlines )
		if ( n.len() ) {
			strarray.append( n )
			if ( !startswith( n, "PAUSE" ) && !sync_chat_with_game_text )
				ClientPrint( null, 3, format( "\x07%s %s\x07%s %s", print_color, message_prefix, TF_COLOR_DEFAULT, n ) )
		}

	local i = -1
	local textcooldown = 0
	function ExplanationTextThink() {

		if ( textcooldown > Time() ) return

		i++
		if ( i == strarray.len() ) {

			SetPropString( txtent, "m_iszMessage", "" )
			txtent.AcceptInput( "Display", "", null, null )

			foreach( i, str in strarray )
				if ( !( i % 2 ) )
					PZI_GameStrings.StringTable[ str ] <- strarray[i+1]

			txtent.Kill()
			return
		}
		local s = strarray[i]

		//make text display slightly longer depending on string length
		local delaybetweendisplays = text_print_time
		if ( delaybetweendisplays == -1 ) {
			delaybetweendisplays = Clamp( s.len() / 10, 2, 12 )
		}

		// allow for pauses in the announcement
		if ( startswith( s, "PAUSE" ) ) {

			local pause = split( s, " " )[1].tofloat()
		//	  DoEntFire( "player", "SetScriptOverlayMaterial", "", -1, player, player )
			SetPropString( txtent, "m_iszMessage", "" )

			SetPropInt( txtent, "m_textParms.holdTime", pause )
			txtent.KeyValueFromInt( "holdtime", pause )

			txtent.AcceptInput( "Display", "", null, null )

			textcooldown = Time() + pause
			return 0.033
		}

		// calculate the game_text x position based on string length
		function calculate_x( str ) {

			local t = 1 - ( str.len().tofloat() / 48 )
			local x = 1 * ( 1 - t )
			x = ( 1 - ( x / 3 ) ) / 2.1
			// x = Clamp( x, 0.28, 0.5 )
			return x
		}

		SetPropFloat( txtent, "m_textParms.x", calculate_x( s ) )
		// txtent.KeyValueFromFloat( "x", calculate_x( s ) )
		SetPropString( txtent, "m_iszMessage", s )
		SetPropInt( txtent, "m_textParms.holdTime", delaybetweendisplays )
		// txtent.KeyValueFromInt( "holdtime", delaybetweendisplays )

		txtent.AcceptInput( "Display", "", null, null )
		if ( sync_chat_with_game_text )
			ClientPrint( null, 3, format( "\x07%s %s\x07%s %s", COLOR_YELLOW, message_prefix, TF_COLOR_DEFAULT, s ) )

		textcooldown = Time() + delaybetweendisplays

		return 0.033
	}

	AddThink( txtent, ExplanationTextThink )
}

function PZI_Util::RemoveAmmo( player, slot = -1 ) {

	if ( slot != -1 )
		return slot < TF_AMMO_COUNT ? SetPropIntArray( player, STRING_NETPROP_AMMO, 0, slot ) : Assert( false, "RemoveAmmo: Invalid slot" )

	local ammo_array = GetPropArraySize( player, STRING_NETPROP_AMMO )

	for ( local i = 0; i < ammo_array; i++ )
		SetPropIntArray( player, STRING_NETPROP_AMMO, 0, i )
}

function PZI_Util::GetAllEnts( count_players = false, callback = null ) {

	local entlist = []

	local start = count_players ? 1 : MAX_CLIENTS

	for ( local i = start, ent; i <= MAX_EDICTS; ent = EntIndexToHScript( i ), i++ )
		if ( ent )
			entlist.append( ent )

	if ( callback != null )
		foreach ( ent in entlist )
			callback( ent )

	return { "entlist": entlist, "numents": entlist.len() }
}

// optimized entity cache iteration for large numbers of static entities
function PZI_Util::ForEachEnt( identifier = null, filter = null, callback = null, findby = "FindByClassname", force_update = true ) {

	local entlist = []

	// no lambda so perf counter prints it
	local function foreachent_filter( i, ent ) { return filter ? filter( ent ) : true }

	if ( !findby || !( findby in ROOT ) )
		findby = "FindByClassname"

	local cache_key = findby.slice( 4 )

	local update_entity_cache = force_update || ( identifier && !( identifier in EntTable[cache_key] ) )

	// check the existing entity cache instead
	if ( !update_entity_cache ) {

		local tbl = identifier ? EntTable[ cache_key ][ identifier ] : EntTable

		foreach ( i, ent in tbl ) {

			if ( identifier || ( typeof ent == "instance" && foreachent_filter( i, ent ) ) ) {

				if ( EntTable[ ent ].cachetime < Time() + 5 )
					ent = EntIndexToHScript( i )

				entlist.append( ent )

				if ( callback ) callback( ent )
			}
		}

		return { "entlist": entlist, "numents": entlist.len() }
	}

	// check using FindByX functions
	if ( identifier ) {

		// special case for players
		if ( identifier == "player" && findby == "FindByClassname" ) {

			if ( PlayerArray.len() )
				entlist.extend( PlayerArray )

			// we should at least have the bots in this list.
			if ( IsMannVsMachineMode() && entlist.len() < GetInt( "tf_mvm_max_invaders" ) )
				for ( local i = 1, player; i <= MAX_CLIENTS; player = PlayerInstanceFromIndex( i ), i++ )
					if ( player )
						entlist.append( player )
		}
		// non-players
		else
			for ( local ent; ent = ROOT[ findby ]( ent, identifier ); )
				entlist.append( ent )
	}

	// get every entity
	else
		for ( local ent = First(); ent; ent = Next( ent ) )
			entlist.append( ent )

	// run callbacks and update entity cache
	foreach ( ent in entlist ) {

		if ( callback )
			callback( ent )

		PZI_Util.EntTable[ent] <- {

			name 	  = ent.GetName()
			model     = ent.GetModelName()
			scope     = ent.GetScriptScope()
			entidx    = ent.entindex()
			classname = ent.GetClassname()
			scriptid  = ent.GetScriptId()
			thinkfunc = ent.GetScriptThinkFunc()
			cachetime = Time()
		}

		local ent_table = clone PZI_Util.EntTable[ ent ]
		foreach ( cachekey, entval in { ByName = "name", ByModel = "model", ByThinkFunc = "thinkfunc", ByClassname = "classname", ByScriptID = "scriptid" } ) {

			local val = ent_table[ entval ]

			if ( val == "" ) continue

			if ( !( val in PZI_Util.EntTable[ cachekey ] ) )
				PZI_Util.EntTable[ cachekey ][ val ] <- {}

			PZI_Util.EntTable[ cachekey ][ val ][ ent ] <- ent_table
		}

		local target = GetPropString( ent, "m_target" )
		if ( target != "" ) {

			if ( !( target in PZI_Util.EntTable.ByTarget ) )
				PZI_Util.EntTable.ByTarget[ target ] <- {}

			PZI_Util.EntTable.ByTarget[ target ][ ent ] <- ent_table
		}

	}
	return { "entlist": entlist, "numents": entlist.len() }
}

function PZI_Util::PointScriptTemplate( targetname = null, onspawn = null ) {

	local template = CreateByClassname( "point_script_template" )
	SetTargetname( template, targetname || template.GetScriptId() )
	SetPropBool( template, STRING_NETPROP_PURGESTRINGS, true )

	local template_scope = GetEntScope( template )
	template_scope.ents <- []

	template_scope.__EntityMakerResult <- { entities = template_scope.ents }.setdelegate( {

		function _newslot( _, value ) {

			entities.append( value )
		}
	} )

	if ( onspawn )
		template_scope.PostSpawn <- onspawn.bindenv( template_scope )

	return template
}

function PZI_Util::AttachParticle( ent, particle, attachment_name ) {

	SetPropString( TriggerParticle, "m_iszParticleName", particle )
	SetPropString( TriggerParticle, "m_iszAttachmentName", attachment_name )
	TriggerParticle.AcceptInput( "StartTouch", null, ent, ent )
}

//sets m_hOwnerEntity and m_hOwner to the same value
function PZI_Util::_SetOwner( ent, owner ) {

	//incase we run into an ent that for some reason uses both of these netprops for two different entities
	if ( ent.GetOwner() && GetPropEntity( ent, "m_hOwner" ) && ent.GetOwner() != GetPropEntity( ent, "m_hOwner" ) )
		error( format( "m_hOwner is %s but m_hOwnerEntity is %s\n", GetPropEntity( ent, "m_hOwner" ), ent.GetOwner() ) )

	ent.SetOwner( owner )
	SetPropEntity( ent, "m_hOwner", owner )
}

/**
	* Displays a training annotation.
	*
	* @param table args        Annotation settings.
	*
	* Example usage:
	*  PZI_Util.ShowAnnotation( {
	*      text = `Defend the hatch!`
	*      entity = FindByModel( null, `models/props_mvm/mann_hatch.mdl` )
	*      //pos = Vector( -64.0, -1984.0, 446.5 )
	*      lifetime = 5.0
	*      distance = true
	*      sound = `ui/hint.wav`
	*      players = [GetListenServerHost()]
	*  } )
	*
	* ALL AVAILABLE ARGUMENTS:
	*  text    ( string ): Annotation message to display.
	*    Defaults to "This is an annotation."
	*
	*  lifetime ( float ): Duration to display the annotation for in seconds.
	*    Defaults to 10 seconds.
	*    Pass -1.0 to make the annotation fade in and display forever.
	*
	*  sound   ( string ): Sound to play when the annotation is shown.
	*    Must be a raw sound, SoundScripts will not work.
	*    Defaults to no sound.
	*
	*  distance  ( bool ): Display the distance between the player and the annotation.
	*    Defaults to false.
	*
	*  id     ( integer ): Annotation ID.
	*    Annotations must have a unique ID to display multiple simultaneously.
	*    Defaults to 0.
	*
	*  entity  ( handle ): Entity this annotation should follow. ( Default: None )
	*    Overrides "pos" and "normal" arguments.
	*    Note that the entity must be networked to the client for this argument to work.a
	*
	*  pos     ( Vector ): Annotation position in the world.
	*    Defaults to the world origin ( Vector( 0, 0, 0 ) ).
	*
	*  ping      ( bool ): Display a green in-world ping under the annotation as it appears.
	*    Defaults to false.
	*
	*  normal  ( Vector ): Relative ping effect offset from the animation.
	*    Requires "ping" to be set to true.
	*    Defaults to no offset.
	*
	*  players  ( array ): Players handles that are allowed to see the annotation.
	*    Overrides "visbit" argument.
	*    Defaults visibility to all players when left empty.
	*
	*  visbit ( integer ): Bitfield that controls which players can see the annotation.
	*    Can be used for manual bitfield input instead of using the "players" array.
	*    Defaults visibility to all players.
	*    Note that it is only possible to filter annotations to the first 32/64 players depending on the server's _intsize_.
	*      TODO: This is untested; it may be the case that only the first 32 players may be targeted even on a 64-bit server.
	**/
function PZI_Util::ShowAnnotation( args = {} ) {

	if ( !( "pos" in args ) )
		args.pos <- Vector()

	if ( !( "normal" in args ) )
		args.normal <- Vector()
	else
		// Normal offset is normally 20x the input value, so we correct it here.
		args.normal *= 0.05

	if ( "players" in args && args.players.len() ) {
		// Create visibility bitfield from passed player handles.
		args.visbit <- 0

		foreach ( p in args.players )
			if ( p && p.IsValid() )
				args.visbit = args.visbit | ( 1 << p.entindex() )

		// visibilityBitfield == 0 causes the annotation to show to everyone, we override that
		//  here otherwise "players = [<nullptr>]" would show to everyone.
		if ( !args.visbit ) return
	}

	// "entindex" and "effect" arguments are only supported for legacy compatiability.
	if ( "entity" in args ) args.entindex <- args.entity.entindex()
	if ( "ping" in args ) args.effect <- args.ping

	SendGlobalGameEvent( "show_annotation", {
		text 			   = "text" in args ? args.text : "This is an annotation."
		lifetime 		   = "lifetime" in args ? args.lifetime : 10.0
		worldPosX 		   = args.pos.x
		worldPosY 		   = args.pos.y
		worldPosZ 		   = args.pos.z
		id 				   = "id" in args ? args.id : 0
		play_sound 		   = "sound" in args ? args.sound : "misc/null.wav"
		show_distance 	   = "distance" in args ? args.distance : false
		show_effect 	   = "effect" in args ? args.effect : false
		follow_entindex    = "entindex" in args ? args.entindex : 0
		visibilityBitfield = "visbit" in args ? args.visbit : 0
		worldNormalX 	   = args.normal.x
		worldNormalY 	   = args.normal.y
		worldNormalZ 	   = args.normal.z
	} )
}

function PZI_Util::TrainingHUD( title, text, duration = 5.0 ) {

	EntFire( "func_upgradestation", "Disable" )

	local tutorial_text = CreateByClassname( "tf_logic_training_mode" )

	SetPropBool( GameRules, "m_bIsInTraining", true )
	SetPropBool( GameRules, "m_bAllowTrainingAchievements", true )

	tutorial_text.AcceptInput( "ShowTrainingHUD","", null, null )
	tutorial_text.AcceptInput( "ShowTrainingObjective", title, null, null )
	tutorial_text.AcceptInput( "ShowTrainingMsg", text, null, null )
	tutorial_text.Kill()

	SetValue( "hide_server", 0 )

	ScriptEntFireSafe( GameRules, "SetPropBool( self, `m_bIsInTraining`, false )", duration )

	EntFire( "func_upgradestation", "Enable", "", duration )
}

function PZI_Util::PressButton( player, button, duration = -1 ) {

	SetPropInt( player, "m_afButtonForced", GetPropInt( player, "m_afButtonForced" ) | button )
	SetPropInt( player, "m_nButtons", GetPropInt( player, "m_nButtons" ) | button )

	if ( duration != -1 )
		ScriptEntFireSafe( player, format( "PZI_Util.ReleaseButton( self, %d )", button ), duration )
}

function PZI_Util::ReleaseButton( player, button ) {

	SetPropInt( player, "m_afButtonForced", GetPropInt( player, "m_afButtonForced" ) & ~button )
	SetPropInt( player, "m_nButtons", GetPropInt( player, "m_nButtons" ) & ~button )
}

function PZI_Util::IsPointInTrigger( point, classname = "func_respawnroom" ) {

	local triggers = []
	for ( local trigger; trigger = FindByClassname( trigger, classname ); ) {

		if ( classname == "func_respawnroom" )
			trigger.SetCollisionGroup( COLLISION_GROUP_NONE )

		trigger.RemoveSolidFlags( FSOLID_NOT_SOLID )
		triggers.append( trigger )
	}

	local trace = {

		start = point
		end   = point
		mask  = 0
	}

	TraceLineEx( trace )

	foreach ( trigger in triggers ) {

		if ( classname == "func_respawnroom" )
			trigger.SetCollisionGroup( TFCOLLISION_GROUP_RESPAWNROOMS )

		trigger.AddSolidFlags( FSOLID_NOT_SOLID )
	}

	if ( trace.hit )
		if ( trace.enthit.GetClassname() == classname )
			return true

	return false
}

function PZI_Util::GetItemInSlot( player, slot ) {

	local item
	for ( local child = player.FirstMoveChild(); child && child instanceof CBaseCombatWeapon; child = child.NextMovePeer() ) {

		if ( child.GetSlot() != slot ) continue

		item = child
		break
	}
	return item
}

function PZI_Util::SwitchToFirstValidWeapon( player ) {

	for ( local i = 0; i < SLOT_COUNT; i++ ) {
		local wep = GetPropEntityArray( player, STRING_NETPROP_MYWEAPONS, i )
		if ( !wep ) continue

		player.Weapon_Switch( wep )
		return wep
	}
}

function PZI_Util::PlayerBonemergeModel( player, model ) {

	local scope = player.GetScriptScope()

	if ( "bonemerge_model" in scope && scope.bonemerge_model && scope.bonemerge_model.IsValid() )
		scope.bonemerge_model.Kill()

	local bonemerge_model = CreateByClassname( "tf_wearable" )
	SetTargetname( bonemerge_model, "__pzi_util_bonemerge_model" + player.entindex() )
	SetPropInt( bonemerge_model, STRING_NETPROP_MODELINDEX, PrecacheModel( model ) )
	SetPropBool( bonemerge_model, STRING_NETPROP_ATTACH, true )
	SetPropEntity( bonemerge_model, "m_hOwner", player )
	bonemerge_model.SetTeam( player.GetTeam() )
	bonemerge_model.SetOwner( player )
	::DispatchSpawn( bonemerge_model )
	SetPropBool( bonemerge_model, STRING_NETPROP_PURGESTRINGS, true )
	EntFireByHandle( bonemerge_model, "SetParent", "!activator", -1, player, player )
	SetPropInt( bonemerge_model, "m_fEffects", EF_BONEMERGE|EF_BONEMERGE_FASTCULL )
	scope.bonemerge_model <- bonemerge_model

	SetPropInt( player, "m_nRenderMode", kRenderTransColor )
	SetPropInt( player, "m_clrRender", 0 )

	function BonemergeModelThink() {

		if ( bonemerge_model.IsValid() && ( player.IsTaunting() || bonemerge_model.GetMoveParent() != player ) )
			bonemerge_model.AcceptInput( "SetParent", "!activator", player, player )
		return -1
	}
}

function PZI_Util::PlayerSequence( player, sequence, model_override = "", playbackrate = 1.0, freeze_player = false, thirdperson = false ) {

	SetPropInt( player, "m_nRenderMode", kRenderTransColor )
	SetPropInt( player, "m_clrRender", 0 )
	local scope = player.GetScriptScope()

	local has_bonemerge_model = "bonemerge_model" in scope && scope.bonemerge_model && scope.bonemerge_model.IsValid()

	local dummy = CreateByClassname( "funCBaseFlex" )
	SetTargetname( dummy, format( "__pzi_util_sequence_dummy%d", player.entindex() ) )

	// SetModelSimple is more expensive but handles precaching and refreshes bone cache automatically
	if ( model_override != "" )
		dummy.SetModelSimple( model_override )
	else
		dummy.SetModel( has_bonemerge_model ? scope.bonemerge_model.GetModelName() : player.GetModelName() )

	dummy.SetAbsOrigin( player.GetOrigin() )
	dummy.SetSkin( player.GetSkin() )
	dummy.SetAbsAngles( QAngle( 0, player.EyeAngles().y, 0 ) )

	::DispatchSpawn( dummy )
	dummy.AcceptInput( "SetParent", "!activator", player, player )

	dummy.ResetSequence( typeof sequence == "string" ? dummy.LookupSequence( sequence ) : sequence )
	dummy.SetPlaybackRate( playbackrate )

	function PlaySequenceThink() {

		// kv origin/angles are smoothly interpolated, SetOrigin/SetAngles may look choppy in comparison
		dummy.KeyValueFromVector( "origin", player.GetOrigin() )
		dummy.KeyValueFromString( "angles", player.GetAbsAngles().ToKVString() )

		if ( GetPropFloat( dummy, "m_flCycle" ) >= 0.99 ) {

			SetPropInt( player, "m_clrRender", 0xFFFFFFFF )
			if ( freeze_player ) LockInPlace( player, false )
			if ( thirdperson ) player.AcceptInput( "SetForcedTauntCam", "0", null, null )
			if ( dummy.IsValid() ) dummy.Kill()
			return // no -1 think to avoid null instance errors
		}
		dummy.StudioFrameAdvance()
		return -1
	}
	AddThink( dummy, PlaySequenceThink )

	if ( freeze_player ) LockInPlace( player )
	if ( thirdperson ) player.AcceptInput( "SetForcedTauntCam", "1", null, null )

}

function PZI_Util::HasItemInLoadout( player, index ) {

	local t = null

	for ( local child = player.FirstMoveChild(); child; child = child.NextMovePeer() ) {
		if (
			child == index
			|| child.GetClassname() == index
			|| ( index != -1 && GetItemIndex( child ) == index )
			|| ( index in PZI_ItemMap && GetItemIndex( child ) == PZI_ItemMap[index].id )
		) {
			t = child
			break
		}
	}

	if ( t != null ) return t

	//didn't find weapon in children, go through m_hMyWeapons instead
	for ( local i = 0; i < SLOT_COUNT; i++ ) {

		local wep = GetPropEntityArray( player, STRING_NETPROP_MYWEAPONS, i )

		if ( !wep || !wep.IsValid() ) continue

		if (
			wep == index
			|| wep.GetClassname() == index
			|| GetItemIndex( wep ) == index
			|| ( index in PZI_ItemMap && GetItemIndex( wep ) == PZI_ItemMap[index].id )
		) {
			t = wep
			break
		}
	}
	if ( t != null ) return t

	// check for custom weapons
	// only accepts weapon handle or weapon string name
	local scope = player.GetScriptScope()
	if ( "CustomWeapons" in scope ) {
		foreach ( wep, v in scope.CustomWeapons ) {

			if ( wep == "worldmodel" ) continue

			if ( wep == index || v.name == index ) {

				t = wep
				break
			}
		}
	}
	return t
}

// This was made before StunPlayer was exposed, however StunPlayer doesn't control m_bStunEffects like this does.
function PZI_Util::StunPlayer( player, duration = 5, type = 1, delay = 0, speedreduce = 0.5, scared = false ) {

	local utilstun = CreateByClassname( "trigger_stun" )

	SetTargetname( utilstun, "__pzi_util_stun" )
	utilstun.KeyValueFromInt( "stun_type", type )
	utilstun.KeyValueFromInt( "stun_effects", scared.tointeger() )
	utilstun.KeyValueFromFloat( "stun_duration", duration.tofloat() )
	utilstun.KeyValueFromFloat( "move_speed_reduction", speedreduce.tofloat() )
	utilstun.KeyValueFromFloat( "trigger_delay", delay.tofloat() )
	utilstun.KeyValueFromInt( "spawnflags", SF_TRIGGER_ALLOW_CLIENTS )

	::DispatchSpawn( utilstun )

	utilstun.AcceptInput( "EndTouch", "", player, player )
	utilstun.Kill()
}

function PZI_Util::Ignite( player, duration = 10.0, damage = 1 ) {

	local utilignite = FindByName( null, "__pzi_util_ignite" ) || SpawnEntityFromTable( "trigger_ignite", {
			targetname = "__pzi_util_ignite"
			burn_duration = duration
			damage = damage
			spawnflags = SF_TRIGGER_ALLOW_CLIENTS
		} )
	EntFireByHandle( utilignite, "StartTouch", null, -1, player, player )
	EntFireByHandle( utilignite, "EndTouch", null, SINGLE_TICK, player, player )
}

function PZI_Util::ShowHudHint( text = "This is a hud hint", player = null, duration = 5.0 ) {

	local hudhint = FindByName( null, "__pzi_util_hudhint" ) || SpawnEntityFromTable( "env_hudhint", {
		targetname = "__pzi_util_hudhint"
		spawnflags = !player ? 1 : 0
		message = text
	} )
	SetPropBool( hudhint, STRING_NETPROP_PURGESTRINGS, true )
	hudhint.KeyValueFromString( "message", text )

	hudhint.AcceptInput( "ShowHudHint", null, player, player )
	EntFireByHandle( hudhint, "HideHudHint", null, duration, player, player )

	PZI_GameStrings.PurgeGameString( "env_hudhint" )
}

function PZI_Util::SetEntityColor( entity, r, g, b, a ) {

	local color = ( r ) | ( g << 8 ) | ( b << 16 ) | ( a << 24 )
	SetPropInt( entity, "m_clrRender", color )
}

function PZI_Util::GetEntityColor( entity ) {

	local color = GetPropInt( entity, "m_clrRender" )
	local clr = {}
	clr.r <- color & 0xFF
	clr.g <- ( color >> 8 ) & 0xFF
	clr.b <- ( color >> 16 ) & 0xFF
	clr.a <- ( color >> 24 ) & 0xFF
	return clr
}

function PZI_Util::AddAttributeToLoadout( player, attribute, value, duration = -1 ) {

	ForEachItem( player, function( item ) {

		item.AddAttribute( attribute, value, duration )
		item.ReapplyProvision()
	} )
}

function PZI_Util::ShowModelToPlayer( player, model = ["models/player/heavy.mdl", 0], pos = Vector(), ang = QAngle(), duration = INT_MAX, bodygroup = null ) {

	PrecacheModel( model[0] )
	local proxy_entity = CreateByClassname( "obj_teleporter" ) // use obj_teleporter to set bodygroups.  not using SpawnEntityFromTable as that creates spawning noises
	proxy_entity.SetAbsOrigin( pos )
	proxy_entity.SetAbsAngles( ang )
	::DispatchSpawn( proxy_entity )

	proxy_entity.SetModel( model[0] )
	proxy_entity.SetSkin( model[1] )
	proxy_entity.AddEFlags( EFL_NO_THINK_FUNCTION ) // EFL_NO_THINK_function prevents the entity from disappearing
	proxy_entity.SetSolid( SOLID_NONE )

	SetPropBool( proxy_entity, "m_bPlacing", true )
	SetPropInt( proxy_entity, "m_fObjectFlags", OF_MUST_BE_BUILT_ON_ATTACHMENT ) // sets "attachment" flag, prevents entity being snapped to player feet

	// m_hBuilder is the player who the entity will be networked to only
	SetPropEntity( proxy_entity, "m_hBuilder", player )
	EntFireByHandle( proxy_entity, "Kill", null, duration, player, player )
	return proxy_entity
}

function PZI_Util::LockInPlace( player, enable = true ) {

	if ( enable ) {
		player.AddFlag( FL_ATCONTROLS )
		player.AddCustomAttribute( "no_jump", 1, -1 )
		player.AddCustomAttribute( "no_duck", 1, -1 )
		player.AddCustomAttribute( "no_attack", 1, -1 )
		player.AddCustomAttribute( "disable weapon switch", 1, -1 )
		return

	}

	player.RemoveFlag( FL_ATCONTROLS )
	player.RemoveCustomAttribute( "no_jump" )
	player.RemoveCustomAttribute( "no_duck" )
	player.RemoveCustomAttribute( "no_attack" )
	player.RemoveCustomAttribute( "disable weapon switch" )
}

function PZI_Util::InitEconItem( item, index ) {

	SetPropInt( item, STRING_NETPROP_ITEMDEF, index )
	SetPropBool( item, STRING_NETPROP_INIT, true )
	SetPropBool( item, STRING_NETPROP_ATTACH, true )
}

function PZI_Util::RemoveOutputAll( ent, output ) {
	local outputs = []

	for ( local i = GetNumElements( ent, output ); i >= 0; i-- ) {

		local t = {}
		GetOutputTable( ent, output, t, i )
		outputs.append( t )
	}

	foreach ( o in outputs )
		foreach( _ in o )
			RemoveOutput( ent, output, o.target, o.input, o.parameter )
}

function PZI_Util::GetAllOutputs( ent, output ) {
	local outputs = []
	for ( local i = GetNumElements( ent, output ); i >= 0; i-- ) {
		local t = {}
		GetOutputTable( ent, output, t, i )
		outputs.append( t )
	}
	return outputs
}

function PZI_Util::GetPropAny( ent, prop, i = 0 ) {

	local type = GetPropType( ent, prop )

	if ( type == "instance" )
		return GetPropEntityArray( ent, prop, i )
	else if ( type == "integer" )
		return GetPropIntArray( ent, prop, i )
	else {

		local funcname = format( "GetProp%sArray", type.slice( 0, 1 ).toupper() + type.slice( 1 ) )
		return ROOT[funcname]( ent, prop, i )
	}
}

function PZI_Util::SetPropAny( ent, prop, value, i = 0 ) {

	local type = GetPropType( ent, prop )

	if ( type == "instance" )
		SetPropEntityArray( ent, prop, value, i )
	else if ( type == "integer" )
		SetPropIntArray( ent, prop, value, i )

	else {

		local converted = type == "bool" ? value.tointeger() : value[format( "to%s", type )]()

		local funcname = format( "SetProp%sArray", type.slice( 0, 1 ).toupper() + type.slice( 1 ) )
		ROOT[funcname]( ent, prop, value, i )
	}

	SetPropBool( ent, STRING_NETPROP_PURGESTRINGS, true )
}

function PZI_Util::RemovePlayerWearables( player ) {

	for ( local wearable = player.FirstMoveChild();  wearable; wearable = wearable.NextMovePeer() ) {

		if ( wearable instanceof CBaseCombatWeapon || !( wearable instanceof CEconEntity ) )
			continue

		SetPropBool( wearable, STRING_NETPROP_PURGESTRINGS, true )
		EntFireByHandle( wearable, "Kill", null, -1, null, null )
	}
	return
}

function PZI_Util::GiveWeapon( player, class_name, item_id ) {

	if ( typeof item_id == "string" && class_name == "tf_wearable" ) {

		CTFBot.GenerateAndWearItem.call( player, item_id )
		return
	}
	local weapon = CreateByClassname( class_name )
	InitEconItem( weapon, item_id )
	weapon.SetTeam( player.GetTeam() )
	::DispatchSpawn( weapon )
	SetPropBool( weapon, STRING_NETPROP_PURGESTRINGS, true )

	// remove existing weapon in same slot
	ForEachItem( player, function( child ) {

		if ( child.GetSlot() != weapon.GetSlot() )
			return

		SetPropBool( child, STRING_NETPROP_PURGESTRINGS, true )
		EntFireByHandle( child, "Kill", null, -1, null, null )
		// SetPropEntityArray( player, STRING_NETPROP_MYWEAPONS, null, slot )
	}, true )

	player.Weapon_Equip( weapon )
	player.Weapon_Switch( weapon )

	return weapon
}

function PZI_Util::IsEntityClassnameInList( entity, list ) {

	local classname = entity.GetClassname()
	local list_type = typeof list

	switch ( list_type ) {
		case "table":
			return ( classname in list )

		case "array":
			return ( list.find( classname ) != null )

		default:
			return false
	}
}

function PZI_Util::SetPlayerClassRespawnAndTeleport( player, playerclass, location_set = null ) {
	local teleport_origin, teleport_angles, teleport_velocity

	if ( !location_set )
		teleport_origin = player.GetOrigin()
	else
		teleport_origin = location_set
	teleport_angles = player.EyeAngles()
	teleport_velocity = player.GetAbsVelocity()
	SetPropInt( player, "m_Shared.m_iDesiredPlayerClass", playerclass )

	player.ForceRegenerateAndRespawn()

	player.Teleport( true, teleport_origin, true, teleport_angles, true, teleport_velocity )
}

function PZI_Util::PlaySoundOnClient( player, name, volume = 1.0, pitch = 100 ) {
	EmitSoundEx( {
		sound_name = name,
		volume = volume
		pitch = pitch,
		entity = player,
		filter_type = RECIPIENT_FILTER_SINGLE_PLAYER
	} )
}

function PZI_Util::PlaySoundOnAllClients( name ) {
	EmitSoundEx( {
		sound_name = name,
		filter_type = RECIPIENT_FILTER_GLOBAL
	} )
}

function PZI_Util::StopAndPlayMVMSound( player, soundscript, delay ) {

	local scope = player.GetScriptScope()
	scope.sound <- soundscript

	ScriptEntFireSafe( player, "self.StopSound( sound );", delay )

	local sound	   =  scope.sound
	local dotindex =  sound.find( "." )
	if ( dotindex == null ) return

	scope.mvmsound <- sound.slice( 0, dotindex+1 ) + "MVM_" + sound.slice( dotindex+1 )

	ScriptEntFireSafe( player, "self.EmitSound( mvmsound );", delay + SINGLE_TICK )
}

function PZI_Util::StringReplace( str, findwhat, replace ) {

	local returnstring = ""
	local findwhatlen  = findwhat.len()
	local splitlist	   = []

	local start = 0
	local previndex = 0
	while ( start < str.len() ) {
		local index = str.find( findwhat, start )
		if ( index == null ) {
			if ( start < str.len() - 1 )
				splitlist.append( str.slice( start ) )
			break
		}

		splitlist.append( str.slice( previndex, index ) )

		start = index + findwhatlen
		previndex = start
	}

	foreach ( index, s in splitlist ) {
		if ( index < splitlist.len() - 1 )
			returnstring += s + replace
		else
			returnstring += s
	}

	return returnstring
}

// Python's string.capwords()
function PZI_Util::CapWords( s, sep = null ) {

	if ( sep == null ) sep = " "
	local words = []
	local start = 0
	local end = s.find( sep )
	while ( end != null ) {
		words.push( s.slice( start, end ) )
		start = end + sep.len()
		end = s.find( sep, start )
	}
	words.push( s.slice( start ) )

	local result = []
	foreach ( word in words ) {
		local first_char = word.slice( 0, 1 ).toupper()
		local rest_of_word = word.slice( 1 )
		result.push( first_char + rest_of_word )
	}

	local final_result = ""
	foreach ( i, word in result ) {
		if ( i > 0 ) final_result += sep
		final_result += word
	}
	return final_result
}

// backwards compatibility
PZI_Util.capwords <- PZI_Util.CapWords

// Python's string.partition(), except the separator itself is not returned
// Basically like calling python's string.split( sep, 1 ), notice the 1 meaning to only split once
function PZI_Util::SplitOnce( s, sep = null ) {

	if ( sep == null ) return [s, null]

	local pos = s.find( sep )
	local result_left = pos == 0 ? null : s.slice( 0, pos )
	local result_right = pos == s.len() - 1 ? null : s.slice( pos + 1 )

	return [result_left, result_right]
}

function PZI_Util::SilentDisguise( player, target = null, tfteam = TF_TEAM_PVE_INVADERS, tfclass = TF_CLASS_SCOUT ) {

	if ( !player || !player.IsPlayer() ) return

	function FindTargetPlayer( passcond ) {

		local target
		foreach( potentialtarget in HumanArray ) {

			if ( potentialtarget == player || !passcond( potentialtarget ) ) continue

			target = potentialtarget
			break
		}
		return target
	}

	if ( !target ) {
		// Find disguise target
		target = FindTargetPlayer( @( p ) p.GetTeam() == tfteam && p.GetPlayerClass() == tfclass )
		// Couldn't find any targets of tfclass, look for any class this time
		if ( !target )
			target = FindTargetPlayer( @( p ) p.GetTeam() == tfteam )
	}

	// Disguise as this player
	if ( target ) {
		SetPropInt( player, "m_Shared.m_nDisguiseTeam", target.GetTeam() )
		SetPropInt( player, "m_Shared.m_nDisguiseClass", target.GetPlayerClass() )
		SetPropInt( player, "m_Shared.m_iDisguiseHealth", target.GetHealth() )
		SetPropEntity( player, "m_Shared.m_hDisguiseTarget", target )
		// When we drop our disguise, the player we disguised as gets this weapon removed for some reason
		//SetPropEntity( player, "m_Shared.m_hDisguiseWeapon", target.GetActiveWeapon() )
	}
	// No valid targets, just give us a generic disguise
	else {
		SetPropInt( player, "m_Shared.m_nDisguiseTeam", tfteam )
		SetPropInt( player, "m_Shared.m_nDisguiseClass", tfclass )
	}

	player.AddCond( TF_COND_DISGUISED )

	// Hack to get our movespeed set correctly for our disguise
	player.AddCond( TF_COND_SPEED_BOOST )
	player.RemoveCond( TF_COND_SPEED_BOOST )
}

function PZI_Util::GetPlayerReadyCount() {
	local roundtime = GetPropFloat( GameRules, "m_flRestartRoundTime" )
	if ( IsInSetup ) return 0
	local ready = 0

	for ( local i = 0; i < GetPropArraySize( GameRules, "m_bPlayerReady" ); i++ ) {
		if ( !GetPropBoolArray( GameRules, "m_bPlayerReady", i ) ) continue
		ready++
	}

	return ready
}

function PZI_Util::RoundWin( team = 2 ) {

	local round_win = SpawnEntityFromTable( "game_round_win", {

		force_map_reset = true
		TeamNum         = team
		switch_teams    = false
	} )

    SetValue( "mp_humans_must_join_team", "red" )
	round_win.AcceptInput( "RoundWin", null, null, null )

	EntFireByHandle( round_win, "Kill", null, 3.0, null, null )
}

function PZI_Util::GetWeaponMaxAmmo( player, wep ) {

	if ( !wep ) return

	local slot      = wep.GetSlot()
	local classname = wep.GetClassname()
	local itemid    = GetItemIndex( wep )

	local table = MaxAmmoTable[player.GetPlayerClass()]

	if ( !( itemid in table ) && !( classname in table ) )
		return -1

	local base_max = ( itemid in table ) ? table[itemid] : table[classname]

	/*
	local mod = 1.0

	local incr
	local decr
	local hid
	if ( slot == SLOT_PRIMARY ) {
		incr = wep.GetAttribute( "maxammo primary increased", 1.0 )
		decr = wep.GetAttribute( "maxammo primary reduced", 1.0 )
		hid  = wep.GetAttribute( "hidden primary max ammo bonus", 1.0 )
	}
	else if ( slot == SLOT_SECONDARY ) {
		incr = wep.GetAttribute( "maxammo secondary increased", 1.0 )
		decr = wep.GetAttribute( "maxammo secondary reduced", 1.0 )
		hid  = wep.GetAttribute( "hidden secondary max ammo penalty", 1.0 )
	}

	mod *= incr * decr * hid
	return base_max * mod
	*/

	return base_max
}

function PZI_Util::TeleportNearVictim( ent, victim, attempt, ignore_visibility = false ) {

	if ( !victim || !victim.GetLastKnownArea() )
		return

	local max_surround_travel_range = 6000.0

	local surround_travel_range = 1500.0 + 500.0 * attempt
	// surround_travel_range = Max( surround_travel_range, max_surround_travel_range )

	local areas = {}
	GetNavAreasInRadius( victim.GetOrigin(), surround_travel_range, areas )

	local ambush_areas = areas.filter( @( name, area ) name in PZI_Util.SafeNavAreas && ( ignore_visibility || !area.IsPotentiallyVisibleToTeam( victim.GetTeam() ) ) ).values()

	if ( !ambush_areas.len() )
		return false

	local max_tries = Min( 10, ambush_areas.len() )

	for ( local retry = 0; retry < max_tries; retry++ ) {

		local which = RandomInt( 0, ambush_areas.len() - 1 )
		local where = ambush_areas[which].GetCenter() + Vector( 0, 0, STEP_HEIGHT )

		if ( IsSpaceToSpawnHere( where, ent.GetBoundingMins(), ent.GetBoundingMaxs() ) ) {
			ent.SetAbsOrigin( where )
			return true
		}
	}

	return false
}

function PZI_Util::IsSpaceToSpawnHere( where, hullmin, hullmax ) {

	local trace = {
		start = where,
		end = where,
		hullmin = hullmin,
		hullmax = hullmax,
		mask = MASK_PLAYERSOLID
	}
	TraceHull( trace )

	return trace.fraction >= 1.0
}

function PZI_Util::ClearLastKnownArea( bot ) {

	local trigger = SpawnEntityFromTable( "trigger_remove_tf_player_condition", {
		spawnflags = SF_TRIGGER_ALLOW_CLIENTS,
		condition = TF_COND_TMPDAMAGEBONUS,
	})
	EntFireByHandle( trigger, "StartTouch", "!activator", -1, bot, bot )
	EntFireByHandle( trigger, "Kill", "", -1, null, null )
}

function PZI_Util::KillPlayer( player ) {
	player.TakeDamage( INT_MAX, 0, TriggerHurt )
}

function PZI_Util::KillAllBots() {
	foreach ( bot in BotArray )
		if ( bot.IsAlive() )
			KillPlayer( bot )
}

// EntFire wrapper for:
// - Purging game strings to avoid CUtlRBTree Overflow crashes
// - Logging for invalid targets when debug mode is enabled
// - Handling dead players without putting isalive checks everywhere
function PZI_Util::ScriptEntFireSafe( target, code, delay = -1, activator = null, caller = null, allow_dead = false ) {

	local entfirefunc = typeof target == "string" ? DoEntFire : EntFireByHandle

	entfirefunc( target, "RunScriptCode", format( @"

		if ( self && self.IsValid() ) {

			SetPropBool( self, STRING_NETPROP_PURGESTRINGS, true )

			if ( self.IsPlayer() && !self.IsAlive() && !%d ) {

				// PZI_Ext.Error.DebugLog( `Ignoring dead player in ScriptEntFireSafe: ` + self )
				return
			}

			// code passed to ScriptEntFireSafe
			%s

			return
		}

		// PZI_Ext.Error.DebugLog( `Invalid target passed to ScriptEntFireSafe: ` + self )

	", allow_dead.tointeger(), code ), delay, activator, caller )

	PZI_GameStrings.StringTable[code] <- null
}

function PZI_Util::SetDestroyCallback( entity, callback ) {

	local scope = GetEntScope( entity )

	if ( "__pzi_util_destroy_callback" in scope )
		return

	scope.__pzi_util_destroy_callback <- callback.bindenv( scope )

	scope.setdelegate( {}.setdelegate( {

			parent   = scope.getdelegate()
			id       = entity.GetScriptId()
			index    = entity.entindex()

			function _get( k ) {

				return parent[k]
			}

			function _delslot( k ) {

				if ( k == id ) {

					entity = EntIndexToHScript( index )
					local scope = entity.GetScriptScope()
					scope.self <- entity
					PZI_GameStrings.PurgeGameString( id )
					scope.__pzi_util_destroy_callback()
				}

				delete parent[k]
			}
		} )
	)
}

function PZI_Util::OnWeaponFire( wep, func ) {

	if ( !wep ) return

	local scope = GetEntScope( wep )

	scope.last_fire_time <- 0.0

	function OnWeaponFireThink() {

		local fire_time = GetPropFloat( self, "m_flLastFireTime" )
		if ( fire_time > last_fire_time ) {
			func.call( scope )
			last_fire_time = fire_time
		}
		return
	}
	AddThink( wep, OnWeaponFireThink )
}

function PZI_Util::ForEachItem( player, func, weapons_only = false ) {

	for ( local child = player.FirstMoveChild(); ( child && child instanceof CEconEntity ); child = child.NextMovePeer() ) {

		if ( weapons_only && !( child instanceof CBaseCombatWeapon ) )
			continue

		func( child )
	}
}

function PZI_Util::IsProjectileWeapon( wep ) {

	local wep_classname = wep.GetClassname()
	local override_projectile = wep.GetAttribute( "override projectile type", 0.0 )

	return ( wep_classname in PROJECTILE_WEAPONS && override_projectile != 1 ) || override_projectile > 1
}

function PZI_Util::GetLastFiredProjectile( player ) {

	local active_projectiles = GetEntScope( player ).PRESERVED.active_projectiles
	local projectiles = []

	foreach ( projectile, info in active_projectiles )
		projectiles.append( info )

	projectiles.sort( @( a, b ) a[1] <=> b[1] )

	local projectiles_len = projectiles.len()
	return projectiles_len ? projectiles[ projectiles_len - 1 ][ 0 ] : null

}

function PZI_Util::ChangeLevel( mapname = "", delay = 1.0, mvm_cyclemissionfile = false ) {

	if ( mapname != "" ) {

		// listen servers can just do this
		if ( !IsDedicatedServer() )
			SendToConsole( format( "nextlevel %s", mapname ) )

		// check for allow point_servercommand
		else if ( GetStr( "sv_allow_point_servercommand" ) == "always" )
			SendToServerConsole( format( "nextlevel %s", mapname ) )

		// check the allowlist
		else if ( IsConVarOnAllowList( "nextlevel" ) )
			SetValue( "nextlevel", mapname )

		// can't set it, just load the next map in the mapcycle file or hope the server sets nextlevel for us
		else
			printl( "PZI_Util.ChangeLevel: cannot set nextlevel! loading next map instead..." )
	}

	// required for GoToIntermission
	SetValue( "mp_tournament", 0 )

	// wait at scoreboard for this many seconds
	SetValue( "mp_chattime", delay )

	local intermission = CreateByClassname( "point_intermission" )

	// for mvm, otherwise it'll ignore delay and switch to the next map in the missioncycle file
	if ( !mvm_cyclemissionfile )
		EntFire( "info_populator", "Kill" )

	// don't use acceptinput so we execute after info_populator kill
	EntFireByHandle( intermission, "Activate", "", -1, null, null )
}

function PZI_Util::ToStrictNum( str, float = false ) {

	if ( typeof str == "string" ) {

		str = strip( str )
		local rex = regexp( @"-?[0-9]+( \.[0-9]+ )?" )
		if ( !rex.match( str ) ) return
	}

	try
		return float ? str.tofloat() : str.tointeger()
	catch ( _ )
		return
}

function PZI_Util::AddThink( ent, func ) {

	local thinktable_name = null
	local thinktable_func = null

	if ( !ent || !ent.IsValid() )
		return

	foreach ( k, v in PZI_Util.ThinkTableSetup ) {

		if ( typeof v != "array" )
			continue

		if ( startswith( ent.GetClassname(), k ) ) {

			thinktable_name = 0 in v ? v[0] : "ThinkTable"
			thinktable_func = 1 in v ? v[1] : format( "%s_Think", ent.GetName() )

			// if ( thinktable_name == "PlayerThinkTable" ) {

			// 	ForEachItem( ent, @( item ) AddThink( item, func ))
			// }
			break
		}
	}

	local scope = GetEntScope( ent )

	// no think table setup, normal function
	if ( !thinktable_name || !thinktable_func ) {

		local func_name = ""

		if ( endswith( typeof func, "function" ) ) {

			func_name = func.getinfos().name || format( "__%s_ANONYMOUS_THINK", ent.GetName() )
			scope[ func_name ] <- func
		}
		else if ( !(func in scope) && func in ROOT ) {

			func_name = func
			scope[ func_name ] <- ROOT[ func_name ].bindenv( scope )
		}

		"_AddThinkToEnt" in ROOT ? _AddThinkToEnt( ent, func_name ) : AddThinkToEnt( ent, func_name )

		return
	}

	// setup thinktable if it doesn't exist
	if ( !( thinktable_name in scope ) )
		scope[ thinktable_name ] <- {}

	scope.__thinktable_name <- thinktable_name

	if ( !( thinktable_func in scope ) ) {

		// scope[ thinktable_func ] <- function() {

		// 	foreach ( name, _func in scope[ thinktable_name ] || {} )
		// 		_func.call( scope )

		// 	return -1
		// }

		compilestring( format( "function %s() { foreach( _func in %s || {} ) _func(); return -1 }", thinktable_func, thinktable_name ) ).call( scope )
		try { _AddThinkToEnt( ent, thinktable_func ) } catch ( e ) { AddThinkToEnt( ent, thinktable_func ) }
	}
	// only initialize blank think setup for empty string
	if ( func == "" )
		return

	// add think function to thinktable
	else if ( func ) {

		if ( endswith( typeof func, "function" ) ) {

			scope[ thinktable_name ][ func.getinfos().name || format( "__%s_ANONYMOUS_THINK", ent.GetName() ) ] <- func
			return
		}

		else if (
			typeof func == "string"
			&& !( func in scope[ thinktable_name ] )
			&& ( ( func in this && endswith( typeof this[ func ], "function" ) ) || ( func in ROOT && endswith( typeof ROOT[ func ], "function" ) ) )
		) {

			scope[ thinktable_name ][ func ] <- func in this ? this[ func ].bindenv( scope ) : ROOT[ func ].bindenv( scope )
			return
		}
	}
	else {

		scope[ thinktable_name ].clear()
		return
	}

}

PZI_Util.AddThinkToEnt <- PZI_Util.AddThink

function PZI_Util::RemoveThink( ent, func = null ) {

	local scope = GetEntScope( ent )

	if ( !( "__thinktable_name" in scope ) ) {
		SetPropString( ent, "m_iszScriptThinkFunction", "" )
		return
	}

	local thinktable_name = scope.__thinktable_name

	if ( typeof func == "function" )
		func = func.getinfos().name || format( "__%s_ANONYMOUS_THINK", ent.GetName() )

	if ( !( func in scope[ thinktable_name ] ) )
		return

	!func ? scope[ thinktable_name ].clear() : delete scope[ thinktable_name ][ func ]
}

function PZI_Util::SetConvar( convar, value, duration = 0, hide_chat_message = true ) {

	// TODO: this hack doesn't seem to work.
	local hide_fcvar_notify = hide_chat_message ? CommentaryNode() : null

	// save original values to restore later
	if ( !( convar in ConVars ) ) ConVars[convar] <- GetStr( convar )

	// delay to ensure its set after any server configs
	if ( GetStr( convar ) != value )
		ScriptEntFireSafe( "__pzi_util_util", format( "SetValue( `%s`, `%s` )", convar, value.tostring() ) )

	if ( duration > 0 )
		ScriptEntFireSafe( "__pzi_util_util", format( "PZI_Util.SetConvar( `%s`,`%s` )", convar, ConVars[convar].tostring() ), duration )

	if ( hide_fcvar_notify )
		EntFireByHandle( hide_fcvar_notify, "Kill", "", 1, null, null )
}

function PZI_Util::ResetConvars( hide_chat_message = true ) {

	local hide_fcvar_notify = hide_chat_message ? CommentaryNode() : null

	foreach ( convar, value in ConVars )
		ScriptEntFireSafe( "BigNet", format( "SetValue( `%s`, `%s` )", convar, value.tostring() ) )

	ConVars.clear()

	if ( hide_fcvar_notify )
		EntFireByHandle( hide_fcvar_notify, "Kill", "", -1, null, null )
}

function PZI_Util::ValidatePlayerTables() {

	local function playervalidate(player, _) { return player && player.IsValid() }

	PlayerTable = PlayerTable.filter( playervalidate )
	BotTable 	= BotTable.filter( playervalidate )
	HumanTable 	= HumanTable.filter( playervalidate )
	ZombieTable = ZombieTable.filter( playervalidate )

	PlayerArray = PlayerTable.keys()
	BotArray    = BotTable.keys()
	HumanArray  = HumanTable.keys()
	ZombieArray = ZombieTable.keys()
}

function PZI_Util::KVStringToVectorOrQAngle( str, angles = false, startidx = 0 ) {

	if ( typeof str == "Vector" || typeof str == "QAngle" )
		return str

	local separator = str.find( "," ) ? "," : " "

	local split = split( str, separator, true ).apply( @( v ) PZI_Util.ToStrictNum( v, true ) )

	local errorstr = "KVString CONVERSION ERROR: %s"

	if ( !( 2 in split ) ) {

		// PZI_Ext.Error.ParseError( format( errorstr, "Not enough values ( need at least 3 )" ), true )
		return angles ? QAngle() : Vector()
	}

	local invalid = split.find( null )

	if ( invalid != null ) {

		local invalid_kvstringidx = invalid
		if ( invalid ) {

			local invalid_mod = invalid % 3
			invalid_kvstringidx = !invalid_mod ? 2 : invalid_mod - 1
		}

		local kvstringvalue = angles ? ["yaw", "pitch", "roll"] : ["X", "Y", "Z"]
		// PZI_Ext.Error.ParseError( format( errorstr, format( "Could not convert string to number for KVString %s ( index %d )", kvstringvalue[ invalid_kvstringidx ], invalid ) ), true )
		return angles ? QAngle() : Vector()
	}

	return angles ? QAngle( split[ startidx ], split[ startidx + 1 ], split[ startidx + 2 ] ) : Vector( split[ startidx ], split[ startidx + 1 ], split[ startidx + 2 ] )
}

function PZI_Util::RunGenerator( func, interval = -1 ) {

	local dummy = CreateByClassname( "logic_autosave" )
	dummy.ValidateScriptScope()

	local gen = func()
	function PZI_GeneratorThink() {

		resume gen
		return interval
	}
	dummy.GetScriptScope()[ func.getinfos().name ] <- func
}

// MATH

function PZI_Util::Min( a, b ) {
	return ( a <= b ) ? a : b
}

function PZI_Util::Max( a, b ) {
	return ( a >= b ) ? a : b
}

function PZI_Util::Round( num, decimals=0 ) {

	if ( decimals <= 0 )
		return floor( num + 0.5 )

	local mod = pow( 10, decimals )
	return floor( ( num * mod ) + 0.5 ) / mod
}

function PZI_Util::Clamp( x, a, b ) {
	return Min( b, Max( a, x ) )
}

function PZI_Util::RemapVal( v, A, B, C, D ) {

	if ( A == B ) {
		if ( v >= B )
			return D
		return C
	}
	return C + ( D - C ) * ( v - A ) / ( B - A )
}

function PZI_Util::RemapValClamped( v, A, B, C, D ) {

	if ( A == B ) {
		if ( v >= B )
			return D
		return C
	}
	local cv = ( v - A ) / ( B - A )
	if ( cv <= 0.0 )
		return C
	if ( cv >= 1.0 )
		return D
	return C + ( D - C ) * cv
}

function PZI_Util::IntersectionPointBox( pos, mins, maxs ) {

	if ( pos.x < mins.x || pos.x > maxs.x ||
		pos.y < mins.y || pos.y > maxs.y ||
		pos.z < mins.z || pos.z > maxs.z )
		return false

	return true
}

function PZI_Util::NormalizeAngle( target ) {

	target %= 360.0
	if ( target > 180.0 )
		target -= 360.0
	else if ( target < -180.0 )
		target += 360.0
	return target
}

function PZI_Util::ApproachAngle( target, value, speed ) {

	target = NormalizeAngle( target )
	value = NormalizeAngle( value )
	local delta = NormalizeAngle( target - value )
	if ( delta > speed )
		return value + speed
	else if ( delta < -speed )
		return value - speed
	return target
}

function PZI_Util::VectorAngles( forward ) {

	local yaw, pitch
	if ( !forward.y && !forward.x ) {
		yaw = 0.0
		if ( forward.z > 0.0 )
			pitch = 270.0
		else
			pitch = 90.0
	}
	else {
		yaw = ( atan2( forward.y, forward.x ) * 180.0 / Pi )
		if ( yaw < 0.0 )
			yaw += 360.0
		pitch = ( atan2( -forward.z, forward.Length2D() ) * 180.0 / Pi )
		if ( pitch < 0.0 )
			pitch += 360.0
	}

	return QAngle( pitch, yaw, 0.0 )
}

function PZI_Util::AnglesToVector( angles ) {

	local pitch = angles.x * Pi / 180.0
	local yaw = angles.y * Pi / 180.0
	local x = cos( pitch ) * cos( yaw )
	local y = cos( pitch ) * sin( yaw )
	local z = sin( pitch )
	return Vector( x, y, z )
}

function PZI_Util::QAngleDistance( a, b ) {

	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return sqrt( dx*dx + dy*dy + dz*dz )
}

function PZI_Util::Clamp360Angle( ang ) {

	local t = {x = ang.x, y = ang.y, z = ang.z}

	// Clamp
	foreach ( index, angle in t ) {

		if ( angle > 360 || angle < -360 ) {

			local x = fabs( angle / 360.0 )
			t[index] = Round( ( x - floor( x ) ) * 360.0, 3 )
		}
	}

	// Abs
	foreach ( index, angle in t )
		if ( angle < 0 )
			t[index] = 360.0 - fabs( angle )

	return QAngle( t.x, t.y, t.z )
}

function PZI_Util::CheckBitwise( num ) {
	return num && !( num & ( num - 1 ) )
}

PZI_EVENT( "teamplay_setup_finished", "UtilSetupStatus", function ( params ) {

	PZI_Util.IsInSetup = false

	// delay GC call so we don't eat into the budget of other round start scripts
	EntFire( "__pzi_util", "CallScriptFunction", "collectgarbage" )

}, EVENT_WRAPPER_UTIL )

PZI_EVENT( "teamplay_round_start", "UtilRoundStart", function ( params ) {

	PZI_Util.TriggerHurt 	   <- PZI_Util.SpawnEnt( "trigger_hurt", "__pzi_triggerhurt", false )
	PZI_Util.ClientCommand 	   <- PZI_Util.SpawnEnt( "point_clientcommand", "__pzi_clientcommand", false )
	PZI_Util.RespawnOverride   <- PZI_Util.SpawnEnt( "trigger_player_respawn_override", "__pzi_respawnoverride", false )
	PZI_Util.TriggerParticle   <- PZI_Util.SpawnEnt( "trigger_particle", "__pzi_triggerparticle", false, "attachment_type", 4 )

	PZI_Util.IsInSetup = true
	SetPropBool( PZI_Util.GameRules, "m_bIsInTraining", false )
	PZI_Util.ResetConvars()

	foreach( table in ["kill_on_spawn", "kill_on_death"] )
		foreach ( wearable in PZI_Util[ table ].values() )
				if ( wearable && wearable.IsValid() )
					wearable.Kill()

	PZI_Util.kill_on_spawn.clear()
	PZI_Util.kill_on_death.clear()

	// delay GC call so we don't eat into the budget of other round reset scripts
	EntFire( "__pzi_util", "CallScriptFunction", "collectgarbage" )

}, EVENT_WRAPPER_UTIL )

PZI_EVENT( "player_team", "UtilPlayerTeam", function ( params ) {

	local player = GetPlayerFromUserID( params.userid )

	if ( !( player in PZI_Util.PlayerTable ) )
		PZI_Util.PlayerTable[ player ] <- params.userid

	if ( params.team > TEAM_SPECTATOR ) {

		local tbl = PZI_Util[ params.team == TEAM_HUMAN ? "HumanTable" : "ZombieTable" ]

		if ( !( player in tbl ) )
			tbl[ player ] <- params.userid
	}

	PZI_Util.ValidatePlayerTables()

}, EVENT_WRAPPER_UTIL )

PZI_EVENT( "player_death", "UtilPlayerDeath", function ( params ) {

	local player = GetPlayerFromUserID( params.userid )

	if ( player in PZI_Util.kill_on_death )
		foreach ( wearable in PZI_Util.kill_on_death[ player ] )
			EntFireByHandle( wearable, "Kill", "", -1, null, null )

}, EVENT_WRAPPER_UTIL )

PZI_EVENT( "player_disconnect", "UtilPlayerDisconnect", function ( params ) {

	local player = GetPlayerFromUserID( params.userid )

	local human_table  = PZI_Util.HumanTable
	local zombie_table = PZI_Util.ZombieTable
	local player_table = PZI_Util.PlayerTable
	local bot_table    = PZI_Util.BotTable

	if ( player in human_table )
		delete human_table[ player ]

	if ( player in zombie_table )
		delete zombie_table[ player ]

	if ( player in player_table )
		delete player_table[ player ]

	if ( player in bot_table )
		delete bot_table[ player ]

	PZI_Util.ValidatePlayerTables()

}, EVENT_WRAPPER_UTIL )

PZI_EVENT( "player_team", "UtilPlayerTeam", function( params ) {

	local player = GetPlayerFromUserID( params.userid )

	// hack for potato servers, not necessary in vanilla
	if (!player || !player.IsValid()) return

	if ( !( player in PZI_Util.PlayerTable ) ) {

		PZI_Util.PlayerTable[ player ] <- params.userid

		if ( IsPlayerABot( player ) && !( player in PZI_Util.BotTable ) )
			PZI_Util.BotTable[ player ] <- params.userid
	}

	local tablename = params.team == TEAM_HUMAN ? "HumanTable" : "ZombieTable"

	if ( !( player in PZI_Util[ tablename ] ) )
		PZI_Util[ tablename ][ player ] <- params.userid

}, EVENT_WRAPPER_UTIL )

PZI_EVENT( "post_inventory_application", "UtilPostInventoryApplication", function( params ) {

	local player = GetPlayerFromUserID( params.userid )

	if ( !player || !player.IsValid() || player.IsEFlagSet( EFL_IS_BEING_LIFTED_BY_BARNACLE ) )
		return

	if ( player in PZI_Util.kill_on_death )
		foreach ( wearable in PZI_Util.kill_on_death[ player ] )
			EntFireByHandle( wearable, "Kill", "", -1, null, null )

	local human_table  = PZI_Util.HumanTable
	local zombie_table = PZI_Util.ZombieTable
	local player_table = PZI_Util.PlayerTable
	local bot_table    = PZI_Util.BotTable

	// fill out player tables if empty
	if ( !player_table.len() ) {

		for ( local i = 1, player; i <= MAX_CLIENTS; player = PlayerInstanceFromIndex( i ), i++ ) {

			if ( !player || !player.IsValid() ) continue

			local scope = PZI_Util.GetEntScope( player )
			local userid = PZI_Util.GetPlayerUserID( player )

			if ( IsPlayerABot( player ) )
				bot_table[ player ] <- userid

			else if ( player.GetTeam() == TEAM_HUMAN )
				human_table[ player ] <- userid

			else if ( player.GetTeam() == TEAM_ZOMBIE )
				zombie_table[ player ] <- userid

			player_table[ player ] <- userid
		}

		PZI_Util.ValidatePlayerTables()
		return
	}

	local userid = params.userid

	if ( IsPlayerABot( player ) )
		bot_table[ player ] <- userid

	else if ( player.GetTeam() == TEAM_HUMAN )
		human_table[ player ] <- userid

	else if ( player.GetTeam() == TEAM_ZOMBIE )
		zombie_table[ player ] <- userid

	if ( !( player in player_table ) )
		player_table[ player ] <- userid

	PZI_Util.HumanArray  = human_table.keys()
	PZI_Util.ZombieArray = zombie_table.keys()
	PZI_Util.PlayerArray = player_table.keys()
	PZI_Util.BotArray    = bot_table.keys()

	PZI_Util.ValidatePlayerTables()

}, EVENT_WRAPPER_UTIL )

GetAllAreas( PZI_Util.AllNavAreas )

// pre-collect safe nav areas on load
function PZI_Util::GetSafeNavAreas() {

	if ( !AllNavAreas.len() )
		return

	ScriptEntFireSafe( self, "print( `\\n\\n Collecting nav areas, performance warnings will go away shortly...\\n\\n`)", 0.1)

	local i = 0
	local color_valid  = [   0, 180,  20, 50  ]
	local color_small  = [   0,  20, 180, 50  ]
	local color_edge   = [   0, 180, 180, 50  ]
	local color_warn   = [ 180, 180,  20,  50 ]
	local color_danger = [ 180,   0,  20,  50 ]

	local color
	local trace = {}

	// filter out areas that are too small or inside a trigger_hurt
	foreach( name, area in AllNavAreas ) {

		if ( area.GetSizeX() < 50 )
			color = color_small

		else if ( area.GetSizeY() < 50 )
			color = color_small

		else if ( IsPointInTrigger( area.GetCenter(), "trigger_hurt" ) )
			color = color_danger

		else {

			for ( local i = 0; i < NUM_DIRECTIONS; i++ )
				if ( !area.GetAdjacentArea(i, 1) ) {

					color = color_edge
					break
				}

			if ( color == color_edge )
				continue

			trace.clear()
			trace.start <- area.GetCenter()
			trace.end 	<- area.GetCenter() + Vector( 0, 0, INT_MAX )
			trace.mask  <- CONTENTS_SOLID
			trace.hullmin <- area.GetCorner( NORTH_WEST )
			trace.hullmax <- area.GetCorner( SOUTH_EAST )

			TraceHull( trace )

			if ( trace.hit && trace.enthit && trace.enthit.GetClassname() == "trigger_hurt" )
				color = color_warn
			else
				color = color_valid
		}

		if ( color == color_valid )
			SafeNavAreas[name] <- area

		if ( NAV_DEBUG )
			area.DebugDrawFilled( color[0], color[1], color[2], color[3], 5.0, true, 0.0 )

		i++

		if ( !(i % 500) ) // process this many nav areas per tick
			yield SafeNavAreas.len()
	}

	print("\n\nSafe nav areas collected\n\n")
	EntFire( "__pzi_util", "CallScriptFunction", "collectgarbage" )
}

local gen = PZI_Util.GetSafeNavAreas()
resume gen // do one step right away before thinking

function PZI_Util::ThinkTable::PopulateSafeNav() {

	if ( gen.getstatus() == "dead" ) {

		delete PZI_Util.ThinkTable.PopulateSafeNav
		return 1
	}
	local result = resume gen || SafeNavAreas.len()
	printf("Safe Areas: %s / %s\n", result.tostring(), AllNavAreas.len().tostring() )
}

PZI_Util.ForEachEnt( null, null, null, null, true )