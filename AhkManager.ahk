; A manager to handle multiple AHK scripts on startup.
;
; Will start all managed scripts, and close them when this script exits.
; Intended to manage many separate scripts with no icons to avoid cluttering
; the system tray.

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir % A_ScriptDir
#Persistent
#KeyHistory 0
Menu, Tray, Icon, icons/AhkManager.ico

; List of paths to scripts/apps this script should manage. Intended for AHK
; scripts but can really be anything.
managedApps := ["fix_WindowsHelp.ahk"
  , "fix_ChildWindows.ahk"
  , "fix_MicrosoftEdgeExists.ahk"
  , "fix_Misc.ahk"
  , "feature_Typography.ahk"
  , "feature_Misc.ahk"
  , "feature_IdaBackups.ahk"]



managedPids := []
OnExit("ExitCleanup")
LaunchManagedApps()


LaunchManagedApps() {
  global managedApps, managedPids
  for i, name in managedApps {
    Run, % name, A_ScriptDir, , newPid
    managedPids.Push(newPid)
  }
}

ExitCleanup(exitReason, exitCode) {
  CloseManagedApps()
  ; ; TODO catch non-managed AHK instances, which may include managed scripts
  ; ; that were reloaded externally.
  ; ; see https://www.autohotkey.com/board/topic/95550-how-to-get-a-list-of-autohotkey-scripts-running/
  ; for script in GetRunningScripts() ; any remaining unmanaged processes
  ;   if script == self
  ;     continue
  ;   if managedApps contains script or PromptUser() == Close
  ;     Process, Close, script
  RefreshSystemTray()
}

CloseManagedApps() {
  global managedPids
  for i, pid in managedPids {
    Process, Close, % pid
  }
}

; RefreshSystemTray by Noesis, masato, and neogna2 on the AHK forums,
; renamed from Tray_Refresh for consistency.
; Found at https://www.autohotkey.com/boards/viewtopic.php?p=156072&sid=98ca62c3acb93bacb0d56e3ca2c1ade9#p156072
; with modifications at https://www.autohotkey.com/boards/viewtopic.php?p=205925&sid=98ca62c3acb93bacb0d56e3ca2c1ade9#p205925
RefreshSystemTray() {
/*		Remove any dead icon from the tray menu
 *		Should work both for W7 & W10
 */
	WM_MOUSEMOVE := 0x200
	detectHiddenWin := A_DetectHiddenWindows
	DetectHiddenWindows, On

	allTitles := ["ahk_class Shell_TrayWnd"
			, "ahk_class NotifyIconOverflowWindow"]
	allControls := ["ToolbarWindow321"
				, "ToolbarWindow322"
				, "ToolbarWindow323"
				, "ToolbarWindow324"
				, "ToolbarWindow325"
				, "ToolbarWindow326"]
	allIconSizes := [24,32]

	for id, title in allTitles {
		for id, controlName in allControls
		{
			for id, iconSize in allIconSizes
			{
				ControlGetPos, xTray,yTray,wdTray,htTray,% controlName,% title
				y := htTray - 10
				While (y > 0)
				{
					x := wdTray - iconSize/2
					While (x > 0)
					{
						point := (y << 16) + x
						PostMessage,% WM_MOUSEMOVE, 0,% point,% controlName,% title
						x -= iconSize/2
					}
					y -= iconSize/2
				}
			}
		}
	}

	DetectHiddenWindows, %detectHiddenWin%
}
