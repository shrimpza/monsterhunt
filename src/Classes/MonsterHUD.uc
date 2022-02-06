//=============================================================
// MonsterHUD.
//=============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterHUD extends ChallengeTeamHUD;

#exec TEXTURE IMPORT NAME=HudIcon FILE=Textures\HUDIcon.PCX GROUP=Hud MIPS=OFF LODSET=0
#exec TEXTURE IMPORT NAME=BlackStuff FILE=Textures\BlackStuff.PCX GROUP=Hud MIPS=OFF LODSET=0
#exec TEXTURE IMPORT NAME=BlackStuff2 FILE=Textures\BlackStuff2.PCX GROUP=Hud MIPS=OFF LODSET=0
#exec TEXTURE IMPORT NAME=ObjComplete FILE=Textures\ObjComplete.pcx GROUP=Hud MIPS=OFF LODSET=0
#exec TEXTURE IMPORT NAME=ObjIncomplete FILE=Textures\ObjIncomplete.pcx GROUP=Hud MIPS=OFF LODSET=0

var localized string TimeRemainingLabel;
var localized string LivesRemainLabel;
var localized string EscapedMonstersLabel;
var localized string HuntersRemainLabel;
var localized string MonstersRemainLabel;

simulated function PostBeginPlay() {
	Super.PostBeginPlay();

	bUseTeamColor = MonsterReplicationInfo(PlayerPawn(Owner).GameReplicationInfo).bUseTeamSkins;
}

simulated function DrawGameSynopsis(Canvas Canvas) {
	local float XL, YL, YOffset, XOffset;
	local string escapesString;
	local MonsterReplicationInfo mri;
	local int Minutes, Seconds, i;
	local MonsterHuntObjective obj;

	XOffset = 10;

	if ((PawnOwner.PlayerReplicationInfo == None) || PawnOwner.PlayerReplicationInfo.bIsSpectator) return;

	mri = MonsterReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);

	Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);
	Canvas.DrawColor = WhiteColor;

	Canvas.StrLen(RankString, XL, YL);
	if (bHideAllWeapons) {
		YOffset = Canvas.ClipY - YL;
	} else if (HudScale * WeaponScale * Canvas.ClipX <= Canvas.ClipX - 256 * Scale) {
		YOffset = Canvas.ClipY - 64 * Scale - YL;
	} else {
		YOffset = Canvas.ClipY - 128 * Scale - YL;
	}

	if (mri != None) {
		Canvas.SetPos(XOffset, YOffset);
		Canvas.DrawText(MonstersRemainLabel $ ": " $ string(mri.Monsters), False);
		YOffset -= YL;

		Canvas.SetPos(XOffset, YOffset);
		Canvas.DrawText(HuntersRemainLabel $ ": " $ string(mri.Hunters), False);
		YOffset -= YL;

		if (Level.Game.IsA('MonsterHuntDefence')) {
			Canvas.SetPos(XOffset, YOffset);
			escapesString = EscapedMonstersLabel $ ": " $ string(mri.Escapees);
			if (mri.MaxEscapees > 0) {
				escapesString = escapesString $ "/" $ string(mri.MaxEscapees);
				if (mri.MaxEscapees - mri.Escapees < 5) Canvas.DrawColor = RedColor;
			} else {
				Canvas.DrawColor = WhiteColor;
			}
			Canvas.DrawText(escapesString, False);
			YOffset -= YL;
		}

		if (mri.bUseLives) {
		  if (PawnOwner.PlayerReplicationInfo.Deaths < 3) Canvas.DrawColor = RedColor;
		  else Canvas.DrawColor = WhiteColor;
			Canvas.SetPos(XOffset, YOffset);
			Canvas.DrawText(LivesRemainLabel $ ": " $ int(PawnOwner.PlayerReplicationInfo.Deaths), False);
			YOffset -= YL;
		}

		if (mri.RemainingTime > 0) {
			if (mri.RemainingTime < 30) Canvas.DrawColor = RedColor;
			else Canvas.DrawColor = WhiteColor;
			Canvas.SetPos(XOffset, YOffset);
			Minutes = mri.RemainingTime / 60;
			Seconds = mri.RemainingTime % 60;
			Canvas.DrawText(TimeRemainingLabel $ ": " $ TwoDigitString(Minutes) $ ":" $ TwoDigitString(Seconds), true);
			YOffset -= YL;
		}

		if (MonsterHunt(Level.Game) != None) {
			Canvas.StrLen(RankString, XL, YL);
			for (i = 15; i >= 0; i--) { // backwards, since we're rendering hud elements from bottom up
				obj = MonsterHunt(Level.Game).objectives[i];
				if (obj != None) {
					if (!obj.bActive && !obj.bAlwaysShown) {
					if (!obj.bCompleted || (obj.bCompleted && !obj.bShowWhenComplete))	continue;
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
						Canvas.DrawTile(Texture'{{package}}.Hud.ObjComplete', (YL - 8) * Scale, (YL - 8) * Scale, 0, 0, 32, 32);
					} else {
						Canvas.DrawTile(Texture'{{package}}.Hud.ObjIncomplete', (YL - 8) * Scale, (YL - 8) * Scale, 0, 0, 32, 32);
					}

					Canvas.Style = Style;

					YOffset -= YL;
				}
			}
		}
	}
}

