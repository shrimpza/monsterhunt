//--[[[[----
//=============================================================
// MonsterHunt
//=============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2002 Kenneth "Shrimp" Watson
//          For more info, http://shrimpworks.za.net
//    Not to be modified without permission from the author
// ============================================================

class MonsterHunt expands TeamGamePlus
	config(MonsterHunt);

var config bool bUseTeamSkins;

var config int MonsterSkill;

var config int Lives;
var bool bUseLives;

var string TimeOutMessage;

var int LivePpl;
var int PlainPpl;

var int LastPoint;
var int NumPoints;
var int MonstersTotal;
var int HuntersTotal;

function PostBeginPlay()
{
	local int i;
	local ScriptedPawn S;
	local pawn pawnlink;
	local MonsterWaypoint WP;

	LastPoint = 0;

//	MonsterReplicationInfo(GameReplicationInfo).Lives = Lives;

	foreach AllActors(class'MonsterWaypoint', WP)
		NumPoints ++;

	foreach AllActors(class'ScriptedPawn', S)
	{
		MonstersTotal ++;
		if ( !S.IsA('Nali') && !S.IsA('Cow') && !S.IsA('NaliRabbit') )
			S.AttitudeToPlayer=ATTITUDE_Ignore;
		if (S.Shadow == None)
			SetPawnDifficulty(MonsterSkill, S);
	}

	MonsterReplicationInfo(GameReplicationInfo).Monsters = MonstersTotal;
	MonsterReplicationInfo(GameReplicationInfo).Lives = Lives;
	MonsterReplicationInfo(GameReplicationInfo).bUseTeamSkins = bUseTeamSkins;
	if ( MonsterReplicationInfo(GameReplicationInfo).Lives <= 0 )
		MonsterReplicationInfo(GameReplicationInfo).bUseLives = False;
	else
		MonsterReplicationInfo(GameReplicationInfo).bUseLives = True;

	Super.PostBeginPlay();
}

function SetPawnDifficulty( int Diff, ScriptedPawn S )
{
	local int DiffScale;

	switch (Diff)
	{
		case 0:
			DiffScale = 80;
			break;
		case 1:
			DiffScale = 90;
			break;
		case 2:
			DiffScale = 100;
			break;
		case 3:
			DiffScale = 110;
			break;
		case 4:
			DiffScale = 120;
			break;
		case 5:
			DiffScale = 130;
			break;
		case 6:
			DiffScale = 140;
			break;
		case 7:
			DiffScale = 150;
			break;
	}
	S.Health = (S.Health * DiffScale) / 100;
	S.SightRadius = (S.SightRadius * DiffScale) / 100;
	S.Aggressiveness = (S.Aggressiveness * DiffScale) / 100;
	S.ReFireRate = (S.ReFireRate * DiffScale) / 100;
	S.CombatStyle = (S.CombatStyle * DiffScale) / 100;
	S.ProjectileSpeed = (S.ProjectileSpeed * DiffScale) / 100;
	S.GroundSpeed = (S.GroundSpeed * DiffScale) / 100;
	S.AirSpeed = (S.AirSpeed * DiffScale) / 100;
	S.WaterSpeed = (S.WaterSpeed * DiffScale) / 100;

	if (S.IsA('Brute'))
		Brute(S).WhipDamage = (Brute(S).WhipDamage * DiffScale) / 100;
	if (S.IsA('Gasbag'))
		Gasbag(S).PunchDamage = (Gasbag(S).PunchDamage * DiffScale) / 100;
	if (S.IsA('Titan'))
		Titan(S).PunchDamage = (Titan(S).PunchDamage * DiffScale) / 100;
	if (S.IsA('Krall'))
		Krall(S).StrikeDamage = (Krall(S).StrikeDamage * DiffScale) / 100;
	if (S.IsA('Manta'))
		Manta(S).StingDamage = (Manta(S).StingDamage * DiffScale) / 100;
	if (S.IsA('Mercenary'))
		Mercenary(S).PunchDamage = (Mercenary(S).PunchDamage * DiffScale) / 100;
	if (S.IsA('Skaarj'))
		Skaarj(S).ClawDamage = (Skaarj(S).ClawDamage * DiffScale) / 100;
	if (S.IsA('Pupae'))
		Pupae(S).BiteDamage = (Pupae(S).BiteDamage * DiffScale) / 100;
	if (S.IsA('Queen'))
		Queen(S).ClawDamage = (Queen(S).ClawDamage * DiffScale) / 100;
	if (S.IsA('Slith'))
		Slith(S).ClawDamage = (Slith(S).ClawDamage * DiffScale) / 100;
	if (S.IsA('Warlord'))
		Warlord(S).StrikeDamage = (Warlord(S).StrikeDamage * DiffScale) / 100;
	
	if (S.Shadow == None)
		S.Shadow = Spawn(class'MonsterShadow', S);
}

