//--[[[[----
// ============================================================
// MonsterTriggerMarker
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2002 Kenneth "Shrimp" Watson
//          For more info, http://shrimpworks.za.net
//    Not to be modified without permission from the author
// ============================================================

// Doesn't really work, don't use it...
// MonsterWaypoint does what this should have

class MonsterTriggerMarker expands NavigationPoint;

#exec Texture Import File=textures\MHMarker.pcx Name=MHMarker Mips=Off Flags=2

defaultproperties
{
     ExtraCost=800
     bSpecialCost=True
     Texture=Texture'MonsterHunt.MHMarker'
}

//--]]]]----
