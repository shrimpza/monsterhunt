// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.OSRingExplosion2: spawns the decals......
// ============================================================

class OSRingExplosion2 extends RingExplosion2;

simulated function SpawnEffects() {
	super.SpawnEffects();
	if (class'{{package}}.UIweapons'.default.bUseDecals)
		Spawn(class'BigEnergyImpact', ,, ,rot(16384, 0, 0));
}

defaultproperties {
}
