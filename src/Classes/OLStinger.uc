// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.OLstinger: Network/decal stinger....
// ============================================================

class OLstinger extends UIweapons;

var bool bAlreadyFiring, idleplaying;

// ============================================================
// Set priority to same as the UT version - Shrimp

function SetSwitchPriority(pawn Other) {
	local int i;

	if (PlayerPawn(Other) != None) {
		for (i = 0; i < 20; i++)
			if (PlayerPawn(Other).WeaponPriority[i] == 'PulseGun') {
				AutoSwitchPriority = i;
				return;
			}

	}
}

//
// ===========================================================

function bool HandlePickupQuery(inventory Item) {
	//bpreventclientfire = false; //ensure that it's set to false....
	return Super.HandlePickupQuery(Item);
}
//simply plays the rapid fire animation......
function Fire(float Value) {
	if ((AmmoType == None) && (AmmoName != None)) {
		// ammocheck
		GiveAmmo(Pawn(Owner));
	}
	if (AmmoType.UseAmmo(1)) {
		GotoState('NormalFire');
		bPointing = True;
		bCanClientFire = true;
		ClientFire(Value);
		Pawn(Owner).PlayRecoil(FiringSpeed);
		ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
	}
}
function float RateSelf(out int bUseAltMode) {
	local float EnemyDist;

	if (AmmoType.AmmoAmount <=0)
		return -2;
	if (Pawn(Owner).Enemy == None) {
		bUseAltMode = 0;
		return AIRating;
	}

	EnemyDist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
	bUseAltMode = int(600 * FRand() > EnemyDist - 140);
	return AIRating;
}

simulated function PlayFiring() { //if (bclientfireallowed) {
	if (bAlreadyFiring) {
		AmbientSound = sound'StingerTwoFire';
		SoundVolume = Pawn(Owner).SoundDampening * 255;
		LoopAnim('FireOne', 0.7);
	} else {
		PlayOwnedSound(FireSound, SLOT_Misc, 2.0 * Pawn(Owner).SoundDampening);
		PlayAnim('FireOne', 0.7);
	}
	bAlreadyFiring = true;
	bWarnTarget = (FRand() < 0.2); // }
}

simulated function PlayAltFiring() {
	//if (bclientfireallowed) {
	PlayOwnedSound(AltFireSound, SLOT_Misc, 2.0 * Pawn(Owner).SoundDampening);
	PlayAnim('FireOne', 0.6);//}
}

///////////////////////////////////////////////////////
state ClientAltFiring                                   { //notcode stuff....
	simulated function timer() {
	idleplaying = false;
	if ((Pawn(Owner) == None)
			|| ((AmmoType != None) && (AmmoType.AmmoAmount <= 0))) {
			PlayIdleAnim();
			GotoState('');
		} else if (!bCanClientFire)
			Gotostate ('');
		else if ((Pawn(Owner).bFire != 0)) {          //animation stuff......
			Global.ClientFire(0);  } else if ((Pawn(Owner).bAltFire != 0)) {       //will simply play idle anim if not...
			Global.ClientAltFire(0);    } else {
			PlayIdleAnim();
			GotoState('');
		}}
	simulated function AnimEnd() {
		Playidleanim();
		if (!idleplaying)
		settimer (1.0, false);
		idleplaying = true;
		}
}

state clientfiring { //anim control......
simulated function EndState() {
		if (AmbientSound != None&&Owner != none) Owner.PlayownedSound(Misc1Sound, SLOT_Misc, 2.0 * Pawn(Owner).SoundDampening);
		AmbientSound = None;
		bAlreadyFiring = false;
		Super.EndState();
	}
}
state NormalFire {          ignores animend;

	function Tick(float DeltaTime) {
		if (Owner == None) AmbientSound = None;
		else
			SetLocation(Owner.Location);
	}

	function EndState() {
		if (AmbientSound != None && Owner != None) Owner.PlaySound(Misc1Sound, SLOT_Misc, 2.0 * Pawn(Owner).SoundDampening);
		AmbientSound = None;
		bAlreadyFiring = false;
		Super.EndState();
	}

Begin:
	Sleep(0.2);
	SetLocation(Owner.Location);
	Finish();
}

///////////////////////////////////////////////////////////////
state AltFiring { ignores animend;
	function Projectile ProjectileFire(class < projectile> ProjClass, float ProjSpeed, bool bWarn) {
		local Projectile S;
		local int i;
		local vector Start;
		local Rotator StartRot, AltRotation;

		S = Global.ProjectileFire(ProjClass, ProjSpeed, bWarn);
		StartRot = S.Rotation;
		Start = S.Location;
		for (i = 0; i< 4; i++) {
			if (AmmoType.UseAmmo(1)) {
				AltRotation = StartRot;
				AltRotation.Pitch += FRand() * 3000 - 1500;
				AltRotation.Yaw += FRand() * 3000 - 1500;
				AltRotation.Roll += FRand() * 9000 - 4500;
				S = Spawn(AltProjectileClass, ,, Start - 2 * VRand(), AltRotation);
			}
		}
		StingerProjectile(S).bLighting = True;
		return S;
	}

Begin:
	FinishAnim();
	// bpreventclientfire = true;
	PlayIdleAnim();
	//animations only var.  clientcanfire would actually screw this up......
	Sleep(1.0);
	Finish();
// bpreventclientfire	 = false;
}

///////////////////////////////////////////////////////////
simulated function PlayIdleAnim() {
	PlayAnim('Still', ,0.05);
}

defaultproperties {
	WeaponDescription="Classification: Tarydium Shard Launcher"
	AmmoName=Class'UnrealShare.StingerAmmo'
	PickupAmmoCount=40
	bAltWarnTarget=True
	bSpecialIcon=False
	FireOffset=(X=12.000000,Y=-10.000000,Z=-15.000000)
	ProjectileClass=Class'{{package}}.OSStingerProjectile'
	AltProjectileClass=Class'{{package}}.OSStingerProjectile'
	shakemag=120.000000
	AIRating=0.400000
	RefireRate=0.800000
	FireSound=Sound'UnrealShare.Stinger.StingerFire'
	AltFireSound=Sound'UnrealShare.Stinger.StingerAltFire'
	SelectSound=Sound'UnrealShare.Stinger.StingerLoad'
	Misc1Sound=Sound'UnrealShare.Stinger.EndFire'
	DeathMessage="%o was perforated by %k's %w."
	AutoSwitchPriority=3
	InventoryGroup=3
	PickupMessage="You picked up the Stinger"
	ItemName="Stinger"
	PlayerViewOffset=(X=4.200000,Y=-3.000000,Z=-4.000000)
	PlayerViewMesh=LodMesh'UnrealShare.StingerM'
	PlayerViewScale=1.700000
	PickupViewMesh=LodMesh'UnrealShare.StingerPickup'
	ThirdPersonMesh=LodMesh'UnrealShare.Stinger3rd'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Mesh=LodMesh'UnrealShare.StingerPickup'
	bNoSmooth=False
	SoundRadius=64
	SoundVolume=255
	CollisionRadius=27.000000
	CollisionHeight=8.000000
}
