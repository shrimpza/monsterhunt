//=============================================================
// MonsterHuntDefence
//=============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterHuntDefence extends MonsterHunt
	config(MonsterHunt);

var config int MaxEscapees;
var config int WarmupTime;

var int WarmupCountdown;

var localized string MonstersEscapedMessage, EscapedMessage, WarmupMessage;

// pre-set tags we use internally
var Name monsterOrderTag;

// the flag base (red flag) we want monsters to charge towards
var FlagBase monsterTarget;

var bool bInWarmup;

function PostBeginPlay() {
	local FlagBase flag;

	foreach AllActors(class'FlagBase', flag) {
		if (flag.team == 0) {
			flag.Tag = monsterOrderTag;
			monsterTarget = flag;

			flag.Spawn(class'MonsterDefenceEscape');
			break;
		}
	}

	Super.PostBeginPlay();
}


function InitGameReplicationInfo() {
	local MonsterReplicationInfo mri;

	Super.InitGameReplicationInfo();

	mri = MonsterReplicationInfo(GameReplicationInfo);
	if (mri != None) {
		mri.MaxEscapees = MaxEscapees;
	}
}

function StartMatch() {
	if (WarmupTime > 0) {
		bInWarmup = true;
		WarmupCountdown = WarmupTime;
		BroadcastMessage(WarmupCountdown @ WarmupMessage, true, 'CriticalEvent');
	}

	Super.StartMatch();
}

function bool IsRelevant(Actor Other) {
	// Disable invulnerability shields on Mercenaries, since its unfair on approach to escape
	local Mercenary merc;
	merc = Mercenary(Other);
	if (merc != None) merc.bHasInvulnerableShield = false;

	return Super.IsRelevant(Other);
}

function monsterEscaped(ScriptedPawn escapee) {
	MonsterReplicationInfo(GameReplicationInfo).Escapees++;

	BroadcastMessage(UppercaseFirst(escapee.GetHumanName()) @ EscapedMessage, false, 'MonsterCriticalEvent');

	if (MonsterReplicationInfo(GameReplicationInfo).Escapees >= MaxEscapees) EndGame("Monsters Escaped");
}

function bool isBadEnd(string reason) {
	if (reason == "Monsters Escaped") return true;
	if ((RemainingTime == 0) && (TimeLimit >= 1)) return false;
	else return Super.isBadEnd(reason);
}

function string endedMessage(string reason) {
	if (reason == "Monsters Escaped") return MonstersEscapedMessage;
	if ((RemainingTime == 0) && (TimeLimit >= 1)) return GameEndedMessage;
	return Super.endedMessage(reason);
}

function Timer() {
	local Pawn P;

	Super.Timer();

	if (bGameStarted && bInWarmup && WarmupCountdown > 0) {
		if (WarmupCountdown < 6) {
			for (P = Level.PawnList; P != None; P = P.nextPawn) {
				if (P.IsA('TournamentPlayer')) TournamentPlayer(P).TimeMessage(WarmupCountdown);
			}
		} else if (WarmupCountdown % 10 == 0) {
			BroadcastMessage(WarmupCountdown @ WarmupMessage, true, 'CriticalEvent');
		}

		WarmupCountdown --;
	}
	bInWarmup = WarmupCountdown > 0;
}

defaultproperties {
	WarmupTime=30
	MaxEscapees=20
	monsterOrderTag="MHDAttackThis"
	MapPrefix="CTF"
	MapListType=Class'Botpack.CTFMapList'
	BeaconName="MHD"
	GameName="Monster Defence"
	StartUpMessage="Work with your teammates to defend your base against the monsters!"
	StartMessage="The defence has begun!"
	GameEndedMessage="Defence Successful!"
	SingleWaitingMessage="Press Fire to begin defending."
	MonstersEscapedMessage="Too many monsters escaped!"
	WarmupMessage="seconds until the monsters arrive!"
	EscapedMessage="escaped!"
	RulesMenuType="{{package}}.MonsterHuntDefenceRules"

	MonsterExtensionType=Class'{{package}}.MonsterHuntMonsterDefenceExtension'
	BotExtensionType=Class'{{package}}.MonsterHuntBotDefenceExtension'
}
