// ============================================================
// LavaSlith
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class LavaSlith expands Slith;

#exec TEXTURE IMPORT NAME=LavaSlith FILE=textures\LavaSlith.PCX GROUP=Skins

defaultproperties {
	CarcassType=Class'{{package}}.LavaSlithCarcass'
	RangedProjectile=Class'{{package}}.LavaSlithProjectile'
	MultiSkins(0)=Texture'{{package}}.Skins.LavaSlith'
}
