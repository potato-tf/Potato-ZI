// Strip all logic from all maps to replace with ZI logic
Convars.SetValue( "mp_autoteambalance", 0 )
Convars.SetValue( "mp_scrambleteams_auto", 0 )
Convars.SetValue( "mp_teams_unbalance_limit", 0 )
Convars.SetValue( "mp_tournament", 0 )
Convars.SetValue( "mp_respawnwavetime", 2 )

::LOCALTIME <- {}
LocalTime(LOCALTIME)

//TODO: move this somewhere more fitting than the map logic scripts
::SERVER_DATA <- {

	endpoint_url			  = "https://archive.potato.tf/api/serverstatus"
	server_name				  = ""
	server_key				  = ""
    server_tags               = GetStr("sv_tags")
	address					  = 0
	wave 					  = 0
	max_wave				  = -1
	players_blu				  = 0
	players_connecting		  = 0
	players_max				  = MaxClients().tointeger()
	players_red				  = 0
	matchmaking_disable_time  = 0
	map					      = GetMapName()
	mission					  = "Zombie Infection"
	region					  = ""
	password 				  = ""
	classes					  = ""
	domain 					  = "potato.tf"
	campaign_name 			  = "Other Gamemodes"
	status 					  = "Eating your brains..."
	// in_protected_match		  = false
	// is_fake_ip				  = false
	// steam_ids				  = []

	// update_time 			  = {

	// 	year	= LOCALTIME.year
	// 	month	= LOCALTIME.month
	// 	day		= LOCALTIME.day
	// 	hour	= LOCALTIME.hour
	// 	minute	= LOCALTIME.minute
	// 	second	= LOCALTIME.second
	// }
}

function PZI_Util::GetServerKey( hostname = SERVER_DATA.server_name ) { return strip( hostname.slice( hostname.find("#") + 1, hostname.find(" [") ) ) }

