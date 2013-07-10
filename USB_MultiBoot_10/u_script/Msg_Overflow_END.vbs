Dim MyVar, strMsg

strMsg = vbCrLf & _
"*****  용량넘침!  *****      " & vbCrLf & vbCrLf & _
"USB-Drive의 남은공간이 너무 작아요. 어쩔수 없이 프로그램이 종료됩니다. " & vbCrLf & vbCrLf

 
MyVar = MsgBox (strMsg, 48, "           OVERFLOW - END PROGRAM  ")
   ' MyVar contains either 6=Yes or 7=No, depending on which button is clicked.
wscript.echo MyVar
