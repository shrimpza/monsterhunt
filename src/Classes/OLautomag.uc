// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.OLautomag: The automag now playing twirl :D
// can be akimbo'd to (uses bane's code..... only one controls firing....other purely for animation)
// ============================================================

class OLautomag expands UIweapons;
var() int hitdamage;
var  float AltAccuracy;
var bool nowfire, isslave, slaverequestreload, slaveprevent;        //for reloading and animations
var int ClipCount, slaveclipcount;    //both clipcounts stored (for accurate counting :D)
var olautomag slavemag, mastermag;  //the slave  (second one)   and the master (for referencing in newclip
var byte fireanim, firstfire, newclipanim, iFireAGun; //for client stuff.....
var bool bSetup, trytick;        // used for setting display properties

replication {
  reliable if (bNetOwner && (Role == ROLE_Authority))     //server send to client
    clipcount, slavemag, slaveclipcount, iFireAGun, isslave;
  /*reliable if (Role < Role_Authority) //client send to server....
  reload;   */
}

// ============================================================
// Set priority to same as the UT version - Shrimp

function SetSwitchPriority(pawn Other) {
	local int i;

	if (PlayerPawn(Other) != None) {
		for (i = 0; i < 20; i++)
			if (PlayerPawn(Other).WeaponPriority[i] == 'Enforcer') {
				AutoSwitchPriority = i;
				return;
			}
	}
}

//
// ===========================================================

function BringUp() {
  if (Slavemag != none) {
    SetTwoHands();
    Slavemag.BringUp();
  }
  Super.BringUp();
}

//shows clip count (an enhancement)         (idea from AgentX...thankx guys!!! great mod!!!!!!)
simulated function PostRender(canvas Canvas) {
  local PlayerPawn P;
  local float multiplier;
  P = PlayerPawn(Owner);
  if  (P != None) {
		if (P.myhud.isa('challengehud')) multiplier = 0.8;
		else multiplier = 0.9;

		Canvas.DrawColor.B = 0;
		if (slavemag !=none) {
			//reverse if left side...)
			if (P.Handedness != 1) {
				if (clipcount > 15) {       //set colour according to shots left.....
					Canvas.DrawColor.R = 255;
					Canvas.DrawColor.G = 0;
				} else {
					Canvas.DrawColor.R = 0;
					Canvas.DrawColor.G = 255;
				}
				Canvas.SetPos(0.85 * Canvas.ClipX, multiplier* Canvas.ClipY);
				Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.Font = Canvas.SmallFont;
				Canvas.DrawText("Clip: " $ 20 - clipcount);
				if (slaveclipcount > 15) {       //set colour according to shots left.....
					Canvas.DrawColor.R = 255;
					Canvas.DrawColor.G = 0;
				} else {
					Canvas.DrawColor.R = 0;
					Canvas.DrawColor.G = 255;
				}
				Canvas.SetPos(0.05 * Canvas.ClipX, multiplier * Canvas.ClipY);
				Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.Font = Canvas.SmallFont;
				Canvas.DrawText("Clip: " $ 20 - slaveclipcount);
			} else {
				if (slaveclipcount > 15) {       //set colour according to shots left.....
					Canvas.DrawColor.R = 255;
					Canvas.DrawColor.G = 0;
				} else {
					Canvas.DrawColor.R = 0;
					Canvas.DrawColor.G = 255;
				}
				Canvas.SetPos(0.85 * Canvas.ClipX, multiplier * Canvas.ClipY);
				Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.Font = Canvas.SmallFont;
				Canvas.DrawText("Clip: " $ 20 - slaveclipcount);
				if (clipcount > 15) {       //set colour according to shots left.....
					Canvas.DrawColor.R = 255;
					Canvas.DrawColor.G = 0;
				} else {
					Canvas.DrawColor.R = 0;
					Canvas.DrawColor.G = 255;
				}
				Canvas.SetPos(0.05 * Canvas.ClipX, multiplier * Canvas.ClipY);
				Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.Font = Canvas.SmallFont;
				Canvas.DrawText("Clip: " $ 20 - clipcount);
			}
		} else { //doesn't have 2
			if (clipcount > 15) {       //set colour according to shots left.....
				Canvas.DrawColor.R = 255;
				Canvas.DrawColor.G = 0;
			} else {
				Canvas.DrawColor.R = 0;
				Canvas.DrawColor.G = 255;
			}
			if (P.Handedness != 1) {
				Canvas.SetPos(0.05 * Canvas.ClipX, multiplier * Canvas.ClipY);
				Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.Font = Canvas.SmallFont;
			} else {
				Canvas.SetPos(0.85 * Canvas.ClipX, multiplier * Canvas.ClipY);
				Canvas.Style = ERenderStyle.STY_Translucent;
				Canvas.Font = Canvas.SmallFont;
			}
			Canvas.DrawText("Clip: " $ 20 - clipcount);
		}
	}
}

function Finish() {
  if (bChangeWeapon) GotoState('DownWeapon');
  else if (PlayerPawn(Owner) == None) Super.Finish();
  else if ((AmmoType.AmmoAmount <= 0) || (Pawn(Owner).Weapon != self)) GotoState('Idle');
  else if (ClipCount >= 20) GoToState('NewClip');
  else if (Pawn(Owner).bFire != 0) Global.Fire(0);
  else if (Pawn(Owner).bAltFire != 0) Global.AltFire(0);
  else GotoState('Idle');
}

