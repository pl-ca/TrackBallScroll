#SingleInstance force
#NoEnv
#Warn
SendMode Input
SetWorkingDir %A_ScriptDir%
#InstallKeybdHook

EnvGet, lsysroot, SystemRoot

Menu, Tray, Icon, % lsysroot "\system32\setupapi.dll", 2, 1
Menu, Tray, Tip, % "Simulating a scroll wheel when some buttons are pressed"
Menu, Tray, NoStandard
Menu, Tray, Add, % "About", About
Menu, Tray, Add
Menu, Tray, Add, % "Exit", ExitNow

CoordMode, Mouse, Screen
global scroll_value:=0
global scroll_speed:=32
scrollActive( obutton := "RButton", extra := "" )
{
	extraup := ""
	extradown := ""
	if ( extra <> "" ) {
		extraup := "{" . extra . " Up}"
		extradown := "{" . extra . " Down}"
	}
	Sleep, 200
	if ( GetKeyState( obutton, "p") ) {
		Loop {
			MouseGetPos, x1, y1
			Sleep, 1
			MouseGetPos, x2, y2
			BlockInput MouseMove
			MouseMove, x1, y1, 0
			if ( y1 <> y2 ) {
				SendInput, % extradown
			}
			if ( y2 > y1 ) {
				n := ( y2 - y1 )
				if scroll_value < 0
				{
					scroll_value:=0
				}
				scroll_value+=n
				n := Floor(scroll_value/scroll_speed)
				if n > 0
				{
					While n > 0
					{
						SendInput, % "{WheelDown Down}"
						n--
						scroll_value-=scroll_speed
					}
				}
			}
			else if ( y2 < y1 ) {
				n := ( y1 - y2 )
				if scroll_value > 0
				{
					scroll_value:=0
				}
				scroll_value-=n
				n := Floor(-1*scroll_value/scroll_speed)
				if n > 0
				{
					While n > 0
					{
						SendInput, % "{WheelUp Down}"
						n--
						scroll_value+=scroll_speed
					}
				}
			}
			if ( y1 <> y2 ) {
				SendInput, % extraup
			}
			BlockInput MouseMoveOff
		}
		Until NOT ( GetKeyState( obutton, "p") )
	}
	else {
		SendInput, % extradown . "{" . obutton . "}" . extraup
	}
	scroll:=0

}

RButton::
	scrollActive( "RButton" )
return

; ==============================
<^RButton::
	scrollActive( "RButton", "LCtrl" )
return


>^RButton::
	scrollActive( "RButton", "RCtrl" )
return

; ==============================
<!RButton::
	scrollActive( "RButton", "LAlt" )
return


>!RButton::
	scrollActive( "RButton", "RAlt" )
return

; ==============================
<+RButton::
	scrollActive( "RButton", "LShift" )
return


>+RButton::
	scrollActive( "RButton", "RShift" )
return

; ===============================

About:
	MsgBox, 0, % "About", % "Adapted by https://github.com/pl-ca/ for my needs from original`nscript found at https://furgelnod.com/2014/trackball-to-scroll-wheel/."
return
ExitNow:
	ExitApp