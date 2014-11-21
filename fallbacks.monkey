Strict

Public

' Imports (Internal):
Import external

' Imports (External):
#If Not TOGGLE_CURSOR_IMPLEMENTED
	#If BRL_GAMETARGET_IMPLEMENTED
		Import mojo.app
		
		#TOGGLE_CURSOR_FALLBACK_IMPLEMENTED = True
		#TOGGLE_CURSOR_AVAILABLE = True
	#End
#End

' Classes:
' Nothing so far.

' Functions:
#If Not APPTITLE_IMPLEMENTED
	Function AppTitle:String()
		Return ""
	End
	
	Function AppTitle:Void(Input:String)
		Return
	End
#End

#If Not CONFINE_CURSOR_IMPLEMENTED
	' Global variable(s):
	Global ConfineCursorState:Bool = False
	
	' Functions:
	Function BeginConfineCursor:Void()
		Return
	End
	
	Function EndConfineCursor:Void()
		Return
	End
#End

#If TOGGLE_CURSOR_FALLBACK_IMPLEMENTED
	' Functions:
	Function ToggleCursor:Int(Toggle:Bool)
		#If TOGGLE_CURSOR_FALLBACK_IMPLEMENTED
			If (Toggle) Then
				ShowMouse()
			Else
				HideMouse()
			Endif
		#End
		
		' Always return zero.
		Return 0
	End
	
	Function UpdateSmartCursorToggle:Void()
		Return
	End
#End