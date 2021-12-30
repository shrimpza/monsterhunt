//--[[[[----
//=============================================================
// MonsterRules
//=============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2002 Kenneth "Shrimp" Watson
//          For more info, http://shrimpworks.za.net
//    Not to be modified without permission from the author
// ============================================================
// NO LONGER USED =============================================
// ============================================================

class MonsterRules expands UTTeamRCWindow;

// Monster Difficulty
var UWindowComboControl DiffCombo;
var localized string DiffText;
var localized string Diffs[4];
var localized string DiffHelp;

// Friendly Fire Scale
var UWindowHSliderControl FFSlider;
var localized string FFText;
var localized string FFHelp;

function Created()
{
	local int FFS;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;
	
	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ButtonWidth = WinWidth - 140;
	ButtonLeft = WinWidth - ButtonWidth - 40;

	Initialized = False;

	// Monster Difficulty
	DiffCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, 20, ControlWidth, 1));
	DiffCombo.SetText(DiffText);
	DiffCombo.SetHelpText(DiffHelp);
	DiffCombo.SetFont(F_Normal);
	DiffCombo.SetEditable(False);
	DiffCombo.AddItem(Diffs[0]);
	DiffCombo.AddItem(Diffs[1]);
	DiffCombo.AddItem(Diffs[2]);
	DiffCombo.AddItem(Diffs[3]);
	ControlOffset += 25;

	// Friendly Fire Scale
	FFSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	FFSlider.SetRange(0, 10, 1);
	FFS = Class<TeamGamePlus>(BotmatchParent.GameClass).Default.FriendlyFireScale * 10;
	FFSlider.SetValue(FFS);
	FFSlider.SetText(FFText$" ["$FFS*10$"%]:");
	FFSlider.SetHelpText(FFHelp);
	FFSlider.SetFont(F_Normal);

	FragEdit.HideWindow();

	Initialized = True;
}

function SetupNetworkOptions()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	// don't call UTRulesCWindow's version (force respawn)
	Super(UMenuGameRulesBase).SetupNetworkOptions();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	if(BotmatchParent.bNetworkGame)
	{
		BalancePlayersCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
		BalancePlayersCheck.SetText(BalancePlayersText);
		BalancePlayersCheck.SetHelpText(BalancePlayersHelp);
		BalancePlayersCheck.SetFont(F_Normal);
		BalancePlayersCheck.Align = TA_Right;
	}

	if(
		!ClassIsChildOf( BotmatchParent.GameClass, class'CTFGame' ) &&
		!ClassIsChildOf( BotmatchParent.GameClass, class'Assault' )
	)
	{
		MaxTeamsEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlRight, ControlOffset, ControlWidth, 1));

		MaxTeamsEdit.SetText(MaxTeamsText);
		MaxTeamsEdit.SetHelpText(MaxTeamsHelp);
		MaxTeamsEdit.SetFont(F_Normal);
		MaxTeamsEdit.SetNumericOnly(True);
		MaxTeamsEdit.SetMaxLength(3);
		MaxTeamsEdit.Align = TA_Right;
		MaxTeamsEdit.SetDelayedNotify(True);
	}
	ControlOffset += 25;

	if(BotmatchParent.bNetworkGame)
	{
		if(ClassIsChildOf(BotmatchParent.GameClass, class'CTFGame'))
			ControlOffset -= 25;

		ForceRespawnCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
		ForceRespawnCheck.SetText(ForceRespawnText);
		ForceRespawnCheck.SetHelpText(ForceRespawnHelp);
		ForceRespawnCheck.SetFont(F_Normal);
		ForceRespawnCheck.Align = TA_Right;	
		ControlOffset += 25;
	}
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	TeamScoreEdit.SetSize(ControlWidth, 1);
	TeamScoreEdit.WinLeft = ControlLeft;
	TeamScoreEdit.EditBoxWidth = 20;

	if( BalancePlayersCheck != None )
	{
		BalancePlayersCheck.SetSize(ControlWidth, 1);
		BalancePlayersCheck.WinLeft = ControlLeft;
	}

	if(MaxTeamsEdit != None)
	{
		MaxTeamsEdit.SetSize(ControlWidth, 1);
		if( BalancePlayersCheck != None )
			MaxTeamsEdit.WinLeft = ControlRight;
		else
			MaxTeamsEdit.WinLeft = ControlLeft;
		MaxTeamsEdit.EditBoxWidth = 20;
	}

	if(ForceRespawnCheck != None && ClassIsChildOf(BotmatchParent.GameClass, class'CTFGame'))
		ForceRespawnCheck.WinLeft = ControlRight;

	FFSlider.SetSize(CenterWidth, 1);
	FFSlider.SliderWidth = 90;
	FFSlider.WinLeft = CenterPos;
}


function Notify(UWindowDialogControl C, byte E)
{
	if (!Initialized)
		return;

	Super.Notify(C, E);

	switch(E)
	{
	case DE_Change:
		switch (C)
		{
			case DiffCombo:
				DiffChanged();
				break;
			case TeamScoreEdit:
				TeamScoreChanged();
				break;
			case FFSlider:
				FFChanged();
				break;
			case MaxTeamsEdit:
				MaxTeamsChanged();
				break;
			case BalancePlayersCheck:
				BalancePlayersChanged();
				break;
		}
	}
}

function DiffChanged()
{
	switch (DiffCombo.GetSelectedIndex())
	{
		case 0:
			Class'MonsterHunt.MonsterHunt'.Default.Difficulty = 0;
			break;
		case 1:
			Class'MonsterHunt.MonsterHunt'.Default.Difficulty = 1;
			break;
		case 2:
			Class'MonsterHunt.MonsterHunt'.Default.Difficulty = 2;
			break;
		case 3:
			Class'MonsterHunt.MonsterHunt'.Default.Difficulty = 3;
			break;
	}
}

function BalancePlayersChanged()
{
	Class<TeamGamePlus>(BotmatchParent.GameClass).Default.bPlayersBalanceTeams = BalancePlayersCheck.bChecked;
}

singular function MaxTeamsChanged()
{
	if(Int(MaxTeamsEdit.GetValue()) > MaxAllowedTeams)
		MaxTeamsEdit.SetValue(string(MaxAllowedTeams));
	if(Int(MaxTeamsEdit.GetValue()) < 2)
		MaxTeamsEdit.SetValue("2");

	Class<TeamGamePlus>(BotmatchParent.GameClass).Default.MaxTeams = int(MaxTeamsEdit.GetValue());
}

function TeamScoreChanged()
{
	Class<TeamGamePlus>(BotmatchParent.GameClass).Default.GoalTeamScore = int(TeamScoreEdit.GetValue());
}

function FFChanged()
{
	Class<TeamGamePlus>(BotmatchParent.GameClass).Default.FriendlyFireScale = FFSlider.GetValue() / 10;
	FFSlider.SetText(FFText$" ["$int(FFSlider.GetValue()*10)$"%]:");
}

defaultproperties
{
     DiffText="Difficulty:"
     Diffs(0)="Easy"
     Diffs(1)="Medium"
     Diffs(2)="Hard"
     Diffs(3)="Unreal!"
     DiffHelp="Set the difficulty level of the monsters for this game."
}

//--]]]]----
