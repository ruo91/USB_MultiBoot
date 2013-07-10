dim fs,fo, n, dr_arg

dr_arg=Wscript.Arguments(0)

set fs=CreateObject("Scripting.FileSystemObject")
set fo=fs.GetFolder(dr_arg)

wscript.echo(fo.Size)

' n = "The size of the folder D:\UW_CONTENT is: "
' n = n & vbCrLf & vbCrLf & fo.Size & "  bytes"
' wscript.echo(n)

set fo=nothing
set fs=nothing
set dr_arg=nothing