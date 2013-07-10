Dim MyVar, strMsg

strMsg = vbCrLf & _
"당신이 고른 비스타 경로에 BOOTMGR이 없습니다. 맞습니까?      " & vbCrLf & vbCrLf & _
"네 = 나도압니다. - 잘 고른거니 계속 합시다.        " & vbCrLf & vbCrLf & _
"아니오  = 메인메뉴로 돌아가서 VISTA Source 경로를 다시 고를께요. " & vbCrLf & vbCrLf

 
MyVar = MsgBox (strMsg, 308, "           WARNING - BOOTMGR이 없습니다. - 계속하시겠습니까?  ")
   ' MyVar contains either 6=Yes or 7=No, depending on which button is clicked.
wscript.echo MyVar
