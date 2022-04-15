// ============================================================
// MonsterHuntMonsterExtension
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

/*
 The MonsterExtension provides a means of allowing custom implementations of
 various monster attributes and behaviours.

 The interface of this class is as follows:

	- SetPawnDifficulty
		- a static function which allows alternative per-pawn difficulty scaling
	- EvaluatePawns
		- called via timer (approx every 1s) to iterate over all pawns and provide custom behaviours
		- you should not need to re-implement this generally, rather use CoercePawn
	- CoercePawn
		- called from the default EvaluatePawns implementation, per ScriptedPawn, to provide a means
			of altering individual monster behaviour

	Other functions should be  considered "private" implementation details of this
	specific implementation, and should be overridden with caution.

	The game and gameReplicationInfo variables should be available after PostBeginPlay.
*/
class MonsterHuntMonsterExtension extends MonsterHuntExtension
	config(MonsterHunt);

var config int MonsterEvalInterval; // approximate seconds between iterating over the pawns list
var int monsterEvalCounter;

var MonsterHunt game;
var GameReplicationInfo gameReplicationInfo;

static function SetPawnDifficulty(int MonsterSkill, ScriptedPawn S, bool bGameStarted) {
	local float DiffScale;

	if (S == None) return;

	DiffScale = (80 + (MonsterSkill * 10)) / 100;

	S.Health = (S.Health * DiffScale);
	S.SightRadius = (S.SightRadius * DiffScale);
	S.Aggressiveness = (S.Aggressiveness * DiffScale);
	S.ReFireRate = (S.ReFireRate * DiffScale);
	S.CombatStyle = (S.CombatStyle * DiffScale);
	S.ProjectileSpeed = (S.ProjectileSpeed * DiffScale);
	S.GroundSpeed = (S.GroundSpeed * DiffScale);
	S.AirSpeed = (S.AirSpeed * DiffScale);
	S.WaterSpeed = (S.WaterSpeed * DiffScale);

	if (S.IsA('Brute')) Brute(S).WhipDamage = (Brute(S).WhipDamage * DiffScale);
	if (S.IsA('Gasbag')) Gasbag(S).PunchDamage = (Gasbag(S).PunchDamage * DiffScale);
	if (S.IsA('Titan')) Titan(S).PunchDamage = (Titan(S).PunchDamage * DiffScale);
	if (S.IsA('Krall')) Krall(S).StrikeDamage = (Krall(S).StrikeDamage * DiffScale);
	if (S.IsA('Manta')) Manta(S).StingDamage = (Manta(S).StingDamage * DiffScale);
	if (S.IsA('Mercenary')) Mercenary(S).PunchDamage = (Mercenary(S).PunchDamage * DiffScale);
	if (S.IsA('Skaarj')) Skaarj(S).ClawDamage = (Skaarj(S).ClawDamage * DiffScale);
	if (S.IsA('Pupae')) Pupae(S).BiteDamage = (Pupae(S).BiteDamage * DiffScale);
	if (S.IsA('Queen')) Queen(S).ClawDamage = (Queen(S).ClawDamage * DiffScale);
	if (S.IsA('Slith')) Slith(S).ClawDamage = (Slith(S).ClawDamage * DiffScale);
	if (S.IsA('Warlord')) Warlord(S).StrikeDamage = (Warlord(S).StrikeDamage * DiffScale);

	if (!S.IsA('Nali') && !S.IsA('Cow')) {
		if (bGameStarted) S.AttitudeToPlayer = ATTITUDE_Hate;
		else S.AttitudeToPlayer = ATTITUDE_Ignore;
	}
}

function bool MaybeEvilFriendlyPawn(ScriptedPawn Pawn, optional Pawn Other) {
	switch (Pawn.Default.AttitudeToPlayer) {
		case ATTITUDE_Hate:
		case ATTITUDE_Frenzy:
			return true;
		default:
			if (Other != None) {
				switch (Pawn.AttitudeToCreature(Other)) {
					case ATTITUDE_Hate:
					case ATTITUDE_Frenzy:
						return true;
				}
			}
	}
	return false;
}

function EvaluatePawns() {
	local Pawn P;
	local int monsterCount;

	if (game != None && game.bGameEnded) return;

	monsterEvalCounter ++;
	if (monsterEvalCounter < MonsterEvalInterval) return;

	monsterEvalCounter = 0;

	monsterCount = 0;
	for (P = Level.PawnList; P != None; P = P.nextPawn) {
		if (P.IsA('ScriptedPawn') && P.Health >= 1) {
			CoercePawn(ScriptedPawn(P));
			if ((P.IsA('Nali') || P.IsA('Cow')) && !MaybeEvilFriendlyPawn(ScriptedPawn(P))) continue;
			monsterCount ++;
		}
	}

	if (MonsterReplicationInfo(GameReplicationInfo) != None) {
		MonsterReplicationInfo(GameReplicationInfo).Monsters = monsterCount;
	}
}

function CoercePawn(ScriptedPawn pawn) {
	// by default, we implement no special monster behaviours
}

defaultproperties {
	MonsterEvalInterval=1
}
