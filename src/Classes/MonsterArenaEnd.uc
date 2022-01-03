// ============================================================
// MonsterArenaEnd
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

#exec Texture Import File=textures\MAEnd.pcx Name=MAEnd Mips=Off Flags=2

class MonsterArenaEnd extends MonsterEnd;

function TriggerObjective() {
	SetCollision(False, False, False);
	Level.Game.EndGame("Hunt Successful!");
}

defaultproperties {
	bInitiallyActive=False
	InitialState=OtherTriggerTurnsOn
	Texture=Texture'{{package}}.MAEnd'
	CollisionRadius=15000.000000
	CollisionHeight=15000.000000
}
