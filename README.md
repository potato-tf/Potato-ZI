# Potato ZI
A custom fork of the Team Fortress 2 Zombie Infection gamemode modified to run on any map using a custom extension system to simplify modification.

## How to Run
1. Merge the `tf/scripts/vscripts/` folder in this repo with your own.
2. Add `script_execute potatozi_init` to your server.cfg/server exec commands, or simply rename this file to `mapspawn.nut` if you are lazy
    - `mapspawn.nut` will conflict with any other maps that pack this file, this is a non-issue on the current official maps, but your mileage may vary on custom maps.*
3. (Optional) load custom vscript extensions by adding them to `PZI_ACTIVE_EXTENSIONS` in `potatozi_init.nut`

## Creating Extensions
