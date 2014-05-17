
/*
All code is public-domain, and can be used in any way you see fit.
This is provided as-is, and I take no responsibility for any damages.

Credit would be appreciated, but it's not a requirement.
*/

// Includes:
#ifndef NATIVE_DESKTOP_WINDOW_H
	#define NATIVE_DESKTOP_WINDOW_H 1
	
	/*
	All code is public-domain, and can be used in any way you see fit.
	This is provided as-is, and I take no responsibility for any damages.
	
	Credit would be appreciated, but it's not a requirement.
	*/
	
	// Credits:
	// Current version by:	Sonickidnextgen (Anthony Diamond)
	
	// Includes:
	#if !defined(_WIN32) //#if defined(__linux__)
		#include <unistd.h>
	#else
		#define WIN32_LEAN_AND_MEAN
		
		#include <windows.h>
		
		#undef WIN32_LEAN_AND_MEAN
	#endif
	
	//#include <math.h>
	#include <cmath>
	#include <algorithm>
	
	/*
	float std::min(float, float);
	float std::max(float, float);
	*/
	
	// Preprocessor related:	
	/*
	#if !defined(max)
		#define max(X, Y) (X > Y) ? X : Y
	#endif
	
	#if !defined(min)
		#define min(X, Y) (X < Y) ? X : Y
	#endif
	*/
	
	#if defined(_WIN32)
		#define TOGGLE_CURSOR_IMPLEMENTED
	#endif
	
	// Structures:
	struct handle_Data
	{
		DWORD processID; // Also known as 'unsigned long', AKA 'ULONG' in 'WinDef' terminology.
		HWND mainWindow; //NULL;
	};
	
	// Classes:
	
	// Everything related to the window:
	// I was going to make this a namespace, but sadly they don't support 'private'.
	class desktopWindow
	{
		// Public members:
		public:
			// Constant variables:
			static const short transitionRate = 45;
		
			// Global variables:
			static bool desktopChecked;
			static float minTransitionSpeed;
			static String windowTitle;
			static bool windowCreated;
			
			#if defined(_WIN32)
				static HWND hWnd;
				
				static RECT rcClip;
				static RECT rcOldClip;
				
				static bool confineCursor_screenOnly;
				static bool confineCursor_state;
			#endif
			
			#if defined(TOGGLE_CURSOR_IMPLEMENTED)
				static bool smartCursorToggle_state;
				static bool cursorToggle_state;
			#endif
			
			// Transition related variables:
			static float transitionX;
			static float transitionY;
			
			// Destination related variables:
			static float destinationX;
			static float destinationY;
			
			// Platform specific variables:
			#if defined(CFG_GLFW_TARGET) && CFG_GLFW_TARGET == 1
				static GLFWvidmode desktop;
			#else
				// Nothing so far.
			#endif
			
			// Constructors & Destructors:
			desktopWindow();
			~desktopWindow();
		
			// Public functions:

			// Here's a simple function you might find useful, I use it for my own project.
			static inline void appTitle(String s);
			
			static inline String appTitle() { return windowTitle; }
		
			// The window-resize/screen-mode code:
			static inline void setDestination(int x, int y);
			static inline void toCenter();
			static void toDestination(int currentX=NOVAR, int currentY=NOVAR, int x=NOVAR, int y=NOVAR, bool windowCreated=true);
			static inline void move(int x, int y);
			
			#if defined(TOGGLE_CURSOR_IMPLEMENTED)
				static inline int toggleCursor(bool value, bool setState=true);
				static inline void updateSmartCursorToggle();
			#endif
			
			// Windows specific code:
			#if defined(_WIN32)
				static inline void confineCursor_begin();
				static inline void confineCursor_end();
				
				static inline void confineCursor_toggleScreenOnly(bool value)
				{
					confineCursor_screenOnly = value;
					
					return;
				}
				
				static inline void confineCursor_toggleScreenOnly()
				{
					confineCursor_screenOnly = !confineCursor_screenOnly;
					
					return;
				}
				
				static inline HWND windows_getWindow()
				{					
					handle_Data handleData;
					memset(&handleData, 0, sizeof(handleData));
					
					handleData.processID = GetCurrentProcessId();
					
					EnumWindows(&enum_windows_callback, (LPARAM)&handleData);
					
					return handleData.mainWindow;
				}
				
				static inline BOOL CALLBACK enum_windows_callback(HWND handle, LPARAM lParam)
				{
					// Local variable(s):
					handle_Data& data = *(handle_Data*)lParam;
					ULONG processID = 0;
					
					GetWindowThreadProcessId(handle, &processID);
					
					if (data.processID != processID || !isMainWindow(handle))
					{
						return TRUE;
					}
					
					data.mainWindow = handle;
					
					return FALSE;
				}
				
				static inline BOOL isMainWindow(HWND handle)
				{
					return (GetWindow(handle, GW_OWNER) == (HWND)0 && IsWindowVisible(handle));
				}
			#endif
			
			#if defined(CFG_GLFW_TARGET) && CFG_GLFW_TARGET == 1
				static inline GLFWvidmode* desktopVideoMode();
			#else
				// Nothing so far.
			#endif
			
			static inline void delay(unsigned int ms);
			
			// Public methods:
			inline void setResolution(unsigned int w, unsigned int h);
			inline void setResolution(const unsigned int* r);
			
			// Make sure to delete the int array after the function returns it.
			inline unsigned int* getResolution();
			
			// Public fields:
			unsigned int width;
			unsigned int height;
	
		// Private members:
		private:
			// Private enumerators:
			
			// So far the only entry is NOVAR.
			enum
			{
				// I'd do a simple pointer check,
				// but that doesn't really work in all situations.
				NOVAR=-999999
				
				// Nothing else at the moment.
			};
			
			// Private functions:
			static inline void setWindowPos(int x, int y);
			
			static inline void updateTransition
			(
				bool& transition,
				float& transitionX, float& transitionY,
				int destX, int destY,
				int windowW, int windowH
			);
			
			static inline void calculateDestination();
			
			// Private fields:
			// Nothing so far.
			
			// Private methods:
			// Nothing so far.
	} currentWindow;
	
	// Global variables:
	#if defined(CFG_GLFW_TARGET) && CFG_GLFW_TARGET == 1
		GLFWvidmode desktopWindow::desktop;
	#endif
	
	bool desktopWindow::desktopChecked = false;
	bool desktopWindow::windowCreated = false; // true;
	
	// Transition related variables:
	float desktopWindow::transitionX = 0.0f;
	float desktopWindow::transitionY = 0.0f;
	
	// Destination related variables:
	float desktopWindow::destinationX = desktopWindow::NOVAR;
	float desktopWindow::destinationY = desktopWindow::NOVAR;
	
	// This can be changed to any value you want, but it usually makes the window shake.
	float desktopWindow::minTransitionSpeed = 0.0f;
	String desktopWindow::windowTitle = String(_STRINGIZE(CFG_GLFW_WINDOW_TITLE));
	
	#if defined(_WIN32)
		HWND desktopWindow::hWnd = 0;
		RECT desktopWindow::rcClip; // NULL
		RECT desktopWindow::rcOldClip; // NULL
		
		bool desktopWindow::confineCursor_screenOnly = true;
		bool desktopWindow::confineCursor_state = false;
	#endif
	
	#if defined(TOGGLE_CURSOR_IMPLEMENTED)
		bool desktopWindow::cursorToggle_state = true;
		bool desktopWindow::smartCursorToggle_state = false;
	#endif
