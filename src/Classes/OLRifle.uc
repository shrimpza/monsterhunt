// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.Olrifle: the rifle.....       with HUD crosshair since the rifle disappears anyway....
// ============================================================

class Olrifle extends UIweapons;

var int NumFire;
var float StillTime, StillStart;
var vector OwnerLocation;

// ============================================================
// Set priority to same as the UT version - Shrimp

function SetSwitchPriority(pawn Other) {
	local int i;

	if (PlayerPawn(Other) != None) {
		for (i = 0; i < 20; i++)
			if (PlayerPawn(Other).WeaponPriority[i] == 'SniperRifle') {
				AutoSwitchPriority = i;
				return;
			}

	}
}

//
// ===========================================================

simulated function TweenDown() {
	if (IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select'))
		TweenAnim(AnimSequence, AnimFrame * 0.4);
	else if ((playerpawn(owner) != None)&&(Playerpawn(Owner).DesiredFOV != Playerpawn(Owner).DefaultFOV))
		PlayAnim('DownWscope', 1.0, 0.05);           //yeah!!
	else PlayAnim('Down', 1.0, 0.05);
}
function float RateSelf(out int bUseAltMode) {                 //from UT snipey rifle...
	local float dist;

	if (AmmoType.AmmoAmount <=0)
		return -2;

	bUseAltMode = 0;
	if ((Bot(Owner) != None) && Bot(Owner).bSniping)
		return AIRating + 1.15;
	if (Pawn(Owner).Enemy != None) {
		dist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
		if (dist > 1200) {
			if (dist > 2000)
				return (AIRating + 0.75);
			return (AIRating + FMin(0.0001 * dist, 0.45));
		}
	}
	return AIRating;
}

function AltFire(float Value) {
		ClientAltFire(Value);
}

simulated function bool ClientAltFire(float Value) {
	// PlayAltFiring(); // fix zoom bug https://ut99.org/viewtopic.php?f=4&t=14512
	GotoState('Zooming');
	return true;
}
///////////////////////////////////////////////////////
state NormalFire {
	function Fire(float F) {
	}

	function AltFire(float F) {
	}

Begin:
	FinishAnim();
	Finish();
}

function Timer() {
	local actor targ;
	local float bestAim, bestDist;
	local vector FireDir;

	bestAim = 0.95;
	if (Pawn(Owner) == None) {
		GotoState('');
		return;
	}
	if (VSize(Pawn(Owner).Location - OwnerLocation) < 6)
		StillTime += FMin(2.0, Level.TimeSeconds - StillStart);

	else
		StillTime = 0;
	StillStart = Level.TimeSeconds;
	OwnerLocation = Pawn(Owner).Location;
	FireDir = vector(Pawn(Owner).ViewRotation);
	targ = Pawn(Owner).PickTarget(bestAim, bestDist, FireDir, Owner.Location);
	if (Pawn(targ) != None) {
		SetTimer(1 + 4 * FRand(), false);
		bPointing = true;
		Pawn(targ).WarnTarget(Pawn(Owner), 200, FireDir);
	} else {
		SetTimer(0.4 + 1.6 * FRand(), false);
		if ((Pawn(Owner).bFire == 0) && (Pawn(Owner).bAltFire == 0))
		bPointing = false;
	}
}  

simulated function PlayAltFiring() { //uses the 1337 scope, man!!!!!!!
	if (Playerpawn(Owner).DesiredFOV != Playerpawn(Owner).DefaultFOV)    //if not then we want to scope down...
		PlayAnim('Scopedown', 3.0, 0.05);
	else
		PlayAnim('Scopeup', 3.0, 0.05);
}

/*simulated function PlayDownScope() { //uses the 1337 scope, man!!!!!!!
	PlayAnim('Scopedown', 3.0, 0.05);
}*/

simulated function PlayFiring() {
	PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening * 3.0);
	if ((playerpawn(owner) != None)&&(Playerpawn(Owner).DesiredFOV != Playerpawn(Owner).DefaultFOV))
	PlayAnim('ScopeFire', 0.56, 0.05);
	else
	PlayAnim('Fire', 0.7, 0.05);

}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z) {
	local shellcase s;

	if (PlayerPawn(Owner) != None) {
		PlayerPawn(Owner).ClientInstantFlash(-0.4, vect(650, 450, 190));
		if (PlayerPawn(Owner).DesiredFOV == PlayerPawn(Owner).DefaultFOV)
			bMuzzleFlash++;
	}

	s = Spawn(class'ShellCase', Pawn(Owner), '', Owner.Location + CalcDrawOffset() + 30 * X + (2.8 * FireOffset.Y + 5.0) * Y - Z * 1);
	if (s != None) {
		s.DrawScale = 2.0;
		s.Eject(((FRand() * 0.3 + 0.4) * X + (FRand() * 0.2 + 0.2) * Y + (FRand() * 0.3 + 1.0) * Z) * 160);
	}
	if (Other == Level)
		Spawn(class'OSHeavyWallHitEffect', ,, HitLocation + HitNormal * 9, Rotator(HitNormal));
	else if ((Other != self) && (Other != Owner) && (Other != None)) {
		if (Other.IsA('Pawn') && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
			&& (instigator.IsA('PlayerPawn') || (instigator.skill > 1))
			&& (!Other.IsA('ScriptedPawn') || !ScriptedPawn(Other).bIsBoss))
			Other.TakeDamage(100, Pawn(Owner), HitLocation, 35000 * X, 'decapitated');
		else
			Other.TakeDamage(45,  Pawn(Owner), HitLocation, 30000.0 * X, 'shot');
		if (!Other.IsA('Pawn') && !Other.IsA('Carcass'))
			spawn(class'SpriteSmokePuff', ,, HitLocation + HitNormal * 9);
	}
}

