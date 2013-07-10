Option Explicit

' WScript.Echo BrowseFolder( "C:\Program Files", True )
WScript.Echo BrowseFolder( "My Computer", False )
' WScript.Echo BrowseFolder( "", False )


Function BrowseFolder( myStartLocation, blnSimpleDialog )
' This function generates a Browse Folder dialog
' and returns the selected folder as a string.
'
' Arguments:
' myStartLocation   [string]  start folder for dialog, or "My Computer", or
'                             empty string to open in "Desktop\My Documents"
' blnSimpleDialog   [boolean] if False, an additional text field will be
'                             displayed where the folder can be selected
'                             by typing the fully qualified path
'
' Returns:          [string]  the fully qualified path to the selected folder
'
' Based on the Hey Scripting Guys article
' "How Can I Show Users a Dialog Box That Only Lets Them Select Folders?"
' http://www.microsoft.com/technet/scriptcenter/resources/qanda/jun05/hey0617.mspx
'
' Function written by Rob van der Woude
' http://www.robvanderwoude.com
	Const MY_COMPUTER   = &H11&
	Const WINDOW_HANDLE = 0 ' Must ALWAYS be 0

	Dim numOptions, objFolder, objFolderItem
	Dim objPath, objShell, strPath, strPrompt

	' Set the options for the dialog window
	strPrompt = "Select a Folder:"
	If blnSimpleDialog = True Then
		numOptions = 0      ' Simple dialog
	Else
		numOptions = &H10&  ' Additional text field to type folder path
	End If
	
	' Create a Windows Shell object
	Set objShell = CreateObject( "Shell.Application" )

	' If specified, convert "My Computer" to a valid
	' path for the Windows Shell's BrowseFolder method
	If UCase( myStartLocation ) = "MY COMPUTER" Then
		Set objFolder = objShell.Namespace( MY_COMPUTER )
		Set objFolderItem = objFolder.Self
		strPath = objFolderItem.Path
	Else
		strPath = myStartLocation
	End If

	Set objFolder = objShell.BrowseForFolder( WINDOW_HANDLE, strPrompt, _
	                                          numOptions, strPath )

	' Quit if no folder was selected
	If objFolder Is Nothing Then
    	BrowseFolder = ""
    	Exit Function
	End If

	' Retrieve the path of the selected folder
	Set objFolderItem = objFolder.Self
	objPath = objFolderItem.Path

	' Return the path of the selected folder
	BrowseFolder = objPath
End Function
