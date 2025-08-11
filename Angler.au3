#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=icon.ico
#AutoIt3Wrapper_outfile=Angler.exe
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <WindowsConstants.au3>
#include <GUIConstants.au3>
#include <ScreenCapture.au3>

#region Global Declarations
Global $BobberColor,$SplashColor,$BobberIsSet=0,$SplashIsSet=0,$Loop=0,$Timer,$BaitTimer,$ExitTimer
Global $SSPath = @Scriptdir & "\data\ScreenCap.bmp"
Global $INIFile = @ScriptDir & "\data\Settings.ini"
Global $UseTimer=4,$HearthOnTimer=4,$TimerMinutes=60
;==>Customizable Settings
;Settings Section
Global $BaitInterval = IniRead($INIFile,"Settings","BaitTimer","10")
Global $UseBait = IniRead($INIFile,"Settings","UseBait","4")
Global $WoWWindow = IniRead ($INIFile, "Settings", "WoWWinTitle", "World of Warcraft")
Global $MaxTime = IniRead($INIFile, "Settings", "MaxTime", "20")
Global $Font = IniRead($INIFile, "Settings", "Font", "Matisse ITC")
Global $WinTitle = IniRead($INIFile, "Settings","AnglerTitleBar","")
Global $CollectTrash = IniRead($INIFile,"Settings","CollectTrash","4")
;Hotkeys Section
Global $FishKey = IniRead($INIFile, "Hotkeys", "FishKey", "^0")
Global $Trash1 = IniRead($INIFile,"HotKeys", "Trash1","^9")
Global $Trash2 = IniRead($INIFile,"HotKeys", "Trash2","^8")
Global $Trash3 = IniRead($INIFile,"HotKeys", "Trash3","^7")
Global $HearthKey = IniRead($INIFile,"HotKeys","Hearth","^6")
SetHK()
#endregion
TraySetIcon(@ScriptDir&"\icon.ico")
$GUI = GUICreate($WinTitle,200,255)
GUISetBkColor(0x000000)
GUISetFont(12, 800, 0, $Font)
$BobberLabel = GUICtrlCreateLabel("F1:",1,3,20,25)
GUICtrlSetColor($BobberLabel,0xFFFFFF)
$BobberColorInput = GUICtrlCreateInput("Bobber Color",21,1,80,25)
GUICtrlSetFont($BobberColorInput,12,200)
GUICtrlSetBkColor($BobberColorInput,0x222222)
GUICtrlSetColor($BobberColorInput,0xFFFFFF)
$SplashLabel = GUICtrlCreateLabel("F2:",100,3,20,25)
GUICtrlSetColor($SplashLabel,0xFFFFFF)
$SplashColorInput = GUICtrlCreateInput("Splash Color",121,1,80,25)
GUICtrlSetFont($SplashColorInput,12,200)
GUICtrlSetBkColor($SplashColorInput,0x222222)
GUICtrlSetColor($SplashColorInput,0xFFFFFF)
FileInstall ("C:\Users\YOUR_USER\Dropbox\projects\Angler\res\DefaultCap.bmp", @TempDir & "\DefaultCap.bmp", 1) ;Default Welcome Image
$SSCap=GUICtrlCreatePic(@TempDir & "\DefaultCap.bmp",1,25,200,200)
$StartButton = GUICtrlCreateButton("Why hello there!",1,225,150,30)
GUICtrlSetBkColor($StartButton,0x999999)
GUICtrlSetColor($StartButton,0x000000)
$OptionsButton = GUICtrlCreateButton("Opt",150,225,50,30)
GUICtrlSetBkColor($OptionsButton,0x111111)
GUICtrlSetColor($OptionsButton,0xFFFFFF)
GUISetState(@SW_Show)
If Not FileExists(@ScriptDir & "\data\Settings.ini") Then
	DirCreate(@ScriptDir & "\data")
	FileWrite(@ScriptDir & "\data\ScreenCap.bmp","")
	FileWrite(@ScriptDir & "\data\Settings.ini","")
	MsgBox(0,"Options Setup","Take a moment to set up the options. " & @CRLF & "You can just click the green Save button for default settings." & _
		@CRLF & @CRLF & "                                  -Eru")
	Options()
