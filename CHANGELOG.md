# Changelog 

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
