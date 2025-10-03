function ChatCmdHuman( _hPlayer ) {

    _hPlayer.RemoveCustomAttribute( "hidden maxhealth non buffed" )

    _hPlayer.RemovePlayerWearables()
    _hPlayer.ClearZombieEntities()

    _hPlayer.ForceChangeTeam( TEAM_HUMAN, true )
    _hPlayer.SetHealth  ( _hPlayer.GetMaxHealth() )

    _hPlayer.MakeHuman()
    _hPlayer.ClearZombieEntities()
    _hPlayer.ResetInfectionVars()

    ClientPrint        ( _hPlayer, 4, STRING_SURVIVOR_START )
    _hPlayer.SetHealth ( _hPlayer.GetMaxHealth() )
    _hPlayer.ForceRegenerateAndRespawn()
    return
}

function ChatCmdZombie( _hPlayer ) {

    local _sc = _hPlayer.GetScriptScope()
    _hPlayer.ForceChangeTeam( TEAM_ZOMBIE, true )
    _sc.m_iFlags         <- ( _sc.m_iFlags | ZBIT_PENDING_ZOMBIE )

    _hPlayer.RemovePlayerWearables()
    _hPlayer.GiveZombieCosmetics()
    // _hPlayer.GiveZombieFXWearable()

    _hPlayer.SetHealth      ( _hPlayer.GetMaxHealth() )
    _hPlayer.SetNextActTime ( ZOMBIE_BECOME_ZOMBIE, 1 )
    return
}

function ChatCmdNoclip() {

    if ( _hPlayer.GetMoveType() == MOVETYPE_NOCLIP ) {

        _hPlayer.SetMoveType( MOVETYPE_WALK, 0 )
    }
    else {

        _hPlayer.SetMoveType( MOVETYPE_NOCLIP, 0 )
    }

    return
}

function ChatCmdToggleDebug() {

    if ( DEBUG_MODE ) {

        ClientPrint( null, HUD_PRINTTALK, "\x0870b04aFFDebug mode disabled. Restarting game..." )
        ::DEBUG_MODE = 0
        Convars.SetValue( "mp_restartgame_immediate", 1 )
        DebugSFX( 3 )
        return
    }

    ClientPrint( null, HUD_PRINTTALK, "\x0870b04aFFDebug mode enabled." )
    FindByClassname( null, "team_round_timer" ).Destroy()
    ::DEBUG_MODE <- 5
    DebugSFX( 4 )
    return
}