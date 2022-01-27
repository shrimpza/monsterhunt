// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.OLDpistol: the NEW pistol... well..bot really :D
// ============================================================

class OLDpistol extends UIweapons;

var travel int PowerLevel, clientpowerlevel;
var vector WeaponPos;
var float Count, ChargeSize;
var ChargeLight cl1, cl2;
var Pickup Amp;
var Sound PowerUpSound;
var bool bburst;    //client-side var ensureing proper timing.....

replication   { //to ensure that the powerlevels work :D
	reliable if (bNetOwner && (Role == ROLE_Authority))     //server send to client
		powerlevel;
}

// ============================================================
// Set priority to same as the UT version - Shrimp

function SetSwitchPriority(pawn Other) {
	local int i;

	if (PlayerPawn(Other) != None) {
		for (i = 0; i < 20; i++)
			if (PlayerPawn(Other).WeaponPriority[i] == 'ImpactHammer') {
				AutoSwitchPriority = i;
				return;
			}

	}
}

//
// ===========================================================

function float RateSelf(out int bUseAltMode) {
	local float rating;

	if (Amp != None)
		rating = 6 * AIRating;
	else
		rating = AIRating;

	if (AmmoType.AmmoAmount <=0)
		return 0.05;
	if (Pawn(Owner).Enemy == None) {
		bUseAltMode = 0;
		return rating * (PowerLevel + 1);
	}
	bUseAltMode = int(FRand() < 0.3);
		// splash damage should be used if we are higher than the target, but definitely not if we're lower...
	if ((Owner.Location.Z > Pawn(owner).Enemy.Location.Z + 120))
		bUseAltMode = 1;
	else if (Pawn(owner).Enemy.Location.Z > Owner.Location.Z + 120)
		bUseAltMode = 0;
	if (powerlevel > 2) //always use primary if the power is high...
	bUseAltMode = 0;
	return rating * (PowerLevel + 1);
}

// return delta to combat style
function float SuggestAttackStyle() {
	if (!Pawn(Owner).bIsPlayer || (PowerLevel > 0))
		return 0;

	return -0.3;
}

function bool HandlePickupQuery(inventory Item) {
	if (Item.IsA('osWeaponPowerup') || Item.IsA('WeaponPowerup')) {
		AmmoType.AddAmmo(AmmoType.MaxAmmo);
		Pawn(Owner).ClientMessage(Item.PickupMessage, 'Pickup');
		Item.PlaySound (PickupSound);
		if (PowerLevel < 4) {
			ShakeVert = Default.ShakeVert + PowerLevel;
			PowerUpSound = Item.ActivateSound;
			if (Pawn(Owner).Weapon == self) {
				PowerLevel++;
				GotoState('PowerUp');
			} else if ((Pawn(Owner).Weapon != Self) && !Pawn(Owner).bNeverSwitchOnPickup) {
				Pawn(Owner).Weapon.PutDown();
				Pawn(Owner).PendingWeapon = self;
				GotoState('PowerUp', 'Waiting');
			} else PowerLevel++;
		}
		Item.SetRespawn();
		return true;
	} else return Super.HandlePickupQuery(Item);
}

simulated function tick(float deltatime) {       //ticker for client - powerups
if (clientpowerlevel != powerlevel&&Role < role_authority) {
clientpowerlevel = powerlevel;
Gotostate ('clientpowerup');
disable('tick');       }
}
function BecomePickup() {
	Amp = None;
	Super.BecomePickup();
}