function DropFrom(vector StartLocation) {
  if (!SetLocation(StartLocation)) return;
	if (slavemag != none) {
		slavemag.Destroy();
		slavemag = None;
  }
  AIRating = Default.AIRating;
  Super.DropFrom(StartLocation);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z) {
  local shellcase s;
  local vector realLoc;

  realLoc = Owner.Location + CalcDrawOffset();
  if (slavemag != None && ((iFireAGun == 1 && IsInState('AltFiring')) || iFireAGun == 0 && IsInState('NormalFire'))) {
    s = Spawn(class'ShellCase', Pawn(Owner), '', realLoc + 20 * X + slavemag.FireOffset.Y * Y + Z);
	} else {
  	s = Spawn(class'ShellCase', , '', realLoc + 20 * X + FireOffset.Y * Y + Z);
	}
  if (s != None) {
    s.Eject(((FRand() * 0.3 + 0.4) * X + (FRand() * 0.2 + 0.2) * Y + (FRand() * 0.3 + 1.0) * Z) * 160);
	}
  if (Other == Level) {
    Spawn(class'MonsterHunt.osWallHitEffect', ,, HitLocation + HitNormal * 9, Rotator(HitNormal));
  } else if ((Other != self) && (Other != Owner) && (Other != None)) {
    if (FRand() < 0.2) X *= 5;
    Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 3000.0 * X, MyDamageType);
    if (!Other.bIsPawn && !Other.IsA('Carcass')) {
      spawn(class'SpriteSmokePuff', ,, HitLocation + HitNormal * 9);
    } else {
      Other.PlaySound(Sound 'ChunkHit', , 4.0, ,100);
		}
  }
}

function bool HandlePickupQuery(inventory Item) {
  local int OldAmmo;
  local Pawn P;

  if (Item.class == class) {
    if ((Weapon(item).bWeaponStay && (slavemag != None || !akimbomag||level.game.isa('unrealgameinfo')))
        && (!Weapon(item).bHeldItem || Weapon(item).bTossedOut)) {
      return true;
		}

    P = Pawn(Owner);
    
    if (AmmoType != None) {
      OldAmmo = AmmoType.AmmoAmount;
      if (AmmoType.AddAmmo(PickupAmmoCount) && (OldAmmo == 0)
        && (P.Weapon.class != item.class) && !P.bNeverSwitchOnPickup) {
          WeaponSet(P);
			}
    }
    if (Level.Game.LocalLog != None) Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
    if (Level.Game.WorldLog != None) Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));

    //message
    if (!akimbomag||level.game.isa('unrealgameinfo')) {
			if (PickupMessageClass == None) P.ClientMessage(PickupMessage, 'Pickup');
			else P.ReceiveLocalizedMessage(PickupMessageClass, 0, None, None, item.Class);
    } else if (slavemag != None) {
      if (playerpawn(owner)!=none&&playerpawn(owner).myhud.isa('challengehud')) P.ClientMessage("You scavenge some ammo", 'PickupMessagePlus');
      else P.ClientMessage("You scavenge some ammo", 'Pickup');
    } else {
      if (playerpawn(owner)!=none&&playerpawn(owner).myhud.isa('challengehud')) P.clientmessage("Automag Akimbo!", 'PickupMessagePlus');
      else P.ClientMessage("Automag Akimbo!", 'Pickup');}
    //P.ReceiveLocalizedMessage(class'PickupMessagePlus', 0, None, None, Self.Class);
    
    if (slavemag == None&&akimbomag&&!level.game.isa('unrealgameinfo')) {
      slavemag = Spawn(class'olautomag');
      slavemag.isslave = true;
      slavemag.mastermag = self; //new clip referencing..
      slavemag.SetOwner(Owner);
      slavemag.setHand(255);
      slavemag.BecomeItem();
      slavemag.BringUp();
      SetTwoHands();
      AIRating = 0.4;
      Slavemag.SetDisplayProperties(Style, Texture, bUnlit, bMeshEnviromap);
    	SetTwoHands();
    }
    item.PlaySound(PickupSound);
    item.SetRespawn();
    return true;
  }

  if (Inventory == None) return false;

  return Inventory.HandlePickupQuery(Item);
}

function SetTwoHands() {
  if (Slavemag == None) return;

  if ((PlayerPawn(Owner) != None) && (PlayerPawn(Owner).Handedness == 2)) {
    SetHand(2);
    return;
  }

  if (Mesh == mesh'AutoMagL') SetHand(1);
  else SetHand(-1);
}

function setHand(float Hand) {
  if (Hand == 2) {
    bHideWeapon = true;
    Super.SetHand(Hand);
    return;
  }

  if (Slavemag != None) {
    if (Hand == 0) Hand = -1;
    Slavemag.SetHand(-1 * Hand);
  }
  Super.SetHand(Hand);
  if (Hand == 1) Mesh = mesh'AutoMagL';
  else Mesh = mesh'AutoMagR';
}

function TraceFire(float Accuracy) {
  if (Owner.IsA('Bot') && !Bot(Owner).bNovice) Accuracy = FMax(Accuracy, 0.45);

  Super.TraceFire(Accuracy);
}

