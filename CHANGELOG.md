# Changelog

## 612 to 613
 - Spanish localisation updates (thanks Neon_Knight)
 - German localisation (thanks eGo)
 - Improve monster's ability to find the objective in Monster Defence on smaller maps, maps with movers

## 611 to 612:
 - Deaths via traps reduce the life count, rather than increasing it
 - Performance optimisations for monster shadows

## 610 to 611:
 - Moved logic for several actions into separate "extension" classes:
   - `MonsterHuntScoreExtension`: Allows implementation of custom scoring for monster kills and player deaths  
   - `MonsterHuntBotExtension`: Moves all the bot orders and other checks out of game code, and allows custom behaviour  
   - `MonsterHuntMonsterExtension`: Allows implementation of custom monster skill settings and behaviours
   - These are all configurable on the MonsterHunt gametypes
 - Support for green blood splats in the Monster Mess mutator
 - Fix missing Monster Mess splats in multiplayer clients
 - Improve visual effects of Defence escape portal
 - Reduce occurrences of Enemy AccessNone logs in Defence
 - Fix overlapping lives/ping stats on multiplayer scoreboard
 - Show monster difficulty on multiplayer scoreboard

## 609 to 610:
 - Updated spanish definitions (thanks Neon_Knight)
 - New Mutator - Monster Mess; monster corpses and giblets leave blood splats
 - Unreal ammo and pickup messages appear as UT HUD messages rather than in the chat log
 - Fix positioning of MH HUD icon when growing or shrinking HUD 

## 608 to 609:
 - Properly support `bEnabled` on `MonsterWaypoint`, to allow for more complex AI navigation orchestration
   - waypoint can now be disabled at start, and then triggered to enable (default is enabled)
 - Adjust bot behaviour to try to clear monsters in an area before proceeding to next waypoint
 - Localisation templates and Spanish Localisation (thanks Neon_Knight)
   - Update build scripts/templates to support localised template variables 
 - Optimise `MonsterWaypoint` startup, only do `AllActors` traversal if/when touched and only if events configured
 - Add icons on the scoreboard: 
   - a skull for players with no remaining lives
   - a star "award" at the end for players with no deaths for the whole round
 - Re-worked and improved MH-Revenge]\[ map, included as MH-Revenge]\[-SE
 - Add option to hide objectives on HUD. Can be Set in `User.ini`:
   - under `[MonsterHunt.MonsterHUD]` section, set `bHideObjectives=true` (default is false)

## 607 to 608:
 - Re-worked and improved MH-NaliVillage]\[ map, included as MH-NaliVillage]\[-SE
 - Include monster difficulty in scoreboard footer message
 - Show objectives on scoreboard
 - Reduce volume of objective activated/completed sounds
 - Only include unfriendly creatures in monsters remaining count
 - Tweak levers/waypoints in MH-NaliVillage]\[ map to prevent double-triggering by AI

## 606 to 607:
 - Introduction of support for optional objectives in maps, which can show up on the HUD, and tell players what they need to be doing
 - Cleaned up some chat log kill messaging, and do not show suicide messages as "Player1 killed Player1"
 - Polish pass for MH-Lonely][, fixing bad geometry, general cleanup and visual improvements
 - Added objectives to all standard MH maps

## 605 to 606:
 - Fix incorrect view offsets for U1 weapons making them seem invisible

## 604 to 605:
 - Remove automatically assigning monsters to team
 - Show monster names better, "KrallElite" becomes "Krall Elite" 
 - Grammatically correct escape message

## 603 to 604:
 - Fix saving of game rule settings
 - Refactor scoring implementation, including default scores for more monster types
 - Fix upgrade dispersion pistol (thanks SeriousBuggie)
 - Fix zoom for old rifle (thanks SeriousBuggie)
 - Prevent call endgame if game already ended (thanks SeriousBuggie)
 - Fix destroy shadow for bugged monsters (thanks SeriousBuggie)
 - Fix break broken team skins like Cow and Nali (thanks SeriousBuggie)
 - Refactor Login function to work around bug with triggers in start areas (thanks SeriousBuggie)
 - Fix killing friendly Nalis and Cows, and bots waking up Titans (thanks SeriousBuggie)

## 602 to 603:
 - Decoupled monster difficulty from bot skill - difficulty is its own option on the Rules tab
 - Add configurable Warmup time to Defence, before monsters start spawning
 - Make Defence max escapees configurable in Rules tab
 - Monster attitude to player set in difficulty, rather than when the match starts
 - Better re-trigger prevention for MonsterEnd (thanks sector2111)
 - Removed `MonsterHunt` type-check on `MonsterEnd` triggers, so other gametypes can use them (thanks sector2111)
 - Improved and optimised bot waypoint finding to better support missed waypoints and no waypoints (thanks sector2111)
 - Moved `MonsterReplicationInfo` setup into `InitGameReplicationInfo()` where it should be 
 - New higher resolution graphics for settings tabs
 - Fix missing localisation for player lives ran out message

## 601 to 602:
 - Fix incorrect `UIWeapon` reference in MonsterBase.CheckReplacement
 - Remove NaliRabit from ScriptedPawn checks
 - Do not spawn monster shadows on dedicated servers
 - Implement better difficulty call using GameInfo.IsRelevant, rather than being called from various other places
 - MonsterEnd should only ever trigger once
 - Defence: Better application of orders on monsters, yielding better attack behaviour
 - Defence: Disable Mercenary invulnerability shield
 - Defence: Monsters do not block eachother, so they can navigate across the map better
 - Defence: Monsters which don't move from their starting positions can be killed and recycled
 - Defence: Optimisations to mid-game monster order coercion
 - Defence: Tweaks to several monster spawn probabilities
 - Defence: Localise "... escaped!" message

## 503 to 601:
 - Implement new game type: Monster Defence
   - Played on CTF maps, players must prevent attacking monsters from escaping via the portal that has opened in their base
   - Will only work on CTF maps with reasonable pathing
   - Players lose when the maximum number of allowed monsters has escaped, or all lives have been lost
   - Players win by successfully holding off the monster advance until the time limit
 - Fix numerous "Accessed None" errors in logs related to various assumptions about `bIsPlayer` and `PlayerReplicationInfo` in UT classes
 - Fix bug with RazorJack not being replaced by `OLRazorjack`
 - Fix Monster Arena using the wrong GameReplicationInfo class
 - Improve updates of remaining monsters counter
 - Update HUD info with remaining time, add defence escapees, critical things go red when needed
 - Made many strings localised
 - Various improvements and optimisations where possible
 - Clean up all compiler warnings, remove unused classes
 - Reformat code to conform to cleaner style
