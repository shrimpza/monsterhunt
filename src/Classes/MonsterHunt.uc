//=============================================================
// MonsterHunt
//=============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterHunt expands TeamGamePlus
	config(MonsterHunt);

var config bool bUseTeamSkins;

var config int MonsterSkill;

var config int Lives;
var bool bUseLives;

var localized string TimeOutMessage;
var localized string NoHuntersMessage;
var localized string HuntCompleteMessage;

var int LivePpl;
var int PlainPpl;

var int LastPoint;
var int NumPoints;

function PostBeginPlay() {
	local ScriptedPawn S;
	local MonsterWaypoint WP;
	local MonsterReplicationInfo mpri;

	LastPoint = 0;

	foreach AllActors(class'MonsterWaypoint', WP) NumPoints ++;

	foreach AllActors(class'ScriptedPawn', S) {
		if (!S.IsA('Nali') && !S.IsA('Cow') && !S.IsA('NaliRabbit')) S.AttitudeToPlayer = ATTITUDE_Ignore;
		if (S.Shadow == None) SetPawnDifficulty(MonsterSkill, S);
	}

	mpri = MonsterReplicationInfo(GameReplicationInfo);
	mpri.Lives = Lives;
	mpri.bUseTeamSkins = bUseTeamSkins;
	mpri.bUseLives = Lives > 0;

  // get initial monster count
	countMonsters();

	Super.PostBeginPlay();
}

function SetPawnDifficulty(int Diff, ScriptedPawn S) {
	local float DiffScale;

  DiffScale = (80 + (Diff * 10)) / 100;

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

	if (S.Shadow == None) S.Shadow = Spawn(class'MonsterShadow', S);
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
	}
	if (Level.NetMode == NM_StandAlone) {
		bRequireReady = true;
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

function bool isBadEnd(string reason) {
	if ((RemainingTime == 0) && (TimeLimit >= 1)) return true;
  return reason == "No Hunters";
}

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
		NewPlayer.SetProgressColor(Green, i);
		NewPlayer.SetProgressMessage(TourneyMessage, i++);
	 } else {
		NewPlayer.SetProgressColor(Green, i);
		NewPlayer.SetProgressMessage(StartUpMessage, i++);
	}

	if (Level.NetMode == NM_Standalone) NewPlayer.SetProgressMessage(SingleWaitingMessage, i++);
}

