// ============================================================
// MonsterMenuItem
// ============================================================
//       		=== Monster Hunt ===
//
//       Copyright 2000 - 2022 Kenneth "Shrimp" Watson
//          For more info, https://shrimpworks.za.net
// ============================================================

class MonsterMenuItem expands UMenuModMenuItem;

function Execute() {
	MenuItem.Owner.Root.CreateWindow(class'{{package}}.MonsterCreditsWindow', 100, 100, 100, 100);
}

defaultproperties {
     MenuCaption="&Monster Hunt Credits"
     MenuHelp="All the people behind Monster Hunt!"
}