function Fire(float Value) {
  if (AmmoType == None) {
    // ammocheck
    GiveAmmo(Pawn(Owner));
  }

  if (slavemag != none&&slavemag.isinstate('newclip')) return;

	if (AmmoType.UseAmmo(1)) {
    GotoState('NormalFire');
    bCanClientFire = true;
    bPointing = True;
    ClientFire(value);

    Pawn(Owner).PlayRecoil(FiringSpeed);
    TraceFire(0.0);
  }
}

simulated function PlayFiring() {
  PlayOwnedSound(FireSound, SLOT_None, 2.0 * Pawn(Owner).SoundDampening);
  //PlayAnim('Shoot', 0.5 + 0.31 * FireAdjust, 0.02);
  if (iFireAGun == 1 && slavemag != None && slavemag.AnimSequence != 'Shoot0') {
     slavemag.PlayAnim('Shoot', 2.5, 0.02);
 	} else if (AnimSequence != 'Shoot0') {
 		PlayAnim('Shoot', 2.5, 0.02);
  }
  fireanim = 0;
}

simulated function PlayFiringmid() {
  PlayAnim('Shoot0', 0.26, 0.04);
  fireanim = 2;
}
simulated function PlayFiringend() {
  PlayAnim('Shoot2', 0.8, 0.0);
  fireanim = 3;
}
simulated function PlayAltFiring() {
 PlayAnim('T1', 1.3, 0.05);
 if (slavemag != None) slavemag.PlayAnim('T1', 1.3, 0.05);
 firstfire = 1;
}

simulated function PlayAltstart() {
	PlayAnim('Shot2a', 1.2, 0.05);
	firstfire = 2;
}
simulated function Playaltend() {
	PlayAnim('Shot2c', 0.7, 0.05);
	firstfire = 3;
}
simulated function PlayRepeatFiring() {
  if (Affector != None) Affector.FireEffect();
  if (PlayerPawn(Owner) != None) {
    PlayerPawn(Owner).ClientInstantFlash(-0.2, vect(325, 225, 95));
    PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
  }
  //bMuzzleFlash++;
	Owner.PlaySound(FireSound, SLOT_None, 2.0 * Pawn(Owner).SoundDampening);
  PlayAnim('Shot2b', 0.4, 0.05);
}

function AltFire(float Value) {
  if (slavemag != none&&slavemag.isinstate('newclip')) return;

  bPointing = True;
  bCanClientFire = true;
  AltAccuracy = 0.4;
  CheckVisibility();

  if (AmmoType == None) {
    // ammocheck
    GiveAmmo(Pawn(Owner));
  }
  if (AmmoType.AmmoAmount > 0) {
		Pawn(Owner).PlayRecoil(1.5 * FiringSpeed);
    if (PlayerPawn(Owner) != None) PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
    ClientAltFire(value);
    GotoState('AltFiring');
  }
}
simulated function bool ClientAltFire(float Value) {
  if (slavemag != none&&slavemag.isinstate('clientnewclip')) return false;

  if (bCanClientFire && ((Role == ROLE_Authority) || (AmmoType == None) || (AmmoType.AmmoAmount > 0))) {
    if ((PlayerPawn(Owner) != None)
      && ((Level.NetMode == NM_Standalone) || PlayerPawn(Owner).Player.IsA('ViewPort'))) {
      if (InstFlash != 0.0) PlayerPawn(Owner).ClientInstantFlash(InstFlash, InstFog);
      PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
    }
    if (Affector != None) Affector.FireEffect();

    PlayAltFiring();

    if (Role < ROLE_Authority) GotoState('ClientAltFiring');

    return true;
  }
  return false;
}
simulated function bool ClientFire(float Value) {    //for returning state stuff.....
  if (slavemag != none&&slavemag.isinstate('clientnewclip')) return false;
  if (bCanClientFire && ((Role == ROLE_Authority) || (AmmoType == None) || (AmmoType.AmmoAmount > 0))) {
    if ((PlayerPawn(Owner) != None)
      && ((Level.NetMode == NM_Standalone) || PlayerPawn(Owner).Player.IsA('ViewPort'))) {
      if (InstFlash != 0.0) PlayerPawn(Owner).ClientInstantFlash(InstFlash, InstFog);
      PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
    }
    if (Affector != None) Affector.FireEffect();

    PlayFiring();

    if (Role < ROLE_Authority) GotoState('ClientFiring');

    return true;
  }
  return false;
}

