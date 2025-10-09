PZI_CREATE_SCOPE( "__pzi_bots", "PZI_Bots", "PZI_BotSpawner", "PZI_BotSpawnerThink" )

PZI_Bots.NAV_SNIPER_SPOT_FACTOR <- 3 // higher value = lower chance.  1/3 chance to be a sniper spot
PZI_Bots.NAV_SENTRY_SPOT_FACTOR <- 8 // higher value = lower chance.  1/8 chance to be a sentry spot
PZI_Bots.MAX_THREAT_DISTANCE <- 64.0

PZI_Bots.RandomLoadouts <- {

    [TF_CLASS_SCOUT] = {

		[SLOT_PRIMARY] = [

			"The Soda Popper",
			"The Shortstop",
			"The Force-a-Nature"
		],

		[SLOT_SECONDARY] = [

			"The Winger",
			"Pretty Boy's Pocket Pistol",
			"Mad Milk",
			"Crit-a-Cola",
			"The Flying Guillotine"
		],

		[SLOT_MELEE] = [

			"The Candy Cane",
			"The Fan O'War",
			"The Atomizer",
			"Unarmed Combat",
			"The Holy Mackerel"
		]
	},

    [TF_CLASS_SOLDIER] = {

		[SLOT_PRIMARY] = [

			"The Original",
			"The Liberty Launcher",
			"The Black Box",
			"The Direct Hit"
		],

		[SLOT_SECONDARY] = [

			"Panic Attack Shotgun",
			"The Reserve Shooter",
			"The Buff Banner",
			"The Concheror",
			"The Battalion's Backup"
		],

		[SLOT_MELEE] = [

			"The Disciplinary Action",
			"The Equalizer",
			"The Escape Plan",
			"The Pain Train",
			"The Half-Zatoichi"
		]
	},

	[TF_CLASS_PYRO] = {

		[SLOT_PRIMARY] = [

			"The Backburner",
			"The Degreaser",
			"The Nostromo Napalmer",
			"The Dragon's Fury"
		],

		[SLOT_SECONDARY] = [

			"The Flare Gun",
			"The Scorch Shot",
			"The Detonator",
			"The Manmelter",
			"The Reserve Shooter",
			"Panic Attack Shotgun",
			"The Thermal Thruster"
		],

		[SLOT_MELEE] = [

			"The Third Degree",
			"The Hot Hand",
			"The Back Scratcher",
			"The Homewrecker",
			"The Maul",
			"The Powerjack",
			"The Axtinguisher"
		]
	},

    [TF_CLASS_DEMOMAN] = {

		[SLOT_PRIMARY] = [

			"The Iron Bomber",
			"The Loch-n-Load",
			"Ali Baba's Wee Booties",
			"The Bootlegger"
		],

		[SLOT_SECONDARY] = [

			"The Scottish Resistance",
			"The Quickiebomb Launcher",
			"The Chargin' Targe",
			"The Tide Turner",
			"The Splendid Screen"
		],

		[SLOT_MELEE] = [

			"The Scottish Handshake",
			"The Eyelander",
			"The Scotsman's Skullcutter",
			"The Half-Zatoichi",
			"The Claidheamohmor",
			"The Persian Persuader",
			"The Ullapool Caber"
		]
	},

    [TF_CLASS_HEAVYWEAPONS] = {

		[SLOT_PRIMARY] = [

			"Natascha",
			"Tomislav",
			"The Brass Beast",
			"The Huo Long Heatmaker"
		],

		[SLOT_SECONDARY] = [

			"The Family Business",
			"Panic Attack Shotgun",
			"The Sandvich",
			"Fishcake",
			"The Dalokohs Bar",
			"The Second Banana"
		],

		[SLOT_MELEE] = [

			"The Killing Gloves of Boxing",
			"Gloves of Running Urgently",
			"Gloves of Running Urgently MvM",
			"The Eviction Notice",
			"Fists of Steel",
			"The Holiday Punch",
			"The Apoco-Fists"
		]
	},

	[TF_CLASS_ENGINEER] = {

		[SLOT_PRIMARY] = [
			"The Rescue Ranger",
			"The Frontier Justice",
			"The Pomson 6000",
			"The Widowmaker",
			"Panic Attack Shotgun"
		],

		[SLOT_SECONDARY] = [
			"The Short Circuit"
		],

		[SLOT_MELEE] = [

			"The Eureka Effect",
			"The Jag",
			"The Gunslinger",
			"The Southern Hospitality"
		]
	},

	[TF_CLASS_MEDIC] = {

		[SLOT_PRIMARY] = [

			"The Crusader's Crossbow",
			"The Blutsauger",
			"The Overdose"
		],

		[SLOT_SECONDARY] = [

			"The Kritzkrieg",
			"The Vaccinator",
			"The Quick-Fix",
		],

		[SLOT_MELEE] = [
			"The Amputator",
			"The Ubersaw",
			"The Vita-Saw"
		]
	},

	[TF_CLASS_SNIPER] = {

		[SLOT_PRIMARY] = [

			"The Huntsman",
			"The Fortified Compound",
			"The Sydney Sleeper",
			"The Machina",
			"The Hitmans Heatmaker"
		],

		[SLOT_SECONDARY] = [

			"The Cleaner's Carbine",
			"Jarate",
			"The Darwin's Danger Shield",
			"The Cozy Camper"
		],

		[SLOT_MELEE] = [

			"The Bushwacka",
			"The Tribalman's Shiv",
			"The Shahanshah"
		]
	},


	[TF_CLASS_SPY] = {

		[SLOT_PRIMARY] = [

			"The Ambassador",
			"The L'etranger",
			"The Enforcer",
			"The Diamondback",
		],

		[SLOT_MELEE] = [

			"You Eternal Reward",
			"The Wanga Prick",
			"The Big Earner",
			"The Conniver's Kunai",
			"The Black Rose"
		]
	},

}

