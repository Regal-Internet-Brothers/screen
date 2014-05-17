
// Well, here it is, it isn't anything special:
public static class desktopWindow
{
	// Functions:
	public static void toggleAA(bool value)
	{
		//BBXnaGame.XnaGame()._devman.RenderState.MultiSampleAntiAlias = value;
		
		return;
	}
	
	public static void appTitle(String s)
	{
		BBXnaGame.XnaGame().GetXNAGame().Window.Title = s;
		
		return;
	}
	
	public static string appTitle()
	{
		return BBXnaGame.XnaGame().GetXNAGame().Window.Title;
	}
};