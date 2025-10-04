
/**************************************************************************************************
 *                                                                                                *
 * All Code By: Harry Colquhoun ( https://steamcommunity.com/profiles/76561198025795825 )         *
 * Assets/Game Design by: Diva Dan ( https://steamcommunity.com/profiles/76561198072146551 )      *
 * Modified for Potato.TF by: Braindawg ( https://steamcommunity.com/profiles/76561197988531991 ) *
 *                                                                                                *
***************************************************************************************************
 * zombie abilities                                                                               *
***************************************************************************************************/

/////////////////////////////////////////////////////////////////////////////////////////////
// ZombieEngie EMP Grenade Ability |------------------------------------------------------ //
/////////////////////////////////////////////////////////////////////////////////////////////
::ENGIE_EMP_LIFETIME               <- 3.5;   // How long the EMP lasts for once thrown  //
// --------------------------------------------------------------------------------------- //
::ENGIE_EMP_BUILDING_DISABLE_TIME  <- 6.5;   // how long is a hit buildable disabled    //
::ENGIE_EMP_BUILDING_DISABLE_RANGE <- 500;   // range from grenade explode to disable   //
::ENGIE_EMP_BUILDING_FLAT_DMG      <- 110;   // how much damage is dealt to buildables  //
// --------------------------------------------------------------------------------------- //
::ENGIE_EMP_THROW_DIST_FROM_EYES   <- -20;   // distance from eyes to spawn grenade     //
::ENGIE_EMP_THROW_FORCE            <- 1500;  // initial force to apply to nade          //
// --------------------------------------------------------------------------------------- //
::ENGIE_EMP_INITIAL_FLASH_RATE     <- 0.85;  // initial delay between each flash        //
::ENGIE_EMP_FLASH_RATE_DECAY_FAC   <- 0.7;   // amnt delay reduced between flashes      //
// --------------------------------------------------------------------------------------- //
::ENGIE_EMP_SCREENSHAKE_AMP        <- 500;   // amplitude of grenade screenshake        //
::ENGIE_EMP_SCREENSHAKE_FREQ       <- 500;   // frequency of grenade screenshake        //
::ENGIE_EMP_SCREENSHAKE_DUR        <- 1;     // duration of grenade screenshake         //
::ENGIE_EMP_SCREENSHAKE_RAD        <- 1000;  // duration of grenade screenshake         //
::ENGIE_EMP_MINIROOT_LEN           <- 0.25;  //                                         //
::ENGIE_EMP_FIRST_HIT_RANGE        <- 88;    //                                         //
::ENGIE_EMP_FIRST_HIT_DMG_PERCENT  <- 0.25;  //                                         //
// --------------------------------------------------------------------------------------- //
/////////////////////////////////////////////////////////////////////////////////////////////
// ZombieSniper Spit Ability |------------------------------------------------------------ //
/////////////////////////////////////////////////////////////////////////////////////////////
::SNIPER_SPIT_THROW_DIST           <- 50;    // distance from eyes to spawn spit ball   //
::SNIPER_SPIT_THROW_FORCE          <- 2000;  // initial force to apply to spit ball     //
::SNIPER_SPIT_HIT_PLAYER_Z_DIST    <- 300;   // initial force to apply to spit ball     //
::SNIPER_SPIT_HIT_WORLD_Z_DIST     <- 100;   // initial force to apply to spit ball     //
// --------------------------------------------------------------------------------------- //
::SNIPER_SPIT_MASS                 <- 0.1;   // spit ball mass ( for base physprop )      //
// --------------------------------------------------------------------------------------- //
::SNIPER_SPIT_ZONE_DAMAGE          <- 25.0;  // damage per tick from spit zone          //
::SNIPER_SPIT_POP_DAMAGE           <- 45.0;  // dmg to players in zone when first pop   //
::SNIPER_SPIT_MIN_SURFACE_PERCENT  <- 75;    // min surface hit % for spit zone to form //
::SNIPER_SPIT_HITBOX_SIZE          <- 5;     // size in hu of spitball hitbox           //
// --------------------------------------------------------------------------------------- //
::SNIPER_SPIT_OVERLOAD_START_TIME  <- 3.5;   // how many seconds til overload           //
::SNIPER_SPIT_LIFETIME             <- 2.5;   // how many seconds til overload           //
::SNIPER_SPIT_MAX_CHANNEL_TIME     <- 5;     // max time spitball can be held for       //
::SPIT_ZONE_LIFETIME               <- 5;     // how many seconds the zone stays down    //
::SPIT_ZONE_RADIUS                 <- 130;   // hammer units radius of spit zone damage //
// --------------------------------------------------------------------------------------- //
/////////////////////////////////////////////////////////////////////////////////////////////
// ZombieSpy Reveal Ability |------------------------------------------------------------- //
/////////////////////////////////////////////////////////////////////////////////////////////
::SPY_REVEAL_RANGE               <- 1000;  // Maximum distance for player to be hit     //
::SPY_REVEAL_LENGTH              <- 20;    // how long players are revealed for ( sec )   //
::SPY_RECLOAK_TIME               <- 3;     // how long before spy becomes cloaked again //
// --------------------------------------------------------------------------------------- //
/////////////////////////////////////////////////////////////////////////////////////////////
// ZombieMedic Heal Ability |------------------------------------------------------------- //
/////////////////////////////////////////////////////////////////////////////////////////////
::MEDIC_HEAL_RANGE                 <- 275;   // Maximum distance for player to be hit   //
::MEDIC_HEAL_RATE                  <- 0.5;   // time in sec between each heal tick      //
/////////////////////////////////////////////////////////////////////////////////////////////
// ZombieDemo Charge Ability |------------------------------------------------------------ //
/////////////////////////////////////////////////////////////////////////////////////////////
// DEMOMAN_CHARGE_DAMAGE              = 275;   //                                          //
::DEMOMAN_CHARGE_BASE_DAMAGE            <- 100;   //                                    //
::DEMOMAN_CHARGE_DAMAGE_PER_PLAYER_MULT <- 1.35;  //                                    //
::DEMOMAN_CHARGE_RADIUS                 <- 200;   //                                    //
::DEMOMAN_CHARGE_INVULN_TIME            <- 1.4;   //                                    //
::DEMOMAN_CHARGE_FORCE                  <- 650;  //                                     //
::DEMOMAN_CHARGE_FORCE_UPWARD_MULT      <- 1.5;   //                                    //
/////////////////////////////////////////////////////////////////////////////////////////////
// generic zombie stuff      |------------------------------------------------------------ //
/////////////////////////////////////////////////////////////////////////////////////////////
::ZOMBIE_BOOST_SPEED_DEBUFF        <- 0.85;  //                                         //
// --------------------------------------------------------------------------------------- //
/////////////////////////////////////////////////////////////////////////////////////////////

