//--[[[[----
// ============================================================
// MonsterWeapons
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2002 Kenneth "Shrimp" Watson
//          For more info, http://shrimpworks.za.net
//    Not to be modified without permission from the author
// ============================================================

// OBSOLETE - INCORPORATED INTO MONSTERBASE

class MonsterWeapons expands Mutator;

function bool AlwaysKeep( Actor Other )
{
	local bool bRetVal;
	
	bRetVal = false;
	if( Other.IsA('Weapon') && !Other.IsA('TournamentWeapon') )
	{
		if( Other.IsA('Stinger')     		||
		    Other.IsA('Rifle')			||
		    Other.IsA('Razorjack')		||
    		    Other.IsA('Minigun')		||
		    Other.IsA('AutoMag')		||
		    Other.IsA('Eightball')		||
		    Other.IsA('FlakCannon')		||
		    Other.IsA('ASMD')			||
		    Other.IsA('QuadShot')		||
		    Other.IsA('GesBioRifle')		||
		    Other.IsA('DispersionPistol') )
		{
			bRetVal = true;
		}
	}		
	else if ( Other.IsA('Ammo') && !Other.IsA('TournamentAmmo') )
	{
		if( Other.IsA('ASMDAmmo')		||
			Other.IsA('RocketCan')		||
			Other.IsA('StingerAmmo')	||
			Other.IsA('RazorAmmo')		||
			Other.IsA('RifleRound')		||
			Other.IsA('RifleAmmo')		||
			Other.IsA('FlakBox')		||
			Other.IsA('Clip')		||
			Other.IsA('ShellBox')		||
			Other.IsA('Sludge') )
		{
			bRetVal = true;
		}
	}
	else if ( Other.IsA('WeaponPowerUp') )
	{
		bRetVal = true;
	}		
	else if ( NextMutator != None )
	{
		bRetVal = NextMutator.AlwaysKeep(Other);
	}
		
	return bRetVal;
}

defaultproperties
{
}

//--]]]]----
