Dim MyVar, strMsg

strMsg = vbCrLf & _
"USB-Drive로 파일복사를 할 준비가 완료됨 " & vbCrLf & vbCrLf
 
MyVar = MsgBox (strMsg, 64, "           USB-Drive로 파일복사를 할 준비가 완료됨 ")

wscript.echo MyVar
