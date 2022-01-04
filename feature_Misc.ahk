; A collection of features too small to have their own script.


#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir % A_ScriptDir
#Persistent
#KeyHistory 0
#NoTrayIcon


{ ; Numlock override for builtin laptop keyboard being tiny
  ; ^Pause::Send, {NumLock}
  ; NumLock::Send, {BackSpace}
}

{ ; Media controls
  ; ^!.::Volume_Up
  ; ^!,::Volume_Down
  ^0::Volume_Mute
  ^![::Media_Prev
  ^!]::Media_Next
  ^!Space::
    KeyWait, Space
    Send {Media_Play_Pause}
    Return
}


{ ; Paging for keyboard without page keys
  ; ^Down::
  ;   Send {PgDn}
  ;   Return
  ; ^Up::
  ;   Send {PgUp}
  ;   Return
}
