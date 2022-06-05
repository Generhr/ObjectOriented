#Requires AutoHotkey v2.0-beta

;============ Auto-Execute ====================================================;
;======================================================  Include  ==============;

#Include %A_ScriptDir%\..\..\Core.ahk

#Include %A_ScriptDir%\..\..\Assert\Assert.ahk
#Include %A_ScriptDir%\..\..\Console\Console.ahk

;======================================================  Setting  ==============;

#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off

ListLines(False)
ProcessSetPriority("Normal")

;======================================================== Test ================;
;--------------------------------------------------------  Log  ----------------;

Console.Log(Assert.CreateReport())

exit

;=============== Hotkey =======================================================;

#HotIf (WinActive(A_ScriptName))

	$F10:: {
		ListVars
	}

	~$^s:: {
		Critical(True)

		Sleep(200)
		Reload
	}

#HotIf
