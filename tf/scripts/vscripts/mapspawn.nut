// local hooks = [
//     "stringtofile",
// ]
// local fixes = [

// ]
// foreach (hook in hooks) IncludeScript(format("hooks/%s", hook), this)
// foreach (fix in fixes) IncludeScript(format("fixes/%s", fix), this)
IncludeScript("potatozi")

IncludeScript("infection_potato/util/constants", getroottable())
IncludeScript("infection_potato/util/itemdef_constants", getroottable())
IncludeScript("infection_potato/util/item_map", getroottable())

IncludeScript ("infection_potato/strings", getroottable())
IncludeScript ("infection_potato/const", getroottable())
IncludeScript("infection_potato/util/util", getroottable())
IncludeScript("infection_potato/util/event_hook_table", getroottable())

IncludeScript("spawnanywhere")

IncludeScript("infection_potato/infection")

ZI_EventHooks.CollectEvents()