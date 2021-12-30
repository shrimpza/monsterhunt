//--[[[[----
// ============================================================
// ClimbZone -- DOESN'T WORK!! DO NOT USE!!
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2002 Kenneth "Shrimp" Watson
//          For more info, http://shrimpworks.za.net
//    Not to be modified without permission from the author
// ============================================================

class ClimbZone expands ZoneInfo;

#exec Texture Import File=textures\MHClimb.pcx Name=MHClimb Mips=Off Flags=2


event ActorEntered( actor Other )
{
	if (Pawn(Other).bIsPlayer)
		Other.SetPhysics(PHYS_Spider);
}


event ActorLeaving( actor Other )
{
	if (Pawn(Other).bIsPlayer)
		Other.SetPhysics(PHYS_Falling);
}

defaultproperties
{
     Texture=Texture'MonsterHunt.MHClimb'
}

//--]]]]----
