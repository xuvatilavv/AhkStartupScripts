; Windows Help windows (e.g. AHK help docs) often launch with the single window
; spanning the full width of all my monitors, regardless of any previous state.
; This script detects that condition on app launch and rescales it to
; fullscreen on the primary monitor.
;
; A convenience hotkey for global search in that window is also included.
; (this bit may only apply to AHK docs)

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir % A_ScriptDir
#Persistent
#KeyHistory 0
#NoTrayIcon
CoordMode, Mouse, Client
SetWinDelay, 0
DetectHiddenWindows, On

Loop {
  WinWait, ahk_exe hh.exe
  WinGetPos, x, y, w, h
  If (w > A_ScreenWidth) {
    SysGet, primIdx, MonitorPrimary
    SysGet, primBounds, Monitor, primIdx
    WinMove, ahk_exe hh.exe, , %primBoundsLeft%, %primBoundsTop%, A_ScreenWidth, A_ScreenHeight
  }
  WinMaximize
  WinWaitClose, ahk_exe hh.exe
}

#IfWinActive, ahk_exe hh.exe
; Hotkey for new global search
^+f::
  Send, !s
  Sleep, 50
  Send, ^a
  Return
