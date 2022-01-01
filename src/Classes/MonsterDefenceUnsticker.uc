// ============================================================
// MonsterDefenceEscape
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterDefenceUnsticker extends Actor;

function PostBeginPlay() {
	SetTimer(10.0, false);
}

function Timer() {
	local ScriptedPawn nearby;

  if (Owner == None) return;

	foreach RadiusActors(class'ScriptedPawn', nearby, CollisionRadius, Location) {
		if (nearby == Owner) {
			Owner.Destroy();
			break;
		}
	}

	Destroy();
}

defaultproperties {
  bCollideActors=True
	CollisionRadius=80
	CollisionHeight=50
	DrawType=DT_None
}
