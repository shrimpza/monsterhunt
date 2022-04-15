// ============================================================
// MonsterDefenceFlare
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterDefenceFlare extends Effects;

#exec Texture Import File=textures\MHDFlare.pcx Name=MHDFlare
#exec Texture Import File=textures\MHDFlare2.pcx Name=MHDFlare2

var bool bScaleMode;

var bool bIncrease;

function SetScaleMode() {
	bScaleMode = true;
	if (bScaleMode) Texture=Texture'{{package}}.MHDFlare2';
}

simulated function Tick(float DeltaTime) {
	if (Level.NetMode != NM_DedicatedServer)	{
		if (bScaleMode) {
			if (bIncrease) DrawScale += 0.7 * DeltaTime;
			else DrawScale -= 0.7 * DeltaTime;

			if (DrawScale >= 1) bIncrease = false;
			else if (DrawScale <= 0.4) bIncrease = true;
			else if (FRand() > 0.975) bIncrease = !bIncrease;
		} else {
			if (bIncrease) ScaleGlow += 1.0 * DeltaTime;
			else ScaleGlow -= 1.0 * DeltaTime;

			if (ScaleGlow >= 1.0) bIncrease = false;
			else if (ScaleGlow <= 0.4) bIncrease = true;
			else if (FRand() > 0.975) bIncrease = !bIncrease;
		}
	}
}

defaultproperties {
	bScaleMode=False
	bIncrease=False
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'{{package}}.MHDFlare'
}
