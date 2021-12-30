// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.OSLightWallHitEffect: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// ============================================================

class OSLightWallHitEffect expands LightWallHitEffect;
simulated function SpawnEffects() {
  local Actor A;
  local float decision;
  if (Level.NetMode == NM_DedicatedServer)
  return;
  decision = FRand();
  if (decision < 0.2) 
    PlaySound(sound'ricochet', , 1, ,1200, 0.5 + FRand());
  else if (decision < 0.4)
    PlaySound(sound'Impact1', , 3.0, ,800);
  else if (decision < 0.6)
    PlaySound(sound'Impact2', , 3.0, ,800);

  if (FRand()< 0.2) {
    A = spawn(class'Chip');
    if (A != None)
      A.RemoteRole = ROLE_None;
  }
  if (!Level.bHighDetailMode)
    return;
   if (class'{{package}}.UIweapons'.default.bUseDecals&& Level.NetMode != NM_DedicatedServer)
Spawn(class'Pock');
   if (Level.bDropDetail)
    return;
  if (FRand()< 0.2) {
    A = spawn(class'SmallSpark', ,, ,Rotation + RotRand());
    if (A != None)
      A.RemoteRole = ROLE_None;
  }
}

defaultproperties {
}

