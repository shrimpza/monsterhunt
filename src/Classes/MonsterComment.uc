//--[[[[----
// ============================================================
// MonsterComment
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2002 Kenneth "Shrimp" Watson
//          For more info, http://shrimpworks.za.net
//    Not to be modified without permission from the author
// ============================================================

// Place comments in maps for easy reference when editing

class MonsterComment expands Actor;

#exec Texture Import File=textures\MHComment.pcx Name=MHComment Mips=Off Flags=2

var() string Comment1, Comment2, Comment3, Comment4, Comment5;

defaultproperties
{
     bHidden=True
     Texture=Texture'MonsterHunt.MHComment'
     DrawScale=2.000000
}

//--]]]]----
