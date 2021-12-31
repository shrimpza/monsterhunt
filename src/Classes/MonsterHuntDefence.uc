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

var localized string MonstersEscapedMessage;

// pre-set tags we use internally
var Name monsterOrderTag, runnerTag, defaultRunnerState, defaultOtherState;

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

var bool bGameStarted;

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

	MonsterReplicationInfo(GameReplicationInfo).MaxEscapees = MaxEscapees;

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

function StartMatch() {
	bGameStarted = true;

	Super.StartMatch();
}

function monsterEscaped(ScriptedPawn escapee) {
	MonsterReplicationInfo(GameReplicationInfo).Escapees++;

	BroadcastMessage(escapee.GetHumanName() @ "escaped!", true, 'MonsterCriticalEvent');

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
	forceOrders();

	Super.Timer();
}

function forceOrders() {
	local ScriptedPawn pawn;
	local Pawn P;
	local Pawn maybeEnemyPlayers[32];
	local int playerCount;

	if (bGameEnded) return;

	playerCount = 0;
	for (P = Level.PawnList; P != None; P = P.nextPawn) {
		if (P.bIsPlayer) {
			if ((P.PlayerReplicationInfo == None) || P.PlayerReplicationInfo.bIsSpectator) continue;
			maybeEnemyPlayers[playerCount] = P;
			playerCount++;
		}
	}

	foreach AllActors(class'ScriptedPawn', pawn) {
		if (pawn.Enemy == None && pawn.tag != runnerTag) {
			// only evaluating against one random player per pawn, since CanSee might be expensive to run over all players for every pawn
			P = maybeEnemyPlayers[Rand(playerCount)];
			if (pawn.CanSee(P)) {
				pawn.SetEnemy(P);
				pawn.AlarmTag = '';
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
				} else if (pawn.OrderTag == '' && FRand() > 0.5) {
					// we're done hanging around, try to go back toward the target
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
	currentSpawnInterval += delta;
	if (currentSpawnInterval >= spawnInterval) {
		spawnMonsters();
		currentSpawnInterval = 0;
	}

	Super.Tick(delta);
}

function spawnMonsters() {
	if (!bGameStarted || bGameEnded) return;

	// every ~8 seconds, spawn a runner
	if (spawnCycle % 8 == 0) {
		if (FRand() > 0.8) spawnMonsterAt(findFarSpawn(), class'SkaarjWarrior', defaultRunnerState, runnerTag);
		else if (FRand() > 0.6) spawnMonsterAt(findFarSpawn(), class'SkaarjAssassin', defaultRunnerState, runnerTag);
		else if (FRand() > 0.4) spawnMonsterAt(findFarSpawn(), class'SkaarjBerserker', defaultRunnerState, runnerTag);
		else if (FRand() > 0.2) spawnMonsterAt(findFarSpawn(), class'SkaarjLord', defaultRunnerState, runnerTag);
		else spawnMonsterAt(findFarSpawn(), class'SkaarjScout', defaultRunnerState, runnerTag);
	}

	// don't spam more monsters - but allow skaarj runners to keep spawning.
	if (MonsterReplicationInfo(GameReplicationInfo).Monsters < (maxOtherMonsters * spawnChanceScaler)) {
		if (spawnCycle % 5 == 0 && FRand() < (0.4 * spawnChanceScaler)) {
			if (FRand() > 0.75) spawnMonsterAt(findFarSpawn(), class'SkaarjInfantry', defaultRunnerState);
			else if (FRand() > 0.5) spawnMonsterAt(findFarSpawn(), class'SkaarjGunner', defaultRunnerState);
			else if (FRand() > 0.25) spawnMonsterAt(findFarSpawn(), class'SkaarjOfficer', defaultRunnerState);
			else spawnMonsterAt(findFarSpawn(), class'SkaarjSniper', defaultRunnerState);
		}

		if (spawnCycle % 3 == 0 && FRand() < (0.6 * spawnChanceScaler)) {
			if (FRand() > 0.5) spawnMonsterAt(findFarSpawn(), class'KrallElite', defaultOtherState);
			else spawnMonsterAt(findFarSpawn(), class'Krall', defaultOtherState);
		}
		if (spawnCycle % 4 == 0 && FRand() < (0.4 * spawnChanceScaler)) {
			if (FRand() > 0.7) spawnMonsterAt(findFarSpawn(), class'LavaSlith', defaultOtherState);
			else spawnMonsterAt(findFarSpawn(), class'Slith', defaultOtherState);
		}
		if (spawnCycle % 5 == 0 && FRand() < (0.4 * spawnChanceScaler)) {
			if (FRand() > 0.5) spawnMonsterAt(findNearSpawn(), class'MercenaryElite', defaultOtherState);
			else spawnMonsterAt(findNearSpawn(), class'Mercenary', defaultOtherState);
		}

		if (spawnCycle % 5 == 0 && FRand() < (0.2 * spawnChanceScaler)) {
			if (FRand() > 0.7) spawnMonsterAt(findNearSpawn(), class'Behemoth', defaultOtherState);
			else spawnMonsterAt(findNearSpawn(), class'Brute', defaultOtherState);
		}

		if (spawnCycle % 5 == 0 && FRand() < (0.2 * spawnChanceScaler)) spawnMonsterAt(findNearSpawn(), class'GasBag', defaultOtherState);

		if (FRand() < (0.3 * spawnChanceScaler)) {
			if (FRand() > 0.6) spawnMonsterAt(findNearSpawn(), class'Pupae', defaultOtherState);
			else if (FRand() > 0.3) spawnMonsterAt(findNearSpawn(), class'Fly', defaultOtherState);
			else spawnMonsterAt(findNearSpawn(), class'Manta', defaultOtherState);
		}

		// small chance of spawning a large monster
		if (spawnCycle % 18 == 0 && FRand() > 0.75) {
			if (FRand() > 0.33) spawnMonsterAt(findNearSpawn(), class'Warlord', defaultOtherState);
			else if (FRand() > 0.33) spawnMonsterAt(findNearSpawn(), class'Titan', defaultOtherState);
			else spawnMonsterAt(findNearSpawn(), class'Queen', defaultOtherState);
		}
	}

	spawnCycle++;
}

function ScriptedPawn spawnMonsterAt(
	NavigationPoint startSpot,
	class<ScriptedPawn> monsterClass,
	Name orders,
	optional Name tag
) {
	local ScriptedPawn newMonster;

	if (startSpot == None) return None;

	newMonster = startSpot.Spawn(monsterClass);
	if (newMonster == None) return None;

	newMonster.SetRotation(startSpot.Rotation);

	// make them advance towards the objective
	newMonster.Orders = orders;
	newMonster.OrderObject = monsterTarget;
	newMonster.OrderTag = monsterOrderTag;
	if (startSpot.IsA('PlayerStart'))	newMonster.AlarmTag = monsterOrderTag;
	else if (FRand() > 0.3) newMonster.AlarmTag = monsterOrderTag;
	if (tag != '') newMonster.tag = tag;

	// make them less dumb
	newMonster.Intelligence = BRAINS_HUMAN;
	newMonster.SightRadius = minSpawnDistance * 4; // be able to see right across the map
	newMonster.bIgnoreFriends = True;

	newMonster.SetMovementPhysics();
	if (newMonster.Physics == PHYS_Walking) newMonster.SetPhysics(PHYS_Falling);

	SpawnEffect(newMonster);

	return newMonster;
}

function ScriptedPawn spawnMonster(class<ScriptedPawn> monsterClass, Name orders, optional Name tag) {
	return spawnMonsterAt(FindPlayerStart(None, 1), monsterClass, orders, tag);
}

function SpawnEffect(Pawn other) {
	local actor e;

	e = Spawn(class'TranslocOutEffect', ,, other.location, other.rotation);
	e.Mesh = other.Mesh;
	e.Animframe = other.Animframe;
	e.Animsequence = other.Animsequence;
	e.Texture = TeleportEffectTexture;

	e.PlaySound(sound'Resp2A', , 10.0);
}

defaultproperties {
	MaxEscapees=20
	spawnChanceBaseScale=1750
	spawnInterval=1.0
	maxOtherMonsters=80
	monsterOrderTag="MHDAttackThis"
	runnerTag="MHDRunner"
	defaultRunnerState='TriggerAlarm'
	defaultOtherState='TriggerAlarm'
	MapPrefix="CTF"
	MapListType=Class'Botpack.CTFMapList'
	BeaconName="MHD"
	GameName="Monster Defence"
	StartUpMessage="Work with your teammates to defend your base against the monsters!"
	StartMessage="The defence has begun!"
	GameEndedMessage="Defence Successful!"
	SingleWaitingMessage="Press Fire to begin defending."
	MonstersEscapedMessage="Too many monsters escaped!"
	DefaultBotOrders='Defend'

	TeleportEffectTexture=Texture'Botpack.Skins.MuzzyPulse'
}
