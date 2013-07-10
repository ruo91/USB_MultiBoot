Dim MyVar, strMsg

strMsg = vbCrLf & vbCrLf & _
"Existing XP Folder $WIN_NT$.~LS on USB-Drive Detected    " & vbCrLf & vbCrLf & _
"Yes = " & vbCrLf & _
"Create New XP Source next to Existing XP Folders on USB-Drive - 15 min  " & vbCrLf & vbCrLf & _
"No  = " & vbCrLf & _
"Update Existing XP Folder $WIN_NT$.~LS on USB-Drive  " & vbCrLf & vbCrLf

 
MyVar = MsgBox (strMsg, 52, "           Multiple XP Install from USB ?  ")
   ' MyVar contains either 6=Yes or 7=No, depending on which button is clicked.
wscript.echo MyVar
