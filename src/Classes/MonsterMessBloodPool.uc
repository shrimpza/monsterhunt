// ============================================================
// MonsterMessBloodPool
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterMessBloodPool extends UTBloodPool;

/*
 Rescales the decal based on properties of the other actor.
*/
function rescale(Actor other) {
	DetachDecal();

	DrawScale = 0.04 * Other.CollisionRadius;

	AttachToSurface();
}

defaultproperties {
}