#endif

// Definitions:

// Constructors & Destructors:
desktopWindow::desktopWindow() : width(CFG_GLFW_WINDOW_WIDTH), height(CFG_GLFW_WINDOW_HEIGHT)
{
	// Nothing so far.
}

desktopWindow::~desktopWindow()
{
	// Nothing so far.
}

// Public functions:
inline void desktopWindow::appTitle(String s)
{
	// Set the title of the window to the string specified:
	#if defined(CFG_GLFW_TARGET) && CFG_GLFW_TARGET == 1
		glfwSetWindowTitle(s.ToCString<char>());
	#else
		// Nothing so far.
	#endif
	
	windowTitle = s;
	
	return;
}

void desktopWindow::toDestination(int currentX, int currentY, int x, int y, bool windowCreated)
{
	// Temporary variables:
	bool transition = true;
	
	#if defined(CFG_GLFW_TARGET) && CFG_GLFW_TARGET == 1
		GLFWvidmode* desktopMode;
		BBGlfwGame* glfwGame;
		
		// Detect the desktop resolution.
		desktopMode = desktopVideoMode();
		glfwGame = BBGlfwGame::GlfwGame();
	#else
		// Nothing so far.
	#endif
	
	// Etc:
	if (x != NOVAR)
		destinationX = x;
	
	if (y != NOVAR)
		destinationY = y;
		
	calculateDestination();
		
	if (currentX == NOVAR)
		currentX = ((desktopVideoMode()->Width - currentWindow.width)/2);
		
	if (currentY == NOVAR)
		currentY = ((desktopVideoMode()->Height - currentWindow.height)/2);

	if (desktopWindow::windowCreated == windowCreated)
	{
		// Set the initial window position:
		transitionX = (float)currentX;
		transitionY = (float)currentY;
		
		setWindowPos((int)transitionX, (int)transitionY);
	
		// Delay for 100ms.	
		delay(100);
		
		// Repeat until the transition variable is false.
		#if defined(CFG_GLFW_TARGET) && CFG_GLFW_TARGET == 1						
			while (transition == true)
			{			
				// Update the transition.
				updateTransition
				(
					// Arguments:
					
					// Transition variable. (Boolean)
					transition,
					
					// X and Y variables. (Floats)
					transitionX,
					transitionY,
					
					// X and Y destination values. (Ints)
					destinationX, destinationY,
					
					// The width and height values for the current window. (Ints)
					currentWindow.width,
					currentWindow.height
				);
				
				// Delay based on the frame-rate.
				delay(1000/transitionRate);
			}
		#else
			// Nothing so far.
		#endif
		
		// Set the transition variable back to true.
		//transition = true;
	}
	
	desktopWindow::windowCreated = !windowCreated;
	
	destinationX = NOVAR;
	destinationY = NOVAR;
		
	return;
}

