// ============================================================
// MonsterBoard
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterBoard extends TournamentScoreBoard;

var color LightGreenColor, DarkGreenColor;
var localized String MonsterDifficultyJoinString, ObjectivesString;

function DrawHeader(canvas Canvas) {
	local GameReplicationInfo GRI;
	local float XL, YL;
	local font CanvasFont;

	Canvas.DrawColor = DarkGreenColor;
	GRI = PlayerPawn(Owner).GameReplicationInfo;

	Canvas.Font = MyFonts.GetHugeFont(Canvas.ClipX);

	Canvas.bCenter = True;
	Canvas.StrLen("Test", XL, YL);
	ScoreStart = 58.0 / 768.0 * Canvas.ClipY;
	CanvasFont = Canvas.Font;
	if (GRI.GameEndedComments != "") {
		Canvas.DrawColor = GoldColor;
		Canvas.SetPos(0, ScoreStart);
		Canvas.DrawText(GRI.GameEndedComments, True);
	} else {
		Canvas.SetPos(0, ScoreStart);
		DrawVictoryConditions(Canvas);
	}
	Canvas.bCenter = False;
	Canvas.Font = CanvasFont;
}

function DrawVictoryConditions(Canvas Canvas) {
	local TournamentGameReplicationInfo TGRI;
	local float XL, YL;

	TGRI = TournamentGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);
	if (TGRI == None) return;

	Canvas.DrawText(TGRI.GameName);
	Canvas.StrLen("Test", XL, YL);
	Canvas.SetPos(0, Canvas.CurY - YL);

	Canvas.DrawColor = LightGreenColor;

	if (TGRI.TimeLimit > 0) Canvas.DrawText(TimeLimit @ TGRI.TimeLimit $ ":00");
}

function DrawTrailer(canvas Canvas) {
	local int Hours, Minutes, Seconds;
	local float XL, YL;
	local PlayerPawn PlayerOwner;
	local GameReplicationInfo GRI;
	local string TitleQuote, DifficultyQuote;

	Canvas.bCenter = true;
	Canvas.StrLen("Test", XL, YL);
	Canvas.DrawColor = LightGreenColor;
	Canvas.SetPos(0, Canvas.ClipY - 2 * YL);

	PlayerOwner = PlayerPawn(Owner);
	GRI = PlayerPawn(Owner).GameReplicationInfo;

	if (Level.Game.IsA('MonsterHunt') && GRI.IsA('MonsterReplicationInfo')) {
		DifficultyQuote = class'MonsterHuntRules'.default.Skills[
			class'MonsterHuntRules'.static.TranslateMonsterSkillIndex(MonsterReplicationInfo(GRI).MonsterSkill)
		] @ MonsterDifficultyJoinString;
	} else {
		DifficultyQuote = "";
	}

	if ((Level.NetMode == NM_Standalone) && Level.Game.IsA('MonsterHunt')) {
		TitleQuote = GRI.GameName @ MapTitle @ MapTitleQuote $ Level.Title $ MapTitleQuote;
		if (DeathMatchPlus(Level.Game).bNoviceMode) {
			TitleQuote = class'ChallengeBotInfo'.default.Skills[Level.Game.Difficulty] @ TitleQuote;
		} else {
			TitleQuote = class'ChallengeBotInfo'.default.Skills[Level.Game.Difficulty + 4] @ TitleQuote;
		}
	}	else {
		TitleQuote = GRI.GameName @ MapTitle @ Level.Title;
	}

	Canvas.DrawText(DifficultyQuote @ TitleQuote, true);

	Canvas.SetPos(0, Canvas.ClipY - YL);
	if (bTimeDown || (GRI.RemainingTime > 0)) {
		bTimeDown = true;
		if (GRI.RemainingTime <= 0) {
			Canvas.DrawText(RemainingTime @ "00:00", true);
		} else {
			Minutes = GRI.RemainingTime / 60;
			Seconds = GRI.RemainingTime % 60;
			Canvas.DrawText(RemainingTime @ TwoDigitString(Minutes) $ ":" $ TwoDigitString(Seconds), true);
		}
	} else {
		Seconds = GRI.ElapsedTime;
		Minutes = Seconds / 60;
		Hours   = Minutes / 60;
		Seconds = Seconds - (Minutes * 60);
		Minutes = Minutes - (Hours * 60);
		Canvas.DrawText(ElapsedTime @ TwoDigitString(Hours) $ ":" $ TwoDigitString(Minutes) $ ":" $ TwoDigitString(Seconds), true);
	}

	if (GRI.GameEndedComments != "") {
		Canvas.bCenter = true;
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.ClipY - Min(YL * 6, Canvas.ClipY * 0.1));
		Canvas.DrawColor = GreenColor;
		if (Level.NetMode == NM_Standalone) Canvas.DrawText(Ended @ Continue, true);
		else Canvas.DrawText(Ended, true);
	} else if ((PlayerOwner != None) && (PlayerOwner.Health <= 0)) {
		Canvas.bCenter = true;
		Canvas.StrLen("Test", XL, YL);
		Canvas.SetPos(0, Canvas.ClipY - Min(YL * 6, Canvas.ClipY * 0.1));
		Canvas.DrawColor = GreenColor;
		Canvas.DrawText(Restart, true);
	}
	Canvas.bCenter = false;

	DrawObjectivesList(Canvas);
}

