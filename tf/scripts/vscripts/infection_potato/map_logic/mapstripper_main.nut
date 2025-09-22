// Strip all logic from all maps to replace with ZI logic
Convars.SetValue( "mp_autoteambalance", 0 )
Convars.SetValue( "mp_scrambleteams_auto", 0 )
Convars.SetValue( "mp_teams_unbalance_limit", 0 )
Convars.SetValue( "mp_tournament", 0 )
Convars.SetValue( "mp_respawnwavetime", 2 )

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

local GAMEMODE = GetGamemode()

local gamemode_funcs = {

    function PL() {

        // delete payload cart and tracks
        for ( local watcher; watcher = FindByClassname( watcher, "team_train_watcher" ); ) {

            local start  = FindByName( null, GetPropString( watcher, "m_iszStartNode" ) )
            local next   = GetPropEntity( start, "p_pnext" )
            local tracks = { start = next }

            while ( next = GetPropEntity( next, "p_pnext" ) ) {

                tracks[ next ] <- null

                local altpath = GetPropEntity( next, "m_paltpath" )
                if ( altpath = FindByName( null, GetPropString( next, "m_altName" ) ) || altpath )
                    tracks[ next ] = altpath
            }

            foreach ( track1, track2 in tracks )
                PZI_Util.EntShredder[ track1 ] <- track2

            EntFire( GetPropString( watcher, "m_iszTrain" ), "Kill" )
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

    local timer = SpawnEntityFromTable( "team_round_timer", {

        targetname          = "__pzi_timer",
        auto_countdown      = 1
        max_length          = 720
        reset_time          = 1
        setup_length        = 60
        show_in_hud         = 1
        show_time_remaining = 1
        start_paused        = 0
        timer_length        = 480
        StartDisabled       = 0
        "OnFinished#1"      : "__pzi_util,CallScriptFunction,RoundWin,1"
    } )

    EntFire( "__pzi_timer", "Resume", null, 1 )

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

} )

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
