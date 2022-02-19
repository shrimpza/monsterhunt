//=============================================================
// MonsterReplicationInfo
//=============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterReplicationInfo extends TournamentGameReplicationInfo;

var bool bUseLives;
var bool bUseTeamSkins;
var int Lives;
var int Monsters;
var int Hunters;
var int MonsterSkill;

// objectives
var MonsterHuntObjective objectives[16];

// monster defence
var int MaxEscapees;
var int Escapees;

replication {
	reliable if (Role == ROLE_Authority)
		Lives, Monsters, bUseLives, bUseTeamSkins, Hunters, Escapees, objectives, MonsterSkill;
}

function RegisterObjective(MonsterHuntObjective objective) {
	local MonsterHuntObjective obj;
	local int i, j;
	for (i = 0; i < 16; i++) {
		if (objectives[i] == None) {
			objectives[i] = objective;
			break;
		} else if (objectives[i] == objective) break; // already known
	}

	for (i = 0; i < 16 - 1; i++) {
		if (objectives[i] == None) return;
		for (j = i + 1; j < 16 - i - 1; j++) {
			if (objectives[j] == None) return;
			if (objectives[i].DisplayOrder > objectives[j].DisplayOrder) {
				obj = objectives[j];
				objectives[j] = objectives[i];
				objectives[j+1] = obj;
			}
		}
	}
}

defaultproperties {
}