function DrawCategoryHeaders(Canvas Canvas) {
	local float Offset, XL, YL;

	Offset = Canvas.CurY;
	Canvas.DrawColor = LightGreenColor;

	Canvas.StrLen(PlayerString, XL, YL);
	Canvas.SetPos((Canvas.ClipX / 8) * 2 - XL / 2, Offset);
	Canvas.DrawText(PlayerString);

	Canvas.StrLen(FragsString, XL, YL);
	Canvas.SetPos((Canvas.ClipX / 8) * 5.3 - XL / 2, Offset);
	Canvas.DrawText(FragsString);

	if (MonsterReplicationInfo(PlayerPawn(Owner).GameReplicationInfo).bUseLives) {
		Canvas.StrLen(DeathsString, XL, YL);
		Canvas.SetPos((Canvas.ClipX / 8) * 6.35 - XL / 2, Offset);
		Canvas.DrawText(DeathsString);
	}
}

function DrawNameAndPing(Canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset, bool bCompressed) {
	local float XL, YL, XL2, YL2, XL3, YL3;
	local bool bLocalPlayer;
	local PlayerPawn PlayerOwner;
	local int Time;

	PlayerOwner = PlayerPawn(Owner);

	bLocalPlayer = (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName);
	Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);

	// Draw Name
	if (PRI.bAdmin) Canvas.DrawColor = WhiteColor;
	else if (bLocalPlayer) Canvas.DrawColor = RedColor;
	else Canvas.DrawColor = BronzeColor;

	Canvas.SetPos(Canvas.ClipX * 0.1875, YOffset);
	Canvas.DrawText(PRI.PlayerName, False);

	Canvas.StrLen("0000", XL, YL);

	// Draw Score
	if (!bLocalPlayer) Canvas.DrawColor = GoldColor;

	Canvas.StrLen(int(PRI.Score), XL2, YL);
	Canvas.SetPos(Canvas.ClipX * 0.645 + XL * 0.5 - XL2, YOffset);
	Canvas.DrawText(int(PRI.Score), false);

	// Draw remaining lives
	if (MonsterReplicationInfo(PlayerPawn(Owner).GameReplicationInfo).bUseLives) {
		Canvas.StrLen(int(PRI.Deaths), XL2, YL);
		Canvas.SetPos(Canvas.ClipX * 0.775 + XL * 0.5 - XL2, YOffset);
		Canvas.DrawText(int(PRI.Deaths), false);
	}

	if ((Canvas.ClipX > 512) && (Level.NetMode != NM_Standalone)) {
		Canvas.DrawColor = LightGreenColor;
		Canvas.Font = MyFonts.GetSmallestFont(Canvas.ClipX);

		// Draw Time
		Time = Max(1, (Level.TimeSeconds + PlayerOwner.PlayerReplicationInfo.StartTime - PRI.StartTime) / 60);
		Canvas.TextSize(TimeString $ ": 999", XL3, YL3);
		Canvas.SetPos(Canvas.ClipX * 0.75 + XL, YOffset);
		Canvas.DrawText(TimeString $ ":" @ Time, false);

		// Draw FPH
		Canvas.TextSize(FPHString $ ": 999", XL2, YL2);
		Canvas.SetPos(Canvas.ClipX * 0.75 + XL, YOffset + 0.5 * YL);
		Canvas.DrawText(FPHString $ ": " @ int(60 * PRI.Score / Time), false);

		XL3 = FMax(XL3, XL2);
		// Draw Ping
		Canvas.SetPos(Canvas.ClipX * 0.75 + XL + XL3 + 16, YOffset);
		Canvas.DrawText(PingString $ ":" @ PRI.Ping, false);

		// Draw Packetloss
		Canvas.SetPos(Canvas.ClipX * 0.75 + XL + XL3 + 16, YOffset + 0.5 * YL);
		Canvas.DrawText(LossString $ ":" @ PRI.PacketLoss $ "%", false);
	}
}

