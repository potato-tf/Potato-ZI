PrecacheModel("models/bots/skeleton_sniper/skeleton_sniper.mdl")

::CONST <- getconsttable()
::ROOT <- getroottable()
if (!("ConstantNamingConvention" in ROOT)) {

	foreach(a, b in Constants)
		foreach(k, v in b)
		{
			CONST[k] <- v != null ? v : 0
			ROOT[k] <- v != null ? v : 0
		}
}
const MAX_NAV_VIEW_DISTANCE = 2048
const NEAREST_NAV_RADIUS = 1024
const MAX_SPAWN_DISTANCE = 16384 //NOT HAMMER UNITS, see trace_dist

const SUMMON_ANIM_MULT = 0.7
const SUMMON_HEAL_DELAY = 1.5
const SUMMON_MAX_OVERHEAL_MULT = 1

const PLAYER_HULL_HEIGHT = 82

CONST.HIDEHUD_GHOST <- (HIDEHUD_CROSSHAIR|HIDEHUD_HEALTH|HIDEHUD_WEAPONSELECTION|HIDEHUD_METAL|HIDEHUD_BUILDING_STATUS|HIDEHUD_CLOAK_AND_FEIGN|HIDEHUD_PIPES_AND_CHARGE)
CONST.TRACEMASK <- (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_PLAYERCLIP|CONTENTS_WINDOW|CONTENTS_MONSTER|CONTENTS_GRATE)

