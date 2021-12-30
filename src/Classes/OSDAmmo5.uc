// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.OSDAmmo5: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// ============================================================

class OSDAmmo5 extends DAmmo5;

simulated function PostBeginPlay() { //decals or no decals?
	Super.PostBeginPlay();
	if (class'{{package}}.uiweapons'.default.busedecals)
		ExplosionDecal=Class'Botpack.energyimpact';
	else
		ExplosionDecal=None;
}

defaultproperties {
}
