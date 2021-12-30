//--[[[[----
// ============================================================
// MonsterBaseArena
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2002 Kenneth "Shrimp" Watson
//          For more info, http://shrimpworks.za.net
//    Not to be modified without permission from the author
// ============================================================

// OBSOLETE - INCORPORATED INTO MONSTERBASE

class MonsterBaseArena expands MonsterBase;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{

	if ( Other.IsA('Weapon') )
	{
		Weapon(Other).RespawnTime = 3;
	}

	if ( Other.IsA('Ammo') )
	{
		Ammo(Other).RespawnTime = 3;
	}

	bSuperRelevant = 0;
	return true;
}

defaultproperties
{
}

//--]]]]----
