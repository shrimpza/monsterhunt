# Changelog 

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
