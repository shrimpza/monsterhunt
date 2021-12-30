// ============================================================
// MonsterHuntArena
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterHuntArena expands MonsterHunt
	config(MonsterHunt);

defaultproperties {
	GoalTeamScore=500.000000
	StartUpTeamMessage="Welcome to the ultimate arena battle!"
	FragLimit=500
	StartUpMessage="Work with your teammates to overcome the monsters!"
	StartMessage="The battle has begun!"
	GameEndedMessage="Arena Cleared!"
	SingleWaitingMessage="Press Fire to enter the arena."
	MapListType=Class'{{package}}.MonsterArenaMapList'
	MapPrefix="MA"
	BeaconName="MA"
	LeftMessage=" left the arena."
	EnteredMessage=" has entered the arena!"
	GameName="Monster Arena"
	GameReplicationInfoClass=Class'Botpack.TournamentGameReplicationInfo'
}
