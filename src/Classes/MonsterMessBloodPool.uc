// ============================================================
// MonsterMessBloodPool
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterMessBloodPool extends UTBloodPool;

#exec TEXTURE IMPORT NAME=GBloodPool6 GROUP=Blood FILE=Textures\GBloodPool6.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GBloodPool7 GROUP=Blood FILE=Textures\GBloodPool7.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GBloodPool8 GROUP=Blood FILE=Textures\GBloodPool8.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GBloodPool9 GROUP=Blood FILE=Textures\GBloodPool9.pcx LODSET=2

var Texture greenSplats[4];

/*
 Rescales the decal based on properties of the other actor.
*/
function rescale(Actor other) {
	DetachDecal();

	DrawScale = 0.04 * Other.CollisionRadius;

	if (CreatureCarcass(other) != None && CreatureCarcass(other).bGreenBlood) {
		Texture = greenSplats[Rand(4)];
	}

	AttachToSurface();
}

defaultproperties {
	greenSplats(0)=Texture'{{package}}.Blood.GBloodPool6'
	greenSplats(1)=Texture'{{package}}.Blood.GBloodPool7'
	greenSplats(2)=Texture'{{package}}.Blood.GBloodPool8'
	greenSplats(3)=Texture'{{package}}.Blood.GBloodPool9'
}
