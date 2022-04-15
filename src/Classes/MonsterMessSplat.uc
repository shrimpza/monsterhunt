// ============================================================
// MonsterMessSplat
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterMessSplat extends BloodSplat;

#exec TEXTURE IMPORT NAME=GBloodSplat3 GROUP=Blood FILE=Textures\GBloodSplat3.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GBloodSplat4 GROUP=Blood FILE=Textures\GBloodSplat4.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GBloodSplat5 GROUP=Blood FILE=Textures\GBloodSplat5.pcx LODSET=2
#exec TEXTURE IMPORT NAME=GBloodSplat8 GROUP=Blood FILE=Textures\GBloodSplat8.pcx LODSET=2

var Texture greenSplats[4];

/*
 Rescales the decal based on properties of the other actor.
*/
function rescale(Actor other) {
	DetachDecal();

	DrawScale = 0.025 * Other.CollisionRadius;

	if (CreatureChunks(other) != None && CreatureChunks(other).bGreenBlood) {
		Texture = greenSplats[Rand(4)];
	}

	AttachToSurface();
}

defaultproperties {
	greenSplats(0)=Texture'{{package}}.Blood.GBloodSplat3'
	greenSplats(1)=Texture'{{package}}.Blood.GBloodSplat4'
	greenSplats(2)=Texture'{{package}}.Blood.GBloodSplat5'
	greenSplats(3)=Texture'{{package}}.Blood.GBloodSplat8'
}
