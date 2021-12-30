// ============================================================
// MonsterDefenceEscape
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterDefenceEscape extends Trigger;

var Texture TeleportEffectTexture;
var Sound EscapeSound;

function Touch(Actor Other) {
	local MonsterHuntDefence MH;

	if (IsRelevant(Other) && Other.IsA('ScriptedPawn')) {
		MH = MonsterHuntDefence(Level.Game);
		if (MH != None) MH.monsterEscaped(ScriptedPawn(Other));
		else log("MonsterDefenceEscape - Touch - MH == None");

		SpawnEffect(Pawn(Other));
		Other.Destroy();
	}
}

simulated function PostBeginPlay() {
	LoopAnim('Teleport', 2.0, 0.0);
}

function SpawnEffect(Pawn other) {
	local actor e;

	e = Spawn(class'TranslocOutEffect', ,, other.location, other.rotation);
	e.Mesh = other.Mesh;
	e.Animframe = other.Animframe;
	e.Animsequence = other.Animsequence;
	e.Texture = TeleportEffectTexture;

	e.PlaySound(EscapeSound, , 10.0);
}

defaultproperties {
	bInitiallyActive=True
	TriggerType=TT_PawnProximity
	CollisionRadius=50
	CollisionHeight=50
	Mesh=LodMesh'Botpack.Tele2'
	MultiSkins(1)=Texture'Botpack.Skins.MuzzyPulse'
	Style=STY_Translucent
	DrawType=DT_Mesh
	DrawScale=1.4
	bUnlit=True
	bHidden=False
	LightType=LT_Pulse
	LightEffect=LE_WateryShimmer
	LightRadius=10
	LightBrightness=255
	LightHue=85
	LightSaturation=127
	LightPeriod=100
	TeleportEffectTexture=Texture'Botpack.Skins.MuzzyPulse'
	EscapeSound=Sound'Botpack.CTF.flagtaken'
}