function AddDefaultInventory( pawn PlayerPawn )
{
	bUseTranslocator = false;
	Super.AddDefaultInventory(PlayerPawn);
}

event InitGame( string Options, out string Error )
{
	local string InOpt;
	local Mutator M, last;
	local class<Mutator> MutatorClass;
	local int i;

	MaxTeams = Min(MaxTeams,MaxAllowedTeams);

	for (M = BaseMutator; M != None; M = M.NextMutator)
	{
		if (M.class == class'Botpack.LowGrav')
		{
			last.NextMutator = M.NextMutator;
			M.Destroy();M = last;
		}
		if (M.class == class'Botpack.InstaGibDM')
		{
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
	FragLimit = GetIntOption( Options, "FragLimit", FragLimit );
	TimeLimit = GetIntOption( Options, "TimeLimit", TimeLimit );
	MaxCommanders = GetIntOption( Options, "MaxCommanders", MaxCommanders );
	InOpt = ParseOption( Options, "CoopWeaponMode");
	if ( InOpt != "" ) bCoopWeaponMode = bool(InOpt);
	IDnum = -1;
	IDnum = GetIntOption( Options, "Tournament", IDnum );
	if ( IDnum > 0 ){
		bRatedGame = true;
		TimeLimit = 0;
		RemainingTime = 0;}
	if ( Level.NetMode == NM_StandAlone ){
		bRequireReady = true;
		CheckReady();}
	if ( Level.NetMode == NM_StandAlone ){
		bRequireReady = true;
		CountDown = 1;}
	if ( !bRequireReady && (Level.NetMode != NM_Standalone) ){
		bRequireReady = true;
		bNetReady = true;}

	bJumpMatch = False;
	bNoMonsters = False;
}

function bool SetEndCams(string Reason)
{
	local TeamInfo BestTeam;
	local int i;
	local pawn P, Best;
	local PlayerPawn player;
	local bool bGood;

	bGood = True;

	// find individual winner
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
		if ( P.bIsPlayer && ((Best == None) || (P.PlayerReplicationInfo.Score > Best.PlayerReplicationInfo.Score)) )
			Best = P;

	if ( Reason == "No Hunters" )
	{
		bGood = False;
		GameEndedMessage = "Hunting party eliminated!";
	}

	if ( (RemainingTime == 0) && (TimeLimit >= 1) )
	{
		bGood = False;
		GameReplicationInfo.GameEndedComments = TimeOutMessage;
	}
	else
		GameReplicationInfo.GameEndedComments = GameEndedMessage;

	EndTime = Level.TimeSeconds + 3.0;
	for ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		player = PlayerPawn(P);
		if ( Player != None )
		{
			if (!bTutorialGame)
				PlayWinMessage(Player, bGood);
			player.bBehindView = true;
			if ( Player == Best )
				Player.ViewTarget = None;
			else
				Player.ViewTarget = Best;
			player.ClientGameEnded();
		}
		P.GotoState('GameEnded');
	}
	CalcEndStats();
	return true;
}

function PlayStartUpMessage(PlayerPawn NewPlayer)
{
	local int i;
	local color Green, DarkGreen;

	NewPlayer.ClearProgressMessages();

	Green.G = 255;
	Green.B = 128;
	DarkGreen.G = 200;
	DarkGreen.B = 64;

	NewPlayer.SetProgressColor(Green, i);

	NewPlayer.SetProgressMessage(GameName, i++);
	if ( bRequireReady && (Level.NetMode != NM_Standalone) )
	{
		NewPlayer.SetProgressColor(Green, i);
		NewPlayer.SetProgressMessage(TourneyMessage, i++);
	}
	else
	{
		NewPlayer.SetProgressColor(Green, i);
		NewPlayer.SetProgressMessage(StartUpMessage, i++);
	}

	if ( Level.NetMode == NM_Standalone )
		NewPlayer.SetProgressMessage(SingleWaitingMessage, i++);
}

function playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn newPlayer;
	local NavigationPoint StartSpot;

	newPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	if ( newPlayer == None)
		return None;

	if ( bSpawnInTeamArea )
	{
		StartSpot = FindPlayerStart(NewPlayer,0, Portal);
		if ( StartSpot != None )
		{
			NewPlayer.SetLocation(StartSpot.Location);
			NewPlayer.SetRotation(StartSpot.Rotation);
			NewPlayer.ViewRotation = StartSpot.Rotation;
			NewPlayer.ClientSetRotation(NewPlayer.Rotation);
			StartSpot.PlayTeleportEffect( NewPlayer, true );
		}
	}
	PlayerTeamNum = NewPlayer.PlayerReplicationInfo.Team;

	if (bUseLives)
		if ( (NewPlayer != None) && !NewPlayer.IsA('Spectator') )
			NewPlayer.PlayerReplicationInfo.Deaths = MonsterReplicationInfo(GameReplicationInfo).Lives;

	CountHunters();

	return newPlayer;
}

