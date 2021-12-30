// ============================================================
// MonsterEvent
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterEvent expands Triggers;

#exec Texture Import File=textures\MHEvent.pcx Name=MHEvent Mips=Off Flags=2

var() localized string Message;

function Trigger(actor Other, pawn EventInstigator) {
	BroadcastMessage(Message, true, 'MonsterCriticalEvent');
}

defaultproperties {
	Texture=Texture'{{package}}.MHEvent'
}
