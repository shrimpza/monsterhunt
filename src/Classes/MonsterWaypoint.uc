//--[[[[----
// ============================================================
// MonsterWaypoint
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2002 Kenneth "Shrimp" Watson
//          For more info, http://shrimpworks.za.net
//    Not to be modified without permission from the author
// ============================================================

class MonsterWaypoint expands Keypoint;

var(Waypoint) int Position;
var(Waypoint) Actor TriggerItem;
var(Waypoint) Name TriggerEvent1;
var(Waypoint) Name TriggerEvent2;
var(Waypoint) Name TriggerEvent3;
var(Waypoint) Name TriggerEvent4;
var actor TriggerActor1;
var actor TriggerActor2;
var actor TriggerActor3;
var actor TriggerActor4;
var bool bVisited;
var bool bEnabled;

function PostBeginPlay()
{
	local Actor A;

	TriggerActor1 = None;
	TriggerActor2 = None;
	TriggerActor3 = None;
	TriggerActor4 = None;
	ForEach AllActors(class 'Actor', A)
	{
		if ( A.Event == TriggerEvent1)
		{
			if (TriggerActor1 == None)
				TriggerActor1 = A;
		}
		if ( A.Event == TriggerEvent2)
		{
			if (TriggerActor2 == None)
				TriggerActor2 = A;
		}
		if ( A.Event == TriggerEvent3)
		{
			if (TriggerActor3 == None)
				TriggerActor3 = A;
		}
		if ( A.Event == TriggerEvent4)
		{
			if (TriggerActor4 == None)
				TriggerActor4 = A;
		}
	}
}

function Touch( actor Other )
{
	if ( !bVisited && bEnabled && ( Other.IsA('PlayerPawn') || Other.IsA('Bot') ) )
	{
		if ((TriggerActor1 != None) && Other.IsA('Bot'))
		{
			if (TriggerActor1.IsA('Mover'))
				TriggerActor1.Bump(Other);
			TriggerActor1.Trigger(Self, Pawn(Other));
		}
		if ((TriggerActor2 != None) && Other.IsA('Bot'))
		{
			if (TriggerActor2.IsA('Mover'))
				TriggerActor2.Bump(Other);
			TriggerActor2.Trigger(Self, Pawn(Other));
		}
		if ((TriggerActor3 != None) && Other.IsA('Bot'))
		{
			if (TriggerActor3.IsA('Mover'))
				TriggerActor3.Bump(Other);
			TriggerActor3.Trigger(Self, Pawn(Other));
		}
		if ((TriggerActor4 != None) && Other.IsA('Bot'))
		{
			if (TriggerActor4.IsA('Mover'))
				TriggerActor4.Bump(Other);
			TriggerActor4.Trigger(Self, Pawn(Other));
		}
		if ((TriggerItem != None) && Other.IsA('Bot'))
		{
			if (TriggerItem.IsA('Mover'))
				TriggerItem.Bump(Other);
			TriggerItem.Trigger(Self, Pawn(Other));
		}
		MonsterHunt(Level.Game).LastPoint = Position;
		bVisited = True;
		bEnabled = False;
	}
}

defaultproperties
{
     Position=1
     bEnabled=True
     bStatic=False
     Texture=Texture'MonsterHunt.MHMarker'
     CollisionRadius=30.000000
     CollisionHeight=30.000000
     bCollideActors=True
}

//--]]]]----
