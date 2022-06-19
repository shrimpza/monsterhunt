// ============================================================
// MonsterMapScoreExtension
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

/*
 The ScoreExtension provides a means of allowing implementations of custom
 scoring rules.

 The interface of this class is as follows:

	- ScoreKill
		- called when a player kills a monster, returns the intended score adjustment
	- PlayerKilled
		- called when a player is killed, returns a score adjustment

	Other functions should be  considered "private" implementation details of this
	specific implementation, and should be overridden with caution.

	The game and gameReplicationInfo variables should be available after PostBeginPlay.
*/
class MonsterHuntScoreExtension extends MonsterHuntExtension;

var MonsterHunt game;
var GameReplicationInfo gameReplicationInfo;

/**
	Score depending on which monster type the player kills
*/
function int ScoreKill(Pawn killer, Pawn other) {
	local int score;

	// by default, score 1 for all kills
	score = 1;

	if (Other.IsA('Titan') || Other.IsA('Queen') || Other.IsA('WarLord')) score = 5;
	else if (Other.IsA('GiantGasBag') || Other.IsA('GiantManta') || Other.IsA('SkaarjTrooper')) score = 4;
	else if (Other.IsA('SkaarjWarrior') || Other.IsA('MercenaryElite') || Other.IsA('Brute') || Other.IsA('GiantManta')) score = 3;
	else if (Other.IsA('Krall') || Other.IsA('Slith') || Other.IsA('GasBag')) score = 2;
	// Lose points for killing innocent creatures. Shame ;-)
	else if ((Other.IsA('Nali') || Other.IsA('Cow')) && game != None) {
		if (!game.MaybeEvilFriendlyPawn(ScriptedPawn(Other), Killer)) score = -5;
	}

	// Get 10 extra points for killing the boss!!
	if ((ScriptedPawn(Other) != None && ScriptedPawn(Other).bIsBoss)) score = 10;

	return score;
}

function int PlayerKilled(Pawn killer, Pawn other) {
	// suicide, or death by traps
	if (killer == None || killer == Other) return -4;

	// player was killed by a monster
	if (killer.IsA('ScriptedPawn') && Other.bIsPlayer && !MonsterReplicationInfo(GameReplicationInfo).bUseLives) {
		return -5;
	}

	return 0;
}

defaultproperties {
}
