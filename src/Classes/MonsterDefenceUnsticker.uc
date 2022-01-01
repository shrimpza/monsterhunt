// ============================================================
// MonsterDefenceEscape
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

/*
 * This is intended to be spawned and owned by a ScriptedPawn, and
 * when CheckInterval has passed, checks to see whether the owner
 * pawn is still in the same location. If it hasn't moved, it is
 * destroyed. The check is only run once, and this actor is
 * destroyed after the check.
 */
class MonsterDefenceUnsticker extends Actor;

var float CheckInterval;

function PostBeginPlay() {
	SetTimer(CheckInterval, false);
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
  CheckInterval=10.0
	bCollideActors=True
	CollisionRadius=80
	CollisionHeight=50
	DrawType=DT_None
}
