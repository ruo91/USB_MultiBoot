Dim MyVar, strMsg

strMsg = vbCrLf & _
"XPSOURCE에서 $OEM$폴더가 발견되었습니다. " & vbCrLf & _
"각종 레지스트리 트윅과 첫번째 사용자계정명 자동입력을 사용하겠습니까? " & vbCrLf & vbCrLf & _
"네 = " & vbCrLf & _
"XPSOURCE에 있는 $OEM$폴더를 복사해서 USB로 XP를 설치할 때 사용할게요. " & vbCrLf & vbCrLf & _
"아니오  = " & vbCrLf & _
"그 $OEM$ 폴더 말고 그냥 현재 선택되있는 기본 $OEM$ 폴더를 사용할께요. " & vbCrLf & vbCrLf

 
MyVar = MsgBox (strMsg, 68, "           Use $OEM$ Folder Setup Parameters from XPSOURCE ?  ")
   ' MyVar contains either 6=Yes or 7=No, depending on which button is clicked.
wscript.echo MyVar
