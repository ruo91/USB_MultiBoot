TITLE INSTALL_DUMMY.CMD - Make ALL USB-sticks seen as Fixed Local Harddisk
CLS
@echo off

ECHO.
ECHO  This Batch Program Installs dummy.sys in Your WINDOWS\system32\drivers Folder
ECHO  So that After Restart ALL USB-sticks are seen as Fixed Local Harddisks
ECHO.
ECHO  dummydisk.sys was developed by Anton Bassov
ECHO  http://www.codeproject.com/KB/system/soviet_direct_hooking.aspx
ECHO.
ECHO  Windows Disk Manager can then be used to make New Partitions with NTFS Format
ECHO.
pause

copy /y dummydisk\dummy.sys %systemroot%\system32\drivers\dummy.sys
start /wait REGEDT32.EXE /S dummydisk\dummy.reg

ECHO.
ECHO  dummy.sys was Installed in your System, Restart Computer to Activate
ECHO.
ECHO  END Program - INSTALL_DUMMY.CMD will be Closed
ECHO.
PAUSE
EXIT
