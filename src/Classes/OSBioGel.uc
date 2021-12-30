// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// Olweapons.OSBioGel:decals...
// ============================================================

class OSBioGel extends BioGel;

simulated function SetWall(vector HitNormal, Actor Wall) {
	Super.SetWall(HitNormal, Wall);
	if (Level.NetMode != NM_DedicatedServer && class'{{package}}.uiweapons'.default.busedecals)
		spawn(class'BioMark', ,, Location, rotator(SurfaceNormal));
}

defaultproperties {
}