inline void desktopWindow::setDestination(int x, int y)
{
	destinationX = x;
	destinationY = y;
	
	return;
}

inline void desktopWindow::toCenter()
{
	#if defined(CFG_GLFW_TARGET) && CFG_GLFW_TARGET == 1 //|| defined(CFG_POPCAP_TARGET) && CFG_POPCAP_TARGET == 1
		int windowX = (int)(abs((int)(desktopVideoMode()->Width - currentWindow.width)/2));
		int windowY = (int)(abs((int)(desktopVideoMode()->Height - currentWindow.height)/2));
		
		if (currentWindow.height > ((unsigned int)(desktopVideoMode()->Height/1.5)))
		{
			windowY -= (abs((int)desktopVideoMode()->Height - (int)currentWindow.height) / 4);
		}
		
		calculateDestination();
	
		setWindowPos(destinationX, destinationY);
		toDestination((int)destinationX, (int)destinationY, windowX, windowY, false);
	#else
		// Nothing so far.
	#endif
	
	return;
}

inline void desktopWindow::move(int x, int y)
{
	setWindowPos(x, y);
	
	return;
}

#if defined(TOGGLE_CURSOR_IMPLEMENTED)
	inline int desktopWindow::toggleCursor(bool value, bool setState)
	{
		// Local variable(s):
		int ID = 0;
		
		#if defined(_WIN32)
			if (cursorToggle_state == !value || !setState)
			{
				if (setState)
					cursorToggle_state = value;
													
				// Change the cursor to the desired ID.
				while ((value) ? (ShowCursor(value) < 0) : (ShowCursor(value) >= 0));
			}
		#endif
		
		return ID;
	}
	
	inline void desktopWindow::updateSmartCursorToggle()
	{
		if (!confineCursor_state)
		{
			if (hWnd == 0)
			{
				// Get the current window handle.
				hWnd = windows_getWindow();
				
				// Get the current 'clip' for the cursor.
				if (hWnd != 0)
					GetClipCursor((LPRECT)&rcOldClip);
			}
			
			RECT smartClip;
			
			// Get the window rect.
			GetWindowRect(hWnd, (LPRECT)&smartClip);
			
			INT topOffset, bottomOffset, leftOffset, rightOffset;
			
			bottomOffset = GetSystemMetrics(SM_CYSIZEFRAME);// + GetSystemMetrics(SM_CYEDGE);
			topOffset = (GetSystemMetrics(SM_CYCAPTION) + bottomOffset);
			leftOffset = GetSystemMetrics(SM_CXSIZEFRAME);// + GetSystemMetrics(SM_CXEDGE);
			rightOffset = leftOffset; //GetSystemMetrics(SM_CXSIZEFRAME) + GetSystemMetrics(SM_CXEDGE);
			
			smartClip.left += leftOffset;
			smartClip.right -= rightOffset;
			
			smartClip.top += topOffset;
			smartClip.bottom -= bottomOffset;
			
			POINT cursorPos;
			
			GetCursorPos((LPPOINT)&cursorPos);
			
			if (cursorPos.y > smartClip.top && cursorPos.y < smartClip.bottom && cursorPos.x > smartClip.left && cursorPos.x < smartClip.right)
			{
				if (smartCursorToggle_state)
				{
					toggleCursor(cursorToggle_state, false);
					
					smartCursorToggle_state = false;
				}
			}
			else
			{
				if (!smartCursorToggle_state)
				{
					toggleCursor(true, false);
					
					smartCursorToggle_state = true;
				}
			}
		}
		
		return;
	}
#endif

