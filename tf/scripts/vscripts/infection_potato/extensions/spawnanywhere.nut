PZI_CREATE_SCOPE( "__pzi_spawnanywhere", "PZI_SpawnAnywhere", null, "SpawnAnywhereThink" )

const SNIPER_SKELETON = "models/bots/skeleton_sniper/skeleton_sniper.mdl"

const NEST_MODEL            = "models/player/heavy.mdl"
const NEST_EXPLODE_SOUND    = "misc/null.wav"
const NEST_EXPLODE_PARTICLE = " "
const NEST_EXPLODE_DAMAGE   = 120
const NEST_EXPLODE_RADIUS   = 200
const NEST_EXPLODE_HEALTH   = 650

const MAX_SPAWN_DISTANCE   = 2048
const NEAREST_NAV_RADIUS   = 1024
const MAX_NAV_VIEW_DISTANCE = 2048

const SUMMON_ANIM_MULT = 0.7
const SUMMON_HEAL_DELAY = 1.5
const SUMMON_MAX_OVERHEAL_MULT = 1
const SUMMON_RADIUS = 512

const PLAYER_HULL_HEIGHT = 82

CONST.HIDEHUD_GHOST <- ( HIDEHUD_CROSSHAIR|HIDEHUD_HEALTH|HIDEHUD_WEAPONSELECTION|HIDEHUD_METAL|HIDEHUD_BUILDING_STATUS|HIDEHUD_CLOAK_AND_FEIGN|HIDEHUD_PIPES_AND_CHARGE )
CONST.TRACEMASK <- ( CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_PLAYERCLIP|CONTENTS_WINDOW|CONTENTS_MONSTER|CONTENTS_GRATE )

PrecacheModel( NEST_MODEL )
PrecacheModel( SNIPER_SKELETON )

PZI_SpawnAnywhere.ActiveNests <- {}

function PZI_SpawnAnywhere::SetGhostMode( player ) {

    local scope = PZI_Util.GetEntScope( player )

    SetPropInt( player, "m_nRenderMode", kRenderTransColor )
    SetPropInt( player, "m_clrRender", 0 )

    SetPropInt( player, "m_afButtonDisabled", IN_ATTACK2 )

    scope.m_iFlags <- ZBIT_PYRO_DONT_EXPLODE

    scope.playermodel <- player.GetModelName()

    // player.SetPlayerClass( TF_CLASS_SCOUT )
    // SetPropInt( player, "m_Shared.m_iDesiredPlayerClass", TF_CLASS_SCOUT )

    // player.SetScriptOverlayMaterial( "colorcorrection/desaturated.vmt" )

    player.AddHudHideFlags( CONST.HIDEHUD_GHOST )

    for ( local child = player.FirstMoveChild(); child; child = child.NextMovePeer() )
        if ( child instanceof CEconEntity )
            EntFireByHandle( child, "Kill", "", -1, null, null )
        else
            child.DisableDraw()

    PZI_Util.ScriptEntFireSafe( player, "self.AddCustomAttribute( `dmg taken increased`, 0, -1 )", -1 )
    PZI_Util.ScriptEntFireSafe( player, "self.AddCustomAttribute( `move speed bonus`, 5, -1 )", -1 )
    PZI_Util.ScriptEntFireSafe( player, "self.AddCustomAttribute( `major increased jump height`, 3, -1 )", -1 )
    PZI_Util.ScriptEntFireSafe( player, "self.AddCustomAttribute( `voice pitch scale`, 0, -1 )", -1 )

    player.SetCollisionGroup( COLLISION_GROUP_DEBRIS )
    player.SetSolidFlags( FSOLID_TRIGGER )
    // player.SetSolidFlags( FSOLID_NOT_SOLID )
    // player.SetSolid( SOLID_NONE )
    player.AddFlag( FL_DONTTOUCH|FL_NOTARGET )
}

