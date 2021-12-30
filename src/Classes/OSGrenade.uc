// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.OSGrenade: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// ============================================================

class OSGrenade expands Grenade;

simulated function Explosion(vector HitLocation) {
	local SpriteBallExplosion s;
																																		//makes use of decals and speeding up dedicated servers :D
	BlowUp(HitLocation);
	if (Level.NetMode != NM_DedicatedServer) {
		if (class'{{package}}.uiweapons'.default.busedecals)
		spawn(class'Botpack.BlastMark', ,, ,rot(16384, 0, 0));
			s = spawn(class'SpriteBallExplosion', ,, HitLocation);
		s.RemoteRole = ROLE_None;
	}
	Destroy();
}

defaultproperties {
}
