// ============================================================
// MonsterHuntMonsterDefenceExtension
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterHuntMonsterDefenceExtension extends MonsterHuntMonsterExtension;

// pre-set tags we use internally
var Name runnerTag;

// monster spawn locations and counters
var NavigationPoint monsterSpawnPoints[64], monsterRunnerSpawnPoints[64];
var int monsterSpawnCount, monsterRunnerSpawnCount, spawnCycle, maxOtherMonsters;

// spawn scalers, by map scale (roughly defined as distance between flags)
var float spawnChanceBaseScale, spawnChanceScaler;
var int minSpawnDistance;

// monster spawn interval/cycle management
var float spawnInterval, currentSpawnInterval;

// keeps track of players to avoid regular looping
var Pawn maybeEnemyPlayers[32];
var int playerCount, playerCountCounter;
var int PlayerCountInterval;

var Texture TeleportEffectTexture;

function PostBeginPlay() {
	local FlagBase flag;
	local FlagBase bothFlags[2];
	local int maxRange, range;
	local NavigationPoint nav;

	foreach AllActors(class'FlagBase', flag) {
		if (flag.team == 0) bothFlags[0] = flag;
		else if (flag.team == 1) bothFlags[1] = flag;

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

	Super.PostBeginPlay();
}

function EvaluatePawns() {
	local Pawn P;

	if (MonsterHuntDefence(game) != None) {
		// hijacking this process to get hold of monster skill config
		spawnInterval = 2.2 - ((80 + (MonsterHuntDefence(game).MonsterSkill * 10)) / 100);

		if (MonsterHuntDefence(game).bInWarmup) return;
	}

	// we collect players on a slower interval to avoid iterating the pawn list on every eval period
	playerCountCounter ++;
	if (playerCountCounter >= PlayerCountInterval) {
		playerCount = 0;
		for (P = Level.PawnList; P != None; P = P.nextPawn) {
			if (P.bIsPlayer) {
				if ((P.PlayerReplicationInfo == None) || P.PlayerReplicationInfo.bIsSpectator) continue;
				maybeEnemyPlayers[playerCount] = P;
				playerCount++;
			}
		}
	}

	Super.EvaluatePawns();
}

function CoercePawn(ScriptedPawn pawn) {
	local Pawn player;
	local Actor monsterTarget;

	if (MonsterHuntDefence(game) == None) {
		Super.CoercePawn(pawn);
		return;
	}

	monsterTarget = MonsterHuntDefence(game).monsterTarget;

	if (pawn.Enemy == None && pawn.tag != runnerTag) {
		// only evaluating against one random player per pawn, since CanSee might be expensive to run over all players for every pawn
		player = maybeEnemyPlayers[Rand(playerCount)];
		if (player != None && pawn.CanSee(player)) {
			pawn.SetEnemy(player);
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
				pawn.AlarmTag = monsterTarget.Tag;
				pawn.OrderTag = monsterTarget.Tag;
				pawn.OrderObject = monsterTarget;
				pawn.GoToState('TriggerAlarm');
			}
		}
	}
}

function Tick(float delta) {
	if (game.bGameStarted) {
		currentSpawnInterval += delta;
		if (currentSpawnInterval >= spawnInterval) {
			spawnMonsters();
			currentSpawnInterval = 0;
		}
	}

	Super.Tick(delta);
}

function NavigationPoint findNearSpawn() {
	if (monsterSpawnCount == 0) return findFarSpawn();
	return monsterSpawnPoints[Rand(monsterSpawnCount)];
}

function NavigationPoint findFarSpawn() {
	return monsterRunnerSpawnPoints[Rand(monsterRunnerSpawnCount)];
}