state Active {
  function bool PutDown() {
    if (bWeaponUp || (AnimFrame < 0.75)) GotoState('DownWeapon');
    else bChangeWeapon = true;
    return True;
  }

  function BeginState() {
    bChangeWeapon = false;
  }

Begin:
	if (ammotype != none&&!isslave) {
		if (slavemag == none) {   //simple check......
			if (19 < ammotype.ammoamount) clipcount = 0;
			else clipcount = 20 - ammotype.ammoamount;
		} else {
			if (39 < ammotype.ammoamount) {                   //complex: gotta make sure we have enough ammo to fill the clips....
				ClipCount = 0;
				Slaveclipcount = 0;
			} else {
				if (ifireagun == 1) { //base by primary
					clipcount = (40 - ammotype.ammoamount) / 2;
					slaveclipcount = (40 - ammotype.ammoamount) - clipcount;
					//give it the remaining amount....
				} else { //based on slave
					slaveclipcount = (40 - ammotype.ammoamount) / 2;
					clipcount=(40 - ammotype.ammoamount) - slaveclipcount;
				}
			}
		}
	}

	//get the slave outa here!
	if (isslave) gotostate('');
	else {
		FinishAnim();
		if (bChangeWeapon) GotoState('DownWeapon');

		bWeaponUp = True;
		bCanClientFire = true;

		if ((Level.Netmode != NM_Standalone) && (Owner != None)
		  && Owner.IsA('TournamentPlayer')
		  && (PlayerPawn(Owner).Player != None)
		  && !PlayerPawn(Owner).Player.IsA('ViewPort')) {
			if (bForceFire ||Pawn(Owner).bFire != 0) TournamentPlayer(Owner).SendFire(self);
			else if (bForceAltFire ||Pawn(Owner).bAltFire != 0) TournamentPlayer(Owner).SendAltFire(self);
			else if (!bChangeWeapon) TournamentPlayer(Owner).UpdateRealWeapon(self);
		}
		Finish();
	}
}

//newclip animations.....
simulated function playeject() {
	PlayAnim('Eject', 1.5, 0.05);
	PlayOwnedSound(Misc2Sound, SLOT_None, 1.0 * Pawn(Owner).SoundDampening);
	newclipanim = 1;
}
simulated function playdownclip() {
	PlayAnim('Down', 1.2, 0.05);
	newclipanim = 2;
}
simulated function playselectclip() {
	Owner.PlaySound(SelectSound, SLOT_None, 1.0 * Pawn(Owner).SoundDampening);
	PlayAnim('Select', 1.6, 0.07);
	newclipanim = 3;
}

////////////////////////////////////////////////////////
state NewClip { //THE SLAVE CAN BE IN THIS STATE!
ignores Fire, AltFire;

	function Tick(float deltatime) {
		if (trytick&&!isslave&&!slaveprevent) {
			trytick = false;
			if (bChangeWeapon) GotoState('DownWeapon');
			else if (Pawn(Owner).bFire != 0) Global.Fire(0);
			else if (Pawn(Owner).bAltFire != 0) Global.AltFire(0);
			else GotoState('Idle');
		}
	}

Begin:
	//bcanclientfire = false;
	//hack sorta to play cockgun (only works if the mesh is in wating state).  I like Hasanim!!!!
	if (isslave && mastermag == none) log ("mastermag equaled none!");
	if ((pawn(owner) != None) && (pawn(owner).GetAnimGroup(pawn(owner).AnimSequence) == 'waiting') && (pawn(owner).hasanim('cockgun'))) {
		Pawn(owner).PlayAnim('CockGun', , 0.3);
	}

	Playeject();
	FinishAnim();
	Playdownclip();
	FinishAnim();

	if (!isslave&&slavemag == none) {   //simple check......
		if (19 < ammotype.ammoamount) clipcount = 0;
		else clipcount = 20 - ammotype.ammoamount;
	} else {
		//complex: gotta make sure we have enough ammo to fill the clips....
		if (39 < ammotype.ammoamount && !isslave) ClipCount = 0;
		else if (isslave && 39 < mastermag.ammotype.ammoamount) mastermag.slaveclipcount = 0;
		else {
			if (!isslave) clipcount = (40 - ammotype.ammoamount) / 2;
			else mastermag.slaveclipcount = (40 - mastermag.ammotype.ammoamount) - mastermag.clipcount; //give it the remaining amount....
		}
	}

	if (!isslave && slaverequestreload && slavemag != none) {
		slaverequestreload = false;
		slavemag.gotostate('newclip');
		slaveprevent = true;
	}

	Playselectclip();
	FinishAnim();

	//bcanclientfire = true;
	// reloadnow = false;
	if (isslave) {
		mastermag.slaveprevent = false;
		playidleanim();
		Gotostate('');
	} else trytick = true; //launch ticker....
}

//THE SLAVE CAN BE IN THIS STATE!
state ClientNewclip {              //reload 'em client's........
  simulated function bool ClientFire(float Value) {
    bForceFire = bForceFire || (bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0));
    return bForceFire;
  }

  simulated function bool ClientAltFire(float Value) {
    bForceAltFire = bForceAltFire || (bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0));
    return bForceAltFire;
  }

  simulated function AnimEnd() {
    if (newclipanim == 0) Playeject();
    else if (newclipanim == 1) Playdownclip();
    else if (newclipanim == 2) {
    	if (!isslave&&slaverequestreload) slaverequestreload = false;
			slavemag.gotostate('clientnewclip');
			Playselectclip();
    } else {
			if (!isslave) {
				if (bCanClientFire && (PlayerPawn(Owner) != None) && (AmmoType.AmmoAmount > 0)) {
					if (bForceFire || (Pawn(Owner).bFire != 0)) {
						Global.ClientFire(0);
						return;
					} else if (bForceAltFire || (Pawn(Owner).bAltFire != 0)) {
						Global.ClientAltFire(0);
						return;
					}
				}
			}
			GotoState('');
			Global.AnimEnd();
		}
  }

  simulated function EndState() {
    bForceFire = false;
    bForceAltFire = false;
    newclipanim = 0;
  }

  simulated function BeginState() {
    newclipanim = 0;
    Playeject();
    bForceFire = false;
    bForceAltFire = false;
  }
}

