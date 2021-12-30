// ============================================================
// MonsterEnd
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterEnd extends Trigger;

#exec Texture Import File=textures\MHEnd.pcx Name=MHEnd Mips=Off Flags=2

function Touch(actor Other) {
	local actor A;
	if (IsRelevant(Other)) {
		if (ReTriggerDelay > 0) {
			if (Level.TimeSeconds - TriggerTime < ReTriggerDelay) return;
			TriggerTime = Level.TimeSeconds;
		}

		if (Event != '') {
			foreach AllActors(class 'Actor', A, Event) A.Trigger(Other, Other.Instigator);
		}

		if (Other.IsA('Pawn') && (Pawn(Other).SpecialGoal == self)) Pawn(Other).SpecialGoal = None;
				
		if (Message != "") Other.Instigator.ClientMessage(Message);

		if (bTriggerOnceOnly) SetCollision(False);
		else if (RepeatTriggerTime > 0) SetTimer(RepeatTriggerTime, false);

		TriggerObjective();
	}
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType) {
	local actor A;

	if (bInitiallyActive && (TriggerType == TT_Shoot) && (Damage >= DamageThreshold) && (instigatedBy != None)) {
		if (ReTriggerDelay > 0) {
			if (Level.TimeSeconds - TriggerTime < ReTriggerDelay) return;
			TriggerTime = Level.TimeSeconds;
		}

		if (Event != '') foreach AllActors(class 'Actor', A, Event) A.Trigger(instigatedBy, instigatedBy);

		if (Message != "") instigatedBy.Instigator.ClientMessage(Message);

		if (bTriggerOnceOnly) SetCollision(False);

		TriggerObjective();
	}
}

function TriggerObjective() {
	local	MonsterHunt	MH;

	MH = MonsterHunt(Level.Game);
	if (MH != None) MH.EndGame("Hunt Successful!");
	else warn("MonsterEnd - TriggerObjective - MH == None");
}

defaultproperties {
	bInitiallyActive=True
	Texture=Texture'{{package}}.MHEnd'
}
