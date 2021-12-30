// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.OLrazorjack: network/decal razorjack...
// ============================================================

class OLrazorjack expands UIweapons;
var bool clientanidone, bfirstfire;

// ============================================================
// Set priority to same as the UT version - Shrimp

function SetSwitchPriority(pawn Other) {
	local int i;

	if (PlayerPawn(Other) != None) {
		for (i = 0; i < 20; i++)
			if (PlayerPawn(Other).WeaponPriority[i] == 'Ripper') {
				AutoSwitchPriority = i;
				return;
			}

	}
}

//
// ===========================================================

function float SuggestAttackStyle() {
  return -0.2;
}

function float SuggestDefenseStyle() {
  return -0.2;
}
function Projectile ProjectileFire(class < projectile> ProjClass, float ProjSpeed, bool bWarn) {
  local Vector Start, X, Y, Z;

  if (PlayerPawn(Owner) != None)
    PlayerPawn(Owner).ClientInstantFlash(-0.4, vect(500, 0, 650));
  Owner.MakeNoise(Pawn(Owner).SoundDampening);
  GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
  Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Z * Z; 
  AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);  
  return Spawn(ProjClass, ,, Start, AdjustedAim);
}

simulated function tweentostill() {} //wierd bug....
simulated function PlayFiring() {
  PlayAnim('Fire', 0.7, 0.05);
}

simulated function PlayAltFiring() {
  PlayAnim('AltFire1', 0.9, 0.05);
  bFirstFire = true;
}
simulated function PlayRepeatFiring() {
  PlayAnim('AltFire2', 0.4, 0.05);
}
function AltFire(float Value) {
  if (AmmoType.UseAmmo(1)) {
    if (Owner.bHidden)
      CheckVisibility();
    bPointing = True;
    PlayAltFiring();
    GotoState('AltFiring');
  }
}
  
///////////////////////////////////////////////////////////
state AltFiring { ignores animend;
  function Projectile ProjectileFire(class < projectile> ProjClass, float ProjSpeed, bool bWarn) {
    local Vector Start, X, Y, Z;

    Owner.MakeNoise(Pawn(Owner).SoundDampening);
    GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
    Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
    AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);  
    AdjustedAim.Roll += 12768;    
    return RazorBlade(Spawn(ProjClass, ,, Start, AdjustedAim));
  }

Begin:
  FinishAnim();
Repeater:
  ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
  PlayRepeatFiring();
  FinishAnim();
  if (PlayerPawn(Owner) == None) {
    if ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) {
      Pawn(Owner).StopFiring();
      Pawn(Owner).SwitchToBestWeapon();
      if (bChangeWeapon)
        GotoState('DownWeapon');
    } else if ((Pawn(Owner).bAltFire == 0) || (FRand() > AltRefireRate)) {
      Pawn(Owner).StopFiring();
      GotoState('Idle');
    }
  }
  if ((Pawn(Owner).bAltFire != 0)
    && (Pawn(Owner).Weapon == Self) && AmmoType.UseAmmo(1)) {
    goto 'Repeater';
  }  
  PlayAnim('AltFire3', 0.9, 0.05);
  FinishAnim();
  PlayAnim('Load', 0.2, 0.05);
  FinishAnim();  
  if (Pawn(Owner).bFire != 0 && Pawn(Owner).Weapon == Self)
    Global.Fire(0);
  else 
    GotoState('Idle');
}
 /*
state ClientFiring {
  simulated function AnimEnd() {
    if ((Pawn(Owner) == None) || (Ammotype.AmmoAmount <= 0)) {
      PlayIdleAnim();
      GotoState('');
    } else if (!bCanClientFire)
      GotoState('');
    else if (bFirstFire || (Pawn(Owner).bAltFire != 0)) {
      PlayRepeatFiring();
      bFirstFire = false;
    } else if (Pawn(Owner).bFire != 0)
      Global.ClientFire(0);
    else {
      PlayIdleAnim();
      GotoState('');
    }
  }

  simulated function BeginState() {
    Super.BeginState();
     SetTimer(0.5, false);
  }

}  */
state ClientAltFiring                                            { //animation stuff....
  simulated function AnimEnd() {
    if ((Pawn(Owner) == None)
      || ((AmmoType != None) && (AmmoType.AmmoAmount <= 0))) { if (!clientanidone) {      //for using two anims....
      PlayAnim('AltFire3', 0.9, 0.05);
      clientanidone = true;
      } else {
      PlayAnim('Load', 0.2, 0.05);
      clientanidone = False;
      GotoState('');}
    } else if (!bCanClientFire)
      GotoState('');
    else if (Pawn(Owner).bFire != 0) {
      if (!clientanidone) {      //for using two anims....
      PlayAnim('AltFire3', 0.9, 0.05);
      clientanidone = true;
      } else {
      PlayAnim('Load', 0.2, 0.05);
      clientanidone = False;
      Global.ClientFire(0); }    } else if (bfirstfire || Pawn(Owner).bAltFire != 0) {
      PlayRepeatFiring();
      bFirstFire = false;}             //stuff to know if the first fire....
    else {
      if (!clientanidone) {      //for using two anims....
      PlayAnim('AltFire3', 0.9, 0.05);
      clientanidone = true;
      } else {
      PlayAnim('Load', 0.2, 0.05);
      clientanidone = False;
      GotoState('');}
    }
  }
}

///////////////////////////////////////////////////////////
simulated function PlayIdleAnim() {
  LoopAnim('Idle', 0.4);
}

defaultproperties {
     WeaponDescription="Classification: Skaarj Blade Launcher"
     AmmoName=Class'UnrealI.RazorAmmo'
     PickupAmmoCount=15
     FireOffset=(X=16.000000, Z=-15.000000)
     ProjectileClass=Class'MonsterHunt.OSRazorBlade'
     AltProjectileClass=Class'MonsterHunt.OSRazorBladeAlt'
     shakemag=120.000000
     AIRating=0.500000
     RefireRate=0.830000
     AltRefireRate=0.830000
     SelectSound=Sound'UnrealI.Razorjack.beam'
     DeathMessage="%k took a bloody chunk out of %o with the %w."
     AutoSwitchPriority=7
     InventoryGroup=7
     PickupMessage="You got the RazorJack"
     ItemName="Razorjack"
     PlayerViewOffset=(X=2.000000, Z=-0.900000)
     PlayerViewMesh=LodMesh'UnrealI.Razor'
     BobDamping=0.970000
     PickupViewMesh=LodMesh'UnrealI.RazPick'
     ThirdPersonMesh=LodMesh'UnrealI.Razor3rd'
     StatusIcon=Texture'Botpack.Icons.UseRazor'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseRazor'
     Mesh=LodMesh'UnrealI.RazPick'
     bNoSmooth=False
     CollisionRadius=28.000000
     CollisionHeight=7.000000
     Mass=17.000000
}

