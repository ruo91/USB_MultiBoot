Dim MyVar, strMsg

strMsg = vbCrLf & _
"XP소스에서 사용자정보가 입력되어 있는 WINNT.SIF파일이 발견되었습니다.                 " & vbCrLf & vbCrLf & _
"Yes = " & vbCrLf & _
"XP소스에 있는 WINNT.SIF를 사용합니다. 그리고 빈 $OEM$_X Folder를 사용합니다.                  " & vbCrLf & vbCrLf & _
"No  = " & vbCrLf & _
"이 WINNT.SIF를 사용하지 않고 새로 만듭니다.          " & vbCrLf & vbCrLf

 
MyVar = MsgBox (strMsg, 68, "           Use All Setup Parameters from XPSOURCE ?   ")
   ' MyVar contains either 6=Yes or 7=No, depending on which button is clicked.
wscript.echo MyVar
