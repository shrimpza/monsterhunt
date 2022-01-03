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

var localized string MonstersEscapedMessage, EscapedMessage, WarmupMessage;

// pre-set tags we use internally
var Name monsterOrderTag, runnerTag;

// the flag base (red flag) we want monsters to charge towards
var FlagBase monsterTarget;

// monster spawn locations and counters
var NavigationPoint monsterSpawnPoints[64], monsterRunnerSpawnPoints[64];
var int monsterSpawnCount, monsterRunnerSpawnCount, spawnCycle, maxOtherMonsters;

// spawn scalers, by map scale (roughly defined as distance between flags)
var float spawnChanceBaseScale, spawnChanceScaler;
var int minSpawnDistance;

// monster spawn interval/cycle management
var float spawnInterval, currentSpawnInterval;

var bool bInWarmup;

var Texture TeleportEffectTexture;

function PostBeginPlay() {
	local FlagBase flag;
	local FlagBase bothFlags[2];
	local int maxRange, range;
	local NavigationPoint nav;
	// upgrade doors and lifts for monster interactions
	local Trigger trigger;
	local Mover mover;

	local float DiffScale;

	foreach AllActors(class'FlagBase', flag) {
		if (flag.team == 0) {
			bothFlags[0] = flag;
			flag.Tag = monsterOrderTag;
			monsterTarget = flag;

			flag.Spawn(class'MonsterDefenceEscape');
		} else if (flag.team == 1) bothFlags[1] = flag;

		if (bothFlags[0] != None && bothFlags[1] != None) break;
	}

	if (bothFlags[0] != None && bothFlags[1] != None) {
		maxRange = VSize(bothFlags[0].location - bothFlags[1].location);
	}

	maxRange = maxRange / 2;
	minSpawnDistance = maxRange / 2;

	for (nav = Level.NavigationPointList; nav != None; nav = nav.nextNavigationPoint) {
		if (nav.IsA('InventorySpot') || nav.IsA('PlayerStart')) continue;

		range = VSize(nav.location - bothFlags[0].location);
		if (range < maxRange && range > minSpawnDistance && monsterSpawnCount < 64) {
			monsterSpawnPoints[monsterSpawnCount] = nav;
			monsterSpawnCount++;
		} else if (range > maxRange && monsterRunnerSpawnCount < 64) {
			monsterRunnerSpawnPoints[monsterRunnerSpawnCount] = nav;
			monsterRunnerSpawnCount++;
		}
	}

	// looks like we found no suitable points to spawn monsters, so find any available navigation points
	if (monsterSpawnCount == 0) {
		for (nav = Level.NavigationPointList; nav != None && monsterSpawnCount < 64; nav = nav.nextNavigationPoint) {
			monsterSpawnPoints[monsterSpawnCount] = nav;
			monsterSpawnCount++;
		}
	}

	spawnChanceScaler = Max(1000, minSpawnDistance) / spawnChanceBaseScale;

	// we also need monsters to be able to use things like doors and lifts
	foreach AllActors(class'Trigger', trigger) {
		if (trigger.Event != '' && trigger.TriggerType == TT_PlayerProximity) {
			foreach AllActors(class'Mover', mover, trigger.Event) {
				trigger.TriggerType = TT_PawnProximity;
			}
		}
	}
	foreach AllActors(class'Mover', mover) {
		if (mover.BumpType == BT_PlayerBump) {
			mover.BumpType = BT_PawnBump;
		}
	}

	DiffScale = (80 + (MonsterSkill * 10)) / 100;
	spawnInterval = 2.2 - DiffScale;

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
		BroadcastMessage(WarmupTime @ WarmupMessage, true, 'CriticalEvent');
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

	BroadcastMessage(escapee.GetHumanName() @ EscapedMessage, false, 'MonsterCriticalEvent');

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

	CoerceOrders();

	if (bGameStarted && bInWarmup && WarmupTime > 0) {
		if (WarmupTime < 6) {
			for (P = Level.PawnList; P != None; P = P.nextPawn) {
				if (P.IsA('TournamentPlayer')) TournamentPlayer(P).TimeMessage(WarmupTime);
			}
		} else if (WarmupTime % 10 == 0) {
			BroadcastMessage(WarmupTime @ WarmupMessage, true, 'CriticalEvent');
		}

		WarmupTime --;
	}
	bInWarmup = WarmupTime > 0;
}

/*
 * Try to force monsters to behave in specific ways.
 */
