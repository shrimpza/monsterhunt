//--[[[[----
// ============================================================
// RockTentacle
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2002 Kenneth "Shrimp" Watson
//          For more info, http://shrimpworks.za.net
//    Not to be modified without permission from the author
// ============================================================

class RockTentacle expands Tentacle;

#exec TEXTURE IMPORT NAME=RockTentacle FILE=textures\RockTentacle.PCX GROUP=Skins

defaultproperties
{
     CarcassType=Class'MonsterHunt.RockTentacleCarcass'
     MultiSkins(0)=Texture'MonsterHunt.Skins.RockTentacle'
     MultiSkins(1)=Texture'MonsterHunt.Skins.RockTentacle'
}

//--]]]]----
