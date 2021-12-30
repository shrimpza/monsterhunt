//--[[[[----
// ============================================================
// MonsterMenuItem
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2002 Kenneth "Shrimp" Watson
//          For more info, http://shrimpworks.za.net
//    Not to be modified without permission from the author
// ============================================================

class MonsterMenuItem expands UMenuModMenuItem;

function Execute()
{
	MenuItem.Owner.Root.CreateWindow(class'MonsterHunt.MonsterCreditsWindow', 100, 100, 100, 100);
}

defaultproperties
{
     MenuCaption="&Monster Hunt Credits"
     MenuHelp="All the people behind Monster Hunt!"
}

//--]]]]----
