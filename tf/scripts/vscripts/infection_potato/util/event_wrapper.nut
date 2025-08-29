PZI_CREATE_SCOPE( "__pzi_eventwrapper", "PZI_Events" )

PZI_Events.EventsPreCollect <- {}
PZI_Events.CollectedEvents  <- {}

if ( !( "TableId" in PZI_Events ) )
    PZI_Events.TableId <- UniqueString( "_Compiled" )

function PZI_Events::_OnDestroy() {

    ClearEvents( null )
    if ( "PZI_EVENT" in ROOT )
        delete ::PZI_EVENT
}

function PZI_Events::AddRemoveEventHook( event, funcname, func = null, index = "unordered", manual_collect = false ) {

    // remove hook
    if ( !func ) {

        if ( event in EventsPreCollect ) {

            // direct index removal
            if ( index in EventsPreCollect[ event ] && funcname in EventsPreCollect[ event ][ index ] )

                delete EventsPreCollect[ event ][ index ][ funcname ]

            // wildcard funcname
            if ( index in EventsPreCollect[ event ] && endswith( funcname, "*" ) )

                foreach( name, func in EventsPreCollect[ event ][ index ] )

                    if ( funcname == "*" || startswith( name, funcname.slice( 0, -1 ) ) )

                        delete EventsPreCollect[ event ][ index ][ name ]

            // invalid index, look for funcname in any index
            else if ( !( index in EventsPreCollect[ event ] ) )

                foreach( idx, func_table in EventsPreCollect[ event ] )

                    if ( funcname in func_table )

                        delete EventsPreCollect[ event ][ idx ][ funcname ]

            // stil nothing, look for funcname in any event
            else

                foreach( e, event_table in EventsPreCollect )

                    foreach( idx, func_table in event_table )

                        if ( funcname in func_table )

                            delete func_table[ funcname ]
        }
        // remove from all EventsPreCollect at a given index
        else if ( event == "*" )

            foreach( e, event_table in EventsPreCollect )

                if ( index in event_table && funcname in event_table[ index ] )

                    delete EventsPreCollect[ e ][ index ][ funcname ]

                else if ( index in event_table && endswith( funcname, "*" ) )

                    foreach( name, func in event_table[ index ] )

                        if ( funcname == "*" || startswith( name, funcname.slice( 0, -1 ) ) )

                            delete event_table[ index ][ name ]
        return
    }

    if ( !( event in EventsPreCollect ) )

        EventsPreCollect[ event ] <- {}

    if ( !( index in EventsPreCollect[ event ] ) )

        EventsPreCollect[ event ][ index ] <- {}

    EventsPreCollect[ event ][ index ][ funcname ] <- func

    // we don't need this internally, feature for external scripts
    // only here if someone wants to register events then collect them manually at a later time
    if ( manual_collect ) return

    PZI_Events.CollectEvents()
}

function PZI_Events::CollectEvents() {

    local old_table = {}
    local old_table_name = format( "_PZI_Events_%s", TableId )

    if ( old_table_name in CollectedEvents )

        old_table = CollectedEvents[ old_table_name ]

    foreach ( event, new_table in EventsPreCollect ) {

        local call_order = array( MAX_EVENT_FUNCTABLES )

        // set up call order
        foreach ( index, func_table in new_table )

            if ( index != "unordered" )

                call_order[ index ] = func_table

        // add unordered events to the end of the call order
        if ( "unordered" in new_table )

            call_order[ call_order.len() - 1 ] = new_table[ "unordered" ]

        // remove deleted events from the existing table
        foreach ( tbl in call_order )

            foreach ( name, func in tbl || {} )

                if ( name in old_table && !( name in new_table ) )

                    delete old_table[ name ]

        local event_string = event == "OnTakeDamage" ? "OnScriptHook_" : "OnGameEvent_"

        // set up hook table
        old_table[ format( "%s%s", event_string, event ) ] <- function( params ) {

            foreach( i, tbl in call_order )

                foreach( name, func in tbl || {} )

                    if ( func )

                        func( params )
        }
    }

    // copy table to new ID
    local new_id = UniqueString( "_Compiled" )
    local new_table_name = format( "_PZI_Events_%s", new_id )

    // old events are copied to new table to preserve existing event hooks
    CollectedEvents[ new_table_name ] <- old_table

    // remove old table
    if ( old_table_name in CollectedEvents )
        delete CollectedEvents[ old_table_name ]

    // update table ID
    TableId = new_id

    // collect new events
    __CollectGameEventCallbacks( CollectedEvents[ new_table_name ] )
}

function PZI_Events::ClearEvents( index = "unordered" ) {

    if (index == null || index == "*" ) {

        PZI_Events.EventsPreCollect <- {}
        PZI_Events.CollectedEvents  <- {}
        return
    }

    PZI_Events.AddRemoveEventHook( "*", "*", null, index )
}

::PZI_EVENT <- PZI_Events.AddRemoveEventHook.bindenv( PZI_Events )