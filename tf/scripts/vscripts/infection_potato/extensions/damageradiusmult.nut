const RADIUS = 256
const MIN = 0.5
const MAX = 2.5
const DMG_ADD_PER_PLAYER = 0.25
const UPDATE_INTERVAL = 1.0

//not using this one because we need the multiplier value for other things (hud elements etc)
//update the multiplier on a fixed interval think on each player to read back later
// ZI_EventHooks.AddRemoveEventHook("OnTakeDamage", "DamageRadiusMult_OnTakeDamage", function(params) {

//     local victim = params.const_entity

//     if (victim.IsPlayer() && victim.GetTeam() == TF_TEAM_RED)
//     {
//         local dmg_mult = MIN

//         for (local survivor; survivor = FindByClassnameWithin(survivor, "player", victim.GetOrigin(), RADIUS);)
//         {
//             if (dmg_mult >= MAX)
//             {
//                 dmg_mult = MAX
//                 break
//             }

//             if (survivor.GetTeam() == TF_TEAM_RED && survivor != victim)
//                 dmg_mult += DMG_ADD_PER_PLAYER
//         }
//         params.damage *= dmg_mult
//     }
// })

ZI_EventHooks.AddRemoveEventHook("player_spawn", "DamageRadiusMult_OnPlayerSpawn", function(params) {

    local player = GetPlayerFromUserID(params.userid)

    if (player.GetTeam() != TF_TEAM_RED) return

    local scope = player.GetScriptScope()
    local dmg_mult = MIN
    local cooldown_time = 0.0

    for (local survivor; survivor = FindByClassnameWithin(survivor, "player", player.GetOrigin(), RADIUS);)
    {
        if (dmg_mult >= MAX)
            break

        if (survivor.GetTeam() == TF_TEAM_RED && survivor != player)
            dmg_mult += DMG_ADD_PER_PLAYER
    }

    // scope.DmgMult <- dmg_mult > MAX ? MAX : dmg_mult
    scope.DmgMult <- dmg_mult

    scope.ThinkTable.DamageRadiusMult <-  function() {

        if (Time() < cooldown_time)
            return

        local _dmg_mult = MIN

        for (local survivor; survivor = FindByClassnameWithin(survivor, "player", player.GetOrigin(), RADIUS);)
        {
            if (_dmg_mult >= MAX)
                break

            if (survivor.GetTeam() == TF_TEAM_RED && survivor != player)
                _dmg_mult += DMG_ADD_PER_PLAYER
        }

        ClientPrint(player, HUD_PRINTCENTER, "Damage multiplier: " + _dmg_mult)
        // scope.DmgMult <- _dmg_mult > MAX ? MAX : _dmg_mult
        scope.DmgMult <- _dmg_mult

        cooldown_time = Time() + UPDATE_INTERVAL
    }
})

ZI_EventHooks.AddRemoveEventHook("OnTakeDamage", "DamageRadiusMult_OnTakeDamage", function(params) {

    local victim = params.const_entity

    if (IsPlayerABot(victim)) return

    if (victim.IsPlayer() && victim.GetTeam() == TF_TEAM_RED)
        params.damage *= victim.GetScriptScope().DmgMult

})