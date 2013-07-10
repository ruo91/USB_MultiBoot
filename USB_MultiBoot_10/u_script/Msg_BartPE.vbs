Dim MyVar, strMsg

strMsg = vbCrLf & _
"*****  WARNING  *****  " & vbCrLf & _
"USB에 BartPE가 들어갈 minint폴더를 만들었습니다. 복사하실거죠?? " & vbCrLf & vbCrLf & _
"네 = USB로 BartPE를 복사해주세요. - 5분정도 걸립니다.              " & vbCrLf & vbCrLf & _
"아니오  = 그냥 꺼버릴거에요 ...                                                        " & vbCrLf & vbCrLf

 
MyVar = MsgBox (strMsg, 52, "           WARNING - Existing BartPE Folder minint  - CONTINUE ?  ")
   ' MyVar contains either 6=Yes or 7=No, depending on which button is clicked.
wscript.echo MyVar