function Finish() {
	//bMuzzleFlash = 0;
	if (((Pawn(Owner).bFire != 0) || (Pawn(Owner).bAltFire != 0)) && (FRand() < 0.6))
		Timer();
	Super.Finish();
}

state Idle {

	function AltFire(float Value) {
		GoToState('Zooming');
	}

	function Fire(float Value) {
		if (AmmoType.UseAmmo(1)) {
			GotoState('NormalFire');
			bCanClientFire = true;
			if (PlayerPawn(Owner) != None)
				PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
			bPointing = True;
			//taken from sniper rifle: helps bot code :D
			if (Owner.IsA('Bot')) {
				// simulate bot using zoom
				if (Bot(Owner).bSniping && (FRand() < 0.65))
					AimError = AimError / FClamp(StillTime, 1.0, 8.0);
				else if (VSize(Owner.Location - OwnerLocation) < 6)
					AimError = AimError / FClamp(0.5 * StillTime, 1.0, 3.0);
				else
					StillTime = 0;
			}
			Pawn(Owner).PlayRecoil(FiringSpeed);
			TraceFire(0.0);
			ClientFire(Value);
			CheckVisibility();
		}
	}

	function BeginState() {
		if (Pawn(Owner).bFire != 0) Fire(0.0);
		bPointing = false;
		SetTimer(0.4 + 1.6 * FRand(), false);
		Super.BeginState();
	}

	function EndState() {
		SetTimer(0.0, false);
		Super.EndState();
	}

Begin:
	bPointing = False;
	if ((AmmoType != None) && (AmmoType.AmmoAmount <= 0))
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if (Pawn(Owner).bFire != 0) Fire(0.0);
	Disable('AnimEnd');
	PlayIdleAnim();
}

