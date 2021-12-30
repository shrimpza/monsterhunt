// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.OLFlakCannon: the network/decal flak cannon.......
// ============================================================

class OLFlakCannon expands UIweapons;
var bool bejected; //for handling better animations on client.....

// ============================================================
// Set priority to same as the UT version - Shrimp

function SetSwitchPriority(pawn Other) {
	local int i;

	if (PlayerPawn(Other) != None) {
		for (i = 0; i < 20; i++)
			if (PlayerPawn(Other).WeaponPriority[i] == 'UT_FlakCannon') {
				AutoSwitchPriority = i;
				return;
			}

	}
}

//
// ===========================================================

//-------------------------------------------------------
// AI related functions

function float SuggestAttackStyle() {
  local bot B;

  B = Bot(Owner);
  if ((B != None) && B.bNovice)
    return 0.2;
  return 0.4;
}

function float SuggestDefenseStyle() {
  return -0.3;
}
//kick-@$$ b0t c0dE!
function float RateSelf(out int bUseAltMode) {
  local float EnemyDist, rating;
  local vector EnemyDir;

  if (AmmoType.AmmoAmount <=0)
    return -2;
  if (Pawn(Owner).Enemy == None) {
    bUseAltMode = 0;
    return AIRating;
  }
  EnemyDir = Pawn(Owner).Enemy.Location - Owner.Location;
  EnemyDist = VSize(EnemyDir);
  rating = FClamp(AIRating - (EnemyDist - 450) * 0.001, 0.2, AIRating);
  if (Pawn(Owner).Enemy.IsA('StationaryPawn')) {
    bUseAltMode = 0;
    return AIRating + 0.3;
  }
  if (EnemyDist > 900) {
    bUseAltMode = 0;
    if (EnemyDist > 2000) {
      if (EnemyDist > 3500)
        return 0.2;
      return (AIRating - 0.3);
    }      
    if (EnemyDir.Z < -0.5 * EnemyDist) {
      bUseAltMode = 1;
      return (AIRating - 0.3);
    }
  } else if ((EnemyDist < 750) && (Pawn(Owner).Enemy.Weapon != None) && Pawn(Owner).Enemy.Weapon.bMeleeWeapon) {
    bUseAltMode = 0;
    return (AIRating + 0.3);
  } else if ((EnemyDist < 340) || (EnemyDir.Z > 30)) {
    bUseAltMode = 0;
    return (AIRating + 0.2);
  } else bUseAltMode = int(FRand() < 0.65);
  return rating;
}

/*
simulated event RenderOverlays(canvas Canvas) {
  Texture'FlakAmmoled'.NotifyActor = Self;
  Super.RenderOverlays(Canvas);
  Texture'FlakAmmoled'.NotifyActor = None;
}               */

// Fire chunks
function Fire(float Value) {
  local Vector Start, X, Y, Z;
  local Bot B;
  local Pawn P;

  if (AmmoType == None) {
    // ammocheck
    GiveAmmo(Pawn(Owner));
  }
  if (AmmoType.UseAmmo(1)) {
    bCanClientFire = true;
    bPointing = True;
    Start = Owner.Location + CalcDrawOffset();
    B = Bot(Owner);
    P = Pawn(Owner);
    P.PlayRecoil(FiringSpeed);
    Owner.MakeNoise(2.0 * P.SoundDampening);
    AdjustedAim = P.AdjustAim(AltProjectileSpeed, Start, AimError, True, bWarnTarget);
    GetAxes(AdjustedAim, X, Y, Z);
    Spawn(class'WeaponLight', ,'', Start + X*20, rot(0, 0, 0));
    Start = Start + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;  
    Spawn(class 'OSMasterChunk', , '', Start, AdjustedAim);
    Spawn(class 'OSChunk2', , '', Start - Z, AdjustedAim);
    Spawn(class 'OSChunk3', , '', Start + 2 * Y + Z, AdjustedAim);
    Spawn(class 'OSChunk4', , '', Start - Y, AdjustedAim);
    Spawn(class 'OSChunk1', , '', Start + 2 * Y - Z, AdjustedAim);
    Spawn(class 'OSChunk2', , '', Start, AdjustedAim);
    Spawn(class 'OSChunk3', , '', Start + Y - Z, AdjustedAim);
    // lower skill bots fire less flak chunks (I made it so only those below 2 are affected... cause of slow fire rates.....
    if ((B == None) || B.Skill > 2 || ((B.Enemy != None) && (B.Enemy.Weapon != None) && B.Enemy.Weapon.bMeleeWeapon))
    Spawn(class 'OSChunk4', , '', Start + 2 * Y + Z, AdjustedAim);
    ClientFire(Value);
    GoToState('NormalFire');
  }
}

