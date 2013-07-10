dim myValue, myTest, myLen, myButton, myXP, myWin

myWin = "Windows XP"
  
Do
    myValue=InputBox("EXTRA XP Source의 이름을 정해주세요" & vbCrLf & vbCrLf & _
                     "Entry for boot.ini Menu - Max = 20자 제한" & vbCrLf & vbCrLf & _
                     "Allowed Characters 0-9 A-Z a-z - Space" & vbCrLf & vbCrLf & _
                     "Default = Windows XP " & vbCrLf, "Give Name of EXTRA XP Source for boot.ini Menu", myWin)

    myXP = Trim ( myValue )

    myTest = VerifyEntry(myXP, "[^A-Z0-9a-z- ]")

    myLen=Len(myXP)
    If myLen > 20 Then
       myButton = MsgBox ("Input Invalid - Length = " & myLen, 48, "  Input Invalid - Max Length = 20  ")
       myTest = 1
    End If
    If myXP="" Then myXP="Windows XP"
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
    vmsg = MsgBox ("바람직하지 못합니다.", 48, "  Input Invalid  ")
  End If

End Function