function bool RestartPlayer( pawn aPlayer )	
{
	local NavigationPoint startSpot;
	local bool foundStart;
	local Pawn P;

	if (MonsterReplicationInfo(GameReplicationInfo).bUseLives)
	{
		if( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
			return true;

		if ( aPlayer.PlayerReplicationInfo.Deaths < 1 )
		{
			BroadcastMessage(aPlayer.PlayerReplicationInfo.PlayerName$" has been lost!", true, 'MonsterCriticalEvent');
			For ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.bIsPlayer && (P.PlayerReplicationInfo.Deaths >= 1) )
					P.PlayerReplicationInfo.Deaths += 0.00001;
			if ( aPlayer.IsA('Bot') )
			{
				aPlayer.PlayerReplicationInfo.bIsSpectator = true;
				aPlayer.PlayerReplicationInfo.bWaitingPlayer = true;
				aPlayer.GotoState('GameEnded');
				return false;
			}
		}

		startSpot = FindPlayerStart(None, 255);
		if( startSpot == None )
			return false;
			
		foundStart = aPlayer.SetLocation(startSpot.Location);
		if( foundStart )
		{
			startSpot.PlayTeleportEffect(aPlayer, true);
			aPlayer.SetRotation(startSpot.Rotation);
			aPlayer.ViewRotation = aPlayer.Rotation;
			aPlayer.Acceleration = vect(0,0,0);
			aPlayer.Velocity = vect(0,0,0);
			aPlayer.Health = aPlayer.Default.Health;
			aPlayer.ClientSetRotation( startSpot.Rotation );
			aPlayer.bHidden = false;
			aPlayer.SoundDampening = aPlayer.Default.SoundDampening;
			if ( aPlayer.PlayerReplicationInfo.Deaths < 1 )
			{
				aPlayer.bHidden = true;
				aPlayer.PlayerRestartState = 'PlayerSpectating';
			} 
			else
			{
				aPlayer.SetCollision( true, true, true );
				AddDefaultInventory(aPlayer);
			}
		}
		return foundStart;
	}
	else 
		return Super.RestartPlayer(aPlayer);
}

function CheckEndGame()
{
	local Pawn PawnLink;
	local int StillPlaying;
	local bool bStillHuman;
	local bot B, D;

	if ( bGameEnded )
		return;

	LivePpl = 0;
	PlainPpl = 0;
	for ( PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.nextPawn )
		if ( PawnLink.bIsPlayer )
		{
			if ( ( PawnLink.PlayerReplicationInfo.Deaths >= 1 ) && 
				!PawnLink.PlayerReplicationInfo.bIsSpectator )
				LivePpl ++;
			if ( PawnLink.IsA('PlayerPawn') &&
				(PawnLink.PlayerReplicationInfo.Deaths >= 1) )
				PlainPpl ++;
		}

	if ( LivePpl < 1 )
		EndGame("No Hunters");
	else if ( PlainPpl < 1 )
	{
		for ( PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.NextPawn )
		{
			B = Bot(PawnLink);
			if ( (B != None) && (B.Health > 0) )
				B.SetOrders('Attack', None,true);
		}
	}		
}