class CZombieAbility {

    m_iAbilityType       =   0
    m_hAbilityOwner      =   null
    m_fAbilityCooldown   =   0.0
    m_szAbilityName      =   " "
    m_szAbilityDesc      =   " "
    m_arrAttribs         =   [ ]
    m_arrTFConds         =   [ ]

    function GetAbilityType     ()  { return this.m_iAbilityType; }
    function GetAbilityOwner    ()  { return this.m_hAbilityOwner; }
    function GetAbilityCooldown ()  { return this.m_fAbilityCooldown; }
    function GetAbilityName     ()  { return this.m_szAbilityName; }

    function LockAbility() {

        this.m_hAbilityOwner.SetNextActTime( ZOMBIE_ABILITY_CAST, ACT_LOCKED )
    }

    function UnlockAbility() {

        this.m_hAbilityOwner.SetNextActTime( ZOMBIE_ABILITY_CAST, 0.01 )
    }

    function PutAbilityOnCooldown() {

        this.m_hAbilityOwner.SetNextActTime( ZOMBIE_ABILITY_CAST, this.m_fAbilityCooldown )
    }

}
// --------------------------------- //
//            SPY ABILITY            //
// --------------------------------- //
class CSpyReveal extends CZombieAbility {

    constructor( hAbilityOwner ) {

        this.m_hAbilityOwner     =  hAbilityOwner
        this.m_iAbilityType      =  ZABILITY_EMITTER
        this.m_fAbilityCooldown  =  MIN_TIME_BETWEEN_SPY_REVEAL
        this.m_szAbilityName     =  SPY_REVEAL_NAME
    }