function DrawObjectivesList(Canvas Canvas) {
	local float XL, YL, YOffset, XOffset;
	local int i;
	local MonsterReplicationInfo mri;
	local MonsterHuntObjective obj;
	local bool wasObjectives;

	if (PlayerPawn(Owner) == None) return;

	mri = MonsterReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);

	if (mri == None) return;

	Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);
	Canvas.StrLen("Test", XL, YL);

	YOffset = Canvas.ClipY - (YL * 6);
	XOffset = Canvas.ClipX * 0.1875; // in line with names list

	for (i = 15; i >= 0; i--) { // rendering bottom-up
		obj = mri.objectives[i];
		if (obj == None) continue;
		if (!obj.bActive && !obj.bAlwaysShown) {
			if (!obj.bCompleted || (obj.bCompleted && !obj.bShowWhenComplete)) continue;
		}

		if (!obj.bActive) {
			Canvas.Style = ERenderStyle.STY_Translucent;
			Canvas.DrawColor = WhiteColor * 0.5;
		} else {
			Canvas.DrawColor = GoldColor;
		}

		Canvas.SetPos(XOffset + YL, YOffset);
		Canvas.DrawText(obj.message, False);

		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.SetPos(XOffset + 4, YOffset + 4);
		if (obj.bCompleted) {
			Canvas.DrawTile(Texture'{{package}}.Hud.ObjComplete', (YL - 8), (YL - 8), 0, 0, 32, 32);
		} else {
			Canvas.DrawTile(Texture'{{package}}.Hud.ObjIncomplete', (YL - 8), (YL - 8), 0, 0, 32, 32);
		}

		Canvas.Style = Style;

		YOffset -= YL;

		wasObjectives = true;
	}

	if (wasObjectives) {
		Canvas.SetPos(XOffset, YOffset);
		Canvas.DrawColor = GreenColor;
		Canvas.DrawText(ObjectivesString, False);
	}
}

defaultproperties
	LightGreenColor=(G=136)
	DarkGreenColor=(G=255, B=128)
	Restart="You have been killed.  Hit [Fire] to continue the hunt!"
	Continue="Hit [Fire] to begin the next hunt!"
	Ended="The hunt has ended."
	PlayerString="Hunter"
	FragsString="Score"
	DeathsString="Lives"
	MonsterDifficultyJoinString="Monsters /"
	ObjectivesString="Objectives"
}
