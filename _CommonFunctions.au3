;===============================================================================
;DONT FORGET TO UPDATE VERSION NUMBERS AND DATES
;REVISED 2019-05-05
;===============================================================================
#include-once
;#Include <Array.au3>
#include <Security.au3>
#Include <String.au3>
#include <File.au3>

;===============================================================================
;
; Description:
;
; Parameter(s):     Required :
;                   Optional :
; Return Value(s):  On Success -
;                   On Failure -
; Author(s):
;
;===============================================================================
Func _StringExtract($sString, $sStartSearch, $sEndSearch, $iStartTrim = 0, $iEndTrim = 0)
	$iStartPos = StringInStr($sString, $sStartSearch)
	If Not $iStartPos Then Return SetError(1, 0, 0)
	$iStartPos = $iStartPos + StringLen($sStartSearch)

	$iCount = StringInStr($sString, $sEndSearch, 0, 1, $iStartPos)
	If Not $iCount Then Return SetError(2, 0, 0)
	$iCount = $iCount - $iStartPos

	$sNewString = StringMid ( $sString, $iStartPos + $iStartTrim, $iCount + $iEndTrim - $iStartTrim)

	Return $sNewString

EndFunc

;===============================================================================
;
; Description:
;
; Parameter(s):     Required :
;                   Optional :
; Return Value(s):  On Success -
;                   On Failure -
; Author(s):
;
;===============================================================================
Func _WinHTTPRead($sURL, $Agent)
	; Open needed handles
	Local $hOpen = _WinHttpOpen($Agent)
	Local $Connect = StringTrimLeft(StringLeft($sURL,StringInStr($sURL,"/",0,3)-1),7)
	Local $hConnect = _WinHttpConnect($hOpen, $Connect)

	; Specify the reguest:
	Local $RequestURL = StringTrimLeft($sURL,StringInStr($sURL,"/",0,3))
	Local $hRequest = _WinHttpOpenRequest($hConnect, Default, $RequestURL)

	;_WinHttpAddRequestHeaders ($hRequest, "Cache-Control: max-age=0")
	;_WinHttpAddRequestHeaders ($hRequest, "Upgrade-Insecure-Requests: 1")
	_WinHttpAddRequestHeaders ($hRequest, "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3")
	;_WinHttpAddRequestHeaders ($hRequest, "Accept-Encoding: gzip, deflate")
	;_WinHttpAddRequestHeaders ($hRequest, "Accept-Language: en-US,en;q=0.9,en-GB;q=0.8")

	; Send request
	_WinHttpSendRequest($hRequest)

	; Wait for the response
	_WinHttpReceiveResponse($hRequest)

	Local $sHeader = _WinHttpQueryHeaders($hRequest) ; ...get full header

	Local $bData, $bChunk
	While 1
		$bChunk = _WinHttpReadData($hRequest, 2)
		If @error Then ExitLoop
		$bData = _WinHttpBinaryConcat($bData, $bChunk)
	WEnd

	; Clean
	_WinHttpCloseHandle($hRequest)
	_WinHttpCloseHandle($hConnect)
	_WinHttpCloseHandle($hOpen)

	Return $bData

EndFunc

;===============================================================================
;
; Description:      GetUnixTimeStamp - Get time as Unix timestamp value for a specified date
;                   to get the current time stamp call GetUnixTimeStamp with no parameters
;                   beware the current time stamp has system UTC included to get timestamp with UTC + 0
;                   substract your UTC , exemple your UTC is +2 use GetUnixTimeStamp() - 2*3600
; Parameter(s):     Requierd : None
;                   Optional :
;                               - $year => Year ex : 1970 to 2038
;                               - $mon  => Month ex : 1 to 12
;                               - $days => Day ex : 1 to Max Day OF Month
;                               - $hour => Hour ex : 0 to 23
;                               - $min  => Minutes ex : 1 to 60
;                               - $sec  => Seconds ex : 1 to 60
; Return Value(s):  On Success - Returns Unix timestamp
;                   On Failure - No Failure if valid parameters are valid
; Author(s):        azrael-sub7
; User Calltip:     GetUnixTimeStamp() (required: <_AzUnixTime.au3>)
;
;===============================================================================
Func GetUnixTimeStamp($year = 0, $mon = 0, $days = 0, $hour = 0, $min = 0, $sec = 0)
    If $year = 0 Then $year = Number(@YEAR)
    If $mon = 0 Then $mon = Number(@MON)
    If $days = 0 Then $days = Number(@MDAY)
    If $hour = 0 Then $hour = Number(@HOUR)
    If $min = 0 Then $min = Number(@MIN)
    If $sec = 0 Then $sec = Number(@SEC)
    Local $NormalYears = 0
    Local $LeepYears = 0
    For $i = 1970 To $year - 1 Step +1
        If BoolLeapYear($i) = True Then
            $LeepYears = $LeepYears + 1
        Else
            $NormalYears = $NormalYears + 1
        EndIf
    Next
    Local $yearNum = (366 * $LeepYears * 24 * 3600) + (365 * $NormalYears * 24 * 3600)
    Local $MonNum = 0
    For $i = 1 To $mon - 1 Step +1
        $MonNum = $MonNum + MaxDayInMonth($year, $i)
    Next
    Return $yearNum + ($MonNum * 24 * 3600) + (($days -  1 ) * 24 * 3600) + $hour * 3600 + $min * 60 + $sec
EndFunc   ;==>GetUnixTimeStamp

;===============================================================================
;
; Description:      UnixTimeStampToTime - Converts UnixTime to Date
; Parameter(s):     Requierd : $UnixTimeStamp => UnixTime ex : 1102141493
;                   Optional : None
; Return Value(s):  On Success - Returns Array
;                               - $Array[0] => Year ex : 1970 to 2038
;                               - $Array[1] => Month ex : 1 to 12
;                               - $Array[2] => Day ex : 1 to Max Day OF Month
;                               - $Array[3] => Hour ex : 0 to 23
;                               - $Array[4] => Minutes ex : 1 to 60
;                               - $Array[5] => Seconds ex : 1 to 60
;                   On Failure  - No Failure if valid parameter is a valid UnixTimeStamp
; Author(s):        azrael-sub7
; User Calltip:     UnixTimeStampToTime() (required: <_AzUnixTime.au3>)
;
;===============================================================================
Func UnixTimeStampToTime($UnixTimeStamp)
	Dim $pTime[6]
	$pTime[0] = Floor($UnixTimeStamp/31436000) + 1970 ; pTYear

	Local $pLeap = Floor(($pTime[0]-1969)/4)
	Local $pDays =  Floor($UnixTimeStamp/86400)
	$pDays = $pDays - $pLeap
	$pDaysSnEp = Mod($pDays,365)

	$pTime[1] = 1 ;$pTMon
	$pTime[2] = $pDaysSnEp ;$pTDays

	If $pTime[2] > 59 And BoolLeapYear($pTime[0]) = True Then $pTime[2] += 1

	While 1
		If($pTime[2] > 31) Then
		$pTime[2] = $pTime[2] - MaxDayInMonth($pTime[1])
		$pTime[1]  = $pTime[1] + 1
		Else
			ExitLoop
		EndIf
	WEnd

	Local $pSec = $UnixTimeStamp - ($pDays + $pLeap) * 86400

	$pTime[3] = Floor($pSec/3600) ; $pTHour
	$pTime[4] = Floor(($pSec - ($pTime[3] * 3600))/60) ;$pTmin
	$pTime[5] = ($pSec -($pTime[3] * 3600)) - ($pTime[4] * 60) ; $pTSec

	Return $pTime
EndFunc ;==> UnixTimeStampToTime

