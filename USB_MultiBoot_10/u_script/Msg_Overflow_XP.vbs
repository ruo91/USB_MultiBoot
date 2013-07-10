Dim MyVar, strMsg

strMsg = vbCrLf & _
"*****  WARNING  *****  - Low Disk Space  - CONTINUE ?  *****      " & vbCrLf & vbCrLf & _
"Yes = Copy XP Source to USB-Drive - 15 minutes - Overwrite Files  " & vbCrLf & vbCrLf & _
"No  = STOP - End Program                                          " & vbCrLf & vbCrLf

 
MyVar = MsgBox (strMsg, 52, "           WARNING - Low Disk Space  - CONTINUE ?  ")
   ' MyVar contains either 6=Yes or 7=No, depending on which button is clicked.
wscript.echo MyVar