PZI_Bots.red_buildings <- {}

PZI_Bots.PZI_PathPoint <- class {

	constructor( area, pos, how ) {

		this.area = area
		this.pos  = pos
		this.how  = how
	}

	area = null
	pos  = null
	how  = null
}

PZI_Bots.PZI_BotBehavior <- class {

	constructor( bot ) {

		this.bot       = bot
		this.scope     = bot.GetScriptScope()
		this.team      = bot.GetTeam()
		this.cur_eye_ang = bot.EyeAngles()
		this.cur_eye_pos = bot.EyePosition()
		this.cur_eye_fwd = bot.EyeAngles().Forward()
		this.locomotion = bot.GetLocomotionInterface()

		this.time = Time()

		this.threat 			= null
        this.threat_dist        = 0.0
		this.threat_time        = 0.0
		this.threat_lost_time   = 0.0
		this.threat_aim_time    = 0.0
		this.threat_behind_time = 0.0
		this.threat_visible     = false
		this.fire_next_time     = 0.0
		this.aim_time           = FLT_MAX
		this.random_aim_time    = 0.0

		this.path_points = []
		this.path_index = 0
		this.path_areas = {}
		this.path_goalpoint = null
		this.path_recompute_time = 0.0

		this.bot_level = bot.GetDifficulty()

		this.navdebug = false
	}

	function GiveRandomLoadout() {

		local botcls = bot.GetPlayerClass()

		foreach ( wepinfo in PZI_Bots.RandomLoadouts[ botcls ] ) {

			foreach ( slot in wepinfo ) {

				local wepname = slot [ RandomInt( 0, slot.len() - 1 ) ]
				local wep = PZI_ItemMap[ wepname ]

				if ( wep.item_class[6] == 'r' ) // tf_wearable-based weapon, use this instead.
					bot.GenerateAndWearItem( wepname )

				else {

					local cls = wep.item_class

					if ( typeof cls == "array" )
						cls = wep.item_class[ wep.animset.find( PZI_Util.Classes[ botcls ] ) ]

					PZI_Util.GiveWeapon( bot, cls, wep.id )
				}
			}
		}
	}
	function IsLookingTowards( target, cos_tolerance ) {

		local to_target = target - bot.EyePosition()
		to_target.Norm()
		local dot = cur_eye_fwd.Dot( to_target )
		return ( dot >= cos_tolerance )
	}

	function IsInFieldOfView( target ) {

		local tolerance = 0.5736 // cos( 110/2 )

		local delta = target.GetOrigin() - cur_eye_pos
		delta.Norm()
		if ( cur_eye_fwd.Dot( target ) >= tolerance )
			return true

		delta = target.GetCenter() - cur_eye_pos
		delta.Norm()
		if ( cur_eye_fwd.Dot( delta ) >= tolerance )
			return true

		delta = target.EyePosition() - cur_eye_pos
		delta.Norm()
		return ( cur_eye_fwd.Dot( delta ) >= tolerance )
	}

	function IsVisible( target ) {

		local trace = {
			start  = bot.EyePosition(),
			end    = target.EyePosition(),
			mask   = MASK_OPAQUE,
			ignore = bot
		}
		TraceLineEx( trace )
		return !trace.hit
	}

	function IsThreatVisible( target ) {
		return IsInFieldOfView( target ) && IsVisible( target )
	}

	function GetThreatDistance( target ) {
		return ( target.GetOrigin() - bot.GetOrigin() ).Length()
	}

	function GetThreatDistanceSqr( target ) {
		return ( target.GetOrigin() - bot.GetOrigin() ).LengthSqr()
	}

    function GetThreatDistance2D( target ) {
        return ( target.GetOrigin() - bot.GetOrigin() ).Length2D()
    }

	function FindClosestThreat( min_dist, must_be_visible = true ) {

		local closest_threat = null
		local closest_threat_dist = min_dist

		foreach ( player in PZI_Util.PlayerArray ) {

			if ( player == bot || !player.IsAlive() || player.GetTeam() == bot.GetTeam() || ( must_be_visible && !IsThreatVisible( player ) ) )
				continue

			local dist = GetThreatDistance( player )
			if ( dist < closest_threat_dist ) {
				closest_threat = player
				closest_threat_dist = dist
			}
		}
		return closest_threat
	}

	function CollectThreats( maxdist = INT_MAX, disguised = false, invisible = false, alive = true ) {

		local threatarray = []
		foreach ( player in PZI_Util.PlayerArray ) {

			if (
				player == bot
				|| player.GetTeam() == bot.GetTeam()
				|| ( !invisible && player.IsFullyInvisible() )
				|| ( !disguised && player.IsStealthed() )
				|| ( alive && player.IsAlive() )
				|| GetThreatDistance( player ) > maxdist
			)
				continue

			threatarray.append( player )
		}
		return threatarray
	}

	function SetThreat( target, visible ) {
		threat = target
		threat_pos = threat.GetOrigin()
		threat_visible = visible
		threat_behind_time = time + 0.5
	}

	function SwitchToBestWeapon() {
		local weapon = bot.GetActiveWeapon()
	}

	function CheckForProjectileThreat() {

		local projectile
		while ( ( projectile = FindByClassname( projectile, STR_PROJECTILES ) ) != null ) {
			if ( projectile.GetTeam() == team || !IsValidProjectile( projectile ) )
				continue

			local dist = GetThreatDistance( projectile )
			if ( dist <= 67000 && IsVisible( projectile ) ) {

				switch ( bot_level ) {
				case 1: // Normal Skill, only deflect if in FOV
					if ( !IsInFieldOfView( projectile ) )
						return
				break

				case 2: // Hard skill, deflect regardless of FOV
					LookAt( projectile.GetOrigin(), INT_MAX, INT_MAX )
				break

				case 3: // Expert skill, deflect regardless of FOV back to Sender
					local owner = projectile.GetOwner()
					if ( owner != null ) {
						// local owner_head = owner.GetAttachmentOrigin( owner.LookupAttachment( "head" ) )
						// LookAt( owner_head, INT_MAX, INT_MAX )
						LookAt( owner.EyePosition(), INT_MAX, INT_MAX )
					}
				break
				}
				bot.PressAltFireButton()
			}
		}
	}

	function LookAt( target_pos, min_rate, max_rate ) {

		local dt  = FrameTime()
		local dir = target_pos - cur_eye_pos
		dir.Norm()
		local dot = cur_eye_fwd.Dot( dir )

		local desired_angles = PZI_Util.VectorAngles( dir )

		local rate_x = PZI_Util.RemapValClamped( fabs( PZI_Util.NormalizeAngle( cur_eye_ang.x ) - PZI_Util.NormalizeAngle( desired_angles.x ) ), 0.0, 180.0, min_rate, max_rate )
		local rate_y = PZI_Util.RemapValClamped( fabs( PZI_Util.NormalizeAngle( cur_eye_ang.y ) - PZI_Util.NormalizeAngle( desired_angles.y ) ), 0.0, 180.0, min_rate, max_rate )

		if ( dot > 0.7 ) {
			local t = PZI_Util.RemapValClamped( dot, 0.7, 1.0, 1.0, 0.05 )
			local d = sin( 1.57 * t ) // pi/2
			rate_x *= d
			rate_y *= d
		}

		cur_eye_ang.x = PZI_Util.NormalizeAngle( PZI_Util.ApproachAngle( desired_angles.x, cur_eye_ang.x, rate_x * dt ) )
		cur_eye_ang.y = PZI_Util.NormalizeAngle( PZI_Util.ApproachAngle( desired_angles.y, cur_eye_ang.y, rate_y * dt ) )

		bot.SnapEyeAngles( cur_eye_ang )
	}

	//260 Hammer Units or 67700 SQR
	function FireWeapon() {
		if ( cur_melee ) {
			if ( threat != null ) {
				threat_dist = GetThreatDistance( threat )
				if ( threat_dist < 128.0 ) // 128
					bot.PressFireButton( 0.2 )
			}

			return true
		}

		if ( fire_next_time > time ) {
			bot.AddBotAttribute( IGNORE_ENEMIES )
			bot.PressFireButton()
			bot.RemoveBotAttribute( IGNORE_ENEMIES )
			return false
		}

		if ( cur_ammo == 0 )
			return false

		local duration     = 0.11
		local velocity_max = 50.0

		if ( 1 )
			if ( cur_vel.Length() < velocity_max )
				bot.PressFireButton( duration )
		else
			fire_next_time = time + RandomFloat( 0.3, 0.6 )

		return true
	}

	function StartAimWithWeapon() {
		if ( aim_time != FLT_MAX )
			return

		bot.PressAltFireButton( INT_MAX )
		aim_time = time
	}

	function EndAimWithWeapon() {
		if ( aim_time == FLT_MAX )
			return

		bot.AddBotAttribute( SUPPRESS_FIRE )
		bot.PressAltFireButton()
		bot.RemoveBotAttribute( SUPPRESS_FIRE )
		aim_time = FLT_MAX
	}

	function OnTakeDamage( params ) {

		if ( params.attacker != null && params.attacker != this && params.attacker.IsPlayer() ) {
			if ( threat != null && threat.IsValid() ) {
				threat_dist = GetThreatDistance( threat ) * 0.8

				if ( threat_dist > 128.0 ) {
					local attacker_dist = GetThreatDistance( params.attacker )
					threat_dist   = GetThreatDistance( threat ) * 0.8

					if ( attacker_dist > threat_dist )
						return
				}
			}

			SetThreat( params.attacker, true )
		}
	}
	function OnUpdate() {

		cur_pos     = bot.GetOrigin()
		cur_vel     = bot.GetAbsVelocity()
		cur_speed   = cur_vel.Length()
		cur_eye_pos = bot.EyePosition()
		cur_eye_ang = bot.EyeAngles()
		cur_eye_fwd = cur_eye_ang.Forward()

		time = Time()

		//SwitchToBestWeapon()
		//DrawDebugInfo()

		return -1
	}
	function FindPathToThreat() {

		if ( path_recompute_time < time ) {

			local threat_cur_pos = threat.GetOrigin()

			if ( ( !path_points.len() ) || ( ( threat_pos - threat_cur_pos ).LengthSqr() > 4096.0 ) ) {

				local area = GetNavArea( threat_cur_pos, 0.0 )
				if ( area != null ) {

					UpdatePathAndMove( threat_cur_pos )
				}

				threat_pos = threat_cur_pos
			}

			path_recompute_time = time + 0.5
		}
	}
	function ResetPath() {

		path_areas.clear()
		path_points.clear()
		path_index = null
		path_recompute_time = 0
	}
	function UpdatePathAndMove( target_pos, lookat = true, turnrate_min = 600, turnrate_max = 1500 ) {

		local dist_to_target = ( target_pos - bot.GetOrigin() ).Length()
        local path_count = path_points.len()

		if ( path_recompute_time < time ) {
			ResetPath()

			local pos_start = bot.GetOrigin()
			local pos_end   = target_pos

			local area_start = GetNavArea( pos_start, 128.0 )
			local area_end   = GetNavArea( pos_end, 128.0 )

			if ( !area_start )
				area_start = GetNearestNavArea( pos_start, 128.0, false, true )
			if ( !area_end )
				area_end   = GetNearestNavArea( pos_end, 128.0, false, true )

			if ( !area_start || !area_end )
				return false
			if ( !GetNavAreasFromBuildPath( area_start, area_end, pos_end, 0.0, team, false, path_areas ) )
				return false
			if ( area_start != area_end && !path_areas.len() )
				return false

			// Construct path_points
			else {
				path_areas["area"+path_areas.len()] <- area_start
				local area = path_areas["area0"]
				local area_count = path_areas.len()

				// Initial run grabbing area center
				for ( local i = 0; i < area_count && area; i++ ) {
					// Don't add a point for the end area
					if ( i > 0 )
						path_points.append( PZI_Bots.PZI_PathPoint( area, area.GetCenter(), area.GetParentHow() ) )

					area = area.GetParent()
				}

				path_points.reverse()
				path_points.append( PZI_Bots.PZI_PathPoint( area_end, pos_end, 9 ) ) // NUM_TRAVERSE_TYPES

				// Go through again and replace center with border point of next area

				for ( local i = 0; i < path_count; i++ ) {

					if ( !( i in path_points) || !(i + 1 in path_points) )
						continue


					local path_from = path_points[i]
					local path_to = ( i < path_count - 1 ) ? path_points[i + 1] : null

					if ( path_to ) {
						local dir_to_from = path_to.area.ComputeDirection( path_from.area.GetCenter() )
						local dir_from_to = path_from.area.ComputeDirection( path_to.area.GetCenter() )

						local to_c1 = path_to.area.GetCorner( dir_to_from )
						local to_c2 = path_to.area.GetCorner( dir_to_from + 1 )
						local fr_c1 = path_from.area.GetCorner( dir_from_to )
						local fr_c2 = path_from.area.GetCorner( dir_from_to + 1 )

						local minarea = {}
						local maxarea = {}
						if ( ( to_c1 - to_c2 ).Length() < ( fr_c1 - fr_c2 ).Length() ) {
							minarea.area <- path_to.area
							minarea.c1 <- to_c1
							minarea.c2 <- to_c2

							maxarea.area <- path_from.area
							maxarea.c1 <- fr_c1
							maxarea.c2 <- fr_c2
						}
						else {
							minarea.area <- path_from.area
							minarea.c1 <- fr_c1
							minarea.c2 <- fr_c2

							maxarea.area <- path_to.area
							maxarea.c1 <- to_c1
							maxarea.c2 <- to_c2
						}

						// Get center of smaller area's edge between the two
						local vec = minarea.area.GetCenter()
						if ( !dir_to_from || dir_to_from == 2 ) { // GO_NORTH, GO_SOUTH
							vec.y = minarea.c1.y
							vec.z = minarea.c1.z
						}
						else if ( dir_to_from == 1 || dir_to_from == 3 ) { // GO_EAST, GO_WEST
							vec.x = minarea.c1.x
							vec.z = minarea.c1.z
						}

						path_from.pos = vec
					}
				}
			}

			// Base recompute off distance to target
			// Every 500hu away increase our recompute time by 0.1s
			local mod = 0.1 * ceil( dist_to_target / 500.0 )
			if ( mod > 1 ) mod = 1

			path_recompute_time = time + mod
		}

		if ( navdebug ) {

			for ( local i = 0; i < path_count; i++ ) {
				if ( i in path_points)
					DebugDrawLine( path_points[i].pos, (i+1 < path_points.len()) ? path_points[i+1].pos : path_points[i].pos, 0, 0, 255, false, 0.075 )
				// else
					// __DumpScope( 0, path_points )
			}
			local area = path_areas["area0"]
			local area_count = path_areas.len()

			for ( local i = 0; i < area_count && area; i++ ) {
				local x = ( ( area_count - i - 0.0 ) / area_count ) * 255.0
				area.DebugDrawFilled( 0, x, 0, 50, 0.075, true, 0.0 )

				area = area.GetParent()
			}
		}

		// if (!(path_index in path_points))
		// 	return

		if ( path_index == null || !(path_index in path_points) )
			path_index = 0

		if ( ( path_points[path_index].pos - bot.GetOrigin() ).Length() < 64.0 ) {
			path_index++
			if ( path_index >= path_count ) {
				ResetPath()
				return
			}
		}

		if ( !(path_index in path_points) )
			__DumpScope( 0, path_points )

		local point = path_points[path_index].pos
		locomotion.Approach( point, 1.0 )
		// locomotion.DriveTo( point )
		// locomotion.FaceTowards( point )

		local look_pos = Vector( point.x, point.y, cur_eye_pos.z )
		if ( lookat )
			if ( threat != null )
				LookAt( look_pos, turnrate_min, turnrate_max )
			else
				LookAt( look_pos, 350.0, 600.0 )

		// calc lookahead point

		// set eyeang based on lookahead
		// set loco on lookahead if no obstacles found
		// if found obstacle, modify loco
	}


	bot   = null
	scope = null
	team  = null
	time  = null

	bot_level   = null
	locomotion = null

	cur_pos     = null
	cur_vel     = null
	cur_speed   = null
	cur_eye_pos = null
	cur_eye_ang = null
	cur_eye_fwd = null
	cur_weapon  = null
	cur_ammo    = null
	cur_melee   = null

	threat             = null
	threat_dist        = null
	threat_time        = null
	threat_lost_time   = null
	threat_aim_time    = null
	threat_behind_time = null
	threat_visible     = null
	threat_pos         = null

	path_points		    = null
	path_index			= null
	path_areas			= null
	path_goalpoint      = null
	path_recompute_time	= null

	fire_next_time  = null
	aim_time        = null
	random_aim_pos  = null
	random_aim_time = null

	cosmetic = null

	navdebug = null
}

