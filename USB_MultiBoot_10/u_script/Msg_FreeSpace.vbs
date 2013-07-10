Dim fs, d, n, dr_arg

dr_arg=Wscript.Arguments(0)

Set fs=CreateObject("Scripting.FileSystemObject")
Set d=fs.GetDrive(dr_arg)
wscript.echo d.FreeSpace/1024

' n = "Drive:   " & d
' n = n & vbCrLf & vbCrLf & "Free Space  =  " & d.FreeSpace/1024 & "  kB"
' wscript.echo(n)

set d=nothing
set fs=nothing
