; ------------------------------------------------------------
;
; _WindowsHotkeys.ahk, by Cavalol
;   |
;   |--> Effective Hotkeys for Windows-based Workstaitons
;   |
;   |--> Runs via "Autohotkey" (AHK) - Download @ https://www.autohotkey.com/download/
;   |
;   |--> Download this script:  https://raw.githubusercontent.com/mcavallo-git/Coding/master/ahk/NotHotkeys.ahk
;
; ------------------------------------------------------------

#Persistent  ; https://www.autohotkey.com/docs/commands/_Persistent.htm

#HotkeyInterval 2000  ; https://www.autohotkey.com/docs/commands/_HotkeyInterval.htm

#MaxHotkeysPerInterval 2000  ; https://www.autohotkey.com/docs/commands/_MaxHotkeysPerInterval.htm

#SingleInstance Force  ; https://www.autohotkey.com/docs/commands/_SingleInstance.htm

Block_FFXIV_MouseClicks := 0

VerboseOutput := 0

ExeBasename := "ffxiv_dx11.exe"

ExeWinTitle := "FINAL FANTASY XIV"

ExeWinClass := "FFXIVGAME"


; ------------------------------------------------------------
; ------------------------------------------------------------
; ---                   HOTKEY-LISTENERS                   ---
; ------------------------------------------------------------
; ------------------------------------------------------------


; ------------------------------------------------------------
;
;   HOTKEY:  Win + Esc
;   ACTION:  Refresh This Script  ::: Closes then re-opens this script (Allows saved changes to THIS script (file) to be tested/applied on the fly)
;
~#Escape::
	Sleep 250
	BlockInPut, Off  ;  Stop blocking input (e.g. restore full interaction)
	Reload  ; Reload this script
	Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
	MsgBox, 4,, The script could not be reloaded. Would you like to open it for editing?
	IfMsgBox, Yes, Edit
	Return


; ------------------------------------------------------------
;
;  HOTKEY:  WinKey + -
;  ACTION:  Craft it up
;
#-::
	SetKeyDelay, 0, -1
	; SetTitleMatchMode, 2  ; A window's title can contain WinTitle anywhere inside it to be a match
	CoordMode, Mouse, Screen
	SetDefaultMouseSpeed, 0
	SetControlDelay, -1
	Global Block_FFXIV_MouseClicks
	Global ExeBasename
	Global ExeWinTitle
	Global VerboseOutput
	AwaitModifierKeyup()
	Enable_FFXIV_MouseEvents()
	ExePID := GetPID(ExeBasename)
	Echo_Tooltip := "Running Crafting Hotkeys"
	ToolTip, %Echo_Tooltip%
	ClearTooltip(5000)
	MaxLoops := 25
	MsgBox, 3, FFXIV AutoCraft, Is the 'Crafting Log' open with desired item selected?
	IfMsgBox Yes
	{
		Sleep 1000
		Disable_FFXIV_MouseEvents()
		; WinSet, Disable,, ahk_pid %ExePID%
		; OverlayOn(ExeBasename)

		; ------------------------------------------------------------
		; Part 1-of-4 - Select "Synthesize"
			;   |--> Hotkey:  =
			;         |--> In-game, assign this hotkey to the "Confirm" command (found under "System" -> "Keybind" -> "System" tab)
		;
		Sleep 2000
		Loop 4 {
			ControlSend,, =, ahk_pid %ExePID%
			Random, RandomSleep, 500, 1000  ; Random wait
			Sleep %RandomSleep%
		}
		Loop %MaxLoops% {
			; ------------------------------------------------------------
			; General padding at the start of the loop and after each repeat
			;
			Sleep 3000
			Echo_Tooltip := "Crating 83* Gear (loop " A_Index "/"  MaxLoops ")"
			ToolTip, %Echo_Tooltip%
			ClearTooltip(15000)
			Sleep 100
			; ------------------------------------------------------------
			; Part 2-of-4 - Run the first macro (of two) for a "Level 83 Star Craft"
			;   |--> Hotkey:  [
			;         |--> In-game, assign this hotkey to the hotbar position which contains the first crafting macro
			;
			ControlSend,,[, ahk_pid %ExePID%
			Sleep 36000
			Sleep 2000  ; General padding to let craft complete
			Random, RandomSleep, 1000, 5000  ; Random wait
			Sleep %RandomSleep%
			; ------------------------------------------------------------
			; Part 3-of-4 Run the second macro (of two) for a "Level 83 Star Craft"
			;   |--> Hotkey:  ]
			;         |--> In-game, assign this hotkey to the hotbar position which contains the second crafting macro
			;
			ControlSend,,], ahk_pid %ExePID%
			Sleep 14000
			Sleep 2000  ; General padding to let craft complete
			Random, RandomSleep, 1000, 5000  ; Random wait
			Sleep %RandomSleep%
			; ------------------------------------------------------------
			; Part 4-of-4 - Re-select "Synthesize"
			;   |--> Hotkey:  =
			;         |--> In-game, assign this hotkey to the "Confirm" command (found under "System" -> "Keybind" -> "System" tab)
			;
			Sleep 2000
			Loop 3 {
				ControlSend,, =, ahk_pid %ExePID%
				Random, RandomSleep, 500, 1000  ; Random wait
				Sleep %RandomSleep%
			}
			Random, RandomSleep, 1000, 2000  ; Random wait
			Sleep 2000  ; Wait for synthesize to finish
		}
		Enable_FFXIV_MouseEvents()
		Sleep 1000
		; WinSet, Enable,, ahk_pid %ExePID%
		; OverlayOff(ExeBasename)
	}
	Return