    function AbilityCast() {

        if ( this.m_hAbilityOwner == null )
            return

        local _d = this.m_hAbilityOwner.GetScriptScope()

        _d.m_hTempEntity <- SpawnEntityFromTable( "info_particle_system", {

            effect_name   =  FX_EMITTER_FX,
            start_active  =  "0",
            targetname    =  "ZombieSpy_Revealer_pfx",
            origin        =  this.m_hAbilityOwner.GetOrigin(),
        } )

        this.m_hAbilityOwner.SetForcedTauntCam  ( 1 )

        if ( _d.m_hZombieFXWearable != null && _d.m_hZombieFXWearable.IsValid() )
            _d.m_hZombieFXWearable.Destroy()

        if ( _d.m_hZombieWearable != null && _d.m_hZombieWearable.IsValid() )
            _d.m_hZombieWearable.Destroy()

        // this.m_hAbilityOwner.GiveZombieFXWearable()
        this.m_hAbilityOwner.GiveZombieCosmetics()

        this.m_hAbilityOwner.AddCond            ( TF_COND_TAUNTING )
        this.m_hAbilityOwner.AddEventToQueue    ( EVENT_KILL_TEMP_ENTITY, 2 ); // todo - const
        this.m_hAbilityOwner.AddEventToQueue    ( EVENT_PUT_ABILITY_ON_CD, INSTANT )

        EmitSoundOn        ( "WeaponMedigun.HealingWorld", _d.m_hTempEntity )
        EntFireByHandle    ( _d.m_hTempEntity, "Start", "", 0, null, null )
        ScreenShake        ( this.m_hAbilityOwner.GetOrigin(), 15.0, 150.0, 1.0, 500, 0, false )
        EntFireByHandle    ( _d.m_hTempEntity, "SetParent", "!activator", 0, this.m_hAbilityOwner, this.m_hAbilityOwner )

        EmitAmbientSoundOn ( SFX_SPY_REVEAL_ONCAST, 899,  1, 100, this.m_hAbilityOwner )

        local _hPlayer            = null
        local _arrPlayersInRange  = []

        // get all of the players in range
        while ( _hPlayer = FindByClassnameWithin( _hPlayer, "player", this.m_hAbilityOwner.GetOrigin(), ( SPY_REVEAL_RANGE ) ) ) {

            // red ( survivor ) team only
            if ( _hPlayer != null && _hPlayer.GetTeam() != TEAM_ZOMBIE ) {

                _arrPlayersInRange.append( _hPlayer )
            }
        }

        if ( !_arrPlayersInRange.len() )
            return

        // apply reveal effect
        local _arrPlayersInRange_len = _arrPlayersInRange.len()
        for ( local i = 0; i < _arrPlayersInRange_len; i++ ) {

            local _hNextPlayer = _arrPlayersInRange[ i ]

            if ( _hNextPlayer == null || _hNextPlayer == this.m_hAbilityOwner )
                break

            _hNextPlayer.RemoveCond(  TF_COND_DISGUISED   )
            _hNextPlayer.RemoveCond(  TF_COND_DISGUISING  )
            _hNextPlayer.RemoveCond(  TF_COND_STEALTHED   )

            local _scNext = _hNextPlayer.GetScriptScope()

            // spy reveal simply enables m_bGlowEnabled on players
            SetPropBool ( _hNextPlayer, "m_bGlowEnabled", true )

            // stagger glow removal times so the players blink out at random times ( looks cool )
            _hNextPlayer.SetNextActTime ( ZOMBIE_KILL_GLOW, RandomFloat( 5, 7.5 ) )
            _scNext.m_iFlags         <- ( _scNext.m_iFlags | ZBIT_REVEALED_BY_SPY )
        }

        return
    }
}
// --------------------------------- //
//          SOLDIER ABILITY          //
// --------------------------------- //
class CSoldierJump extends CZombieAbility {

    constructor( hAbilityOwner ) {

        this.m_hAbilityOwner     =  hAbilityOwner
        this.m_iAbilityType      =  ZABILITY_THROWABLE
        this.m_fAbilityCooldown  =  MIN_TIME_BETWEEN_SOLDIER_POUNCE
        this.m_szAbilityName     =  SOLDIER_POUNCE_NAME
    }

    function AbilityCast() {

        if ( this.m_hAbilityOwner == null )
            return

        local _sc = this.m_hAbilityOwner.GetScriptScope()

        EmitAmbientSoundOn( "Infection.SoldierPounce", 9, 1, 100, this.m_hAbilityOwner )

        local _hPlayerVM    =   GetPropEntity( this.m_hAbilityOwner, "m_hViewModel" )
        local _iSpecialSeq  =  _hPlayerVM.LookupSequence( "special" )

        SetPropEntity( this.m_hAbilityOwner, "m_hGroundEntity", null )

        _hPlayerVM.ResetSequence        ( _iSpecialSeq )
        this.m_hAbilityOwner.AddCond    ( TF_COND_BLASTJUMPING )
        this.m_hAbilityOwner.RemoveFlag ( FL_ONGROUND )

        _sc.m_iFlags <- ( _sc.m_iFlags | ZBIT_SOLDIER_IN_POUNCE )

        local _vecVelocity = this.m_hAbilityOwner.GetAbsVelocity()

        SetPropEntity( this.m_hAbilityOwner, "m_hGroundEntity", null )

        this.m_hAbilityOwner.ApplyAbsVelocityImpulse( this.m_hAbilityOwner.EyeAngles().Forward() +
                                                      _vecVelocity + Vector( 0, 0, 850 ) ); // todo - const

        this.m_hAbilityOwner.AddEventToQueue ( EVENT_PUT_ABILITY_ON_CD, INSTANT )
        return
    }
}
// --------------------------------- //
//           MEDIC ABILITY           //
// --------------------------------- //
class CMedicHeal extends CZombieAbility {

    constructor( hAbilityOwner ) {

        this.m_hAbilityOwner     =  hAbilityOwner
        this.m_iAbilityType      =  ZABILITY_EMITTER
        this.m_fAbilityCooldown  =  MIN_TIME_BETWEEN_MEDIC_HEAL
        this.m_szAbilityName     =  MEDIC_HEAL_NAME
    }

