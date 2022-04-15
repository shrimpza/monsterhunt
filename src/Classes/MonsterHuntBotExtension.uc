// ============================================================
// MonsterHuntBotExtension
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

/*
 The BotExtension provides a means of allowing implementations of custom
 bot behaviours.

 The interface of this class is as follows:

	- SetAttractionStateFor
	- FindSpecialAttractionFor
	- SetBotOrders
	- AssessBotAttitude
		- the above functions are as per their DeathMatchPlus/GameInfo implementations,
			but made available here for providing Monster Hunt specific behaviours without
			needing to implement new gametypes.

	Other functions should be  considered "private" implementation details of this
	specific implementation, and should be overridden with caution.

	The game and gameReplicationInfo variables should be available after PostBeginPlay.
*/
class MonsterHuntBotExtension extends MonsterHuntExtension;

var MonsterHunt game;
var GameReplicationInfo gameReplicationInfo;

var int NumSupportingPlayer;

var name DefaultBotOrders;

var int LastPoint;
var int NumPoints;
var MonsterWaypoint waypoints[128];
var MonsterEnd endPoints[8];
var int NumEndPoints;

function PostBeginPlay() {
	LastPoint = 0;
	FindWaypoints();
	Super.PostBeginPlay();
}

function FindWaypoints() {
	local int i, j;
	local MonsterWaypoint WP;
	local MonsterEnd EP;

	// we're storing these in local arrays, since they don't change during gameplay, we can save some AllActors iterations later
	foreach AllActors(class'MonsterWaypoint', WP) {
		if (NumPoints > 127) break;
		waypoints[NumPoints] = WP;
		NumPoints ++;
	}
	foreach AllActors(class'MonsterEnd', EP) {
		if (NumEndPoints > 7) break;
		endPoints[NumEndPoints] = EP;
		NumEndPoints ++;
	}

	// sort waypoints by position
	for (i = 0; i < NumPoints - 1; i++) {
		for (j = i + 1; j < NumPoints - i - 1; j++) {
			if (waypoints[i].Position > waypoints[j].Position) {
				WP = waypoints[j];
				waypoints[j] = waypoints[i];
				waypoints[j+1] = WP;
			}
		}
	}
}

function SetAttractionStateFor(Bot aBot) {
	if (aBot.Enemy != None) {
		if (!aBot.IsInState('FallBack')) {
			aBot.bNoClearSpecial = true;
			aBot.TweenToRunning(0.1);
			aBot.GotoState('FallBack', 'SpecialNavig');
		}
	} else if (!aBot.IsInState('Roaming')) {
		aBot.bNoClearSpecial = true;
		aBot.TweenToRunning(0.1);
		aBot.GotoState('Roaming', 'SpecialNavig');
	}
}

function bool FindSpecialAttractionFor(Bot aBot) {
	local ScriptedPawn S;

	if (aBot == None) return false;

	if (aBot.Health < 1) {
		aBot.GotoState('GameEnded');
		return false;
	}

	if (aBot.LastAttractCheck == Level.TimeSeconds) return false;
	aBot.LastAttractCheck = Level.TimeSeconds;

	foreach AllActors(class'ScriptedPawn', S) {
		if (S.isA('Titan') && S.GetStateName() == 'Sitting') continue;
		if (S.IsA('Nali') || S.IsA('Cow')) {
			if (!game.MaybeEvilFriendlyPawn(S, aBot)) continue;
		}

		if (S.CanSee(aBot)) {
			if (((S.Enemy == None) || ((S.Enemy.IsA('PlayerPawn')) && (FRand() > 0.7))) && (S.Health >= 1)) {
				S.Hated = aBot;
				S.Enemy = aBot;
				S.GotoState('Attacking');
			}
		}

		if (aBot.CanSee(S) && (FRand() > 0.25)) {
			// a bot will not move towards an objective as long as enemies are around
			aBot.MoveTarget = None;
			if ((aBot.Enemy == None) && (S.Health >= 1)) {
				aBot.Enemy = S;
				aBot.GotoState('Attacking');
			}
			SetAttractionStateFor(aBot);
			return true;
		}
	}

	return FindNextWaypoint(aBot);
}

