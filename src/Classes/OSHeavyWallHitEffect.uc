// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.OSHeavyWallHitEffect: LOL exact same as the light one....... of course the super calls differently :D
// ============================================================

class OSHeavyWallHitEffect extends HeavyWallHitEffect;

simulated function SpawnEffects() {
	local Actor A;
	local float decision;
	if (Level.NetMode == NM_DedicatedServer) return;

	decision = FRand();
	if (decision < 0.15) PlaySound(sound'ricochet', , 0.5, ,1200, 0.3 + 0.7 * FRand());
	else if (decision < 0.5) PlaySound(sound'Impact1', , 4.0, ,800);
	else if (decision < 0.9) PlaySound(sound'Impact2', , 4.0, ,800);

	if (FRand() < 0.5) {
		A = spawn(class'Chip');
		if (A != None) A.RemoteRole = ROLE_None;
	}
	if (FRand() < 0.5) {
		A = spawn(class'Chip');
		if (A != None) A.RemoteRole = ROLE_None;
	}
	if (FRand() < 0.5) {
		A = spawn(class'Chip');
		if (A != None) A.RemoteRole = ROLE_None;
	}

	if (!Level.bHighDetailMode) return;

	if (class'{{package}}.UIweapons'.default.bUseDecals&& Level.NetMode != NM_DedicatedServer) Spawn(class'Pock');

	if (Level.bDropDetail) return;

	A = spawn(class'SmallSpark', ,, ,Rotation + RotRand());
	if (A != None) A.RemoteRole = ROLE_None;
}

defaultproperties {
}
