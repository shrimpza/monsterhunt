// ============================================================
// MonsterHuntRules
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterHuntRules extends UTRulesCWindow
	config(MonsterHunt);

#exec TEXTURE IMPORT NAME=MHRulesBG FILE=Textures\MHRulesBG.png GROUP=Rules LODSET=0

// Monster Difficulty
var UWindowComboControl DifficultyCombo;
var localized string DifficultyText;
var localized string DifficultyHelp;

// Taunt Label
var UMenuLabelControl TauntLabel;
var localized string Skills[4];
var localized string SkillTaunts[4];

function Created() {
	local int i;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	ControlWidth = WinWidth / 2.5;
	ControlLeft = (WinWidth / 2 - ControlWidth) / 2;
	ControlRight = WinWidth / 2 + ControlLeft;

	CenterWidth = (WinWidth / 4) * 3;
	CenterPos = (WinWidth - CenterWidth) / 2;

	// Difficulty Skill
	DifficultyCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	DifficultyCombo.SetText(DifficultyText);
	DifficultyCombo.SetHelpText(DifficultyHelp);
	DifficultyCombo.SetFont(F_Normal);
	DifficultyCombo.SetEditable(False);
	for (i = 0; i < 4; i++) if (Skills[i] != "") DifficultyCombo.AddItem(Skills[i]);
	ControlOffset += 25;

	// Taunt Label
	TauntLabel = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	TauntLabel.Align = TA_Center;
	ControlOffset += 25;

	Super.Created();

	ForceRespawnCheck.HideWindow();
}


function BeforePaint(Canvas C, float X, float Y) {
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth / 2.5;
	ControlLeft = (WinWidth / 2 - ControlWidth) / 2;
	ControlRight = WinWidth / 2 + ControlLeft;

	CenterWidth = (WinWidth / 4) * 3;
	CenterPos = (WinWidth - CenterWidth) / 2;

	DifficultyCombo.SetSize(CenterWidth, 1);
	DifficultyCombo.WinLeft = CenterPos;
	DifficultyCombo.EditBoxWidth = 120;

	TauntLabel.SetSize(CenterWidth, 1);
	TauntLabel.WinLeft = CenterPos;
}

function Notify(UWindowDialogControl C, byte E) {
	if (!Initialized) return;

	Super.Notify(C, E);

	switch(E) {
		case DE_Change:
			switch(C) {
				case DifficultyCombo:
					DifficultyChanged();
					break;
			}
	}
}

function LoadCurrentValues() {
	local int skill, difficulty;

	Super.LoadCurrentValues();
	TimeEdit.SetValue(string(Class<MonsterHunt>(BotmatchParent.GameClass).Default.TimeLimit));

	if (MaxPlayersEdit != None){
		MaxPlayersEdit.SetValue(string(Class<MonsterHunt>(BotmatchParent.GameClass).Default.MaxPlayers));
	}

	if (MaxSpectatorsEdit != None){
		MaxSpectatorsEdit.SetValue(string(Class<MonsterHunt>(BotmatchParent.GameClass).Default.MaxSpectators));
	}

	if (BotmatchParent.bNetworkGame) {
		WeaponsCheck.bChecked = Class<MonsterHunt>(BotmatchParent.GameClass).Default.bMultiWeaponStay;
	} else {
		WeaponsCheck.bChecked = Class<MonsterHunt>(BotmatchParent.GameClass).Default.bCoopWeaponMode;
	}

	FragEdit.SetValue(string(Class<MonsterHunt>(BotmatchParent.GameClass).Default.Lives));
	TourneyCheck.bChecked = Class<MonsterHunt>(BotmatchParent.GameClass).Default.bUseTeamSkins;

	// translate difficulty on scale of 8 (based on bot skill) to 4 (based on Unreal skills)
	skill = class<MonsterHunt>(BotmatchParent.GameClass).Default.MonsterSkill;
	if (skill <= 1) difficulty = 0;
	else if (skill <= 3) difficulty = 1;
	else if (skill <= 5) difficulty = 2;
	else if (skill <= 7) difficulty = 3;
	else difficulty = 2;

	DifficultyCombo.SetSelectedIndex(Min(difficulty, 7));
	TauntLabel.SetText(SkillTaunts[DifficultyCombo.GetSelectedIndex()]);
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

function DifficultyChanged() {
	local int skill;

	TauntLabel.SetText(SkillTaunts[DifficultyCombo.GetSelectedIndex()]);

	// translate difficulty on scale of 4 to a skill level of 8
	switch (DifficultyCombo.GetSelectedIndex()) {
		case 0:
			skill = 1;
			break;
		case 1:
			skill = 3;
			break;
		case 2:
			skill = 5;
			break;
		case 3:
			skill = 7;
			break;
		default:
			skill = 2;
	}

	class<MonsterHunt>(BotmatchParent.GameClass).Default.MonsterSkill = skill;
	class<MonsterHunt>(BotmatchParent.GameClass).static.StaticSaveConfig();
}

defaultproperties {
	TourneyText="Force team colours"
	TourneyHelp="if enabled, players will use red team skins and HUD, otherwise they will use their own skin and HUD settings."
	FragText="Lives"
	FragHelp="Set the number of lives each hunter starts with for each round. Set it to 0 for no limit."

	DifficultyCombo=None
	DifficultyText="Monster Difficulty:"
	DifficultyHelp="This is the Difficulty skill level of the bots."
	TauntLabel=None
	Skills(0)="Easy"
	Skills(1)="Medium"
	Skills(2)="Hard"
	Skills(3)="Unreal"
	SkillTaunts(0)="Tourist mode."
	SkillTaunts(1)="Ready for some action!"
	SkillTaunts(2)="Not for the faint of heart."
	SkillTaunts(3)="Death wish."
}
