; Function library for working with windows.


; We'll pretend this is an enum.
WindowMoveType := {Center: 1, Relative: 2}


GetMonitorContainingCoords(x, y) {
	SysGet, monCount, MonitorCount
	Loop, %monCount% {
		SysGet, monBounds, MonitorWorkArea, %A_Index%
		; MsgBox, , % Format("{1} - {2}", "mon %A_Index% x %monBoundsLeft% y %MonBoundsRight% t %monBoundsTop% b %monBoundsBottom% test x %x% y %y%"
		if (x >= monBoundsLeft && x < monBoundsRight && y >= monBoundsTop && y < monBoundsBottom) {
			Return %A_Index%
		}
	}
	Return -1
}


GetMonitorCenterCoords(monIndex) {
	if (monIndex < 0) {
		MsgBox, , % Format("{1} - {2}", A_ScriptName, A_ThisFunc), % Format("Invalid target monitor: {1}", monIndex)
		Return
	}
	SysGet, monBounds, MonitorWorkArea, %monIndex%
	Return {x: ((monBoundsRight - monBoundsLeft) // 2) + monBoundsLeft
		, y: ((monBoundsBottom - monBoundsTop) // 2) + monBoundsTop}
}


GetWindowCenterGlobalCoords(hwnd) {
	WinGetPos, x, y, w, h, ahk_id %hwnd%
	Return {x: (x + (w // 2))
		, y: (y + (h // 2))}
}


MoveWindowToMonitorCenter(hwnd, monIndex) {
	if (monIndex < 0) {
		MsgBox, , % Format("{1} - {2}", A_ScriptName, A_ThisFunc), % Format("Invalid target monitor: {1}", monIndex)
		Return
	}
	monCenter := GetMonitorCenterCoords(monIndex)
	WinGetPos, x, y, w, h, ahk_id %hwnd%
	targetX := monCenter.x - (w // 2)
	targetY := monCenter.y - (h // 2)
	; MsgBox, , % Format("{1} - {2}", A_ScriptName, A_ThisFunc), % Format("Moving {1} to x {2} y {3} mx {4} my {5}", hwnd, targetX, targetY, w, y)
	WinMove, ahk_id %hwnd%, , targetX, targetY
}


; Move window to the same position on the target monitor, taking into
; account differing resolution and DPI scaling.
MoveWindowToMonitorRelative(hwnd, monIndex) {
	; TODO
	MoveWindowToMonitorCenter(hwnd, monIndex)
}


; winList: an object array where each key is a HWND (ahk_id), value irrelevant
MoveWindowsToMonitor(winList, targetMonitor, moveType) {
	global WindowMoveType
	for win in winList {
		winCenter := GetWindowCenterGlobalCoords(win)
		winMonitor := GetMonitorContainingCoords(winCenter.x, winCenter.y)

		; ; testing msgbox, ignore
		; MsgBox, , % Format("{1} - {2}", A_ScriptName, "Main")
		; 	, % Format("New id {1} nc.x {2} nc.y {3} nm {4} mm {5}"
		; 	, winId, winCenter.x, winCenter.y, winMonitor, targetMonitor)
		if (winMonitor != targetMonitor) {
			switch moveType {
				case WindowMoveType.Center: 
					MoveWindowToMonitorCenter(win, targetMonitor)
				case WindowMoveType.Relative: 
					MoveWindowToMonitorRelative(win, targetMonitor)
				default: 
					MoveWindowToMonitorCenter(win, targetMonitor)
			}
		}
	}
}

