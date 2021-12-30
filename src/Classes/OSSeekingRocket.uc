// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OSSeekingRocket
// ============================================================

class OSSeekingRocket expands SeekingRocket;
simulated function PostBeginPlay() {
  Super.PostBeginPlay();
  if (class'{{package}}.uiweapons'.default.busedecals)
    ExplosionDecal=Class'Botpack.BlastMark';
  else
    ExplosionDecal=None;
}

defaultproperties {
}