foreach(k, v in ::NetProps.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::NetProps[k].bindenv(::NetProps)

foreach(k, v in ::Entities.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::Entities[k].bindenv(::Entities)

foreach(k, v in ::EntityOutputs.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::EntityOutputs[k].bindenv(::EntityOutputs)

foreach(k, v in ::NavMesh.getclass())
	if (k != "IsValid" && !(k in ROOT))
		ROOT[k] <- ::NavMesh[k].bindenv(::NavMesh)

if ("ZI_SpawnAnywhere" in ROOT) delete ::ZI_SpawnAnywhere

::ZI_SpawnAnywhere <- {

    // Convert 3D world coordinates to 2D screen coordinates
    function worldToScreenCoords(objectPos, cameraPos, cameraForward, cameraRight, cameraUp, fovDegrees = 90.0) {
        // Calculate vector from camera to object
        local dirToObject = Vector(
            objectPos.x - cameraPos.x,
            objectPos.y - cameraPos.y,
            objectPos.z - cameraPos.z
        );

        // Calculate forward distance for depth scaling
        local forwardDist = (dirToObject.x * cameraForward.x +
                            dirToObject.y * cameraForward.y +
                            dirToObject.z * cameraForward.z);

        if (forwardDist <= 0.0)  // Behind camera
            return null;

        // Project onto camera plane
        local rightProj = (dirToObject.x * cameraRight.x +
                        dirToObject.y * cameraRight.y +
                        dirToObject.z * cameraRight.z);
        local upProj = (dirToObject.x * cameraUp.x +
                    dirToObject.y * cameraUp.y +
                    dirToObject.z * cameraUp.z);

        // Convert to screen coordinates (0 to 1)
        local fovRad = fovDegrees * PI / 180.0;
        local scale = 1.0 / tan(fovRad / 2.0);

        return Vector(
            0.5 + (rightProj / forwardDist) * scale * 0.5,
            0.5 + (upProj / forwardDist) * scale * 0.5,
            0.0
        );
    }

    // Calculate text scale based on distance
    function calculateTextScale(baseSize, distance, minSize = 0.1, maxSize = 1.0) {
        local scale = baseSize / (distance * distance);
        return scale < minSize ? minSize : (scale > maxSize ? maxSize : scale);
    }

    // Main function to update text entity
    function updateTextEntity(textEntity, objectPos, cameraPos, cameraForward, cameraRight, cameraUp, baseTextSize) {
        // Calculate distance
        local diff = Vector(
            objectPos.x - cameraPos.x,
            objectPos.y - cameraPos.y,
            objectPos.z - cameraPos.z
        );
        local distance = sqrt(diff.x * diff.x + diff.y * diff.y + diff.z * diff.z);

        // Get screen coordinates
        local screenPos = worldToScreenCoords(objectPos, cameraPos, cameraForward, cameraRight, cameraUp);

        if (screenPos != null) {  // If object is in front of camera
            // Update entity position
            textEntity.SetPosition(screenPos.x, screenPos.y);

            // Update text size
            local size = calculateTextScale(baseTextSize, distance);
            textEntity.SetSize(size);
        }
    }
    function SetGhostMode(player) {

        player.GiveZombieCosmetics()

        local scope = player.GetScriptScope()

        SetPropInt(player, "m_nRenderMode", kRenderTransColor)
        SetPropInt(player, "m_clrRender", 0)

        SetPropInt(player, "m_afButtonDisabled", IN_ATTACK2)
        // SetPropFloat(player.GetActiveWeapon(), "m_flNextSecondaryAttack", INT_MAX)

        if (player.GetPlayerClass() == TF_CLASS_PYRO)
            scope.m_iFlags <- ZBIT_PYRO_DONT_EXPLODE

        // scope.playerclass <- player.GetPlayerClass()
        scope.playermodel <- player.GetModelName()

        // player.SetPlayerClass(TF_CLASS_SCOUT)
        // SetPropInt(player, "m_Shared.m_iDesiredPlayerClass", TF_CLASS_SCOUT)

        // player.SetScriptOverlayMaterial("colorcorrection/desaturated.vmt")

        player.AddHudHideFlags(CONST.HIDEHUD_GHOST)

        //full loadout strip
        for (local child = player.FirstMoveChild(); child != null; child = child.NextMovePeer())
            //only delete weapons
            if (child instanceof CBaseCombatWeapon)
                EntFireByHandle(child, "Kill", "", -1, null, null)
            else
                child.DisableDraw()

        // EntFireByHandle(player, "SetForcedTauntCam", "1", -1, null, null)

        EntFireByHandle(player, "RunScriptCode", "self.AddCustomAttribute(`dmg taken increased`, 0, -1)", -1, null, null)
        EntFireByHandle(player, "RunScriptCode", "self.AddCustomAttribute(`move speed bonus`, 5, -1)", -1, null, null)
        EntFireByHandle(player, "RunScriptCode", "self.AddCustomAttribute(`major increased jump height`, 3, -1)", -1, null, null)
        EntFireByHandle(player, "RunScriptCode", "self.AddCustomAttribute(`voice pitch scale`, 0, -1)", -1, null, null)
        // EntFireByHandle(player, "RunScriptCode", "self.AddCustomAttribute(`air dash count`, 10, -1)", -1, null, null) //doesn't work, active weapon only
        player.AddFlag(FL_DONTTOUCH|FL_NOTARGET)
    }

    function BeginSummonSequence(player, origin) {

        local scope = player.GetScriptScope()

        delete scope.ThinkTable.GetValidSpawnPoint
        delete scope.ThinkTable.SummonZombie

        //should already be invis but whatever
        SetPropInt(player, "m_nRenderMode", kRenderTransColor)
        SetPropInt(player, "m_clrRender", 0)

        player.SetOrigin(origin + Vector(0, 0, 20))

        SetPropInt(player, "m_afButtonForced", IN_DUCK)
        SetPropBool(player, "m_Local.m_bDucked", true)
        player.AddFlag(FL_DUCKING|FL_ATCONTROLS)

        player.SetAbsVelocity(Vector())
        player.AcceptInput("SetForcedTauntCam", "1", null, null)
        player.AddCustomAttribute("no_jump", 1, -1)

        local dummy_skeleton = CreateByClassname("funCBaseFlex")

        dummy_skeleton.SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl")
        dummy_skeleton.SetOrigin(origin)
        dummy_skeleton.SetAbsAngles(QAngle(0, player.EyeAngles().y, 0))

        dummy_skeleton.DispatchSpawn()
        dummy_skeleton.ValidateScriptScope()

        SetPropInt(dummy_skeleton, "m_nRenderMode", kRenderTransColor)
        SetPropInt(dummy_skeleton, "m_clrRender", 0)

        // dummy_skeleton.ResetSequence(dummy_skeleton.LookupSequence(format("spawn0%d", RandomInt(2, 7)))) //spawn01 is cursed
        // dummy_skeleton.ResetSequence(dummy_skeleton.LookupSequence("spawn04"))

        local spawn_seq = RandomInt(3, 4)
        local spawn_seq_name = format("spawn0%d", spawn_seq)

        dummy_skeleton.ResetSequence(dummy_skeleton.LookupSequence(spawn_seq_name))
        dummy_skeleton.SetPlaybackRate(SUMMON_ANIM_MULT)

        local dummy_player = CreateByClassname("funCBaseFlex")

        dummy_player.SetModel(scope.playermodel)
        dummy_player.SetOrigin(origin)
        dummy_player.SetSkin(player.GetSkin())
        dummy_player.AcceptInput("SetParent", "!activator", dummy_skeleton, dummy_skeleton)
        SetPropInt(dummy_player, "m_fEffects", EF_BONEMERGE|EF_BONEMERGE_FASTCULL)
        dummy_player.DispatchSpawn()
        player.RemoveCustomAttribute("dmg taken increased")
        player.SetHealth(1)
        player.RemoveHudHideFlags(CONST.HIDEHUD_GHOST)
        player.RemoveFlag(FL_NOTARGET)
        EntFireByHandle(player, "RunScriptCode", "self.AddCond(TF_COND_HALLOWEEN_QUICK_HEAL)", SUMMON_HEAL_DELAY, null, null)

        scope.ThinkTable.SpawnHealEffect <- function() {
            if (player.GetHealth() >= player.GetMaxHealth() * SUMMON_MAX_OVERHEAL_MULT)
            {
                player.RemoveCond(TF_COND_HALLOWEEN_QUICK_HEAL)
                delete scope.ThinkTable.SpawnHealEffect
            }
        }

        //max health attrib is always last
        local attrib = ZOMBIE_PLAYER_ATTRIBS[player.GetPlayerClass()]
        local lastattrib = attrib[attrib.len() - 1]

        player.AddCustomAttribute(lastattrib[0], lastattrib[1], lastattrib[2])

        dummy_skeleton.GetScriptScope().SpawnPlayer <- function() {

            if (!player || !player.IsValid() || GetPropInt(player, "m_lifeState") != LIFE_ALIVE)
            {
                self.Kill()
                return
            }

            //animation finished, "spawn" player
            if (GetPropFloat(self, "m_flCycle") >= 0.99)
            {
                if (!player || !player.IsValid()) return

                SendGlobalGameEvent("hide_annotation", { id = FindByName(null, format("spawn_hint_teleporter_%d", player.entindex())).entindex() })

                player.RemoveFlag(FL_ATCONTROLS|FL_DUCKING|FL_DONTTOUCH|FL_NOTARGET)
                SetPropInt(player, "m_afButtonForced", 0)
                SetPropBool(player, "m_Local.m_bDucked", false)

                SetPropInt(player, "m_nRenderMode", kRenderNormal)
                SetPropInt(player, "m_clrRender", 0xFFFFFFFF)
                player.AcceptInput("SetForcedTauntCam", "0", null, null)

                player.RemoveCustomAttribute("no_jump")
                player.RemoveCustomAttribute("move speed bonus")
                player.RemoveCustomAttribute("major increased jump height")
                player.RemoveCustomAttribute("voice pitch scale")

                player.GiveZombieCosmetics()

                for (local child = player.FirstMoveChild(); child != null; child = child.NextMovePeer())
                    child.EnableDraw()

                if (player.GetPlayerClass() == TF_CLASS_PYRO)
                    scope.m_iFlags = scope.m_iFlags & ~ZBIT_PYRO_DONT_EXPLODE

                SetPropInt(player, "m_afButtonDisabled", 0)
                self.Kill()
                return
            }

            self.StudioFrameAdvance()
            return -1
        }

        AddThinkToEnt(dummy_skeleton, "SpawnPlayer")
    }
}


ZI_EventHooks.AddRemoveEventHook("player_hurt", "SpawnAnywhere_RemoveQuickHeal", function(params) {

    local player = GetPlayerFromUserID(params.userid)

    if (player.InCond(TF_COND_HALLOWEEN_QUICK_HEAL))
        player.RemoveCond(TF_COND_HALLOWEEN_QUICK_HEAL)

})

ZI_EventHooks.AddRemoveEventHook("player_activate", "SpawnAnywhere_PlayerActivate", function(params) { GetPlayerFromUserID(params.userid).ValidateScriptScope() }),

ZI_EventHooks.AddRemoveEventHook("post_inventory_application", "SpawnAnywhere_PostInventoryApplication", function(params) {

    local player = GetPlayerFromUserID(params.userid)

    if (player == null || !player.IsValid()) return

    player.ValidateScriptScope() //temporary solo testing
    local scope = player.GetScriptScope()

    PlayerThink <- ::PlayerThink
    PlayerThink <- PlayerThink.bindenv(scope)

    local items = {
        tracepos = Vector()

        ThinkTable = {
            // "PlayerThink" : PlayerThink
        }

        spawn_nests = []

        spawn_area = null
    }

    foreach(k, v in items)
        scope[k] <- v

    SetPropInt(player, "m_nRenderMode", kRenderNormal)
    SetPropInt(player, "m_clrRender", 0xFFFFFFFF)

    //GHOST MODE LOGIC BEYOND THIS POINT
    if (player.GetTeam() != TF_TEAM_BLUE || GetRoundState() != GR_STATE_RND_RUNNING) return

    ZI_SpawnAnywhere.SetGhostMode(player)

    local hint_teleporter_name = format("spawn_hint_teleporter_%d", player.entindex())

    //don't need this for now
    // local spawn_hint_teleporter = CreateByClassname("obj_teleporter")
    // spawn_hint_teleporter.KeyValueFromString("targetname", hint_teleporter_name)

    // spawn_hint_teleporter.DispatchSpawn()
    // spawn_hint_teleporter.AddEFlags(EFL_NO_THINK_FUNCTION)

    // spawn_hint_teleporter.SetSolid(SOLID_NONE)
    // spawn_hint_teleporter.SetSolidFlags(FSOLID_NOT_SOLID)
    // spawn_hint_teleporter.DisableDraw()

    // // spawn_hint_teleporter.SetModel("models/player/heavy.mdl")
    // SetPropBool(spawn_hint_teleporter, "m_bPlacing", true)
    // SetPropInt(spawn_hint_teleporter, "m_fObjectFlags", 2)
    // SetPropEntity(spawn_hint_teleporter, "m_hBuilder", player)

    // // SetPropString(spawn_hint_teleporter, "m_iClassname", "__no_distance_text_hack")
    // spawn_hint_teleporter.KeyValueFromString("classname", "__no_distance_text_hack")

    local spawn_hint_teleporter = CreateByClassname("move_rope")
    spawn_hint_teleporter.KeyValueFromString("targetname", hint_teleporter_name)
    spawn_hint_teleporter.DispatchSpawn()


    spawn_hint_teleporter = FindByName(null, hint_teleporter_name)

    local spawn_hint_text = CreateByClassname("point_worldtext")

    // spawn_hint_text.KeyValueFromString("targetname", format("spawn_hint_text%d", player.entindex()))
    // spawn_hint_text.KeyValueFromString("message", "Press[Attack] to spawn")
    // spawn_hint_text.KeyValueFromString("color", "0 0 255 255")
    // spawn_hint_text.KeyValueFromString("orientation", "1")
    // spawn_hint_text.AcceptInput("SetParent", "!activator", spawn_hint_teleporter, spawn_hint_teleporter)
    // spawn_hint_text.DispatchSpawn()

    EntFireByHandle(spawn_hint_teleporter, "RunScriptCode", format(@"
        SendGlobalGameEvent(`show_annotation`, {
            text = `Spawn Here!`
            lifetime = -1
            show_distance = true
            visibilityBitfield = 1 << %d
            follow_entindex = self.entindex()
            worldposX = self.GetOrigin().x
            worldposY = self.GetOrigin().y
            worldposZ = self.GetOrigin().z
            id = self.entindex()
        })
    ", player.entindex()), 0.5, null, null)

    scope.ThinkTable.GetValidSpawnPoint <- function() {

        local nav_trace = {

            start = player.EyePosition(),
            end = (player.EyeAngles().Forward() * 65536),
            mask = CONST.TRACEMASK,
            ignore = player
        }

        TraceLineEx(nav_trace)

        if (!nav_trace.hit) return

        scope.tracepos <- nav_trace.pos

        local nav_area = GetNearestNavArea(scope.tracepos, NEAREST_NAV_RADIUS, false, true)

        local hull_trace = {
            start = nav_trace.pos,
            end = nav_trace.pos,
            hullmin = Vector(-24, -24, 20),
            hullmax = Vector(24, 24, 84),
            mask = CONST.TRACEMASK,
            ignore = player
        }

        TraceHull(hull_trace)

        // DebugDrawBox(hull_trace.pos, hull_trace.hullmin, hull_trace.hullmax, 0, 0, 255, 0, 0.1)

        //smooth movement for the annotation instead of snapping
        // spawn_hint_teleporter.KeyValueFromVector("origin", hull_trace.pos + Vector(0, 0, 20))

        if (hull_trace.hit)
        {
            scope.spawn_area <- null
            return
        }
        if (!nav_area || !nav_area.IsFlat()) return

        scope.spawn_area <- nav_area

        spawn_hint_teleporter.KeyValueFromVector("origin", nav_area.GetCenter() + Vector(0, 0, 20))

        // scope.spawn_area.DebugDrawFilled(255, 0, 0, 100, 0.1, false, 0.1)
    }

    scope.ThinkTable.SummonZombie <- function() {

        local buttons = GetPropInt(player, "m_nButtons")

        //NORMAL GROUND SPAWN
        //left or right clicking when no nests are active
        //right clicking will force this behavior instead of spawning at a nest
        local trace_dist = ((player.GetOrigin() - scope.tracepos).Length2DSqr()) * 0.01
        // printl(trace_dist)
        if (
            scope.spawn_area &&
            trace_dist <= MAX_SPAWN_DISTANCE &&

            //force normal spawn if we are right clicking
            ((buttons & IN_ATTACK && !scope.spawn_nests.len()) ||
            (scope.spawn_nests.len() && (buttons & IN_ATTACK2)))
        )
        {
            ZI_SpawnAnywhere.BeginSummonSequence(player, scope.tracepos)
        }

        //NEST SPAWN
        else if (buttons & IN_ATTACK && scope.spawn_nests.len())
        {
            foreach(nest in scope.spawn_nests)
            {
                //find closest nest to RED team
                if (nest.GetOrigin())
                {
                    ZI_SpawnAnywhere.BeginSummonSequence(player, nest.GetCenter())
                    break
                }
            }
        }

        // player.SetOrigin(scope.spawn_area.GetCenter())
    }

    //add ZI thinks last
    scope.ThinkTable.PlayerThink <- PlayerThink

    scope.Think <- function() {

        foreach(name, func in scope.ThinkTable)
            func.call(scope)
        return -1
    }
    AddThinkToEnt(player, "Think")
})

ZI_EventHooks.AddRemoveEventHook("player_death", "SpawnAnywhere_PlayerDeath", function(params) {

    local player = GetPlayerFromUserID(params.userid)
    player.RemoveFlag(FL_ATCONTROLS|FL_DUCKING|FL_DONTTOUCH|FL_NOTARGET)
    player.TerminateScriptScope()
})