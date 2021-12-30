//--[[[[----
// ============================================================
// MonsterEvent
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2002 Kenneth "Shrimp" Watson
//          For more info, http://shrimpworks.za.net
//    Not to be modified without permission from the author
// ============================================================

class MonsterEvent expands Triggers;

#exec Texture Import File=textures\MHEvent.pcx Name=MHEvent Mips=Off Flags=2

var() localized string Message;

function Trigger( actor Other, pawn EventInstigator )
{
	BroadcastMessage(Message, true, 'MonsterCriticalEvent');
}

defaultproperties
{
     Texture=Texture'MonsterHunt.MHEvent'
}

//--]]]]----
