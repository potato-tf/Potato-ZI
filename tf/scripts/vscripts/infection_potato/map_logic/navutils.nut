// nav utils for generating navmesh on complex multi-stage maps

PZI_CREATE_SCOPE( "__pzi_nav", "PZI_Nav" )

PZI_Nav.nav_generation_state <- {
	generator = null,
	is_running = false
}

PZI_Nav.WalkablePoints <- []

function PZI_Nav::FindWalkablePoints() {

}

function PZI_Nav::NavGenerate( only_this_arena = null ) {

	local player = GetListenServerHost()

	local progress = 0

	local points_len = WalkablePoints.len()

	foreach( point in WalkablePoints ) {

		local generate_delay = 0.0
		progress++
		// Process spawn points for current arena
		foreach( spawn_point in WalkablePoints ) {

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

		", progress, points_len ), generate_delay + GENERIC_DELAY )

		yield
	}
}

function PZI_Nav::ResumeNavGeneration() {

	if ( nav_generation_state.generator.getstatus() == "dead" )
		return nav_generation_state.is_running = false, null

	resume nav_generation_state.generator
}

function PZI_Nav::CreateNav( only_this_arena = null ) {

	player.SetMoveType( MOVETYPE_NOCLIP, MOVECOLLIDE_DEFAULT )

	scope <- player.GetScriptScope() || player.ValidateScriptScope(), player.GetScriptScope()

	function scope::NavThink() {

		if ( !GetInt( "host_thread_mode" ) )
			ResumeNavGeneration()

		return 1

	}
	AddThinkToEnt( player, "NavThink" )

	// Start generating
	nav_generation_state.generator = NavGenerate( only_this_arena )
	nav_generation_state.is_running = true
}