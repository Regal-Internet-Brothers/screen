Strict

Public

' Only bother if we have a game-target implementation:
#If BRL_GAMETARGET_IMPLEMENTED

' Preprocessor related:
#If (TARGET = "glfw" Or TARGET = "sexy") And (Not GLFW_VERSION Or GLFW_VERSION = 2)
	#SCREEN_GLFW2_TARGET = True
#End

#If SCREEN_GLFW2_TARGET
	#DESKTOP_WINDOW_TRANSITION = True
#End

#If SCREEN_GLFW2_TARGET Or TARGET = "xna"
	#SCREEN_SUPPORTED = True
#End

#If SCREEN_GLFW2_TARGET Or TARGET = "xna"
	#APPTITLE_IMPLEMENTED = True
#End

#If SCREEN_GLFW2_TARGET And HOST = "winnt"
	#CONFINE_CURSOR_IMPLEMENTED = True
	#TOGGLE_CURSOR_AVAILABLE = True
#End

' Imports (Public):

' Preprocessor:
Import regal.preprocessor.defaults
Import regal.preprocessor.flags

' General:
Import regal.util
Import regal.vector
Import regal.ioelement

' BRL:
Import brl.stream

' Imports (Private):
Private

Import mojo.app

Public

' Preprocessor related:
#If SCREEN_GLFW2_TARGET And HOST = "winnt"
	#TOGGLE_CURSOR_IMPLEMENTED = True
#End

' Internal:
Import external
Import fallbacks

' Global variable(s):
'#If FLAG_DESKTOP
' If we're compiling for a desktop target, setup a "Last window screen-mode".
Global CurrentWindowMode:DesktopScreenMode = Null
'#End

' Check if there was already a window created:
#If TARGET <> "xna" And ((DEFAULT_DESKTOP_WINDOW_W > 0 And DEFAULT_DESKTOP_WINDOW_H > 0) Or (SCREEN_GLFW2_TARGET And GLFW_WINDOW_WIDTH > 0 And GLFW_WINDOW_WIDTH > 0))
	Global WindowCreated:Bool = True
#Else
	Global WindowCreated:Bool = False
#End

