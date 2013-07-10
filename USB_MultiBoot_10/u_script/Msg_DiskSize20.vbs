Dim MyVar, strMsg

strMsg = vbCrLf & _
"*****  설정된 드라이브 크기가 20기가보다 더 큽니다. 맞습니까? *****          " & vbCrLf & vbCrLf & _
"네 = 나도 내가 뭘 하고 있는지 압니다. - 전 드라이브를 똑바로 잡았습니다.    " & vbCrLf & vbCrLf & _
"아니오  = 헉, 메인메뉴로 돌아가서 다시 설정해보겠습니다.          " & vbCrLf & vbCrLf

 
MyVar = MsgBox (strMsg, 308, "           WARNING - DiskSize Over 20 GB - CONTINUE ?  ")
   ' MyVar contains either 6=Yes or 7=No, depending on which button is clicked.
wscript.echo MyVar