state NormalFire {
ignores Fire, AltFire, AnimEnd;

Begin:
 iFireAGun = 1 - iFireAGun;

 if (ifireagun == 1&&slavemag != none) slaveclipcount++;
 else if (clipcount < 20) ClipCount++;

	if (iFireAGun == 1 && slavemag != None) {
		if (slavemag.AnimSequence != 'Shoot0')
		sleep(0.01);
		slavemag.playfiringmid();
		Sleep(0.2);
	} else {
		if (AnimSequence != 'Shoot0') {
			if (slavemag != None) Sleep(0.01);
			else FinishAnim();
		}
		Playfiringmid();
		if (slavemag != None) Sleep(0.2);
		else FinishAnim();
	}

  if (ifireagun == 0 && ClipCount > 15) Owner.PlaySound(Misc1Sound, SLOT_None, 3.5 * Pawn(Owner).SoundDampening);
  else if (slaveclipcount > 15) Owner.PlaySound(Misc1Sound, SLOT_None, 3.5 * Pawn(Owner).SoundDampening);

  if (bChangeWeapon) GotoState('DownWeapon');
//  else if (PlayerPawn(Owner) == None)    UsAaR33: pawns obey same rulez as players.....
  //  Super.Finish();
  else if ((AmmoType.AmmoAmount <= 0) || (Pawn(Owner).Weapon != self)) GotoState('Idle');
  else if (ClipCount >= 20&&(slavemag == none||slaveclipcount >= 20)) {
		if (slavemag != none) slaverequestreload = true;
		GoToState('NewClip');
  } else if (clipcount >= 20&&slaveclipcount < 20&&slavemag != none&&ifireagun == 1) { //we need to sleep to let it catch up.....
		sleep(0.21);
		ifireagun = 0;
		if (Pawn(Owner).bFire != 0) Global.Fire(0);
		else if (Pawn(Owner).bAltFire != 0) Global.AltFire(0);
  } else if (Pawn(Owner).bFire != 0) Global.Fire(0);
  else if (Pawn(Owner).bAltFire != 0) Global.AltFire(0);

  if (iFireAGun == 1 && slavemag != None) slavemag.PlayFiringend();

  Playfiringend();
  FinishAnim();
  GoToState('Idle');
}

state ClientFiring {
  simulated function AnimEnd() {
		if ((ClipCount >= 20)&&(Ammotype.ammoamount > 0)) {
			fireanim = 0;
			GoToState('clientNewClip');
		} else if (fireanim == 2) {
			if (ClipCount > 15) Owner.PlayOwnedSound(Misc1Sound, SLOT_None, 3.5 * Pawn(Owner).SoundDampening);
			Playfiringend();
		} else if (fireanim != 3) {
			Playfiringmid();
		} else {
			fireanim = 0;
			if ((Pawn(Owner) == None) || (Ammotype.AmmoAmount <= 0)) {
				PlayIdleAnim();
				GotoState('');
			} else if (!bCanClientFire) {
				GotoState('');
			} else if (Pawn(Owner).bAltFire != 0) {
				FirstFire = 0;
				Global.ClientAltFire(0);
			} else if (Pawn(Owner).bFire != 0) {
				Global.ClientFire(0);
			} else {
				PlayIdleAnim();
				GotoState('');
			}
		}
  }
}

state ClientAltFiring {

  simulated function timer() {
		if (ifireagun == 0 && ClipCount > 15 && firstfire != 1) PlayownedSound(Misc1Sound, SLOT_None, 3.5 * Pawn(Owner).SoundDampening);
		else if (slaveclipcount > 15 && firstfire != 1) PlayownedSound(Misc1Sound, SLOT_None, 3.5 * Pawn(Owner).SoundDampening);

		if (Pawn(Owner) == None) {
			GotoState('');
		} else if (ClipCount >= 20&&(slavemag == none||slaveclipcount >= 20)) {
			if (slavemag != none) slaverequestreload = true;
			GoToState('clientNewClip');
		} else if (Ammotype.AmmoAmount <= 0) {
			PlayAnim('T2', 0.9, 0.05);
			GotoState('');
		} else if (!bCanClientFire) {
			GotoState('');
		} else if (FirstFire == 2 || (Pawn(Owner).bAltFire != 0)) {
			if (iFireAGun == 1 && slavemag != None) slavemag.playrepeatfiring();
			else PlayRepeatFiring();
			settimer(0.13, false);
		} else if (firstfire != 3) {
			enable('animend');
			Playaltend();
		} else if (Pawn(Owner).bFire != 0 && !nowfire) {
			PlayAnim('T2', 0.9, 0.05);
			Nowfire = true;
			enable('animend');
		} else {
			PlayAnim('T2', 0.9, 0.05);
			GotoState('');
		}
	}

  simulated function AnimEnd() {
		if (ifireagun == 0 && ClipCount > 15 && firstfire != 1) PlayownedSound(Misc1Sound, SLOT_None, 3.5 * Pawn(Owner).SoundDampening);
		else if (slaveclipcount > 15 && firstfire != 1) PlayownedSound(Misc1Sound, SLOT_None, 3.5 * Pawn(Owner).SoundDampening);

		if (Pawn(Owner) == None) {
			GotoState('');
		} else if (ClipCount >= 20&&(slavemag == none||slaveclipcount >= 20)) {
			if (slavemag != none) slaverequestreload = true;
			GoToState('clientNewClip');
		} else if (firstfire == 1) {
			if (slavemag != None) slavemag.Playaltstart();
			Playaltstart();
		} else if (Ammotype.AmmoAmount <= 0) {
			PlayAnim('T2', 0.9, 0.05);
			GotoState('');
		} else if (!bCanClientFire) {
			GotoState('');
		} else if (FirstFire == 2 || (Pawn(Owner).bAltFire != 0)) {
			if (iFireAGun == 1 && slavemag != None) slavemag.playrepeatfiring();
			else PlayRepeatFiring();

			if (slavemag != none && ifireagun == 1) slavemag.firstfire= 0;
			else FirstFire = 0;

			if (slavemag != none) {
				settimer(0.13, false);
				disable('animend');
			}
		} else if (firstfire != 3) {
			Playaltend();
		} else if (Pawn(Owner).bFire != 0 && !nowfire) {
			PlayAnim('T2', 0.9, 0.05);
			Nowfire = true;
		} else if (nowfire) {
			Nowfire = false;
			Global.ClientFire(0);
		} else {
			PlayAnim('T2', 0.9, 0.05);
			GotoState('');
		}
  }
}