    function AbilityCast() {

        if ( this.m_hAbilityOwner == null )
            return

        local _d = this.m_hAbilityOwner.GetScriptScope()

        _d.m_hTempEntity <- SpawnEntityFromTable( "info_particle_system", {

            effect_name   =  FX_MEDIC_HEAL,
            start_active  =  "0",
            targetname    =  "ZombieSpy_Revealer_pfx",
            origin        =  this.m_hAbilityOwner.GetOrigin(),
        } )

        if ( _d.m_hZombieFXWearable != null && _d.m_hZombieFXWearable.IsValid() )
            _d.m_hZombieFXWearable.Destroy()

        if ( _d.m_hZombieWearable != null && _d.m_hZombieWearable.IsValid() )
            _d.m_hZombieWearable.Destroy()

        // this.m_hAbilityOwner.GiveZombieFXWearable()
        this.m_hAbilityOwner.GiveZombieCosmetics()

        this.m_hAbilityOwner.SetForcedTauntCam  ( 1 )
        this.m_hAbilityOwner.AddCustomAttribute ( "no_attack", 1, -1 )
        this.m_hAbilityOwner.AddEventToQueue    ( EVENT_KILL_TEMP_ENTITY, 2 ); // todo - const
        this.m_hAbilityOwner.AddEventToQueue    ( EVENT_PUT_ABILITY_ON_CD, INSTANT )
        this.m_hAbilityOwner.AddCondEx          ( TF_COND_INVULNERABLE_USER_BUFF, 1, this.m_hAbilityOwner )
        this.m_hAbilityOwner.AddCondEx          ( TF_COND_HALLOWEEN_QUICK_HEAL, 2, this.m_hAbilityOwner  )
        EmitSoundOn                             ( SFX_ZMEDIC_HEAL, this.m_hAbilityOwner )

        EntFireByHandle    ( _d.m_hTempEntity, "SetParent", "!activator", 0, this.m_hAbilityOwner, this.m_hAbilityOwner )
        EntFireByHandle    ( _d.m_hTempEntity, "Start", "", 0.2, null, null )
       // EmitSoundOnClient  ( "WeaponMedigun.HealingWorld", this.m_hAbilityOwner )

        local _hPlayer            = null
        local _arrPlayersInRange  = []

        // get all of the players in range
        while ( _hPlayer = FindByClassnameWithin( _hPlayer, "player", this.m_hAbilityOwner.GetOrigin(), MEDIC_HEAL_RANGE ) ) {

            // blue ( zombie ) team only
            if ( _hPlayer != null && _hPlayer.GetTeam() == TEAM_ZOMBIE && _hPlayer != this.m_hAbilityOwner ) {

                _arrPlayersInRange.append( _hPlayer )
            }
        }

        if ( !_arrPlayersInRange.len() )
            return

        // apply heal effect
        local _arrPlayersInRange_len = _arrPlayersInRange.len()
        for ( local i = 0; i < _arrPlayersInRange_len; i++ ) {

            local _hNextPlayer   =  _arrPlayersInRange[ i ]
            local _angPlayer     =  _hNextPlayer.GetLocalAngles()
            local _vecAngPlayer  =  Vector( _angPlayer.x, _angPlayer.y, _angPlayer.z )

            if ( _hNextPlayer == null || _hNextPlayer == this.m_hAbilityOwner )
                break

            local _scNext = _hNextPlayer.GetScriptScope()

            _hNextPlayer.SpawnEffect()

            _hNextPlayer.AddCondEx ( TF_COND_INVULNERABLE_USER_BUFF, 1, this.m_hAbilityOwner )
            _hNextPlayer.AddCondEx ( TF_COND_HALLOWEEN_QUICK_HEAL,   2, this.m_hAbilityOwner )
        }

        return
    }

}
// --------------------------------- //
//          SNIPER ABILITY           //
// --------------------------------- //
class CSniperSpitball extends CZombieAbility {

    constructor( hAbilityOwner ) {

        this.m_hAbilityOwner     =  hAbilityOwner
        this.m_iAbilityType      =  ZABILITY_PROJECTILE
        this.m_fAbilityCooldown  =  MIN_TIME_BETWEEN_ENGIE_EMP_THROW
        this.m_szAbilityName     =  SNIPER_SPIT_NAME
    }

    function AbilityCast() {

        if ( this.m_hAbilityOwner == null )
            return

        local _d = this.m_hAbilityOwner.GetScriptScope()

        if ( ( _d.m_iFlags & ZBIT_SNIPER_CHARGING_SPIT ) )
            return

        local _hPlayerVM = GetPropEntity( this.m_hAbilityOwner, "m_hViewModel" )

        this.m_hAbilityOwner.AddEventToQueue( EVENT_SNIPER_SPITBALL, MIN_TIME_BETWEEN_SPIT_START_END )
        local _specialSequence = _hPlayerVM.LookupSequence ( "special" )
        _hPlayerVM.ResetSequence  ( _specialSequence )

        _d.m_fTimeAbilityCastStarted <- Time()

        _d.m_iFlags = ( _d.m_iFlags | ZBIT_SNIPER_CHARGING_SPIT )
        EmitSoundOn   ( SFX_ZOMBIE_SPIT_START, m_hAbilityOwner )

        this.m_hAbilityOwner.GetActiveWeapon().AddAttribute( "move speed penalty", 0.5, -1 )
        return
    }

