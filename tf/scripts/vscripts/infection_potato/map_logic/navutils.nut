// nav utils for generating navmesh on complex multi-stage maps

PZI_CREATE_SCOPE( "__pzi_nav", "PZI_Nav" )

PZI_Nav.nav_generation_state <- {
	generator = null,
	is_running = false
}

function PZI_Nav::FindWalkablePoints() {

}

function PZI_Nav::NavGenerate( only_this_arena = null ) {

	local player = GetListenServerHost()

	local progress = 0

	if ( !only_this_arena ) {

		local arenas_len = Arenas.len()

		foreach( arena_name, arena in Arenas ) {

			local generate_delay = 0.0
			progress++
			// Process spawn points for current arena
			foreach( spawn_point in arena.SpawnPoints ) {

				generate_delay += 0.01
				EntFireByHandle( player, "RunScriptCode", format( @"
					local origin = Vector( %f, %f, %f )
					self.SetAbsOrigin( origin )
					self.SnapEyeAngles( QAngle( 90, 0, 0 ) )
						SendToConsole( `nav_mark_walkable` )
						printl( `Marking Spawn Point: ` + origin )
				", spawn_point[0].x, spawn_point[0].y, spawn_point[0].z ), generate_delay, null, null )
			}

			// Schedule nav generation for current arena
			EntFire( "bignet", "RunScriptCode", format( @"
				ClientPrint( null, 3, `Areas marked!` )
				ClientPrint( null, 3, `Generating nav...` )
				SendToConsole( `host_thread_mode -1` )
				SendToConsole( `nav_generate_incremental` )
				ClientPrint( null, 3, `Progress: ` + %d +`/`+ %d )
			", progress,arenas_len ), generate_delay + GENERIC_DELAY )

			yield
		}
	} else {

		local arena = Arenas[only_this_arena]
		local generate_delay = 0.0

		foreach( spawn_point in arena.SpawnPoints ) {

			generate_delay += 0.01
			EntFireByHandle( player, "RunScriptCode", format( @"
				local origin = Vector( %f, %f, %f )
				self.SetAbsOrigin( origin )
				self.SnapEyeAngles( QAngle( 90, 0, 0 ) )
					SendToConsole( `nav_mark_walkable` )
					printl( `Marking Spawn Point: ` + origin )
			", spawn_point[0].x, spawn_point[0].y, spawn_point[0].z ), generate_delay, null, null )
		}

		// Schedule nav generation for current arena
		EntFire( "bignet", "RunScriptCode", @"
			ClientPrint( null, 3, `Areas marked!` )
			ClientPrint( null, 3, `Generating nav...` )
			SendToConsole( `host_thread_mode -1` )
			SendToConsole( `nav_generate_incremental` )
		", generate_delay + GENERIC_DELAY )
	}
}

function PZI_Nav::ResumeNavGeneration() {

	if ( nav_generation_state.generator.getstatus() == "dead" )
		return nav_generation_state.is_running = false, null

	resume nav_generation_state.generator
}

function PZI_Nav::CreateNav( only_this_arena = null ) {

	player.SetMoveType( MOVETYPE_NOCLIP, MOVECOLLIDE_DEFAULT )

	if ( !Arenas.len() )
		LoadSpawnPoints()

	AddPlayer( player, Arenas_List[0] )

	player.ValidateScriptScope()
	player.GetScriptScope().NavThink <- function() {
		if ( !GetInt( "host_thread_mode" ) ) {
			ResumeNavGeneration()
		}
		return 1
	}
	AddThinkToEnt( player, "NavThink" )

	// Start generating
	nav_generation_state.generator = NavGenerate( only_this_arena )
	nav_generation_state.is_running = true
}