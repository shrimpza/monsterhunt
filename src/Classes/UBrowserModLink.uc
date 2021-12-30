//--[[[[----
class UBrowserModLink extends UBrowserGSpyLink;

var string GameType;

// States
state FoundSecretState 
{
	function Tick(float Delta)
	{
		Global.Tick(Delta);

		// Hack for 0 servers in server list
		if(!IsConnected() && WaitResult == "\\final\\")
		{
			OwnerFactory.QueryFinished(True);
			GotoState('Done');
		}
	}

Begin:
	Enable('Tick');
	SendBufferedData("\\list\\\\gamename\\"$GameName$"\\gametype\\"$GameType$"\\final\\");
	WaitFor("ip\\", 30, NextIP);
}

defaultproperties
{
}

//--]]]]----
