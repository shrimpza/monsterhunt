// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.OSBigBiogel: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// ============================================================

class OSBigBiogel extends BigBiogel;

simulated function SetWall(vector HitNormal, Actor Wall) {
	Super.SetWall(HitNormal, Wall);
	if (Level.NetMode != NM_DedicatedServer && class'{{package}}.uiweapons'.default.busedecals)
		spawn(class'BioMark', ,, Location, rotator(SurfaceNormal));
}

function DropDrip() {
	local BioGel Gel;

	PlaySound(SpawnSound);    // Dripping Sound
	Gel = Spawn(class'OSBioDrop', Pawn(Owner), ,Location - Vect(0, 0, 1) * 10);
	Gel.DrawScale = DrawScale * 0.5;
}

defaultproperties {
}
