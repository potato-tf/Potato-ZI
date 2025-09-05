class TypedOrderedTable {

    constructor( key_type = null, value_type = null ) {

        local table = { length = 0, idx = [] }.setdelegate({

            function _get( key ) {

                if ( key in idx )
                    return idx[ key ].value

                return null
            }

            function _set( key, value ) {

                this.rawset( key, value ) // allow assignment with = instead of <-
            }

            function _newslot( key, value ) {

                if ( key_type && typeof key != key_type ) {
                    Assert(false, format( "Invalid Key Type: %s (Expected: %s)", typeof key, key_type ) )    
                }

                else if ( value_type && typeof value != value_type ) {
                    Assert( false, format("Invalid Value Type: %s (Expected: %s)", typeof value, value_type ) )
                }

                else {

                    idx.append( { key = key, value = value } )
                    length++
                }
            }

            function _delslot( key ) {

                if ( key in idx ) {

                    length--
                    idx.remove( idx[key] )
                }

                table.rawdelete( key )
            }
        })

        return table
    }
}