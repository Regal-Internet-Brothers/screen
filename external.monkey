Strict

Public

' Imports (Monkey):
Import screen ' regal.screen

' Imports (Native):
#If SCREEN_SUPPORTED
	Import "native/desktopWindow.${TARGET}.${LANG}"
#End

' Constant variable(s):
#If SCREEN_GLFW2_TARGET
	Const SCREEN_GL_TRUE:Int = 1
	Const SCREEN_GL_FALSE:Int = 0
	
	Const SCREEN_GLFW_FSAA_SAMPLES:Int = $00020013
#End

' External bindings:
Extern

' Functions:
#If SCREEN_GLFW2_TARGET
	Function SetWindowDestination:Void(X:Int, Y:Int)="desktopWindow::setDestination"
	
	Function MoveWindow:Void(X:Int, Y:Int)="desktopWindow::move"
	Function MoveWindow_ToCenter:Void()="desktopWindow::toCenter"
	Function MoveWindow_ToDestination:Void(CurrentX:Int=NOVAR, CurrentY:Int=NOVAR, DestX:Int=NOVAR, DestY:Int=NOVAR, WindowCreated:Bool=True)="desktopWindow::toDestination"
	Function MoveWindow_SetResolution:Void(Width:Int, Height:Int)="currentWindow.setResolution"	
		
	Function GlfwOpenWindowHint:Void(Target:Int, Hint:Int)="glfwOpenWindowHint"	
#End

#If TARGET = "xna"
	Function XNA_ToggleAA:Void(Value:Bool)="desktopWindow.toggleAA"
	
	#APPTITLE_IMPLEMENTED = True
#End

#If CONFINE_CURSOR_IMPLEMENTED
	#If LANG = "cpp"
		' Global variable(s):
		Global ConfineCursorState:Bool="desktopWindow::confineCursor_state"
		
		' Functions:
		Function BeginConfineCursor:Void()="desktopWindow::confineCursor_begin"
		Function EndConfineCursor:Void()="desktopWindow::confineCursor_end"
		
		Function ConfineCursor_ToggleScreenOnly:Void()="desktopWindow::confineCursor_toggleScreenOnly"
		Function ConfineCursor_ScreenOnly:Void(Value:Bool)="desktopWindow::confineCursor_toggleScreenOnly"
	#Else
		' Global variable(s):
		Global ConfineCursorState:Bool="desktopWindow.confineCursor_state"
		
		' Functions:
		Function BeginConfineCursor:Void()="desktopWindow.confineCursor_begin"
		Function EndConfineCursor:Void()="desktopWindow.confineCursor_end"
		
		Function ConfineCursor_ToggleScreenOnly:Void()="desktopWindow.confineCursor_toggleScreenOnly"
		Function ConfineCursor_ScreenOnly:Void(Value:Bool)="desktopWindow.confineCursor_toggleScreenOnly"
	#End
#End

#If TOGGLE_CURSOR_IMPLEMENTED
	' Functions:
	#If LANG = "cpp"
		Function ToggleCursor:Int(Show:Bool)="desktopWindow::toggleCursor"
		Function UpdateSmartCursorToggle:Void()="desktopWindow::updateSmartCursorToggle"
	#Else
		Function ToggleCursor:Int(Show:Bool)="desktopWindow.toggleCursor"
		Function UpdateSmartCursorToggle:Void()="desktopWindow.updateSmartCursorToggle"
	#End
#End

#If APPTITLE_IMPLEMENTED
	#If LANG = "cpp"
		Function AppTitle:Void(Title:String)="desktopWindow::appTitle"
		Function AppTitle:String()="desktopWindow::appTitle"
	#Else
		Function AppTitle:Void(Title:String)="desktopWindow.appTitle"
		Function AppTitle:String()="desktopWindow.appTitle"
	#End
#End

Public