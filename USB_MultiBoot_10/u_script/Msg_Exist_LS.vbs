Dim MyVar, strMsg

strMsg = vbCrLf & _
"*****  WARNING  *****  "& vbCrLf & _
"$WIN_NT$.~LS가 USB-Drive에서 발견되었습니다.  *****   " & vbCrLf & vbCrLf & _
"네 = " & vbCrLf & _
"그냥 다 덮어씌웁니다.(안좋은거 아니에요.) - 약 15분                 " & vbCrLf & vbCrLf & _
"아니오  = " & vbCrLf & _
"무조건 대체하지않고 Total Commander로 동기화를 해서 낮은버전의 것만 교체합니다. " & vbCrLf & vbCrLf

 
MyVar = MsgBox (strMsg, 52, "           WARNING - Existing Folder $WIN_NT$.~LS  - CONTINUE ?  ")
   ' MyVar contains either 6=Yes or 7=No, depending on which button is clicked.
wscript.echo MyVar
