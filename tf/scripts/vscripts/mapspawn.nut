// local hooks = [
//     "stringtofile",
// ]
// local fixes = [

// ]
// foreach (hook in hooks) IncludeScript(format("hooks/%s", hook), this)
// foreach (fix in fixes) IncludeScript(format("fixes/%s", fix), this)
local root = getroottable()

local include = [

    "infection_potato/extensions/util/constants",
    "infection_potato/extensions/util/itemdef_constants",
    "infection_potato/extensions/util/item_map",
    "infection_potato/extensions/util/util",

    "infection_potato/strings",
    "infection_potato/const",

    "infection_potato/extensions/potatozi/misc",
    "infection_potato/extensions/potatozi/navmesh",
    "infection_potato/extensions/potatozi",

    "infection_potato/extensions/event_hook_table",
    "infection_potato/extensions/damageradiusmult",
    "infection_potato/extensions/spawnanywhere",
]

foreach (script in include) IncludeScript(script, root)

IncludeScript("infection_potato/infection")

ZI_EventHooks.CollectEvents()