    function CreateSpitball( _bPlayerDead = false ) {

        if ( this.m_hAbilityOwner == null )
            return

        local _d = this.m_hAbilityOwner.GetScriptScope()

        // if the player is dead when the spitball is thrown, drop straight down
        local _iThrowForce   =  SNIPER_SPIT_THROW_FORCE
        local _iDist         =  SNIPER_SPIT_THROW_DIST
        local _vecPlayerVel  =  GetPropVector( this.m_hAbilityOwner, "m_vecVelocity" )

        local _vecFwd    =  this.m_hAbilityOwner.EyeAngles().Forward()
        local _vecThrow  =  ( ( _vecFwd * _iThrowForce ) + _vecPlayerVel )

        local _angPos    =  ( this.m_hAbilityOwner.EyePosition() + ( _vecFwd * _iDist ) )
        local _spitEnt   =  CreateByClassname( "prop_physics_override" )

        if ( _bPlayerDead ) {

            _vecThrow = Vector( 0, 0, -100 )
        }

        // spit projectile is just an engie nade
        _spitEnt.SetModel  ( MDL_WORLD_MODEL_ENGIE_NADE )
        _spitEnt.SetAbsOrigin ( _angPos )

        // // not sure if this does anything
        // SetPropVector ( _spitEnt, "m_vInitialVelocity", _vecThrow )

        // make it invisible
        SetPropInt    ( _spitEnt, "m_nRenderMode", kRenderTransColor )
        SetPropInt    ( _spitEnt, "m_clrRendder", 0 )
        SetPropInt    ( _spitEnt, "m_CollisionGroup", COLLISION_GROUP_PROJECTILE )

        local _hPfxEnt = SpawnEntityFromTable( "info_particle_system", {

            effect_name  = FX_SPIT_TRAIL,
            start_active = "1",
            origin       = _angPos
        } )

        EntFireByHandle( _hPfxEnt, "SetParent", "!activator",  0, _spitEnt, _spitEnt )

        ::DispatchSpawn( _spitEnt )
        _spitEnt.SetPhysVelocity ( _vecThrow )

        SetPropInt( _spitEnt, "m_nRenderMode", kRenderTransColor )
        SetPropInt( _spitEnt, "m_clrRender", 0 )

        _spitEnt.ValidateScriptScope()

        local _sc = _spitEnt.GetScriptScope()

        _sc.m_hOwner        <-   this.m_hAbilityOwner
        _sc.m_iState        <-   SPIT_STATE_IN_TRANSIT
        _sc.m_hPfx          <-   _hPfxEnt
        _sc.m_bDealtPopDmg  <-   false
        _sc.m_bHasHitSolid  <-   false

        _sc.m_fTimeStart    <-   ( Time() ).tofloat()
        _sc.m_flKillMeTime  <-   ( Time() + SNIPER_SPIT_LIFETIME ).tofloat()

        _sc.m_iDistanceToGround  <- 0
        _sc.m_vecHitPosition     <- Vector( 0, 0, 0 )
        _sc.m_vecPlaneNormal     <- Vector( 0, 0, 0 )

        this.m_hAbilityOwner.GetActiveWeapon().RemoveAttribute( "move speed penalty" )

        EmitSoundOn( SFX_ZOMBIE_SPIT_END, m_hAbilityOwner )

        _d.m_iFlags = ( _d.m_iFlags & ~ZBIT_SNIPER_CHARGING_SPIT )

        this.PutAbilityOnCooldown()

        AddThinkToEnt( _spitEnt, "SniperSpitThink" )
        return
    }
}

// --------------------------------- //
//         ENGINEER ABILITY          //
// --------------------------------- //
class CEngineerSapperNade extends CZombieAbility {

    constructor( hAbilityOwner ) {

        this.m_hAbilityOwner     =  hAbilityOwner
        this.m_iAbilityType      =  ZABILITY_THROWABLE
        this.m_fAbilityCooldown  =  MIN_TIME_BETWEEN_ENGIE_EMP_THROW
        this.m_szAbilityName     =  ENGIE_EMP_NAME
    }

    function AbilityCast() {

        if ( this.m_hAbilityOwner == null )
            return

        local _d = this.m_hAbilityOwner.GetScriptScope()

        SetPropFloat ( _d.m_hZombieWep, "m_flNextPrimaryAttack",   FLT_MAX )
        SetPropFloat ( _d.m_hZombieWep, "m_flNextSecondaryAttack", FLT_MAX )

        this.m_hAbilityOwner.GetActiveWeapon().AddAttribute( "move speed penalty", 0.5, -1 )

        EmitSoundOnClient ( "Weapon_GrenadeLauncher.DrumStop", m_hAbilityOwner )

        this.m_hAbilityOwner.AddEventToQueue ( EVENT_ENGIE_THROW_NADE, INSTANT )
        this.m_hAbilityOwner.AddEventToQueue ( EVENT_ENGIE_EXIT_MINIROOT, ENGIE_EMP_MINIROOT_LEN )
        return
    }

