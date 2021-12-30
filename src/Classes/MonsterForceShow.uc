//--[[[[----
// ============================================================
// MonsterForceShow
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2002 Kenneth "Shrimp" Watson
//          For more info, http://shrimpworks.za.net
//    Not to be modified without permission from the author
// ============================================================

// OBSOLETE - INCORPORATED INTO MONSTERBASE

class MonsterForceShow expands Mutator;

function bool AlwaysKeep(Actor Other) {
  
	if(Other.IsA('ScriptedPawn')) return true;
	if(Other.IsA('ThingFactory')) return true;
	if(Other.IsA('Spawnpoint')) return true;
	return Super.AlwaysKeep(Other);
}

defaultproperties
{
}

//--]]]]----
