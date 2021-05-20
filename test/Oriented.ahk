;============ Auto-Execute ====================================================;
;======================================================  Setting  ==============;

#SingleInstance
#Warn All, MsgBox
#Warn LocalSameAsGlobal, Off

ProcessSetPriority("Normal")

;======================================================  Include  ==============;

#Include %A_ScriptDir%\..\..\Core.ahk

#Include %A_ScriptDir%\..\..\Assert\Assert.ahk
#Include %A_ScriptDir%\..\..\Console\Console.ahk

;======================================================== Test ================;
;--------------------------------------------------------  Log  ----------------;
Console.Log(Assert.CreateReport())

exit

;=============== Hotkey =======================================================;

#HotIf (WinActive(A_ScriptName) || WinActive("ObjectOriented.ahk"))

	$F10:: {
		ListVars
	}

	~$^s:: {
		Critical(True)

		Sleep(200)
		Reload
	}

#HotIf