dim fs, d, n, dr_arg

dr_arg=Wscript.Arguments(0)

set fs=CreateObject("Scripting.FileSystemObject")
set d=fs.GetDrive(dr_arg)
wscript.echo d.FileSystem

' n = "Drive:   " & d
' n = n & vbCrLf & vbCrLf & "파일시스템은 : " & d.FileSystem
' wscript.echo n

set d=nothing
set fs=nothing