state AltFiring {
ignores Fire, AltFire, AnimEnd;

Begin:
  FinishAnim();
  if (slavemag != None) slavemag.Playaltstart();
  Playaltstart();
  FinishAnim();

Repeater:
	if (AmmoType.UseAmmo(1)) {
		iFireAGun = 1 - iFireAGun;
		if (PlayerPawn(Owner) != None) PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		if (ifireagun == 1&&slavemag != none) slaveclipcount++;
		else if (clipcount < 20) ClipCount++;

		Pawn(Owner).PlayRecoil(1.5 * FiringSpeed);
		TraceFire(AltAccuracy);
		if (iFireAGun == 1 && slavemag != None) slavemag.playrepeatfiring();
		else PlayRepeatFiring();

		if (slavemag != None) Sleep(0.13);
		else FinishAnim();
	}

	if (AltAccuracy < 3) AltAccuracy += 0.5;

	if (ifireagun == 0 && ClipCount > 15) Owner.PlaySound(Misc1Sound, SLOT_None, 3.5 * Pawn(Owner).SoundDampening);
	else if (slaveclipcount > 15) Owner.PlaySound(Misc1Sound, SLOT_None, 3.5 * Pawn(Owner).SoundDampening);

	if (bChangeWeapon) GotoState('DownWeapon');
	else if ((AmmoType.AmmoAmount <= 0) || (Pawn(Owner).Weapon != self)) GotoState('Idle');
	else if (ClipCount >= 20 && (slavemag == none || slaveclipcount >= 20)) {
		if (slavemag != none) slaverequestreload = true;
		GoToState('NewClip');
	} else if ((Pawn(Owner).bAltFire != 0) && AmmoType.AmmoAmount > 0) {
		if (PlayerPawn(Owner) == None)
		Pawn(Owner).bAltFire = int(FRand() < AltReFireRate);
		if (clipcount >= 20&&slaveclipcount < 20&&slavemag != none&&ifireagun == 1) { //we need to sleep to let it catch up.....
			sleep(0.13);
			ifireagun = 0;
		}
		Goto('Repeater');
	}
	if (/*iFireAGun == 1 && */slavemag != None) slavemag.playaltend();
	Playaltend();
	FinishAnim();
	if (slavemag != None) slavemag.PlayAnim('T2', 0.9, 0.05);
	PlayAnim('T2', 0.9, 0.05);
	FinishAnim();
	Finish();
}

