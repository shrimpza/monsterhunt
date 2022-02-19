//=============================================================
// MonsterHunt
//=============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterHunt extends TeamGamePlus
	config(MonsterHunt);

var config bool bUseTeamSkins;

var config int MonsterSkill;

var config int Lives;
var bool bUseLives;

var localized string TimeOutMessage;
var localized string NoHuntersMessage;
var localized string NoLivesLeftMessage;
var localized string HuntCompleteMessage;

var int LivePpl;
var int PlainPpl;

var name DefaultBotOrders;

var int LastPoint;
var int NumPoints;
var MonsterWaypoint waypoints[128];
var MonsterEnd endPoints[8];
var int NumEndPoints;

var bool bGameStarted;

function PostBeginPlay() {
	LastPoint = 0;

	FindWaypoints();

	// get initial monster count
	CountMonsters();

	Super.PostBeginPlay();
}

function InitGameReplicationInfo() {
	local MonsterReplicationInfo mri;

	Super.InitGameReplicationInfo();

	mri = MonsterReplicationInfo(GameReplicationInfo);
	if (mri != None) {
		mri.Lives = Lives;
		mri.bUseTeamSkins = bUseTeamSkins;
		mri.bUseLives = Lives > 0;
		mri.MonsterSkill = MonsterSkill;
	}
}