simulated function PlayFiring() {
	AmmoType.GoToState('Idle2');
	Owner.PlaySound(AltFireSound, SLOT_None, 1.8 * Pawn(Owner).SoundDampening, ,, 1.2);
	if (PlayerPawn(Owner) != None)
		PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
	if (PowerLevel == 0)
		PlayAnim('Shoot1', 0.4, 0.2);
	else if (PowerLevel == 1)
		PlayAnim('Shoot2', 0.3, 0.2);
	else if (PowerLevel == 2)
		PlayAnim('Shoot3', 0.2, 0.2);
	else if (PowerLevel == 3)
		PlayAnim('Shoot4', 0.1, 0.2);
	else if (PowerLevel == 4)
		PlayAnim('Shoot5', 0.1, 0.2);
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn) {
	local Vector Start, X, Y, Z;
	local DispersionAmmo da;
	local float Mult;

	Owner.MakeNoise(Pawn(Owner).SoundDampening);

	if (Amp != None) Mult = Amp.UseCharge(80);
	else Mult = 1.0;

	GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, (3.5 * FRand() - 1 < PowerLevel));
	if ((PowerLevel == 0) || (AmmoType.AmmoAmount < 10)) {
		da = DispersionAmmo(Spawn(ProjClass, ,, Start, AdjustedAim));
		if ((AmmoType.AmmoAmount < 1) && Level.Game.bDeathMatch)
			AmmoType.AmmoAmount = 1;
	} else {
		if ((PowerLevel == 1) && AmmoType.UseAmmo(2))
			da = Spawn(class'{{package}}.OSDAmmo2', ,, Start, AdjustedAim);
		if ((PowerLevel == 2) && AmmoType.UseAmmo(4))
			da = Spawn(class'{{package}}.OSDAmmo3', ,, Start, AdjustedAim);
		if ((PowerLevel == 3) && AmmoType.UseAmmo(5))
			da = Spawn(class'{{package}}.OSDAmmo4', ,, Start, AdjustedAim);
		if ((PowerLevel >= 4) && AmmoType.UseAmmo(6))
			da = Spawn(class'{{package}}.OSDAmmo5', ,, Start, AdjustedAim);
	}
	if ((da != None) && (Mult > 1.0))
		da.InitSplash(Mult);

	return da;
}

function AltFire(float Value) {
	bPointing = True;
	CheckVisibility();
	bCanClientFire = true;
	ClientAltFire(Value);
	GoToState('AltFiring');
}

////////////////////////////////////////////////////////
state AltFiring {
ignores AltFire, animend;

	function Tick(float DeltaTime) {
		if (Level.NetMode == NM_StandAlone || (Level.Netmode == NM_listenserver&&owner.role == Role_authority)) { //don't let this happen in netgames....  (that is called by clientaltfire)
			PlayerViewOffset.X = WeaponPos.X + FRand() * ChargeSize * 7;
			PlayerViewOffset.Y = WeaponPos.Y + FRand() * ChargeSize * 7;
			PlayerViewOffset.Z = WeaponPos.Z + FRand() * ChargeSize * 7;
		}
		ChargeSize += DeltaTime;
		if ((pawn(Owner).bAltFire == 0)) GoToState('ShootLoad');
		Count += DeltaTime;
		if (Count > 0.3) {
			Count = 0.0;
			if (!AmmoType.UseAmmo(1)) GoToState('ShootLoad');
			AmmoType.GoToState('Idle2');
		}
	}

	function EndState() {
		if (Level.NetMode == NM_StandAlone || (Level.Netmode == NM_listenserver&&owner.role == Role_authority))
		PlayerviewOffset = WeaponPos;
		if (cl1 != None) cl1.Destroy();
		if (cl2 != None) cl2.Destroy();
	}

	function BeginState() {
		if (Level.NetMode == NM_StandAlone || (Level.Netmode == NM_listenserver&&owner.role == Role_authority))
		WeaponPos = PlayerviewOffset;
		ChargeSize = 0.0;
	}

Begin:
	if (AmmoType.UseAmmo(1)) {
		//Owner.Playsound(Misc1Sound, SLOT_Misc, Pawn(Owner).SoundDampening*4.0);
		Count = 0.0;
		Sleep(2.0 + 0.6 * PowerLevel);
		GoToState('ShootLoad');
	} else GotoState('Idle');

}
simulated function playaltfiring() { //play misc sound
Playownedsound(Misc1Sound, SLOT_Misc, Pawn(Owner).SoundDampening * 4.0);
}
///////////////////////////////////////////////////////////
state ClientAltFiring        { //client - side animations.....
	simulated function Tick(float DeltaTime) {
	if (clientpowerlevel != powerlevel)
		Gotostate ('clientpowerup');
		if (bBurst)    //don't run!!!!
			return;
		//if (isinstate('clientaltfiring')) { //verify we want to do this.......
		PlayerViewOffset.X = WeaponPos.X + FRand() * ChargeSize * 7;            //allow offsets to change....
		PlayerViewOffset.Y = WeaponPos.Y + FRand() * ChargeSize * 7;
		PlayerViewOffset.Z = WeaponPos.Z + FRand() * ChargeSize * 7;
		ChargeSize += DeltaTime;
		if (!bCanClientFire || (Pawn(Owner) == None))
			GotoState('');
		else if (Pawn(Owner).bAltFire == 0 || Ammotype.ammoamount <= 0 || chargesize >=(2.0 + 0.6 * PowerLevel)) {
			Playshootload();
			bburst = true;
			PlayerviewOffset = weaponpos;
		}

	} //  }
	simulated function AnimEnd() { //when shootload is done......
		if (bBurst) {
			bBurst = false;
			chargesize = 0.0;
			if ((Pawn(Owner) == None)
			|| ((AmmoType != None) && (AmmoType.AmmoAmount <= 0))) {
			PlayIdleAnim();
			GotoState('');
		} else if (!bCanClientFire)
			GotoState('');
		else if (Pawn(Owner).bFire != 0)
			Global.ClientFire(0);
		else if (Pawn(Owner).bAltFire != 0)
			Global.ClientaltFire(0);
		else {
			PlayIdleAnim();
			GotoState('');
		}

		} }
	simulated function endstate() {
	super.endstate();
	//disable('tick');
	PlayerviewOffset = weaponpos;
	}
	simulated function beginstate() {
	super.beginstate();
	//enable('tick');
	chargesize = 0.0;
	weaponpos = PlayerviewOffset;
	}
}
simulated function Playshootload() {
		PlayOwnedSound(AltFireSound, SLOT_Misc, 1.8 * Pawn(Owner).SoundDampening);
		if (PlayerPawn(Owner) != None)
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag * ChargeSize, ShakeVert);
		if (PowerLevel == 0) PlayAnim('Shoot1', 0.2, 0.05);
		else if (PowerLevel == 1) PlayAnim('Shoot2', 0.2, 0.05);
		else if (PowerLevel == 2) PlayAnim('Shoot3', 0.2, 0.05);
		else if (PowerLevel == 3) PlayAnim('Shoot4', 0.2, 0.05);
		else if (PowerLevel == 4) PlayAnim('Shoot5', 0.2, 0.05);
		Owner.MakeNoise(Pawn(Owner).SoundDampening);}

