// ============================================================
// MonsterShadow
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterShadow extends Decal
	config(MonsterHunt);

#exec TEXTURE IMPORT NAME=MHShadow FILE=Textures\MHShadow.pcx LODSET=2

var vector OldOwnerLocation;

const ShadowDir = vect(0.1, 0.1, 0);
const ShadowDrop = vect(0, 0, 300);

function AttachToSurface() {
}

simulated event PostBeginPlay() {
	DrawScale = 0.09 * Owner.CollisionRadius;
	if (Owner.IsA('Nali') || Owner.IsA('Slith')) DrawScale *= 1.0;
	if (Owner.IsA('Pupae')) DrawScale = 0.12 * (Owner.CollisionRadius / 2);
}

simulated function Tick(float DeltaTime) {
	local Actor HitActor;
	local Vector HitNormal, HitLocation, ShadowStart;

	if (Owner == None) {
		Destroy();
		return;
	}

	if (OldOwnerLocation == Owner.Location) return;

	OldOwnerLocation = Owner.Location;

	DetachDecal();

	ShadowStart = Owner.Location + Owner.CollisionRadius * ShadowDir;
	HitActor = Trace(HitLocation, HitNormal, ShadowStart - ShadowDrop, ShadowStart, false);

	if (HitActor == None) return;

	SetLocation(HitLocation);
	SetRotation(rotator(HitNormal));
	AttachDecal(10, ShadowDir);
}

defaultproperties {
	MultiDecalLevel=3
	Texture=Texture'MHShadow'
	DrawScale=0.500000
}