function spawnMonsters() {
	local Actor monsterTarget;

	if (MonsterHuntDefence(game) == None) {
		return;
	}

	if (!game.bGameStarted || MonsterHuntDefence(game).bInWarmup || game.bGameEnded) return;

	monsterTarget = MonsterHuntDefence(game).monsterTarget;

	// every ~8 seconds, spawn a runner
	if (spawnCycle % 8 == 0) {
		if (FRand() > 0.8) spawnMonsterAt(findFarSpawn(), class'SkaarjWarrior', monsterTarget, runnerTag);
		else if (FRand() > 0.6) spawnMonsterAt(findFarSpawn(), class'SkaarjAssassin', monsterTarget, runnerTag);
		else if (FRand() > 0.4) spawnMonsterAt(findFarSpawn(), class'SkaarjBerserker', monsterTarget, runnerTag);
		else if (FRand() > 0.2) spawnMonsterAt(findFarSpawn(), class'SkaarjLord', monsterTarget, runnerTag);
		else spawnMonsterAt(findFarSpawn(), class'SkaarjScout', monsterTarget, runnerTag);
	}

	// don't spam more monsters - but allow skaarj runners to keep spawning.
	if (MonsterReplicationInfo(GameReplicationInfo).Monsters < (maxOtherMonsters * spawnChanceScaler)) {
		if (spawnCycle % 5 == 0 && FRand() < (0.4 * spawnChanceScaler)) {
			if (FRand() > 0.75) spawnMonsterAt(findFarSpawn(), class'SkaarjInfantry', monsterTarget);
			else if (FRand() > 0.5) spawnMonsterAt(findFarSpawn(), class'SkaarjGunner', monsterTarget);
			else if (FRand() > 0.25) spawnMonsterAt(findFarSpawn(), class'SkaarjOfficer', monsterTarget);
			else spawnMonsterAt(findFarSpawn(), class'SkaarjSniper', monsterTarget);
		}

		if (spawnCycle % 3 == 0 && FRand() < (0.6 * spawnChanceScaler)) {
			if (FRand() > 0.5) spawnMonsterAt(findFarSpawn(), class'KrallElite', monsterTarget);
			else spawnMonsterAt(findFarSpawn(), class'Krall', monsterTarget);
		}
		if (spawnCycle % 4 == 0 && FRand() < (0.4 * spawnChanceScaler)) {
			if (FRand() > 0.7) spawnMonsterAt(findFarSpawn(), class'LavaSlith', monsterTarget);
			else spawnMonsterAt(findFarSpawn(), class'Slith', monsterTarget);
		}
		if (spawnCycle % 5 == 0 && FRand() < (0.4 * spawnChanceScaler)) {
			if (FRand() > 0.5) spawnMonsterAt(findNearSpawn(), class'MercenaryElite', monsterTarget);
			else spawnMonsterAt(findNearSpawn(), class'Mercenary', monsterTarget);
		}

		if (spawnCycle % 5 == 0 && FRand() < (0.2 * spawnChanceScaler)) {
			if (FRand() > 0.6) spawnMonsterAt(findNearSpawn(), class'Behemoth', monsterTarget);
			else spawnMonsterAt(findNearSpawn(), class'Brute', monsterTarget);
		}

		if (spawnCycle % 5 == 0 && FRand() < (0.2 * spawnChanceScaler)) spawnMonsterAt(findNearSpawn(), class'GasBag', monsterTarget);

		if (FRand() < (0.25 * spawnChanceScaler)) {
			if (FRand() > 0.6) spawnMonsterAt(findNearSpawn(), class'Pupae', monsterTarget);
			else if (FRand() > 0.3) spawnMonsterAt(findNearSpawn(), class'Fly', monsterTarget);
			else spawnMonsterAt(findNearSpawn(), class'Manta', monsterTarget);
		}

		// small chance of spawning a large monster
		if (spawnCycle % 18 == 0 && FRand() > 0.8) {
			if (FRand() > 0.33) spawnMonsterAt(findNearSpawn(), class'Warlord', monsterTarget);
			else if (FRand() > 0.33) spawnMonsterAt(findNearSpawn(), class'Titan', monsterTarget);
			else spawnMonsterAt(findNearSpawn(), class'Queen', monsterTarget);
		}
	}

	spawnCycle++;
}

function ScriptedPawn spawnMonsterAt(
	NavigationPoint startSpot,
	class<ScriptedPawn> monsterClass,
	Actor monsterTarget,
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

	SetSpawnOrders(newMonster, monsterTarget, tag != '');

	newMonster.SetMovementPhysics();
	if (newMonster.Physics == PHYS_Walking) newMonster.SetPhysics(PHYS_Falling);

	SpawnEffect(newMonster);
	SpawnUnsticker(newMonster);

	return newMonster;
}

function SetSpawnOrders(ScriptedPawn pawn, Actor monsterTarget, bool isRunner) {
	local Pawn maybePlayer;

	// make them advance towards the objective
	pawn.OrderObject = monsterTarget;
	pawn.OrderTag = monsterTarget.Tag;

	if (isRunner || FRand() > 0.7) {
		pawn.AlarmTag = monsterTarget.Tag;
		pawn.Orders = 'TriggerAlarm';
		// when an alarm is triggered, TriggerAlarm causes AccessedNone on Enemy, so assign a random enemy
		if (playerCount > 0) {
			maybePlayer = maybeEnemyPlayers[Rand(playerCount)];
			if (maybePlayer != None) pawn.SetEnemy(maybePlayer);
		}
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
	Spawn(class'MonsterDefenceUnsticker', other,, other.location);
}

defaultproperties {
	MonsterEvalInterval=3
	PlayerCountInterval=5

	spawnChanceBaseScale=1750
	spawnInterval=1.0
	maxOtherMonsters=80
	runnerTag="MHDRunner"

	TeleportEffectTexture=Texture'Botpack.Skins.MuzzyPulse'
}
