// ============================================================
// MonsterWaypoint
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterWaypoint extends Keypoint;

var(Waypoint) int Position;
var(Waypoint) Actor TriggerItem;
var(Waypoint) Name TriggerEvent1;
var(Waypoint) Name TriggerEvent2;
var(Waypoint) Name TriggerEvent3;
var(Waypoint) Name TriggerEvent4;
var(Waypoint) bool bEnabled;

var(Waypoint) ScriptedPawn ArrivalTarget;

var bool bVisited;

function Trigger(actor Other, pawn EventInstigator) {
	bEnabled = !bEnabled;
}

function Touch(actor Other) {
	local Actor A;

  if (bVisited || !bEnabled) return;

	if ((Other.IsA('PlayerPawn') || Other.IsA('Bot'))) {
		if (TriggerEvent1 != '' || TriggerEvent2 != '' || TriggerEvent3 != '' || TriggerEvent4 != '') {
			foreach AllActors(class 'Actor', A) {
				// triggering on 'Event' is technically incorrect, but this is for backward compatibility
				if (TriggerEvent1 != '' && A.Event == TriggerEvent1) {
					if (A.IsA('Mover')) A.Bump(Other);
					A.Trigger(Self, Pawn(Other));
				} else if (TriggerEvent2 != '' && A.Event == TriggerEvent2) {
					if (A.IsA('Mover')) A.Bump(Other);
					A.Trigger(Self, Pawn(Other));
				} else if (TriggerEvent3 != '' && A.Event == TriggerEvent3) {
					if (A.IsA('Mover')) A.Bump(Other);
					A.Trigger(Self, Pawn(Other));
				} else if (TriggerEvent4 != '' && A.Event == TriggerEvent4) {
					if (A.IsA('Mover')) A.Bump(Other);
					A.Trigger(Self, Pawn(Other));
				}
			}
		}

		if ((TriggerItem != None) && Other.IsA('Bot')) {
			if (TriggerItem.IsA('Mover')) TriggerItem.Bump(Other);
			TriggerItem.Trigger(Self, Pawn(Other));
		}

		MonsterHunt(Level.Game).SetLastPoint(Position);
		bVisited = True;
	}
}

defaultproperties {
	Position=1
	bEnabled=True
	bStatic=False
	Texture=Texture'{{package}}.MHMarker'
	CollisionRadius=30.000000
	CollisionHeight=30.000000
	bCollideActors=True
}