EndIf
While 1
	GUI()
	Sleep(50)
WEnd

Func GUI()
	$Msg = GUIGetMsg()
	Select
		Case $Msg = $GUI_EVENT_CLOSE
			Exit
		Case $Msg = $StartButton
			If $BobberIsSet = 0 or $SplashIsSet = 0 Then
				GUICtrlSetData($StartButton,"Set Colors First")
				GUICtrlSetBkColor($StartButton,0xAAAA00)
			ElseIf Not WinExists($WoWWindow) Then
				GUICtrlSetData($StartButton,"Start WoW First")
				GUICtrlSetBkColor($StartButton,0xAAAA00)
			ElseIf $Loop = 0 Then
				$Loop = 1
				GUICtrlSetData($StartButton,"Take a break")
				TraySetIcon(@ScriptDir & "/icons/green.ico")
				GUICtrlSetBkColor($StartButton,0x990000)
				FishBot()
			ElseIf $Loop = 1 Then
				$Loop = 0
				TraySetIcon(@ScriptDir & "/icons/red.ico")
				GUICtrlSetData($StartButton,"Back to Fishin'!")
				GUICtrlSetBkColor($StartButton,0x009900)
			EndIf
		Case $MSG = $OptionsButton
			Options()
	EndSelect
EndFunc

#region Main Bot Section
Func FishBot()
	;Begin Timer Setup
	If $UseBait = 1 Then
		Send("{ShiftDown}" & $FishKey & "{ShiftUp}")
		$BaitTimer = TimerInit()
	EndIf
	If $UseTimer = 1 Then $ExitTimer = TimerInit()
	;End Timer Setup
    WinActivate($WoWWindow)
    WinWaitActive($WoWWindow)
	Local $WindowSize = WingetPos($WoWWindow)
	Local $Left = $WindowSize[0] + 5 + $WindowSize[2]*.05  ;5 px border + buffer area
	Local $Top = $WindowSize[1] + 25  + $WindowSize[3] * .15 ;25 px titlebar
	Local $Right = ($WindowSize[0] + $WindowSize[2]) * .88
	Local $Bottom = ($WindowSize[1] + $WindowSize[3]) * .7 ;Ignores very bottom of screen (chat/hotkeys,etc)
    MouseMove($Left, $Top, 7) ; draws out the area with pixels being checked.
    MouseMove($Right, $Top, 7)
    MouseMove($Right, $Bottom, 7)
    MouseMove($Left, $Bottom, 7)
	Sleep(3000)
    Do
        While $Loop = 1
			If TimerDiff($BaitTimer) > $BaitInterval *60 *1000 Then
				Send("{ShiftDown}" & $FishKey & "{ShiftUp}")
				$BaitTimer = TimerInit()
			EndIf
			If $UseTimer = 1 And TimerDiff($ExitTimer) > $TimerMinutes * 60 * 1000 Then
				If $HearthOnTimer = 1 Then Send($HearthKey)
				Exit
			EndIf
			If $CollectTrash = 1 Then DeleteTrash()
			$Timer = TimerInit()
            Send($FishKey)
			Sleep(1000)
            If $Loop = 1 Then
                Do
                    GUI()
                    Sleep (5)
                    Local $BobberPos = PixelSearch($Left, $Top, $Right, $Bottom, $BobberColor, 10, 3)
					CheckTimer(@error)
                Until @error <> 1
            Else
                ExitLoop
            EndIf
            If IsArray($BobberPOS) AND $Loop = 1 Then
                MouseMove ($BobberPos[0], $BobberPos[1], 5)
                Sleep (500)
                MouseMove ($BobberPos[0] + 100, $BobberPos[1] + 100, 5)
                $SLeft = $BobberPos[0] - 35
                $SRight = $SLeft + 60
                $STop = $BobberPos[1] - 35
                $SBottom = $STop + 65
            Else
                ExitLoop
            EndIf
            If $Loop = 1 Then
                Do
                    GUI()
                    Sleep (5)
                    $SplashPos = PixelSearch($SLeft, $STop, $Sright, $SBottom, $SplashColor, 20, 2)
                    CheckTimer(@error)
                Until @error <> 1
            Else
                ExitLoop
            EndIf
            If IsArray($SplashPos) Then Mouseclick ("Right", $BobberPos[0], $BobberPos[1], 1, 0)
                Sleep (3000)
        WEnd
    Until $Loop = 0
