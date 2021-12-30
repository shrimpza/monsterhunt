//=============================================================
// MonsterReplicationInfo
//=============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterReplicationInfo expands TournamentGameReplicationInfo;

var bool bUseLives;
var bool bUseTeamSkins;
var int Lives;
var int Monsters;
var int Hunters;

// monster defence
var int MaxEscapees;
var int Escapees;

replication {
	reliable if (Role == ROLE_Authority)
		Lives, Monsters, bUseLives, bUseTeamSkins, Hunters, Escapees;
}

defaultproperties {
}
