; A collection of fixes too small to have their own script.

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir % A_ScriptDir
#Persistent
#KeyHistory 0
#NoTrayIcon


; Sleep key is problems and should go away
Sleep::return

; No more accidental calls in Discord DMs
#IfWinActive ahk_exe Discord.exe
^'::Send "
