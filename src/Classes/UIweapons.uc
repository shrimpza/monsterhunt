// ============================================================
// Origionally from OldSkool by UsAaR33.
// Check it out at http://www.unreality.org/usaar33
//
// Used with permission from the author.
// 
// ============================================================
// OLweapons.UIweapons: really a dummy class... defines 1 var (decals) but mainly helps the mutator
// ============================================================

class UIweapons extends TournamentWeapon
	config(MonsterHunt)
	abstract;

var config bool bUseDecals;  //decals option
var config bool AkimboMag; //akimbo mag option (here to look neater in INI's..
var config bool newarmorrules; //new armor rules (i.e. limit at 150 armor)
var bool bwantreload; //for reloading
var bool wepcanreload;

replication {
	reliable if (Role < Role_Authority) //client send to server....
	reload, stopreload;
}

function SetSwitchPriority(pawn Other) { //allow weapon to register in first 20....
	local int i;
	local name temp, carried;

	if (PlayerPawn(Other) != None) {
		for (i = 0; i < ArrayCount(PlayerPawn(Other).WeaponPriority); i++) {
			if (PlayerPawn(Other).WeaponPriority[i] == class.name) {
				AutoSwitchPriority = i;
				return;
			}
		}
		// else, register this weapon
		carried = class.name;
		for (i = AutoSwitchPriority; i < ArrayCount(PlayerPawn(Other).WeaponPriority); i++) {
			if ((PlayerPawn(Other).WeaponPriority[i] == '') || (PlayerPawn(Other).WeaponPriority[i] == 'None')) { //little bug pops up sometimes....
				PlayerPawn(Other).WeaponPriority[i] = carried;
				return;
			} else if (i < ArrayCount(PlayerPawn(Other).WeaponPriority) - 1) {
				temp = PlayerPawn(Other).WeaponPriority[i];
				PlayerPawn(Other).WeaponPriority[i] = carried;
				carried = temp;
			}
		}
	}
}

//client to server reloading functions...
exec function reload() { //call the exec function (var failed to replicate to server continuously.......
	if (pawn(owner) != None && pawn(owner).weapon == self) bwantreload = true;
}
exec function stopreload() {
	if (pawn(owner) != None && pawn(owner).weapon == self) bwantreload = false;
}

defaultproperties {
	bUseDecals=True
	AkimboMag=True
	bSpecialIcon=True
}