state ShootLoad {
	function Fire(float F) {}
	function AltFire(float F) {}

	function BeginState() {
		local DispersionAmmo d;
		local Vector Start, X, Y, Z;
		local float Mult;

		if (Amp != None) Mult = Amp.UseCharge(ChargeSize * 50 + 50);
		else Mult = 1.0;
		Playshootload();
		GetAxes(Pawn(owner).ViewRotation, X, Y, Z);
		Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		AdjustedAim = pawn(owner).AdjustAim(AltProjectileSpeed, Start, AimError, True, True);
		d = DispersionAmmo(Spawn(AltProjectileClass, ,, Start, AdjustedAim));
		if (d != None) {
			d.bAltFire = True;
			d.DrawScale = 0.5 + ChargeSize * 0.6;
			d.InitSplash(d.DrawScale * Mult * 1.1);
		}
	}
Begin:
	FinishAnim();
	Finish();
}


///////////////////////////////////////////////////////////
simulated function PlayIdleAnim() {
	if (PowerLevel == 0) LoopAnim('Idle1', 0.04, 0.2);
	else if (PowerLevel == 1) LoopAnim('Idle2', 0.04, 0.2);
	else if (PowerLevel == 2) LoopAnim('Idle3', 0.04, 0.2);
	else if (PowerLevel == 3) LoopAnim('Idle4', 0.04, 0.2);
	else if (PowerLevel == 4) LoopAnim('Idle5', 0.04, 0.2);
}

simulated function PlayPowerup() {
	if (PowerLevel < 5)
			PlayOwnedSound(PowerUpSound, SLOT_None, Pawn(Owner).SoundDampening);
		if (PowerLevel == 1)
			PlayAnim('PowerUp1', 0.1, 0.05);
		else if (PowerLevel == 2)
			PlayAnim('PowerUp2', 0.1, 0.05);
		else if (PowerLevel == 3)
			PlayAnim('PowerUp3', 0.1, 0.05);
		else if (PowerLevel == 4)
			PlayAnim('PowerUp4', 0.1, 0.05);
}
///////////////////////////////////////////////////////
state Clientpowerup { //client - side anims.....
	simulated function bool ClientFire(float Value) {
		bForceFire = bForceFire || (bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0));
		return bForceFire;
	}

	simulated function tick(float deltatime) {     //ticker to detect mid - anim powerlevel chages
	if (powerlevel != clientpowerlevel)
	clientpowerlevel = powerlevel;
	Playpowerup(); //replay anim...
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
		clientpowerlevel = powerlevel;
		Playpowerup();
		Enable('tick');
		bForceFire = false;
		bForceAltFire = false;
	}
}

