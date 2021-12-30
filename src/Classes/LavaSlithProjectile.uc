// ============================================================
// LavaSlithProjectile
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class LavaSlithProjectile expands SlithProjectile;

function Timer() {
	local BlackSmoke gsp;

	gsp = Spawn(class'BlackSmoke', ,, Location + SurfaceNormal * 9);
	if (i !=-1) {
		if (LightBrightness > 10) LightBrightness -= 10;
		DrawScale = 0.9 * DrawScale;
		gsp.DrawScale = DrawScale * 5;
		i++;
		if (i > 12) Explode(Location, vect(0, 0, 0));
	}
}

function Explode(vector HitLocation, vector HitNormal) {
	HurtRadius(damage * DrawScale, DrawScale * 200, 'burned', MomentumTransfer, HitLocation);
	Destroy();
}

defaultproperties {
	Style=STY_Translucent
	MultiSkins(0)=Texture'UnrealShare.Skins.Jflameball1'
	MultiSkins(1)=Texture'UnrealShare.Skins.Jflameball1'
	LightBrightness=160
	LightHue=21
	LightSaturation=31
}