simulated function PlayFiring() {
  PlayAnim('Fire', 0.9, 0.05);
  PlayOwnedSound(FireSound, SLOT_Misc, Pawn(Owner).SoundDampening * 4.0);
  //bMuzzleFlash++;
}

simulated function PlayAltFiring() {
  PlayOwnedSound(AltFireSound, SLOT_Misc, Pawn(Owner).SoundDampening * 4.0);
  PlayAnim('AltFire', 1.3, 0.05);
  //bMuzzleFlash++;
}

function AltFire(float Value) {
  local Vector Start, X, Y, Z;

  if (AmmoType == None) {
    // ammocheck
    GiveAmmo(Pawn(Owner));
  }
  if (AmmoType.UseAmmo(1)) {
    Pawn(Owner).PlayRecoil(FiringSpeed);
    bPointing = True;
    bCanClientFire = true;
    Owner.MakeNoise(Pawn(Owner).SoundDampening);
    GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
    Start = Owner.Location + CalcDrawOffset();
    Spawn(class'WeaponLight', ,'', Start + X*20, rot(0, 0, 0));
    Start = Start + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
    AdjustedAim = pawn(owner).AdjustToss(AltProjectileSpeed, Start, AimError, True, bAltWarnTarget);  
    Spawn(class'OSflakshell', ,, Start, AdjustedAim);
    ClientAltFire(Value);  
    GoToState('AltFiring');
  }  
}

////////////////////////////////////////////////////////////
state AltFiring {
  function EndState() {
    Super.EndState();
    OldFlashCount = FlashCount;
  }

  function AnimEnd() {
    if ((AnimSequence != 'Loading') && (AmmoType.AmmoAmount > 0))
      PlayReloading();
    else
      Finish();
  }
    
Begin:
  FlashCount++;
}

/////////////////////////////////////////////////////////////
simulated function PlayReloading() {
  PlayAnim('Loading', 0.65, 0.05);
  Owner.PlayOwnedSound(CockingSound, SLOT_None, 0.5 * Pawn(Owner).SoundDampening);
}

simulated function Playejecting() {
  PlayAnim('Eject', 1.5, 0.05);
  Owner.PlayOwnedSound(Misc3Sound, SLOT_None, 0.6 * Pawn(Owner).SoundDampening);
  }
simulated function PlayFastReloading() {

  //FinishAnim();
  PlayAnim('Loading', 1.4, 0.05);
  Owner.PlayOwnedSound(CockingSound, SLOT_None, 0.5 * Pawn(Owner).SoundDampening);
  //FinishAnim();
}

state ClientReload {
  simulated function bool ClientFire(float Value) {
    bForceFire = bForceFire || (bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0));
    return bForceFire;
  }

  simulated function bool ClientAltFire(float Value) {
    bForceAltFire = bForceAltFire || (bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0));
    return bForceAltFire;
  }

  simulated function AnimEnd() {
    if (bCanClientFire && (PlayerPawn(Owner) != None) && (AmmoType.AmmoAmount > 0)) {
      if (bForceFire || (Pawn(Owner).bFire != 0)) {
        Global.ClientFire(0);
        return;
      } else if (bForceAltFire || (Pawn(Owner).bAltFire != 0)) {
        Global.ClientAltFire(0);
        return;
      }
    }      
    GotoState('');
    Global.AnimEnd();
  }

  simulated function EndState() {
    bForceFire = false;
    bForceAltFire = false;
  }

  simulated function BeginState() {
    bForceFire = false;
    bForceAltFire = false;
  }
}