' Classes:
Class DesktopScreenMode Implements SerializableElement
	' Constant variable(s):
	
	' General:
	
	' Flags (Only useful when using the standard Mojo backend):
	Const FLAG_FULLSCREEN:Int = 1
	Const FLAG_RESIZABLE:Int = 2
	Const FLAG_DECORATED:Int = 4
	Const FLAG_FLOATING:Int = 8
	Const FLAG_DEPTH_BUFFERED:Int = 16
	Const FLAG_SINGLE_BUFFERED:Int = 32
	Const FLAG_SECOND_MONITOR:Int = 64
	
	' Color related:
	Const COLOR_ARRAY_LENGTH:Int = 6
	
	Const COLOR_RPOS:Int			= 0
	Const COLOR_GPOS:Int			= 1
	Const COLOR_BPOS:Int			= 2
	Const COLOR_APOS:Int			= 3
	Const COLOR_DEPTHPOS:Int		= 4
	Const COLOR_STENCILPOS:Int		= 5
	
	' I/O related:
	Const ZERO:Int = 0
	
	Const IOVersion:Int = 3
	
	Const IOVERSION_EXT_NATIVE_FLAGS:Int = 3
	
	' Global variable(s):
	' Nothing so far.
	
	' Constant variable(s):
	#If DEFAULT_DESKTOP_FULLSCREEN
		Const Default_Fullscreen:Bool = True
	#Else
		Const Default_Fullscreen:Bool = False
	#End
	
	Const Default_Transition:Bool = False
	
	Const Default_AASamples:Int = 0
	Const Default_Framerate:Int = 60
	
	' Constructor(s) (Public):
	Method New()
		ConstructDSM(0, 0, Default_Fullscreen, Default_AASamples, Default_Framerate, Default_Transition, Null)
	End
	
	Method New(Width:Int, Height:Int, Fullscreen:Bool=Default_Fullscreen, AASamples:Int=Default_AASamples, Framerate:Int=Default_Framerate, Transition:Bool=Default_Transition, Position:Vector2D<IntObject>=Null, Color:Int[]=[])
		ConstructDSM(Width, Height, Fullscreen, AASamples, Framerate, Transition, Position, Color)
	End
	
	Method New(Width:Int, Height:Int, Fullscreen:Bool, AASamples:Int, Framerate:Int, Transition:Bool, X:IntObject, Y:IntObject, Color:Int[]=[])
		ConstructDSM(Width, Height, Fullscreen, AASamples, Framerate, Transition, New Vector2D<IntObject>(X, Y), Color)
	End
	
	Method ConstructDSM:Void(Width:Int, Height:Int, Fullscreen:Bool=Default_Fullscreen, AASamples:Int=Default_AASamples, Framerate:Int=Default_Framerate, Transition:Bool=Default_Transition, Position:Vector2D<IntObject>=Null, Color:Int[]=[])
		Self.Width = Width
		Self.Height = Height
		
		Self.Fullscreen = Fullscreen
		Self.AASamples = AASamples
		Self.Framerate = Framerate
		Self.Transition = Transition
		
		Self.Position = Position
		
		' If we don't have a position vector to work with, create one:
		If (Self.Position = Null) Then
			Self.Position = New Vector2D<IntObject>(Null, Null)
		Endif
		
		Self._Color = Color
		
		Return
	End
	
	' Constructor(s) (Private):
	Private
	
	' Nothing so far.
	
	Public
	
	' Methods:
	Method Clone:DesktopScreenMode()		
		Return CloneByRef(New DesktopScreenMode())
	End
	
	Method CloneByRef:DesktopScreenMode(A:DesktopScreenMode)	
		A.ConstructDSM(Width, Height, Fullscreen, AASamples, Framerate, Transition, Vector2D<IntObject>(Position.Clone()), _Color)
		
		Return A
	End
	
	Method ColorAvailable:Bool()
		Return (_Color.Length() > 0)
	End
	
	Method ToDisplayMode:DisplayMode()
		Return New DisplayMode(Width, Height)
	End
	
	' I/O related:
	Method Load:Bool(S:Stream)
		' Check for errors:
		If (S = Null) Then Return False
		If (S.Eof()) Then Return False
		
		' Local variable(s):
		
		Local IOVersion:Int = DesktopScreenMode.IOVersion
		
		' Position related:
		Local X:IntObject, Y:IntObject
		
		' Screen related:
		Local Width:Int, Height:Int
		Local AASamples:Int, Framerate:Int
		Local Color:Int[]
		
		' Flags:
		Local PositionAvailable:Bool
		Local Fullscreen:Bool
		Local Transition:Bool
		Local ColorAvail:Bool
		
		IOVersion = S.ReadInt()
		
		' The display size:
		Width = S.ReadInt()
		Height = S.ReadInt()
		
		' Meta-data:
		Fullscreen = IOElement.ReadBool(S)
		Transition = IOElement.ReadBool(S)
		
		' Anti-aliasing samples.
		AASamples = S.ReadByte()
		
		' Target frame-rate.
		Framerate = S.ReadInt()
		
		#If SCREEN_GLFW2_TARGET
			If (Framerate < 0) Then
				Framerate = Default_Framerate
			Endif
		#End
		
		' Read the position (If there is one):
		PositionAvailable = IOElement.ReadBool(S)
		
		If (PositionAvailable) Then
			If (IOElement.ReadBool(S)) Then
				X = S.ReadInt()
			Endif
			
			If (IOElement.ReadBool(S)) Then
				Y = S.ReadInt()
			Endif
		Endif
		
		' Check if we have a color-setting:
		ColorAvail = IOElement.ReadBool(S)
		
		If (ColorAvail) Then
			' Read the color from the stream.
			Color = New Int[COLOR_ARRAY_LENGTH]
			
			For Local I:Int = 0 Until Color.Length()
				Color[I] = S.ReadByte()
			Next
		Endif
		
		If (IOVersion >= IOVERSION_EXT_NATIVE_FLAGS) Then
			Flags = S.ReadInt()
		Endif
		
		' Construct the screen-mode.
		ConstructDSM(Width, Height, Fullscreen, AASamples, Framerate, Transition, New Vector2D<IntObject>(X, Y), Color)
		
		' Return the default response.
		Return True
	End
	
	Method Save:Bool(S:Stream)
		' Check for errors:
		If (S = Null) Then Return False
		'If (S.Eof()) Then Return False
		
		' This issue has been fixed, there's no need for this check:
		#Rem
		If (Color.Length() > COLOR_ARRAY_LENGTH) Then
			Return False
		Endif
		#End
		
		' Local variable(s):
		Local PositionAvailable:Bool = (Self.Position <> Null And (Self.Position.X <> Null Or Self.Position.Y <> Null))
		
		' Write the I/O version.
		S.WriteInt(IOVersion)
		
		' Resolution:
		S.WriteInt(Self.Width)
		S.WriteInt(Self.Height)
		
		' Flags:
		IOElement.WriteBool(S, Self.Fullscreen)
		IOElement.WriteBool(S, Self.Transition)
		
		' General:
		
		' Anti-aliasing samples.
		S.WriteByte(AASamples)
		
		' The target frame-rate.
		S.WriteInt(Framerate)
				
		' Position:
		IOElement.WriteBool(S, PositionAvailable)

		' The extra check here (In the 'If' statement) isn't needed, but makes this a bit more efficient.
		If (PositionAvailable) Then
			IOElement.WriteBool(S, (Self.Position.X <> Null))
			
			If (Self.Position.X <> Null) Then
				S.WriteInt(Self.Position.X)
			Endif
			
			IOElement.WriteBool(S, (Self.Position.Y <> Null))
			
			If (Self.Position.Y <> Null) Then
				S.WriteInt(Self.Position.Y)
			Endif
		Endif
		
		' Color settings:
		IOElement.WriteBool(S, ColorAvailable())
		
		If (ColorAvailable()) Then
			' Write the color-array to the stream.
			For Local I:Int = 0 Until Min(Color.Length(), COLOR_ARRAY_LENGTH)
				S.WriteByte(Color[I])
			Next
			
			' Pad-out the rest of the bytes of the array.
			For Local Padding:= 0 Until Max(COLOR_ARRAY_LENGTH-Color.Length(), 0)
				S.WriteByte(ZERO)
			Next
		Endif
		
		If (IOVersion >= IOVERSION_EXT_NATIVE_FLAGS) Then
			S.WriteInt(Flags)
		Endif
		
		' Return the default response.
		Return True
	End
	
	' Properties (Public):
	
	' If the input is too small, a padded clone will be made.
	Method Color:Void(Input:Int[], BlankUndefined:Bool=False) Property
		' Local variable(s):
		Local InputLength:= Input.Length()
		
		If (Not ColorAvailable()) Then
			If (InputLength < COLOR_ARRAY_LENGTH) Then
				Input = Input.Resize(COLOR_ARRAY_LENGTH)
			Endif
			
			Self._Color = Input
		Else
			For Local I:Int = 0 Until Min(COLOR_ARRAY_LENGTH, InputLength)
				Self._Color[I] = Input[I]
			Next
			
			If (BlankUndefined) Then
				For Local I:Int = 0 Until Max(COLOR_ARRAY_LENGTH-InputLength, 0)
					Self._Color[InputLength+I] = 0
				Next
			Endif
		Endif
		
		Return
	End
	
	Method Color:Int[]() Property
		If (Not ColorAvailable()) Then
			Self._Color = New Int[COLOR_ARRAY_LENGTH]
		Endif
		
		Return Self._Color
	End
	
	Method X:IntObject() Property
		If (Self.Position <> Null) Then
			Return Position.X
		Endif
		
		Return 0
	End
	
	Method Y:IntObject() Property
		If (Self.Position <> Null) Then
			Return Position.Y
		Endif
		
		Return 0
	End
	
	Method W:Int() Property
		Return Width
	End
	
	Method W:Void(Input:Int) Property
		Width = Input
		
		Return
	End
	
	Method H:Int() Property
		Return Height
	End
	
	Method H:Void(Input:Int)
		Height = Input
		
		Return
	End
	
	' Color related:
	Method R:Int() Property
		Return Color[COLOR_RPOS]
	End
	
	Method R:Void(Input:Int) Property
		Color[COLOR_RPOS] = Input
		
		Return
	End
	
	Method G:Int() Property
		Return Color[COLOR_GPOS]
	End
	
	Method G:Void(Input:Int) Property
		Color[COLOR_GPOS] = Input
		
		Return
	End	
	
	Method B:Int() Property
		Return Color[COLOR_BPOS]
	End
	
	Method B:Void(Input:Int) Property
		Color[COLOR_BPOS] = Input
		
		Return
	End
	
	Method A:Int() Property
		Return Color[COLOR_APOS]
	End
	
	Method A:Void(Input:Int) Property
		Color[COLOR_APOS] = Input
		
		Return
	End
	
	Method Depth:Int() Property
		Return Color[COLOR_DEPTHPOS]
	End
	
	Method Depth:Void(Input:Int) Property
		Color[COLOR_DEPTHPOS] = Input
		
		Return
	End
	
	Method Stencil:Int() Property
		Return Color[COLOR_STENCILPOS]
	End
	
	Method Stencil:Void(Input:Int) Property
		Color[COLOR_STENCILPOS] = Input
		
		Return
	End
	
	' Properties (Private):
	Private
	
	' Nothing so far.
	
	Public
	
	' Fields (Public):
	
	' These are pretty self-explanatory:
	Field Fullscreen:Bool
	Field Transition:Bool
	
	' The default placement of a window.
	Field Position:Vector2D<IntObject>
	
	' The actual resolution:
	Field Width:Int
	Field Height:Int
	
	' Other:
	Field AASamples:Int
	Field Framerate:Int
	
	Field Flags:Int
	
	' Fields (Private):
	Private
	
	Field _Color:Int[]
	
	' Flags:
	' Nothing so far.
	
	Public
