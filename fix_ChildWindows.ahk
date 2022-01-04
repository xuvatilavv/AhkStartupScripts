; Move new child windows to the same display as their parent window.
;
; Moving certain apps between monitors often leaves them confused as to where
; to spawn their children. Some will use the main window's monitor when first
; launched and not look for changes, some will spawn windows based on the
; location of your cursor, some decide in other ways. All of these can lead to
; undesired  behaviour, so we monitor and kindly move their children for them.

#NoEnv
SendMode Input
SetWorkingDir % A_ScriptDir
#SingleInstance Force
#Persistent
#KeyHistory 0
#NoTrayIcon

#Include lib/WindowUtils.ahk


; Define each managed app as dict in this array.
;
; exeName: The name or pattern to pass to ahk_exe to identify the window.
; moveType: Value indicating where to place the window in the new monitor.
; shouldHandle: A reference to a function that takes a window handle and
;	returns True if that window should be moved, otherwise False.
managedApps := [{exeName: "MusicBee.exe", moveType: WindowMoveType.Center, shouldHandle: Func("Filter_MusicBee")}
	, {exeName: "notepad`+`+.exe", moveType: WindowMoveType.Relative, shouldHandle: Func("Filter_AlwaysMove")}]

; start everything
ManageApps(managedApps)


;;;; Filters

Filter_MusicBee(hwnd) {
	; We don't want to move the new song popup, only larger child windows

	; TODO calculate min dims with window constants, compensate for window scaling
	; ; Reported dimensions of song change popup at 1920x1080 and 100% scale
	; minWinDimensions := {w: 304, h: 94}
	; Instead we use a generous value because sometimes it's larger?
	minWinDimensions := {w: 610, h: 200}

	WinGetPos, , , winWidth, winHeight, ahk_id %hwnd%
	Return (winWidth > minWinDimensions.w && winHeight > minWinDimensions.h)
}


Filter_AlwaysMove(hwnd) {
	Return true
}


;;;; Manage apps

; Start managing a set of apps
ManageApps(managedApps) {
	for i, app in managedApps {
		GroupAdd, managed, % "ahk_exe" app.exeName
		app.prevWindows := {}
	}
	Loop {
		WinWait, ahk_group managed
		While WinExist(ahk_group managed) {
			Sleep, 100
			for i, app in managedApps {
				; windows == N == matching window count
				; creates windows1 to windowsN, sorted top to bottom
				; TODO call for all windows and filter manually? how expensive are system calls?
				WinGet, windows, List, % "ahk_exe" app.exeName
				if (windows <= 1) {
					; we don't track the main window
					if (app.prevWindows.Count() != 0) {
						app.prevWindows := {}
					}
					Continue
				}

				; Assume the bottom window is the main app window, and that
				; it won't move monitors while we're testing its children.
				mainCenter := GetWindowCenterGlobalCoords(windows%windows%)
				monMain := GetMonitorContainingCoords(mainCenter.x, mainCenter.y)
				
				; Convert pseudo-array to object array so we can pass it around
				curWindows := {}
				newWindowsFiltered := {}				
				; ignore bottom window
				Loop % windows - 1 {
					win := windows%A_Index%
					curWindows[win] := 0
					; Only move new windows, and exclude undesired windows
					; using their filter callback.
					if (!app.prevWindows.HasKey(win) && app.shouldHandle.Call(win)) {
						newWindowsFiltered[win] := 0
					}
				}

				MoveWindowsToMonitor(newWindowsFiltered, monMain, app.moveType)
				; Object ref rather than clone avoids unnecessary allocation.
				app.prevWindows := curWindows
			}
		}
	}
}