#if defined(_WIN32)
	inline void desktopWindow::confineCursor_begin()
	{
		if (confineCursor_state)
			return;
		
		confineCursor_state = true;
		
		if (hWnd == 0)
		{
			// Get the current window handle.
			hWnd = windows_getWindow();
			
			//bbPrint(String((int)hWnd));
			
			// Get the current 'clip' for the cursor.
			if (hWnd != 0)
				GetClipCursor((LPRECT)&rcOldClip);
		}
		
		if (hWnd != 0)
		{
			// Get the window rect.
			//GetWindowRect(hWnd, (LPRECT)&rcClip);
			GetWindowRect(hWnd, (LPRECT)&rcClip);
			
			if (confineCursor_screenOnly)
			{
				INT topOffset, bottomOffset, leftOffset, rightOffset;
				
				bottomOffset = GetSystemMetrics(SM_CYSIZEFRAME);// + GetSystemMetrics(SM_CYEDGE);
				topOffset = (GetSystemMetrics(SM_CYCAPTION) + bottomOffset);
				leftOffset = GetSystemMetrics(SM_CXSIZEFRAME);// + GetSystemMetrics(SM_CXEDGE);
				rightOffset = leftOffset; //GetSystemMetrics(SM_CXSIZEFRAME) + GetSystemMetrics(SM_CXEDGE);
				
				rcClip.left += leftOffset;
				rcClip.right -= rightOffset;
				
				rcClip.top += topOffset;
				rcClip.bottom -= bottomOffset;
			}
			
			// Confine the cursor to the window.
			ClipCursor((LPRECT)&rcClip);
		}
		
		return;
	}
	
	inline void desktopWindow::confineCursor_end()
	{
		if (!confineCursor_state)
			return;
			
		confineCursor_state = false;
		
		if (hWnd != 0)
		{
			// Restore the 'clip' for the cursor.
			ClipCursor((LPRECT)&rcOldClip);
		}
		
		return;
	}
#endif

// Public methods:
inline void desktopWindow::setResolution(unsigned int w, unsigned int h)
{
	this->width = w;
	this->height = h;

	return;
}

inline void desktopWindow::setResolution(const unsigned int* r)
{
	// I could technically use 'memcpy' here,
	// but it's not such a good idea for expandability:
	setResolution(r[0], r[1]);
	
	return;
}

// Make sure to delete the int array after the function returns it.
inline unsigned int* desktopWindow::getResolution()
{
	unsigned int* resolution = new unsigned int[2];
	
	resolution[0] = this->width;
	resolution[1] = this->height;
	
	return resolution;
}

// Private functions:

// A simple command that grabs the current desktop resolution:
inline GLFWvidmode* desktopWindow::desktopVideoMode()
{
	if (desktopChecked == false)
	{
		glfwGetDesktopMode(&desktop);
		desktopChecked = true;
	}
	
	// Return the desktop's video mode/info.
	return &desktop;
}

// A basic cross-platform 'delay' command.
inline void desktopWindow::delay(unsigned int ms)
{
	#if defined(_WIN32)
		Sleep(ms);
	#else
		usleep(ms*1000);
	#endif
	
	return;
}

inline void desktopWindow::setWindowPos(int x, int y)
{
	#if defined(CFG_GLFW_TARGET) && CFG_GLFW_TARGET == 1
		glfwSetWindowPos(x, y);
	#else
		// Nothing so far. (Unsupported)
	#endif
	
	return;
}

inline void desktopWindow::updateTransition(bool& transition, float& transitionX, float& transitionY, int destX, int destY, int windowW, int windowH)
{
	// Namespace(s):
	using namespace std;
	
	// Tell GLFW to poll for events.
	#if defined(CFG_GLFW_TARGET) && CFG_GLFW_TARGET == 1
		glfwPollEvents();
	#endif

	// Check if we're going up or down, then move accordingly:
	if (destX > transitionX)
		transitionX += max((float)(abs(transitionX-destX) * 0.1425), minTransitionSpeed);
	else
		transitionX -= max((float)(abs(transitionX-destX) * 0.1425), minTransitionSpeed);
		
	if (destY > transitionY)
		transitionY += max((float)(abs(transitionY-destY) * 0.1425), minTransitionSpeed);
	else
		transitionY -= max((float)(abs(transitionY-destY) * 0.1425), minTransitionSpeed);
	
	if (abs((int)transitionX - destX) <= 2 && abs((((int)(transitionY) - destY)/2)) <= 2)
		transition = false;
	
	setWindowPos((int)transitionX, (int)transitionY);
	
	//Print(String("transitionX: ") + String(transitionX) + String(" transitionY: ") + String(transitionY));
	//Print(String("DESTX: ") + String(destX) + String(" DESTY: ") + String(destY));
	
	return;
}

inline void desktopWindow::calculateDestination()
{
	#if defined(CFG_GLFW_TARGET) && CFG_GLFW_TARGET == 1
		if (destinationX == NOVAR)
			destinationX = ((desktopVideoMode()->Width - currentWindow.width)/2);
			
		if (destinationY == NOVAR)
			destinationY = desktopVideoMode()->Height;
	#endif
		
	return;
}