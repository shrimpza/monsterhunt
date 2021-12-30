// ============================================================
// MonsterCreditsCW
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterCreditsCW extends UTCreditsCW;

#exec TEXTURE IMPORT NAME=MHCreditsBG FILE=Textures\MHCreditsBG.PCX GROUP=Rules LODSET=0

function Paint(Canvas C, float X, float Y) {
	Super.Paint(C, X, Y);
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'MHCreditsBG');
}

defaultproperties {
	ProgrammerNames(0)="Kenneth 'Shrimp' Watson"
	MaxProgs=1
	DesignerNames(0)="Shrimp"
	DesignerNames(1)="Ecstaticus"
	MaxDesigners=2
	ArtText="Testers"
	ArtNames(0)="BikerBob"
	ArtNames(1)="Wipeout"
	ArtNames(2)="DuckMan"
	ArtNames(3)="_Tuke"
	MaxArts=4
	MusicSoundText="Special Thanks"
	MusicNames(0)="Valkyrie"
	MusicNames(1)="Beppo"
	MusicNames(2)="Albert Reed"
	MusicNames(3)="UsAaR33"
	MusicNames(4)=" "
	MusicNames(5)="All at UnrealZA"
	MusicNames(6)=" "
	MusicNames(7)="And most of all"
	MusicNames(8)="EPIC GAMES"
	MaxMusics=9
	BizText="Contact info"
	BizNames(0)="A ShrimpWorks production"
	BizNames(1)=" "
	BizNames(3)="Web - https://shrimpworks.za.net/"
	MaxBiz=4
}
