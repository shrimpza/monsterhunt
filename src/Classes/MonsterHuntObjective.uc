// ============================================================
// MonsterHuntObjective
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterHuntObjective extends Keypoint;

#exec Texture Import File=textures\MHObjective.pcx Name=MHObjective Mips=Off Flags=2

/**
  Message string displayed on HUD and in broadcasts.
*/
var() localized string Message;
/**
  If true, this objective is set as currently active at game start.
*/
var() bool bInitiallyActive;
/**
  If true, this objective is always shown on the HUD, even when its not active.
*/
var() bool bAlwaysShown;
/**
  If true, this objective will be shown on the HUD even if it's complete.
*/
var() bool bShowWhenComplete;
/**
  If true, will trigger a broadcast message to all players when completed.
*/
var() bool bBroadcastMessage;
/**
  In the case of using an EventSequence, which of those events should be active to consider this objective complete.
*/
var() Name CompletedEvent;
/**
  In the case of multiple concurrently active or bAlwaysShown objectives, the order in which to show them on the HUD.
*/
var() byte DisplayOrder;

// internal state management
var bool bActive;
var bool bCompleted;

function PostBeginPlay() {
	if (MonsterHunt(Level.Game) != None) MonsterHunt(Level.Game).RegisterObjective(Self);

	if (bInitiallyActive) Trigger(None, None);

	Super.PostBeginPlay();
}

function Trigger(Actor Other, Pawn EventInstigator) {
	if (bCompleted) return;

  if (bActive && (CompletedEvent == '' || Tag == CompletedEvent)) bCompleted = True;

  if (!bActive && bBroadcastMessage) BroadcastMessage(Message, true, 'MonsterCriticalEvent');

  bActive = !bActive;
  if (CompletedEvent != '') Tag = CompletedEvent;
}

defaultproperties {
  bAlwaysShown=false
  bShowWhenComplete=true
  bBroadcastMessage=true
  Message="Complete the objective"
  bInitiallyActive=false
  bActive=false
	Texture=Texture'{{package}}.MHObjective'
	bAlwaysRelevant=true
	DisplayOrder=0
}