EndFunc

Func DeleteTrash()
	Send($Trash1)
	Send($Trash2)
	Send($Trash3)
EndFunc

Func CheckTimer($PixelError)
    If TimerDiff($Timer) >= $MaxTime * 1000 Then
        SetError(0)
        Return -1
    EndIf
    SetError($PixelError)
EndFunc ;==> CheckTimer
#endregion

#region GUI & Bot Setup Functions
Func HKBobberSet()
    Local $Position = MouseGetPos()
    Local $HKColor = PixelgetColor($Position[0], $Position[1])
    GuiCtrlSetData($BobberColorInput, Hex($HKColor))
    GUICtrlSetBkColor($BobberColorInput, $HKColor)
	GUICtrlSetColor($BobberColorInput,0xFFFFFF-$HKColor)
    $BobberColor = $HKColor
	$BobberIsSet = 1
	SetupCheck()
EndFunc ;==>HKBobberSet

Func HKSplashSet()
    Local $Position = MouseGetPos()
    Local $HKColor = PixelGetColor($Position[0], $Position[1])
    GuiCtrlSetData($SplashColorInput, Hex($HKColor))
    GuiCtrlSetBKColor($SplashColorInput, $HKColor)
	GUICtrlSetColor($SplashColorInput,0xFFFFFF-$HKColor)
    $SplashColor = $HKColor
	$SplashIsSet = 1
	SetupCheck()
EndFunc ;==>HKSplashSet

Func SetupCheck()
	If $SplashIsSet = 1 And $BobberIsSet = 1 Then
		GUICtrlSetBkColor($StartButton,0x009900)
		GUICtrlSetData($StartButton,"Get to Fishin'!")
	EndIf
EndFunc

Func SSCapture()
    Local $SSPosition = MouseGetPos()
    Local $SSPositionTLX = $SSPosition[0] - 100
    Local $SSPositionTLY = $SSPosition[1] - 100
    Local $SSPositionBRX = $SSPosition[0] + 100
    Local $SSPositionBRY = $SSPosition[1] + 100
    _ScreenCapture_Capture ($SSpath, $SSPositionTLX, $SSPositionTLY, $SSPositionBRX, $SSPositionBRY, False)
    Sleep (1000)
    GUICtrlSetImage ($SSCap, $SSPath)
EndFunc ;==>SSCapture
#endregion

#region Program Startup:  GUI & HK Setup
Func SetHK()
    Local $StartCHK1 = IniRead($INIFile, "Hotkeys", "Start", "{Home}")
    Local $StopCHK = IniRead($INIFile, "Hotkeys", "Stop", "{End}")
	HotKeySet ("{F4}","SSCapture")
    HotKeySet ("{F1}","HKBobberSet")
    HotKeySet ("{F2}","HKSplashSet")
    HotKeySet ($StopCHK , "StopLoop")
    HotKeySet ($StartCHK1 , "BotHK")
EndFunc ;==> SetHK

Func BotHK()
	If $BobberIsSet = 0 or $SplashIsSet = 0 Then
		GUICtrlSetData($StartButton,"Set Colors First")
		GUICtrlSetBkColor($StartButton,0xAAAA00)
	ElseIf Not WinExists($WoWWindow) Then
		GUICtrlSetData($StartButton,"Start WoW First")
		GUICtrlSetBkColor($StartButton,0xAAAA00)
	ElseIf $Loop = 0 Then
		$Loop = 1
		GUICtrlSetData($StartButton,"Take a break")
		TraySetIcon(@ScriptDir & "/icons/green.ico")
		GUICtrlSetBkColor($StartButton,0x990000)
		FishBot()
	EndIf