function playerpawn Login(
	string Portal,
	string Options,
	out string Error,
	class < playerpawn> SpawnClass
) {
	local PlayerPawn newPlayer;
	local NavigationPoint StartSpot;

	newPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	if (newPlayer == None) return None;

	if (bSpawnInTeamArea) {
		StartSpot = FindPlayerStart(NewPlayer, 0, Portal);
		if (StartSpot != None) {
			NewPlayer.SetLocation(StartSpot.Location);
			NewPlayer.SetRotation(StartSpot.Rotation);
			NewPlayer.ViewRotation = StartSpot.Rotation;
			NewPlayer.ClientSetRotation(NewPlayer.Rotation);
			StartSpot.PlayTeleportEffect(NewPlayer, true);
		}
	}
	PlayerTeamNum = NewPlayer.PlayerReplicationInfo.Team;

	if (bUseLives && (NewPlayer != None) && !NewPlayer.IsA('Spectator')) {
		NewPlayer.PlayerReplicationInfo.Deaths = MonsterReplicationInfo(GameReplicationInfo).Lives;
	}

	CountHunters();

	return newPlayer;
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
			BroadcastMessage(aPlayer.PlayerReplicationInfo.PlayerName @ "has been lost!", true, 'MonsterCriticalEvent');
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

function CheckEndGame() {
	local Pawn PawnLink;
	local bot B;

	if (bGameEnded) return;

	LivePpl = 0;
	PlainPpl = 0;
	for (PawnLink = Level.PawnList; PawnLink != None; PawnLink = PawnLink.nextPawn)
		if (PawnLink.bIsPlayer) {
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
	local ScriptedPawn S;

	if (Killer == None) return;

	if (Killer == Other || !Other.bIsPlayer || (Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team)) {
		Super.ScoreKill(Killer, Other);
	}

	if (Other.bIsPlayer && MonsterReplicationInfo(GameReplicationInfo).bUseLives) {
		Other.PlayerReplicationInfo.Deaths -= 1;
	}

 	if (!Other.IsA('ScriptedPawn')) return;

	if (Killer != None) BroadcastMessage(Killer.GetHumanName() @ "killed" $ Other.GetHumanName());

// =========================================================================
// Score depending on which monster type the player kills

  if (Killer.bIsPlayer) {
		if (Other.IsA('Titan') || Other.IsA('Queen') || Other.IsA('WarLord')) Killer.PlayerReplicationInfo.Score += 4;
		else if (Other.IsA('GiantGasBag') || Other.IsA('GiantManta')) Killer.PlayerReplicationInfo.Score += 3;
		else if (Other.IsA('SkaarjWarrior') || Other.IsA('MercenaryElite') || Other.IsA('Brute')) Killer.PlayerReplicationInfo.Score += 2;
		// Lose points for killing innocent creatures. Shame ;-)
		else if (Other.IsA('Nali') || Other.IsA('Cow') || Other.IsA('NaliRabbit')) Killer.PlayerReplicationInfo.Score -= 6;
		// be default, score 1 for all other kills
		else Killer.PlayerReplicationInfo.Score += 1;
	}

	// Get 10 extra points for killing the boss!!

	if (Other.IsA('ScriptedPawn')) S = ScriptedPawn(Other);
	if ((Killer.bIsPlayer) && (S.bIsBoss)) Killer.PlayerReplicationInfo.Score += 9;
}

function AddToTeam(int num, Pawn Other) {
	local teaminfo aTeam;
	local Pawn P;
	local bool bSuccess;
	local string SkinName, FaceName;

	if (Other != None) {
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
				if (P.bIsPlayer && (P != Other)
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
			Other.static.SetMultiSkin(Other, SkinName, FaceName, 0);
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
		if (!S.IsA('Nali') && !S.IsA('Cow') && !S.IsA('NaliRabbit')) S.AttitudeToPlayer = ATTITUDE_Hate;
	}

	super.StartMatch();
}

function Timer() {
	CountHunters();
	countMonsters();

	Super.Timer();
}

function bool FindSpecialAttractionFor(Bot aBot) {
	local MonsterWaypoint W;
	local MonsterEnd E;
	local MonsterWaypoint NextPoint;
	local ScriptedPawn S;

	if (aBot == None) return false;

	if (aBot.Health < 1) {
		aBot.GotoState('GameEnded');
		return false;
	}

	if (aBot.LastAttractCheck == Level.TimeSeconds) return false;

	foreach AllActors(class'ScriptedPawn', S) {
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

	if ((aBot.Orders == 'Attack') || ((aBot.Orders == 'Freelance') && (FRand() > 0.2))) {
		foreach AllActors(class'MonsterWaypoint', W) {
			if (!W.bVisited && (W.Position == LastPoint + 1)) {
				NextPoint = W;
				if (aBot.ActorReachable(NextPoint)) aBot.MoveTarget = NextPoint;
				else aBot.MoveTarget = aBot.FindPathToward(NextPoint);
				NumPoints --;
				SetAttractionStateFor(aBot);
				return true;
			}
		}

		if (NumPoints <= 0) {
			foreach AllActors(class'MonsterEnd', E) {
				if (aBot.ActorReachable(E)) aBot.MoveTarget = E;
				else aBot.MoveTarget = aBot.FindPathToward(E);
				SetAttractionStateFor(aBot);
				return true;
			}
		}
	}

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

function countMonsters() {
  local ScriptedPawn S;
	local int monsterCount;

	monsterCount = 0;
	foreach AllActors(class'ScriptedPawn', S) {
		if (S.Health >= 1) {
			monsterCount ++;

			// silly piggy-back which we use to detect whether a monster has had its difficulty scaled yet
			if (S.Shadow == None)	SetPawnDifficulty(MonsterSkill, S);
		}
	}

	MonsterReplicationInfo(GameReplicationInfo).Monsters = monsterCount;
}

defaultproperties {
     MonsterSkill=5
     Lives=6
     TimeOutMessage="Time up, hunt failed!"
     NoHuntersMessage="Hunting party eliminated!"
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
     ScoreBoardType=Class'MonsterHunt.MonsterBoard'
     BotMenuType="MonsterHunt.MonsterBotConfig"
     RulesMenuType="MonsterHunt.MonsterHuntRules"
     SettingsMenuType="MonsterHunt.MonsterSettings"
     HUDType=Class'MonsterHunt.MonsterHUD'
     MapListType=Class'MonsterHunt.MonsterMapList'
     MapPrefix="MH"
     BeaconName="MH"
     LeftMessage=" left the hunt."
     EnteredMessage=" has joined the hunt!"
     GameName="Monster Hunt"
     DMMessageClass=Class'MonsterHunt.HuntMessage'
     MutatorClass=Class'MonsterHunt.MonsterBase'
     GameReplicationInfoClass=Class'MonsterHunt.MonsterReplicationInfo'
     bLocalLog=True
}
