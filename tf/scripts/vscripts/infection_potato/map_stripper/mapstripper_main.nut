// Strip all logic from all maps to replace with ZI logic

Convars.SetValue("mp_autoteambalance", 0)
Convars.SetValue("mp_scrambleteams_auto", 0)
Convars.SetValue("mp_teams_unbalance_limit", 0)
Convars.SetValue("mp_tournament", 0)

local logic_ents = {
 
    tf_logic_koth                    = "KOTH"
    tf_logic_arena                   = "Arena"
    tf_logic_medieval                = "Medieval"
    tf_logic_bounty_mode             = "Bounty"
    tf_logic_competitive             = "Comp"
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

    while ( ent = FindByClassname( ent, "func_powerupvolume" ) )
        return "Mannpower"

    while ( ent = FindByClassname( ent, "tf_weapon_grapplinghook" ) )
        for ( local spawner; spawner = FindByClassname( spawner, "info_powerup_spawn" ); )
            return "Mannpower"

    while ( ent = FindByClassname( ent, "func_passtime*" ) )
        return "PASS"

    while ( ent = FindByClassname( ent, "item_teamflag" ) )
        for ( local cap; cap = FindByClassname( cap, "func_capturezone" ); )
            return "CTF"

    return split( MAPNAME, "_" )[0].toupper()
}

local GAMEMODE = GetGamemode()

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

foreach (prop in gamemode_props)
    SetPropBool(PZI_Util.GameRules, prop, false)

local gamemode_funcs = {

    function PL() {

        // delete payload cart and tracks
        for ( local watcher; watcher = FindByClassname(watcher, "team_train_watcher"); ) {

            local start  = FindByName( null, GetPropString( watcher, "m_iszStartNode" ) )
            local next   = GetPropEntity( start, "p_pnext" )
            local tracks = { start = next }

            while ( next = GetPropEntity( next, "p_pnext" ) ) {

                tracks[ next ] <- null

                local altpath = GetPropEntity( next, "m_paltpath" )
                if ( altpath = FindByName( null, GetPropString( next, "m_altName" ) ) || altpath )
                    tracks[ next ] <- altpath
            }

            foreach ( track1, track2 in tracks )
                PZI_Util.EntShredder[ track1 ] <- track2

            EntFire( GetPropString( watcher, "m_iszTrain" ), "KillHierarchy" )
        }
    }

    function MvM() {

        foreach( ent in [ "func_capturezone", "item_teamflag", "info_populator", "tf_logic_mann_vs_machine" ] )
            EntFire( ent, "Kill" )
    }

    function CTF() {

        foreach( ent in [ "func_capturezone", "item_teamflag" ] )
            EntFire( ent, "Kill" )
    }

    function PD() {

        EntFire( "func_capturezone", "Kill" )

        PZI_EVENT( "player_death", "PZI_MapStripper_PlayerDeath", function ( params ) {

            EntFire( "item_teamflag", "Kill" )
        })
    }
}
gamemode_funcs.PLR <- gamemode_funcs.PL

try { IncludeScript( format("infection_potato/map_strippers/%s", MAPNAME) ) } catch ( e ) {}

PZI_EVENT( "teamplay_round_start", "PZI_MapStripper_RoundStart", function ( params ) {
    
    gamemode_funcs[ GAMEMODE ]()

    // Disables most huds
    SetPropInt( PZI_Util.GameRules, "m_nHudType", 2 )

    // disable control points hud elements
    for ( local tcp; tcp = FindByClassname( null, "team_control_point_master" ); )
    {
        SetPropFloat( tcp, "m_flCustomPositionX", 1.0 )
        tcp.AcceptInput( "RoundSpawn", "", null, null )
        break
    }

    // disable control points
	EntFire( "team_control_point", "Disable" )
	EntFire( "team_control_point", "HideModel" )

    PZI_Util.ScriptEntFireSafe( "*", "PZI_Util.GameStrings[ self.GetScriptId() ] <- null", 0.1 )
    PZI_Util.GameStrings[ "PZI_Util.GameStrings[ self.GetScriptId() ] <- null" ] <- null

})

PZI_EVENT( "teamplay_setup_finished", "PZI_MapStripper_SetupFinished", function ( params ) {

    EntFire( "func_respawnroom", "Disable" )
    EntFire( "func_respawnroom", "SetInactive" )
})