function PZI_SpawnAnywhere::BeginSummonSequence( player, origin ) {

    local scope = player.GetScriptScope() || ( player.ValidateScriptScope(), player.GetScriptScope() )

    if ( "GhostThink" in scope.ThinkTable )
        delete scope.ThinkTable.GhostThink

    //should already be invis but whatever
    SetPropInt( player, "m_nRenderMode", kRenderTransColor )
    SetPropInt( player, "m_clrRender", 0 )

    player.SetAbsOrigin( origin + Vector( 0, 0, 20 ) )

    SetPropInt( player, "m_afButtonForced", IN_DUCK )
    SetPropBool( player, "m_Local.m_bDucked", true )
    player.AddFlag( FL_DUCKING|FL_ATCONTROLS )

    player.SetAbsVelocity( Vector() )
    player.AcceptInput( "SetForcedTauntCam", "1", null, null )
    player.AddCustomAttribute( "no_jump", 1, -1 )
    player.GiveZombieEyeParticles()

    scope.m_iFlags = scope.m_iFlags | ZBIT_PENDING_ZOMBIE

    local playercls = player.GetPlayerClass()

    local dummy_skeleton = CreateByClassname( "funCBaseFlex" )

    dummy_skeleton.SetModel( SNIPER_SKELETON )
    dummy_skeleton.SetAbsOrigin( origin )
    dummy_skeleton.SetAbsAngles( QAngle( 0, player.EyeAngles().y, 0 ) )

    ::DispatchSpawn( dummy_skeleton )
    dummy_skeleton.ValidateScriptScope()
    local dummy_scope = dummy_skeleton.GetScriptScope()

    SetPropInt( dummy_skeleton, "m_nRenderMode", kRenderTransColor )
    SetPropInt( dummy_skeleton, "m_clrRender", 0 )

    // dummy_skeleton.ResetSequence( dummy_skeleton.LookupSequence( format( "spawn0%d", RandomInt( 2, 7 ) ) ) ) //spawn01 is cursed
    // dummy_skeleton.ResetSequence( dummy_skeleton.LookupSequence( "spawn04" ) )

    local spawn_seq = RandomInt( 3, 4 )
    local spawn_seq_name = format( "spawn0%d", spawn_seq )

    dummy_skeleton.ResetSequence( dummy_skeleton.LookupSequence( spawn_seq_name ) )
    dummy_skeleton.SetPlaybackRate( SUMMON_ANIM_MULT )

    local dummy_player = CreateByClassname( "funCBaseFlex" )

    dummy_player.SetModel( format( "models/player/%s.mdl", PZI_Util.Classes[playercls] ) )
    dummy_player.SetAbsOrigin( origin )
    dummy_player.SetSkin( player.GetSkin() + 4 )
    dummy_player.AcceptInput( "SetParent", "!activator", dummy_skeleton, dummy_skeleton )
    SetPropInt( dummy_player, "m_fEffects", EF_BONEMERGE|EF_BONEMERGE_FASTCULL )
    ::DispatchSpawn( dummy_player )
    dummy_scope.dummy_player <- dummy_player
    // CTFPlayer.GiveZombieEyeParticles.call( dummy_player )

    local fakewearable = CreateByClassname( "prop_dynamic_ornament" )
    fakewearable.SetModel( arrZombieCosmeticModelStr[playercls] )
    fakewearable.SetSkin( 1 )
    ::DispatchSpawn( fakewearable )
    fakewearable.AcceptInput( "SetAttached", "!activator", dummy_player, dummy_player )
    dummy_scope.fakewearable <- fakewearable

    player.RemoveCustomAttribute( "dmg taken increased" )
    player.SetHealth( 1 )
    player.RemoveHudHideFlags( CONST.HIDEHUD_GHOST )
    player.RemoveFlag( FL_NOTARGET|FL_DONTTOUCH )
    player.SetSolid( SOLID_BBOX )
    player.SetSolidFlags( 0 )
    player.SetCollisionGroup( COLLISION_GROUP_PLAYER_MOVEMENT )

    PZI_Util.ScriptEntFireSafe( player, "self.AddCond( TF_COND_HALLOWEEN_QUICK_HEAL )", SUMMON_HEAL_DELAY )

    function SummonPreSpawn() {

        if ( player.GetHealth() >= player.GetMaxHealth() * SUMMON_MAX_OVERHEAL_MULT ) {

            player.RemoveCond( TF_COND_HALLOWEEN_QUICK_HEAL )
            delete this.ThinkTable.SummonPreSpawn
        }
    }

    scope.ThinkTable.SummonPreSpawn <- SummonPreSpawn

    //max health attrib is always last
    local attrib = ZOMBIE_PLAYER_ATTRIBS[playercls]
    local lastattrib = attrib[attrib.len() - 1]

    player.AddCustomAttribute( lastattrib[0], lastattrib[1], lastattrib[2] )

    function SpawnPlayer() {

        if ( !player || !player.IsValid() || !player.IsAlive() ) {

            if ( fakewearable && fakewearable.IsValid() )
                fakewearable.Kill()

            self.Kill()
            return
        }

        // animation finished, "spawn" player
        if ( GetPropFloat( self, "m_flCycle" ) >= 0.99 ) {

            SendGlobalGameEvent( "hide_annotation", { id = player.entindex() } )

            player.RemoveFlag( FL_ATCONTROLS|FL_DUCKING )
            SetPropInt( player, "m_afButtonForced", 0 )
            SetPropBool( player, "m_Local.m_bDucked", false )

            SetPropInt( player, "m_nRenderMode", kRenderNormal )
            SetPropInt( player, "m_clrRender", 0xFFFFFFFF )
            player.AcceptInput( "SetForcedTauntCam", "0", null, null )

            player.RemoveCustomAttribute( "no_jump" )
            player.RemoveCustomAttribute( "move speed bonus" )
            player.RemoveCustomAttribute( "major increased jump height" )
            player.RemoveCustomAttribute( "voice pitch scale" )

            for ( local child = player.FirstMoveChild(); child; child = child.NextMovePeer() )
                child.EnableDraw()

            if ( player.GetPlayerClass() == TF_CLASS_PYRO )
                scope.m_iFlags = scope.m_iFlags & ~ZBIT_PYRO_DONT_EXPLODE

            SetPropInt( player, "m_afButtonDisabled", 0 )
            player.GiveZombieCosmetics()
            // PZI_Util.ScriptEntFireSafe( player, "self.GiveZombieCosmetics(); self.GiveZombieEyeParticles()" )

            EntFireByHandle( self, "Kill", "", -1, null, null )
            EntFireByHandle( fakewearable, "Kill", "", -1, null, null )
            return 10
        }

        self.StudioFrameAdvance()
        return -1
    }

    dummy_scope.SpawnPlayer <- SpawnPlayer
    AddThinkToEnt( dummy_skeleton, "SpawnPlayer" )
}

