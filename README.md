# Potato ZI
A custom fork of the Team Fortress 2 Zombie Infection gamemode modified to run on any map using a custom extension system to simplify modification.

## How to Run
1. Merge the `tf/scripts/vscripts/` folder in this repo with your own.
2. Add `script_execute potatozi_init` to your server.cfg/server exec commands
3. (Optional) load custom vscript extensions by adding them to `PZI_ACTIVE_EXTENSIONS` in `potatozi_init.nut`

## Creating Extensions
