@ECHO OFF
CLS
:: Check Windows version
IF NOT "%OS%"=="Windows_NT" GOTO Syntax

SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

:: Give XP Source Directory with Location of DOSNET.INF
SET xpsource=
SET bttarget=
:: SET btdir=$WIN_NT$.~BT
SET btdir=XPBT

IF "%btdir%" == "" (
        echo.
        echo  Bootfolder Name NOT Valid
        echo.
	goto _end_quit
)

:_main
ECHO.
ECHO  BT_folder4.cmd Batch Program for Windows XP - 14 mar 2008
echo.
echo  Parse DOSNET.INF for making Windows XP Setup Bootfolder $WIN_NT$.~BT
echo.
echo     1) Change Windows XP Source Path  , currently [%xpsource%]
echo.
echo     2) Change Destination Directory   , currently [%bttarget%]
echo.
echo     3) Make Target Windows XP Setup Bootfolder %btdir%
echo.
echo     Q) Quit
echo.

set _ok=
set /p _ok= Enter your choice: 
if "%_ok%" == "1" goto _getsrc
if "%_ok%" == "2" goto _gettmp
if "%_ok%" == "3" goto _mktemp
if /I "%_ok%" == "q" goto _end_quit
ECHO.
ECHO ***** NOT in Menu - Wrong Selection - Try Again *****
ECHO.
pause
goto :_main

:_getsrc
set src_ok=
echo.
echo  Please give the location to your Windows XP Source Files
ECHO  e.g if you have C:\XPSOURCE\I386 type C:\XPSOURCE
ECHO.
set /p src_ok= Enter Source path:
ECHO %src_ok%|FIND " "
IF "%ERRORLEVEL%"=="0" (
  echo.
  echo  ***** Error: Selected Path does Contain Spaces and is Invalid *****
  echo.
  echo     Solution: Rename Folder or Change to Path without Spaces
  echo.
  pause
  goto _main
)
 
if exist %src_ok%\i386\nul (
        SET xpsource=%src_ok%
) else (
	echo.
	echo  Error: The path %src_ok% does not contain Windows XP Source Files
        echo.
	pause
)
goto _main

:_gettmp
set _ok=
echo.
echo  Give Target Directory Path for making Windows XP Setup Bootfolder %btdir%
ECHO.
set /p _ok= Enter Target Directory Path: 
if exist !_ok!\nul (
  SET bttarget=!_ok!
  if EXIST !bttarget!\%btdir%\nul (
        echo.
	echo  ***** WARNING Existing XP Bootfolder %btdir% Detected   *****
        echo  ***** Files will be Replaced when Making %btdir% Folder *****
        echo.
	pause
  )
) ELSE (
  echo  Directory Path !_ok! Does NOT Exists, Make Selection Again
  echo.
  pause
)
goto _main

:_mktemp
IF "%xpsource%" == "" (
        echo  Please give first valid XP Source Path
        echo.
	pause
	goto _main
)

IF "%bttarget%" == "" (
        echo  Please give first valid Destination Directory
        echo.
	pause
	goto _main
)

:: Make Destination directories for XP Setup Bootfolder
IF NOT EXIST %bttarget%\%btdir%\nul MD %bttarget%\%btdir%
IF NOT EXIST %bttarget%\%btdir%\system32\nul MD %bttarget%\%btdir%\system32


SET cpyflag=0
FOR /F "tokens=1,2,3* delims=, " %%G IN (%xpsource%\I386\DOSNET.INF) DO (
  SET FTAG=%%G
  SET FTAG=!FTAG:~0,13!
  IF "!FTAG!"=="[FloppyFiles." ( 
    SET cpyflag=1
    IF "%%G"=="[FloppyFiles.x]" SET cpyflag=0
  ) ELSE (
    SET FTAG=!FTAG:~0,1!
    IF "!FTAG!"=="[" SET cpyflag=0
    IF "!cpyflag!"=="1" (
      SET btfile=%%H
      IF "%%I"=="" (
         SET btfile=!btfile:~0,-1!*
         xcopy %xpsource%\I386\!btfile! %bttarget%\%btdir% /i /k /y /h
      ) ELSE (
         copy /y %xpsource%\I386\%%H %bttarget%\%btdir%\%%I
      )
    ) 
  )
)

ECHO.
ECHO  Making Windows XP Setup Bootfolder %bttarget%\%btdir% - READY
GOTO :_end_quit

:Syntax
ECHO.
ECHO  BT_folder.cmd,  Version 1.0 for Windows XP
ECHO.
ECHO  Parse DOSNET.INF for making Windows XP Setup Bootfolder $WIN_NT$.~BT 
ECHO.

:_end_quit
ECHO.
ECHO  End BT_folder.cmd Batch Program
ECHO.
pause
EXIT
