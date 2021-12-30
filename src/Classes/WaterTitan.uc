// ============================================================
// WaterTitan
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class WaterTitan expands Titan;

function SpawnRock() {
	local Projectile Proj;
	local vector X, Y, Z, projStart;
	GetAxes(Rotation, X, Y, Z);
	
	MakeNoise(1.0);
	if (FRand() < 0.4) {
		projStart = Location + CollisionRadius * X + 0.4 * CollisionHeight * Z;
		Proj = spawn(class 'WaterBoulder', self, '', projStart, AdjustAim(1000, projStart, 400, false, true));
		if (Proj != None) Proj.SetPhysics(PHYS_Projectile);
		return;
	}
	
	projStart = Location + CollisionRadius * X + 0.4 * CollisionHeight * Z;
	Proj = spawn(class 'WaterRock', self, '', projStart, AdjustAim(1000, projStart, 400, false, true));
	if (Proj != None) Proj.SetPhysics(PHYS_Projectile);

	projStart = Location + CollisionRadius * X -  40 * Y + 0.4 * CollisionHeight * Z;
	Proj = spawn(class 'WaterRock', self, '', projStart, AdjustAim(1000, projStart, 400, true, true));
	if (Proj != None) Proj.SetPhysics(PHYS_Projectile);

	if (FRand() < 0.2 * skill) {
		projStart = Location + CollisionRadius * X + 40 * Y + 0.4 * CollisionHeight * Z;
		Proj = spawn(class 'WaterRock', self, '', projStart, AdjustAim(1000, projStart, 2000, false, true));
		if (Proj != None) Proj.SetPhysics(PHYS_Projectile);
	}
}

defaultproperties {
	CarcassType=Class'{{package}}.WaterTitanCarcass'
	Style=STY_Translucent
}
