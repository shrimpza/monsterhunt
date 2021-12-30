//--[[[[----
// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.OSWallHitEffect: put your comment here

// Created by UClasses - (C) 2000 by meltdown@thirdtower.com
// ============================================================

class OSWallHitEffect expands WallHitEffect;
simulated function SpawnEffects()
{
  local Actor A;
  local float decision;
  if ( Level.NetMode == NM_DedicatedServer )
  return;
  decision = FRand();
  if (decision<0.1) 
    PlaySound(sound'ricochet',, 1,,1200, 0.5+FRand());    
  if ( decision < 0.35 )
    PlaySound(sound'Impact1',, 2.0,,1200);
  else if ( decision < 0.6 )
    PlaySound(sound'Impact2',, 2.0,,1200);

  if (FRand()< 0.3) 
  {
    A = spawn(class'Chip');
    if ( A != None )
      A.RemoteRole = ROLE_None;
  }
  if (FRand()< 0.3) 
  {
    A = spawn(class'Chip');
    if ( A != None )
      A.RemoteRole = ROLE_None;
  }
  if (FRand()< 0.3)
  {
    A = spawn(class'Chip');
    if ( A != None )
      A.RemoteRole = ROLE_None;
  }
    if ( !Level.bHighDetailMode )
    return;
   If(class'MonsterHunt.UIweapons'.default.bUseDecals&& Level.NetMode != NM_DedicatedServer )
Spawn(class'Pock');
   if ( Level.bDropDetail )
    return;
  A = spawn(class'SmallSpark2',,,,Rotation + RotRand());
  if ( A != None )
    A.RemoteRole = ROLE_None;
}

defaultproperties
{
}

//--]]]]----