function Killed( pawn killer, pawn Other, name damageType )
{
	Super.Killed(Killer, Other, damageType);

	if ( Killer == Other )
		Other.PlayerReplicationInfo.Score -= 4;

	if ( Killer.IsA('ScriptedPawn') && Other.bIsPlayer && !MonsterReplicationInfo(GameReplicationInfo).bUseLives)
		Other.PlayerReplicationInfo.Score -= 5;

	if (MonsterReplicationInfo(GameReplicationInfo).bUseLives && Other.bIsPlayer)
	{
		Other.PlayerReplicationInfo.Deaths -= 1;
		CheckEndGame();
	}
}

function ScoreKill(pawn Killer, pawn Other)
{
	local ScriptedPawn S;

	if ( (Killer == None) || (Killer == Other) || !Other.bIsPlayer 
		|| (Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team) )
		Super.ScoreKill(Killer, Other);

	MonstersTotal = 0;

	foreach AllActors(class'ScriptedPawn', S)
	{
		if (S.Health >= 1)
			MonstersTotal ++;
		if (S.Shadow == None)
			SetPawnDifficulty(MonsterSkill, S);
	}

	MonsterReplicationInfo(GameReplicationInfo).Monsters = MonstersTotal;

	if (Other.bIsPlayer && MonsterReplicationInfo(GameReplicationInfo).bUseLives)
		Other.PlayerReplicationInfo.Deaths -= 1;

 	if(!Other.IsA('ScriptedPawn')) return;

	if(Killer!=None)
 	{
    		BroadcastMessage(Killer.GetHumanName()@"killed"$Other.GetHumanName());
 	}

// =========================================================================
// Score depending on which monster type the player kills

	if ( (Killer.bIsPlayer) && ( (Other.IsA('Titan')) || (Other.IsA('Queen')) || (Other.IsA('WarLord')) ) )
		Killer.PlayerReplicationInfo.Score += 4;
	if ( (Killer.bIsPlayer) && ( (Other.IsA('GiantGasBag')) || (Other.IsA('GiantManta')) ) )
		Killer.PlayerReplicationInfo.Score += 3;
	if ( (Killer.bIsPlayer) && ( (Other.IsA('SkaarjWarrior')) || (Other.IsA('MercenaryElite')) || (Other.IsA('Brute')) ) )
		Killer.PlayerReplicationInfo.Score += 2;
	if ( (Killer.bIsPlayer) && ( (Other.IsA('SkaarjTrooper')) || ( (Other.IsA('Mercenary')) && (!Other.IsA('MercenaryElite')) ) || (Other.IsA('Krall')) || (Other.IsA('Slith')) || ( (Other.IsA('GasBag')) && (!Other.IsA('GiantGasBag')) ) ) )
		Killer.PlayerReplicationInfo.Score += 1;

	// Lose points for killing innocent creatures. Shame ;-)
	if ( (Killer.bIsPlayer) && ( (Other.IsA('Nali')) || (Other.IsA('Cow')) || (Other.IsA('NaliRabbit')) ) )
		Killer.PlayerReplicationInfo.Score -= 6;

	// Get 10 extra points for killing the boss!!

	if (Other.IsA('ScriptedPawn'))
		S = ScriptedPawn(Other);
	if ( (Killer.bIsPlayer) && ( S.bIsBoss ) )
		Killer.PlayerReplicationInfo.Score += 9;
}

