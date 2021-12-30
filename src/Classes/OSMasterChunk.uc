// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.OSMasterChunk: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// ============================================================

class OSMasterChunk extends MasterChunk;

simulated function HitWall(vector HitNormal, actor Wall) {
	if (!bDelayTime) {
		if ((Level.Netmode != NM_DedicatedServer) && (FRand() < 0.5) && class'{{package}}.uiweapons'.default.busedecals)
			Spawn(class'WallCrack', ,, Location, rotator(HitNormal));
	}
	Super.HitWall(HitNormal, Wall);
}

defaultproperties {
}
