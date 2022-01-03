// ============================================================
// MonsterHuntRules
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterHuntDefenceRules extends MonsterHuntRules
	config(MonsterHunt);

// Max Escapees
var UWindowEditControl EscapeesEdit;
var localized string EscapeesText;
var localized string EscapeesHelp;

// Warmup Time
var UWindowEditControl WarmupEdit;
var localized string WarmupText;
var localized string WarmupHelp;

function Created() {
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	Super.Created();

	ControlWidth = WinWidth / 2.5;
	ControlLeft = (WinWidth / 2 - ControlWidth) / 2;
	ControlRight = WinWidth / 2 + ControlLeft;

	CenterWidth = (WinWidth / 4) * 3;
	CenterPos = (WinWidth - CenterWidth) / 2;

	// Max Escapees
	EscapeesEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
	EscapeesEdit.SetText(EscapeesText);
	EscapeesEdit.SetHelpText(EscapeesHelp);
	EscapeesEdit.SetFont(F_Normal);
	EscapeesEdit.SetNumericOnly(True);
	EscapeesEdit.SetMaxLength(3);
	EscapeesEdit.Align = TA_Right;

	// Warmup Time
	WarmupEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlRight, ControlOffset, ControlWidth, 1));
	WarmupEdit.SetText(WarmupText);
	WarmupEdit.SetHelpText(WarmupHelp);
	WarmupEdit.SetFont(F_Normal);
	WarmupEdit.SetNumericOnly(True);
	WarmupEdit.SetMaxLength(3);
	WarmupEdit.Align = TA_Right;
	ControlOffset += 25;
}

function BeforePaint(Canvas C, float X, float Y) {
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth / 2.5;
	ControlLeft = (WinWidth / 2 - ControlWidth) / 2;
	ControlRight = WinWidth / 2 + ControlLeft;

	CenterWidth = (WinWidth / 4) * 3;
	CenterPos = (WinWidth - CenterWidth) / 2;

	EscapeesEdit.SetSize(ControlWidth, 1);
	EscapeesEdit.WinLeft = ControlLeft;
	EscapeesEdit.EditBoxWidth = 25;

	WarmupEdit.SetSize(ControlWidth, 1);
	WarmupEdit.WinLeft = ControlRight;
	WarmupEdit.EditBoxWidth = 25;
}

function Notify(UWindowDialogControl C, byte E) {
	if (!Initialized) return;

	Super.Notify(C, E);

	switch(E) {
		case DE_Change:
			switch(C) {
				case EscapeesEdit:
					EscapeesChanged();
					break;
				case WarmupEdit:
					WarmupChanged();
					break;
			}
	}
}

function LoadCurrentValues() {
	Super.LoadCurrentValues();

	if (EscapeesEdit != None) {
		EscapeesEdit.SetValue(string(Class<MonsterHuntDefence>(BotmatchParent.GameClass).Default.MaxEscapees));
	}
	if (WarmupEdit != None) {
		WarmupEdit.SetValue(string(Class<MonsterHuntDefence>(BotmatchParent.GameClass).Default.WarmupTime));
	}
}

function EscapeesChanged() {
	Class<MonsterHuntDefence>(BotmatchParent.GameClass).Default.MaxEscapees = int(EscapeesEdit.GetValue());
}

function WarmupChanged() {
	Class<MonsterHuntDefence>(BotmatchParent.GameClass).Default.WarmupTime = int(WarmupEdit.GetValue());
}

defaultproperties {
	EscapeesEdit=None
	EscapeesText="Max Escapees"
	EscapeesHelp="The maximum number of Monsters which are allowed to escape, before the round is lost."
	WarmupEdit=None
	WarmupText="Warmup Time"
	WarmupHelp="Number of seconds to wait before monsters start attacking."
}