function AddToTeam( int num, Pawn Other )
{
	local teaminfo aTeam;
	local Pawn P;
	local bool bSuccess;
	local string SkinName, FaceName;

	if ( Other != None )
	{
		aTeam = Teams[0];
		aTeam.Size++;
		Other.PlayerReplicationInfo.Team = 0;
		Other.PlayerReplicationInfo.TeamName = aTeam.TeamName;
		bSuccess = false;
		if ( Other.IsA('PlayerPawn') )
		{
			Other.PlayerReplicationInfo.TeamID = 0;
			PlayerPawn(Other).ClientChangeTeam(Other.PlayerReplicationInfo.Team);
		}
		else
			Other.PlayerReplicationInfo.TeamID = 1;

		while ( !bSuccess )
		{
			bSuccess = true;
			for ( P=Level.PawnList; P!=None; P=P.nextPawn )
				if ( P.bIsPlayer && (P != Other) 
					&& (P.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) 
					&& (P.PlayerReplicationInfo.TeamId == Other.PlayerReplicationInfo.TeamId) )
			{	
				Other.PlayerReplicationInfo.TeamID++;
				bSuccess = False;
			}
		}

		if (MonsterReplicationInfo(GameReplicationInfo).bUseLives)
			Other.PlayerReplicationInfo.Deaths = MonsterReplicationInfo(GameReplicationInfo).Lives;

		if (MonsterReplicationInfo(GameReplicationInfo).bUseTeamSkins)
		{
			Other.static.GetMultiSkin(Other, SkinName, FaceName);
			Other.static.SetMultiSkin(Other, SkinName, FaceName, 0);
		}
	}
}

function StartMatch()
{
	local ScriptedPawn S;

	CountHunters();

	foreach AllActors(class'ScriptedPawn', S)
	{
		if ( !S.IsA('Nali') && !S.IsA('Cow') && !S.IsA('NaliRabbit') )
			S.AttitudeToPlayer=ATTITUDE_Hate;
	}

	super.StartMatch();
}

function Timer()
{
	CountHunters();

	Super.Timer();
}

function CountHunters()
{
	local Bot B;
	local TournamentPlayer P;

	HuntersTotal = 0;

	foreach AllActors(class'TournamentPlayer', P)
	{
		if (!P.PlayerReplicationInfo.bIsSpectator)
			HuntersTotal ++;
	}

	foreach AllActors(class'Bot', B)
	{
		if (!B.PlayerReplicationInfo.bIsSpectator)
			HuntersTotal ++;
	}

	MonsterReplicationInfo(GameReplicationInfo).Hunters = HuntersTotal;
}

function bool FindSpecialAttractionFor(Bot aBot)
{
	local MonsterWaypoint W;
	local MonsterEnd E;
	local MonsterWaypoint NextPoint;
	local bool bFound;
	local ScriptedPawn S;

	if ((aBot != None) && (aBot.Health < 1))
	{
		aBot.GotoState('GameEnded');
		return false;
	}

	if ( aBot.LastAttractCheck == Level.TimeSeconds )
		return false;

	if(aBot==None)
		return false;

	foreach AllActors( class'ScriptedPawn', S )
	{
		if ( S.CanSee(aBot) )
		{
			if ( ((S.Enemy == None) || ((S.Enemy.IsA('PlayerPawn')) && (FRand() >= 0.5))) && (S.Health >= 1) )
			{
				S.Hated = aBot;
				S.Enemy = aBot;
				aBot.Enemy = S;
				S.GotoState('Attacking');
				If (FRand() >= 0.35)
				{
					aBot.GotoState('Attacking');
					return false;
				}
			}
		}
		else
		if (aBot.CanSee(S) && (FRand() >= 0.35) && (S.Health >= 1))
		{
			aBot.Enemy = S;
			aBot.GotoState('Attacking');
			S.Enemy = aBot;
			S.GotoState('Attacking');
			return false;
		}
	}

	aBot.LastAttractCheck = Level.TimeSeconds;

	if ( (aBot.Orders == 'Attack') || ((aBot.Orders == 'Freelance') && (FRand() > 0.2)) )
	{
		foreach AllActors( class'MonsterWaypoint', W )
		{
			if (!W.bVisited && (W.Position == LastPoint + 1))
			{
				NextPoint = W;
				if ( aBot.ActorReachable(NextPoint) )
					aBot.MoveTarget = NextPoint;
				else
					aBot.MoveTarget = aBot.FindPathToward(NextPoint);
				NumPoints --;
				SetAttractionStateFor(aBot);
				return True;
			}
		}

		if (NumPoints <= 0)
		{
			foreach AllActors( class'MonsterEnd', E )
			{
				if ( aBot.ActorReachable(E) )
					aBot.MoveTarget = E;
				else
					aBot.MoveTarget = aBot.FindPathToward(E);
				SetAttractionStateFor(aBot);
				return True;
			}
		}
	}

	return false;
}

defaultproperties
{
     MonsterSkill=5
     Lives=6
     TimeOutMessage="Time up, hunt failed!"
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

//--]]]]----
