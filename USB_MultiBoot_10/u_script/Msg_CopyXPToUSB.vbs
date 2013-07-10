Dim MyVar, strMsg

strMsg = vbCrLf & _
"예 = XP + EXTRA Sources를 USB-Drive로 복사합니다.(권장)_    " & vbCrLf & vbCrLf & _
"아니오  = 오직 EXTRA Sources만을 USB-Drive로 복사합니다.    " & vbCrLf & vbCrLf & _
"취소 = 멈춤 - 프로그램을 종료합니다.                               " & vbCrLf & vbCrLf

 
MyVar = MsgBox (strMsg, 67, "        XP Source를 USB로 복사합니다. - 약 15분  ")
   ' MyVar contains either 6=Yes 7=No or 2=Cancel, depending on which button is clicked.
wscript.echo MyVar
