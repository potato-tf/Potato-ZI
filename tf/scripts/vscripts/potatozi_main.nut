// add extensions to this table.
// extensions will be loaded in the order they are defined.
::PZI_ACTIVE_EXTENSIONS <- [
    {"infection_potato/extensions/spawnanywhere"    : null } // single file
    {"infection_potato/extensions/bots"             : null }
    {"infection_potato/extensions/damageradiusmult" : null }
    // { "infection_potato/extensions/example/"         : [ "misc", "navmesh", "potatozi" ] } // multiple files in the example dir
]

::ROOT <- getroottable()

try { PZI_Events.ClearEvents( null ) } catch( e ) {}

for ( local ent; ent = Entities.FindByName( ent, "__pzi*" ); )
    EntFireByHandle( ent, "Kill", "", -1, null, null )

Convars.SetValue( "mp_restartgame", 3 )
ClientPrint( null, 3, "[PZI] GAMEMODE RELOADED, RESTARTING..." )
ClientPrint( null, 4, "[PZI] GAMEMODE RELOADED, RESTARTING..." )
EntFire( "player", "RunScriptCode", "self.AddFlag( FL_FROZEN ); AddThinkToEnt( self, null ); self.TerminateScriptScope()" )
EntFire( "player", "RunScriptCode", "self.RemoveFlag( FL_FROZEN )", 4 )

if ( "PZI_GameStrings" in ROOT )
    PZI_GameStrings.StringTable[ "self.AddFlag( FL_FROZEN ); AddThinkToEnt( self, null ); self.TerminateScriptScope()" ] <- "self.RemoveFlag( FL_FROZEN )"

try { delete ::PZI_CREATE_SCOPE } catch( e ) {}

local function Include( script ) { try { IncludeScript( format( "%s", script ), ROOT ) } catch( e ) { printl( e ); ClientPrint( null, 3, e ) } }

// load core files
local include = [

    {"infection_potato/util/" : [ "constants", "itemdef_constants", "item_map", "create_scope", "event_wrapper", "gamestrings", "util" ] } 
    {"infection_potato/"      : [ "strings", "const", "infection" ] } // bug with util ents being deleted too early
    {"infection_potato/map_logic/" : [ "mapstripper_main" ] }

].extend( PZI_ACTIVE_EXTENSIONS ) // load extensions after

local function IncludeGen( include ) {

    foreach ( inc in include )

        foreach ( dir, files in inc || {} )

            foreach ( i, file in files || [""] ) {

                Include( format( "%s%s", dir, file ) )

                if ( "PZI_GameStrings" in ROOT )

                    PZI_GameStrings.StringTable[ format( "%s%s", dir, file ) ] <- null

                yield file

            }
}

local gen = IncludeGen( include )
while ( gen.getstatus() != "dead" )
    resume gen

// IncludeGen( include )