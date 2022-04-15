// ============================================================
// MonsterMessChunks
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterMessChunks extends CreatureChunks;

var CreatureChunks orig; // the original chunk we're going to duplicate
var bool initialised;

simulated function Landed(vector HitNormal) {
	local MonsterMessSplat splat;

	super.Landed(HitNormal);

	if ((Level.NetMode != NM_DedicatedServer)) {
		if (!Level.bDropDetail || (FRand() < 0.8)) {
			splat = Spawn(class'MonsterMessSplat',,, Location, rotator(HitNormal));
			if (splat != None) splat.rescale(Self);
		}
	}
}

simulated function HitWall(vector HitNormal, actor Wall) {
	local MonsterMessSplat splat;

	super.HitWall(HitNormal, Wall);

	if ((Level.NetMode != NM_DedicatedServer)) {
		if (!Level.bDropDetail || (FRand() < 0.75)) {
			splat = Spawn(class'MonsterMessSplat',,, Location, rotator(HitNormal));
			if (splat != None) splat.rescale(Self);
		}
	}
}

simulated function Tick(float delta) {
	// we're effectively polling here, until something sets the original chunk
	// once set, we'll replace the original chunk, and destroy it, then the
	// polling will stop
	if (orig == None || initialised) return;

	if (orig.velocity != vect(0, 0, 0) || orig.CarcassClass != None) {
		HijackChunk();
		initialised = true;
		Disable('Tick');
	}
}

/*
	Copies the properties of an existing chunk and simulates the calls made to
	CreatureChunks by CreatureCarcass when chunked.
*/
function HijackChunk() {
	// things the carcass sets
	TrailSize = orig.TrailSize;
	Mesh = orig.Mesh;
	bMasterChunk = orig.bMasterChunk;

	// things InitFor sets
	PlayerOwner = orig.PlayerOwner;
	bDecorative = false;
	DrawScale = orig.DrawScale;
	SetCollisionSize(orig.CollisionRadius, orig.CollisionHeight);
	RotationRate = orig.RotationRate;
	Velocity = orig.Velocity;

	if (bMasterChunk) {
		// stuff from SetAsMaster
		CarcassClass = orig.CarcassClass;
		CarcassAnim = orig.CarcassAnim;
		CarcLocation = orig.CarcLocation;
		CarcHeight = orig.CarcHeight;
	}

	bGreenBlood = orig.bGreenBlood;
	Buoyancy = orig.Buoyancy;

	Bugs = orig.Bugs;
	if (Bugs != None)	Bugs.SetBase(self);

	orig.Destroy();
}

defaultproperties {
}
