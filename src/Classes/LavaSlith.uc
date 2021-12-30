//--[[[[----
// ============================================================
// LavaSlith
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2002 Kenneth "Shrimp" Watson
//          For more info, http://shrimpworks.za.net
//    Not to be modified without permission from the author
// ============================================================

class LavaSlith expands Slith;

#exec TEXTURE IMPORT NAME=LavaSlith FILE=textures\LavaSlith.PCX GROUP=Skins

defaultproperties
{
     CarcassType=Class'MonsterHunt.LavaSlithCarcass'
     RangedProjectile=Class'MonsterHunt.LavaSlithProjectile'
     MultiSkins(0)=Texture'MonsterHunt.Skins.LavaSlith'
}

//--]]]]----