function CoerceOrders() {
	local ScriptedPawn pawn;
	local Pawn P;
	local Pawn maybeEnemyPlayers[32];
	local ScriptedPawn scriptedPawns[256];
	local int playerCount, scriptedPawnCount, i;

	if (bGameEnded || bInWarmup) return;

	playerCount = 0;
	scriptedPawnCount = 0;
	for (P = Level.PawnList; P != None; P = P.nextPawn) {
		if (P.bIsPlayer) {
			if ((P.PlayerReplicationInfo == None) || P.PlayerReplicationInfo.bIsSpectator) continue;
			maybeEnemyPlayers[playerCount] = P;
			playerCount++;
		}

		if (P.IsA('ScriptedPawn')) {
			scriptedPawns[scriptedPawnCount] = ScriptedPawn(P);
			scriptedPawnCount++;
		}
	}

	for (i = 0; i < scriptedPawnCount; i++) {
		pawn = scriptedPawns[i];
		if (pawn == None) continue;

		if (pawn.Enemy == None && pawn.tag != runnerTag) {
			// only evaluating against one random player per pawn, since CanSee might be expensive to run over all players for every pawn
			P = maybeEnemyPlayers[Rand(playerCount)];
			if (pawn.CanSee(P)) {
				pawn.SetEnemy(P);
				pawn.OrderTag = '';
				pawn.OrderObject = None;
				pawn.GoToState('Attacking');
			} else if (VSize(monsterTarget.location - pawn.location) < minSpawnDistance) {
				// this guy's getting in close, maybe switch mode
				if (pawn.OrderTag != '' && FRand() > 0.5) {
					// stop charging and hang around, maybe there's someone to attack
					pawn.AlarmTag = '';
					pawn.OrderTag = '';
					pawn.OrderObject = None;
					pawn.GoToState('Roaming');
				} else if (pawn.AlarmTag == '' && FRand() > 0.5) {
					// we're done hanging around, charge for the target
					pawn.AlarmTag = monsterOrderTag;
					pawn.OrderTag = monsterOrderTag;
					pawn.OrderObject = monsterTarget;
					pawn.GoToState('TriggerAlarm');
				}
			}
		}
	}
}

function NavigationPoint findNearSpawn() {
	if (monsterSpawnCount == 0) return findFarSpawn();
	return monsterSpawnPoints[Rand(monsterSpawnCount)];
}

function NavigationPoint findFarSpawn() {
	return monsterRunnerSpawnPoints[Rand(monsterRunnerSpawnCount)];
}

function Tick(float delta) {
	if (bGameStarted) {
		currentSpawnInterval += delta;
		if (currentSpawnInterval >= spawnInterval) {
			spawnMonsters();
			currentSpawnInterval = 0;
		}
	}

	Super.Tick(delta);
}

