dim fs, d, n, dr_arg

dr_arg=Wscript.Arguments(0)

set fs=CreateObject("Scripting.FileSystemObject")
set d=fs.GetDrive(dr_arg)
wscript.echo(d.IsReady)

' n = "The " & d.DriveLetter
' if d.IsReady=true then 
'    n = n & " 드라이브 준비됨."
' else
'    n = n & " 드라이브 준비안됨."
' end if 
' wscript.echo(n)

set d=nothing
set fs=nothing