simulated function PlayIdleAnim() {
	local float randy;
	if (Mesh == PickupViewMesh) return;
	if (slavemag != none&&!slavemag.isinstate('newclip')&&!slavemag.isinstate('clientnewclip')) {
		randy = frand();
		if (randy > 0.95) slavemag.PlayAnim('Twiddle', 0.6, 0.3);
		else if (randy > 0.9) slavemag.PlayAnim('Twirl', 0.6);                     //I utilitized the unused twirl animation....
		else slavemag.LoopAnim('Sway1', 0.02, 0.3);
	}
	randy = frand();
	if (randy > 0.95) PlayAnim('Twiddle', 0.6, 0.3);
	else if (randy > 0.9) PlayAnim('Twirl', 0.6);                     //I utilitized the unused twirl animation....
	else LoopAnim('Sway1', 0.02, 0.3);
}
 /*
exec function reload() {
      if ((20 - clipcount < AmmoType.AmmoAmount)&&(clipcount != 0)&&Isinstate('idle')) {            //we don't want to reload if all the ammo is actually IN the clip...
      //had problems reloading both....  h4x....  we can't let it reload if that's all the ammo (i.e. all ammo is in clips)
      Gotostate ('Newclip');
      reloadnow = true;
      } }

simulated event tick(float deltatime) {
if (Role < role_authority&&reloadnow) {
reloadnow = false;
gotostate ('clientnewclip'); } } */
simulated function Tick(float deltatime) {
	local bool mastertostate;
	if (isslave || role == role_authority) return;        //do not do a tick on the slave....

	if (slavemag == none) { //simple reload
		if (Playerpawn(owner) != None && (PlayerPawn(Owner).bExtra3 != 0)
				&& (20 - clipcount < AmmoType.AmmoAmount) && (clipcount != 0) && bcanclientfire
				&& !(Isinstate('clientfiring')) && !Isinstate('clientaltfiring') && !Isinstate('clientnewclip')) {   //play the anim and goto the state
			Gotostate('clientnewclip');
		}
	} else { //complex reload...
		if (Playerpawn(owner) != None && (PlayerPawn(Owner).bExtra3 != 0)
				&& (40 - (clipcount + slaveclipcount) < ammotype.ammoamount) && (clipcount != 0) && bcanclientfire
				&& !(Isinstate('clientfiring')) && !Isinstate('clientaltfiring') && !Isinstate('clientnewclip')) {
			Gotostate('clientnewclip');
			mastertostate = true;
		} else if (Playerpawn(owner) !=None && (PlayerPawn(Owner).bExtra3 != 0)
				&&(40 - (clipcount + slaveclipcount) < ammotype.ammoamount) && (slaveclipcount != 0) && bcanclientfire
				&& !(Isinstate('clientfiring')) && !Isinstate('clientaltfiring') && !Isinstate('clientnewclip')) {
			if (!mastertostate) slavemag.gotostate('clientnewclip');
			else slaverequestreload = true;
		}
	}
}

state Idle {
  function AnimEnd() {
    PlayIdleAnim();
  }

  function bool PutDown() {
    GotoState('DownWeapon');
    return True;
  }

  //tick tock tick tock....the timer is too slow (1.5 sec) and used for waiting anyway, so we got tick used to detect reload calls...
  event Tick(float DeltaTime) {
  /*global.tick(deltatime);
        if ((Pawn(Owner)!=None)&&(Playerpawn(owner)==None)) {
        if ((20 - clipcount < AmmoType.AmmoAmount)&&(Pawn(Owner).enemy == None)&&(clipcount != 0))            //we don't want to reload if all the ammo is actually IN the clip...
      //had problems reloading both....  h4x....  we can't let it reload if that's all the ammo (i.e. all ammo is in clips)
      Gotostate ('Newclip');  }           just reload the damn thing......       */

		local bool mastertostate;
		if (ammotype == none) {
			log("ammotype fawked up!");
			return;
		}
		if (pawn(owner) == none) return;
		if (isslave) return; //do not tick the slave.....
		if (slavemag == none) { //simple reload
			if (((Playerpawn(owner) != None && (bwantreload || playerpawn(owner).bextra3 != 0))
			  	|| (Playerpawn(owner) == None && Pawn(Owner).enemy == None))
			  	&& (20 - clipcount < AmmoType.AmmoAmount) && (clipcount != 0)) {   //play the anim and goto the state
				Gotostate('newclip');
			}
		}	else { //complex reload...
			if (((Playerpawn(owner) ! =None && (bwantreload || playerpawn(owner).bextra3 != 0))
			  	|| (Playerpawn(owner) == None&&Pawn(Owner).enemy == None))
			  	&& (40 - (clipcount + slaveclipcount) < ammotype.ammoamount) && (clipcount != 0)) {
				Gotostate('newclip');
				mastertostate = true;
			}
			if (((Playerpawn(owner) != None && (bwantreload || playerpawn(owner).bextra3 != 0))
			  	|| (Playerpawn(owner) == None && Pawn(Owner).enemy == None))
			  	&& (40 - (clipcount + slaveclipcount) < ammotype.ammoamount) && (slaveclipcount != 0)) {
				if (!mastertostate) slavemag.gotostate('newclip');
				else slaverequestreload = true;
			}
		}
  }

Begin:
  bPointing = False;
  if ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
  //Disable('AnimEnd');
  if (slavemag != None && !slavemag.isinstate('newclip')) slavemag.LoopAnim('Sway1', 0.02, 0.1);
  LoopAnim('Sway1', 0.02, 0.1);
  if (Pawn(Owner).bFire != 0) Global.Fire(0.0);
  if (Pawn(Owner).bAltFire != 0) Global.AltFire(0.0);
}

///akimbo specific stuff......
function SetDisplayProperties(ERenderStyle NewStyle, texture NewTexture, bool bLighting, bool bEnviroMap) { //set properties for the slave
  if (!bSetup) {
    bSetup = true;
    if (Slavemag != None) Slavemag.SetDisplayProperties(NewStyle, NewTexture, bLighting, bEnviromap);
    bSetup = false;
  }      
  Super.SetDisplayProperties(NewStyle, NewTexture, bLighting, bEnviromap);
}

function SetDefaultDisplayProperties() {
  if (!bSetup) {
    bSetup = true;
    if (Slavemag != None) Slavemag.SetDefaultDisplayProperties();
    bSetup = false;
  }
  Super.SetDefaultDisplayProperties();
}