;===============================================================================
;
; Description:      BoolLeapYear - Check if Year is Leap Year
; Parameter(s):     Requierd : $year => Year to check ex : 2011
;                   Optional : None
; Return Value(s):  True if $year is Leap Year else False
; Author(s):        azrael-sub7
; User Calltip:     BoolLeapYear() (required: <_AzUnixTime.au3>)
; Credits :         Wikipedia Leap Year
;===============================================================================
Func BoolLeapYear($year)
    If Mod($year, 400) = 0 Then
        Return True ;is_leap_year
    ElseIf Mod($year, 100) = 0 Then
        Return False ;is_not_leap_y
    ElseIf Mod($year, 4) = 0 Then
        Return True ;is_leap_year
    Else
        Return False ;is_not_leap_y
    EndIf
EndFunc   ;==>BoolLeapYear

;===============================================================================
;
; Description:      MaxDayInMonth - Converts UnixTime to Date
;                   if the function is called with no parameters it returns maximum days for current system set month
;                   else it returns maximum days for the specified month in specified year
; Parameter(s):     Requierd : None
;                   Optional :
;                               - $year : year : 1970 to 2038
;                               - $mon : month : 1 to 12
; Return Value(s):
; Author(s):        azrael-sub7
; User Calltip:     MaxDayInMonth() (required: <_AzUnixTime.au3>)
;===============================================================================
Func MaxDayInMonth($year = @YEAR, $mon = @MON)
    If Number($mon) = 2 Then
        If BoolLeapYear($year) = True Then
            Return 29 ;is_leap_year
        Else
            Return 28 ;is_not_leap_y
        EndIf
    Else
        If $mon < 8 Then
    If Mod($mon, 2) = 0 Then
        Return 30
    Else
        Return 31
    EndIf
Else
    If Mod($mon, 2) = 1 Then
        Return 30
    Else
        Return 31
    EndIf
EndIf
    EndIf
EndFunc   ;==>MaxDayInMonth
;===============================================================================
; Function Name:    __StringProper
; Description:		Improved version of _StringProper, wont capitalize after apostrophes
; Call With:		__StringProper($s_String)
; Parameter(s):
; Return Value(s):  On Success -
; 					On Failure -
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		10/15/2014  --  v1.0
;===============================================================================
Func __StringProper($s_String)
	Local $iX = 0
	Local $CapNext = 1
	Local $s_nStr = ""
	Local $s_CurChar
	For $iX = 1 To StringLen($s_String)
		$s_CurChar = StringMid($s_String, $iX, 1)
		Select
			Case $CapNext = 1
				If StringRegExp($s_CurChar, '[a-zA-ZÀ-ÿšœžŸ]') Then
					$s_CurChar = StringUpper($s_CurChar)
					$CapNext = 0
				EndIf
			Case Not StringRegExp($s_CurChar, '[a-zA-ZÀ-ÿšœžŸ]') AND $s_CurChar <> "'"
				$CapNext = 1
			Case Else
				$s_CurChar = StringLower($s_CurChar)
		EndSelect
		$s_nStr &= $s_CurChar
	Next
	Return $s_nStr
EndFunc
;===============================================================================
; Function Name:    _FileInUse()
; Description:      Checks if file is in use
; Call With:        _FileInUse($sFilename, $iAccess = 0)
; Parameter(s):     $sFilename = File name
;                   $iAccess = 0 = GENERIC_READ - other apps can have file open in readonly mode
;                   $iAccess = 1 = GENERIC_READ|GENERIC_WRITE - exclusive access to file,
;                   fails if file open in readonly mode by app
; Return Value(s):  1 - file in use (@error contains system error code)
;                   0 - file not in use
;                   -1 dllcall error (@error contains dllcall error code)
; Author(s):        Siao, rover
; Date/Version:		10/15/2014  --  v1.0
;===============================================================================
Func _FileInUse($sFilename, $iAccess = 0)
    Local $aRet, $hFile, $iError, $iDA
    Local Const $GENERIC_WRITE = 0x40000000
    Local Const $GENERIC_READ = 0x80000000
    Local Const $FILE_ATTRIBUTE_NORMAL = 0x80
    Local Const $OPEN_EXISTING = 3
    $iDA = $GENERIC_READ
    If BitAND($iAccess, 1) <> 0 Then $iDA = BitOR($GENERIC_READ, $GENERIC_WRITE)
    $aRet = DllCall("Kernel32.dll", "hwnd", "CreateFile", _
                                    "str", $sFilename, _ ;lpFileName
                                    "dword", $iDA, _ ;dwDesiredAccess
                                    "dword", 0x00000000, _ ;dwShareMode = DO NOT SHARE
                                    "dword", 0x00000000, _ ;lpSecurityAttributes = NULL
                                    "dword", $OPEN_EXISTING, _ ;dwCreationDisposition = OPEN_EXISTING
                                    "dword", $FILE_ATTRIBUTE_NORMAL, _ ;dwFlagsAndAttributes = FILE_ATTRIBUTE_NORMAL
                                    "hwnd", 0) ;hTemplateFile = NULL
    $iError = @error
    If @error Or IsArray($aRet) = 0 Then Return SetError($iError, 0, -1)
    $hFile = $aRet[0]
    If $hFile = -1 Then ;INVALID_HANDLE_VALUE = -1
        $aRet = DllCall("Kernel32.dll", "int", "GetLastError")
        ;ERROR_SHARING_VIOLATION = 32 0x20
        ;The process cannot access the file because it is being used by another process.
        If @error Or IsArray($aRet) = 0 Then Return SetError($iError, 0, 1)
        Return SetError($aRet[0], 0, 1)
    Else
        ;close file handle
        DllCall("Kernel32.dll", "int", "CloseHandle", "hwnd", $hFile)
        Return SetError(@error, 0, 0)
    EndIf
EndFunc
;===============================================================================
; Function Name:    _FileInUseWait
; Description:		Checkes to see if a file has open handles
; Call With:		_FileInUse($sFilePath, $iAccess = 0)
; Parameter(s):
; Return Value(s):  On Success -
; 					On Failure -
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		10/15/2014  --  v1.0
;===============================================================================
func _FileInUseWait($sFilePath, $Timeout=0, $Sleep=2000)
	$Timeout=$Timeout*1000
	$Time=TimerInit ( )
	while 1
		if _FileInUse($sFilePath) Then
			_ConsoleWrite("  File locked")
		Else
			Return 1
		endif
		if $Timeout > 0 AND $Timeout < TimerDiff($Time) then
			_ConsoleWrite("  Timeout, file locked")
			Return 0
		endif
		Sleep($Sleep)
	wend
endfunc
;===============================================================================
; Function Name:    _ProcessWaitClose
; Description:		ProcessWaitClose that handles stdout from the running process
; Call With:		_ProcessWaitClose($iPid)
; Parameter(s):
; Return Value(s):  On Success -
; 					On Failure -
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/16/2016  --  v1.2
;===============================================================================
Func _ProcessWaitClose($iPid)
	Local $sData, $sStdOut
	ProcessWait ($iPid,1)
	While ProcessExists($iPid)
		Sleep(10)
		$sStdOut = StdoutRead($iPid)
		If $sStdOut = "" Then ContinueLoop
		;$sStdOut=StringReplace($sStdOut,@CR&@LF,""); I don't know why this exists, we shouldn't remove anything
		$sStdOut=StringReplace($sStdOut,@CR&@LF&@CR&@LF,@CR&@LF) ; special purpose replacment for above, seems like this should be handled in the output function
		_ConsoleWrite($sStdOut)
		$sData &= $sStdOut
	WEnd
	return $sData
endfunc
;===============================================================================
; Function Name:    _RunWait
; Description:		Improved version of RunWait that plays nice with my console logging
; Call With:		_RunWait($Run, $Working="")
; Parameter(s):
; Return Value(s):  On Success - Return value of Run() (Should be PID)
; 					On Failure - Return value of Run()
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/16/2016  --  v1.1
;===============================================================================
Func _RunWait($sProgram, $Working="", $Show = @SW_HIDE, $Opt = BitOR($STDIN_CHILD, $STDOUT_CHILD, $STDERR_CHILD))
	Local $sData, $sStdOut, $iPid
	$iPid=Run($sProgram, $Working, $Show, $Opt)
	If @error then
		_ConsoleWrite("_RunWait: Couldn't Run "&$sProgram)
		return $iPid
	endif

	_ProcessWaitClose($iPid)

	return $iPid
