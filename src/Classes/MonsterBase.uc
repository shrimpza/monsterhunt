//--[[[[----
// ============================================================
// MonsterBase
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2002 Kenneth "Shrimp" Watson
//          For more info, http://shrimpworks.za.net
//    Not to be modified without permission from the author
// ============================================================

// I had to re-create a custom version or DMMutator because
// it was just causing too much trouble.

class MonsterBase expands Mutator;

var DeathMatchPlus MyGame;

function PostBeginPlay()
{
	MyGame = DeathMatchPlus(Level.Game);
	Super.PostBeginPlay();
}

// --------------------------------------------------------------
// Used to allow usage of Unreal 1 weapons as well as UT weapons.
// Also, Keep monsters as they sometimes get turned off.
//
// Thanks to UsAaR33 of OldSkool for letting me use some of his
// code from OldSkool.
// --------------------------------------------------------------

function bool AlwaysKeep(Actor Other)
{
	local bool bTemp;

	if ( Other.IsA('ScriptedPawn') )
	{
		if (ScriptedPawn(Other).Shadow == None)
			MonsterHunt(Level.Game).SetPawnDifficulty(MonsterHunt(Level.Game).MonsterSkill, ScriptedPawn(Other));
		return true;
	}

	if ( Other.IsA('ThingFactory') )
		return true;

	if ( Other.IsA('SpawnPoint') )
		return true;

	if ( NextMutator != None )
		return ( NextMutator.AlwaysKeep(Other) );
	return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local Inventory Inv;

	bSuperRelevant = 1;

/*	if ( Other.IsA('ScriptedPawn') )
		ScriptedPawn(Other).Shadow = Spawn(class'MonsterHunt.MonsterShadow',Other);
*/
	if ( MyGame.bMegaSpeed && Other.bIsPawn && Pawn(Other).bIsPlayer )
	{
		Pawn(Other).GroundSpeed *= 1.4;
		Pawn(Other).WaterSpeed *= 1.4;
		Pawn(Other).AirSpeed *= 1.4;
		Pawn(Other).AccelRate *= 1.4;
	}

	Inv = Inventory(Other);
 	if ( Inv == None )
	{
		bSuperRelevant = 0;
		if ( Other.IsA('TorchFlame') )
			Other.NetUpdateFrequency = 0.5;
		return true;
	}

	if ( MyGame.bNoviceMode && MyGame.bRatedGame && (Level.NetMode == NM_Standalone) )
		Inv.RespawnTime *= (0.5 + 0.1 * MyGame.Difficulty);

	if ( Other.IsA('Weapon') )
	{
		if ( Other.IsA('TournamentWeapon') )
			return true;

		if ( Other.IsA('UIWeapon') )
			return true;

		if ( Other.IsA('Stinger'))
		{
			ReplaceWith(Other, "MonsterHunt.OLStinger");
			return false;
		}

		if ( Other.IsA('Rifle'))
		{
			ReplaceWith( Other, "MonsterHunt.OLRifle" );
			Return false;
		}
	
		if ( Other.IsA('Razorjack') )
		{
			ReplaceWith(Other, "MonsterHunt.OLRajorjack");
			Return false;
		}

		if ( Other.IsA('Minigun'))
		{
			ReplaceWith( Other, "MonsterHunt.OLMinigun" );
			return false;
		}
	
		if ( Other.IsA('AutoMag'))
		{
			ReplaceWith( Other, "MonsterHunt.OLAutoMag" );
			return false;
		}

		if ( Other.IsA('Eightball'))
		{
			ReplaceWith( Other, "MonsterHunt.OLEightball" );
			return false;
		}
	
		if ( Other.IsA('FlakCannon') )
		{
			ReplaceWith( Other, "MonsterHunt.OLFlakCannon" );
			return false;
		}
		
		if ( Other.IsA('ASMD'))
		{
			ReplaceWith( Other, "MonsterHunt.OLASMD" );
			return false;
		}

		if ( Other.IsA('GesBioRifle') )
		{
			ReplaceWith( Other, "MonsterHunt.OLGESBioRifle" );
			return false;
		}

		if ( Other.IsA('dispersionpistol') )
		{
			ReplaceWith( Other, "MonsterHunt.OLDPistol" );
			return false;
		}
		bSuperRelevant = 0;
		return true;
	}

	if ( Other.IsA('Pickup') )
	{
		Pickup(Other).bAutoActivate = true;
		if ( Other.IsA('TournamentPickup') )
			return true;
	}
	if ( Other.IsA('TournamentHealth') )
		return true;

	if ( Level.Game.IsA('MonsterHuntArena') )
	{
		if ( Other.IsA('Weapon') )
		{
			Weapon(Other).RespawnTime = 3;
		}

		else if ( Other.IsA('Ammo') )
		{
			Ammo(Other).RespawnTime = 3;
		}
	return true;
	}

	bSuperRelevant = 0;
	return true;
}

function Mutate(string MutateString, PlayerPawn Sender)
{
	local Pawn P;

	if ( MutateString ~= "version" )
		Sender.ClientMessage("Monster Hunt v503", 'CriticalEvent', True);

	if ( NextMutator != None )
		NextMutator.Mutate(MutateString, Sender);
}

defaultproperties
{
}

//--]]]]----
