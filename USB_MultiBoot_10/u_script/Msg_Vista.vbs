Dim MyVar, strMsg

strMsg = vbCrLf & _
"***  NTLDR 부트섹터가 USB-Drive에서 발견되지 않았습니다. - Vista Format *** " & vbCrLf & vbCrLf & _
"Yes = " & vbCrLf & _
"Windows XP boot.ini 메뉴에 필요한 NTLDR 부트섹터를 만듭니다. " & vbCrLf & vbCrLf & _
"No  = " & vbCrLf & _
"멈추고 프로그램을 종료합니다.                                " & vbCrLf & vbCrLf

 
MyVar = MsgBox (strMsg, 52, "           WARNING - USB-Drive의 부트섹터를 바꿉니다. - 계속진행?  ")
   ' MyVar contains either 6=Yes or 7=No, depending on which button is clicked.
wscript.echo MyVar
