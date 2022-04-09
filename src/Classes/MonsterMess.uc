// ============================================================
// MonsterMess
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterMess extends Mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
	local CreatureChunks chunk;
	local MonsterMessChunks hijacker;
	local MonsterMessBloodPool bloodpool;

	bSuperRelevant = 1;

	chunk = CreatureChunks(Other);
	if (chunk != None && !chunk.IsA('MonsterMessChunks')) {
		hijacker = Spawn(class'MonsterMessChunks',,, chunk.Location);
		if (hijacker != None) hijacker.orig = chunk;
		return true;
	}

	if (Other.IsA('CreatureCarcass')) {
		// the location is raised up a little - it seems sometimes the location of some creatures is in the ground?
		bloodpool = Spawn(class'MonsterMessBloodPool',,, Other.Location + vect(0, 20, 0), rot(16384, 0, 0));
		if (bloodpool != None) bloodpool.rescale(Other);
	}

	bSuperRelevant = 0;
	return true;
}

defaultproperties {
}