PZI_Util.ScriptEntFireSafe("__pzi_util", @"

	local server_name  = GetStr(`hostname`)
	local split_server = split(server_name, `#`)
	local split_region = split_server.len() == 1 ? [``, `]`] : split(split_server[1], `[`)

	SERVER_DATA.server_name = server_name
    SERVER_DATA.server_tags = GetStr(`sv_tags`)
	SERVER_DATA.server_key	= GetServerKey( server_name )
	SERVER_DATA.region		= split_region.len() == 1 ? `` : split_region[1].slice(0, split_region[1].find(`]`))
	SERVER_DATA.domain		= SERVER_DATA.region == `USA` ? `us.potato.tf` : format(`%s.%s`, SERVER_DATA.region.tolower(), SERVER_DATA.domain)

	if ( SERVER_DATA.domain == `ustx.potato.tf` )
		SERVER_DATA.domain += `:22443`

", 5)

local spawns = []

for ( local spawn; spawn = FindByClassname( spawn, "info_player_teamspawn" ); ) {

    // SetPropInt( spawn, "m_iTeamNum", TEAM_UNASSIGNED )

    if ( spawn.GetName() == "" )
        SetPropString( spawn, STRING_NETPROP_NAME, format( "teamspawn_%d", spawn.entindex() ) )

    spawns.append( spawn.GetName() )
}

local spawns_len = spawns.len()

local logic_ents = {

    tf_logic_koth                    = "KOTH"
    tf_logic_arena                   = "Arena"
    tf_logic_medieval                = "Medieval"
    tf_logic_bounty_mode             = "Bounty"
    tf_logic_hybrid_ctf_cp           = "CTF/CP"
    tf_logic_mann_vs_machine         = "MvM"
    tf_logic_multiple_escort         = "PLR"
    tf_logic_special_delivery_mode   = "SD"
    tf_logic_robot_destruction_mode  = "RD"
    tf_logic_player_destruction_mode = "PD"
}

local function GetGamemode() {

    local ent
    while ( ent = FindByClassname( ent, "tf_logic*" ) )
        if ( ent.GetClassname() in logic_ents )
            return logic_ents[ ent.GetClassname() ]

    while ( ent = FindByClassname( ent, "team_train_watcher" ) )
        return "PL"

    while ( ent = FindByClassname( ent, "func_passtime*" ) )
        return "PASS"

    while ( ent = FindByClassname( ent, "item_teamflag" ) ) {

        for ( local spawner; spawner = FindByClassname( spawner, "info_powerup_spawn" ); )
            return "Mannpower"

        for ( local cap; cap = FindByClassname( cap, "func_capturezone" ); )
            return "CTF"
    }

    return split( MAPNAME, "_" )[0].toupper()
}

local function SetupRoundTimer() {

    for (local timer; timer = FindByClassname(timer, "team_round_timer");)
        EntFireByHandle(timer, "Kill", null, -1, null, null)

    local timer = SpawnEntityFromTable( "team_round_timer", {

        targetname          = "__pzi_timer"
        vscripts            = " "
        auto_countdown      = 1
        max_length          = 300
        reset_time          = 1
        setup_length        = 45
        show_in_hud         = 1
        show_time_remaining = 1
        start_paused        = 0
        timer_length        = 240
        StartDisabled       = 0
        "OnFinished#1"      : "__pzi_util,CallScriptFunction,RoundWin,0,-1"
        "OnFinished#2"      : "__pzi_util,RunScriptCode,SetValue(`mp_humans_must_join_team` `red`),1,-1"
        "OnSetupFinished#1" : "self,RunScriptCode,base_timestamp = GetPropFloat(self `m_flTimeRemaining`),1,-1"
    })

    if ( PlayerCount(TEAM_HUMAN) + PlayerCount(TEAM_ZOMBIE) )
        EntFire( "__pzi_timer", "Resume", null, 1 )

    local scope = timer.GetScriptScope()
    scope.base_timestamp <- GetPropFloat(timer, "m_flTimeRemaining")

    if ("VPI" in ROOT)
    {
        function TimerThink()
        {
            local time_left = (base_timestamp - Time()).tointeger()
            if ( !(time_left % 10) )
            {
                local players = PlayerCount( TEAM_HUMAN ) + PlayerCount( TEAM_ZOMBIE )

                if ( players <= 1 )
                    timer.AcceptInput("SetTime", "30", null, null)

                // LocalTime(LOCALTIME)
                // SERVER_DATA.update_time = LOCALTIME
                SERVER_DATA.max_wave = time_left
                SERVER_DATA.wave = time_left
                SERVER_DATA.server_name = GetStr("hostname")
                SERVER_DATA.server_tags = GetStr("sv_tags")

                if ( SERVER_DATA.server_key == "" )
                    SERVER_DATA.server_key = PZI_Util.GetServerKey( SERVER_DATA.server_name )

                local players = array(2, 0)
                local spectators = 0
                foreach (player, userid in PZI_Util.PlayerTable)
                {
                    if (!player || !player.IsValid())
                        continue

                    if ( player.GetTeam() == TEAM_SPECTATOR || IsPlayerABot(player) )
                        spectators++
                    else
                        players[player.GetTeam() == TEAM_HUMAN ? 0 : 1]++
                }

                SERVER_DATA.players_red = players[0]
                SERVER_DATA.players_blu = players[1]
                SERVER_DATA.players_connecting = spectators

                VPI.AsyncCall({
                    func   = "VPI_UpdateServerData"
                    kwargs = SERVER_DATA

                    // callback = function(response, error) {

                    //     assert(!error)

                    //     if (SERVER_DATA.address == 0 && "address" in response)
                    //         SERVER_DATA.address = response.address
                    // }
                })
                return 1.1
            }
            return -1
        }

        function InputSetTime() {

            base_timestamp = GetPropFloat(timer, "m_flTimeRemaining") + Time()
            return true
        }
        scope.InputSetTime <- InputSetTime
        scope.Inputsettime <- InputSetTime
        scope.TimerThink <- TimerThink
        AddThinkToEnt(timer, "TimerThink")
    }
    return timer
}

local timer = SetupRoundTimer()

local GAMEMODE = GetGamemode()

local gamemode_funcs = {

    function PL() {

        // delete payload cart and tracks
        EntFire( "mapobj_cart_dispenser", "Kill" )
        local shredder = PZI_Util.EntShredder
        for ( local watcher; watcher = FindByClassname( watcher, "team_train_watcher" ); ) {

            EntFire( GetPropString( watcher, "m_iszTrain" ), "Kill" )

            local last   = FindByName( null, GetPropString( watcher, "m_iszGoalNode" ) )
            local prev   = GetPropEntity( last, "m_pprevious" )
            local tracks = { [last] = prev }

            while ( prev = GetPropEntity( prev, "m_pprevious" ) ) {

                shredder.append( prev )

                local altpath = GetPropEntity( prev, "m_paltpath" )
                if ( altpath )
                    shredder.append( altpath )
                else if ( altpath = FindByName( null, GetPropString( prev, "m_altName" ) ) )
                    shredder.append( altpath )
            }
            shredder.append( watcher )
        }
    }

    function MvM() {

        foreach( ent in [ "func_capturezone", "item_teamflag", "info_populator", "tf_logic_mann_vs_machine" ] )
            EntFire( ent, "Kill" )
    }

    function PD() {

        EntFire( "func_capturezone", "Kill" )

        PZI_EVENT( "player_death", "PZI_MapStripper_PlayerDeath", function ( params ) {

            EntFire( "item_teamflag", "Kill" )
        } )
    }
}
gamemode_funcs.RD  <- gamemode_funcs.PD
gamemode_funcs.PLR <- gamemode_funcs.PL
gamemode_funcs.CTF <- gamemode_funcs.MvM


// disable gamemode logic
local gamemode_props = [

    "m_bIsInTraining"
    "m_bIsWaitingForTrainingContinue"
    "m_bIsTrainingHUDVisible"
    "m_bIsInItemTestingMode"
    "m_bPlayingKoth"
    "m_bPlayingMedieval"
    "m_bPlayingHybrid_CTF_CP"
    "m_bPlayingSpecialDeliveryMode"
    "m_bPlayingRobotDestructionMode"
    "m_bPlayingMannVsMachine"
    "m_bIsUsingSpells"
    "m_bCompetitiveMode"
    "m_bPowerupMode"
    "m_nForceEscortPushLogic"
    "m_bBountyModeEnabled"
]

foreach ( prop in gamemode_props )
    SetPropBool( PZI_Util.GameRules, prop, false )

try { IncludeScript( format( "infection_potato/map_stripper/%s", MAPNAME ) ) } catch ( e ) {}

local ents_to_kill = [ "team_round_timer", "game_round_win" ]

PZI_EVENT( "teamplay_round_start", "PZI_MapStripper_RoundStart", function ( params ) {

    if ( GAMEMODE in gamemode_funcs )
        gamemode_funcs[ GAMEMODE ]()

    foreach ( tokill in ents_to_kill )
        for ( local ent; ent = FindByClassname( ent, tokill ); )
            EntFireByHandle( ent, "Kill", null, -1, null, null )

    timer = SetupRoundTimer()

    // Disables most huds
    SetPropInt( PZI_Util.GameRules, "m_nHudType", 2 )

    // disable control points hud elements
    for ( local tcp; tcp = FindByClassname( null, "team_control_point_master" ); ) {

        SetPropFloat( tcp, "m_flCustomPositionX", 1.0 )
        SetPropFloat( tcp, "m_flCustomPositionY", 1.0 )
        tcp.AcceptInput( "RoundSpawn", "", null, null )
        local tcp_scope = PZI_Util.GetEntScope( tcp )
        tcp_scope.InputSetWinner <- @() false
        tcp_scope.Inputsetwinner <- @() false
        break
    }
    // disable control points
    EntFire( "team_control_point", "SetLocked", "1" )
    EntFire( "team_control_point", "HideModel" )
	EntFire( "team_control_point", "Disable" )

})

PZI_EVENT( "teamplay_setup_finished", "PZI_MapStripper_SetupFinished", function ( params ) {

    EntFire( "func_respawnroom", "Disable" )
    EntFire( "func_respawnroom", "SetInactive" )
    EntFire( "func_regenerate", "Kill" )

    // open all doors near respawn rooms
    for ( local respawnroom; respawnroom = FindByClassname( respawnroom, "func_respawnroom*" ); ) {

        for ( local door; door = FindByClassnameWithin( door, "func_door*", respawnroom.GetCenter(), 1024 ); ) {

            door.AcceptInput( "Open", null, null, null )
            EntFireByHandle( door, "Kill", null, 0.1, null, null )
        }
    }

} )

PZI_EVENT( "player_spawn", "PZI_MapStripper_PlayerSpawn", function ( params ) {

    local player = GetPlayerFromUserID( params.userid )
    EntFire( "__pzi_respawnoverride", "StartTouch", null, -1, player )

    // random spawn points
    EntFire( "__pzi_respawnoverride", "SetRespawnName", spawns[ RandomInt( 0, spawns_len - 1 ) ], -1, player )
} )
