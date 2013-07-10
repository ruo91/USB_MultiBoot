' RW_SIF.VBS is INIFUNCS.VBS of Rob van der Woude, modified for use wth USB_MultiBoot_10.cmd - 02 June 2008

Option Explicit

dim wname, worgn, wpkey, wcomp, wadmn, wtzon, wwork, wuser, rname, rorgn, rpkey, rcomp, radmn, rtzon, rwork, ruser
dim nstr, MyVar, myValue, myTest, my_wsif, my_user, myLen, myButton, pos, myFlag, first_ch, PID_flag, MyMsg

my_wsif=WScript.Arguments(0)
my_user=WScript.Arguments(1)

myLen = Len(my_user)
first_ch=Mid(my_user,1,1)
If first_ch = CHR(34) Then
  ruser=Mid(my_user,2,myLen-2)
Else
  ruser=my_user
End If


wuser=""

PID_flag = 0


' WriteIni "C:\test.ini", "TEST1", "My1stKey", "My1stValue"
' WriteIni "C:\test.ini", "TEST2", "My1stKey", "My1stValue"
' WScript.Echo ReadIni( "C:\test.ini", "TEST1", "My1stKey" )
' WriteIni "C:\test.ini", "TEST1", "My1stKey", "My2ndValue"
' WScript.Echo ReadIni( "C:\test.ini", "TEST1", "My1stKey" )

' Remove Surrounding doublequotes from Actual XP Setup Parameters

myValue=ReadIni( my_wsif, "UserData", "FullName" )
myLen = Len(myValue)
first_ch=Mid(myValue,1,1)
If first_ch = CHR(34) Then
  rname=Mid(myValue,2,myLen-2)
Else
  rname=myValue
End If

myValue=ReadIni( my_wsif, "UserData", "OrgName" )
myLen = Len(myValue)
first_ch=Mid(myValue,1,1)
If first_ch = CHR(34) Then
  rorgn=Mid(myValue,2,myLen-2)
Else
  rorgn=myValue
End If

myValue=ReadIni( my_wsif, "UserData", "productkey" )
If myValue="" Then 
   myValue=ReadIni( my_wsif, "UserData", "ProductID" )
   If myValue <> "" Then PID_Flag = 1
End If
myLen = Len(myValue)
first_ch=Mid(myValue,1,1)
If first_ch = CHR(34) Then
  rpkey=Mid(myValue,2,myLen-2)
Else
  rpkey=myValue
End If

myValue=ReadIni( my_wsif, "UserData", "ComputerName" )
myLen = Len(myValue)
first_ch=Mid(myValue,1,1)
If first_ch = CHR(34) Then
  rcomp=Mid(myValue,2,myLen-2)
Else
  rcomp=myValue
End If

myValue=ReadIni( my_wsif, "GuiUnattended", "AdminPassword" )
myLen = Len(myValue)
first_ch=Mid(myValue,1,1)
If first_ch = CHR(34) Then
  radmn=Mid(myValue,2,myLen-2)
Else
  radmn=myValue
End If

myValue=ReadIni( my_wsif, "GuiUnattended", "TimeZone" )
myLen = Len(myValue)
first_ch=Mid(myValue,1,1)
If first_ch = CHR(34) Then
  rtzon=Mid(myValue,2,myLen-2)
Else
  rtzon=myValue
End If


myValue=ReadIni( my_wsif, "Identification", "JoinWorkgroup" )
myLen = Len(myValue)
first_ch=Mid(myValue,1,1)
If first_ch = CHR(34) Then
  rwork=Mid(myValue,2,myLen-2)
Else
  rwork=myValue
End If

' 현재의 XP 설치 정보

nstr = "1. 소유자 Full Name = " & rname & vbCrLf & vbCrLf & "2. 조직 이름 = " & rorgn & vbCrLf & vbCrLf & _
"3. 시디키 = " & rpkey & vbCrLf & vbCrLf & "4. 컴퓨터 이름 = " & rcomp & vbCrLf & vbCrLf & _
"5. 사용자 비밀번호 = " & radmn & vbCrLf & vbCrLf & "6. 표준시간대 = " & rtzon & vbCrLf & vbCrLf & _
"7. Workgroup명 = " & rwork & vbCrLf & vbCrLf & "8. 첫번째 사용자의 이름 for $OEM$ = " & ruser & vbCrLf & vbCrLf & _
"반자동 무인설치는 (환영합니다) 화면에서 첫번째 사용자의 이름을 수동으로 입력합니다. " & vbCrLf & vbCrLf & _
"현재 정보는 이러합니다.(예)나 (아니오)는 이 정보를 수정합니다. 취소는 이 정보를 그대로 씁니다. " & vbCrLf & vbCrLf & _
"    예=완전 무인설치     아니오=반자동 무인설치   취소=들어있던거 그대로 씀        "
MyVar = MsgBox (nstr, 67, "  Unattand? - XP Setup UserData in winnt.sif and $OEM$    ")