function PZI_Bots::PrepareNavmesh() {

	local sniper_chance = PZI_Bots.NAV_SNIPER_SPOT_FACTOR
	local sentry_chance = PZI_Bots.NAV_SENTRY_SPOT_FACTOR

	foreach ( nav in PZI_Util.SafeNavAreas ) {

		if ( nav.IsValidForWanderingPopulation() ) {

			if ( !RandomInt( 0, sniper_chance ) )

				nav.SetAttributeTF( TF_NAV_SNIPER_SPOT )

			else if ( !RandomInt( 0, sentry_chance ) )

				nav.SetAttributeTF( TF_NAV_SENTRY_SPOT )
		}

		// yield nav
	}
}

function PZI_Bots::GenericZombie( bot, threat_type = "closest" ) {

    local cooldown = 0.0
    local threat_cooldown = 5.0

    function GenericZombieThink() {

        if ( !bot.IsAlive() || bot.GetFlags() & FL_FROZEN || ( bot.GetActionPoint() && bot.GetActionPoint().IsValid() ) )
            return

		// for some reason bots don't like to move until they're nudged around a bit
		// if we're stuck just throw us around a bit and hope for the best
		if ( GetRoundState() == GR_STATE_RND_RUNNING && !PZI_BotBehavior.locomotion.IsStuck() && !bot.GetAbsVelocity().Length() )
			bot.ApplyAbsVelocityImpulse( Vector( RandomInt( 30, 60 ), RandomInt( 30, 60 ), RandomInt( 10, 20 ) ) )

        local threat = PZI_BotBehavior.threat

        if ( !threat || !threat.IsValid() || !threat.IsAlive() || threat.GetTeam() == bot.GetTeam() ) {

            if ( threat_type == "closest" && Time() > cooldown ) {

                    PZI_BotBehavior.threat = PZI_BotBehavior.FindClosestThreat( INT_MAX, false )
                    cooldown = Time() + threat_cooldown // find new threat every threat_cooldown seconds
            }
            else if ( threat_type == "random" ) {

                    local threats = PZI_BotBehavior.CollectThreats( INT_MAX, true, true )
                    if ( !threats.len() ) return
                    PZI_BotBehavior.threat = threats[RandomInt( 0, threats.len() - 1 )]
            }
        }
        else {

            local distance = PZI_BotBehavior.GetThreatDistance( threat )

			if ( distance > PZI_Bots.MAX_THREAT_DISTANCE )
				PZI_BotBehavior.UpdatePathAndMove( threat.GetOrigin(), false, 1500, 1500 )

			bot.SetAttentionFocus( threat )
            // else
            //     PZI_BotBehavior.LookAt( threat.EyePosition() - Vector( 0, 0, 20 ), 1500, 1500 )
        }
    }

    PZI_Util.AddThink( bot, GenericZombieThink )
}

