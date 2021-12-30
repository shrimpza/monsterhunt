//--[[[[----
//=============================================================
// MonsterReplicationInfo
//=============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2002 Kenneth "Shrimp" Watson
//          For more info, http://shrimpworks.za.net
//    Not to be modified without permission from the author
// ============================================================

class MonsterReplicationInfo expands TournamentGameReplicationInfo;

var bool bUseLives;
var bool bUseTeamSkins;
var int Lives;
var int Monsters;
var int Hunters;

replication
{
	reliable if ( Role == ROLE_Authority )
		Lives, Monsters, bUseLives, bUseTeamSkins, Hunters;
}

defaultproperties
{
}

//--]]]]----
