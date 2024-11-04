::ZI_EventHooks <- {

    Events = {}
    CompiledEvents = {}

    AddRemoveEventHook = function(event, funcname, func = null, index = "unordered") {

        //remove hook
        if (func == null)
        {
            try
                delete ZI_EventHooks.Events[event][index][funcname]
            catch (e)
                printf("Event hook not found: %s\n", funcname)

            return
        }

        if (!(event in ZI_EventHooks.Events))
            ZI_EventHooks.Events[event] <- {}

        if (!(index in ZI_EventHooks.Events[event]))
            ZI_EventHooks.Events[event][index] <- {}

        ZI_EventHooks.Events[event][index][funcname] <- func

    }

    CollectEvents = function() {

        foreach (event, event_table in ZI_EventHooks.Events)
        {
            local call_order = array(event_table.len() - 1)

            foreach (index, func_table in event_table)
                if (index != "unordered")
                    call_order[index] = func_table

            if ("unordered" in event_table)
                call_order.append(event_table["unordered"])

            local event_string = event == "OnTakeDamage" ? "OnScriptHook_" : "OnGameEvent_"

            ZI_EventHooks.CompiledEvents[format("%s%s", event_string, event)] <- function(params) {

                foreach(tbl in call_order)
                    foreach(name, func in tbl)
                        func(params)
            }
        }

        __CollectGameEventCallbacks(ZI_EventHooks.CompiledEvents)
    }
}

ZI_EventHooks.AddRemoveEventHook("player_death", "FuncNameHereA", function(params) {
    printl(params.userid + " died")
}, 0)
ZI_EventHooks.AddRemoveEventHook("player_death", "FuncNameHereB", function(params) {
    printl(params.userid + " died")
}, 0)
ZI_EventHooks.AddRemoveEventHook("player_death", "FuncNameHere1", function(params) {
    printl(params.userid + " died2")
}, 1)
ZI_EventHooks.AddRemoveEventHook("player_death", "FuncNameHere2", function(params) {
    printl(params.userid + " died3")
}, 2)
ZI_EventHooks.AddRemoveEventHook("player_death", "FuncNameHere3", function(params) {
    printl(params.userid + " died4")
}, 3)
ZI_EventHooks.AddRemoveEventHook("player_death", "FuncNameHere4", function(params) {
    printl(params.userid + " died5")
})