function PZI_Bots::GenericSpecial( bot ) {

	function GenericSpecialThink() {

		local threat = PZI_BotBehavior.threat

		if ( !threat || !threat.IsValid())
			return
		else if ( !threat.IsAlive() || threat.GetTeam() == bot.GetTeam() )
			return
		else if ( PZI_BotBehavior.GetThreatDistance( threat ) <= PZI_Bots.MAX_THREAT_DISTANCE * 8 && PZI_BotBehavior.IsThreatVisible( threat ) )
			bot.PressAltFireButton( 1.0 )
	}

	PZI_Util.AddThink( bot, GenericSpecialThink )
}

function PZI_Bots::ScoutZombie( bot ) {

	bot.SetAutoJump( 0.05, 2 )
}

function PZI_Bots::SoldierZombie( bot ) {

	function SoldierZombieThink( bot ) {

		if ( !GetPropEntity( bot, "m_hGroundEntity" ) && GetPropInt( bot, "m_nButtons" ) & IN_BACK ) {

			SetPropInt( bot, "m_afButtonDisabled", IN_BACK )
			SetPropInt( bot, "m_nButtons", ~IN_BACK )
			return
		}

		SetPropInt( bot "m_afButtonDisabled", 0 )
	}
}

function PZI_Bots::MedicZombie( bot ) {

	// heal nearby teammates
    function MedicZombieThink() {

		for (local player; player = FindByClassnameWithin( player, "player", bot.GetOrigin(), MEDIC_HEAL_RANGE );)
			if ( player.GetTeam() == TEAM_ZOMBIE && player.GetHealth() < player.GetMaxHealth() * 0.75 )
				bot.PressAltFireButton( 1.0 )

    }

	PZI_Util.AddThink( bot, MedicZombieThink )
}