    function ThrowNadeProjectile() {

        if ( this.m_hAbilityOwner == null )
            return

        local _d = this.m_hAbilityOwner.GetScriptScope()

        PrecacheScriptSound  ( "Infection.EngineerEMP" )
        EmitAmbientSoundOn   ( "Infection.EngineerEMP", 9, 1, 100, this.m_hAbilityOwner )

        local _hPlayerVM     =  GetPropEntity( this.m_hAbilityOwner, "m_hViewModel" )

        // random numbers for angles so the nade spins
        local _fPitch        =  RandomFloat( -360, 360 )
        local _fYaw          =  RandomFloat( -360, 360 )
        local _fRoll         =  RandomFloat( -360, 360 )

        local _iDist         =  ENGIE_EMP_THROW_DIST_FROM_EYES
        local _iThrowForce   =  ENGIE_EMP_THROW_FORCE

        local _vecPlayerVel  =  GetPropVector( m_hAbilityOwner, "m_vecVelocity" )

        local _vecFwd        =  m_hAbilityOwner.EyeAngles().Forward()
        local _vecThrow      =  ( ( _vecFwd * _iThrowForce ) + _vecPlayerVel )
        local _angPos        =  ( m_hAbilityOwner.EyePosition() + ( _vecFwd * _iDist ) )
        local _nadeEnt       =  CreateByClassname( "prop_physics_override" )

        SetPropFloat( _d.m_hZombieWep, "m_flNextPrimaryAttack", FLT_MAX )

        _nadeEnt.SetModel  ( MDL_WORLD_MODEL_ENGIE_NADE )
        _nadeEnt.SetAbsOrigin ( _angPos )

        _nadeEnt.SetModelScale ( 1.4, 0.0 ); // todo - const
        _nadeEnt.SetSize       ( ( _nadeEnt.GetBoundingMins() * 1 ),
                                 ( _nadeEnt.GetBoundingMaxs() * 1 ) ); // todo - const

        SetPropInt      ( _nadeEnt, "m_CollisionGroup", COLLISION_GROUP_PROJECTILE )
        SetPropVector   ( _nadeEnt, "m_vInitialVelocity ", _vecThrow )
        SetPropInt      ( _nadeEnt, "m_takedamage", 1 )
        _nadeEnt.KeyValueFromString ( "targetname", "engie_nade_physprop" )


        ::DispatchSpawn( _nadeEnt )
        //_nadeEnt.SetMoveType( MOVETYPE_WALK, MOVECOLLIDE_DEFAULT )
        local _hPfxEnt = SpawnEntityFromTable( "info_particle_system", {

            effect_name  = FX_EMP_FLASH,
            start_active = "0",
            targetname   = "ZombieEngie_EMP_Grenade_particle",
            origin       = _angPos
        } )

        EntFireByHandle             ( _hPfxEnt,  "SetParent", "!activator",  0, _nadeEnt, _nadeEnt )
       // _nadeEnt.KeyValueFromString ( "targetname", "engie_nade_physprop" )

        _nadeEnt.SetAngles           ( _fPitch, _fYaw, _fRoll )
        _nadeEnt.SetAngularVelocity  ( _fPitch, _fYaw, _fRoll )
        _nadeEnt.SetPhysVelocity     ( _vecThrow )

        _nadeEnt.ValidateScriptScope()

        local _sc = _nadeEnt.GetScriptScope()

        _sc.m_fTimeStart       <-  ( Time() ).tofloat()
        _sc.m_fNextFlashTime   <-  ( Time() + ENGIE_EMP_INITIAL_FLASH_RATE ).tofloat()
        _sc.m_fExplodeTime     <-  ( Time() + ENGIE_EMP_LIFETIME ).tofloat()
        _sc.m_bStuckToSurface  <-  false

        _sc.m_fFlashRate   <-  ENGIE_EMP_INITIAL_FLASH_RATE
        _sc.m_hOwner       <-  this.m_hAbilityOwner
        _sc.m_hPfx         <-  _hPfxEnt
        _sc.m_bHasHitSolid <-  false
        _sc.m_bMustFizzle  <-  false

        this.m_hAbilityOwner.ViewPunch( QAngle( -3, 0, 0 ) ); // todo - const

        local _iSpecialSeq = _hPlayerVM.LookupSequence( "special" )
        _hPlayerVM.ResetSequence ( _iSpecialSeq )


        this.m_hAbilityOwner.AddEventToQueue ( EVENT_PUT_ABILITY_ON_CD, 2 )
        AddThinkToEnt                        ( _nadeEnt, "EngieEMPThink" )
        return
    }

    function ExitRoot() {

        this.m_hAbilityOwner.GetActiveWeapon().RemoveAttribute( "move speed penalty" )
        this.PutAbilityOnCooldown()
        return
    }
}

// ---------------------------------------------------------------------------------------------------------- //
//          DEMO ABILITY                                                                                      //
// REWORKED: Extremely high knockback, Damage now scales with players in radius, Reduced invulnerability time //
// Getting oneshot by a random demo charge is really stupid, but demo should still be able to bunker bust     //
// Skybox individual players instead because it's funny and more fair                                         //
// ---------------------------------------------------------------------------------------------------------- //
class CDemoCharge extends CZombieAbility {

    constructor( hAbilityOwner ) {

        this.m_hAbilityOwner     =  hAbilityOwner
        this.m_iAbilityType      =  ZABILITY_THROWABLE
        this.m_fAbilityCooldown  =  MIN_TIME_BETWEEN_DEMO_CHARGE
        this.m_szAbilityName     =  DEMO_CHARGE_NAME
    }

