// ============================================================
// RockTentacle
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class RockTentacle extends Tentacle;

#exec TEXTURE IMPORT NAME=RockTentacle FILE=textures\RockTentacle.PCX GROUP=Skins

defaultproperties {
	CarcassType=Class'{{package}}.RockTentacleCarcass'
	MultiSkins(0)=Texture'{{package}}.Skins.RockTentacle'
	MultiSkins(1)=Texture'{{package}}.Skins.RockTentacle'
}
