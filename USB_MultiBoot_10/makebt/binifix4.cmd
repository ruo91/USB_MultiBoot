@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
::> binifix4.cmd 
::> Small batch to adjust rdisk(z) in BOOT.INI
::> by jaclaz
::> Will change the Default entry in BOOT.INI on the Drive given as parameter
::> USAGE:
::> binifix4.cmd [drive]
::> ...
::> Example:
::> binifix4.cmd W:
::> ...
::> Will change file W:\BOOT.INI
::> ...
::> If no parameter is given, it will ask for a drive letter
::> File slightly modified for Unattended Install - 18-08-2007


IF %1.==. (
CALL :USAGE "%~fx0"
ECHO Drive has not been specified on command line.
ECHO Please Input Drive below:
SET /P drive=
) ELSE (
SET drive=%1
)

SET drive=%drive:~0,1%:
IF NOT EXIST %drive%\nul GOTO :Error
SET Source=%drive%\BOOT.INI
SET BOOTTXT=%drive%\BOOT.TXT


CLS
ECHO Drive is: %drive% Source file is: %Source%
ECHO.

Set /A Counter=0
GOTO :backuploop
:IncreaseCounters

:backuploop
SET /A Counter=%Counter%+1
IF %Counter%==4 GOTO :Error3
Set dest=%drive%\BOOT.00%Counter%
CALL :attribs %source%
IF NOT EXIST %dest% (Copy /b %source% %dest%>nul) Else (goto :Backuploop)
ATTRIB !switches! %source%>nul
ATTRIB !switches! %dest%>nul

FOR /F "tokens=1,* delims==" %%A in (%source%) DO (
Call :ClearTrailLeft %%A
Call :CleartrailRight %%B
IF /I "!Left!"=="default" SET DefaultEntry=!Right!
IF "!Left!"=="!DefaultEntry!" SET EntryDesc=!Right!
IF /I "!Left!"=="Timeout" SET Timeout=!Right!
)


FOR %%A IN (DefaultEntry EntryDesc Timeout) DO IF NOT DEFINED %%A CALL :Error0 %%A&GOTO :EOF

ECHO Default entry is currently:
ECHO %DefaultEntry%
ECHO.
ECHO Description for Default entry is:
ECHO %EntryDesc%

SET BusType=%DefaultEntry:~0,4%
IF %BusType%==scsi SET /A CharOffset=20
IF %BusType%==mult SET /A CharOffset=21
IF %BusType%==sign SET /A CharOffset=32
IF NOT DEFINED CharOffset GOTO :Error1
Set /A rdisk=!DefaultEntry:~%CharOffset%,1!
IF NOT DEFINED rdisk GOTO :Error
IF %rdisk%==0 GOTO :Error2
SET /A rdisk=%rdisk%-1

::Check length of DefaultEntry
Set /A Counter=1
:Loop1
Set DefaultEntryLen=!DefaultEntry:~0,%counter%!
IF NOT %DefaultEntryLen%==%DefaultEntry% SET /A Counter=%Counter%+1&GOTO :Loop1
Set /A DefaultEntryLen=%Counter%
SET EntryHead=!DefaultEntry:~0,%CharOffset%!
SET /A CharOffset=%CharOffset%+1 
SET EntryTail=!DefaultEntry:~%CharOffset%,%DefaultEntryLen%!
IF %BusType%==sign CALL :FixSignature

ECHO.
ECHO New Default entry will be:
ECHO %EntryHead%%rdisk%%EntryTail%
Call :Olddefault %EntryDesc%
ECHO.
ECHO.Old one will be added as last entry as follows:
ECHO %Olddefault%
REM Rule with PAUSE disabled - edit 18-08-2007 
REM PAUSE

FOR /F "tokens=1,* delims==" %%A in (%source%) DO (
Call :ClearTrailLeft %%A
Call :CleartrailRight %%B
IF NOT "%%A"=="" CALL :WriteEntry
)
ECHO %DefaultEntry%=%Olddefault%>>%BOOTTXT%