function bool FindNextWaypoint(Bot aBot) {
	local int i, lastVisited;

	lastVisited = -1;

	if ((aBot.Orders == 'Attack') || ((aBot.Orders == 'Freelance') && (FRand() > 0.2))) {
		for (i = 0; i < NumPoints; i++) {
			if (waypoints[i].bVisited) lastVisited = i;

			if (!waypoints[i].bVisited && waypoints[i].bEnabled) {
				if (aBot.ActorReachable(waypoints[i])) aBot.MoveTarget = waypoints[i];
				else aBot.MoveTarget = aBot.FindPathToward(waypoints[i]);

				// there's no path to the next waypoint in line, so try to go to the next one
				if (aBot.MoveTarget == None) continue;

				SetAttractionStateFor(aBot);
				return true;
			}

			// the next waypoint in line is not enabled, so stop here
			if (i > lastVisited && !waypoints[i].bEnabled) {
				break;
			}
		}

		// we have to attack this thing now
		if (lastVisited > -1 && waypoints[lastVisited].ArrivalTarget != None) {
			if (!aBot.CanSee(waypoints[lastVisited].ArrivalTarget)) {
				if (aBot.ActorReachable(waypoints[lastVisited].ArrivalTarget)) aBot.MoveTarget = waypoints[lastVisited].ArrivalTarget;
				else aBot.MoveTarget = aBot.FindPathToward(waypoints[lastVisited].ArrivalTarget);
			} else {
				aBot.SetEnemy(waypoints[lastVisited].ArrivalTarget);
				aBot.SetOrders('Attack', None, false);
			}
			SetAttractionStateFor(aBot);
			return true;
		}

		// there are no waypoints left, or we can't reach any, so head for an end if possible
		if (i >= NumPoints) {
			for (i = 0; i < NumEndPoints; i++) {
				if (aBot.ActorReachable(endPoints[i])) aBot.MoveTarget = endPoints[i];
				else aBot.MoveTarget = aBot.FindPathToward(endPoints[i]);

				// we can't reach this endpoint, try the next one
				if (aBot.MoveTarget == None) continue;

				SetAttractionStateFor(aBot);
				return true;
			}
		}
	}

	// no waypoints available, no change in bot orders
	return false;
}

function SetBotOrders(Bot NewBot) {
	local Pawn P, L;
	local int num, total;

	// only follow players, if there are any
	if (NumSupportingPlayer == 0) {
		for (P = Level.PawnList; P != None; P = P.NextPawn) {
			if (P.IsA('PlayerPawn') && (P.PlayerReplicationInfo.Team == NewBot.PlayerReplicationInfo.Team)
				&& !P.IsA('Spectator')) {
				num++;
				if ((L == None) || (FRand() < 1.0 / float(num))) L = P;
			}
		}

		if (L != None) {
			NumSupportingPlayer++;
			NewBot.SetOrders('Follow', L, true);
			return;
		}
	}

	num = 0;

	for (P = Level.PawnList; P != None; P = P.NextPawn) {
		if (!P.IsA('ScriptedPawn')
				&& P.bIsPlayer
				&& P.PlayerReplicationInfo != None
				&& (P.PlayerReplicationInfo.Team == NewBot.PlayerReplicationInfo.Team)) {
			total++;
			if ((P != NewBot) && P.IsA('Bot') && (Bot(P).Orders == DefaultBotOrders)) {
				num++;
				if ((L == None) || (FRand() < 1 / float(num))) L = P;
			}
		}
	}

	if ((L != None) && (FRand() < float(num) / float(total))) {
		NewBot.SetOrders('Follow', L, true);
		return;
	}

	NewBot.SetOrders(DefaultBotOrders, None, true);
}

/*
		AssessBotAttitude returns a value that translates to an attitude
		0 = ATTITUDE_Fear;
		1 = return ATTITUDE_Hate;
		2 = return ATTITUDE_Ignore;
		3 = return ATTITUDE_Friendly;

		Special return value: 255: Fall back to DeathMatchPlus.AssessBotAttitude
*/
function byte AssessBotAttitude(Bot aBot, Pawn Other) {
	if (Other.isA('Titan') && Other.GetStateName() == 'Sitting') return 2; // ATTITUDE_Ignore
	if (!aBot.LineOfSightTo(Other))	return 2; // ATTITUDE_Ignore
	if (Other.IsA('Nali') || Other.IsA('Cow')) {
		if (game.MaybeEvilFriendlyPawn(ScriptedPawn(Other), aBot)) return 1; // ATTITUDE_Hate
		else return 3; // ATTITUDE_Friendly
	}
	if (Other.bIsPlayer && Other.PlayerReplicationInfo != None && Other.PlayerReplicationInfo.Team == aBot.PlayerReplicationInfo.Team) {
		return 3; // ATTITUDE_Friendly
	}
	if (Other.IsA('TeamCannon')) {
		if (TeamCannon(Other).SameTeamAs(0)) return 3; // ATTITUDE_Friendly
		if (Other.GetStateName() != 'ActiveCannon') return 2; // ATTITUDE_Ignore
	}
	if (!(Other.bIsPlayer && Other.PlayerReplicationInfo != None) && Other.CollisionHeight < 75) return 1; // ATTITUDE_Hate
	if (!(Other.bIsPlayer && Other.PlayerReplicationInfo != None) && Other.CollisionHeight >= 75) return 0; // ATTITUDE_Fear

	return 255;
}

defaultproperties {
	DefaultBotOrders='Attack'
}