function string TwoDigitString(int Num) {
	if (Num < 10) return "0" $ Num;
	else return string(Num);
}

simulated function DrawStatus(Canvas Canvas) {
	local float X, Y;

	Super.DrawStatus(Canvas);

	Canvas.DrawColor = HUDColor;
	if (bHideStatus && bHideAllWeapons) {
		X = 0.5 * Canvas.ClipX - 128 * Scale;
		Y = Canvas.ClipY - 64 * Scale;
	} else {
		X = Canvas.ClipX - 128 * Scale * StatusScale - 140 * Scale;
		Y = 128 * Scale;
	}

	Canvas.SetPos(X, Y);
	Canvas.DrawTile(Texture'{{package}}.Hud.HudIcon', 128 * Scale, 64 * Scale, 0, 192, 128.0, 64.0);
}

simulated function Message(PlayerReplicationInfo PRI, coerce string Msg, name MsgType) {
	local int i;
	local Class<LocalMessage> MessageClass;

	switch (MsgType) {
		case 'Say':
			MessageClass = class'SayMessagePlus';
			break;
		case 'TeamSay':
			MessageClass = class'TeamSayMessagePlus';
			break;
		case 'CriticalEvent':
			MessageClass = class'CriticalStringPlus';
			LocalizedMessage(MessageClass, 0, None, None, None, Msg);
			return;

		case 'MonsterCriticalEvent':
			MessageClass = class'MonsterCriticalString';
			LocalizedMessage(MessageClass, 0, None, None, None, Msg);
			return;

		case 'DeathMessage':
			MessageClass = class'RedSayMessagePlus';
			break;
		case 'Pickup':
			PickupTime = Level.TimeSeconds;
		default:
			MessageClass = class'StringMessagePlus';
			break;
	}

	if (ClassIsChildOf(MessageClass, class'SayMessagePlus') || ClassIsChildOf(MessageClass, class'TeamSayMessagePlus')) {
		if (Msg == "") return;
		FaceTexture = PRI.TalkTexture;
		FaceTeam = TeamColor[PRI.Team];
		if (FaceTexture != None) FaceTime = Level.TimeSeconds + 3;
	}

	for (i = 0; i < 4; i++) {
		if (ShortMessageQueue[i].Message == None) {
			// Add the message here.
			ShortMessageQueue[i].Message = MessageClass;
			ShortMessageQueue[i].Switch = 0;
			ShortMessageQueue[i].RelatedPRI = PRI;
			ShortMessageQueue[i].OptionalObject = None;
			ShortMessageQueue[i].EndOfLife = MessageClass.Default.Lifetime + Level.TimeSeconds;
			if (MessageClass.Default.bComplexString) ShortMessageQueue[i].StringMessage = Msg;
			else ShortMessageQueue[i].StringMessage = MessageClass.Static.AssembleString(self, 0, PRI, Msg);
			return;
		}
	}

	// No empty slots.  Force a message out.
	for (i = 0; i < 3; i++) CopyMessage(ShortMessageQueue[i], ShortMessageQueue[i + 1]);

	ShortMessageQueue[3].Message = MessageClass;
	ShortMessageQueue[3].Switch = 0;
	ShortMessageQueue[3].RelatedPRI = PRI;
	ShortMessageQueue[3].OptionalObject = None;
	ShortMessageQueue[3].EndOfLife = MessageClass.Default.Lifetime + Level.TimeSeconds;
	if (MessageClass.Default.bComplexString) ShortMessageQueue[3].StringMessage = Msg;
	else ShortMessageQueue[3].StringMessage = MessageClass.Static.AssembleString(self, 0, PRI, Msg);
}

simulated function DrawBlackStuff(canvas Canvas) {
	Canvas.DrawColor = WhiteColor;
	Canvas.Style = ERenderStyle.STY_Modulated;

	Canvas.SetPos(0, 0);
	Canvas.DrawTile(Texture'{{package}}.Hud.BlackStuff', Canvas.ClipX, 160 * Scale, 0, 0, 16, 64);
	Canvas.SetPos(0, Canvas.ClipY - (160 * Scale));
	Canvas.DrawTile(Texture'{{package}}.Hud.BlackStuff2', Canvas.ClipX, 160 * Scale, 0, 0, 16, 64);

	Canvas.Style = ERenderStyle.STY_Translucent;
}

simulated function PostRender(canvas Canvas) {
	HUDSetup(canvas);
	if ((PawnOwner == None) || (PlayerOwner.PlayerReplicationInfo == None)) return;

	if (MonsterReplicationInfo(PlayerPawn(Owner).GameReplicationInfo).bUseLives
			&& (PawnOwner.PlayerReplicationInfo.Deaths < 1) && !PawnOwner.IsA('Spectator')) {
		DrawBlackStuff(Canvas);
	}

	super.PostRender(Canvas);
}

defaultproperties {
	TimeRemainingLabel="Time Remaining"
	LivesRemainLabel="Lives"
	EscapedMonstersLabel="Escaped Monsters"
	HuntersRemainLabel="Hunters"
	MonstersRemainLabel="Monsters"
}
