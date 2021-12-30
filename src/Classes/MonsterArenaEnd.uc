// ============================================================
// MonsterArenaEnd
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

#exec Texture Import File=textures\MAEnd.pcx Name=MAEnd Mips=Off Flags=2

class MonsterArenaEnd expands MonsterEnd;

function TriggerObjective() {
	local MonsterHuntArena MH;

	MH = MonsterHuntArena(Level.Game);
	if (MH != None) MH.EndGame("Arena Cleared!");
	else warn("MonsterArenaEnd - TriggerObjective - MH == None");
}

defaultproperties {
     bInitiallyActive=False
     InitialState=OtherTriggerTurnsOn
     Texture=Texture'MonsterHunt.MAEnd'
     CollisionRadius=15000.000000
     CollisionHeight=15000.000000
}
