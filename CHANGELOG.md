# Changelog 

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
