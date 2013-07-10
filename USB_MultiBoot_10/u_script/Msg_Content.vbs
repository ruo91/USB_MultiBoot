Dim MyVar, strMsg

strMsg = vbCrLf & _
"*****  당신이 고른 드라이브는 사용중인 공간이 5GB가 넘습니다. 맞습니까? *****       " & vbCrLf & vbCrLf & _
"예 = 나도 뭔 상황인지 압니다. 맞으니까 계속 진행 합시다.    " & vbCrLf & vbCrLf & _
"아니오  = 메인메뉴로 가서 USB드라이브를 다시 고르겠습니다.          " & vbCrLf & vbCrLf

 
MyVar = MsgBox (strMsg, 308, "           WARNING - Used Space is More than 5 GB - CONTINUE ?  ")
   ' MyVar contains either 6=Yes or 7=No, depending on which button is clicked.
wscript.echo MyVar
