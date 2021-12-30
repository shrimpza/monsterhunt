// ============================================================
// MonsterShadow
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterShadow extends Decal;

var vector OldOwnerLocation;
var vector offset;

function AttachToSurface() {
}

simulated event PostBeginPlay() {
	DrawScale = 0.03 * Owner.CollisionRadius;
	if (Owner.IsA('Nali') || Owner.IsA('Slith')) DrawScale *= 0.75;
	if (Owner.IsA('Pupae')) DrawScale = 0.03 * (Owner.CollisionRadius / 2);
}

simulated function Tick(float DeltaTime) {
	local Actor HitActor;
	local Vector HitNormal, HitLocation, ShadowStart, ShadowDir;

	if (Owner == None) return;

	if (OldOwnerLocation == Owner.Location) return;

	OldOwnerLocation = Owner.Location;

	DetachDecal();

	ShadowDir = vect(0.1, 0.1, 0);

	ShadowStart = Owner.Location + Owner.CollisionRadius * ShadowDir;
	HitActor = Trace(HitLocation, HitNormal, ShadowStart - vect(0, 0, 300), ShadowStart, false);

	if (HitActor == None) return;

	SetLocation(HitLocation);
	SetRotation(rotator(HitNormal));
	AttachDecal(10, ShadowDir);
}

defaultproperties {
	MultiDecalLevel=3
	Texture=Texture'Botpack.energymark'
	DrawScale=0.500000
}