End

' Functions:
Function ResizeWindow:Bool(Resolution:DesktopScreenMode, ForceFlags:Bool=False)
	Return InitWindow(Resolution, True, ForceFlags)
End

Function InitWindow:Bool(Resolution:DesktopScreenMode, Force:Bool=False, ForceFlags:Bool=False)
	' Check if the window has already been created.
	If (WindowCreated And Not Force) Then Return False
	
	' Local variable(s):
	Local Response:Bool = False
	
	' Change the resolution if possible:
	#If FLAG_DESKTOP
		#If SCREEN_GLFW2_TARGET
			' Local variable(s):
			Local GlfwInstance:= GlfwGame.GetGlfwGame()
		#End
		
		#If DESKTOP_WINDOW_TRANSITION
			If (Resolution <> Null) Then
				' Check for a transition.
				If (Resolution.Transition) Then
					' Local variable(s):
					Local IsFullscreen:Bool = False
					
					If (WindowCreated) Then
						If (CurrentWindowMode = Null) Then
							#If (SCREEN_GLFW2_TARGET And GLFW_WINDOW_FULLSCREEN) Or (DEFAULT_DESKTOP_FULLSCREEN)
								IsFullscreen = True
							#Else
								IsFullscreen = False
							#End
						Else
							IsFullscreen = CurrentWindowMode.Fullscreen
						Endif
						
						If (Not IsFullscreen) Then
							MoveWindow_ToDestination()
						
							If (Resolution.Fullscreen) Then
								Delay(250)
							Endif
						Endif
					Endif
				Endif
			Endif
		#End
		
		#If SCREEN_GLFW2_TARGET
			' Color related:
			Local RBits:Int = 0
			Local GBits:Int = 0
			Local BBits:Int = 0
			Local ABits:Int = 0
			
			Local Depth:Int = 0
			Local Stencil:Int = 0
			
			' Screen related:
			Local Width:Int = -1
			Local Height:Int = -1
			
			' Flags:
			Local Fullscreen:Bool = True
			Local Transition:Bool = False
			
			' Other:
			Local Framerate:Int = DesktopScreenMode.Default_Framerate
			Local AASamples:Int = DesktopScreenMode.Default_AASamples
			
			If (Resolution <> Null) Then
				Width = Resolution.Width
				Height = Resolution.Height
				Fullscreen = Resolution.Fullscreen
				AASamples = Resolution.AASamples
			Endif
			
			If (Width < 0 Or Height < 0) Then
				Local DesktopMode:= GlfwInstance.GetGlfwDesktopMode()
				
				Width = DesktopMode.Width
				Height = DesktopMode.Height
				Fullscreen = True
				
				RBits = DesktopMode.RedBits
				GBits = DesktopMode.GreenBits
				BBits = DesktopMode.BlueBits
			ElseIf (Resolution <> Null) Then
				If (Resolution.ColorAvailable()) Then
					RBits = Resolution.R
					GBits = Resolution.G
					BBits = Resolution.B
					ABits = Resolution.A
					
					Depth = Resolution.Depth
					Stencil = Resolution.Stencil
				Else
					RBits = GlfwInstance.GetGlfwDesktopMode().RedBits
					GBits = GlfwInstance.GetGlfwDesktopMode().GreenBits
					BBits = GlfwInstance.GetGlfwDesktopMode().BlueBits
					
					'ABits = 0
					'Depth = 0
					'Stencil = 0
				Endif
			Endif
			
			GlfwOpenWindowHint(SCREEN_GLFW_FSAA_SAMPLES, AASamples)
			
			GlfwInstance.SetGlfwWindow(Width, Height, RBits, GBits, BBits, ABits, Depth, Stencil, Fullscreen)
		#Else
			Local Width:Int = -1
			Local Height:Int = -1
			Local Fullscreen:Bool = True
			Local AASamples:Int = DesktopScreenMode.Default_AASamples
			
			If (Resolution <> Null) Then
				Width = Resolution.Width
				Height = Resolution.Height
				Fullscreen = Resolution.Fullscreen
				AASamples = Resolution.AASamples
			Endif
			
			If (Width < 0 Or Height < 0) Then
				Local Desktop:= DesktopMode()
				
				Width = Desktop.Width
				Height = Desktop.Height
								
				Fullscreen = True
			Endif
			
			#If TARGET = "xna"
				XNA_ToggleAA((AASamples > 0))
			#End
			
			If (ForceFlags Or (Resolution.Flags <> 0)) Then
				SetDeviceWindow(Width, Height, Resolution.Flags)
			Else
				SetDeviceWindow(Width, Height, Int(Fullscreen)|DesktopScreenMode.FLAG_RESIZABLE|DesktopScreenMode.FLAG_DECORATED) ' FLAG_FULLSCREEN
			Endif
		#End
		
		' Set the response to true.
		Response = True
		
		#If DESKTOP_WINDOW_TRANSITION
			If (Resolution <> Null) Then
				If (Resolution.Transition) Then
					MoveWindow_SetResolution(Resolution.W, Resolution.H)
					
					If (Not Resolution.Fullscreen) Then
						MoveWindow_ToCenter()
							
						' Local variable(s):
						Local Response:Bool = False
						Local RX:Int = NOVAR
						Local RY:Int = NOVAR
						
						If (Resolution.X <> Null) Then
							RX = Resolution.X
							Response = True
						Endif
						
						If (Resolution.Y <> Null) Then
							RY = Resolution.Y
							Response = True
						Endif
						
						If (Response) Then
							MoveWindow_ToDestination(NOVAR, NOVAR, RX, RY, True)
						Endif
					Endif
				Else
					If (Resolution.X <> Null And Resolution.Y <> Null) Then
						MoveWindow(Resolution.X, Resolution.Y)
					Endif
				Endif
			Endif
		#End
		
		WindowCreated = True
			
		#Rem
		'#If TARGET = "xna"
			Local XnaInstance:= XnaGame.GetXnaGame()
			
			' Keeping this blank for now.
			
			'WindowCreated = True
		#End
		
		' If the change was successful, set the last window screen-mode to a clone of the input.
		If (Response) Then
			If (Resolution <> Null) Then
				CurrentWindowMode = Resolution.Clone()
			Else
				' Local variable(s):
				Local Color:Int[]
				
				' If we have a color setup, use it:
				#If SCREEN_GLFW2_TARGET
					If (RBits <> 0 Or GBits <> 0 Or BBits <> 0 Or ABits <> 0 Or Depth <> 0 Or Stencil <> 0) Then
						Color = [RBits, GBits, BBits, ABits, Depth, Stencil]
					Endif
				#Else
					Local Fullscreen:Bool = True
					Local Transition:Bool = False
					Local Framerate:Int = DesktopScreenMode.Default_Framerate
				#End
				
				CurrentWindowMode = New DesktopScreenMode(Width, Height, Fullscreen, AASamples, Framerate, Transition, Null, Color)
				'New(Width:Int, Height:Int, Fullscreen:Bool, AASamples:Int, Framerate:Int, Transition:Bool, X:IntObject, Y:IntObject, Color:Int[]=[])
			Endif
		Endif
		
		#If CONFINE_CURSOR_IMPLEMENTED
			'BeginConfineCursor()
			'EndConfineCursor()
		#End
	#Else
		' Nothing so far.
	#End
	
	' Platform/target independent code:
	'SetCursor(CursorMode) <- I may look into this later.
	
	Return Response
End
#End