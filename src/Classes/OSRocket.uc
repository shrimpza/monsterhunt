// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.OSRocket: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// ============================================================

class OSRocket expands Rocket;

simulated function PostBeginPlay() { //decals or no decals?
	Super.PostBeginPlay();
	if (class'{{package}}.uiweapons'.default.busedecals)
		ExplosionDecal = Class'Botpack.BlastMark';
	else
		ExplosionDecal=None;
}

defaultproperties {
}
