TITLE REMOVE_DUMMY.CMD - Make ALL USB-sticks seen as Removable Disks
CLS
@echo off

ECHO.
ECHO  This Batch Program Removes dummy subkey from your HKLM Registry Key
ECHO  So that After Restart ALL USB-sticks are seen as Removable Disks
ECHO.
ECHO  dummydisk.sys was developed by Anton Bassov
ECHO  http://www.codeproject.com/KB/system/soviet_direct_hooking.aspx
ECHO.
ECHO.
pause

start /wait REG.EXE DELETE HKLM\SYSTEM\ControlSet001\Services\dummy

ECHO.
ECHO  dummy subkey was Removed from your HKLM Registry, Restart Computer to Activate
ECHO.
ECHO  END Program - REMOVE_DUMMY.CMD will be Closed
ECHO.
PAUSE
EXIT