    function AbilityCast() {

        if ( this.m_hAbilityOwner == null )
            return

        local _d = this.m_hAbilityOwner.GetScriptScope()

        this.m_hAbilityOwner.SetForcedTauntCam( 1 )

        SetPropFloat ( _d.m_hZombieWep, "m_flNextPrimaryAttack",   FLT_MAX )
        SetPropFloat ( _d.m_hZombieWep, "m_flNextSecondaryAttack", FLT_MAX )

        if ( _d.m_hZombieFXWearable != null && _d.m_hZombieFXWearable.IsValid() )
            _d.m_hZombieFXWearable.Destroy()

        if ( _d.m_hZombieWearable != null && _d.m_hZombieWearable.IsValid() )
            _d.m_hZombieWearable.Destroy()

        // create new ones now that the player can see themselves
        // this.m_hAbilityOwner.GiveZombieFXWearable()
        this.m_hAbilityOwner.GiveZombieCosmetics()

        EmitSoundOn( SFX_DEMO_CHARGE_RAMP, this.m_hAbilityOwner )

        // todo - array
        this.m_hAbilityOwner.AddCond   ( TF_COND_CRITBOOSTED_PUMPKIN )
        this.m_hAbilityOwner.AddCond   ( TF_COND_TAUNTING )
        // this.m_hAbilityOwner.AddCondEx ( TF_COND_INVULNERABLE_USER_BUFF, 1.76, this.m_hAbilityOwner )
        this.m_hAbilityOwner.AddCondEx ( TF_COND_INVULNERABLE_USER_BUFF, DEMOMAN_CHARGE_INVULN_TIME, this.m_hAbilityOwner )
        this.m_hAbilityOwner.AddCond   ( TF_COND_RADIUSHEAL ); // just the heal ring

        this.m_hAbilityOwner.RemoveOutOfCombat ( true )

        this.m_hAbilityOwner.AddCustomAttribute ( "no_jump", 1, -1 )
        this.m_hAbilityOwner.AddCustomAttribute ( "no_duck", 1, -1 )
        this.m_hAbilityOwner.AddCustomAttribute ( "no_attack", 1, -1 )
        this.m_hAbilityOwner.AddCustomAttribute ( "move speed penalty", 0.001, -1 )

        this.m_hAbilityOwner.AddEventToQueue   ( EVENT_DEMO_CHARGE_START, 1.75 )

        _d.m_iFlags <- ( _d.m_iFlags | ZBIT_DEMOCHARGE )

        return
    }

    function StartDemoCharge() {

        if ( this.m_hAbilityOwner == null )
            return

        local _sc = this.m_hAbilityOwner.GetScriptScope()

        EmitAmbientSoundOn ( "Infection.DemoCharge", 10, 1, 100, this.m_hAbilityOwner )

        _sc.m_iFlags  <- ( _sc.m_iFlags | ZBIT_MUST_EXPLODE )

        this.m_hAbilityOwner.AddCond    ( TF_COND_SHIELD_CHARGE )
        this.m_hAbilityOwner.RemoveCond ( TF_COND_RADIUSHEAL )
        // this.m_hAbilityOwner.AddCondEx  ( TF_COND_INVULNERABLE_USER_BUFF, 0.298, this.m_hAbilityOwner )
        this.m_hAbilityOwner.AddEventToQueue   ( EVENT_DEMO_CHARGE_EXIT, 1.5 )

        this.m_hAbilityOwner.RemoveCustomAttribute ( "no_jump" )
        this.m_hAbilityOwner.RemoveCustomAttribute ( "no_duck" )
        this.m_hAbilityOwner.RemoveCustomAttribute ( "no_attack" )
        this.m_hAbilityOwner.RemoveCustomAttribute ( "move speed penalty" )
        return
    }

    function ExitDemoCharge() {

        if ( this.m_hAbilityOwner == null )
            return

        local _d = this.m_hAbilityOwner.GetScriptScope()

        this.m_hAbilityOwner.RemoveCond  ( TF_COND_SHIELD_CHARGE )
        this.m_hAbilityOwner.RemoveCond  ( TF_COND_INVULNERABLE_USER_BUFF )
        this.m_hAbilityOwner.RemoveCond  ( TF_COND_TAUNTING )

        this.PutAbilityOnCooldown()

        _d.m_iFlags            <- ( _d.m_iFlags & ~ZBIT_MUST_EXPLODE )
        _d.m_iFlags            <- ( _d.m_iFlags & ~ZBIT_DEMOCHARGE )
        _d.m_tblEventQueue     <- { }

        DemomanExplosionPreCheck( this.m_hAbilityOwner.GetOrigin(),
                                  DEMOMAN_CHARGE_BASE_DAMAGE,
                                  DEMOMAN_CHARGE_DAMAGE_PER_PLAYER_MULT,
                                  DEMOMAN_CHARGE_RADIUS,
                                  this.m_hAbilityOwner,
                                  DEMOMAN_CHARGE_FORCE,
                                  DEMOMAN_CHARGE_FORCE_UPWARD_MULT )

        this.m_hAbilityOwner.AddEventToQueue( EVENT_DEMO_CHARGE_RESET, 0.1 )
        return
    }
}
class CPassiveAbility extends CZombieAbility {

    function AbilityCast() {

        return
    }

    // ------------------------------------------------------------------- //
    // passive abilities are now handled through zombie attrib/cond system //
    // this is still here because it's used for name/desc                  //
    // todo - remove this                                                  //
    // ------------------------------------------------------------------- //
    function ApplyPassive() {

        return
    }