function PZI_SpawnAnywhere::CreateNest( player, origin = null ) {

    local nest = CreateByClassname( "tf_generic_bomb" )

    nest.KeyValueFromInt( "health", NEST_EXPLODE_HEALTH )
    nest.KeyValueFromFloat( "damage", NEST_EXPLODE_DAMAGE )
    nest.KeyValueFromFloat( "radius", NEST_EXPLODE_RADIUS )
    nest.KeyValueFromString( "targetname", format( "__pzi_spawn_nest_%d", player.entindex() ) )
    nest.KeyValueFromString( "explode_particle", NEST_EXPLODE_PARTICLE )
    nest.KeyValueFromString( "sound", NEST_EXPLODE_SOUND )
    SetPropBool( nest, STRING_NETPROP_PURGESTRINGS, true )
    nest.SetModel( NEST_MODEL )

    nest.ValidateScriptScope()

    nest.SetAbsOrigin( origin || player.GetOrigin() )

    PZI_SpawnAnywhere.ActiveNests[nest.GetName()] <- {

        health          = NEST_EXPLODE_HEALTH
        last_takedamage = 0.0
        nearby_players  = 0
        closest_player  = null
        nest_origin     = nest.GetOrigin()
        nest_generator  = null
    }

    NestScope <- nest.GetScriptScope()

    foreach ( k, v in PZI_SpawnAnywhere.ActiveNests )
        NestScope[k] <- v

    function NestScope::NestGenerator() {

        foreach ( player in PZI_Util.HumanArray ) {

            local player_origin = player.GetOrigin()

            if ( ( player_origin - nest_origin ).Length() <= SUMMON_RADIUS )
                nearby_players++

            if ( !closest_player || ( player_origin - nest_origin ).Length() < ( closest_player.GetOrigin() - nest_origin ).Length() )
                closest_player = player

            yield player
        }

        // update the nest in the active nests table
        PZI_SpawnAnywhere.ActiveNests[self.GetName()] = NestScope
    }

    function NestScope::NestThink() {

        if ( !PZI_Util.HumanArray.len() )
            return 1

        if ( health != GetPropInt( nest, "m_iHealth" ) ) {

            last_takedamage = Time()
            health = GetPropInt( nest, "m_iHealth" )
        }

        // look for closest player and num players nearby
        if ( !nest_generator || nest_generator.getstatus() == "dead" )
            nest_generator = NestGenerator()

        resume nest_generator

        return -1

    }

    AddThinkToEnt( nest, "NestThink" )
}

