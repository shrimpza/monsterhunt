// ============================================================
// MonsterBotConfig
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterBotConfig extends UTBotConfigClient
	config(MonsterHunt);

#exec TEXTURE IMPORT NAME=MHBotsBG FILE=Textures\MHBotsBG.png GROUP=Rules LODSET=0

function Created() {
	Super.Created();
	BalanceTeamsCheck.HideWindow();	
}

function Paint(Canvas C, float X, float Y) {
	Super.Paint(C, X, Y);
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'MHBotsBG');
}

function NumBotsChanged() {
	if (int(NumBotsEdit.GetValue()) > 32) NumBotsEdit.SetValue("32");

	if (BotmatchParent.bNetworkGame) class<MonsterHunt>(BotmatchParent.GameClass).default.MinPlayers = int(NumBotsEdit.GetValue());
	else class<MonsterHunt>(BotmatchParent.GameClass).default.InitialBots = int(NumBotsEdit.GetValue());
	BotmatchParent.GameClass.static.StaticSaveConfig();
}

function LoadCurrentValues() {
	Super.LoadCurrentValues();
	if (BotmatchParent.bNetworkGame) NumBotsEdit.SetValue(string(class'MonsterHunt'.Default.MinPlayers));
	else NumBotsEdit.SetValue(string(class'MonsterHunt'.Default.InitialBots));
}

function BaseChanged() {
	Super.BaseChanged();
	class<MonsterHunt>(BotmatchParent.GameClass).Default.MonsterSkill = BaseCombo.GetSelectedIndex();
	class<MonsterHunt>(BotmatchParent.GameClass).static.StaticSaveConfig();
}

defaultproperties {
	MinPlayersText="Min. Total Hunters"
	BaseText="AI Hunter Skill:"
	SkillTaunts(0)="They might know how to kill a Fly."
	SkillTaunts(2)="Look out monsters!"
	SkillTaunts(3)="Monsters are in for a good beating."
	SkillTaunts(4)="I wouldn't like to be in the monsters shoes..."
	SkillTaunts(5)="It's a pity the monsters can't respawn."
	SkillTaunts(6)="Those poor monsters are already dead."
	SkillTaunts(7)="Rest in peace, monsters..."
}
