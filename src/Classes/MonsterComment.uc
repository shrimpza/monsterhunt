// ============================================================
// MonsterComment
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

// Place comments in maps for easy reference when editing

class MonsterComment expands Actor;

#exec Texture Import File=textures\MHComment.pcx Name=MHComment Mips=Off Flags=2

var() string Comment1, Comment2, Comment3, Comment4, Comment5;

defaultproperties {
     bHidden=True
     Texture=Texture'MonsterHunt.MHComment'
     DrawScale=2.000000
}