    function StripPassive() {

        return
    }
}

class CPyroPassive extends CPassiveAbility {

    constructor( hAbilityOwner ) {

        this.m_hAbilityOwner     =  hAbilityOwner
        this.m_iAbilityType      =  ZABILITY_PASSIVE
        this.m_fAbilityCooldown  =  ACT_LOCKED
        this.m_szAbilityName     =  PYRO_BLAST_NAME
     // this.m_arrAttribs        =  PYRO_PASSIVE_ATTRIBUTES
     // this.m_arrTFConds        =  PYRO_PASSIVE_CONDS
    }
}

class CHeavyPassive extends CPassiveAbility {

    constructor( hAbilityOwner ) {

        this.m_hAbilityOwner     =  hAbilityOwner
        this.m_iAbilityType      =  ZABILITY_PASSIVE
        this.m_fAbilityCooldown  =  ACT_LOCKED
        this.m_szAbilityName     =  HEAVY_PASSIVE_NAME
     // this.m_arrAttribs        =  HEAVY_PASSIVE_ATTRIBUTES
     // this.m_arrTFConds        =  HEAVY_PASSIVE_CONDS
    }
}

class CScoutPassive extends CPassiveAbility {

    constructor( hAbilityOwner ) {

        this.m_hAbilityOwner     =  hAbilityOwner
        this.m_iAbilityType      =  ZABILITY_PASSIVE
        this.m_fAbilityCooldown  =  ACT_LOCKED
        this.m_szAbilityName     =  SCOUT_PASSIVE_NAME
     // this.m_arrAttribs        =  SCOUT_PASSIVE_ATTRIBUTES
     // this.m_arrTFConds        =  SCOUT_PASSIVE_CONDS
    }
}

class CMedicPassive extends CPassiveAbility {

    constructor( hAbilityOwner ) {

        this.m_hAbilityOwner     =  hAbilityOwner
        this.m_iAbilityType      =  ZABILITY_PASSIVE
        this.m_fAbilityCooldown  =  ACT_LOCKED
        this.m_szAbilityName     =  MEDIC_PASSIVE_NAME
     // this.m_arrAttribs        =  SCOUT_PASSIVE_ATTRIBUTES
     // this.m_arrTFConds        =  SCOUT_PASSIVE_CONDS
    }
}


class CPyroBlast extends CZombieAbility {

    constructor( hAbilityOwner ) {

        this.m_hAbilityOwner     =  hAbilityOwner
        this.m_iAbilityType      =  ZABILITY_THROWABLE
        this.m_fAbilityCooldown  =  MIN_TIME_BETWEEN_PYRO_BLAST
        this.m_szAbilityName     =  PYRO_BLAST_NAME
    }

    function AbilityCast() {

        if ( this.m_hAbilityOwner == null )
            return

        local _sc = this.m_hAbilityOwner.GetScriptScope()

        local _vecAngFwd    = this.m_hAbilityOwner.EyeAngles().Forward()*975
        local _vecAngOrigin = this.m_hAbilityOwner.EyePosition()+this.m_hAbilityOwner.EyeAngles().Forward()*32
        local _vecAngEye    = this.m_hAbilityOwner.EyeAngles()

        // spawn the dragon's fury projectile
        local _BallOfFlames = SpawnEntityFromTable( "tf_projectile_BallOfFire", {

            basevelocity = _vecAngFwd,
            teamnum      = this.m_hAbilityOwner.GetTeam(),
            origin       = _vecAngOrigin,
            angles       = _vecAngEye
        } )

        AddThinkToEnt          ( _BallOfFlames, "PyroFireballThink" )
        _BallOfFlames.SetOwner ( this.m_hAbilityOwner )

        local _dummyFlamer = CreateByClassname( "tf_weapon_flamethrower" )

        SetPropInt  ( _dummyFlamer, STRING_NETPROP_ITEMDEF, ID_FLAMETHROWER )
        SetPropBool ( _dummyFlamer, STRING_NETPROP_ATTACH, true )
        SetPropFloat( _dummyFlamer, "m_flNextSecondaryAttack", 0.0 )

        ::DispatchSpawn( _dummyFlamer )

        this.m_hAbilityOwner.Weapon_Equip( _dummyFlamer )

        SetPropIntArray( this.m_hAbilityOwner, STRING_NETPROP_AMMO, 99, 1 )

        _dummyFlamer.SecondaryAttack()

        this.m_hAbilityOwner.DestroyAllWeapons()
        this.m_hAbilityOwner.GiveZombieWeapon()
        this.m_hAbilityOwner.RemoveAmmo()

        this.m_hAbilityOwner.AddEventToQueue ( EVENT_PUT_ABILITY_ON_CD, INSTANT )
        this.m_hAbilityOwner.AddEventToQueue ( EVENT_RESET_ZOMBIE_WEP,   0.01 )

        return
    }
}

CZombieAbility.m_arrClassAbilities <- [ null, CScoutPassive, CSniperSpitball, CSoldierJump, CDemoCharge, CMedicHeal, CHeavyPassive, CPyroBlast, CSpyReveal, CEngineerSapperNade, CScoutPassive ]