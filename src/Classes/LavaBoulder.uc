// ============================================================
// LavaBoulder
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

// LavaTitan's throwing rock

class LavaBoulder expands Boulder1;

function SpawnChunks(int num) {
	local int NumChunks, i;
	local LavaRock TempRock;
	local float scale;

	NumChunks = 1 + Rand(num);
	scale = 12 * sqrt(0.52 / NumChunks);
	speed = VSize(Velocity);
	for (i = 0; i < NumChunks; i++) {
		TempRock = Spawn(class'LavaRock');
		if (TempRock != None) TempRock.InitFrag(self, scale);
	}
	InitFrag(self, 0.5);
}

defaultproperties {
	MultiSkins(0)=Texture'UnrealShare.Skins.Jflameball1'
	MultiSkins(1)=Texture'UnrealShare.Skins.Jflameball1'
	MultiSkins(2)=Texture'UnrealShare.Skins.Jflameball1'
	MultiSkins(3)=Texture'UnrealShare.Skins.Jflameball1'
	MultiSkins(4)=Texture'UnrealShare.Skins.Jflameball1'
	MultiSkins(5)=Texture'UnrealShare.Skins.Jflameball1'
	MultiSkins(6)=Texture'UnrealShare.Skins.Jflameball1'
	MultiSkins(7)=Texture'UnrealShare.Skins.Jflameball1'
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=160
	LightHue=21
	LightSaturation=21
	LightRadius=6
}
