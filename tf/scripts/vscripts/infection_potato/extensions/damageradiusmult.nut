local DMG_MULT_RADIUS = 256
local DMG_MULT_MIN = 0.5
local DMG_MULT_MAX = 2.5
local DMG_MULT_PER_PLAYER = 0.25
local UPDATE_INTERVAL = 1.0

PZI_EVENT("player_spawn", "DamageRadiusMult_OnPlayerSpawn", function(params) {

    local player = GetPlayerFromUserID(params.userid)

    if (player.GetTeam() != TF_TEAM_RED) return

    PlayerScope <- player.GetScriptScope()
    local dmg_mult = DMG_MULT_MIN
    local cooldown_time = 0.0

    for (local survivor; survivor = FindByClassnameWithin(survivor, "player", player.GetOrigin(), DMG_MULT_RADIUS);)
    {
        if ( dmg_mult >= DMG_MULT_MAX )
            break

        if ( survivor.GetTeam() == TF_TEAM_RED && survivor != player )
            dmg_mult += DMG_MULT_PER_PLAYER
    }

    // scope.DmgMult <- dmg_mult > DMG_MULT_MAX ? DMG_MULT_MAX : dmg_mult
    PlayerScope.DmgMult <- dmg_mult

    function PlayerScope::ThinkTable::DamageRadiusMult() {

        if ( Time() < cooldown_time )
            return

        local _dmg_mult = DMG_MULT_MIN

        for ( local survivor; survivor = FindByClassnameWithin( survivor, "player", player.GetOrigin(), DMG_MULT_RADIUS ); )
        {
            if (_dmg_mult >= DMG_MULT_MAX)
                break

            if (survivor.GetTeam() == TF_TEAM_RED && survivor != player)
                _dmg_mult += DMG_MULT_PER_PLAYER
        }

        ClientPrint( player, HUD_PRINTCENTER, "Damage multiplier: " + _dmg_mult )
        // DmgMult <- _dmg_mult > DMG_MULT_MAX ? DMG_MULT_MAX : _dmg_mult
        DmgMult = _dmg_mult

        cooldown_time = Time() + UPDATE_INTERVAL
    }
})

PZI_EVENT( "OnTakeDamage", "DamageRadiusMult_OnTakeDamage", function(params) {

    local victim = params.const_entity
    local victim_scope = PZI_Util.GetEntScope(victim)

    if ( victim.IsPlayer() && victim.GetTeam() == TF_TEAM_RED && "DmgMult" in victim_scope )
        params.damage *= victim_scope.DmgMult

})