PZI_EVENT( "player_hurt", "SpawnAnywhere_RemoveQuickHeal", function( params ) {

    local player = GetPlayerFromUserID( params.userid )

    if ( player.InCond( TF_COND_HALLOWEEN_QUICK_HEAL ) && player.GetTeam() == TEAM_ZOMBIE )
        player.RemoveCond( TF_COND_HALLOWEEN_QUICK_HEAL )

} )

PZI_EVENT( "player_activate", "SpawnAnywhere_PlayerActivate", function( params ) { GetPlayerFromUserID( params.userid ).ValidateScriptScope() } )

PZI_EVENT( "player_spawn", "SpawnAnywhere_PlayerSpawn", function( params ) {

    local player = GetPlayerFromUserID( params.userid )

    // make everyone non-solid
    player.SetCollisionGroup( TFCOLLISION_GROUP_COMBATOBJECT )

    local scope = player.GetScriptScope() || ( player.ValidateScriptScope(), player.GetScriptScope() )

    if ( GetPropInt( player, "m_nRenderMode" ) == kRenderTransColor ) {

        SetPropInt( player, "m_nRenderMode", kRenderNormal )
        SetPropInt( player, "m_clrRender", 0xFFFFFFFF )
    }

    // BLU LOGIC BEYOND THIS POINT
    if ( player.GetTeam() != TEAM_ZOMBIE ) return

    else if ( GetRoundState() != GR_STATE_RND_RUNNING ) return

    scope.spawn_nests <- []
    scope.tracepos    <- Vector()
    scope.spawn_area  <- null

    // PZI_Util.ScriptEntFireSafe( player, "PZI_SpawnAnywhere.SetGhostMode( self )", -1 )
    PZI_SpawnAnywhere.SetGhostMode( player )

    // make bots behave like mvm spy bots
    if ( IsPlayerABot( player ) ) {

        PZI_Util.ScriptEntFireSafe( player, @"

            local players = GetRandomPlayers( 1, TEAM_HUMAN )
            if ( !( 0 in players ) )
                return

            PZI_Util.TeleportNearVictim( self, players[0], 0.25)
            PZI_SpawnAnywhere.BeginSummonSequence( self, self.GetOrigin() )

        ", RandomFloat( 0.1, 1.2 ) ) // random delay to avoid predictable spawn waves
    }

    local players = GetRandomPlayers( 1, TEAM_HUMAN )

    if ( !( 0 in players ) )
        return

    PZI_Util.TeleportNearVictim( player, players[0], 0.25 )

    local spawn_hint = CreateByClassname( "move_rope" )
    spawn_hint.KeyValueFromString( "targetname", format( "spawn_hint_%d", player.entindex() ) )
    // spawn_hint.AddEFlags( EFL_IN_SKYBOX )
    ::DispatchSpawn( spawn_hint )
    SetPropBool( spawn_hint, STRING_NETPROP_PURGESTRINGS, true )

    PZI_Util.ScriptEntFireSafe( spawn_hint, format( @"

        local player_idx = %d

        local origin = self.GetOrigin()

        SendGlobalGameEvent( `show_annotation`, {

            text = `Spawn Here!`
            lifetime = -1
            show_distance = true
            visibilityBitfield = 1 << player_idx
            follow_entindex = self.entindex()
            worldposX = origin.x
            worldposY = origin.y
            worldposZ = origin.z
            id = player_idx
        } )

    ", player.entindex() ), 0.5 )

    function GhostThink() {

        // find the nav we're looking at
        local nav_trace = {

            start  = player.EyePosition()
            end    = player.EyeAngles().Forward() * INT_MAX
            mask   = CONST.TRACEMASK
            ignore = player
        }

        TraceLineEx( nav_trace )

        // no world geometry found
        if ( !nav_trace.hit ) return

        tracepos = nav_trace.pos

        // trace too far away
        if ( ( player.GetOrigin() - tracepos ).Length2D() > MAX_SPAWN_DISTANCE ) return

        local nav_area = GetNearestNavArea( tracepos, NEAREST_NAV_RADIUS, false, true )

        // not a valid area
        if ( !nav_area || !nav_area.IsFlat() || PZI_Util.IsPointInTrigger( nav_area.GetCenter() + Vector( 0, 0, 64 ), "trigger_hurt" ) ) return

        // smooth movement for the annotation instead of snapping
        // spawn_hint.KeyValueFromVector( "origin", hull_trace.pos + Vector( 0, 0, 20 ) )

        // check if we can fit here
        local hull_trace = {

            start   = nav_trace.pos
            end     = nav_trace.pos
            hullmin = Vector( -24, -24, 20 )
            hullmax = Vector( 24, 24, 84 )
            mask    = CONST.TRACEMASK
            ignore  = player
        }

        TraceHull( hull_trace )

        spawn_area = hull_trace.hit ? null : nav_area

        if ( spawn_area )
            spawn_hint.KeyValueFromVector( "origin", spawn_area.GetCenter() + Vector( 0, 0, 20 ) )

        // DebugDrawBox( nav_area.GetCenter(), hull_trace.hullmin, hull_trace.hullmax, spawn_area ? 0 : 255, spawn_area ? 255 : 0, 0, 255, 0.1 )

        local buttons = GetPropInt( player, "m_nButtons" )

        if ( buttons ) {

            // NORMAL GROUND SPAWN
            // snap the spawn point to the nav area center
            if ( spawn_area && buttons & IN_ATTACK && !( buttons & IN_ATTACK2 ) ) {

                for ( local survivor; survivor = FindByClassnameWithin( survivor, "player", tracepos, SUMMON_RADIUS ); )
                    if ( survivor.GetTeam() == TEAM_HUMAN )
                        return ClientPrint( player, HUD_PRINTTALK, "Too close to a survivor!" )

                PZI_SpawnAnywhere.BeginSummonSequence( player, spawn_area.GetCenter() )
            }

            // NEST SPAWN
            // loop through active nests and find the one with the most players nearby
            else if ( buttons & IN_ATTACK2 && PZI_SpawnAnywhere.ActiveNests.len() ) {

                spawn_nests = PZI_SpawnAnywhere.ActiveNests.keys().filter( @( nest ) PZI_SpawnAnywhere.ActiveNests[nest].last_takedamage < Time() - 2.0 )

                if ( !spawn_nests.len() ) return

                PZI_SpawnAnywhere.BeginSummonSequence( player, spawn_nests.sort( @( a, b ) a.nearby_players > b.nearby_players )[0].nest_origin )

                return
            }
        }
    }
    scope.ThinkTable.GhostThink <- GhostThink
} )

PZI_EVENT( "player_death", "SpawnAnywhere_PlayerDeath", function( params ) {

    local player = GetPlayerFromUserID( params.userid )

    if ( player.GetTeam() == TEAM_ZOMBIE ) {

        player.RemoveFlag( FL_ATCONTROLS|FL_DUCKING|FL_DONTTOUCH|FL_NOTARGET )
        player.AcceptInput( "DispatchEffect", "ParticleEffectStop", null, null )
        AddThinkToEnt( player, null )
    }
} )



// local spawn_hint_teleporter = CreateByClassname( "obj_teleporter" )
// spawn_hint_teleporter.KeyValueFromString( "targetname", hint_teleporter_name )

// spawn_hint_teleporter.::DispatchSpawn()
// spawn_hint_teleporter.AddEFlags( EFL_NO_THINK_FUNCTION )

// spawn_hint_teleporter.SetSolid( SOLID_NONE )
// spawn_hint_teleporter.SetSolidFlags( FSOLID_NOT_SOLID )
// spawn_hint_teleporter.DisableDraw()

// // spawn_hint_teleporter.SetModel( "models/player/heavy.mdl" )
// SetPropBool( spawn_hint_teleporter, "m_bPlacing", true )
// SetPropInt( spawn_hint_teleporter, "m_fObjectFlags", 2 )
// SetPropEntity( spawn_hint_teleporter, "m_hBuilder", player )

// // SetPropString( spawn_hint_teleporter, "m_iClassname", "__no_distance_text_hack" )
// spawn_hint_teleporter.KeyValueFromString( "classname", "__no_distance_text_hack" )

// local spawn_hint_text = CreateByClassname( "point_worldtext" )

// spawn_hint_text.KeyValueFromString( "targetname", format( "spawn_hint_text%d", player.entindex() ) )
// spawn_hint_text.KeyValueFromString( "message", "Press[Attack] to spawn" )
// spawn_hint_text.KeyValueFromString( "color", "0 0 255 255" )
// spawn_hint_text.KeyValueFromString( "orientation", "1" )
// spawn_hint_text.AcceptInput( "SetParent", "!activator", spawn_hint_teleporter, spawn_hint_teleporter )
// spawn_hint_text.::DispatchSpawn()