' MyVar contains either 6=Yes 7=No or 2=Cancel, depending on which button is clicked

' 완전자동 무인설치  - Give XP Setup Parameters

If MyVar = 2 Then

  ' MyVar = 2 - Cancel = No changes

  wscript.echo "Cancel"

else

  Do
    myValue=InputBox("사용자이름을 쓰세요 - Max = 20자 제한 " & vbCrLf & vbCrLf & _
            "문자는 0-9 A-Z a-z - Space 가 가능합니다." & vbCrLf & vbCrLf & _
            "기본값 = UserXP " & vbCrLf, "  1. Give Owner Full Name    ", rname)

    wname = Trim ( myValue )

    myTest = VerifyEntry(wname, "[^A-Z0-9a-z- ]")

    myFlag=0
    If StrComp(wname, "Administrator", 1)=0 Then myFlag = 1
    If StrComp(wname, "Guest", 1)=0 Then myFlag = 1
    If StrComp(wname, "Gast", 1)=0 Then myFlag = 1

    If myFlag = 1 Then
       myButton = MsgBox ("User Name Input Invalid", 48, "  User Name Input Invalid  ")
       myTest = 1
    End If

    myLen=Len(wname)
    If myLen > 20 Then
       myButton = MsgBox ("Input Invalid - Length = " & myLen, 48, "  Input Invalid - Max Length = 20  ")
       myTest = 1
    End If
    If wname="" Then wname="UserXP"
    rname=wname
  Loop While myTest > 0


  Do
    myValue=InputBox("조직 이름을 쓰세요 - Max = 20 Chars" & vbCrLf & vbCrLf & _
          "Allowed Characters 0-9 A-Z a-z - Space", "  2. Give Organization Name    ", rorgn)

    worgn = Trim ( myValue )

    myTest = VerifyEntry(worgn, "[^A-Z0-9a-z- ]")

    myLen=Len(worgn)
    If myLen > 20 Then
       myButton = MsgBox ("Input Invalid - Length = " & myLen, 48, "  Input Invalid - Max Length = 20  ")
       myTest = 1
    End If
    rorgn=worgn
  Loop While myTest > 0


  Do
    myValue=InputBox("시디키를 입력하세요:" & vbCrLf & vbCrLf & _
          "12345-ABCDE-12345-ABCDE-12345", "  3. Give Product Key  ", rpkey)

    wpkey = Trim ( myValue )

    myTest = VerifyEntry(wpkey, "[^A-Z0-9a-z-]")

    myFlag=0
    pos=InStr( wpkey, "-")
    If pos <> 6 Then myFlag = 1

    pos=InStr( 7, wpkey, "-")
    If pos <> 12 Then myFlag = 1
        
    pos=InStr( 13, wpkey, "-")
    If pos <> 18 Then myFlag = 1
    
    pos=InStr( 19, wpkey, "-")
    If pos <> 24 Then myFlag = 1

    pos=InStr( 25, wpkey, "-")
    If pos > 24 Then myFlag = 1

    If myFlag > 0 Then
      myButton = Msgbox ("Invalid Position of - Character  ", 48, "  Key Input Invalid  ")
      myTest = 1
    End If

    myLen=Len(wpkey)
    If myLen <> 29 Then
      myButton = MsgBox ("Key Input Invalid - Length = " & myLen, 48, "  Key Input Invalid - 29 Chars Required  ")
      myTest = 1
    End If
    rpkey=wpkey
  Loop While myTest > 0
  

  Do
    myValue=InputBox("컴퓨터의 이름을 입력하세요 - Max = 15 Chars" & vbCrLf & vbCrLf & _
          "자동으로 지정하려면 *를 입력" & vbCrLf & vbCrLf & _
          "Allowed Characters 0-9 A-Z a-z - *" & vbCrLf & vbCrLf & _
          "기본값 = * " & vbCrLf, "  4. Give Computer Name    ", rcomp)

    wcomp = Trim ( myValue )

    myTest = VerifyEntry(wcomp, "[^A-Z0-9a-z-*]")

    myLen=Len(wcomp)
    If myLen > 15 Then
       myButton = MsgBox ("Input Invalid - Length = " & myLen, 48, "  Input Invalid - Max Length = 15  ")
       myTest = 1
    End If
    If wcomp="" Then wcomp="*"
    rcomp=wcomp
  Loop While myTest > 0


  Do
    myValue=InputBox("사용자계정 비밀번호입력 - Max = 20 Chars" & vbCrLf & vbCrLf & _
          "비밀번호 없음은 *을 입력" & vbCrLf & vbCrLf & _
          "Allowed Characters 0-9 A-Z a-z *" & vbCrLf & vbCrLf & _
          "기본값 = * " & vbCrLf, "  5. Give Admin Password    ", radmn)

    wadmn = Trim ( myValue )

    myTest = VerifyEntry(wadmn, "[^A-Z0-9a-z*]")

    myLen=Len(wadmn)
    If myLen > 20 Then
       myButton = MsgBox ("Input Invalid - Length = " & myLen, 48, "  Input Invalid - Max Length = 20  ")
       myTest = 1
    End If
    If wadmn="" Then wadmn="*"
    radmn=wadmn
  Loop While myTest > 0


  Do
    myValue=InputBox("세계표준시간대명을 입력:" & vbCrLf & _
    "002 - Hawaiian Standard Time (GMT-10:00)" & vbCrLf & _
    "004 - Pacific Standard Time (GMT-08:00)" & vbCrLf & _
    "010 - Mountain Standard Time (GMT-07:00)" & vbCrLf & _
    "020 - Central Standard Time (GMT-06:00)" & vbCrLf & _
    "035 - Eastern Standard Time (GMT-05:00)" & vbCrLf & _
    "050 - Atlantic Standard Time (GMT-04:00)" & vbCrLf & _
    "070 - S.A. Eastern Standard Time (GMT-03:00)" & vbCrLf & _
    "085 - GMT London Standard Time (GMT)" & vbCrLf & _
    "110 - W. Europe Standard Time (GMT+01:00)" & vbCrLf & _
    "115 - E. Europe Standard Time (GMT+02:00)" & vbCrLf & _
    "145 - Russian Standard Time (GMT+03:00)" & vbCrLf & _
    "185 - West Asia Standard Time (GMT+05:00)" & vbCrLf & _
    "205 - S.E. Asia Standard Time (GMT+07:00)" & vbCrLf & _
    "210 - China Standard Time (GMT+08:00)" & vbCrLf & _
    "230 - 한국 표준 시간대 (GMT+09:00)" & vbCrLf & _
    "255 - A.U.S. Eastern Standard Time (GMT+10:00)" & vbCrLf & _
    "290 - New Zealand Standard Time (GMT+12:00)", "  6. Give Time Zone - First Three Digits    ", rtzon)
    
    wtzon = Trim ( myValue )

    myTest = VerifyEntry(wtzon, "[^0-9]")

    myLen=Len(wtzon)
    If myLen <> 3 Then
       myButton = MsgBox ("Input Invalid - Length = " & myLen, 48, "  Input Invalid - 3 Digits Required  ")
       myTest = 1
    End If
    rtzon=wtzon
  Loop While myTest > 0


  Do
    myValue=InputBox("Workgroup명 입력 - Max = 20 Chars" & vbCrLf & vbCrLf & _
          "문자는 0-9 A-Z a-z Space까지 가능. 기본값권장" & vbCrLf & vbCrLf & _
          "기본값 = WORKGROUP" & vbCrLf, "  7. Give Workgroup Name    ", rwork)

    wwork = Trim ( myValue )

    myTest = VerifyEntry(wwork, "[^A-Z0-9a-z- ]")

    myLen=Len(wwork)
    If myLen > 20 Then
       myButton = MsgBox ("Input Invalid - Length = " & myLen, 48, "  Input Invalid - Max Length = 20  ")
       myTest = 1
    End If
    If wwork="" Then wwork="WORKGROUP"
    rwork=wwork
  Loop While myTest > 0


  If MyVar = 6 Then
      Do
        myValue=InputBox("첫번째 사용자 계정이름 입력 - Max = 20 Chars" & vbCrLf & vbCrLf & _
              "이것은 nLite에 없는 멋진? 기능입니다. " & vbCrLf & vbCrLf & _
              "환영합니다 화면이후 사용자1의 이름을 정하는 겁니다." & vbCrLf & vbCrLf & _
              "Allowed Characters 0-9 A-Z a-z - Space" & vbCrLf & vbCrLf & _
              "기본값 = UserXP " & vbCrLf, "  8. Give First User Name for useraccounts.cmd", ruser)

        wuser = Trim ( myValue )

        myTest = VerifyEntry(wuser, "[^A-Z0-9a-z- ]")

        myFlag=0
        If StrComp(wuser, "Administrator", 1)=0 Then myFlag = 1
        If StrComp(wuser, "Guest", 1)=0 Then myFlag = 1
        If StrComp(wuser, "Gast", 1)=0 Then myFlag = 1
        If StrComp(wuser, "None", 1)=0 Then myFlag = 1

        If myFlag = 1 Then
           myButton = MsgBox ("User Name Input Invalid", 48, "  User Name Input Invalid  ")
           myTest = 1
        End If

        myLen=Len(wuser)
        If myLen > 20 Then
           myButton = MsgBox ("Input Invalid - Length = " & myLen, 48, "  Input Invalid - Max Length = 20  ")
           myTest = 1
        End If
        If wuser="" Then wuser="UserXP"
        ruser=wuser
      Loop While myTest > 0
  else
      wuser="None"
  End If


  ' Change Parameters in Selected winnt.sif File

  WriteIni my_wsif, "UserData", "ComputerName", wcomp
  If PID_Flag = 0 Then
     WriteIni my_wsif, "UserData", "productkey", CHR(34) & wpkey & CHR(34)
  else
     WriteIni my_wsif, "UserData", "ProductID", CHR(34) & wpkey & CHR(34)
  End If
  WriteIni my_wsif, "UserData", "OrgName", CHR(34) & worgn & CHR(34)
  WriteIni my_wsif, "UserData", "FullName", CHR(34) & wname & CHR(34)
  WriteIni my_wsif, "GuiUnattended", "AdminPassword", wadmn
  WriteIni my_wsif, "GuiUnattended", "TimeZone", wtzon
  WriteIni my_wsif, "Identification", "JoinWorkgroup", CHR(34) & wwork & CHR(34)

  WriteIni my_wsif, "Data", "EulaComplete", CHR(34) & "1" & CHR(34)
  WriteIni my_wsif, "Data", "UnattendedInstall", CHR(34) & "Yes" & CHR(34)
  WriteIni my_wsif, "GuiUnattended", "OEMSkipRegional", CHR(34) & "1" & CHR(34)
  If wuser="None" Then
    WriteIni my_wsif, "Data", "unattendswitch", CHR(34) & "No" & CHR(34)
  else
    WriteIni my_wsif, "Data", "unattendswitch", CHR(34) & "Yes" & CHR(34)
  End If

  ' Display the Result

  rname=ReadIni( my_wsif, "UserData", "FullName" )
  rorgn=ReadIni( my_wsif, "UserData", "OrgName" )
  If PID_Flag = 0 Then
    rpkey=ReadIni( my_wsif, "UserData", "productkey" )
  else
    rpkey=ReadIni( my_wsif, "UserData", "ProductID" )
  End If
  rcomp=ReadIni( my_wsif, "UserData", "ComputerName" )
  radmn=ReadIni( my_wsif, "GuiUnattended", "AdminPassword" )
  rtzon=ReadIni( my_wsif, "GuiUnattended", "TimeZone" )
  rwork=ReadIni( my_wsif, "Identification", "JoinWorkgroup" )


  If MyVar = 6 Then
     nstr = "1. 소유자 Full Name = " & rname & vbCrLf & vbCrLf & "2. 조직 이름 = " & rorgn & vbCrLf & vbCrLf & _
     "3. 시디키 = " & rpkey & vbCrLf & vbCrLf & "4. 컴퓨터 이름 = " & rcomp & vbCrLf & vbCrLf & _
     "5. 사용자 비밀번호 = " & radmn & vbCrLf & vbCrLf & "6. 표준시간대 = " & rtzon & vbCrLf & vbCrLf & _
     "7. Workgroup명 = " & rwork & vbCrLf & vbCrLf & "8. 첫번째 사용자의 이름 for $OEM$ = " & CHR(34) & wuser & CHR(34)
     MyMsg = MsgBox (nstr, 64, " Unattended Install - UserData in Current winnt.sif and $OEM$ - EDIT Ready ")
  else
     nstr = "1. 소유자 Full Name = " & rname & vbCrLf & vbCrLf & "2. 조직 이름 = " & rorgn & vbCrLf & vbCrLf & _
     "3. 시디키 = " & rpkey & vbCrLf & vbCrLf & "4. 컴퓨터 이름 = " & rcomp & vbCrLf & vbCrLf & _
     "5. 사용자 비밀번호 = " & radmn & vbCrLf & vbCrLf & "6. 표준시간대 = " & rtzon & vbCrLf & vbCrLf & _
     "7. Workgroup명 = " & rwork & vbCrLf & vbCrLf & _
     "8. 첫번째 사용자의 이름 = " & CHR(34) & wuser & CHR(34) & "     Semi-Unattended Install " & vbCrLf & vbCrLf & _
     "Allows to Give User Names in Windows Welcome Screens   "
     MyMsg = MsgBox (nstr, 64, "  Semi-Unattended Install - UserData Current winnt.sif and $OEM$ - EDIT Ready           ")
  End If

  wscript.echo wuser