simulated event RenderOverlays(canvas Canvas) { //prevents the damn thing from hiding the sniper rifle, cause that's bad :D
	local rotator NewRot;
	local bool bPlayerOwner;
	local int Hand;
	local PlayerPawn PlayerOwner;

	if (bHideWeapon || (Owner == None))
		return;

	PlayerOwner = PlayerPawn(Owner);

	if (PlayerOwner != None) {
		bPlayerOwner = true;
		Hand = PlayerOwner.Handedness;

		if ((Level.NetMode == NM_Client) && (Hand == 2)) {
			bHideWeapon = true;
			return;
		}
	}

	if (!bPlayerOwner || (PlayerOwner.Player == None))
		Pawn(Owner).WalkBob = vect(0, 0, 0);

	if ((bMuzzleFlash > 0) && bDrawMuzzleFlash && Level.bHighDetailMode && (MFTexture != None)) {
		MuzzleScale = Default.MuzzleScale * Canvas.ClipX / 640.0;
		if (!bSetFlashTime) {
			bSetFlashTime = true;
			FlashTime = Level.TimeSeconds + FlashLength;
		} else if (FlashTime < Level.TimeSeconds)
			bMuzzleFlash = 0;
		if (bMuzzleFlash > 0) {
			if (Hand == 0)
				Canvas.SetPos(Canvas.ClipX / 2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipX * (-0.2 * Default.FireOffset.Y * FlashO), Canvas.ClipY / 2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipY * (FlashY + FlashC));
			else
				Canvas.SetPos(Canvas.ClipX / 2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipX * (Hand * Default.FireOffset.Y * FlashO), Canvas.ClipY / 2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipY * FlashY);

			Canvas.Style = 3;
			Canvas.DrawIcon(MFTexture, MuzzleScale);
			Canvas.Style = 1;
		}
	} else bSetFlashTime = false;

	SetLocation(Owner.Location + CalcDrawOffset());
	NewRot = Pawn(Owner).ViewRotation;

	if (Hand == 0)
		newRot.Roll = -2 * Default.Rotation.Roll;
	else
		newRot.Roll = Default.Rotation.Roll * Hand;

	setRotation(newRot);
	Canvas.DrawActor(self, false);
}

///////////////////////////////////////////////////////
//so it can zoom instantly like the UT one......
state Zooming {
simulated function Tick(float DeltaTime) {
	if (Pawn(Owner).bAltFire == 0) {
		if ((PlayerPawn(Owner) != None) && PlayerPawn(Owner).Player.IsA('ViewPort'))
			PlayerPawn(Owner).StopZoom();
		SetTimer(0.0, False);
		GoToState('Idle');
	}
}

simulated function BeginState() {
	if (Owner.IsA('PlayerPawn')) {
		if (PlayerPawn(Owner).Player.IsA('ViewPort'))
		PlayerPawn(Owner).ToggleZoom();
		SetTimer(0.075, True);
	} else {
		Pawn(Owner).bFire = 1;
		Pawn(Owner).bAltFire = 0;
		Global.Fire(0);
	}
}
}
///////////////////////////////////////////////////////////
simulated function PlayIdleAnim() {
	if (Mesh != PickupViewMesh) {
	if ((playerpawn(owner) != None)&&(Playerpawn(Owner).DesiredFOV != Playerpawn(Owner).DefaultFOV)&&Animsequence != 'scopeup')
	PlayAnim('StillScope', 1.0, 0.05);
	else if (animsequence != 'scopedown'&&animsequence != 'scopeup')
	PlayAnim('Still', 1.0, 0.05);  }
}

defaultproperties {
	WeaponDescription="Classification: Long-Range Ballistic"
	AmmoName=Class'UnrealI.RifleAmmo'
	PickupAmmoCount=8
	bInstantHit=True
	bAltInstantHit=True
	FireOffset=(Y=-5.000000,Z=-2.000000)
	MyDamageType=shot
	AltDamageType=Decapitated
	shakemag=400.000000
	shaketime=0.150000
	shakevert=8.000000
	AIRating=0.700000
	RefireRate=0.600000
	AltRefireRate=0.300000
	FireSound=Sound'UnrealI.Rifle.RifleShot'
	SelectSound=Sound'UnrealI.Rifle.RiflePickup'
	DeathMessage="%k put a bullet through %o's head."
	AutoSwitchPriority=9
	InventoryGroup=9
	PickupMessage="You got the Rifle"
	ItemName="Sniper Rifle"
	PlayerViewOffset=(X=3.200000,Y=-1.200000,Z=-1.700000)
	PlayerViewMesh=LodMesh'UnrealI.RifleM'
	PickupViewMesh=LodMesh'UnrealI.RiPick'
	ThirdPersonMesh=LodMesh'UnrealI.Rifle3rd'
	StatusIcon=Texture'Botpack.Icons.UseRifle'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Icon=Texture'Botpack.Icons.UseRifle'
	Mesh=LodMesh'UnrealI.RiPick'
	bNoSmooth=False
	CollisionRadius=28.000000
	CollisionHeight=8.000000
}
