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

var bool bGameStarted;

var config class<MonsterHuntScoreExtension> ScoreExtensionType;
var config class<MonsterHuntBotExtension> BotExtensionType;
var config class<MonsterHuntMonsterExtension> MonsterExtensionType;
var MonsterHuntScoreExtension scoreExtension;
var MonsterHuntBotExtension botExtension;
var MonsterHuntMonsterExtension monsterExtension;

function PreBeginPlay() {
	Super.PreBeginPlay();

	// Spawn extensions
	spawnExtensions();
}

function spawnExtensions() {
	scoreExtension = Spawn(ScoreExtensionType);
	if (scoreExtension != None) {
		log("Using scoreExtension " $ scoreExtension);
		scoreExtension.game = Self;
		scoreExtension.gameReplicationInfo = GameReplicationInfo;
	}	else {
		error("*** No score extension spawned, players will not score monster kills!!");
	}

	botExtension = Spawn(BotExtensionType);
	if (botExtension != None) {
		log("Using botExtension " $ botExtension);
		botExtension.game = Self;
		botExtension.gameReplicationInfo = GameReplicationInfo;
	}	else {
		error("*** No bot extension spawned, bots will be dumb!!");
	}

	monsterExtension = Spawn(MonsterExtensionType);
	if (monsterExtension != None) {
		log("Using monsterExtension " $ monsterExtension);
		monsterExtension.game = Self;
		monsterExtension.gameReplicationInfo = GameReplicationInfo;
		monsterExtension.EvaluatePawns();
	}	else {
		error("*** No monster extension spawned, some monster behaviours might not work!!");
	}
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
	if (S == None) return;
	if (MonsterExtensionType != None)	MonsterExtensionType.static.setPawnDifficulty(MonsterSkill, S, bGameStarted);
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

function Killed(Pawn killer, Pawn other, name damageType) {
	Super.Killed(killer, other, damageType);

	if (other == None) return;

	if (other.PlayerReplicationInfo == None) return;

	if (scoreExtension != None) other.PlayerReplicationInfo.Score += scoreExtension.PlayerKilled(killer, other);

	if (MonsterReplicationInfo(GameReplicationInfo).bUseLives && other.bIsPlayer) {
		// if there was no killer (trap death), super increases the deaths count, while we're decreasing it here.
		// avoiding introduction of a new PRI value for life countdown, since some things elsewhere may now rely on it.
		// so we need to decrease it by two, as a giant hack :(
		if (killer == None) other.PlayerReplicationInfo.Deaths -= 1;
		other.PlayerReplicationInfo.Deaths -= 1;
		CheckEndGame();
	}
}

function ScoreKill(Pawn Killer, Pawn Other) {
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

	if (Killer.bIsPlayer && Killer.PlayerReplicationInfo != None) {
		if (scoreExtension != None) Score = scoreExtension.ScoreKill(killer, other);
		else Score = 1;
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

	if (monsterExtension != None) monsterExtension.EvaluatePawns();

	Super.Timer();
}

function bool FindSpecialAttractionFor(Bot aBot) {
	if (botExtension != None) return botExtension.FindSpecialAttractionFor(aBot);
	else return Super.FindSpecialAttractionFor(aBot);
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
function SetBotOrders(Bot newBot) {
	if (botExtension != None) botExtension.SetBotOrders(newBot);
	else Super.SetBotOrders(newBot);
}

/*
		AssessBotAttitude returns a value that translates to an attitude
		0 = ATTITUDE_Fear;
		1 = return ATTITUDE_Hate;
		2 = return ATTITUDE_Ignore;
		3 = return ATTITUDE_Friendly;
*/
function byte AssessBotAttitude(Bot aBot, Pawn Other) {
	local byte newAttitude;

	if (botExtension != None) {
		newAttitude =   botExtension.AssessBotAttitude(aBot, Other);
		if (newAttitude < 255) return newAttitude;
	}

	return super(DeathMatchPlus).AssessBotAttitude(aBot, Other);
}

function bool MaybeEvilFriendlyPawn(ScriptedPawn Pawn, optional Pawn Other) {
	if (monsterExtension != None) return monsterExtension.MaybeEvilFriendlyPawn(Pawn, Other);
	else return false;
}

function SetLastPoint(int LastPointPosition) {
	if (botExtension != None) botExtension.LastPoint = LastPointPosition;
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

	ScoreExtensionType=Class'{{package}}.MonsterHuntScoreExtension'
	BotExtensionType=Class'{{package}}.MonsterHuntBotExtension'
	MonsterExtensionType=Class'{{package}}.MonsterHuntMonsterExtension'
}