EndFunc

Func StopLoop()
	If $Loop = 1 Then
		$Loop = 0
		TraySetIcon(@ScriptDir & "/icons/red.ico")
		GUICtrlSetData($StartButton,"Back to Fishin'!")
		GUICtrlSetBkColor($StartButton,0x009900)
	EndIf
EndFunc
#endregion

#region Options
Func Options()
	Local $AnglerPosition = WinGetPos($WinTitle)
	Local $OptionsGUI = GUICreate("Options",205,200,$AnglerPosition[0],$AnglerPosition[1]+45,$WS_Popup,$WS_EX_TOPMOST)
	GUISetBkColor(0x000000)
	Local $UseBaitCheckbox = GUICtrlCreateCheckbox("",0,0,15,20)
	GUICtrlSetState($UseBaitCheckbox,IniRead($INIFile,"Settings","UseBait","4")) ;1 True 4 False
	Local $BaitLabel1 = GUICtrlCreateLabel("Use bait every",15,2,70,20)
	GUICtrlSetColor($Baitlabel1,0x999999)
	GUICtrlSetColor($UseBaitCheckbox,0xFFFFFF)
	Local $BaitTimer = GUICtrlCreateInput(IniRead($INIFile,"Settings","BaitTimer","10"),85,0,25,18)
	GUICtrlSetBkColor($BaitTimer,0x222222)
	GUICtrlSetColor($BaitTimer,0xFFFFFF)
	Local $BaitLabel2 = GUICtrlCreateLabel("minutes | StopHK:",111,2,100,20)
	GUICtrlSetColor($Baitlabel2,0x999999)
	Local $CollectTrashCheckbox = GUICtrlCreateCheckbox("",70,58,15,15)
	GUICtrlSetState($CollectTrashCheckbox,IniRead($INIFile,"Settings","CollectTrash","4"))
	Local $TrashLabel = GUICtrlCreateLabel("Destroy Garbage Items",85,58,120,20)
	GUICtrlSetColor($TrashLabel,0x999999)
	Local $UseTimerCheckbox = GUICtrlCreateCheckbox("",0,80,13,13)
	GUICtrlSetState($UseTimerCheckbox,$UseTimer)
	Local $TimerLabel1 = GUICtrlCreateLabel("Exit",13,80,17,20)
	Local $HearthOnTimerCheckbox = GUICtrlCreateCheckbox("",30,80,13,13)
	GUICtrlSetState($HearthOnTimerCheckbox,$HearthOnTimer)
	Local $TimerLabel2 = GUICtrlCreateLabel("and Hearth",43,80,53,20)
	Local $TimerLabel3 = GUICtrlCreateLabel("after",98,80,22,20)
	Local $TimerMinutesInput = GUICtrlCreateInput($TimerMinutes,120,77,45,20)
	Local $TimerLabel4 = GUICtrlCreateLabel("minutes.",165,80,42,20)
	GUICtrlSetColor($TimerLabel1,0x999999)
	GUICtrlSetColor($TimerLabel2,0x999999)
	GUICtrlSetColor($TimerLabel3,0x999999)
	GUICtrlSetColor($TimerLabel4,0x999999)
	GUICtrlSetColor($TimerMinutesInput,0xFFFFFF)
	GUICtrlSetBkColor($TimerMinutesInput,0x222222)
	;Hotkey Labels
	Local $HKLabel1 = GUICtrlCreateLabel("-=(Hotkeys)=-  StartHK:",0,23,110,20)
	Local $HKLabel2 = GUICtrlCreateLabel("Fishing:",0,40,35,20)
	Local $HKLabel3 = GUICtrlCreateLabel("Trash:",70,40,30,20)
	Local $HKLabel4 = GUICtrlCreateLabel("Hearth:",0,60,35,20)
	;Hotkey Inputs
	Local $StartHKInput = GUICtrlCreateInput(IniRead($INIFile, "HotKeys", "Start", "{Home}"),110,21,45,18)
	Local $StopHKInput = GUICtrlCreateInput(IniRead($INIFile, "HotKeys", "Stop", "{End}"),155,21,45,18)
	Local $FishKeyInput = GUICtrlCreateInput(IniRead($INIFile, "HotKeys", "FishKey", "^0"),35,38,35,18)
	Local $Trash1Input = GUICtrlCreateInput(IniRead($INIFile,"HotKeys", "Trash1","^9"),100,38,33,18)
	Local $Trash2Input = GUICtrlCreateInput(IniRead($INIFile,"HotKeys", "Trash2","^8"),133,38,33,18)
	Local $Trash3Input = GUICtrlCreateInput(IniRead($INIFile,"HotKeys", "Trash3","^7"),166,38,33,18)
	Local $HearthInput = GUICtrlCreateInput(IniRead($INIFile,"HotKeys","Hearth","^6"),36,58,33,18)
	GUICtrlSetColor($HKLabel1,0x999999)
	GUICtrlSetColor($HKLabel2,0x999999)
	GUICtrlSetColor($HKLabel3,0x999999)
	GUICtrlSetColor($HKLabel4,0x999999)
	GUICtrlSetColor($Trash1Input,0xFFFFFF)
	GUICtrlSetColor($Trash2Input,0xFFFFFF)
	GUICtrlSetColor($Trash3Input,0xFFFFFF)
	GUICtrlSetColor($StartHKInput,0xFFFFFF)
	GUICtrlSetColor($StopHKInput,0xFFFFFF)
	GUICtrlSetColor($HearthInput,0xFFFFFF)
	GUICtrlSetColor($FishKeyInput,0xFFFFFF)
	GUICtrlSetBkColor($HearthInput,0x222222)
	GUICtrlSetBkColor($Trash1Input,0x222222)
	GUICtrlSetBkColor($Trash2Input,0x222222)
	GUICtrlSetBkColor($Trash3Input,0x222222)
	GUICtrlSetBkColor($StartHKInput,0x222222)
	GUICtrlSetBkColor($StopHKInput,0x222222)
	GUICtrlSetBkColor($FishKeyInput,0x222222)
	;Advanced Settings
	Local $AdvancedLabel = GUICtrlCreateLabel("              -=(Advanced Settings)=-",1,100,200,20)
	GUICtrlSetColor($AdvancedLabel,0x999999)
	Local $WoWWinOptLabel = GUICtrlCreateLabel("TargetWindow:",1,115,80,20)
	GUICtrlSetColor($WoWWinOptLabel,0x999999)
	Local $WoWWinOpt = GUICtrlCreateInput(IniRead ($INIFile, "Settings", "WoWWinTitle", "World of Warcraft"),76,113,130,18)
	GUICtrlSetColor($WoWWinOpt,0xFFFFFF)
	GUICtrlSetBkColor($WoWWinOpt,0x222222)
	Local $MaxTimeLabel = GUICtrlCreateLabel("MaxCastTime:",0,132,70,20)
	GUICtrlSetColor($MaxTimeLabel,0x999999)
	Local $MaxTimeInput = GUICtrlCreateInput(IniRead($INIFile, "Settings", "MaxTime", "20"),70,130,40,18)
	GUICtrlSetColor($MaxTimeInput,0xFFFFFF)
	GUICtrlSetBkColor($MaxTimeInput,0x222222)
	Local $MaxTimeLabel2 = GUICtrlCreateLabel("sec.",111,132,20,20)
	GUICtrlSetColor($MaxTimeLabel2,0x999999)
	Local $TitleBarLabel = GUICtrlCreateLabel("TitleBar:",0,148,40,20)
	GUICtrlSetColor($TitleBarLabel,0x999999)
	Local $TitleBarInput = GUICtrlCreateInput(IniRead($INIFile, "Settings","AnglerTitleBar",""),40,146,165,17)
	GUICtrlSetColor($TitleBarInput,0xFFFFFF)
	GUICtrlSetBkColor($TitleBarInput,0x222222)
	Local $FontLabel = GUICtrlCreateLabel("Font:",0,165,30,20)
	GUICtrlSetColor($FontLabel,0x999999)
	Local $FontInput = GUICtrlCreateInput(IniRead($INIFile, "Settings", "Font", "Matisse ITC"),30,163,150,17)
	GUICtrlSetColor($FontInput,0xFFFFFF)
	GUICtrlSetBkColor($FontInput,0x222222)
	;Buttons
	Local $OptionsSave = GUICtrlCreateButton("Save",120,180,80,20)
	GUICtrlSetBkColor($OptionsSave,0x009900)
	GUICtrlSetColor($OptionsSave,0x000000)
	Local $OptionsCancel = GUICtrlCreateButton("Cancel",0,180,80,20)
	GUICtrlSetBkColor($OptionsCancel,0x990000)
	GUICtrlSetColor($OptionsCancel,0x000000)
	Local $HelpButton = GUICtrlCreateButton("Help!",80,180,40,20)
	GUICtrlSetColor($HelpButton,0x000000)
	GUICtrlSetBkColor($HelpButton,0x999900)
	GUISetState(@SW_SHOW)

	While 1
		$Msg = GUIGetMsg()
		Select
			Case $Msg = $OptionsCancel
				GUIDelete($OptionsGUI)
				ExitLoop
			Case $Msg = $HelpButton
				ShellExecute("http://DEAD.DOMAIN/tenement/viewtopic.php?pid=28#p28")
			Case $Msg = $OptionsSave
				#region SaveOptions
				IniWrite($INIFile,"Settings","BaitTimer",GUICtrlRead($BaitTimer))
				$BaitInterval = GUICtrlRead($BaitTimer)
				IniWrite($INIFile,"Settings","UseBait",GUICtrlRead($UseBaitCheckbox))
				$UseBait = GUICtrlRead($UseBaitCheckbox)
				IniWrite($INIFile,"Hotkeys","Start",GUICtrlRead($StartHKInput))
				HotKeySet (GUICtrlRead($StartHKInput),"BotHK")
				IniWrite($INIFile,"Hotkeys","Stop",GUICtrlRead($StopHKInput))
				HotKeySet(GUICtrlRead($StopHKInput),"StopLoop")
				IniWrite($INIFile,"Hotkeys","FishKey",GUICtrlRead($FishKeyInput))
				$FishKey=GUICtrlRead($FishKeyInput)
				IniWrite($INIFile,"Hotkeys","Trash1",GUICtrlRead($Trash1Input))
				IniWrite($INIFile,"Hotkeys","Trash2",GUICtrlRead($Trash2Input))
				IniWrite($INIFile,"Hotkeys","Trash3",GUICtrlRead($Trash3Input))
				IniWrite($INIFile,"HotKeys","Hearth",GUICtrlRead($HearthInput))
				IniWrite($INIFile,"Settings","WoWWinTitle",GUICtrlRead($WoWWinOpt))
				IniWrite($INIFile,"Settings","MaxTime",GUICtrlRead($MaxTimeInput))
				IniWrite($INIFile,"Settings","AnglerTitleBar",GUICtrlRead($TitleBarInput))
				IniWrite($INIFile,"Settings","Font",GUICtrlRead($FontInput))
				$Trash1 = GUICtrlRead($Trash1Input)
				$Trash2 = GUICtrlRead($Trash2Input)
				$Trash3 = GUICtrlRead($Trash3Input)
				$HearthKey = GUICtrlRead($HearthInput)
				IniWrite($INIFile,"Settings","CollectTrash",GUICtrlRead($CollectTrashCheckbox))
				$CollectTrash = GUICtrlRead($CollectTrashCheckbox)
				$UseTimer=GUICtrlRead($UseTimerCheckbox)
				$HearthOnTimer=GUICtrlRead($HearthOnTimerCheckbox)
				$TimerMinutes=GUICtrlRead($TimerMinutesInput)
				$WoWWindow = GUICtrlRead($WoWWinOpt)
				$MaxTime = GUICtrlRead($MaxTimeInput)
				#endregion
				GUIDelete($OptionsGUI)
				Exitloop
		EndSelect
	WEnd
EndFunc
#endregion