event float BotDesireability(Pawn Bot) { //bots like it better with akimbo :D
  local OLautomag AlreadyHas;
  local float desire;

  desire = MaxDesireability + Bot.AdjustDesireFor(self);
  AlreadyHas = OLautomag(Bot.FindInventoryType(class));
  if (AlreadyHas != None) {
    if ((!bHeldItem || bTossedOut) && bWeaponStay) return 0;
    if (AlreadyHas.Slavemag != None) {
      if ((RespawnTime < 10)
        	&& (bHidden || (AlreadyHas.AmmoType == None)
          	|| (AlreadyHas.AmmoType.AmmoAmount < AlreadyHas.AmmoType.MaxAmmo))) {
       	return 0;
			}
      if (AlreadyHas.AmmoType == None) return 0.25 * desire;

      if (AlreadyHas.AmmoType.AmmoAmount > 0) {
        return FMax(
        	0.25 * desire,
        	AlreadyHas.AmmoType.MaxDesireability * FMin(1, 0.15 * AlreadyHas.AmmoType.MaxAmmo / AlreadyHas.AmmoType.AmmoAmount)
				);
		 	}
    }
  }

  if ((Bot.Weapon == None) || (Bot.Weapon.AIRating <= 0.4)) return 2 * desire;

  return desire;
}

//almighty double renderer :D
simulated event RenderOverlays(canvas Canvas) {
  local PlayerPawn PlayerOwner;
  local int realhand;

  PlayerOwner = PlayerPawn(Owner);
  if (PlayerOwner != None) {
    if (PlayerOwner.DesiredFOV != PlayerOwner.DefaultFOV) return;
    realhand = PlayerOwner.Handedness;
    if ((Level.NetMode == NM_Client) && (realHand == 2)) {
      bHideWeapon = true;
      return;
    }
    if (!bHideWeapon) {
      if (Mesh == mesh'AutoMagL') PlayerOwner.Handedness = 1;
      else if (/* bIsSlave || */(Slavemag != None)) PlayerOwner.Handedness = -1;
    }
  }
  if (!bHideWeapon && ((Slavemag != None) /*|| bIsSlave*/)) {
    Super.RenderOverlays(Canvas);
    if (Slavemag != None) {
      Slavemag.RenderOverlays(Canvas);
    }
  } else Super.RenderOverlays(Canvas);

  if (PlayerOwner != None) PlayerOwner.Handedness = realhand;
}

//more stuff for akimbo......
simulated function TweenDown() {
  if (slavemag != None) {
    if ((slavemag.AnimSequence != '') && (slavemag.GetAnimGroup(slavemag.AnimSequence) == 'Select')) {
      TweenAnim(slavemag.AnimSequence, slavemag.AnimFrame * 0.4);
    } else {
      slavemag.PlayAnim('Down', 1.0, 0.05);
		}
  }
  if ((AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select')) {
    TweenAnim(AnimSequence, AnimFrame * 0.4);
  } else {
    PlayAnim('Down', 1.0, 0.05);
	}
}

simulated function TweenSelect() {
  if (slavemag != None) slavemag.TweenAnim('Select', 0.001);
  TweenAnim('Select', 0.001);
}

simulated function PlaySelect() {
  if (slavemag != None) slavemag.PlayAnim('Select', 1.0, 0.0);
  Super.PlaySelect();
}

defaultproperties {
     hitdamage=17
     wepcanreload=True
     WeaponDescription="Classification: Automatic Magnum"
     InstFlash=-0.200000
     InstFog=(X=325.000000, Y=225.000000, Z=95.000000)
     AmmoName=Class'UnrealShare.ShellBox'
     PickupAmmoCount=20
     bInstantHit=True
     bAltInstantHit=True
     FiringSpeed=1.500000
     FireOffset=(Y=-10.000000, Z=-4.000000)
     MyDamageType=shot
     shakemag=200.000000
     shakevert=4.000000
     AIRating=0.200000
     RefireRate=0.700000
     AltRefireRate=0.900000
     FireSound=Sound'UnrealShare.AutoMag.shot'
     AltFireSound=Sound'UnrealShare.AutoMag.shot'
     CockingSound=Sound'UnrealShare.AutoMag.Cocking'
     SelectSound=Sound'UnrealShare.AutoMag.Cocking'
     Misc1Sound=Sound'UnrealShare.flak.Click'
     Misc2Sound=Sound'UnrealShare.AutoMag.Reload'
     DeathMessage="%o got gatted by %k's %w."
     NameColor=(R=200, G=200)
     AutoSwitchPriority=2
     InventoryGroup=2
     PickupMessage="You got the AutoMag"
     ItemName="Automag"
     PlayerViewOffset=(X=4.800000, Y=-1.700000, Z=-2.700000)
     PlayerViewMesh=LodMesh'UnrealShare.AutoMagL'
     PickupViewMesh=LodMesh'UnrealShare.AutoMagPickup'
     ThirdPersonMesh=LodMesh'UnrealShare.auto3rd'
     StatusIcon=Texture'Botpack.Icons.UseAutoM'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Icon=Texture'Botpack.Icons.UseAutoM'
     Mesh=LodMesh'UnrealShare.AutoMagPickup'
     bNoSmooth=False
     CollisionRadius=25.000000
     CollisionHeight=10.000000
     Mass=15.000000
}