state ClientFiring {
  simulated function AnimEnd() {
    if ((Pawn(Owner) == None) || (Ammotype.AmmoAmount <= 0)) {
      PlayIdleAnim();
      GotoState('');
    } else if (!bCanClientFire)
      GotoState('');
    else if (bejected) {
      PlayFastReloading();
      bejected = false;
      GotoState('ClientReload');} else {
      PlayEjecting();
      bEjected = True;
    }

  }
  simulated function EndState() {
    bejected = false;
  }
}

state ClientAltFiring {
  simulated function AnimEnd() {
    if ((Pawn(Owner) == None) || (Ammotype.AmmoAmount <= 0)) {
      PlayIdleAnim();
      GotoState('');
    } else if (!bCanClientFire)
      GotoState('');
    else {
      PlayReloading();
      GotoState('ClientReload');
    }

  }
}

state NormalFire {  ignores animend;
/*function AnimEnd() {
      //if ((AnimSequence != 'Eject') && (AmmoType.AmmoAmount > 0))    //would be playing if network....
      if ((!bEjected)&& (AmmoType.AmmoAmount > 0)) {
      PlayEjecting();
      bEjected = True;
      if ((bEjected) && (AmmoType.AmmoAmount > 0))
      PlayFastReloading();
      } else Finish();
      bEjected = False;
  }           */
    
Begin:

      if ((!bEjected)&& (AnimSequence != 'Eject')&&(AnimSequence != 'Loading')&&(AmmoType.AmmoAmount > 0)) {
      FinishAnim();
      PlayEjecting();
      //bEjected = True; }
      //if ((bEjected) && (AnimSequence != 'Eject')&&(AmmoType.AmmoAmount > 0))
      FinishAnim();
      PlayFastReloading();
      FinishAnim();
      }
      Finish();
      bEjected = False;
}

///////////////////////////////////////////////////////////
simulated function TweenDown() {
  if (GetAnimGroup(AnimSequence) == 'Select')
    TweenAnim(AnimSequence, AnimFrame * 0.4);
  else {
    if (AmmoType.AmmoAmount <= 0)  PlayAnim('Down2', 1.0, 0.05);
    else PlayAnim('Down', 1.0, 0.05);
  }
}

simulated function PlayIdleAnim() {
LoopAnim('Sway', 0.01, 0.3);
}

simulated function PlayPostSelect() {
  PlayAnim('Loading', 1.3, 0.05);
  Owner.PlayOwnedSound(Misc2Sound, SLOT_None, 1.3 * Pawn(Owner).SoundDampening);
}

defaultproperties {
     WeaponDescription="Classification: Heavy Shrapnel"
     AmmoName=Class'UnrealI.FlakBox'
     PickupAmmoCount=10
     bWarnTarget=True
     bAltWarnTarget=True
     bSplashDamage=True
     FireOffset=(X=10.000000, Y=-12.000000, Z=-15.000000)
     ProjectileClass=Class'MonsterHunt.OSMasterChunk'
     AltProjectileClass=Class'MonsterHunt.OSFlakShell'
     shakemag=350.000000
     shaketime=0.150000
     shakevert=8.500000
     AIRating=0.800000
     FireSound=Sound'UnrealShare.flak.shot1'
     AltFireSound=Sound'UnrealShare.flak.Explode1'
     CockingSound=Sound'UnrealI.flak.load1'
     SelectSound=Sound'UnrealI.flak.pdown'
     Misc2Sound=Sound'UnrealI.flak.Hidraul2'
     Misc3Sound=Sound'UnrealShare.flak.Click'
     DeathMessage="%o was ripped to shreds by %k's %w."
     AutoSwitchPriority=6
     InventoryGroup=6
     PickupMessage="You got the Flak Cannon"
     ItemName="Flak Cannon"
     PlayerViewOffset=(X=2.100000, Y=-1.500000, Z=-1.250000)
     PlayerViewMesh=LodMesh'UnrealI.flak'
     PlayerViewScale=1.200000
     PickupViewMesh=LodMesh'UnrealI.FlakPick'
     ThirdPersonMesh=LodMesh'UnrealI.Flak3rd'
     StatusIcon=Texture'Botpack.Icons.UseFlak'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseFlak'
     Mesh=LodMesh'UnrealI.FlakPick'
     bNoSmooth=False
     CollisionRadius=27.000000
     CollisionHeight=23.000000
     LightBrightness=228
     LightHue=30
     LightSaturation=71
     LightRadius=14
}

