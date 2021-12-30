// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.OLTazerProj: Decals, decals.....
// ============================================================

class OLTazerProj extends TazerProj;

//allows decals...
function SuperExplosion() {
	local RingExplosion2 r;

	HurtRadius(Damage * 3.9, 240, 'jolted', MomentumTransfer * 2, Location);

	r = Spawn(Class'OSRingExplosion2', ,'', Location, Instigator.ViewRotation);
	r.PlaySound(r.ExploSound, ,20.0, ,1000, 0.6);
	Destroy();
}
simulated function PostBeginPlay() { //decals or no decals?
	Super.PostBeginPlay();
	if (class'{{package}}.uiweapons'.default.busedecals)
		ExplosionDecal = Class'Botpack.EnergyImpact';
	else
		ExplosionDecal = None;
}

defaultproperties {
}
