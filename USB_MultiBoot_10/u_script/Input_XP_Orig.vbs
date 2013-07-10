dim myValue, myTest, myLen, myButton, myXP, myWin

myWin = "Original XP"
  
Do
    myValue=InputBox("당신의 원본 XP에게 새 이름을 줍니다." & vbCrLf & vbCrLf & _
                     "Entry in boot.ini Menu - Max = 20자 제한" & vbCrLf & vbCrLf & _
                     "Allowed Characters 0-9 A-Z a-z - Space" & vbCrLf & vbCrLf & _
                     "Default = Original XP " & vbCrLf, "Give NEW Name for Original XP in boot.ini Menu", myWin)

    myXP = Trim ( myValue )

    myTest = VerifyEntry(myXP, "[^A-Z0-9a-z- ]")

    myLen=Len(myXP)
    If myLen > 20 Then
       myButton = MsgBox ("Input Invalid - Length = " & myLen, 48, "  Input Invalid - Max Length = 20  ")
       myTest = 1
    End If
    If myXP="" Then myXP="Original XP"
    myWin=myXP
Loop While myTest > 0
wscript.echo myXP

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
