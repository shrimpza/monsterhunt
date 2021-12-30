// ============================================================
// MonsterSettings
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterSettings extends UTSettingsCWindow
	config(MonsterHunt);

#exec TEXTURE IMPORT NAME=MHSettingsBG FILE=Textures\MHSettingsBG.PCX GROUP=Rules LODSET=0

function Created() {
	Super.Created();
	TranslocCheck.HideWindow();	
}

function Paint(Canvas C, float X, float Y) {
	Super.Paint(C, X, Y);
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'MHSettingsBG');
}

defaultproperties {
}