End If

WriteIni my_wsif, "Data", "MsDosInitiated", CHR(34) & "1" & CHR(34)
WriteIni my_wsif, "Data", "floppyless", CHR(34) & "1" & CHR(34)




Function VerifyEntry( myString, myPattern )

  dim objRegEx, strSearchString, colMatches, vmsg, vpos

  Set objRegEx = CreateObject("VBScript.RegExp")

  objRegEx.Global = True   
  objRegEx.Pattern = myPattern

  strSearchString = myString

  Set colMatches = objRegEx.Execute(strSearchString) 

  VerifyEntry=colMatches.Count

  vpos=InStr( myString, "\")
  If vpos > 0 Then VerifyEntry = 1
  If VerifyEntry > 0 Then
    vmsg = MsgBox ("You entered InValid Characters", 48, "  Input Invalid  ")
  End If

End Function


Function ReadIni( myFilePath, mySection, myKey )
	' This function returns a value read from an INI file
	'
	' Arguments:
	' myFilePath  [string]  the (path and) file name of the INI file
	' mySection   [string]  the section in the INI file to be searched
	' myKey       [string]  the key whose value is to be returned
	'
	' Returns:
	' the [string] value for the specified key in the specified section
	'
	' CAVEAT:     Will return a space if key exists but value is blank, removed for USB_MultiBoot.cmd
	'
	' Written by Keith Lacelle
	' Modified by Denis St-Pierre and Rob van der Woude

	Const ForReading   = 1
	Const ForWriting   = 2
	Const ForAppending = 8

	Dim intEqualPos
	Dim objFSO, objIniFile
	Dim strFilePath, strKey, strLeftString, strLine, strSection

	Set objFSO = CreateObject( "Scripting.FileSystemObject" )

	ReadIni     = ""
	strFilePath = Trim( myFilePath )
	strSection  = Trim( mySection )
	strKey      = Trim( myKey )

	If objFSO.FileExists( strFilePath ) Then
		Set objIniFile = objFSO.OpenTextFile( strFilePath, ForReading, False )
		Do While objIniFile.AtEndOfStream = False
			strLine = Trim( objIniFile.ReadLine )

			' Check if section is found in the current line
			If LCase( strLine ) = "[" & LCase( strSection ) & "]" Then
				strLine = Trim( objIniFile.ReadLine )

				' Parse lines until the next section is reached
				Do While Left( strLine, 1 ) <> "["
					' Find position of equal sign in the line
					intEqualPos = InStr( 1, strLine, "=", 1 )
					If intEqualPos > 0 Then
						strLeftString = Trim( Left( strLine, intEqualPos - 1 ) )
						' Check if item is found in the current line
						If LCase( strLeftString ) = LCase( strKey ) Then
							ReadIni = Trim( Mid( strLine, intEqualPos + 1 ) )
							' If ReadIni = "" Then
							' 	ReadIni = " "
							' End If
							' Abort loop when item is found
							Exit Do
						End If
					End If

					' Abort if the end of the INI file is reached
					If objIniFile.AtEndOfStream Then Exit Do

					' Continue with next line
					strLine = Trim( objIniFile.ReadLine )
				Loop
			Exit Do
			End If
		Loop
		objIniFile.Close
	Else
		WScript.Echo strFilePath & " doesn't exists. Exiting..."
		Wscript.Quit 1
	End If
End Function


Sub WriteIni( myFilePath, mySection, myKey, myValue )
	' This subroutine writes a value to an INI file
	'
	' Arguments:
	' myFilePath  [string]  the (path and) file name of the INI file
	' mySection   [string]  the section in the INI file to be searched
	' myKey       [string]  the key whose value is to be written
	' myValue     [string]  the value to be written (myKey will be
	'                       deleted if myValue is empty ( was <DELETE_THIS_VALUE> )
	'
	' Returns:
	' N/A
	'
	' CAVEAT:     WriteIni function needs ReadIni function to run
	'
	' Written by Keith Lacelle
	' Modified by Denis St-Pierre, Johan Pol and Rob van der Woude
        ' Modified for USB_MultiBoot.cmd - delete myKey if myValue is empty

	Const ForReading   = 1
	Const ForWriting   = 2
	Const ForAppending = 8

	Dim blnInSection, blnKeyExists, blnSectionExists, blnWritten
	Dim intEqualPos
	Dim objFSO, objNewIni, objOrgIni, wshShell
	Dim strFilePath, strFolderPath, strKey, strLeftString
	Dim strLine, strSection, strTempDir, strTempFile, strValue

	strFilePath = Trim( myFilePath )
	strSection  = Trim( mySection )
	strKey      = Trim( myKey )
	strValue    = Trim( myValue )

	Set objFSO   = CreateObject( "Scripting.FileSystemObject" )
	Set wshShell = CreateObject( "WScript.Shell" )

	strTempDir  = wshShell.ExpandEnvironmentStrings( "%TEMP%" )
	strTempFile = objFSO.BuildPath( strTempDir, objFSO.GetTempName )

	Set objOrgIni = objFSO.OpenTextFile( strFilePath, ForReading, True )
	Set objNewIni = objFSO.CreateTextFile( strTempFile, False, False )

	blnInSection     = False
	blnSectionExists = False
	' Check if the specified key already exists
	blnKeyExists     = ( ReadIni( strFilePath, strSection, strKey ) <> "" )
	blnWritten       = False

	' Check if path to INI file exists, quit if not
	strFolderPath = Mid( strFilePath, 1, InStrRev( strFilePath, "\" ) )
	If Not objFSO.FolderExists ( strFolderPath ) Then
		WScript.Echo "Error: WriteIni failed, folder path (" _
		           & strFolderPath & ") to ini file " _
		           & strFilePath & " not found!"
		Set objOrgIni = Nothing
		Set objNewIni = Nothing
		Set objFSO    = Nothing
		WScript.Quit 1
	End If

	While objOrgIni.AtEndOfStream = False
		strLine = Trim( objOrgIni.ReadLine )
		If blnWritten = False Then
			If LCase( strLine ) = "[" & LCase( strSection ) & "]" Then
				blnSectionExists = True
				blnInSection = True
			ElseIf InStr( strLine, "[" ) = 1 Then
				blnInSection = False
			End If
		End If

		If blnInSection Then
			If blnKeyExists Then
				intEqualPos = InStr( 1, strLine, "=", vbTextCompare )
				If intEqualPos > 0 Then
					strLeftString = Trim( Left( strLine, intEqualPos - 1 ) )
					If LCase( strLeftString ) = LCase( strKey ) Then
						' Only write the key if the value isn't empty
						' Modification by Johan Pol
						If strValue <> "" Then
							objNewIni.WriteLine strKey & "=" & strValue
						End If
						blnWritten   = True
						blnInSection = False
					End If
				End If
				If Not blnWritten Then
					objNewIni.WriteLine strLine
				End If
			Else
				objNewIni.WriteLine strLine
					' Only write the key if the value isn't empty
					' Modification by Johan Pol
					If strValue <> "" Then
						objNewIni.WriteLine strKey & "=" & strValue
					End If
				blnWritten   = True
				blnInSection = False
			End If
		Else
			objNewIni.WriteLine strLine
		End If
	Wend

	If blnSectionExists = False Then ' section doesn't exist
		objNewIni.WriteLine
		objNewIni.WriteLine "[" & strSection & "]"
			' Only write the key if the value isn't empty
			' Modification by Johan Pol
			If strValue <> "" Then
				objNewIni.WriteLine strKey & "=" & strValue
			End If
	End If

	objOrgIni.Close
	objNewIni.Close

	' Delete old INI file
	objFSO.DeleteFile strFilePath, True
	' Rename new INI file
	objFSO.MoveFile strTempFile, strFilePath

	Set objOrgIni = Nothing
	Set objNewIni = Nothing
	Set objFSO    = Nothing
	Set wshShell  = Nothing
End Sub
