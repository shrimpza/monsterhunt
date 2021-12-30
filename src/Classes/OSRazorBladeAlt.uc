// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.OSRazorBladeAlt: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// ============================================================

class OSRazorBladeAlt expands RazorBladeAlt;

auto state Flying {
	simulated function HitWall (vector HitNormal, actor Wall) {
		super.Hitwall(hitnormal, wall);
		if (class'{{package}}.uiweapons'.default.bUseDecals)
			Spawn(class'WallCrack', ,, Location, rotator(HitNormal));
	}
}

defaultproperties {
}