function PZI_Bots::EngineerZombie( bot ) {

	local scope 		= PZI_Util.GetEntScope( bot )
	local red_buildings	= PZI_Bots.red_buildings
	scope.building 		<- null

	if ( red_buildings.len() )
		scope.building = red_buildings[RandomInt( 0, red_buildings.len() - 1 )]

	scope.building ? bot.SetBehaviorFlag( 511 ) : bot.ClearBehaviorFlag( 511 )

    function EngineerZombieThink() {

		if ( bot.IsBehaviorFlagSet( 511 ) && building && building.IsValid() )
			return

		if ( !red_buildings.len() ) {

			bot.ClearBehaviorFlag( 511 )
			return
		}

		building = red_buildings[RandomInt( 0, red_buildings.len() - 1 )]

		if ( !building || !building.IsValid() )
			red_buildings = red_buildings.filter( @( k, v ) k && k.IsValid() )
	}

	PZI_Util.AddThink( bot, EngineerZombieThink )
}

PZI_EVENT( "teamplay_round_start", "PZI_Bots_TeamplayRoundStart", function( params ) { EntFire( "__pzi_bots", "CallScriptFunction", "PrepareNavmesh" ) })

PZI_EVENT( "player_spawn", "PZI_Bots_PlayerSpawn", function( params ) {

    local bot = GetPlayerFromUserID( params.userid )

    if ( !IsPlayerABot( bot ) )
		return

	local cls = bot.GetPlayerClass()
    local scope = PZI_Util.GetEntScope( bot )

	if ( cls == TF_CLASS_MEDIC )
		bot.SetMission( NO_MISSION, true )

	else if ( bot.GetTeam() == TEAM_ZOMBIE || cls== TF_CLASS_PYRO || cls == TF_CLASS_SPY )
		bot.SetMission( MISSION_SPY, true )

	else if ( bot.GetTeam() == TEAM_HUMAN ) {

		bot.SetMission( RandomInt( MISSION_SNIPER, MISSION_SPY ), true )

		scope.PZI_BotBehavior.GiveRandomLoadout()
	}

	// give bots infinite ammo
	PZI_Util.ScriptEntFireSafe( bot, "self.AddCustomAttribute( `ammo regen`, 9999.0, -1 )" , 0.1 )
	PZI_Util.ScriptEntFireSafe( bot, "self.AddCustomAttribute( `metal regen`, 9999.0, -1 )", 0.1 )

    scope.PZI_BotBehavior <- PZI_Bots.PZI_BotBehavior( bot )

	function BotThink() {

		if ( !bot.IsAlive() )
			return

		PZI_BotBehavior.OnUpdate()

		// lazy unstuck behavior, just teleport the bot somewhere safe
		if ( PZI_BotBehavior.locomotion.GetStuckDuration() > 10.0 ) {
			local area = bot.GetLastKnownArea()
			if ( area )

				for (local navdir = 0; navdir < NUM_DIRECTIONS; navdir++)
					if ( area.GetAdjacentArea( navdir, 1 ) )
						bot.SetAbsOrigin( area.GetAdjacentArea( navdir, 1 ).GetCenter() )

			else {

				local areas = {}

				GetNavAreasInRadius( bot.GetOrigin(), 128.0, areas )
				if ( areas.len() )
					bot.SetAbsOrigin( areas.values()[RandomInt( 0, areas.values().len() - 1 )].GetCenter() )

				area.MarkAsBlocked( TEAM_ZOMBIE )
			}
		}
	}

	PZI_Util.AddThink( bot, BotThink )

	PZI_Bots.GenericZombie( bot, "closest" )

	local cls = bot.GetPlayerClass()

	if ( cls == TF_CLASS_SCOUT )
		PZI_Bots.ScoutZombie( bot )
	if ( cls == TF_CLASS_SOLDIER )
		PZI_Bots.SoldierZombie( bot )
	else if ( cls == TF_CLASS_MEDIC )
		PZI_Bots.MedicZombie( bot )
	else if ( cls == TF_CLASS_ENGINEER )
		PZI_Bots.EngineerZombie( bot )
	else if ( cls != TF_CLASS_SCOUT && cls != TF_CLASS_HEAVYWEAPONS )
		PZI_Bots.GenericSpecial( bot )

})

PZI_EVENT( "player_builtobject", "PZI_Bots_PlayerBuildObject", function( params ) {

    local building = EntIndexToHScript( params.index )

	if ( !( building in PZI_Bots.red_buildings ) )
		PZI_Bots.red_buildings[building] <- GetPlayerFromUserID( params.userid )
})
