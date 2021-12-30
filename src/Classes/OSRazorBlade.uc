//--[[[[----
// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.OSRazorBlade: makes use of decals and nothing more....
// ============================================================

class OSRazorBlade expands RazorBlade;
auto state Flying
{
simulated function HitWall (vector HitNormal, actor Wall)
  {
  super.Hitwall(hitnormal,wall);
  If (class'MonsterHunt.uiweapons'.default.bUseDecals)
  Spawn(class'WallCrack',,,Location, rotator(HitNormal));    }
  }

defaultproperties
{
}

//--]]]]----
