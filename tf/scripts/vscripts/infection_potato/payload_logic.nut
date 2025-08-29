// --------------------------------------------------------------------------------------- //
// Zombie Infection                                                                        //
// --------------------------------------------------------------------------------------- //
// All Code By: Harry Colquhoun (https://steamcommunity.com/profiles/76561198025795825)    //
// Assets/Game Design by: Diva Dan (https://steamcommunity.com/profiles/76561198072146551) //
// --------------------------------------------------------------------------------------- //
// payload logic                                                                           //
// --------------------------------------------------------------------------------------- //

const PL_NUM_ACTIVE_SPAWNS    = 6;
const PL_PAYLOAD_RETHINK_TIME = 1.5;

if ( GetPropInt( GameRules, "m_nHudType" ) !=  3 )
    return;

::ZombieSpawns  <- [ ];

function initPayload()
{
    local _payload   = Entities.FindByClassname( null, "func_tracktrain" );
    local _teamspawn;

    printl( "** You are running Zombie Infection on a Payload map. Initializing EXPERIMENTAL ZI_PL Logic **" );

    while ( _teamspawn = Entities.FindByClassname( _teamspawn, "info_player_teamspawn" ) )
    {
        if ( _teamspawn != null )
        {
            if ( _teamspawn.GetTeam() == TF_TEAM_BLUE )
            {
                ZombieSpawns.append( _teamspawn );
            }
        }
    }

    ::bIsPayload <- true;
    AddThinkToEnt( _payload, "PayloadThink" );
}

function PayloadThink()
{
    local _payload   = Entities.FindByClassname( null, "func_tracktrain" );

    local _zCount = 0;

    ZombieSpawns.sort( function( a, b )
    {
        return ( a.GetLocalOrigin() - _payload.GetLocalOrigin() ).Length() - ( b.GetLocalOrigin() - _payload.GetLocalOrigin() ).Length();
    } );

    for ( local i = 0; i < ZombieSpawns.len(); i++ )
    {
        if ( _zCount < PL_NUM_ACTIVE_SPAWNS )
        {
            EntFireByHandle( ZombieSpawns[i], "enable", "", 0, null, null );
            _zCount++;
        }
        else
        {
            EntFireByHandle( ZombieSpawns[i], "disable", "", 0, null, null );
        }
    }

    return PL_PAYLOAD_RETHINK_TIME;
}

initPayload();
