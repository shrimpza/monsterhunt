// ============================================================
// MonsterHuntRules
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterHuntRules expands UTRulesCWindow
	config(MonsterHunt);

#exec TEXTURE IMPORT NAME=MHRulesBG FILE=Textures\MHRulesBG.PCX GROUP=Rules LODSET=0

function Created() {
	Super.Created();

	ForceRespawnCheck.HideWindow();
}

function LoadCurrentValues() {
	Super.LoadCurrentValues();
	TimeEdit.SetValue(string(Class<MonsterHunt>(BotmatchParent.GameClass).Default.TimeLimit));

	if (MaxPlayersEdit != None)
		MaxPlayersEdit.SetValue(string(Class<MonsterHunt>(BotmatchParent.GameClass).Default.MaxPlayers));

	if (MaxSpectatorsEdit != None)
		MaxSpectatorsEdit.SetValue(string(Class<MonsterHunt>(BotmatchParent.GameClass).Default.MaxSpectators));

	if (BotmatchParent.bNetworkGame)
		WeaponsCheck.bChecked = Class<MonsterHunt>(BotmatchParent.GameClass).Default.bMultiWeaponStay;
	else
		WeaponsCheck.bChecked = Class<MonsterHunt>(BotmatchParent.GameClass).Default.bCoopWeaponMode;

	FragEdit.SetValue(string(Class<MonsterHunt>(BotmatchParent.GameClass).Default.Lives));
	TourneyCheck.bChecked = Class<MonsterHunt>(BotmatchParent.GameClass).Default.bUseTeamSkins;
}

function Paint(Canvas C, float X, float Y) {
	Super.Paint(C, X, Y);

	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'MHRulesBG');
}

function FragChanged() {
	Class<MonsterHunt>(BotmatchParent.GameClass).Default.Lives = int(FragEdit.GetValue());
}

function TourneyChanged() {
	Class<MonsterHunt>(BotmatchParent.GameClass).Default.bUseTeamSkins = TourneyCheck.bChecked;
}

function TimeChanged() {
	Class<MonsterHunt>(BotmatchParent.GameClass).Default.TimeLimit = int(TimeEdit.GetValue());
}

function WeaponsChecked() {
	if (BotmatchParent.bNetworkGame)
		Class<MonsterHunt>(BotmatchParent.GameClass).Default.bMultiWeaponStay = WeaponsCheck.bChecked;
	else
		Class<MonsterHunt>(BotmatchParent.GameClass).Default.bCoopWeaponMode = WeaponsCheck.bChecked;
}

defaultproperties {
     TourneyText="Force team colours"
     TourneyHelp="if enabled, players will use red team skins and HUD, otherwise they will use their own skin and HUD settings."
     FragText="Lives"
     FragHelp="Set the number of lives each hunter starts with for each round. Set it to 0 for no limit."
}
