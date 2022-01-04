; Kill Microsoft Edge on launch, open non-inane URLs in preferred app instead.
;
; Workaround for Windows forcing Edge to be used for certain links (e.g. microsoft-edge://)
; and to prevent web searches opening due to  errant system searches.
;
; WARNING: If you have Edge configured as the default app for a URL type
; (e.g. ftp://) this may cause an infinite loop! Add an exception to the 
; FilterUrls function or change your default app!

#NoEnv
SendMode Input
SetWorkingDir % A_ScriptDir
#SingleInstance Force
#Persistent
#KeyHistory 0
DetectHiddenText, On
DetectHiddenWindows, On
SetWinDelay, 0

#Include lib/GetBrowserUrl.ahk
Menu, Tray, Icon, icons/fix_MicrosoftEdgeExists.ico

Loop {
	WinWaitActive, ahk_exe msedge.exe
	WinGet, winId
	WinHide

	loop 50 {
		url := GetActiveBrowserURL()
		if (url != "") {
			break
		}
		Sleep 10
	}

	WinActivate, ahk_id %winId%
	Send, ^w ; Close the tab that just opened
	WinKill

	url := FilterUrls(url)
	if (url != "") {
		; Open the URL in the proper default app
		Run % url
	}

	WinWaitClose, ahk_exe msedge.exe
}


FilterUrls(url) {
	; TODO determine other URL issues that may arise
	filtered := RegExReplace(url, "^microsoft-edge://", "https://", , 1)
	if RegExMatch(url, "^https?:\/\/(www\.)?bing\.com")
		return ""
	return filtered
}
