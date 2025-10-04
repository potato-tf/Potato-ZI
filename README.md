# Potato ZI
A custom fork of the Team Fortress 2 Zombie Infection gamemode, modified to run on any map

also includes a custom extension system for adding modifications without needing to significantly alter the core files.  

A few pre-made extensions already exist and are active for the custom spawning and damage logic

## How to Run
1. Merge the `tf/scripts/vscripts/` folder in this repo with your own.
2. Add `script_execute potatozi_main` to your server.cfg/server exec commands
3. (Optional) load custom vscript extensions by adding them to `PZI_ACTIVE_EXTENSIONS` in `potatozi_main.nut`

## Creating Extensions
TODO