endfunc
;===============================================================================
; Function Name:    _TreeList()
; Description:
; Call With:		_TreeList()
; Parameter(s):
; Return Value(s):  On Success -
; 					On Failure -
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		06/02/2011  --  v1.0
;===============================================================================
Func _TreeList($path, $mode=1)
	local $FileList_Original=_FileListToArray($path,"*",0)
	local $FileList[1]

	for $i=1 to ubound($FileList_Original)-1
		local $file_path=$path&"\"&$FileList_Original[$i]
		if StringInStr(FileGetAttrib($file_path),"D") then
			$new_array=_TreeList($file_path,$mode)
			_ArrayConcatenate($FileList,$new_array,1)
		else
			ReDim $FileList[UBound($FileList)+1]
			$FileList[UBound($FileList)-1]=$file_path
		endif
	next

	return $FileList
endfunc
;===============================================================================
; Function Name:    _StringStripWS()
; Description:		Strips all white chars, excluing char(32) the reglar space
; Call With:		_StringStripWS($String)
; Parameter(s): 	$String - String To Strip
; Return Value(s):  On Success - Striped String
; 					On Failure - Full String
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _StringStripWS($String)
	return StringRegExpReplace($String,"["&chr(0)&chr(9)&chr(10)&chr(11)&chr(12)&chr(13)&"]","")
endfunc
;===============================================================================
; Function Name:    _mousecheck()
; Description:		Checks for mouse movement
; Call With:		_mousecheck($Sleep)
; Parameter(s): 	$Sleep - Miliseconds between mouse checks, 0=Compare At Next Call
; Return Value(s):  On Success - 1 (Mouse Moved)
; 					On Failure - 0 (Mouse Didnt Move)
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _MouseCheck($Sleep=300)
	Local $MOUSECHECK_POS1, $MOUSECHECK_POS2

	if $Sleep=0 then Global $MOUSECHECK_POS1
	if isarray($MOUSECHECK_POS1)=0 And $Sleep=0 then $MOUSECHECK_POS1=MouseGetPos()
	Sleep($Sleep)
	$MOUSECHECK_POS2=MouseGetPos()
	If Abs($MOUSECHECK_POS1[0]-$MOUSECHECK_POS2[0])>2 Or Abs($MOUSECHECK_POS1[1]-$MOUSECHECK_POS2[1])>2 Then
		if $Sleep=0 then $MOUSECHECK_POS1=$MOUSECHECK_POS2
		Return 1
	endif

	Return 0