function spawnMonsters() {
	if (!bGameStarted || bInWarmup || bGameEnded) return;

	// every ~8 seconds, spawn a runner
	if (spawnCycle % 8 == 0) {
		if (FRand() > 0.8) spawnMonsterAt(findFarSpawn(), class'SkaarjWarrior', runnerTag);
		else if (FRand() > 0.6) spawnMonsterAt(findFarSpawn(), class'SkaarjAssassin', runnerTag);
		else if (FRand() > 0.4) spawnMonsterAt(findFarSpawn(), class'SkaarjBerserker', runnerTag);
		else if (FRand() > 0.2) spawnMonsterAt(findFarSpawn(), class'SkaarjLord', runnerTag);
		else spawnMonsterAt(findFarSpawn(), class'SkaarjScout', runnerTag);
	}

	// don't spam more monsters - but allow skaarj runners to keep spawning.
	if (MonsterReplicationInfo(GameReplicationInfo).Monsters < (maxOtherMonsters * spawnChanceScaler)) {
		if (spawnCycle % 5 == 0 && FRand() < (0.4 * spawnChanceScaler)) {
			if (FRand() > 0.75) spawnMonsterAt(findFarSpawn(), class'SkaarjInfantry');
			else if (FRand() > 0.5) spawnMonsterAt(findFarSpawn(), class'SkaarjGunner');
			else if (FRand() > 0.25) spawnMonsterAt(findFarSpawn(), class'SkaarjOfficer');
			else spawnMonsterAt(findFarSpawn(), class'SkaarjSniper');
		}

		if (spawnCycle % 3 == 0 && FRand() < (0.6 * spawnChanceScaler)) {
			if (FRand() > 0.5) spawnMonsterAt(findFarSpawn(), class'KrallElite');
			else spawnMonsterAt(findFarSpawn(), class'Krall');
		}
		if (spawnCycle % 4 == 0 && FRand() < (0.4 * spawnChanceScaler)) {
			if (FRand() > 0.7) spawnMonsterAt(findFarSpawn(), class'LavaSlith');
			else spawnMonsterAt(findFarSpawn(), class'Slith');
		}
		if (spawnCycle % 5 == 0 && FRand() < (0.4 * spawnChanceScaler)) {
			if (FRand() > 0.5) spawnMonsterAt(findNearSpawn(), class'MercenaryElite');
			else spawnMonsterAt(findNearSpawn(), class'Mercenary');
		}

		if (spawnCycle % 5 == 0 && FRand() < (0.2 * spawnChanceScaler)) {
			if (FRand() > 0.6) spawnMonsterAt(findNearSpawn(), class'Behemoth');
			else spawnMonsterAt(findNearSpawn(), class'Brute');
		}

		if (spawnCycle % 5 == 0 && FRand() < (0.2 * spawnChanceScaler)) spawnMonsterAt(findNearSpawn(), class'GasBag');

		if (FRand() < (0.25 * spawnChanceScaler)) {
			if (FRand() > 0.6) spawnMonsterAt(findNearSpawn(), class'Pupae');
			else if (FRand() > 0.3) spawnMonsterAt(findNearSpawn(), class'Fly');
			else spawnMonsterAt(findNearSpawn(), class'Manta');
		}

		// small chance of spawning a large monster
		if (spawnCycle % 18 == 0 && FRand() > 0.8) {
			if (FRand() > 0.33) spawnMonsterAt(findNearSpawn(), class'Warlord');
			else if (FRand() > 0.33) spawnMonsterAt(findNearSpawn(), class'Titan');
			else spawnMonsterAt(findNearSpawn(), class'Queen');
		}
	}

	spawnCycle++;
}

function ScriptedPawn spawnMonsterAt(
	NavigationPoint startSpot,
	class<ScriptedPawn> monsterClass,
	optional Name tag
) {
	local ScriptedPawn newMonster;

	if (startSpot == None) return None;

	newMonster = startSpot.Spawn(monsterClass);
	if (newMonster == None) return None;

	if (tag != '') newMonster.tag = tag;

	newMonster.SetRotation(startSpot.Rotation);

	// make them less dumb
	newMonster.Intelligence = BRAINS_HUMAN;
	newMonster.SightRadius = Max(minSpawnDistance * 4, newMonster.SightRadius); // be able to see right across the map
	newMonster.bIgnoreFriends = True;

	// special condition to allow monsters to pass through each other, so they don't block the objective
	newMonster.bBlockActors = false;

	SetSpawnOrders(newMonster, tag != '');

	newMonster.SetMovementPhysics();
	if (newMonster.Physics == PHYS_Walking) newMonster.SetPhysics(PHYS_Falling);

	SpawnEffect(newMonster);
	SpawnUnsticker(newMonster);

	return newMonster;
}

function SetSpawnOrders(ScriptedPawn pawn, bool isRunner) {
	// make them advance towards the objective
	pawn.OrderObject = monsterTarget;
	pawn.OrderTag = monsterOrderTag;

	if (isRunner || FRand() > 0.7) {
		pawn.AlarmTag = monsterOrderTag;
		pawn.Orders = 'TriggerAlarm';
	} else {
		pawn.Orders = 'Roaming';
	}
}

function SpawnEffect(ScriptedPawn other) {
	local actor e;

	e = Spawn(class'TranslocOutEffect', ,, other.location, other.rotation);
	e.Mesh = other.Mesh;
	e.Animframe = other.Animframe;
	e.Animsequence = other.Animsequence;
	e.Texture = TeleportEffectTexture;

	e.PlaySound(sound'Resp2A', , 10.0);
}

function SpawnUnsticker(ScriptedPawn other) {
	local actor un;

	un = Spawn(class'MonsterDefenceUnsticker', other,, other.location);
}

defaultproperties {
  WarmupTime=30
	MaxEscapees=20
	spawnChanceBaseScale=1750
	spawnInterval=1.0
	maxOtherMonsters=80
	monsterOrderTag="MHDAttackThis"
	runnerTag="MHDRunner"
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
	DefaultBotOrders='Defend'
	RulesMenuType="{{package}}.MonsterHuntDefenceRules"

	TeleportEffectTexture=Texture'Botpack.Skins.MuzzyPulse'
}