; ------------------------------------------------------------
;
;  HOTKEY:  Left-MouseClick
;  HOTKEY:  Right-MouseClick
;  ACTION:  Block mouseclick events if the FFXIV window is active && crafting is occurring
;
#If WinActive("ahk_class FFXIVGAME") and (Block_FFXIV_MouseClicks == 1)
	LButton::
	RButton::
		Return
#If


; ; ------------------------------------------------------------
; ;
; ;  HOTKEY:  WinKey + =
; ;  ACTION:  Win the gamble
; ;
; #If WinActive("ahk_class FFXIVGAME")
; 	#1::
; 		SetKeyDelay, 0, -1
; 		; SetTitleMatchMode, 2  ; A window's title can contain WinTitle anywhere inside it to be a match
; 		CoordMode, Mouse, Screen
; 		SetDefaultMouseSpeed, 0
; 		SetControlDelay, -1
; 		Global ExeBasename
; 		Global VerboseOutput
; 		AwaitModifierKeyup()
; 		ExePID := GetPID(ExeBasename)
; 		Exe_ahk_Id := WinActive(ahk_pid %ExePID%)
; 		Sleep 250
; 		Disable_FFXIV_MouseEvents()
; 		MaxLoops := 25
; 		Loop %MaxLoops% {
; 			Sleep 250
; 			; Send 2 * "Confirm" keypresses
; 			Loop 2 {
; 				ControlSend,, =, ahk_id %Exe_ahk_Id%
; 				Random, RandomSleep, 1000, 2000  ; Random wait
; 				Sleep %RandomSleep%
; 			}
; 			; Send right-arrow keypress
; 			ControlSend,, {Right}, ahk_id %Exe_ahk_Id%
; 			Random, RandomSleep, 50, 250  ; Random wait
; 			Sleep %RandomSleep%
; 			; Send up-arrow keypress
; 			ControlSend,, {Up}, ahk_id %Exe_ahk_Id%
; 			Random, RandomSleep, 50, 250  ; Random wait
; 			Sleep %RandomSleep%
; 			; Send "Confirm" keypress (Begin Game)
; 			ControlSend,, =, ahk_id %Exe_ahk_Id%
; 			GameWinWait := 500
; 			Sleep %GameWinWait%  ; Wait exactly long enough to punch the target on the max-payout spot
; 			; Send "Confirm" keypress (Punch the game)
; 			ControlSend,, =, ahk_id %Exe_ahk_Id%
; 			Random, RandomSleep, 500, 1000  ; Random wait
; 			Sleep %RandomSleep%
; 			; Wait until the "Currency" window disappears (by-itself after a short duration)
; 			Sleep 7500
; 		}
; 		Enable_FFXIV_MouseEvents()
; 		Sleep 1000
; 		Return
; #If


; ------------------------------------------------------------
; ------------------------------------------------------------
; ---                       FUNCTIONS                      ---
; ------------------------------------------------------------
; ------------------------------------------------------------


;
; AwaitModifierKeyup  (function)
;   |-->  Wait until all modifier keys are released
;
AwaitModifierKeyup() {
	KeyWait LAlt    ; Wait for [ Left-Alt ] to be released
	KeyWait LCtrl   ; Wait for [ Left-Control ] to be released
	KeyWait LShift  ; Wait for [ Left-Shift ] to be released
	KeyWait LWin    ; Wait for [ Left-Win ] to be released
	KeyWait RAlt    ; Wait for [ Right-Alt ] to be released
	KeyWait RCtrl   ; Wait for [ Right-Control ] to be released
	KeyWait RShift  ; Wait for [ Right-Shift ] to be released
	KeyWait RWin    ; Wait for [ Right-Win ] to be released
	Sleep 10
}


;
; ClearTooltip  (function)
;   |--> If called with a positive [ %Period% ], wait [ %Period% ] milliseconds, executes [ %Label% ], then repeats (until explicitly cancelled)
;	  |--> If called with a negative [ %Period% ], wait [ %Period% ] milliseconds, executes [ %Label% ], then returns
;
ClearTooltip(Period) {
	Label := "RemoveToolTip"
	SetTimer, %Label%, -%Period%
	Return
}


