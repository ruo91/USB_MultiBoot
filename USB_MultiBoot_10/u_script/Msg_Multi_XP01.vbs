Dim MyVar, strMsg

strMsg = vbCrLf & vbCrLf & _
"이제 $WIN_01$.~LS 폴더가 USB-Drive에 만들어졌습니다. " & vbCrLf & vbCrLf & _
"예 = " & vbCrLf & _
"USB에 XP설치파일들을 복사합니다. - 예상소요시간 15분 " & vbCrLf & vbCrLf & _
"아니오  = " & vbCrLf & _
"취소 - 프로그램을 종료합니다.   " & vbCrLf & vbCrLf

 
MyVar = MsgBox (strMsg, 52, "           Multiple XP Install from USB ?  ")
   ' MyVar contains either 6=Yes or 7=No, depending on which button is clicked.
wscript.echo MyVar