function RegisterObjective(MonsterHuntObjective objective) {
	local MonsterReplicationInfo mri;
	mri = MonsterReplicationInfo(GameReplicationInfo);
	if (mri != None) mri.RegisterObjective(objective);
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

function bool IsRelevant(Actor Other) {
	local ScriptedPawn pawn;

	pawn = ScriptedPawn(Other);
	if (pawn != None) {
		SetPawnDifficulty(MonsterSkill, pawn);
		pawn.MenuName = FancyName(pawn);

		if (Level.NetMode != NM_DedicatedServer) {
			if (pawn.Shadow == None) pawn.Shadow = Spawn(class'MonsterShadow', pawn);
		}
	}

	if (Other.IsA('MonsterShadow') && Level.NetMode == NM_DedicatedServer) return false;

	return Super.IsRelevant(Other);
}

function SetPawnDifficulty(int MonsterSkill, ScriptedPawn S) {
	local float DiffScale;

	if (S == None) return;

	DiffScale = (80 + (MonsterSkill * 10)) / 100;

	S.Health = (S.Health * DiffScale);
	S.SightRadius = (S.SightRadius * DiffScale);
	S.Aggressiveness = (S.Aggressiveness * DiffScale);
	S.ReFireRate = (S.ReFireRate * DiffScale);
	S.CombatStyle = (S.CombatStyle * DiffScale);
	S.ProjectileSpeed = (S.ProjectileSpeed * DiffScale);
	S.GroundSpeed = (S.GroundSpeed * DiffScale);
	S.AirSpeed = (S.AirSpeed * DiffScale);
	S.WaterSpeed = (S.WaterSpeed * DiffScale);

	if (S.IsA('Brute')) Brute(S).WhipDamage = (Brute(S).WhipDamage * DiffScale);
	if (S.IsA('Gasbag')) Gasbag(S).PunchDamage = (Gasbag(S).PunchDamage * DiffScale);
	if (S.IsA('Titan')) Titan(S).PunchDamage = (Titan(S).PunchDamage * DiffScale);
	if (S.IsA('Krall')) Krall(S).StrikeDamage = (Krall(S).StrikeDamage * DiffScale);
	if (S.IsA('Manta')) Manta(S).StingDamage = (Manta(S).StingDamage * DiffScale);
	if (S.IsA('Mercenary')) Mercenary(S).PunchDamage = (Mercenary(S).PunchDamage * DiffScale);
	if (S.IsA('Skaarj')) Skaarj(S).ClawDamage = (Skaarj(S).ClawDamage * DiffScale);
	if (S.IsA('Pupae')) Pupae(S).BiteDamage = (Pupae(S).BiteDamage * DiffScale);
	if (S.IsA('Queen')) Queen(S).ClawDamage = (Queen(S).ClawDamage * DiffScale);
	if (S.IsA('Slith')) Slith(S).ClawDamage = (Slith(S).ClawDamage * DiffScale);
	if (S.IsA('Warlord')) Warlord(S).StrikeDamage = (Warlord(S).StrikeDamage * DiffScale);

	if (!S.IsA('Nali') && !S.IsA('Cow')) {
		if (bGameStarted) S.AttitudeToPlayer = ATTITUDE_Hate;
		else S.AttitudeToPlayer = ATTITUDE_Ignore;
	}
}

function String FancyName(Pawn Other, optional Bool upperArticle) {
	local ScriptedPawn S;
	local String baseName, newName, c;
	local int i, a, p;

	S = ScriptedPawn(Other);
	if (S == None) return Other.MenuName;

	baseName = S.MenuName;
	if (baseName == "") baseName = GetItemName(String(S.class));

	newName = Left(baseName, 1);
	for (i = 1; i < Len(baseName); i++) {
		c = Mid(baseName, i, 1);
		p = Asc(Mid(baseName, i-1, 1));
		a = Asc(c);
		if (a >= 65 && a <= 90 && p >= 97 && p <= 122)  newName = newName @ c;
		else newName = newName $ c;
	}

	return newName;
}

function String UppercaseFirst(String S) {
	local String trimmed;
	local int i;

	for (i = 0; i < Len(S); i++) {
		if (Mid(S, i, 1) != " ") {
			trimmed = Mid(S, i);
			break;
		}
	}

	return Caps(Left(trimmed, 1)) $ Mid(trimmed, 1);
}

function AddDefaultInventory(pawn PlayerPawn) {
	bUseTranslocator = false;
	Super.AddDefaultInventory(PlayerPawn);
}

event InitGame(string Options, out string Error) {
	local string InOpt;
	local Mutator M, last;

	MaxTeams = Min(MaxTeams, MaxAllowedTeams);

	for (M = BaseMutator; M != None; M = M.NextMutator) {
		if (M.class == class'Botpack.LowGrav') {
			last.NextMutator = M.NextMutator;
			M.Destroy();
			M = last;
		}
		if (M.class == class'Botpack.InstaGibDM') {
			last.NextMutator = M.NextMutator;
			M.Destroy();
			M = last;
		}
	}

	// This lot is a crappy hack to get Tournament mode
	// to work... Hacked from DeathMatchPlus

	Super(TournamentGameInfo).InitGame(Options, Error);

	RemainingTime = 60 * TimeLimit;
	SetGameSpeed(GameSpeed);
	FragLimit = GetIntOption(Options, "FragLimit", FragLimit);
	TimeLimit = GetIntOption(Options, "TimeLimit", TimeLimit);
	MaxCommanders = GetIntOption(Options, "MaxCommanders", MaxCommanders);
	InOpt = ParseOption(Options, "CoopWeaponMode");
	if (InOpt != "") bCoopWeaponMode = bool(InOpt);
	IDnum = -1;
	IDnum = GetIntOption(Options, "Tournament", IDnum);
	if (IDnum > 0) {
		bRatedGame = true;
		TimeLimit = 0;
		RemainingTime = 0;
	}
	if (Level.NetMode == NM_StandAlone) {
		bRequireReady = true;
		CheckReady();
		CountDown = 1;
	}
	if (!bRequireReady && (Level.NetMode != NM_Standalone)) {
		bRequireReady = true;
		bNetReady = true;
	}

	bJumpMatch = False;
	bNoMonsters = False;
}

function bool SetEndCams(string Reason) {
	local pawn P, Best;
	local PlayerPawn player;
	local bool bGood;

	bGood = True;

	// find individual winner
	for (P = Level.PawnList; P != None; P = P.nextPawn) {
		if (P.bIsPlayer && ((Best == None) || (P.PlayerReplicationInfo.Score > Best.PlayerReplicationInfo.Score))) {
			Best = P;
		}
	}

	bGood = !isBadEnd(Reason);
	GameReplicationInfo.GameEndedComments = endedMessage(reason);

	EndTime = Level.TimeSeconds + 3.0;
	for (P = Level.PawnList; P != None; P = P.nextPawn) {
		player = PlayerPawn(P);
		if (player != None) {
			if (!bTutorialGame) PlayWinMessage(player, bGood);
			if (player == Best) player.ViewTarget = None;
			else player.ViewTarget = Best;
			player.bBehindView = true;
			player.ClientGameEnded();
		}
		P.GotoState('GameEnded');
	}
	CalcEndStats();
	return true;
}

/*
 * Based on Reason, decide whether or not this was a "bad" result.
 * Determines whether the "You have [won|lost] the match" VO plays.
 *
 * Returns true if the player team lost.
 */
function bool isBadEnd(string reason) {
	if ((RemainingTime == 0) && (TimeLimit >= 1)) return true;
	return reason == "No Hunters";
}

/*
 * Based on Reason, return a localised/descriptive message for the
 * game outcome.
 */
function string endedMessage(string reason) {
	if (reason == "No Hunters") return NoHuntersMessage;
	if ((RemainingTime == 0) && (TimeLimit >= 1)) return TimeOutMessage;
	return GameEndedMessage;
}

function PlayStartUpMessage(PlayerPawn NewPlayer) {
	local int i;
	local color Green, DarkGreen;

	NewPlayer.ClearProgressMessages();

	Green.G = 255;
	Green.B = 128;
	DarkGreen.G = 200;
	DarkGreen.B = 64;

	NewPlayer.SetProgressColor(Green, i);

	NewPlayer.SetProgressMessage(GameName, i++);

	if (bRequireReady && (Level.NetMode != NM_Standalone)) {
		NewPlayer.SetProgressMessage(TourneyMessage, i++);
	} else {
		NewPlayer.SetProgressMessage(StartUpMessage, i++);
	}

	if (Level.NetMode == NM_Standalone) NewPlayer.SetProgressMessage(SingleWaitingMessage, i++);
}

function PlayerPawn Login(
	string Portal,
	string Options,
	out string Error,
	class<PlayerPawn> SpawnClass
) {
	local PlayerPawn NewPlayer;
	local NavigationPoint StartSpot;

	NewPlayer = Super(DeathMatchPlus).Login(Portal, Options, Error, SpawnClass);
	if (NewPlayer == None) return None;

	// force finding a red team start spot
	StartSpot = FindPlayerStart(NewPlayer, 0, Portal);
	if (StartSpot != None) {
		NewPlayer.SetCollision(False); // don't collide actors, in case of triggers in start area
		NewPlayer.SetLocation(StartSpot.Location);
		NewPlayer.SetRotation(StartSpot.Rotation);
		NewPlayer.ViewRotation = StartSpot.Rotation;
		NewPlayer.ClientSetRotation(NewPlayer.Rotation);
		StartSpot.PlayTeleportEffect(NewPlayer, true);
		NewPlayer.SetCollision(True); // After setup, re-enable actor collision
	}
	PlayerTeamNum = NewPlayer.PlayerReplicationInfo.Team;

	if (bUseLives && (NewPlayer != None) && !NewPlayer.IsA('Spectator')) {
		NewPlayer.PlayerReplicationInfo.Deaths = MonsterReplicationInfo(GameReplicationInfo).Lives;
	}

	CountHunters();

	return NewPlayer;
}

function bool RestartPlayer(pawn aPlayer) {
	local NavigationPoint startSpot;
	local bool foundStart;
	local Pawn P;

	if (MonsterReplicationInfo(GameReplicationInfo).bUseLives) {
		if (bRestartLevel && Level.NetMode != NM_DedicatedServer && Level.NetMode != NM_ListenServer) {
			return true;
		}

		if (aPlayer.PlayerReplicationInfo.Deaths < 1) {
			BroadcastMessage(aPlayer.PlayerReplicationInfo.PlayerName @ NoLivesLeftMessage, true, 'MonsterCriticalEvent');
			for (P = Level.PawnList; P != None; P = P.NextPawn) {
				if (P.bIsPlayer && (P.PlayerReplicationInfo.Deaths >= 1)) P.PlayerReplicationInfo.Deaths += 0.00001;
			}
			if (aPlayer.IsA('Bot')) {
				aPlayer.PlayerReplicationInfo.bIsSpectator = true;
				aPlayer.PlayerReplicationInfo.bWaitingPlayer = true;
				aPlayer.GotoState('GameEnded');
				return false;
			}
		}

		startSpot = FindPlayerStart(None, 255);
		if (startSpot == None) return false;

		foundStart = aPlayer.SetLocation(startSpot.Location);
		if (foundStart) {
			startSpot.PlayTeleportEffect(aPlayer, true);
			aPlayer.SetRotation(startSpot.Rotation);
			aPlayer.ViewRotation = aPlayer.Rotation;
			aPlayer.Acceleration = vect(0, 0, 0);
			aPlayer.Velocity = vect(0, 0, 0);
			aPlayer.Health = aPlayer.Default.Health;
			aPlayer.ClientSetRotation(startSpot.Rotation);
			aPlayer.bHidden = false;
			aPlayer.SoundDampening = aPlayer.Default.SoundDampening;
			if (aPlayer.PlayerReplicationInfo.Deaths < 1) {
				aPlayer.bHidden = true;
				aPlayer.PlayerRestartState = 'PlayerSpectating';
			} else {
				aPlayer.SetCollision(true, true, true);
				AddDefaultInventory(aPlayer);
			}
		}
		return foundStart;
	} else return Super.RestartPlayer(aPlayer);
}

function EndGame(string Reason) {
	if (bGameEnded) return;
	Super.EndGame(Reason);
}

function CheckEndGame() {
	local Pawn PawnLink;
	local bot B;

	if (bGameEnded) return;

	LivePpl = 0;
	PlainPpl = 0;
	for (PawnLink = Level.PawnList; PawnLink != None; PawnLink = PawnLink.nextPawn)
		if (PawnLink.bIsPlayer && PawnLink.PlayerReplicationInfo != None) {
			if ((PawnLink.PlayerReplicationInfo.Deaths >= 1) && !PawnLink.PlayerReplicationInfo.bIsSpectator) {
				LivePpl ++;
			}
			if (PawnLink.IsA('PlayerPawn') && (PawnLink.PlayerReplicationInfo.Deaths >= 1)) {
				PlainPpl ++;
			}
		}

	if (LivePpl < 1) EndGame("No Hunters");
	else if (PlainPpl < 1) {
		for (PawnLink = Level.PawnList; PawnLink != None; PawnLink = PawnLink.NextPawn) {
			B = Bot(PawnLink);
			if ((B != None) && (B.Health > 0)) B.SetOrders('Attack', None, true);
		}
	}
}

function Killed(pawn killer, pawn Other, name damageType) {
	Super.Killed(Killer, Other, damageType);

	if (killer == None || Other == None) return;

	if (Other.PlayerReplicationInfo == None) return;

	if (Killer == Other) Other.PlayerReplicationInfo.Score -= 4;

	if (Killer.IsA('ScriptedPawn') && Other.bIsPlayer && !MonsterReplicationInfo(GameReplicationInfo).bUseLives) {
		Other.PlayerReplicationInfo.Score -= 5;
	}

	if (MonsterReplicationInfo(GameReplicationInfo).bUseLives && Other.bIsPlayer) {
		Other.PlayerReplicationInfo.Deaths -= 1;
		CheckEndGame();
	}
}

function ScoreKill(pawn Killer, pawn Other) {
	local int Score;

	if (Killer == None) return;

	if (Killer != Other) Killer.KillCount ++;
	if (Other != None) Other.DieCount ++;

	if (Other.bIsPlayer
			&& Other.PlayerReplicationInfo != None
			&& MonsterReplicationInfo(GameReplicationInfo).bUseLives
	) {
		Other.PlayerReplicationInfo.Deaths -= 1;
	}

	if (Killer != Other) {
		if (Killer.IsA('ScriptedPawn')) {
			BroadcastMessage(UppercaseFirst(Killer.GetHumanName()) @ "killed" @ Other.GetHumanName());
		} else {
			BroadcastMessage(Killer.GetHumanName() @ "killed" @ Other.GetHumanName());
		}
	}

	// =========================================================================
	// Score depending on which monster type the player kills
	if (Killer.bIsPlayer && Killer.PlayerReplicationInfo != None) {
		// by default, score 1 for all kills
		Score = 1;

		if (Other.IsA('Titan') || Other.IsA('Queen') || Other.IsA('WarLord')) Score = 5;
		else if (Other.IsA('GiantGasBag') || Other.IsA('GiantManta') || Other.IsA('SkaarjTrooper')) Score = 4;
		else if (Other.IsA('SkaarjWarrior') || Other.IsA('MercenaryElite') || Other.IsA('Brute') || Other.IsA('GiantManta')) Score = 3;
		else if (Other.IsA('Krall') || Other.IsA('Slith') || Other.IsA('GasBag')) Score = 2;
		// Lose points for killing innocent creatures. Shame ;-)
		else if (Other.IsA('Nali') || Other.IsA('Cow')) {
			if (!MaybeEvilFriendlyPawn(ScriptedPawn(Other), Killer)) Score = -5;
		}

		// Get 10 extra points for killing the boss!!
		if ((ScriptedPawn(Other) != None && ScriptedPawn(Other).bIsBoss)) Score = 10;

		Killer.PlayerReplicationInfo.Score += Score;
	}

	BaseMutator.ScoreKill(Killer, Other);
}

function AddToTeam(int num, Pawn Other) {
	local teaminfo aTeam;
	local Pawn P;
	local bool bSuccess;
	local string SkinName, FaceName;

	if (Other != None && Other.PlayerReplicationInfo != None) {
		aTeam = Teams[0];
		aTeam.Size++;
		Other.PlayerReplicationInfo.Team = 0;
		Other.PlayerReplicationInfo.TeamName = aTeam.TeamName;
		bSuccess = false;
		if (Other.IsA('PlayerPawn')) {
			Other.PlayerReplicationInfo.TeamID = 0;
			PlayerPawn(Other).ClientChangeTeam(Other.PlayerReplicationInfo.Team);
		} else Other.PlayerReplicationInfo.TeamID = 1;

		while (!bSuccess) {
			bSuccess = true;
			for (P = Level.PawnList; P != None; P = P.nextPawn) {
				if (P.bIsPlayer && (P != Other) && (P.PlayerReplicationInfo != None)
						&& (P.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team)
						&& (P.PlayerReplicationInfo.TeamId == Other.PlayerReplicationInfo.TeamId)) {
					Other.PlayerReplicationInfo.TeamID++;
					bSuccess = False;
				}
			}
		}

		if (MonsterReplicationInfo(GameReplicationInfo).bUseLives) {
			Other.PlayerReplicationInfo.Deaths = MonsterReplicationInfo(GameReplicationInfo).Lives;
		}

		if (MonsterReplicationInfo(GameReplicationInfo).bUseTeamSkins) {
			Other.static.GetMultiSkin(Other, SkinName, FaceName);
			if (SkinName ~= "None") SkinName = string(Other.Skin);
			if (SkinName ~= "None") SkinName = string(Other.MultiSkins[1]);
			if (!(SkinName ~= "None")) Other.static.SetMultiSkin(Other, SkinName, FaceName, 0);
		}
	}
}

function bool IsOnTeam(Pawn Other, int TeamNum) {
	if (Other == None || Other.PlayerReplicationInfo == None) return false;
	Super.IsOnTeam(Other, TeamNum);
}

function StartMatch() {
	local ScriptedPawn S;

	CountHunters();

	foreach AllActors(class'ScriptedPawn', S) {
		if (!S.IsA('Nali') && !S.IsA('Cow')) S.AttitudeToPlayer = ATTITUDE_Hate;
	}

	bGameStarted = true;

	super.StartMatch();
}

function Timer() {
	CountHunters();
	CountMonsters();

	Super.Timer();
}

function bool FindSpecialAttractionFor(Bot aBot) {
	local ScriptedPawn S;

	if (aBot == None) return false;

	if (aBot.Health < 1) {
		aBot.GotoState('GameEnded');
		return false;
	}

	if (aBot.LastAttractCheck == Level.TimeSeconds) return false;

	foreach AllActors(class'ScriptedPawn', S) {
		if (S.isA('Titan') && S.GetStateName() == 'Sitting') continue;
		if (S.IsA('Nali') || S.IsA('Cow')) {
			if (!MaybeEvilFriendlyPawn(S, aBot)) continue;
		}
		if (S.CanSee(aBot)) {
			if (((S.Enemy == None) || ((S.Enemy.IsA('PlayerPawn')) && (FRand() >= 0.5))) && (S.Health >= 1)) {
				S.Hated = aBot;
				S.Enemy = aBot;
				aBot.Enemy = S;
				S.GotoState('Attacking');
				if (FRand() >= 0.35) {
					aBot.GotoState('Attacking');
					return false;
				}
			}
		} else if (aBot.CanSee(S) && (FRand() >= 0.35) && (S.Health >= 1)) {
			aBot.Enemy = S;
			aBot.GotoState('Attacking');
			S.Enemy = aBot;
			S.GotoState('Attacking');
			return false;
		}
	}

	aBot.LastAttractCheck = Level.TimeSeconds;

	return FindNextWaypoint(aBot);
}

function bool FindNextWaypoint(Bot aBot) {
	local int i;

	if ((aBot.Orders == 'Attack') || ((aBot.Orders == 'Freelance') && (FRand() > 0.2))) {
		for (i = 0; i < NumPoints; i++) {
				if (!waypoints[i].bVisited) {
					if (aBot.ActorReachable(waypoints[i])) aBot.MoveTarget = waypoints[i];
					else aBot.MoveTarget = aBot.FindPathToward(waypoints[i]);

					// there's no path to the next waypoint in line, so try to go to the next one
					if (aBot.MoveTarget == None) continue;

					SetAttractionStateFor(aBot);
					return true;
				}
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

function CountHunters() {
	local Pawn P;
	local int playerCount;

	playerCount = 0;
	for (P = Level.PawnList; P != None; P = P.nextPawn) {
		if (P.bIsPlayer && ((P.PlayerReplicationInfo != None) && !P.PlayerReplicationInfo.bIsSpectator)) {
			playerCount++;
		}
	}

	MonsterReplicationInfo(GameReplicationInfo).Hunters = playerCount;
}

function CountMonsters() {
	local ScriptedPawn S;
	local int monsterCount;

	monsterCount = 0;
	foreach AllActors(class'ScriptedPawn', S) {
		if (S.Health >= 1) {
			if ((S.IsA('Nali') || S.IsA('Cow')) && !MaybeEvilFriendlyPawn(S)) continue;
			monsterCount ++;
		}
	}

	MonsterReplicationInfo(GameReplicationInfo).Monsters = monsterCount;
}

/*
 * Function interned here from DeathMatchPlus, to avoid Accessed None errors on
 * accessing APlayer.NextPawn.PlayerReplicationInfo.
 */
function ChangeName(Pawn Other, string S, bool bNameChange) {
	local pawn APlayer;

	if (Other.IsA('ScriptedPawn')) return;

	if (S == "") return;

	S = left(S, 24);
	if (Other.PlayerReplicationInfo.PlayerName ~= S) return;

	APlayer = Level.PawnList;

	while (APlayer != None) {
		if (!Other.IsA('ScriptedPawn')
				&& APlayer.bIsPlayer && APlayer.PlayerReplicationInfo != None
				&& APlayer.PlayerReplicationInfo.PlayerName ~= S) {
			Other.ClientMessage(S $ NoNameChange);
			return;
		}
		APlayer = APlayer.NextPawn;
	}

	Other.PlayerReplicationInfo.OldName = Other.PlayerReplicationInfo.PlayerName;
	Other.PlayerReplicationInfo.PlayerName = S;
	if (bNameChange && !Other.IsA('Spectator')) BroadcastLocalizedMessage(DMMessageClass, 2, Other.PlayerReplicationInfo);

	if (LocalLog != None) LocalLog.LogNameChange(Other);
	if (WorldLog != None) WorldLog.LogNameChange(Other);
}

/*
 * Function interned here from TeamGamePlus, to avoid Accessed None errors on
 * accessing OtherPlayer.NextPawn.PlayerReplicationInfo.
 */
function NavigationPoint FindPlayerStart(Pawn Player, optional byte InTeam, optional string incomingName ) {
	local PlayerStart Dest, Candidate[16], Best;
	local float Score[16], BestScore, NextDist;
	local pawn OtherPlayer;
	local int i, num;
	local Teleporter Tel;
	local NavigationPoint N;
	local byte Team;

	if (bStartMatch && (Player != None) && Player.IsA('TournamentPlayer')
			&& (Level.NetMode == NM_Standalone)
			&& (TournamentPlayer(Player).StartSpot != None)) {
		return TournamentPlayer(Player).StartSpot;
	}

	if ((Player != None) && (Player.PlayerReplicationInfo != None)) Team = Player.PlayerReplicationInfo.Team;
	else Team = InTeam;

	if (incomingName != "") {
		foreach AllActors(class'Teleporter', Tel) if (string(Tel.Tag) ~= incomingName) return Tel;
	}

	if (Team == 255) Team = 0;

	//choose candidates
	for (N = Level.NavigationPointList; N != None; N = N.nextNavigationPoint) {
		Dest = PlayerStart(N);
		if ((Dest != None) && Dest.bEnabled && (!bSpawnInTeamArea || (Team == Dest.TeamNumber))) {
			if (num < 16) Candidate[num] = Dest;
			else if (Rand(num) < 16) Candidate[Rand(16)] = Dest;
			num++;
		}
	}

	if (num == 0) {
		log("Didn't find any player starts in list for team" @ Team @ "!!!");
		foreach AllActors(class'PlayerStart', Dest) {
			if (num < 16) Candidate[num] = Dest;
			else if (Rand(num) < 16) Candidate[Rand(16)] = Dest;
			num++;
		}
		if ( num == 0 ) return None;
	}

	if (num > 16) num = 16;

	//assess candidates
	for (i = 0; i < num; i++) {
		if (Candidate[i] == LastStartSpot) Score[i] = -6000.0;
		else Score[i] = 4000 * FRand(); //randomize
	}

	for (OtherPlayer = Level.PawnList; OtherPlayer != None; OtherPlayer = OtherPlayer.NextPawn) {
		if (OtherPlayer.IsA('ScriptedPawn') || !OtherPlayer.bIsPlayer || OtherPlayer.PlayerReplicationInfo == None) continue;

		if ((OtherPlayer.Health > 0) && !OtherPlayer.IsA('Spectator')) {
			for (i = 0; i < num; i++) {
				if (OtherPlayer.Region.Zone == Candidate[i].Region.Zone) {
					Score[i] -= 1500;
					NextDist = VSize(OtherPlayer.Location - Candidate[i].Location);
					if (NextDist < 2 * (CollisionRadius + CollisionHeight)) {
						Score[i] -= 1000000.0;
					} else if ((NextDist < 2000) && (OtherPlayer.PlayerReplicationInfo.Team != Team)
							&& FastTrace(Candidate[i].Location, OtherPlayer.Location)) {
						Score[i] -= (10000.0 - NextDist);
					}
				}
			}
		}
	}

	BestScore = Score[0];
	Best = Candidate[0];
	for (i = 1; i < num; i++) {
		if (Score[i] > BestScore) {
			BestScore = Score[i];
			Best = Candidate[i];
		}
	}

	LastStartSpot = Best;

	return Best;
}

/*
 * Function interned here from TeamGamePlus, to avoid Accessed None errors on
 * accessing P.NextPawn.PlayerReplicationInfo.
 */
function SetBotOrders(Bot NewBot) {
	local Pawn P, L;
	local int num, total;

	// only follow players, if there are any
	if ((NumSupportingPlayer == 0)
			|| (NumSupportingPlayer < Teams[NewBot.PlayerReplicationInfo.Team].Size / 2 - 1)) {
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
*/
function byte AssessBotAttitude(Bot aBot, Pawn Other) {
	if (Other.isA('Titan') && Other.GetStateName() == 'Sitting') return 2; // ATTITUDE_Ignore
	if (!aBot.LineOfSightTo(Other))	return 2; // ATTITUDE_Ignore
	if (Other.IsA('Nali') || Other.IsA('Cow')) {
		if (MaybeEvilFriendlyPawn(ScriptedPawn(Other), aBot)) return 1; // ATTITUDE_Hate
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

	return super(DeathMatchPlus).AssessBotAttitude(aBot, Other);
}

function bool MaybeEvilFriendlyPawn(ScriptedPawn Pawn, optional Pawn Other) {
	switch (Pawn.Default.AttitudeToPlayer) {
		case ATTITUDE_Hate:
		case ATTITUDE_Frenzy:
			return true;
		default:
		  if (Other != None) {
				switch (Pawn.AttitudeToCreature(Other)) {
					case ATTITUDE_Hate:
					case ATTITUDE_Frenzy:
						return true;
				}
			}
	}
	return false;
}

defaultproperties {
	MonsterSkill=5
	Lives=6
	TimeOutMessage="Time up, hunt failed!"
	NoHuntersMessage="Hunting party eliminated!"
	NoLivesLeftMessage=" has been lost!"
	bSpawnInTeamArea=True
	bBalanceTeams=False
	bPlayersBalanceTeams=False
	MaxTeams=1
	MaxAllowedTeams=1
	MaxTeamSize=24
	StartUpTeamMessage="Welcome to the hunt!"
	MinPlayers=0
	FragLimit=0
	TimeLimit=30
	bTournament=False
	bUseTranslocator=False
	StartUpMessage="Work with your teammates to hunt down the monsters!"
	StartMessage="The hunt has begun!"
	GameEndedMessage="Hunt Successful!"
	SingleWaitingMessage="Press Fire to begin the hunt."
	InitialBots=6
	ExplodeMessage=" was blown up"
	BurnedMessage=" was incinerated"
	CorrodedMessage=" was slimed"
	HackedMessage=" was hacked"
	DefaultWeapon=Class'Botpack.ChainSaw'
	ScoreBoardType=Class'{{package}}.MonsterBoard'
	BotMenuType="{{package}}.MonsterBotConfig"
	RulesMenuType="{{package}}.MonsterHuntRules"
	SettingsMenuType="{{package}}.MonsterSettings"
	HUDType=Class'{{package}}.MonsterHUD'
	MapListType=Class'{{package}}.MonsterMapList'
	MapPrefix="MH"
	BeaconName="MH"
	LeftMessage=" left the hunt."
	EnteredMessage=" has joined the hunt!"
	GameName="Monster Hunt"
	DMMessageClass=Class'{{package}}.HuntMessage'
	MutatorClass=Class'{{package}}.MonsterBase'
	GameReplicationInfoClass=Class'{{package}}.MonsterReplicationInfo'
	bLocalLog=True
	DefaultBotOrders='Attack'
}
