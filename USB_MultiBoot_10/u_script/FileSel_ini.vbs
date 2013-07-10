dim dr_arg

dr_arg=Wscript.Arguments(0)

WScript.Echo GetFileName( dr_arg, "boot.ini Files (*.ini)|*.ini" )
' WScript.Echo "Selected file: " & GetFileName( "", "Text files|*.txt" )
' WScript.Echo "Selected file: " & GetFileName( "", "MS Office documents|*.doc;*.xls;*.pps" )
' WScript.Echo "Selected file: " & GetFileName( "C:\WINDOWS", "Bitmaps|*.bmp" )

Function GetFileName( myDir, myFilter )
' This function opens a File Open Dialog and returns the
' fully qualified path of the selected file as a string.
'
' Arguments:
' myDir is the initial directory; if no directory is
' specified "My Documents" is used;
' NOTE: this default requires the WScript.Shell
' object, and works only in WSH, not in HTAs!
' myFilter is the file type filter; format "File type description|*.ext"
' ALL arguments MUST get A value (use "" for defaults), OR otherwise you must
' use "On Error Resume Next" to prevent error messages.
'
' Dependencies:
' Requires NUSRMGRLib (nusrmgr.cpl), available in Windows XP and later.
' To use the default "My Documents" WScript.Shell is used, which isn't
' available in HTAs.
'
' Written by Rob van der Woude
' http://www.robvanderwoude.com

    ' Standard housekeeping
    Dim objDialog

    ' Create a dialog object
    Set objDialog = CreateObject( "UserAccounts.CommonDialog" )

    ' Check arguments and use defaults when necessary
    If myDir = "" Then
        ' Default initial folder is "My Documents"
        objDialog.InitialDir = CreateObject( "WScript.Shell" ).SpecialFolders( "MyDocuments" )
    Else
        ' Use the specified initial folder
        objDialog.InitialDir = myDir
    End If
    If myFilter = "" Then
        ' Default file filter is "All files"
        objDialog.Filter = "All files|*.*"
    Else
        ' Use the specified file filter
        objDialog.Filter = myFilter
    End If

    ' Open the dialog and return the selected file name
    If objDialog.ShowOpen Then
        GetFileName = objDialog.FileName
    Else
        GetFileName = ""
    End If
End Function