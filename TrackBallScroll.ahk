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
global scrolling := false
global button_down := false

*$RButton::
	; Right mouse button down: start scrolling if held long enough
	button_down := true
	Sleep, 200 ; Wait to see if button is held down or on the way to be released (clicK)
	if ( GetKeyState( "RButton", "p") ) {
		MouseGetPos, x1, y1
		scrolling := true
		while scrolling && button_down {
			Sleep, 1
			BlockInput MouseMove
			MouseGetPos, x2, y2
			MouseMove, x1, y1, 0

			key:=""
			wheel:=""
			modifier:=0
			if ( y2 > y1 ) {
				modifier:=1
				wheel:="{Blind}{WheelDown Down}"
			}
			else if ( y2 < y1 ) {
				modifier:=-1
				wheel:="{Blind}{WheelUp Down}"
			}

			if ( modifier != 0 )
			{
				n := modifier*( y2 - y1 )
				if modifier*scroll_value < 0
				{
					scroll_value:=0
				}
				scroll_value+=modifier*n
				n := Floor(modifier*scroll_value/scroll_speed)
				if n > 0
				{
					While n > 0
					{
						SendInput % wheel
						n--
						scroll_value-=modifier*scroll_speed
					}
				}
			}
			BlockInput MouseMoveOff
		}
		scrolling :=false
	}
return

*$RButton up::
	; Right mouse button click or stop scrolling
	button_down := false
	if !scrolling {
		SendInput, {Blind}{RButton}
	}
return

$XButton1::
	; Back mouse button mapped to middle click
	SendInput, {MButton down}
return
$XButton1 up::
	; Back mouse button mapped to middle click
	SendInput, {MButton up}
return

$XButton2 up::
	; Forward mouse button mapped to Back mouse button
	SendInput, {Xbutton1}
return

About:
	MsgBox, 0, % "About", % "Adapted by https://github.com/pl-ca/ for my needs from original`nscript found at https://furgelnod.com/2014/trackball-to-scroll-wheel/."
return
ExitNow:
	ExitApp
