Dim MyVar, strMsg

strMsg = vbCrLf & _
"FileCopy to USB-Drive is Ready - OK - Succes               " & vbCrLf & vbCrLf & _
"" & vbCrLf & _
"Yes = " & vbCrLf & _
"Make USB-stick in XP Setup to be Preferred Boot Drive U:   " & vbCrLf & vbCrLf & _
"No  = " & vbCrLf & _
"For Mixed SATA / PATA Config: Don't change migrate.inf     " & vbCrLf

 
MyVar = MsgBox (strMsg, 68, "         Change Migrate.inf for USB-stick = Boot Drive U:  ")
   ' MyVar contains either 6=Yes or 7=No, depending on which button is clicked.
wscript.echo MyVar