EndFunc
;===============================================================================
; Function Name:    _sini()
; Description:		Easily create or work with 2d arrays, such as the ones produced by INIReadSection()
; Call With:		_sini(ByRef $Array, $Key[, $Value[, $Extended]])
; Parameter(s): 	$Array - A previously declared array, if not array, it will be made as one
;					$Key - The value to look for in the first column/dimention or the "Key" in an INI section
;		(Optional)	$Value - The value to write to the array
;		(Optional)	$Extended - Special options turned on by adding a letter to this string (See notes)
;
; Return Value(s):  On Success - The value found or set
; 					On Failure - "" and sets @error to 1 if value is not found ($Extended can override this)
;
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
; Notes:            $Array[0][0] Contains the number of stored parameters
;					Special $Extended Codes:
;						d=value passed is used as default value IF key doesnt already have a value
;						D=d+Check for default value in global var $default_xxx
;						e=encrypt/decrypt value
;						E=e+Use the computers hardware key to encrypt/decrypt
; Example:			_sini($Settings,"trayicon","1","d")
;===============================================================================
Func _sini(ByRef $Array,$Key,$Value=default,$Extended="")
	Local $Alert=0
	if $Value=default then $Alert=1

	If Not IsArray($array) Then Dim $array[1][2]
	If stringinstr($Extended,"E",1) Then $Pass=DriveGetSerial(StringLeft(@WindowsDir,2))&@CPUArch&@OSBuild&$Key
	If stringinstr($Extended,"e",1) Then $Pass="a1e2i3o4u5y6"&$Key

	For $i=1 To UBound($Array)-1;Check for existing key
		If $Array[$i][0]=$Key Then
			If $Value=default OR stringinstr($Extended,"D",1) OR ($Value="" and stringinstr($Extended,"d")=0) Then ;Read Existing Value
				If stringinstr($Extended,"e") Then
					$decrypt=0;_StringEncrypt(0,$array[$i][1],$Pass,2)
					If $decrypt=0 Then $decrypt=""
					Return $decrypt
				Else
					Return $array[$i][1]
				EndIf
			Else
				If stringinstr($Extended,"e") Then				;Change Existing Value
					$Array[$i][1]=0;_StringEncrypt(1,$Value,$Pass,2)
				Else
					$Array[$i][1]=$Value
				EndIf
				$Array[0][0]=UBound($Array)-1
				Return $Value
			EndIf
		EndIf
	Next

	if ($Value="" or $Value=default) and StringInStr($Extended,"D",1) then $Value=Eval("default_"&$Key)

	if $Value=default then
		MsgBox(48,"Error In "&@ScriptName,"Missing Value For Setting """&$Key&""""&@CRLF&"Press Ok To Continue")
	else
		$iUBound = UBound($Array)
		ReDim $Array[$iUBound + 1][2]
		$Array[$iUBound][0]=$Key
		$Array[$iUBound][1]=$Value
		if stringinstr($Extended,"e") then $Array[$iUBound][1]=0;_StringEncrypt(1,$Value,$Pass,2)
		$Array[0][0]=UBound($Array)-1
		return $Value
	endif

	SetError(1)
	return ""
EndFunc ;==>_sini
;===============================================================================
; Function Name:   	_ConsoleWrite()
; Description:		Console & File Loging
; Call With:		_ConsoleWrite($Text,$SameLine)
; Parameter(s): 	$Text - Text to print
;					$Level - The level the given message *is*
;					$SameLine - (Optional) Will continue to print on the same line if set to 1
;
; Return Value(s):  The Text Originaly Sent
; Notes:			Will see if global var $DEBUGLOG=1 or $CmdLineRaw contains "-debuglog" to see if log file should be writen
;					If Text = "OPENLOG" then log file is displayed (casesense)
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		06/1/2012  --  v1.1
;===============================================================================
Func _ConsoleWrite($sMessage, $iLevel=1, $iSameLine=0)
	Local $hHandle, $sData

	if Eval("LogFilePath")="" Then Global $LogFilePath = StringTrimRight(@ScriptFullPath,4)&"_Log.txt"
	if Eval("LogFileMaxSize")="" Then Global $LogFileMaxSize = 0
	if Eval("LogToFile")="" Then Global $LogToFile = False
	if Eval("LogLevel")="" Then Global $LogLevel = 3 ; The level of message to log - If no level set to 3
	If $sMessage=="OPENLOG" Then Return ShellExecute($LogFilePath)

	If $iLevel<=$LogLevel then
		$sMessage=StringReplace($sMessage,@CRLF&@CRLF,@CRLF) ;Remove Double CR
		If StringRight($sMessage,StringLen(@CRLF))=@CRLF Then $sMessage=StringTrimRight($sMessage,StringLen(@CRLF)) ; Remove last CR

		Local $sTime=@YEAR&"-"&@MON&"-"&@MDAY&" "&@HOUR&":"&@MIN&":"&@SEC&"> " ; Generate Timestamp
		$sMessage=StringReplace($sMessage,@CRLF,@CRLF&_StringRepeat(" ",StringLen($sTime))) ; Uses spaces after initial line if string had returns

		if NOT $iSameLine then $sMessage=@CRLF&$sTime&$sMessage

		ConsoleWrite($sMessage)

		If $LogToFile Then
			if $LogFileMaxSize<>0 AND FileGetSize($LogFilePath) > $LogFileMaxSize*1024 then
				$sMessage=FileRead($LogFilePath) & $sMessage
				$sMessage=StringTrimLeft($sMessage,StringInStr($sMessage, @CRLF, 0, 5))
				$hHandle=FileOpen($LogFilePath,2)
			Else
				$hHandle=FileOpen($LogFilePath,1)
			endif
			FileWrite($hHandle,$sMessage)
			FileClose($hHandle)

		endif
	endif

	Return $sMessage
EndFunc ;==> _ConsoleWrite
;===============================================================================
; Function Name:    _ntime()
; Description:		Returns time since 0 unlike the unknown timestamp behavior of timer_init
; Call With:		_ntime([$Flag])
; Parameter(s): 	$Flag - (Optional) Default is 0 (Miliseconds)
;						1 = Return Total Seconds
;						2 = Return Total Minutes
; Return Value(s):  On Success - Time
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _ntime($Flag=0)
	Local $Time

	$Time=@YEAR*365*24*60*60*1000
	$Time=$Time+@YDAY*24*60*60*1000
	$Time=$Time+@HOUR*60*60*1000
	$Time=$Time+@MIN*60*1000
	$Time=$Time+@SEC*1000
	$Time=$Time+@MSEC

	If $Flag=1 Then Return Int($Time/1000) ;Return Seconds
	If $Flag=2 Then Return Int($Time/1000/60) ;Return Minutes
	Return Int($Time) ;Return Miliseconds
EndFunc
;===============================================================================
; Function Name:    _proc_waitnew()
; Description:		Wait for a new proccess to be created before continuing
; Call With:		_proc_waitnew($proc,$timeout=0)
; Parameter(s): 	$Process - PID or proccess name
;					$Timeout - (Optional) Miliseconds Before Giving Up
; Return Value(s):  On Success - 1
; 					On Failure - 0 (Timeout)
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _proc_waitnew($Process,$Timeout=0)
	Local $Count1=_proc_count(), $Count2
	Local $StartTime=_ntime()

	While 1
		$Count2=_proc_count()
		if $Count2>$Count1 then return 1
		if $Count2<$Count1 then $Count1=$Count2

		If $Timeout>0 And $StartTime<_ntime()-$Timeout Then ExitLoop
		Sleep(100)
	WEnd

	Return 0
EndFunc
;===============================================================================
; Function Name:    _proc_count()
; Description:		Returns the number of processes with the same name
; Call With:		_proc_count([$Process[,$OnlyUser]])
; Parameter(s): 	$Process - PID or process name
;					$OnlyUser - Only evaluate processes from this user
; Return Value(s):  On Success - Count
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _proc_count($Process=@AutoItPID,$OnlyUser="")
	Local $Count=0, $Array=ProcessList($Process)

	for $i=1 To $Array[0][0]
		if $Array[$i][1]=$Process then
			if $OnlyUser<>"" And $OnlyUser<>_ProcessOwner($Array[$i][1]) then ContinueLoop
			$Count=$Count+1
		endif
	Next

	Return $Count
EndFunc
;===============================================================================
; Function Name:    _ProcessOwner()
; Description:		Gets username of the owner of a PID
; Call With:		_ProcessOwner($PID[,$Hostname])
; Parameter(s): 	$PID - PID of proccess
;					$Hostname - (Optional) The computers name to check on
; Return Value(s):  On Success - Username of owner
; 					On Failure - 0
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _ProcessOwner($PID,$Hostname=".")
	Local $User, $objWMIService, $colProcess, $objProcess

	$objWMIService = ObjGet("winmgmts://" & $Hostname & "/root/cimv2")
	$colProcess = $objWMIService.ExecQuery("Select * from Win32_Process Where ProcessID ='" & $PID & "'")

	For $objProcess In $colProcess
		If $objProcess.ProcessID = $PID Then
			$User = 0
			$objProcess.GetOwner($User)
			Return $User
		EndIf
	Next
EndFunc
;===============================================================================
; Function Name:    _ProcessCloseOthers()
; Description:		Closes other proccess of the same name
; Call With:		_ProcessCloseOthers([$Process[,$ExcludingUser[,$OnlyUser]]])
; Parameter(s): 	$Process - (Optional) Name or PID
;					$ExcludingUser - (Optional) Username of owner to exclude
;					$OnlyUser - (Optional) Username of proccesses owner to close
; Return Value(s):  On Success - 1
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
func _ProcessCloseOthers($Process=@ScriptName,$ExcludingUser="",$OnlyUser="")
	Local $Array=ProcessList($Process)

	for $i=1 To $Array[0][0]
		if ($Array[$i][1]<>@AutoItPID) then
			if $ExcludingUser<>"" AND _ProcessOwner($Array[$i][1])<>$ExcludingUser then
				ProcessClose($Array[$i][1])
			elseif $OnlyUser<>"" and _ProcessOwner($Array[$i][1])=$OnlyUser then
				ProcessClose($Array[$i][1])
			elseif $OnlyUser="" AND $ExcludingUser="" then
				ProcessClose($Array[$i][1])
			endif
		endif
	Next
endfunc
;===============================================================================
; Function Name:    _OnlyInstance()
; Description:		Checks to see if we are the only instance running
; Call With:		_OnlyInstance($iFlag)
; Parameter(s): 	$iFlag
;						0 = Continue Anyway
;						1 = Exit Without Notification
;						2 = Exit After Notifying
;						3 = Prompt What To Do
;						4 = Close Other Proccesses
; Return Value(s):  On Success - 1 (Found Another Instance)
; 					On Failure - 0 (Didnt Find Another Instance)
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		10/15/2014  --  v1.1
;===============================================================================
func _OnlyInstance($iFlag)
	Local $ERROR_ALREADY_EXISTS = 183, $Handle, $LastError, $Message

	if @Compiled=0 then return 0

	$Handle = DllCall("kernel32.dll", "int", "CreateMutex", "int", 0, "long", 1, "str", @ScriptName)
	$LastError = DllCall("kernel32.dll", "int", "GetLastError")
	If $LastError[0] = $ERROR_ALREADY_EXISTS Then
		SetError($LastError[0], $LastError[0], 0)
		Switch $iFlag
			case 0
				return 1
			case 1
				ProcessClose(@AutoItPID)
			case 2
				MsgBox(262144+48,@ScriptName,"The Program Is Already Running")
				ProcessClose(@AutoItPID)
			case 3
				if MsgBox(262144+256+48+4,@ScriptName, "The Program ("&@ScriptName&") Is Already Running, Continue Anyway?")=7 then ProcessClose(@AutoItPID)
			case 4
				_ProcessCloseOthers()
		EndSwitch
		return 1
	EndIf
	return 0
endfunc
;===============================================================================
; Function Name:    _MsgBox()
; Description:		Displays a msgbox without haulting script by using /AutoIt3ExecuteLine
; Call With:		_MsgBox($Flag,$Title,$Text,$Timeout=0)
; Parameter(s): 	All the same options as standard message box
; Return Value(s):  On Success - PID of new proccess
; 					On Failure - 0
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.1
;===============================================================================
Func _MsgBox($Flag,$Title,$Text,$Timeout=0)
	if $Title="" then $Title=@ScriptName
	if $Flag="" or IsInt($Flag)=0 then $Flag=0
	return Run('"'&@AutoItExe&'"' & ' /AutoIt3ExecuteLine "msgbox('&$Flag&','''&$Title&''','''&$Text&''','''&$Timeout&''')"')
EndFunc
;===============================================================================
; Function Name:    _drive_find()
; Description:		Find a drives letter based on the drives serial
; Call With:		_drive_find($Serial)
; Parameter(s): 	$Serial - Serial of the drive
; Return Value(s):  On Success - Drive letter with ":"
; 					On Failure - 0
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
Func _drive_find($Serial)
	Local $Drivelist
	$Drivelist=StringSplit("c:,d:,e:,f:,g:,h:,i:,j:,k:,l:,m:,n:,o:,p:,q:,r:,s:,t:,u:,v:,w:,x:,y:,z:",",")
	for $i=1 to $Drivelist[0]
		If (DriveGetSerial($Drivelist[$i])=$Serial AND DriveStatus($Drivelist[$i]) = "READY") then return $Drivelist[$i]
	next
	return 0
endfunc

;===============================================================================
; Function Name:    _Speak()
; Description:		Speaks or creates audio file of the specified text
; Call With:		_Speak($Text[,$Speed,[$File]])
; Parameter(s): 	$Text - What to speak
;					$Speed - (Optional) How fast to speak
;					$File - (Optional) Filename to record to if specified (Wont speak outloud)
; Return Value(s):  On Success - 1
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		01/29/2010  --  v1.0
;===============================================================================
func _Speak($Text,$Speed=-3,$File="")
	Local $ObjVoice, $ObjFile

	$ObjVoice=ObjCreate("Sapi.SpVoice")
    if $File<>"" then
		$ObjFile=ObjCreate("SAPI.SpFileStream.1")
		$objFile.Open($File,3)
		$objVoice.AudioOutputStream = $objFile
	endif
    $objVoice.Speak ('<rate speed="'&$Speed&'">'&$Text&'</rate>', 8)

	return 1
endfunc
;===============================================================================
; Function Name:    _Sleep()
; Description:		Simple modification to sleep to allow for adlib functions to run
; Call With:		_Sleep($iTime)
; Parameter(s): 	$iTime - Time in MS
; Return Value(s):  none
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		10/15/2014  --  v1.0
;===============================================================================
func _Sleep($iTime)
	$iTime=Round($iTime/10)
	For $i=1 to $iTime
		sleep(10)
	next
Endfunc
;===============================================================================
; Function Name:    _IsInternet()
; Description:		Gets internet connection state as determined by Windows
; Call With:		_IsInternet()
; Parameter(s): 	none
; Return Value(s):  Success - 1
;					Failure - 0
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		10/15/2014  --  v1.0
;===============================================================================
func _IsInternet()
	local $Ret = DllCall("wininet.dll", 'int', 'InternetGetConnectedState', 'dword*', 0x20, 'dword', 0)

	if (@error) then
		return SetError(1, 0, 0)
	endif

	local $wError = _WinAPI_GetLastError()

	return SetError((not ($wError = 0)), $wError, $Ret[0])
endfunc
;===============================================================================
; Function Name:    _ImageWait()
; Description:		Use image search to wait for an image to apear on the screen
; Call With:		_ImageWait($iFlag)
; Parameter(s):
; Return Value(s):  On Success - 1 (Found image)
; 					On Failure - 0 (Timeout)
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		10/15/2014  --  v1.1
;===============================================================================
func _ImageWait($FindImage,$hWnd=Default,$iTolerance=Default,$iTimeout=Default,$x1=Default,$y1=Default,$x2=Default,$y2=Default)
	$timer=Timerinit()
	while 1
		$Return=_ImageSearch($FindImage,$hWnd,$iTolerance,Default,$x1,$y1,$x2,$y2)
		if not @error then return $Return

		if $iTimeout > 0 AND TimerDiff($timer) > $iTimeout then
			SetError(1)
			Return 0
		endif

		_sleep(500)
	wend
endfunc
;===============================================================================
; Function Name:    _ImageSearch()
; Description:		Searches the chosen area of the screen for an image based on the selected image file
; Call With:		_ImageSearch($FindImage[,$hWnd[,$Tolerance[,$Draw[,$x1[,$y1[,$x2[,$y2]]]]]]])
; Parameter(s): 	$FindImage - File name/path of image to search for
;					$hWnd - (Optional) Handle to window to conduct the search in (speeds up searching)
;					$Tolerance - (Optional) Tolerance for variations between the image file and the screen
;									Note: Checkes pixel for pixel; slight changes in reletive position of pixels are not tolerated
;					$Draw - (Optional) Calls on user function "DrawBox" to draw a green line around the area being searched
;									Note: Can cause performance issues, line lingers after being drawn, for debugging primarily
;					$x1 - (Optional) Left pixel dimention (default: 0)
;					$y1 - (Optional) Top  pixel dimention (default: 0)
;					$x2 - (Optional) Right pixel dimention (default: desktop width)
;					$y2 - (Optional) Bottom pixel dimention (default: desktop height)
; Return Value(s):	On Failure - Returns empty array and sets @error to 1 when the image isnt found
;								 Returns empty array and sets @error to 2 when the call to the image search dll failed
;					On Success - Returns an array containing location values for the searched image
;									$Array[0] = X position
;									$Array[1] = Y postion
;									$Array[2] = Width of image
;									$Array[3] = Height of image
;									$Array[4] = Center position of image found (x)
;									$Array[5] = Center position of image found (y)
; Notes:			This function returns vaules that are considerate of "PixelCoordMode", note that when using
;						relative coords inacuracys are posible while window is being moved
;					Call this function with $FindImage equal to "close" to close the open dll
;					Set "$ImageSearch_hDll" as a global variable in your script to specify you own dll name/path
; Author(s):        DLL Author Unknown
;					JohnMC - JohnsCS.com
; Date/Version:		11/20/2012  --  v1.1
;===============================================================================
Func _ImageSearch($FindImage,$hWnd="",$Tolerance=0,$Draw=0,$x1=0,$y1=0,$x2=@DesktopWidth,$y2=@DesktopHeight)
	Local $Default_Dll="_ImageSearchDLL.dll", $aCoords[6]

	If $hWnd <> "" Then
		$wpos=WinGetPos($hWnd)
		$x1=$wpos[0]
		$y1=$wpos[1]
		$x2=$wpos[0]+$wpos[2]
		$y2=$wpos[1]+$wpos[3]
	EndIf

	if $Draw=1 then _DrawBox($x1,$y1,$x2,$y2)

    if Not FileExists($FindImage) then
		return seterror(3,0,$aCoords)
	endif

	If Not IsDeclared("ImageSearch_hDll") Then
        Global $ImageSearch_hDll=DllOpen($Default_Dll)
    EndIf

	if $FindImage="close" then
		DllClose($ImageSearch_hDll)
		return
	EndIf

	if $tolerance > 0 then $FindImage = "*" & $tolerance & " " & $FindImage

	Local $aReturn = DllCall($ImageSearch_hDll,"str","ImageSearch","int",$x1,"int",$y1,"int",$x2,"int",$y2,"str",$FindImage)

    if @error then
		return seterror(2,0,$aCoords)
	elseif $aReturn[0]="0" then
		return seterror(1,0,$aCoords)
	endif

	$aCoords = StringSplit(StringTrimLeft($aReturn[0],2),"|",2) ;Recycle $aReturn

	if AutoItSetOption("PixelCoordMode")=0 then ;Consideration for coords relative to window
		local $aWinPos = WinGetPos($hWnd)
		$aCoords[0]=$aCoords[0]-$aWinPos[0]
		$aCoords[1]=$aCoords[1]-$aWinPos[1]
	elseif AutoItSetOption("PixelCoordMode")=2 then ;Consideration for coords relative to client area of active window
		if $hWnd="" then $hWnd=WinGetHandle("")
		Local $tpoint = DllStructCreate("int X;int Y")
		DllStructSetData($tpoint, "X", 0)
		DllStructSetData($tpoint, "Y", 0)
		DllCall("user32.dll", "bool", "ClientToScreen", "hwnd", $hWnd, "struct*", $tPoint)
		$aCoords[0]=$aCoords[0]-DllStructGetData($tpoint, "X")
		$aCoords[1]=$aCoords[1]-DllStructGetData($tpoint, "Y")
	endif

	ReDim $aCoords[6]
	$aCoords[4]=Int($aCoords[0]+($aCoords[2]/2));Center X
	$aCoords[5]=Int($aCoords[1]+($aCoords[3]/2));Center Y

	return $aCoords
EndFunc
;===============================================================================
; Function Name:    _DrawBox()
; Description:		Draws a line (box) on the screen using the coorinates provided
; Call With:		_DrawBox($x1,$y1,$x2,$y2[,$Color])
; Parameter(s): 	$x1 - Left pixel dimention
;					$y1 - Top  pixel dimention
;					$x2 - Right pixel dimention
;					$y2 - Bottom pixel dimention
;					$Color - Hex color value, default is green
; Return Value(s):	N/A
; Notes:			Can cause performance issues if called often, line may linger after being drawn, for debugging primarily
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		11/20/2012  --  v1.1
;===============================================================================
Func _DrawBox($x1,$y1,$x2,$y2,$Color=0x00FF00)
    Local $aDC = DllCall ("user32.dll", "int", "GetDC", "hwnd", "")
    Local $hDll = DllOpen ("gdi32.dll")

	For $i=$x1 To $y2
		DllCall ($hDll, "long", "SetPixel", "long", $aDC[0], "long", $i, "long", $y1, "long", $Color)
		DllCall ($hDll, "long", "SetPixel", "long", $aDC[0], "long", $i, "long", $y2, "long", $Color)
	Next

	For $i=$x1 To $y2
		DllCall ($hDll, "long", "SetPixel", "long", $aDC[0], "long", $x1, "long", $i, "long", $Color)
		DllCall ($hDll, "long", "SetPixel", "long", $aDC[0], "long", $x2, "long", $i, "long", $Color)
	Next

	DllClose($hDll)
EndFunc
;===============================================================================
; Function Name:    _WinGetClientPos
; Description:		Retrieves the position and size of the client area of given window
; Call With:		_WinGetClientPos($hWin)
; Parameter(s): 	$hWnd - Handle to window
;					$Absolute - 1 = Get coordinates relative to the screen (deafult)
;								0 = Get coordinates relative to the window
; Return Value(s):	On Success - Returns an array containing location values for client area of the specified window
;									$Array[0] = X position
;									$Array[1] = Y position
;									$Array[2] = Width
;									$Array[3] = Height
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		11/21/2012  --  v1.2
;===============================================================================
Func _WinGetClientPos($hWnd, $Absolute = 1)
	Local $aPos[4], $aSize[4], $aWinPos[4]

	Local $tpoint = DllStructCreate("int X;int Y")
    DllStructSetData($tpoint, "X", 0)
    DllStructSetData($tpoint, "Y", 0)
	DllCall("user32.dll", "bool", "ClientToScreen", "hwnd", $hWnd, "struct*", $tPoint)

	$aSize = WinGetClientSize($hWnd)

	$aPos[0] = DllStructGetData($tpoint, "X")
	$aPos[1] = DllStructGetData($tpoint, "Y")
	$aPos[2] = $aSize[0]
	$aPos[3] = $aSize[1]

	if $Absolute = 0 then
		$aWinPos = WinGetPos($hWnd)
		$aPos[0] = $aPos[0] - $aWinPos[0]
		$aPos[1] = $aPos[1] - $aWinPos[1]
	EndIf

    Return $aPos
EndFunc
;===============================================================================
; Function Name:    _WinMoveClient
; Description:		Retrieves the position and size of the client area of given window
; Call With:		_WinMoveClient($hWin)
; Parameter(s): 	$hWnd - Handle to window
;					$Absolute - 1 = Get coordinates relative to the screen (deafult)
;								0 = Get coordinates relative to the window
; Return Value(s):	Success - Handle to the window
;					Failure - 0
; Author(s):        JohnMC - JohnsCS.com
; Date/Version:		10/15/2014  --  v1.0
;===============================================================================
Func _WinMoveClient($sTitle,$sText,$X,$Y,$Width=default,$Height=default,$Speed=default)

	Local $WinPos=WinGetPos($sTitle,$sText)
	Local $ClientSize=WinGetClientSize($sTitle,$sText)

	if $Width<>default then $Width=$Width+$WinPos[2]-$ClientSize[0]
	if $Height<>default then $Height=$Height+$WinPos[3]-$ClientSize[1]

	Return WinMove($sTitle,$sText,$X,$Y,$Width,$Height,$Speed)
endfunc
;=============================================================================================
; Name:				 _HighPrecisionSleep()
; Description:		Sleeps down to 0.1 microseconds
; Syntax:			_HighPrecisionSleep( $iMicroSeconds, $hDll=False)
; Parameter(s):		$iMicroSeconds        - Amount of microseconds to sleep
;					$hDll  - Can be supplied so the UDF doesn't have to re-open the dll all the time.
; Return value(s):	None
; Author:			Andreas Karlsson (monoceres)
; Remarks:			Even though this has high precision you need to take into consideration that it will take some time for autoit to call the function.
;=============================================================================================
Func _HighPrecisionSleep($iMicroSeconds,$dll="")
    Local $hStruct, $bLoaded
	If $dll<>"" Then $HPS_hDll=$dll
    If Not IsDeclared("HPS_hDll") Then
        Global $HPS_hDll
		$HPS_hDll=DllOpen("ntdll.dll")
        $bLoaded=True
    EndIf
    $hStruct=DllStructCreate("int64 time;")
    DllStructSetData($hStruct,"time",-1*($iMicroSeconds*10))
    DllCall($HPS_hDll,"dword","ZwDelayExecution","int",0,"ptr",DllStructGetPtr($hStruct))
EndFunc
;===============================================================================
; Function:		_ProcessGetWin
; Purpose:		Return information on the Window owned by a process (if any)
; Syntax:		_ProcessGetWin($iPID)
; Parameters:	$iPID = integer process ID
; Returns:  	On success returns an array:
; 					[0] = Window Title (if any)
;					[1] = Window handle
;				If $iPID does not exist, returns empty array and @error = 1
; Notes:		Not every process has a window, indicated by an empty array and
;   			@error = 0, and not every window has a title, so test [1] for the handle
;   			to see if a window existed for the process.
; Author:		PsaltyDS at www.autoitscript.com/forum
;===============================================================================
Func _ProcessGetWin($iPID)
    Local $avWinList = WinList(), $avRET[2]
    For $n = 1 To $avWinList[0][0]
        If WinGetProcess($avWinList[$n][1]) = $iPID Then
            $avRET[0] = $avWinList[$n][0] ; Title
            $avRET[1] = $avWinList[$n][1] ; HWND
            ExitLoop
        EndIf
    Next
    If $avRET[1] = "" Then SetError(1)
    Return $avRET
EndFunc
;===============================================================================
; Function Name:    _ProcessListProperties()
; Description:   Get various properties of a process, or all processes
; Call With:       _ProcessListProperties( [$Process [, $sComputer]] )
; Parameter(s):  (optional) $Process - PID or name of a process, default is "" (all)
;          (optional) $sComputer - remote computer to get list from, default is local
; Requirement(s):   AutoIt v3.2.4.9+
; Return Value(s):  On Success - Returns a 2D array of processes, as in ProcessList()
;            with additional columns added:
;            [0][0] - Number of processes listed (can be 0 if no matches found)
;            [1][0] - 1st process name
;            [1][1] - 1st process PID
;            [1][2] - 1st process Parent PID
;            [1][3] - 1st process owner
;            [1][4] - 1st process priority (0 = low, 31 = high)
;            [1][5] - 1st process executable path
;            [1][6] - 1st process CPU usage
;            [1][7] - 1st process memory usage
;            [1][8] - 1st process creation date/time = "MM/DD/YYY hh:mm:ss" (hh = 00 to 23)
;            [1][9] - 1st process command line string
;            ...
;            [n][0] thru [n][9] - last process properties
; On Failure:     	Returns array with [0][0] = 0 and sets @Error to non-zero (see code below)
; Author(s):      	PsaltyDS at http://www.autoitscript.com/forum
; Date/Version:   	12/01/2009  --  v2.0.4
; Notes:        	If an integer PID or string process name is provided and no match is found,
;             		then [0][0] = 0 and @error = 0 (not treated as an error, same as ProcessList)
;          			This function requires admin permissions to the target computer.
;          			All properties come from the Win32_Process class in WMI.
;            		To get time-base properties (CPU and Memory usage), a 100ms SWbemRefresher is used.
;===============================================================================
Func _ProcessListProperties($Process = "", $sComputer = ".")
    Local $sUserName, $sMsg, $sUserDomain, $avProcs, $dtmDate
    Local $avProcs[1][2] = [[0, ""]], $n = 1

    ; Convert PID if passed as string
    If StringIsInt($Process) Then $Process = Int($Process)

    ; Connect to WMI and get process objects
    $oWMI = ObjGet("winmgmts:{impersonationLevel=impersonate,authenticationLevel=pktPrivacy, (Debug)}!\\" & $sComputer & "\root\cimv2")
    If IsObj($oWMI) Then
        ; Get collection processes from Win32_Process
        If $Process == "" Then
            ; Get all
            $colProcs = $oWMI.ExecQuery("select * from win32_process")
        ElseIf IsInt($Process) Then
            ; Get by PID
            $colProcs = $oWMI.ExecQuery("select * from win32_process where ProcessId = " & $Process)
        Else
            ; Get by Name
            $colProcs = $oWMI.ExecQuery("select * from win32_process where Name = '" & $Process & "'")
        EndIf

        If IsObj($colProcs) Then
            ; Return for no matches
            If $colProcs.count = 0 Then Return $avProcs

            ; Size the array
            ReDim $avProcs[$colProcs.count + 1][10]
            $avProcs[0][0] = UBound($avProcs) - 1

            ; For each process...
            For $oProc In $colProcs
                ; [n][0] = Process name
                $avProcs[$n][0] = $oProc.name
                ; [n][1] = Process PID
                $avProcs[$n][1] = $oProc.ProcessId
                ; [n][2] = Parent PID
                $avProcs[$n][2] = $oProc.ParentProcessId
                ; [n][3] = Owner
                If $oProc.GetOwner($sUserName, $sUserDomain) = 0 Then $avProcs[$n][3] = $sUserDomain & "\" & $sUserName
                ; [n][4] = Priority
                $avProcs[$n][4] = $oProc.Priority
                ; [n][5] = Executable path
                $avProcs[$n][5] = $oProc.ExecutablePath
                ; [n][8] = Creation date/time
                $dtmDate = $oProc.CreationDate
                If $dtmDate <> "" Then
                    ; Back referencing RegExp pattern from weaponx
                    Local $sRegExpPatt = "\A(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})(?:.*)"
                    $dtmDate = StringRegExpReplace($dtmDate, $sRegExpPatt, "$2/$3/$1 $4:$5:$6")
                EndIf
                $avProcs[$n][8] = $dtmDate
                ; [n][9] = Command line string
                $avProcs[$n][9] = $oProc.CommandLine

                ; increment index
                $n += 1
            Next
        Else
            SetError(2); Error getting process collection from WMI
        EndIf
        ; release the collection object
        $colProcs = 0

        ; Get collection of all processes from Win32_PerfFormattedData_PerfProc_Process
        ; Have to use an SWbemRefresher to pull the collection, or all Perf data will be zeros
        Local $oRefresher = ObjCreate("WbemScripting.SWbemRefresher")
        $colProcs = $oRefresher.AddEnum($oWMI, "Win32_PerfFormattedData_PerfProc_Process" ).objectSet
        $oRefresher.Refresh

        ; Time delay before calling refresher
        Local $iTime = TimerInit()
        Do
            Sleep(20)
        Until TimerDiff($iTime) >= 100
        $oRefresher.Refresh

        ; Get PerfProc data
        For $oProc In $colProcs
            ; Find it in the array
            For $n = 1 To $avProcs[0][0]
                If $avProcs[$n][1] = $oProc.IDProcess Then
                    ; [n][6] = CPU usage
                    $avProcs[$n][6] = $oProc.PercentProcessorTime
                    ; [n][7] = memory usage
                    $avProcs[$n][7] = $oProc.WorkingSet
                    ExitLoop
                EndIf
            Next
        Next
    Else
        SetError(1); Error connecting to WMI
    EndIf

    ; Return array
    Return $avProcs
EndFunc
;===============================================================================
; Function:		_IsIP
; Purpose:		Validate if string is an IP address
; Syntax:		_ProcessGetWin($iPID)
; Parameters:	$sIP = String to validate as IP address
; Returns:  	Success - 1=IP 2=Subnet
;				Failure - 0 ()
; Notes:
; Author:
; Date/Version:   	10/15/2014  --  v2.0.4
;===============================================================================
Func _IsIP($sIP,$P_strict=0)
    $t_ip=$sIP
    $port=StringInStr($t_ip,":");check for : (for the port)
    If $port Then ;has a port attached
        $t_ip=StringLeft($sIP,$port-1);remove the port from the rest of the ip
        If $P_strict Then ;return 0 if port is wrong
            $zport=Int(StringTrimLeft($sIP,$port));retrieve the port
            If $zport>65000 Or $zport<0 Then Return 0;port is wrong
        EndIf
    EndIf
    $zip=StringSplit($t_ip,".")
    If $zip[0]<>4  Then Return 0;incorect number of segments
    If Int($zip[1])>255 Or Int($zip[1])<1 Then Return 0;xxx.ooo.ooo.ooo
    If Int($zip[2])>255 Or Int($zip[1])<0 Then Return 0;ooo.xxx.ooo.ooo
    If Int($zip[3])>255 Or Int($zip[3])<0 Then Return 0;ooo.ooo.xxx.ooo
    If Int($zip[4])>255 Or Int($zip[4])<0 Then Return 0;ooo.ooo.ooo.xxx
    $bc=1 ; is it 255.255.255.255 ?
    For $i=1 To 4
        If $zip[$i]<>255 Then $bc=0;no
        ;255.255.255.255 can never be a ip but anything else that ends with .255 can be
        ;ex:10.10.0.255 can actually be an ip address and not a broadcast address
    Next
    If $bc Then Return 0;a broadcast address is not really an ip address...
    If $zip[4]=0 Then;subnet not ip
        If $port Then
            Return 0;subnet with port?
        Else
            Return 2;subnet
        EndIf
    EndIf
    Return 1;;string is a ip
EndFunc
;==============================================================================================
; Description:		FileRegister($ext, $cmd, $verb[, $def[, $icon = ""[, $desc = ""]]])
;					Registers a file type in Explorer
; Parameter(s):		$ext - 	File Extension without period eg. "zip"
;					$cmd - 	Program path with arguments eg. '"C:\test\testprog.exe" "%1"'
;							(%1 is 1st argument, %2 is 2nd, etc.)
;					$verb - Name of action to perform on file
;							eg. "Open with ProgramName" or "Extract Files"
;					$def - 	Action is the default action for this filetype
;							(1 for true 0 for false)
;							If the file is not already associated, this will be the default.
;					$icon - Default icon for filetype including resource # if needed
;							eg. "C:\test\testprog.exe,0" or "C:\test\filetype.ico"
;					$desc - File Description eg. "Zip File" or "ProgramName Document"
;===============================================================================================
Func _FileRegister($ext, $cmd, $verb, $def = 0, $icon = "", $desc = "")
	$loc = RegRead("HKCR\." & $ext, "")
	If @error Then
		RegWrite("HKCR\." & $ext, "", "REG_SZ", $ext & "file")
		$loc = $ext & "file"
	EndIf
	$curdesc = RegRead("HKCR\" & $loc, "")
	If @error Then
		If $desc <> "" Then
			RegWrite("HKCR\" & $loc, "", "REG_SZ", $desc)
		EndIf
	Else
		If $desc <> "" And $curdesc <> $desc Then
			RegWrite("HKCR\" & $loc, "", "REG_SZ", $desc)
			RegWrite("HKCR\" & $loc, "olddesc", "REG_SZ", $curdesc)
		EndIf
		If $curdesc = "" And $desc <> "" Then
			RegWrite("HKCR\" & $loc, "", "REG_SZ", $desc)
		EndIf
	EndIf
	$curverb = RegRead("HKCR\" & $loc & "\shell", "")
	If @error Then
		If $def = 1 Then
			RegWrite("HKCR\" & $loc & "\shell", "", "REG_SZ", $verb)
		EndIf
	Else
		If $def = 1 Then
			RegWrite("HKCR\" & $loc & "\shell", "", "REG_SZ", $verb)
			RegWrite("HKCR\" & $loc & "\shell", "oldverb", "REG_SZ", $curverb)
		EndIf
	EndIf
	$curcmd = RegRead("HKCR\" & $loc & "\shell\" & $verb & "\command", "")
	If Not @error Then
		RegRead("HKCR\" & $loc & "\shell\" & $verb & "\command", "oldcmd")
		If @error Then
			RegWrite("HKCR\" & $loc & "\shell\" & $verb & "\command", "oldcmd", "REG_SZ", $curcmd)
		EndIf
	EndIf
	RegWrite("HKCR\" & $loc & "\shell\" & $verb & "\command", "", "REG_SZ", $cmd)
	If $icon <> "" Then
		$curicon = RegRead("HKCR\" & $loc & "\DefaultIcon", "")
		If @error Then
			RegWrite("HKCR\" & $loc & "\DefaultIcon", "", "REG_SZ", $icon)
		Else
			RegWrite("HKCR\" & $loc & "\DefaultIcon", "", "REG_SZ", $icon)
			RegWrite("HKCR\" & $loc & "\DefaultIcon", "oldicon", "REG_SZ", $curicon)
		EndIf
	EndIf
EndFunc
;===============================================================================
; Description:		FileUnRegister($ext, $verb)
;					UnRegisters a verb for a file type in Explorer
; Parameter(s):		$ext - File Extension without period eg. "zip"
;					$verb - Name of file action to remove
;							eg. "Open with ProgramName" or "Extract Files"
;===============================================================================
Func _FileUnRegister($ext, $verb)
	$loc = RegRead("HKCR\." & $ext, "")
	If Not @error Then
		$oldicon = RegRead("HKCR\" & $loc & "\shell", "oldicon")
		If Not @error Then
			RegWrite("HKCR\" & $loc & "\DefaultIcon", "", "REG_SZ", $oldicon)
		Else
			RegDelete("HKCR\" & $loc & "\DefaultIcon", "")
		EndIf
		$oldverb = RegRead("HKCR\" & $loc & "\shell", "oldverb")
		If Not @error Then
			RegWrite("HKCR\" & $loc & "\shell", "", "REG_SZ", $oldverb)
		Else
			RegDelete("HKCR\" & $loc & "\shell", "")
		EndIf
		$olddesc = RegRead("HKCR\" & $loc, "olddesc")
		If Not @error Then
			RegWrite("HKCR\" & $loc, "", "REG_SZ", $olddesc)
		Else
			RegDelete("HKCR\" & $loc, "")
		EndIf
		$oldcmd = RegRead("HKCR\" & $loc & "\shell\" & $verb & "\command", "oldcmd")
		If Not @error Then
			RegWrite("HKCR\" & $loc & "\shell\" & $verb & "\command", "", "REG_SZ", $oldcmd)
			RegDelete("HKCR\" & $loc & "\shell\" & $verb & "\command", "oldcmd")
		Else
			RegDelete("HKCR\" & $loc & "\shell\" & $verb)
		EndIf
	EndIf
EndFunc
;===============================================================================
; Function:		_SetDefaultContextItem
; Purpose:		Set default context item for file type
; Syntax:		_SetDefaultContextItem($sExtention)
; Parameters:	$sExtention = File extention
;				$sVerb = Verb to set as default
; Returns:  	Success - 1
;				Failure - 0
; Notes:
; Author:
; Date/Version:   	10/15/2014  --  v1.1
;===============================================================================
Func _SetDefaultContextItem($sExtention, $sVerb)
	local $sRegistryLocation = RegRead("HKCR\." & $sExtention, "")
	If @error Then return 0

	RegWrite("HKCR\" & $sRegistryLocation & "\shell", "", "REG_SZ", $sVerb)
	If @error Then return 0
	return 1
EndFunc
;===============================================================================
; Function:		_GetDefaultContextItem
; Purpose:		Get default context item for file type
; Syntax:		_GetDefaultContextItem($sExtention)
; Parameters:	$sExtention = File extention
; Returns:  	Success - Current Verb
;				Failure - 0
; Notes:
; Author:
; Date/Version:   	10/15/2014  --  v1.1
;===============================================================================
Func _GetDefaultContextItem($sExtention)
	Local $sRegistryLocation = RegRead("HKCR\." & $sExtention, "")
	If @error Then return 0

	Local $sVerb = RegRead("HKCR\" & $sRegistryLocation & "\shell", "")
	If @error Then return 0

	return $sVerb
EndFunc
;===============================================================================
; Function:		_GetBroadcast
; Purpose:		Get the UDP broadcast ip address for the adapter address specified
; Syntax:		_GetBroadcast($sIP)
; Parameters:	$sIP = IP address that is currently adisgned to an adapter
; Returns:  	Success - Broadcast address
;				Failure - 0
; Notes:
; Author:
; Date/Version:   	10/15/2014  --  v1.1
;===============================================================================
Func _GetBroadcast($sIP)
    $objWMIService = ObjGet("winmgmts:{impersonationLevel=Impersonate}!\\" & @ComputerName & "\root\cimv2")
    If Not IsObj($objWMIService) Then Exit
    $colAdapters = $objWMIService.ExecQuery ("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")
    For $objAdapter in $colAdapters
        If Not ($objAdapter.IPAddress) = " " Then
            For $i = 0 To UBound($objAdapter.IPAddress)-1
                If $objAdapter.IPAddress($i)=$sIP Then
					Local $BC=""
					$IP=StringSplit($objAdapter.IPAddress($i) , ".")
					$MASK=StringSplit($objAdapter.IPSubnet($i) , ".")
					If $IP[0]<>4 Then Return SetError(1,0,0)
					If $MASK[0]<>4 Then Return SetError(2,0,0)
					For $i=1 To 4
						$BC&=BitXOR(BitXOR($MASK[$i],255),BitAND($IP[$i],$MASK[$i]))&"."
					Next
					Return StringTrimRight($BC,1)
				endif
            Next
        EndIf
    Next
    Return 0
EndFunc
;===============================================================================
; Function:		_SocketToIP
; Purpose:		Get the IP a socket is connected to
; Syntax:		_SocketToIP($iSocket)
; Parameters:	$iSocket
; Returns:  	Success -
;				Failure -
; Notes:
; Author:
; Date/Version:   	10/15/2014  --  v1.1
;===============================================================================
Func _SocketToIP($iSocket)
    Local $aRet
    Local $sSockAddress = DllStructCreate("short;ushort;uint;char[8]")

    $aRet = DllCall("Ws2_32.dll", "int", "getpeername", "int", $iSocket, _
            "ptr", DllStructGetPtr($sSockAddress), "int*", DllStructGetSize($sSockAddress))
    If Not @error And $aRet[0] = 0 Then
        $aRet = DllCall("Ws2_32.dll", "str", "inet_ntoa", "int", DllStructGetData($sSockAddress, 3))
        If Not @error Then $aRet = $aRet[0]
    Else
        $aRet = 0
    EndIf

    $sSockAddress = 0

    Return $aRet
EndFunc
