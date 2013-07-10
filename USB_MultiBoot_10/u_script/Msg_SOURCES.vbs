Dim MyVar, strMsg

strMsg = vbCrLf & _
"*****  WARNING  *****  " & vbCrLf & _
"USB에서 비스타 설치 소스폴더를 발견했습니다." & vbCrLf & vbCrLf & _
"Yes = 비스타 설치 파일들을 USB로 복사해서 기존의 파일들을 대체합니다. - 예상소요시간 15분(XP)               " & vbCrLf & vbCrLf & _
"No  = 멈춤 - 프로그램 종료                                                         " & vbCrLf & vbCrLf

 
MyVar = MsgBox (strMsg, 52, "           WARNING - Existing Folder SOURCES  - CONTINUE ?  ")
   ' MyVar contains either 6=Yes or 7=No, depending on which button is clicked.
wscript.echo MyVar