SET Confirm=NO
ECHO.
ECHO The new settings have been written to file "%BOOTTXT%":
ECHO.

REM ECHO Do you want to overwrite existing %source% with "%BOOTTXT%"?
REM ECHO You need to type "YES" (without quotes and in CAPITAL letters)
REM ECHO to do this, any other value will abort the batch.
REM SET /P Confirm=
REM IF %Confirm%.==YES. GOTO :WriteBootIni 
REM GOTO :EOF

REM Edit 18-08-2007, above 6 rules disabled
REM Instead of the above 6 rules, the following rule is used for automatic Confirmation
GOTO :WriteBootIni

:FixSignature
SET BackupEntry=%DefaultEntry%
SET /A rdisk=%rdisk%+1
SET EntryHead=multi(0)disk(0)rdisk(
GOTO :EOF


:ClearTrailLeft
Set Left=%*
GOTO :EOF

:ClearTrailRight
Set Right=%*
GOTO :EOF

:WriteEntry
IF /I "!Left!"=="[Boot Loader]" ECHO [Boot Loader]>%BOOTTXT%
IF /I "!Left!"=="[Operating Systems]" ECHO [Operating Systems]>>%BOOTTXT%
IF /I "!Left!"=="Default" ECHO Default=%EntryHead%%rdisk%%EntryTail%>>%BOOTTXT%
IF /I NOT "!Left!"=="Default" IF NOT "!Right!"=="" IF NOT "!Left!"=="!DefaultEntry!" ECHO !Left!=!Right!>>%BOOTTXT%
IF "!Left!"=="!DefaultEntry!" ECHO %EntryHead%%rdisk%%EntryTail%=%EntryDesc%>>%BOOTTXT%
IF "!Left!"=="!BackupEntry!" ECHO !Left!=(signature) %EntryDesc%>>%BOOTTXT%
GOTO :EOF

:WriteBootIni
CALL :attribs %source%
Copy %BOOTTXT% %source%
del %BOOTTXT%
ATTRIB !switches! %source%>nul
GOTO :EOF

:attribs
SET attribs=%~a1
ATTRIB -h -r -s %source%
Set IsR=%attribs:~1,1%
Set IsH=%attribs:~3,1%
Set IsS=%attribs:~4,1%
For %%A in (%IsR% %IsH% %IsS%) DO IF NOT "%%A"=="-" SET Switches=!Switches! +%%A
GOTO :EOF

:OldDefault
SET DescTemp=%1
SET DescTemp=%DescTemp:"=%
SET OldDefault=!EntryDesc:%DescTemp%=USB Repair NOT to Start %Desctemp%!
GOTO :EOF

:Error
ECHO.
ECHO ERROR
ECHO Parameter %1 is wrong, aborting.
PAUSE
GOTO :EOF

:Error0
ECHO.
ECHO ERROR
ECHO Variable %1 has not been set, %source% or a needed entry in it is missing.
PAUSE
GOTO :EOF

:Error1
ECHO.
ECHO ERROR
ECHO DefaultEntry is %DefaultEntry%
ECHO.
ECHO The Default entry in BOOT.INI is NOT of types:
ECHO scsi(x)disk(y)rdisk(z)partition(w)\WINDIR
ECHO multi(0)disk(0)rdisk(z)partition(w)\WINDIR
ECHO signature(aabbccdd)disk(0)rdisk(z)partition(w)\WINDIR
PAUSE
GOTO :EOF

:Error2
ECHO.
ECHO ERROR
ECHO DefaultEntry is %DefaultEntry%
ECHO.
ECHO The rdisk value is ALREADY 0
ECHO You don't want me to set it as -1, don't you?
PAUSE
GOTO :EOF

:Error3
ECHO.
ECHO ERROR
ECHO You already have 3 backups of %source%
ECHO.
ECHO Please delete older ones.
ECHO Program aborted.
PAUSE
GOTO :EOF

:USAGE
ECHO.
SET Thisfile=%1
IF EXIST %Thisfile% MORE %Thisfile% | FIND "::>"| FIND /V "MORE"
GOTO :EOF