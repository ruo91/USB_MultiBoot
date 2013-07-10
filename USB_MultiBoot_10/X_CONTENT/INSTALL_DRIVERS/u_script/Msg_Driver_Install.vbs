Dim MyVar, strMsg

strMsg = vbCrLf & _
"DevicePath was SET to Selected Driver Folders, Continue with:        " & vbCrLf & vbCrLf & _
"1. Device Manager:" & vbCrLf & _
"     R-Mouse Device - Select Driver Update ....      " & vbCrLf & vbCrLf & _
"2. Wizard Hardware:            " & vbCrLf & _
"     Select NO WinUpdate and Automatic Install of Driver Software      " & vbCrLf & vbCrLf & _
"3. After Driver Update:            " & vbCrLf & _
"     Close Device Manager and Select Next Driver Type from Menu        " & vbCrLf & vbCrLf

 
MyVar = MsgBox (strMsg, 64, "         Driver Install - Information  ")
wscript.echo MyVar