state PowerUp {
ignores fire, altfire, clientfire, clientaltfire;

	function BringUp() {
		bWeaponUp = false;
		PlaySelect();
		GotoState('Powerup', 'Raising');
	}

	function bool PutDown() {
		bChangeWeapon = true;
		return True;
	}

	function BeginState() {
		bChangeWeapon = false;
	}

Raising:
	FinishAnim();
	PowerLevel++;
Begin:
	if (PowerLevel < 5) {
		AmmoType.MaxAmmo += 10;
		AmmoType.AddAmmo(10);
		PlayPowerUp();
		FinishAnim();
		if (bChangeWeapon)
			GotoState('DownWeapon');
		else
		Finish();
	}
Waiting:
}

simulated function TweenDown() {
	if (GetAnimGroup(AnimSequence) == 'Select')
		TweenAnim(AnimSequence, AnimFrame * 0.4);
	else {
		if (PowerLevel == 0) PlayAnim('Down1', 1.0, 0.05);
		else if (PowerLevel == 1) PlayAnim('Down2', 1.0, 0.05);
		else if (PowerLevel == 2) PlayAnim('Down3', 1.0, 0.05);
		else if (PowerLevel == 3) PlayAnim('Down4', 1.0, 0.05);
		else if (PowerLevel == 4) PlayAnim('Down5', 1.0, 0.05);
	}
}

simulated function TweenSelect() {
	TweenAnim('Select1', 0.001);
}

simulated function PlaySelect() {
	if (Level.Netmode !=NM_StandAlone)
	Enable('tick');
	Owner.PlaySound(SelectSound, SLOT_None, Pawn(Owner).SoundDampening);
	if (PowerLevel == 0) PlayAnim('Select1', 0.5, 0.0);
	else if (PowerLevel == 1) PlayAnim('Select2', 0.5, 0.0);
	else if (PowerLevel == 2) PlayAnim('Select3', 0.5, 0.0);
	else if (PowerLevel == 3) PlayAnim('Select4', 0.5, 0.0);
	else if (PowerLevel == 4) PlayAnim('Select5', 0.5, 0.0);
}

defaultproperties {
	WeaponDescription="Classification: Energy Pistol"
	AmmoName=Class'UnrealShare.DefaultAmmo'
	PickupAmmoCount=50
	bAltWarnTarget=True
	bSpecialIcon=False
	FireOffset=(X=12.000000,Y=-8.000000,Z=-15.000000)
	ProjectileClass=Class'{{package}}.OSDispersionAmmo'
	AltProjectileClass=Class'{{package}}.OSDispersionAmmo'
	shakemag=200.000000
	shaketime=0.130000
	shakevert=2.000000
	RefireRate=0.850000
	AltRefireRate=0.300000
	FireSound=Sound'UnrealShare.Dispersion.DispShot'
	AltFireSound=Sound'UnrealShare.Dispersion.DispShot'
	SelectSound=Sound'UnrealShare.Dispersion.DispPickup'
	Misc1Sound=Sound'UnrealShare.Dispersion.PowerUp3'
	DeathMessage="%o was killed by %k's %w.  What a loser!"
	PickupMessage="You got the Dispersion Pistol"
	ItemName="Dispersion Pistol"
	PlayerViewOffset=(X=3.800000,Y=-2.000000,Z=-2.000000)
	PlayerViewMesh=LodMesh'UnrealShare.DPistol'
	PickupViewMesh=LodMesh'UnrealShare.DPistolPick'
	ThirdPersonMesh=LodMesh'UnrealShare.DPistol3rd'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Texture=None
	Mesh=LodMesh'UnrealShare.DPistolPick'
	bNoSmooth=False
	CollisionRadius=28.000000
	CollisionHeight=8.000000
	Mass=15.000000
}
