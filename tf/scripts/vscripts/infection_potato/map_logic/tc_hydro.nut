// scripts in this folder with the same name as the map will automatically run

// permanently open all doors on tc_hydro
EntFire( "func_door", "Open" )
EntFire( "func_door", "AddOutput", "OnFullyOpen !self:Kill::0:-1" )