;
;	Disable_FFXIV_MouseEvents
;   |--> Shorthand command for disabling mouse-moves and mouse-clicks targeted at the FFXIV window
;
Disable_FFXIV_MouseEvents() {
	Global Block_FFXIV_MouseClicks
	Block_FFXIV_MouseClicks := 1
	SetTimer, IfCrafting_BlockMouse, 50
	Return
}


;
;	Enable_FFXIV_MouseEvents
;   |--> Shorthand command for enabling mouse-moves and mouse-clicks targeted at the FFXIV window
;
Enable_FFXIV_MouseEvents() {
	Global Block_FFXIV_MouseClicks
	Block_FFXIV_MouseClicks := 0
	SetTimer, IfCrafting_BlockMouse, Off
	Return
}


;
; Get_ahk_id_from_pid
;   |--> Input: WinPID to Target
;   |--> Returns ahk_id (process-handle) for AHK back-end control-based calls
;
Get_ahk_id_from_pid(WinPid) {
	SetTitleMatchMode, 2 ; Title must CONTAIN [ WinTitle ] as a substring
	ControlGet, output_var, Hwnd,,, ahk_pid %WinPid%
	dat_ahk_id=ahk_id %output_var%
	Return dat_ahk_id
}


;
;	GetPID
;   |--> Returns PID if process IS found
;   |--> Returns 0 if process is NOT found
;
GetPID(ProcName) {
	Process, Exist, %ProcName%
	Return %ErrorLevel%
}


;
;
;  IfCrafting_BlockMouse()
;   |--> Block the mouse from being used while the FFXIV window is active and crafting is occurring
;
IfCrafting_BlockMouse() {
	Global Block_FFXIV_MouseClicks
	Global VerboseOutput
	CoordMode, Mouse, Screen
	MouseGetPos, , , WinID, control
	WinGetClass, WinClass, ahk_id %WinID%
	KillMouseInteraction := 0
	If (WinClass == "FFXIVGAME") {
		If (Block_FFXIV_MouseClicks == 1) {
			Echo_Tooltip := "Block mouse interaction`n |--> In-game & crafting"
			KillMouseInteraction := 1
		} Else {
			Echo_Tooltip := "Allow mouse interaction`n |--> Not currently crafting"
		}
	} Else {
		Echo_Tooltip := "Allow mouse interaction`n |--> Not in Game"
	}
	If (KillMouseInteraction == 1) {
		BlockInput, MouseMove      ;  Kill mouse interaction
		ToolTip, %Echo_Tooltip%
		ClearTooltip(10000)
	} Else {
		BlockInPut, MouseMoveOff   ;  Restore mouse interaction
		If (VerboseOutput > 0) {
			ToolTip, %Echo_Tooltip%
			ClearTooltip(10000)
		}
		; BlockInPut, Off            ;  Restore full interaction
	}
	Return
}


;
; OverlayOff  (function)
;	  |--> Removes overlay from in-front of target window, restoring access to the user
;
OverlayOff(ExeBasename) {
	If (ProcessExist(ExeBasename) == True) {
		ExePID := GetPID(ExeBasename)
		; WinSet, AlwaysOnTop, Off, ahk_pid %ExePID%
		; WinSet, ExStyle, -0x20, ahk_pid %ExePID%
		; WinSet, Transparent, OFF, ahk_pid %ExePID%
	}
	Return
}


;
; OverlayOn  (function)
;	  |--> Creates an overlay which blocks a target window, denying access from the user until it is removed or otherwise closed
;
OverlayOn(ExeBasename) {
	If (ProcessExist(ExeBasename) == True) {
		ExePID := GetPID(ExeBasename)
		; WinSet, AlwaysOnTop, On, ahk_pid %ExePID%
		; WinSet, 	, 80, ahk_pid %ExePID%
		; WinSet, ExStyle, +0x20, ahk_pid %ExePID%
	}
	Return
}


;
;	ProcessExist (proxy-function for GetPID(...))
;   |--> Returns True if process IS found
;   |--> Returns False if process is NOT found
;
ProcessExist(ProcName) {
  Return (GetPID(ProcName)>0) ? True : False
}


;
; RemoveToolTip  (function)
;   |--> Removes any Tooltips found
;
RemoveToolTip() {
	ToolTip
	Return
}


; ------------------------------------------------------------
;
; Citation(s)
;
;   autohotkey.com  |  "How to block mouse input for a named window? - Ask for Help - AutoHotkey Community"  |  https://autohotkey.com/board/topic/29027-how-to-block-mouse-input-for-a-named-window/
;
;   autohotkey.com  |  "WinSet, Disable... not working as expected - Ask for Help - AutoHotkey Community"  |  https://autohotkey.com/board/topic/103478-winset-disable-not-working-as-expected/
;
;   www.autohotkey.com  |  "OnMessage() - Syntax & Usage | AutoHotkey"  |  https://www.autohotkey.com/docs/commands/OnMessage.htm#The_Functions_Parameters
;
;   www.autohotkey.com  |  "WinSet - Syntax & Usage | AutoHotkey"  |  https://www.autohotkey.com/docs/commands/WinSet.htm#Style
;
; ------------------------------------------------------------