#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Fileversion=0.1.0.1
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <File.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

_Log("Start")

$ScriptName = "NTFSReport"
$ScanDirectory = @ScriptDir
$ReportPath = @ScriptDir&"\"&$ScriptName&".html"

_Log("GUICreate")
$Form1 = GUICreate($ScriptName, 488, 217, 261, 244)

$Label1 = GUICtrlCreateLabel("Scan Directory", 24, 8, 74, 17)
$iScanDirectory = GUICtrlCreateInput($ScanDirectory, 24, 32, 361, 21)
$bScanBrowse = GUICtrlCreateButton("Browse", 392, 32, 75, 25)

$Label2 = GUICtrlCreateLabel("Save Report To", 24, 80, 80, 17)
$iReportPath = GUICtrlCreateInput($ReportPath, 24, 104, 361, 21)
$bReportBrowse = GUICtrlCreateButton("Browse", 392, 104, 75, 25)

$bGenerate = GUICtrlCreateButton("Generate", 392, 176, 75, 25)
GUISetState(@SW_SHOW)

_Log("MainLoop")
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit

		Case $bScanBrowse
			_Log("$bScanBrowse")
			$ScanDirectory = GUICtrlRead ($iScanDirectory)
			$ScanDirectory = FileSelectFolder ( $ScriptName&" - Select Directory", $ScanDirectory, 0, "", $Form1)
			GUICtrlSetData ( $iScanDirectory, $ScanDirectory)

		Case $bReportBrowse
			_Log("$bReportBrowse")
			$ReportPath = GUICtrlRead ($iReportPath)
			$ReportPath = FileSaveDialog ( $ScriptName&" - Save Report", $ReportPath, "HTML file (*.html)", $FD_PROMPTOVERWRITE , $ScriptName&".html", $Form1)
			GUICtrlSetData ( $iReportPath, $ReportPath)

		Case $bGenerate
			_Log("$bGenerate")
			$aFiles = _FileListToArrayRec($ScanDirectory, "*", $FLTAR_FOLDERS, $FLTAR_RECUR)
			_Log("_FileWriteFromArray")
			_FileWriteFromArray(@DesktopDir&"\files.txt", $aFiles, 1)
			_Log("Done")

			exit

			For $i = 1 To UBound($aFiles) - 1
				$ThisFile = $ScanDirectory&$aFiles[$i]
				_Log("$ThisFile = " & $ThisFile)

				for $z = 1 to 100


					;if StringInStr(,)


				next

			Next

	EndSwitch

	sleep(10)
WEnd

Func _Log($message)
	Local $sTime=@YEAR&"-"&@MON&"-"&@MDAY&" "&@HOUR&":"&@MIN&":"&@SEC&"> " ; Generate Timestamp
	ConsoleWrite(@CRLF&$sTime&$message)
	Return $message
Endfunc



