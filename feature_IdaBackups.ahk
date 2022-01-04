; Automatically back up IDA/IDA Pro database files on application close.
;
; IDA seems to require the active database be in the same directory as the
; executable being analysed, which is a problem when working with software
; installed in directories you don't want to back up (Program Files, etc).
; This script will watch for any instance of IDA/IDA64 and wait for it
; close, then copy .idb and .i64 files to a subdirectory in the specified
; location named after the disassembly target.
;
; Note: Expects only one instance of IDA running at a time.

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir % A_ScriptDir
#Persistent
#KeyHistory 0
SetTitleMatchMode Regex
; #NoTrayIcon


; No trailing slash
backupRootDir := A_MyDocuments . "\Projects\RE"
; In addition to the main database. IDB and I64 files are counted separately.
keepBackupsCount := 10

GroupAdd, idaexe, ahk_exe \\ida\.exe$
GroupAdd, idaexe, ahk_exe \\ida64\.exe$


; param filePattern: Not regex, only allows * or ? wildcards
BackupFiles(sourceDir, destDir, filePattern)
{
	; Copy any new database files
	Loop, Files, % sourceDir . "\" . filePattern, F
	{
		needsBackup := True
		curFileName := A_LoopFileName
		curLongPath := A_LoopFileLongPath
		curFileMod := A_LoopFileTimeModified
		Loop, Files, % destDir . "\" . filePattern, F
			if curFileName == A_LoopFileName and not curFileMod > A_LoopFileTimeModified
			{
				needsBackup := False
				break
			}
		if needsBackup
		{
			; 1 = Overwrite
			FileCopy, % curLongPath, % destDir, 1
		}
	}
}


; Sorts by last modified time regardless of filename.
; param filePattern: Not regex, only allows * or ? wildcards
DeleteOldBackups(dir, filePattern, numToKeep)
{
	; Delimiter that is illegal in Windows paths and not special in regex
	illegalFish = "><>"

	; Can't sort arrays directly, so we build a multiline string then convert.
	baks := ""
	Loop, Files, % backupDir . "\" . filePattern, F
		baks .= A_LoopFileTimeModified . illegalFish . A_LoopFileLongPath . "`n"
	; Remove trailing newline
	baks := SubStr(baks, 1, -1)
	Sort baks
	baks := StrSplit(baks, "`n")

	Loop % baks.Count() - keepBackupsCount
	{
		FileDelete % RegExReplace(baks[A_Index], "^.+?" . illegalFish)
	}
}


Loop
{
	; Wait for an appropriate window
	WinWait ^IDA.+?:\\.+\.i(db|64)$ ahk_group idaexe
	WinGetTitle winTitle
	RegExMatch(winTitle, ".:\\.+\.i(db|64)$", idbPath)
	SplitPath, idbPath, mainDbName, idbDir
	; Wait to backup until the app exits
	WinWaitClose ahk_group idaexe

	; Assumes the disassembly target has a 3 letter extension, so databases end with e.g. `.exe.idb`
	backupDir := backupRootDir . "\" . SubStr(mainDbName, 1, -8)
	FileCreateDir backupDir

	BackupFiles(idbDir, backupDir, "*.idb")
	BackupFiles(idbDir, backupDir, "*.i64")

	DeleteOldBackups(backupDir, "*.idb", keepBackupsCount+1)
	DeleteOldBackups(backupDir, "*.i64", keepBackupsCount+1)
}
